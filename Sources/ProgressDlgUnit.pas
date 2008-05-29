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

unit ProgressDlgUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, Messages;

type
  TProgressDlg = class(TForm)
    CancelBtn: TButton;
    ActionLabel: TLabel;
    ProgressBar: TProgressBar;
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProgressDlg: TProgressDlg;

implementation

  uses MainFormUnit;

{$R *.dfm}

procedure TProgressDlg.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  MainForm.Python.PushLine('pyue.ue_runtime.on_progress_dlg_cancel()');
end;


end.
