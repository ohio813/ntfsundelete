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


unit PyNTFSScannerType;

interface

uses
  SysUtils, Classes, PythonEngine;

type
  TScanServices = (
    ssOnProgressFunc,
    ssOnDriveOpenError,
    ssOnDriveOpenOk,
    ssOnVolumeOpenError,
    ssOnVolumeOpenOk,
    ssOnScanStart,
    ssOnScanEnd,
    ssOnOpenMFTEntry,
    ssOnOpenMFTEntryOk,
    ssOnOpenMFTEntryError,
    ssOnScanDeletedItem,
    ssOnScanDeletedFile,
    ssOnScanDeletedDir,
    ssOnScanPresentItem,
    ssOnScanPresentFile,
    ssOnScanPresentDir,
    ssOnScanStopQuery
  );

  TCopierServices = (
    csOnProgress,
    csOnStringNotification,
    csOnCopyStart,
    csOnCopyEnd,
    csOnCriticalError,
    csOnCancelFileQuery,
    csOnCancelAllQuery,
    csOnStartFile,
    csOnFinishFile
  );

  TScanServiceSet = set of TScanServices;
  TCopierServiceSet = set of TCopierServices;

  TPyNTFSScannerThread = class (TPythonThread)
  private
    FDriveName: WideString;
    FMod: TPythonModule;
    FServices: TScanServiceSet;
  protected
    procedure ExecuteWithPython; override;
  public
    constructor Create(Interp: PPyInterpreterState; drive_name: PWideChar; module: TPythonModule; AServices: TScanServiceSet);
  end;

  TPyNTFSCopierThread = class (TPythonThread)
  private
    FMod: TPythonModule;
    FVolume: PPyObject;
    FMFTRef: int64;
    FNewFileName: WideString;
    FServices: TCopierServiceSet;
  protected
    procedure ExecuteWithPython; override;
  public
    constructor Create(Interp: PPyInterpreterState; AVolume: PPyObject; mft_ref: int64; NewFileName: WideString; module: TPythonModule; AServices: TCopierServiceSet);
  end;

  TNTFSScanProgressEvent = procedure (Sender: TObject; mft_ref: int64; volume: PPyObject; percent: double) of object;
  TNTFSScanDriveOpenErrorEvent = procedure (Sender: TObject; errmsg: string) of object;
  TNTFSScanDriveOpenOkEvent = procedure (Sender: TObject) of object;
  TNTFSScanVolumeOpenErrorEvent = procedure (Sender: TObject; errmsg: string) of object;
  TNTFSScanVolumeOpenOkEvent = procedure (Sender: TObject) of object;
  TNTFSScanDVMEvent = procedure (Sender: TObject; Volume: PPyObject; mft_N: int64) of object;
  TNTFSScanDMFEvent = procedure (Sender: TObject; mft_ref: int64; py_file: PPyObject) of object;
  TNTFSScanStopQueryEvent = procedure (Sender: TObject; Volume: PPyObject; mft_N: int64; var StopScan: boolean) of object;
  TNTFSScanOpenEntryEvent = procedure (Sender: TObject; Volume: PPyObject; mft_ref: int64) of object;
  TNTFSScanOpenEntryErrorEvent = procedure (Sender: TObject; mft_ref: int64; err_msg: string) of object;

  TPyNTFSScannerModule = class (TPythonModule)
  private
    FOwnThreadState: PPyThreadState;
    FPyDriveName: PWideChar;
    FErrMsg: pchar;
    FPyVolume: PPyObject;
    FPyFile: PPyObject;
    FStopScan: boolean;
    FMFTRef: int64;
    FPercent: double;
    FScannerThread: TPyNTFSScannerThread;
    FDriveName: WideString;
    FOnProgress: TNTFSScanProgressEvent;
    FOnDriveOpenError: TNTFSScanDriveOpenErrorEvent;
    FOnDriveOpenOk: TNTFSScanDriveOpenOkEvent;
    FOnVolumeOpenError: TNTFSScanVolumeOpenErrorEvent;
    FOnVolumeOpenOk: TNTFSScanVolumeOpenOkEvent;
    FOnFinishScanThread: TNotifyEvent;
    FOnStartScanThread: TNotifyEvent;
    FOnScanEnd: TNTFSScanDVMEvent;
    FOnScanStart: TNTFSScanDVMEvent;
    FOnStopQuery: TNTFSScanStopQueryEvent;
    FOnOpenMFTEntry: TNTFSScanOpenEntryEvent;
    FOnScanPresentFile: TNTFSScanDMFEvent;
    FOnScanDeletedFile: TNTFSScanDMFEvent;
    FOnScanPresentDir: TNTFSScanDMFEvent;
    FOnScanDeletedDir: TNTFSScanDMFEvent;
    FOnScanPresentItem: TNTFSScanDMFEvent;
    FOnScanDeletedItem: TNTFSScanDMFEvent;
    FOnOpenMFTEntryOk: TNTFSScanDMFEvent;
    FOnOpenMFTEntryError: TNTFSScanOpenEntryErrorEvent;
    FServices: TScanServiceSet;
    function GetIsScanning: boolean;
    function _OnProgress(_self, args: PPyObject): PPyObject;cdecl;
    function _OnDriveOpenError(_self, args: PPyObject): PPyObject;cdecl;
    function _OnDriveOpenOk(_self, args: PPyObject): PPyObject;cdecl;
    function _OnVolumeOpenError(_self, args: PPyObject): PPyObject;cdecl;
    function _OnVolumeOpenOk(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanStart(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanEnd(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanStopQuery(_self, args: PPyObject): PPyObject;cdecl;
    function _OnOpenMFTEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _OnOpenMFTEntryError(_self, args: PPyObject): PPyObject;cdecl;
    function _OnOpenMFTEntryOk(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanDeletedItem(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanDeletedDir(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanDeletedFile(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanPresentItem(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanPresentDir(_self, args: PPyObject): PPyObject;cdecl;
    function _OnScanPresentFile(_self, args: PPyObject): PPyObject;cdecl;

    procedure DoProgress;
    procedure DoDriveOpenError;
    procedure DoDriveOpenOk;
    procedure DoVolumeOpenError;
    procedure DoVolumeOpenOk;
    procedure DoOnFinishScanThread;
    procedure DoOnScanStart;
    procedure DoOnScanEnd;
    procedure DoOnScanStopQuery;
    procedure DoOpenMFTEntry;
    procedure DoOpenMFTEntryError;
    procedure DoOpenMFTEntryOk;
    procedure DoScanDeletedItem;
    procedure DoScanDeletedDir;
    procedure DoScanDeletedFile;
    procedure DoScanPresentItem;
    procedure DoScanPresentDir;
    procedure DoScanPresentFile;
    procedure OnScannerThreadDone(Sender: TObject);
  public
    constructor Create(AOwner: TComponent);override;
    procedure Initialize;override;
    procedure StartScan(drive_name: PWideChar);

    property  IsScanning: boolean read GetIsScanning;
    property DriveName: WideString read FDriveName;
  published
    property ScanServices: TScanServiceSet read FServices write FServices;
    property OnStartScanThread: TNotifyEvent read FOnStartScanThread write FOnStartScanThread;
    property OnFinishScanThread: TNotifyEvent read FOnFinishScanThread write FOnFinishScanThread;
    property OnProgress: TNTFSScanProgressEvent read FOnProgress write FOnProgress;
    property OnDriveOpenError: TNTFSScanDriveOpenErrorEvent read FOnDriveOpenError write FOnDriveOpenError;
    property OnDriveOpenOk: TNTFSScanDriveOpenOkEvent read FOnDriveOpenOk write FOnDriveOpenOk;
    property OnVolumeOpenError: TNTFSScanVolumeOpenErrorEvent read FOnVolumeOpenError write FOnVolumeOpenError;
    property OnVolumeOpenOk: TNTFSScanVolumeOpenOkEvent read FOnVolumeOpenOk write FOnVolumeOpenOk;
    property OnScanStart: TNTFSScanDVMEvent read FOnScanStart write FOnScanStart;
    property OnScanEnd: TNTFSScanDVMEvent read FOnScanEnd write FOnScanEnd;
    property OnStopQuery: TNTFSScanStopQueryEvent read FOnStopQuery write FOnStopQuery;
    property OnOpenMFTEntry: TNTFSScanOpenEntryEvent read FOnOpenMFTEntry write FOnOpenMFTEntry;
    property OnOpenMFTEntryOk: TNTFSScanDMFEvent read FOnOpenMFTEntryOk write FOnOpenMFTEntryOk;
    property OnOpenMFTEntryError: TNTFSScanOpenEntryErrorEvent read FOnOpenMFTEntryError write FOnOpenMFTEntryError;
    property OnScanDeletedItem: TNTFSScanDMFEvent read FOnScanDeletedItem write FOnScanDeletedItem;
    property OnScanDeletedDir: TNTFSScanDMFEvent read FOnScanDeletedDir write FOnScanDeletedDir;
    property OnScanDeletedFile: TNTFSScanDMFEvent read FOnScanDeletedFile write FOnScanDeletedFile;
    property OnScanPresentItem: TNTFSScanDMFEvent read FOnScanPresentItem write FOnScanPresentItem;
    property OnScanPresentDir: TNTFSScanDMFEvent read FOnScanPresentDir write FOnScanPresentDir;
    property OnScanPresentFile: TNTFSScanDMFEvent read FOnScanPresentFile write FOnScanPresentFile;
  end;

  TNTFSCopierProgressEvent = procedure (Sender: TObject;
                                        CurrentFile: WideString;
                                        BytesProcessed: int64;
                                        FileProgress: double;
                                        TotalBytesProcessed: int64;
                                        TotalProgress: double) of object;
  TNTFSCopierStringNotificationEvent = procedure (Sender: TObject;
                                        Notification: String) of object;
  TNTFSCopierStartFileEvent = procedure (Sender: TObject; StartedFile: String; size: int64) of object;
  TNTFSCopierFinishFileEvent = procedure (Sender: TObject; FinishedFile: String; copied_size: int64) of object;
  TNTFSCopierCriticalErrorEvent = procedure (Sender: TObject; ErrorMessage: String) of object;
  TNTFSCopierCancelFileQueryEvent = procedure (Sender: TObject; var cancel: boolean) of object;
  TNTFSCopierCancelAllQueryEvent = procedure (Sender: TObject; var cancel: boolean) of object;

  TPyNTFSCopierModule = class(TPythonModule)
  private
    FNote: pchar;
    FCurrentFile: PWideChar;
    Fbytes_processed, Ftotal_bytes_processed: int64;
    Ffile_progress, Ftotal_progress: double;
    Ffile_name: PWideChar;
    Fsize: int64;
    FCancel: boolean;

    FOwnThreadState: PPyThreadState;
    FOnCancelAllQuery: TNTFSCopierCancelAllQueryEvent;
    FOnCancelFileQuery: TNTFSCopierCancelFileQueryEvent;
    FOnCriticalError: TNTFSCopierCriticalErrorEvent;
    FOnFinishFile: TNTFSCopierFinishFileEvent;
    FOnCopyProgress: TNTFSCopierProgressEvent;
    FOnStartFile: TNTFSCopierStartFileEvent;
    FOnStringNotification: TNTFSCopierStringNotificationEvent;
    FOnStartCopy: TNotifyEvent;
    FOnFinishCopy: TNotifyEvent;
    FServices: TCopierServiceSet;
    FCopierThread: TPyNTFSCopierThread;
    FOnStartCopierThread: TNotifyEvent;
    FOnFinishCopierThread: TNotifyEvent;
    procedure DoOnFinishCopyThread;
    procedure DoStartCopy;
    procedure DoFinishCopy;
    procedure DoProgress;
    procedure DoNotification;
    procedure DoStartFile;
    procedure DoFinishFile;
    procedure DoCriticaError;
    procedure DoOnCancelFileQuery;
    procedure DoOnCancelAllQuery;
    function _OnStartCopy(_self, args: PPyObject): PPyObject; cdecl;
    function _OnFinishCopy(_self, args: PPyObject): PPyObject; cdecl;
    function _OnProgress(_self, args: PPyObject): PPyObject; cdecl;
    function _OnNotification(_self, args: PPyObject): PPyObject; cdecl;
    function _OnStartFile(_self, args: PPyObject): PPyObject; cdecl;
    function _OnFinishFile(_self, args: PPyObject): PPyObject; cdecl;
    function _OnCriticalError(_self, args: PPyObject): PPyObject; cdecl;
    function _OnCancelFileQuery(_self, args: PPyObject): PPyObject; cdecl;
    function _OnCancelAllQuery(_self, args: PPyObject): PPyObject; cdecl;
    function GetIsCopying: boolean;
    procedure OnCopierThreadDone(Sender: TObject);
  public
    constructor Create(AOwner: TComponent);override;
    procedure Initialize;override;
    procedure StartCopyFile(Volume: PPyObject; mft_ref: int64; NewFileName: WideString);

    property  IsCopying: boolean read GetIsCopying;
    property  Services: TCopierServiceSet read FServices write FServices;
  published
    property OnCopyProgress: TNTFSCopierProgressEvent read FOnCopyProgress write FOnCopyProgress;
    property OnStartCopierThread: TNotifyEvent read FOnStartCopierThread write FOnStartCopierThread;
    property OnFinishCopierThread: TNotifyEvent read FOnFinishCopierThread write FOnFinishCopierThread;
    property OnStartCopy: TNotifyEvent read FOnStartCopy write FOnStartCopy;
    property OnFinishCopy: TNotifyEvent read FOnFinishCopy write FOnFinishCopy;
    property OnStringNotification: TNTFSCopierStringNotificationEvent read FOnStringNotification write FOnStringNotification;
    property OnStartFile: TNTFSCopierStartFileEvent read FOnStartFile write FOnStartFile;
    property OnFinishFile: TNTFSCopierFinishFileEvent read FOnFinishFile write FOnFinishFile;
    property OnCriticalError: TNTFSCopierCriticalErrorEvent read FOnCriticalError write FOnCriticalError;
    property OnCancelFileQuery: TNTFSCopierCancelFileQueryEvent read FOnCancelFileQuery write FOnCancelFileQuery;
    property OnCancelAllQuery: TNTFSCopierCancelAllQueryEvent read FOnCancelAllQuery write FOnCancelAllQuery;
  end;

  TPyMapper = class
  private
    FPyObject: PPyObject;
  protected
    function CallMapperFNNoArgs(fn_name: pchar): Variant;
    function GetAttr(attr_name: pchar): Variant;
    constructor Create(APyObject: PPyObject);
  public
    destructor Destroy;override;
  end;


  TPyNTFSDataStreamAttr = class (TPyMapper)
  private
    function GetName: WideString;
    function GetSize: int64;
  public
    property Name: WideString read GetName;
    property Size: int64 read GetSize;
  end;

  TPyNTFSFileNameAttr = class (TPyMapper)
  private
    function GetAllocatedSize: int64;
    function GetCreationTime: int64;
    function GetDataSize: int64;
    function GetFileName: WideString;
    function GetLastAccessTime: int64;
    function GetLastDataChangeTime: int64;
    function GetLastMFTChangeTime: int64;
    function GetParentDirectory: int64;
  public

    property ParentDirectory: int64 read GetParentDirectory;
    property CreationTime: int64 read GetCreationTime;
    property LastDataChangeTime: int64 read GetLastDataChangeTime;
    property LastMFTChangeTime: int64 read GetLastMFTChangeTime;
    property LastAccessTime: int64 read GetLastAccessTime;
    property AllocatedSize: int64 read GetAllocatedSize;
    property DataSize: int64 read GetDataSize;
    property FileName: WideString read GetFileName;
  end;


  TPyNTFSFile = class (TPyMapper)
  private
    function GetDataStreamCount: integer;
    function GetFileNameCount: integer;
    function GetIsBaseEntry: boolean;
    function GetIsDeleted: boolean;
    function GetIsDirectory: boolean;
    function GetMFTRef: int64;
    function GetWin32FileNameCount: integer;
    function GetDefaultDataStreamSize: int64;
  public
    constructor Create(APyObject: PPyObject);

    function GetFileNameAttr(idx: integer): TPyNTFSFileNameAttr;
    function GetWin32FileNameAttr(idx: integer): TPyNTFSFileNameAttr;
    function GetDataStreamAttr(idx: integer): TPyNTFSDataStreamAttr;

    property MftRef: int64 read GetMFTRef;
    property IsDirectory: boolean read GetIsDirectory;
    property IsDeleted: boolean read GetIsDeleted;
    property IsBaseEntry: boolean read GetIsBaseEntry;
    property FileNameCount: integer read GetFileNameCount;
    property Win32FileNameCount: integer read GetWin32FileNameCount;
    property DataStreamCount: integer read GetDataStreamCount;
    property DefaultDataStreamSize: int64 read GetDefaultDataStreamSize;
  end;


procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('Drive Suite', [TPyNTFSScannerModule]);
  RegisterComponents('Drive Suite', [TPyNTFSCopierModule]);
end;



{ TPyNTFSScannerModule }

constructor TPyNTFSScannerModule.Create(AOwner: TComponent);
begin
  inherited;
  FDriveName := '';
  FServices := [
    ssOnProgressFunc,
    ssOnDriveOpenError,
    ssOnVolumeOpenError,
    ssOnScanStart,
    ssOnScanEnd,
    ssOnOpenMFTEntryOk,
    ssOnScanStopQuery];
end;

procedure TPyNTFSScannerModule.DoDriveOpenError;
begin
  if Assigned(FOnDriveOpenError) then
    FOnDriveOpenError(self, string(FErrMsg));
end;

procedure TPyNTFSScannerModule.DoDriveOpenOk;
begin
  if Assigned (FOnDriveOpenOk) then
    FOnDriveOpenOk(self);
end;

procedure TPyNTFSScannerModule.DoOnFinishScanThread;
begin
  if Assigned (FOnFinishScanThread) then
    FOnFinishScanThread(self);
end;

procedure TPyNTFSScannerModule.DoOnScanEnd;
begin
  if Assigned(FOnScanEnd) then
    FOnScanEnd(self, FPyVolume, FMFTRef);
end;

procedure TPyNTFSScannerModule.DoOnScanStart;
begin
  if Assigned (FOnScanStart) then
    FOnScanStart(self, FPyVolume, FMFTRef);
end;

procedure TPyNTFSScannerModule.DoOnScanStopQuery;
begin
  if Assigned(FOnStopQuery) then
    FOnStopQuery(self, FPyVolume, FMFTRef, FStopScan);
end;

procedure TPyNTFSScannerModule.DoOpenMFTEntry;
begin
  if Assigned(FOnOpenMFTEntry) then
    FOnOpenMFTEntry(self, FPyVolume, FMFTRef);
end;

procedure TPyNTFSScannerModule.DoOpenMFTEntryError;
begin
  if Assigned(FOnOpenMFTEntryError) then
    FOnOpenMFTEntryError(self, FMFTRef, string(FErrMsg));
end;

procedure TPyNTFSScannerModule.DoOpenMFTEntryOk;
begin
  if Assigned (FOnOpenMFTEntryOk) then
    FOnOpenMFTEntryOk(self, FMFTRef, FPyFile);
end;

procedure TPyNTFSScannerModule.DoProgress;
begin
  if Assigned (FOnProgress) then
    FOnProgress(self, FMFTRef, FPyVolume, FPercent);
end;

procedure TPyNTFSScannerModule.DoScanDeletedDir;
begin
  if Assigned (FOnScanDeletedDir) then
    FOnScanDeletedDir(self, FMFTRef, FPyFile);
end;

procedure TPyNTFSScannerModule.DoScanDeletedFile;
begin
  if Assigned (FOnScanDeletedFile) then
    FOnScanDeletedFile(self, FMFTRef, FPyFile);
end;

procedure TPyNTFSScannerModule.DoScanDeletedItem;
begin
  if Assigned (FOnScanDeletedItem) then
    FOnScanDeletedItem(self, FMFTRef, FPyFile);
end;

procedure TPyNTFSScannerModule.DoScanPresentDir;
begin
  if Assigned (FOnScanPresentDir) then
    FOnScanPresentDir(self, FMFTRef, FPyFile);
end;

procedure TPyNTFSScannerModule.DoScanPresentFile;
begin
  if Assigned (FOnScanPresentFile) then
    FOnScanPresentFile(self, FMFTRef, FPyFile);
end;

procedure TPyNTFSScannerModule.DoScanPresentItem;
begin
  if Assigned (FOnScanPresentItem) then
    FOnScanPresentItem(self, FMFTRef, FPyFile);
end;

procedure TPyNTFSScannerModule.DoVolumeOpenError;
begin
  if Assigned (FOnVolumeOpenError) then
    FOnVolumeOpenError(self, string(FErrMsg));
end;

procedure TPyNTFSScannerModule.DoVolumeOpenOk;
begin
  if Assigned (FOnVolumeOpenOk) then
    FOnVolumeOpenOk(self);
end;

function TPyNTFSScannerModule.GetIsScanning: boolean;
begin
  result := FScannerThread <> nil;
end;

procedure TPyNTFSScannerModule.Initialize;
begin
  AddDelphiMethod('on_progress', _OnProgress, '');
  AddDelphiMethod('on_drive_open_error', _OnDriveOpenError, '');
  AddDelphiMethod('on_drive_open_ok', _OnDriveOpenOk, '');
  AddDelphiMethod('on_volume_open_error', _OnVolumeOpenError, '');
  AddDelphiMethod('on_volume_open_ok', _OnVolumeOpenOk, '');
  AddDelphiMethod('on_scan_start', _OnScanStart, '');
  AddDelphiMethod('on_scan_end', _OnScanEnd, '');
  AddDelphiMethod('on_scan_stop_query', _OnScanStopQuery, '');
  AddDelphiMethod('on_open_mft_entry', _OnOpenMFTEntry, '');
  AddDelphiMethod('on_open_mft_entry_error', _OnOpenMFTEntryError, '');
  AddDelphiMethod('on_open_mft_entry_ok', _OnOpenMFTEntryOk, '');
  AddDelphiMethod('on_scan_deleted_item', _OnScanDeletedItem, '');
  AddDelphiMethod('on_scan_deleted_dir', _OnScanDeletedDir, '');
  AddDelphiMethod('on_scan_deleted_file', _OnScanDeletedFile, '');
  AddDelphiMethod('on_scan_present_item', _OnScanPresentItem, '');
  AddDelphiMethod('on_scan_present_dir', _OnScanPresentDir, '');
  AddDelphiMethod('on_scan_present_file', _OnScanPresentFile, '');
  inherited;
end;

procedure TPyNTFSScannerModule.OnScannerThreadDone(Sender: TObject);
begin
  FScannerThread.Synchronize(DoOnFinishScanThread);
  GetPythonEngine.PyEval_AcquireThread(FOwnThreadState);
  FDriveName := '';
  FScannerThread := nil;
end;

procedure TPyNTFSScannerModule.StartScan(drive_name: PWideChar);
begin
  if not Assigned(FScannerThread) then begin
    with GetPythonEngine do begin
      FDriveName := drive_name;
      FOwnThreadState := PyThreadState_Get;
      PyEval_ReleaseThread(FOwnThreadState);
      FScannerThread := TPyNTFSScannerThread.Create(FOwnThreadState.interp, drive_name, self, FServices);
      FScannerThread.OnTerminate := OnScannerThreadDone;
      FScannerThread.Resume;
      if Assigned (FOnStartScanThread) then
        FOnStartScanThread(self);
    end;
  end else
    raise Exception.Create('Cannot scan more than one drive at a time');
end;

function TPyNTFSScannerModule._OnDriveOpenError(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'us', [@FPyDriveName, @FErrMsg]) <> 0) then begin
      if Assigned(FScannerThread) then begin
        FScannerThread.Synchronize(DoDriveOpenError);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnDriveOpenOk(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'u', [@FPyDriveName]) <> 0 then begin
      if Assigned(FScannerThread) then begin
        FScannerThread.Synchronize(DoDriveOpenOk);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnOpenMFTEntry(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uOL', [@FPyDriveName, @FPyVolume, @FMFTRef]) <> 0) then begin
      if Assigned(FScannerThread) then begin
        FScannerThread.Synchronize(DoOpenMFTEntry);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnOpenMFTEntryError(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLs', [@FPyDriveName, @FMFTRef, @FErrMsg]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoOpenMFTEntryError);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnOpenMFTEntryOk(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLO', [@FPyDriveName, @FMFTRef, @FPyFile]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoOpenMFTEntryOk);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnProgress(_self,
  args: PPyObject): PPyObject;
begin
  //lambda drive_name, volume, mft_rec_no, perc: None
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uOLd', [@FPyDriveName, @FPyVolume, @FMFTRef, @FPercent]) <> 0) then begin
      if Assigned(FScannerThread) then begin
        //FScannerThread.Py_Begin_Allow_Threads;
        FScannerThread.Synchronize(DoProgress);
        //FScannerThread.Py_End_Allow_Threads;
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanDeletedDir(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLO', [@FPyDriveName, @FMFTRef, @FPyFile]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoScanDeletedDir);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanDeletedFile(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLO', [@FPyDriveName, @FMFTRef, @FPyFile]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoScanDeletedFile);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanDeletedItem(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLO', [@FPyDriveName, @FMFTRef, @FPyFile]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoScanDeletedItem);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanEnd(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uOL', [@FPyDriveName, @FPyVolume, @FMFTRef]) <> 0) then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoOnScanEnd);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanPresentDir(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLO', [@FPyDriveName, @FMFTRef, @FPyFile]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoScanPresentDir);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanPresentFile(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLO', [@FPyDriveName, @FMFTRef, @FPyFile]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoScanPresentFile);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanPresentItem(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'uLO', [@FPyDriveName, @FMFTRef, @FPyFile]) <> 0 then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoScanPresentItem);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanStart(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uOL', [@FPyDriveName, @FPyVolume, @FMFTRef]) <> 0) then begin
      if Assigned (FScannerThread) then begin
        FScannerThread.Synchronize(DoOnScanStart);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnScanStopQuery(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uOL', [@FPyDriveName, @FPyVolume, @FMFTRef]) <> 0) then begin
      FStopScan := false;
      if Assigned(FScannerThread) then
        FScannerThread.Synchronize(DoOnScanStopQuery);
      if FStopScan then
        result := PyInt_FromLong(1)
      else
        result := PyInt_FromLong(0);        
    end;
  end;
end;

function TPyNTFSScannerModule._OnVolumeOpenError(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'us', [@FPyDriveName, @FErrMsg]) <> 0) then begin
      if Assigned(FScannerThread) then begin
        FScannerThread.Synchronize(DoVolumeOpenError);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TPyNTFSScannerModule._OnVolumeOpenOk(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'u', [@FPyDriveName]) <> 0 then begin
      if Assigned(FScannerThread) then begin
        FScannerThread.Synchronize(DoVolumeOpenOk);
      end;
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

{ TPyNTFSScannerThread }

constructor TPyNTFSScannerThread.Create(Interp: PPyInterpreterState; drive_name: PWideChar; module: TPythonModule; AServices: TScanServiceSet);
begin
  InterpreterState := Interp;
  FreeOnTerminate := True;
  FMod := module;
  FDriveName := drive_name;
  FServices := AServices;
  inherited Create(True);
end;

procedure TPyNTFSScannerThread.ExecuteWithPython;
var
  S: TStringList;
  func: PPyObject;
  args: PPyObject;
  cb_dict, fn: PPyObject;
begin
  S := TStringList.Create;
  S.Add('from ntfs import *');
  S.Add('import scn');
  with GetPythonEngine do begin
    if Assigned(FMod) and (ThreadExecMode = emNewInterpreter) then
      FMod.InitializeForNewInterpreter;
    try
      ExecStrings(S);
    finally
      S.free;
    end;
    func := nil;
    args := nil;
    cb_dict := nil;
    try
      func := FindFunction('__main__', 'scan_ntfs_drive');
      cb_dict := PyDict_New();
      if ssOnProgressFunc in FServices then begin
        fn := FindFunction('scn', 'on_progress');
        PyDict_SetItemString(cb_dict, 'on_progress', fn);
        Py_DECREF(fn);
      end;
      if ssOnDriveOpenError in FServices then begin
        fn := FindFunction('scn', 'on_drive_open_error');
        PyDict_SetItemString(cb_dict, 'on_drive_open_error', fn);
        Py_DECREF(fn);
      end;
      if ssOnDriveOpenOk in FServices then begin
        fn := FindFunction('scn', 'on_drive_open_ok');
        PyDict_SetItemString(cb_dict, 'on_drive_open_ok', fn);
        Py_DECREF(fn);
      end;
      if ssOnVolumeOpenError in FServices then begin
        fn := FindFunction('scn', 'on_volume_open_error');
        PyDict_SetItemString(cb_dict, 'on_volume_open_error', fn);
        Py_DECREF(fn);
      end;
      if ssOnVolumeOpenOk in FServices then begin
        fn := FindFunction('scn', 'on_volume_open_ok');
        PyDict_SetItemString(cb_dict, 'on_volume_open_ok', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanStart in FServices then begin
        fn := FindFunction('scn', 'on_scan_start');
        PyDict_SetItemString(cb_dict, 'on_scan_start', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanEnd in FServices then begin
        fn := FindFunction('scn', 'on_scan_end');
        PyDict_SetItemString(cb_dict, 'on_scan_end', fn);
        Py_DECREF(fn);
      end;
      if ssOnOpenMFTEntry in FServices then begin
        fn := FindFunction('scn', 'on_open_mft_entry');
        PyDict_SetItemString(cb_dict, 'on_open_mft_entry', fn);
        Py_DECREF(fn);
      end;
      if ssOnOpenMFTEntryOk in FServices then begin
        fn := FindFunction('scn', 'on_open_mft_entry_ok');
        PyDict_SetItemString(cb_dict, 'on_open_mft_entry_ok', fn);
        Py_DECREF(fn);
      end;
      if ssOnOpenMFTEntryError in FServices then begin
        fn := FindFunction('scn', 'on_open_mft_entry_error');
        PyDict_SetItemString(cb_dict, 'on_open_mft_entry_error', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanDeletedItem in FServices then begin
        fn := FindFunction('scn', 'on_scan_deleted_item');
        PyDict_SetItemString(cb_dict, 'on_scan_deleted_item', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanDeletedFile in FServices then begin
        fn := FindFunction('scn', 'on_scan_deleted_file');
        PyDict_SetItemString(cb_dict, 'on_scan_deleted_file', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanDeletedDir in FServices then begin
        fn := FindFunction('scn', 'on_scan_deleted_dir');
        PyDict_SetItemString(cb_dict, 'on_scan_deleted_dir', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanPresentItem in FServices then begin
        fn := FindFunction('scn', 'on_scan_present_item');
        PyDict_SetItemString(cb_dict, 'on_scan_present_item', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanPresentFile in FServices then begin
        fn := FindFunction('scn', 'on_scan_present_file');
        PyDict_SetItemString(cb_dict, 'on_scan_present_file', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanPresentDir in FServices then begin
        fn := FindFunction('scn', 'on_scan_present_dir');
        PyDict_SetItemString(cb_dict, 'on_scan_present_dir', fn);
        Py_DECREF(fn);
      end;
      if ssOnScanStopQuery in FServices then begin
        fn := FindFunction('scn', 'on_scan_stop_query');
        PyDict_SetItemString(cb_dict, 'on_scan_stop_query', fn);
        Py_DECREF(fn);
      end;
      args := Py_BuildValue('(uO)', [FDriveName, cb_dict]);
      EvalPyFunction(func, args);
    finally
      Py_XDECREF(func);
      Py_XDECREF(args);
      Py_XDECREF(cb_dict);
    end;
  end;
end;

{ TPyNTFSFileNameAttr }

function TPyMapper.CallMapperFNNoArgs(fn_name: pchar): Variant;
var
  fn: PPyObject;
begin
  with GetPythonEngine do begin
    fn := PyObject_GetAttrString(FPyObject, fn_name);
    if (fn <> nil) then begin
      try
        result := GetPythonEngine.EvalFunctionNoArgs(fn);
      except
        on Exception do begin
          Py_DECREF(fn);
          raise;
        end;
      end;
      Py_DECREF(fn);
    end else
      RaiseError;
  end;
end;

constructor TPyMapper.Create(APyObject: PPyObject);
begin
  inherited Create;
  FPyObject := APyObject;
  with GetPythonEngine do
    Py_INCREF(FPyObject);
end;

destructor TPyMapper.Destroy;
begin
  with GetPythonEngine do
    Py_DECREF(FPyObject);
  inherited;
end;

function TPyNTFSFileNameAttr.GetAllocatedSize: int64;
begin
  result := CallMapperFNNoArgs('get_allocated_size');
end;

function TPyNTFSFileNameAttr.GetCreationTime: int64;
begin
  result := CallMapperFNNoArgs('get_creation_time');
end;

function TPyNTFSFileNameAttr.GetDataSize: int64;
var
  R: PPyObject;
begin
//  result := CallMapperFNNoArgs('get_data_size');
  with GetPythonEngine do begin
      R := PyObject_CallMethod(FPyObject, 'get_data_size', '', []);
      if R <> nil then begin
        if PyLong_Check(R) then begin
          result := PyLong_AsLongLong(R);
          Py_DECREF(R);
        end else begin
          Py_DECREF(R);
          PyErr_SetString(PyExc_RuntimeError^, 'function get_data_size returned invalid data');
          RaiseError;
        end;
      end else
        RaiseError;
  end;
end;

function TPyNTFSFileNameAttr.GetFileName: WideString;
begin
  result := CallMapperFNNoArgs('get_file_name');
end;

function TPyNTFSFileNameAttr.GetLastAccessTime: int64;
begin
  result := CallMapperFNNoArgs('get_last_access_time');
end;

function TPyNTFSFileNameAttr.GetLastDataChangeTime: int64;
begin
  result := CallMapperFNNoArgs('get_last_data_change_time');
end;

function TPyNTFSFileNameAttr.GetLastMFTChangeTime: int64;
begin
  result := CallMapperFNNoArgs('get_last_mft_change_time');
end;

function TPyNTFSFileNameAttr.GetParentDirectory: int64;
begin
  result := CallMapperFNNoArgs('get_parent_directory') and $0000ffffffffffff;
end;

function TPyMapper.GetAttr(attr_name: pchar): Variant;
var
  R: PPyObject;
begin
  with GetPythonEngine do begin
    R := PyObject_GetAttrString(FPyObject, attr_name);
    if R <> nil then begin
      try
        result := PyObjectAsVariant(R);
      except
        on Exception do begin
          Py_DECREF(R);
          raise;
        end;
      end;
      Py_DECREF(R);
    end else begin
      RaiseError;
    end;
  end;
end;

{ TPyNTFSFile }

constructor TPyNTFSFile.Create(APyObject: PPyObject);
begin
  inherited;
end;

function TPyNTFSFile.GetDataStreamAttr(
  idx: integer): TPyNTFSDataStreamAttr;
var
  R, T: PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    R := PyObject_GetAttrString(FPyObject, 'data_stream_list');
    if R <> nil then begin
      if (PySequence_Check(R) <> 0) then begin
        T := PySequence_GetItem(R, idx);
        Py_DECREF(R);
        if (T <> nil) then begin
          result := TPyNTFSDataStreamAttr.Create(T);
          Py_DECREF(T);
        end else
          RaiseError;
      end else begin
        Py_DECREF(R);
        PyErr_SetString(PyExc_TypeError^, 'data_streams attribute does not support seq protocol');
        RaiseError;
      end;
    end else
      RaiseError;
  end;
end;

function TPyNTFSFile.GetDataStreamCount: integer;
begin
  result := GetAttr('data_stream_count');
end;

function TPyNTFSFile.GetDefaultDataStreamSize: int64;
begin
  result := GetAttr('default_data_stream_size');
end;

function TPyNTFSFile.GetFileNameAttr(idx: integer): TPyNTFSFileNameAttr;
var
  R, T: PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    R := PyObject_GetAttrString(FPyObject, 'file_name_list');
    if R <> nil then begin
      if (PySequence_Check(R) <> 0) then begin
        T := PySequence_GetItem(R, idx);
        Py_DECREF(R);
        if (T <> nil) then begin
          result := TPyNTFSFileNameAttr.Create(T);
          Py_DECREF(T);
        end else
          RaiseError;
      end else begin
        Py_DECREF(R);
        PyErr_SetString(PyExc_TypeError^, 'file_names attribute does not support seq protocol');
        RaiseError;
      end;
    end else
      RaiseError;
  end;
end;

function TPyNTFSFile.GetFileNameCount: integer;
begin
  result := GetAttr('file_name_count');
end;

function TPyNTFSFile.GetIsBaseEntry: boolean;
begin
  result := GetAttr('is_base_entry');
end;

function TPyNTFSFile.GetIsDeleted: boolean;
begin
  result := GetAttr('is_deleted');
end;

function TPyNTFSFile.GetIsDirectory: boolean;
begin
  result := GetAttr('is_directory');
end;

function TPyNTFSFile.GetMFTRef: int64;
begin
  result := GetAttr('mft_ref');
end;

function TPyNTFSFile.GetWin32FileNameAttr(
  idx: integer): TPyNTFSFileNameAttr;
var
  R, T: PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    R := PyObject_GetAttrString(FPyObject, 'win32_file_name_list');
    if R <> nil then begin
      if (PySequence_Check(R) <> 0) then begin
        T := PySequence_GetItem(R, idx);
        Py_DECREF(R);
        if (T <> nil) then begin
          result := TPyNTFSFileNameAttr.Create(T);
          Py_DECREF(T);
        end else
          RaiseError;
      end else begin
        Py_DECREF(R);
        PyErr_SetString(PyExc_TypeError^, 'win32_file_names attribute does not support seq protocol');
        RaiseError;
      end;
    end else
      RaiseError;
  end;
end;

function TPyNTFSFile.GetWin32FileNameCount: integer;
begin
  result := GetAttr('win32_file_name_count');
end;

{ TPyNTFSDataStreamAttr }

function TPyNTFSDataStreamAttr.GetName: WideString;
begin
  result := GetAttr('name');
end;

function TPyNTFSDataStreamAttr.GetSize: int64;
begin
  result := GetAttr('size');
end;

{ TPyNTFSCopierThread }
{
constructor TPyNTFSCopierThread.Create(Interp: PPyInterpreterState;
  module: TPythonModule; AServices: TCopierServiceSet);
begin
  InterpreterState := Interp;
  FreeOnTerminate := True;
  FMod := module;
  FServices := AServices;
  inherited Create(True);
end;

procedure TPyNTFSCopierThread.ExecuteWithPython;
begin
//
end;}

{ TPyNTFSCopierModule }

constructor TPyNTFSCopierModule.Create(AOwner: TComponent);
begin
  inherited;
  ModuleName := 'ncopier';
  FCopierThread := nil;
  FServices := [
    csOnProgress,
    csOnStringNotification,
    csOnCopyStart,
    csOnCopyEnd,
    csOnCriticalError,
    csOnCancelFileQuery,
    csOnCancelAllQuery,
    csOnStartFile,
    csOnFinishFile
  ];
end;

procedure TPyNTFSCopierModule.DoCriticaError;
begin
  if Assigned(FOnCriticalError) then
    FOnCriticalError(self, FNote);
end;

procedure TPyNTFSCopierModule.DoFinishCopy;
begin
  if Assigned(FOnFinishCopy) then
    FOnFinishCopy(self);
end;

procedure TPyNTFSCopierModule.DoFinishFile;
begin
  if Assigned(FOnFinishFile) then
    FOnFinishFile(self, Ffile_name, Fsize);
end;

procedure TPyNTFSCopierModule.DoNotification;
begin
  if Assigned(FOnStringNotification) then
    FOnStringNotification(self, FNote);
end;

procedure TPyNTFSCopierModule.DoOnCancelAllQuery;
begin
  if Assigned(FOnCancelAllQuery) then
    FOnCancelAllQuery(self, Fcancel);
end;

procedure TPyNTFSCopierModule.DoOnCancelFileQuery;
begin
  if Assigned(FOnCancelFileQuery) then
    FOnCancelFileQuery(self, Fcancel);
end;

procedure TPyNTFSCopierModule.DoOnFinishCopyThread;
begin
  if Assigned(FOnFinishCopierThread) then
    FOnFinishCopierThread(self);
end;

procedure TPyNTFSCopierModule.DoProgress;
begin
  if Assigned(FOnCopyProgress) then
    FOnCopyProgress(self, FCurrentFile, Fbytes_processed, Ffile_progress, Ftotal_bytes_processed, Ftotal_progress);
end;

procedure TPyNTFSCopierModule.DoStartCopy;
begin
  if Assigned(FOnStartCopy) then
    FOnStartCopy(self);
end;

procedure TPyNTFSCopierModule.DoStartFile;
begin
  if Assigned(FOnStartFile) then
    FOnStartFile(self, Ffile_name, Fsize);
end;

function TPyNTFSCopierModule.GetIsCopying: boolean;
begin
  result := FCopierThread <> nil;
end;

procedure TPyNTFSCopierModule.Initialize;
begin
  AddDelphiMethod( 'on_start_copy', _OnStartCopy, '');
  AddDelphiMethod( 'on_finish_copy', _OnFinishCopy, '');
  AddDelphiMethod( 'on_progress', _OnProgress, '');
  AddDelphiMethod( 'on_notification', _OnNotification, '');
  AddDelphiMethod( 'on_start_file', _OnStartFile, '');
  AddDelphiMethod( 'on_finish_file', _OnFinishFile, '');
  AddDelphiMethod( 'on_critical_error', _OnCriticalError, '');
  AddDelphiMethod( 'on_cancel_file_query', _OnCancelFileQuery, '');
  AddDelphiMethod( 'on_cancel_all_query', _OnCancelAllQuery, '');
  inherited;
end;

procedure TPyNTFSCopierModule.OnCopierThreadDone(Sender: TObject);
begin
  FCopierThread.Synchronize(DoOnFinishCopyThread);
  GetPythonEngine.PyEval_AcquireThread(FOwnThreadState);
  FCopierThread := nil;
end;

procedure TPyNTFSCopierModule.StartCopyFile(Volume: PPyObject; mft_ref: int64; NewFileName: WideString);
begin
  if not Assigned(FCopierThread) then begin
    with GetPythonEngine do begin
      FOwnThreadState := PyThreadState_Get;
      PyEval_ReleaseThread(FOwnThreadState);
      FCopierThread := TPyNTFSCopierThread.Create(FOwnThreadState.interp, Volume, mft_ref, NewFileName, self, FServices);
      FCopierThread.OnTerminate := OnCopierThreadDone;
      FCopierThread.Resume;
      if Assigned (FOnStartCopierThread) then
        FOnStartCopierThread(self);
    end;
  end else
    raise Exception.Create('Cannot scan more than one drive at a time');
end;

function TPyNTFSCopierModule._OnCancelAllQuery(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, '', []) <> 0) then begin
      FCancel := False;
      FCopierThread.Synchronize(DoOnCancelAllQuery);
      if FCancel then
        result := PyInt_FromLong(1)
      else
        result := PyInt_FromLong(0);
    end;
  end;
end;

function TPyNTFSCopierModule._OnCancelFileQuery(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, '', []) <> 0) then begin
      FCancel := False;
      FCopierThread.Synchronize(DoOnCancelFileQuery);
      if FCancel then
        result := PyInt_FromLong(1)
      else
        result := PyInt_FromLong(0);
    end;
  end;
end;

function TPyNTFSCopierModule._OnCriticalError(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 's', [@Fnote]) <> 0) then begin
      FCopierThread.Synchronize(DoCriticaError);
      Py_INCREF(Py_None);
      result := Py_None;
    end;
  end;
end;

function TPyNTFSCopierModule._OnFinishCopy(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, '', []) <> 0) then begin
      FCopierThread.Synchronize(DoFinishCopy);
      Py_INCREF(Py_None);
      result := Py_None;
    end;
  end;
end;

function TPyNTFSCopierModule._OnFinishFile(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uL', [@Ffile_name, @Fsize]) <> 0) then begin
      FCopierThread.Synchronize(DoFinishFile);
      Py_INCREF(Py_None);
      result := Py_None;
    end;
  end;
end;

function TPyNTFSCopierModule._OnNotification(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 's', [@Fnote]) <> 0) then begin
      FCopierThread.Synchronize(DoNotification);
      Py_INCREF(Py_None);
      result := Py_None;
    end;
  end;
end;

function TPyNTFSCopierModule._OnProgress(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uLdLd', [@FCurrentFile, @Fbytes_processed, @Ffile_progress, @Ftotal_bytes_processed, @Ftotal_progress]) <> 0) then begin
      FCopierThread.Synchronize(DoProgress);
      Py_INCREF(Py_None);
      result := Py_None;
    end;
  end;
end;

function TPyNTFSCopierModule._OnStartCopy(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, '', []) <> 0) then begin
      FCopierThread.Synchronize(DoStartCopy);
      Py_INCREF(Py_None);
      result := Py_None;
    end;
  end;
end;

function TPyNTFSCopierModule._OnStartFile(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if (PyArg_ParseTuple(args, 'uL', [@Ffile_name, @Fsize]) <> 0) then begin
      FCopierThread.Synchronize(DoStartFile);
      Py_INCREF(Py_None);
      result := Py_None;
    end;
  end;
end;

{ TPyNTFSCopierThread }

constructor TPyNTFSCopierThread.Create(Interp: PPyInterpreterState; AVolume: PPyObject;
  mft_ref: int64; NewFileName: WideString; module: TPythonModule; AServices: TCopierServiceSet);
begin
  InterpreterState := Interp;
  FreeOnTerminate := true;
  FVolume := AVolume;
  FMod := module;
  FServices := AServices;
  FMFTRef := mft_ref;
  FNewFileName := NewFileName;
  inherited Create(True);
end;

procedure TPyNTFSCopierThread.ExecuteWithPython;
var
  fn, args, cb_dict, func: PPyObject;
begin
  with GetPythonEngine do begin
    func := FindFunction('__main__', 'copy_file');
    cb_dict := PyDict_New();
    if csOnFinishFile in FServices then begin
      fn := FindFunction('ncopier', 'on_finish_file');
      PyDict_SetItemString(cb_dict, 'on_finish_file', fn);
      Py_DECREF(fn);
    end;
    if csOnStartFile in FServices then begin
      fn := FindFunction('ncopier', 'on_start_file');
      PyDict_SetItemString(cb_dict, 'on_start_file', fn);
      Py_DECREF(fn);
    end;
    if csOnCancelAllQuery in FServices then begin
      fn := FindFunction('ncopier', 'on_cancel_all_query');
      PyDict_SetItemString(cb_dict, 'on_cancel_all_query', fn);
      Py_DECREF(fn);
    end;
    if csOnCancelFileQuery in FServices then begin
      fn := FindFunction('ncopier', 'on_cancel_file_query');
      PyDict_SetItemString(cb_dict, 'on_cancel_file_query', fn);
      Py_DECREF(fn);
    end;
    if csOnCriticalError in FServices then begin
      fn := FindFunction('ncopier', 'on_critical_error');
      PyDict_SetItemString(cb_dict, 'on_critical_error', fn);
      Py_DECREF(fn);
    end;
    if csOnProgress in FServices then begin
      fn := FindFunction('ncopier', 'on_progress');
      PyDict_SetItemString(cb_dict, 'on_progress', fn);
      Py_DECREF(fn);
    end;
    if csOnStringNotification in FServices then begin
      fn := FindFunction('ncopier', 'on_notification');
      PyDict_SetItemString(cb_dict, 'on_notification', fn);
      Py_DECREF(fn);
    end;
    if csOnCopyStart in FServices then begin
      fn := FindFunction('ncopier', 'on_start_copy');
      PyDict_SetItemString(cb_dict, 'on_start_copy', fn);
      Py_DECREF(fn);
    end;
    if csOnCopyEnd in FServices then begin
      fn := FindFunction('ncopier', 'on_finish_copy');
      PyDict_SetItemString(cb_dict, 'on_finish_copy', fn);
      Py_DECREF(fn);
    end;
    args := nil;
    try
      args := Py_BuildValue('(ONuN)', [FVolume, PyLong_FromLongLong(FMFTRef), FNewFileName, cb_dict]);
      EvalPyFunction(func, args);
    finally
      Py_XDECREF(Args);
    end;
  end;
end;

end.
