(*
    NTFS Undelete
    Copyright (C) 2008 Atola Technology.
    http://ntfsundelete.com

    Authors:
      Alexander Malashonok
      Fedir Nepyivoda


    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

unit PythonMisc;

interface

  uses
    Windows, Dialogs, Classes, PythonEngine, SyncObjs, SysUtils, Messages;

type
  TPythonCommand = (
      pcExecuteScript,
      pcEvalString,
      pcExecuteLine,
      pcEvalFunction,
      pcTerminate,
      pcExecMethod,
      pcExecMethodWithNotification
    );
  TPyExecMethod = procedure (context: pointer) of object;
  TPythonRequest = record
    command: TPythonCommand;
    case TPythonCommand of
    pcExecuteScript: (
                  Script: TStrings;
                  FreeOnComplete: boolean;
               );
    pcExecuteLine: (
                  ExecLine: pchar;
               );
    pcEvalString: (
                  EvalLock: TEvent;
                  EvalResult: PPyObject;
                  EvalString: pchar;
               );
    pcEvalFunction: (
                  EvalFunctionLock: TEvent;
                  EvalFunctionResult: PPyObject;
                  EvalFunctionName: pchar;
                  EvalFunctionModule: pchar;
                  EvalFunctionArgs: PPyObject;
              );
    pcExecMethod: (
                  ExecMethod: TPyExecMethod;
                  ExecContext: pointer;
              );
    pcExecMethodWithNotification: (
                  ExecMethodB: TPyExecMethod;
                  ExecContextB: pointer;
                  ExecMethodBMessage: cardinal;
                  ExecMethodBHandle: cardinal;
              );
  end;
  PPythonRequest = ^TPythonRequest;

  TExceptionEvent = procedure (Sender: TObject; E: Exception) of object;
  TPython = class (TThread)
  private
    FPythonEngine: TPythonEngine;
    FCommandList: TList;
    FCommandCS: TCriticalSection;
    FHasCommands: TSimpleEvent;
    FCurrentState: PPyThreadState;
    FEngineMod: TPythonModule;
    FOnException: TExceptionEvent;
    FLastException: Exception;
    FOnInitModules: TNotifyEvent;
    function _PyESys_EngineProcessRequest(_self, args: PPyObject): PPyObject;cdecl;
    procedure InitializeModules;
    procedure DoOnException;
    procedure DoInitModules;
  protected
    procedure Execute;override;
    procedure WaitForRequest;
    function PopRequest: PPythonRequest;
    procedure QueueCommand(p: PPythonRequest);
    procedure ProcessRequest;
  public
    constructor Create(CreateSuspended: boolean);
    destructor Destroy;override;
    procedure BeginAllowThreads;
    procedure EndAllowThreads;
    procedure Acquire;
    procedure Release;

    procedure PushScript(Script: TStrings; FreeOnComplete: boolean);
    procedure PushLine(PythonExec: string);
    function EvalString(S: string): PPyObject;
    function EvalFunction(mod_name, func_name: string; args: PPyObject): PPyObject;
    procedure PushMethod(Meth: TPyExecMethod; context: pointer);
    procedure ExecMethod(Meth: TPyExecMethod; context : pointer; Handle: HWND; Msg: cardinal);
    procedure PushTerminate;

    property OnException: TExceptionEvent read FOnException write FOnException;
    property OnInitModules: TNotifyEvent read FOnInitModules write FOnInitModules;

    // Ќе трогать!!!! - если не уверен, что это безопасно!
    property PythonEngine: TPythonEngine read FPythonEngine;

  end;

  function AllocStr(S: string): pchar;
  procedure FreeStr(S: pchar);

implementation

function AllocStr(S: string): pchar;
var
  L: integer;
begin
  L := length(S);
  result := AllocMem(L+1);
  Move(pchar(S)^, result^, L);
  pchar(result+L)^ := #0;
end;

procedure FreeStr(S: pchar);
begin
  FreeMem(S);
end;

procedure TPython.Acquire;
begin
  FPythonEngine.PyEval_AcquireLock;
end;

procedure TPython.BeginAllowThreads;
begin
  FCurrentState := FPythonEngine.PyEval_SaveThread;
end;

constructor TPython.Create(CreateSuspended: boolean);
begin
  inherited;
  FCommandList := TList.Create;
  FCommandCS := TCriticalSection.Create;
  FHasCommands := TSimpleEvent.Create;
end;

destructor TPython.Destroy;
begin
  FCommandCS.Free;
  FCommandList.Free;
  FHasCommands.Free;
  inherited;
end;


procedure TPython.DoInitModules;
begin
  if Assigned(FOnInitModules) then
    FOnInitModules(self);
end;

procedure TPython.DoOnException;
begin
  if Assigned (FOnException) then begin
    try
      FOnException(self, FLastException);
    except
      on E: Exception do begin
        ShowMessage('Double exception: ' + E.Message);
      end;
    end;
  end;
end;

procedure TPython.EndAllowThreads;
begin
  FPythonEngine.PyEval_RestoreThread(FCurrentState);
end;

function TPython.EvalFunction(mod_name, func_name: string;
  args: PPyObject): PPyObject;
var
  p: PPythonRequest;
begin
  new(p);
  p^.command := pcEvalFunction;
  p^.EvalFunctionLock := TEvent.Create(nil, False, False, '');
  p^.EvalFunctionResult := nil;
  p^.EvalFunctionName := AllocStr(func_name);
  p^.EvalFunctionModule := AllocStr(mod_name);
  p^.EvalFunctionArgs := args;
  QueueCommand(p);
  while p^.EvalFunctionLock.WaitFor(60000) <> wrSignaled do ;
  result := p^.EvalFunctionResult;
  p^.EvalFunctionLock.Free;
  dispose(p);
end;

function TPython.EvalString(S: string): PPyObject;
var
  p: PPythonRequest;
begin
  new(p);
  p^.command := pcEvalString;
  p^.EvalLock := TEvent.Create(nil, False, False, '');
  p^.EvalResult := nil;
  p^.EvalString := pchar(S);
  QueueCommand(p);
  while p^.EvalLock.WaitFor(60000) <> wrSignaled do ;
  result := p^.EvalResult;
  p^.EvalLock.Free;
  dispose(p);
end;

procedure TPython.ExecMethod(Meth: TPyExecMethod; context: pointer; Handle: HWND; Msg: cardinal);
var
  p: PPythonRequest;
begin
  new(p);
  p^.command := pcExecMethodWithNotification;
  p^.ExecMethodB := Meth;
  p^.ExecContextB := context;
  p^.ExecMethodBHandle := Handle;
  p^.ExecMethodBMessage := Msg;
  QueueCommand(p);
end;

procedure TPython.Execute;
begin
  FPythonEngine := TPythonEngine.Create(nil);
  FPythonEngine.DllName := 'Python24.dll';
  FPythonEngine.RegVersion := '2.4';
  if (ParamCount > 0) and (ParamStr(1) = 'console') then
    FPythonEngine.UseWindowsConsole := True;
  FPythonEngine.UseLastKnownVersion := false;
  FPythonEngine.InitThreads := True;
  FPythonEngine.PyFlags := [];
  FPythonEngine.AutoFinalize := True;
  FPythonEngine.InitScript.Add('import esys');
  FPythonEngine.InitScript.Add('import app');
  FPythonEngine.InitScript.Add('import sys');
  FPythonEngine.InitScript.Add('class GUILogger:');
  FPythonEngine.InitScript.Add('    def __init__(self):');
  FPythonEngine.InitScript.Add('        self.__last_line = u""');
  FPythonEngine.InitScript.Add('    def write(self, data):');
  FPythonEngine.InitScript.Add('        line = self.__last_line');
  FPythonEngine.InitScript.Add('        commit = False');
  FPythonEngine.InitScript.Add('        for c in data:');
  FPythonEngine.InitScript.Add('            if c == "\n":');
  FPythonEngine.InitScript.Add('                line = u""');
  FPythonEngine.InitScript.Add('                app.AppendLogMsg(line)');
  FPythonEngine.InitScript.Add('                commit = True');
  FPythonEngine.InitScript.Add('            elif c == "\r":');
  FPythonEngine.InitScript.Add('                app.SetLastLogMsg(line)');
  FPythonEngine.InitScript.Add('                line = u""');
  FPythonEngine.InitScript.Add('                commit = True');
  FPythonEngine.InitScript.Add('            else:');
  FPythonEngine.InitScript.Add('                line += c');
  FPythonEngine.InitScript.Add('                commit = False');
  FPythonEngine.InitScript.Add('        if not commit:');
  FPythonEngine.InitScript.Add('            app.SetLastLogMsg(line)');
  FPythonEngine.InitScript.Add('        self.__last_line = line');
  FPythonEngine.InitScript.Add('    def writelines(self, lines):');
  FPythonEngine.InitScript.Add('        for line in lines:');
  FPythonEngine.InitScript.Add('            self.write(line)');
  FPythonEngine.InitScript.Add('if not app.HasConsole():');
  FPythonEngine.InitScript.Add('    logger = GUILogger()');
  FPythonEngine.InitScript.Add('    sys.stdout = logger');
  FPythonEngine.InitScript.Add('    sys.stderr = logger');

  InitializeModules;
  FPythonEngine.LoadDll;
  while not Terminated do begin
    try
      FPythonEngine.ExecString('esys.engine_process_request()');
    except
      on E: Exception do begin
        FLastException := E;
        Synchronize(DoOnException);
      end;
    end;
  end;
end;

procedure TPython.InitializeModules;
begin
  FEngineMod := TPythonModule.Create(nil);
  FEngineMod.Engine := FPythonEngine;
  FEngineMod.ModuleName := 'esys';
  FEngineMod.AddDelphiMethod('engine_process_request', _PyESys_EngineProcessRequest, '');
  Synchronize(DoInitModules);
end;

function TPython.PopRequest: PPythonRequest;
begin
  WaitForRequest;
  FCommandCS.Enter;
  result := FCommandList.Items[0];
  FCommandList.Delete(0);
  if FCommandList.Count = 0 then
    FHasCommands.ResetEvent;
  FCommandCS.Leave;
end;

procedure TPython.ProcessRequest;
var
  p: PPythonRequest;
  EvalFunction: PPyObject;
begin
  p := PopRequest;
  case p^.command of
  pcTerminate: dispose(p);
  pcExecuteScript:  begin
                try
                  FPythonEngine.ExecStrings(p^.Script);
                  if p^.FreeOnComplete then
                    p^.Script.Free;
                finally
                  dispose(p);
                end;
              end;
  pcEvalString: begin
                try
                  p^.EvalResult := FPythonEngine.EvalString(p^.EvalString);
                finally
                  p^.EvalLock.SetEvent;
                end;
              end;
  pcExecuteLine: begin
                try
                  FPythonEngine.ExecString(p^.ExecLine);
                finally
                  FreeStr(p^.ExecLine);
                  dispose(p);
                end;
              end;
  pcEvalFunction: begin
                try
                  EvalFunction := nil;
                  EvalFunction := FPythonEngine.FindFunction(p^.EvalFunctionModule, p^.EvalFunctionName);
                  if EvalFunction <> nil then begin
                    p^.EvalFunctionResult := FPythonEngine.PyObject_CallObject(EvalFunction, p^.EvalFunctionArgs);
                  end;
                finally
                  FPythonEngine.Py_XDECREF(EvalFunction);
                  FPythonEngine.Py_DECREF(p^.EvalFunctionArgs);
                  p^.EvalFunctionLock.SetEvent;
                  FreeStr(p^.EvalFunctionName);
                  FreeStr(p^.EvalFunctionModule);
                end;
              end;
  pcExecMethod: begin
                try
                  p^.ExecMethod(p^.ExecContext);
                finally
                  dispose(p);
                end;
              end;
  pcExecMethodWithNotification: begin
                try
                  p^.ExecMethodB(p^.ExecContextB);
                finally
                  SendMessage(p^.ExecMethodBHandle, p^.ExecMethodBMessage, 0, cardinal(p^.ExecContextB));
                  dispose(p);
                end;
              end;
  end;
end;

procedure TPython.PushLine(PythonExec: string);
var
  p: PPythonRequest;
begin
  new(p);
  p^.ExecLine := AllocStr(PythonExec);
  p^.command := pcExecuteLine;
  QueueCommand(p);
end;

procedure TPython.PushMethod(Meth: TPyExecMethod; context: pointer);
var
  p: PPythonRequest;
begin
  new(p);
  p^.command := pcExecMethod;
  p^.ExecMethod := Meth;
  p^.ExecContext := context;
  QueueCommand(p);
end;

procedure TPython.PushScript(Script: TStrings; FreeOnComplete: boolean);
var
  p: PPythonRequest;
begin
  new(p);
  p^.command := pcExecuteScript;
  p^.Script := Script;
  p^.FreeOnComplete := FreeOnComplete;
  QueueCommand(p);
end;

procedure TPython.PushTerminate;
var
  p: PPythonRequest;
begin
  new(p);
  p^.command := pcTerminate;
  QueueCommand(p);
end;

procedure TPython.QueueCommand(p: PPythonRequest);
begin
  FCommandCS.Enter;
  FCommandList.Add(p);
  FCommandCS.Leave;
  FHasCommands.SetEvent;
end;

procedure TPython.Release;
begin
  FPythonEngine.PyEval_ReleaseLock;
end;

procedure TPython.WaitForRequest;
begin
  FCommandCS.Enter;
  if FCommandList.Count = 0 then begin
    FCommandCS.Leave;
    while FHasCommands.WaitFor(60000) <> wrSignaled do ;
  end else
    FCommandCS.Leave;
end;



function TPython._PyESys_EngineProcessRequest(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, '', []) <> 0 then begin
      BeginAllowThreads;
      try
        WaitForRequest;
      except
        on e: Exception do begin
          PyErr_SetString(PyExc_RuntimeError^, pchar('Runtime error in WaitForRequest: '+e.Message));
          EndAllowThreads;
          exit;
        end;
      end;
      EndAllowThreads;
      try
        ProcessRequest;
        Py_INCREF(Py_None);
        result := Py_None;
      except
        on e: Exception do begin
          PyErr_SetString(PyExc_RuntimeError^, pchar('Runtime error in ProcessRequest: '+e.Message));
        end;
      end;
    end;
  end;
end;

end.
