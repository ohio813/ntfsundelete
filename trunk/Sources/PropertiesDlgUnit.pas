(*
    NTFS Undelete
    Copyright (C) 2008 Atola Technology.
    http://ntfsundelete.com

    Authors:
      Alexander Malashonok
      Fedir Nepyivoda <fednep@gmail.com>


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

unit PropertiesDlgUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Messages,
  Buttons, ExtCtrls, ComCtrls, PythonMisc, PythonEngine, OleCtrls, SHDocVw;

const
  PROPM_PROPSCOMPLETE = $BD00;

type
  TPrepareContext = record
    Volume: PPyObject;
    mft_ref: int64;
    out_string: WideString;
  end;
  PPrepareContext = ^TPrepareContext;

  TPropertiesDlg = class(TForm)
    OKBtn: TButton;
  private
    { Private declarations }
    procedure __Prepare(context: pointer);
    procedure _PROPM_PropsComplete(var Message: TMessage); message PROPM_PROPSCOMPLETE;
  public
    { Public declarations }
    procedure PrepareFor(Python: TPython; Volume: PPyObject; mft_ref: int64);
  end;

var
  PropertiesDlg: TPropertiesDlg;

implementation

uses
  Dialogs;

{$R *.dfm}

{ TPropertiesDlg }

procedure TPropertiesDlg.PrepareFor(Python: TPython; Volume: PPyObject; mft_ref: int64);
begin

end;

procedure TPropertiesDlg.__Prepare(context: pointer);
var
  p: PPrepareContext;
  R: PPyObject;
  Args, Meth: PPyObject;
begin
  p := context;
  with GetPythonEngine do begin
    Meth := FindFunction('pyue.ue_runtime', 'make_properties_report');
    if Meth <> nil then begin
      Args := PyTuple_New(2);
      Py_INCREF(p^.Volume);
      PyTuple_SetItem(Args, 0, p^.Volume);
      PyTuple_SetItem(Args, 1, PyLong_FromLongLong(p^.mft_ref));
      R := PyObject_CallObject(Meth, Args);
      Py_DECREF(Meth);
      Py_DECREF(Args);
      if R <> nil then begin
        if (PyUnicode_Check(R)) then begin
          p^.out_string := PyUnicode_AsWideString(R);
          Py_DECREF(R);
        end else begin
          Py_DECREF(R);
          raise Exception.Create('Unexpected result from "make_properties_report');
        end;
      end else
        RaiseError;
    end else
      raise Exception.Create('Cannot find function make_properties_report');
  end;
end;

procedure TPropertiesDlg._PROPM_PropsComplete(var Message: TMessage);
begin

end;

end.
