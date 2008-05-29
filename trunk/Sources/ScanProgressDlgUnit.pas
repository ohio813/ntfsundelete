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

unit ScanProgressDlgUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, VFSManager, MainFormUnit;

type
  TScanProgressDlg = class(TForm)
    CancelBtn: TButton;
    NeverShowCbx: TCheckBox;
    Label1: TLabel;
    ProgressBar: TProgressBar;
    PercentLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FActiveEntry: PVFSEntry;
    { Private declarations }
  public
    { Public declarations }
    procedure SetPercent(perc: integer);
    property ActiveEntry: PVFSEntry read FActiveEntry write FActiveEntry;
  end;

var
  ScanProgressDlg: TScanProgressDlg;

implementation

{$R *.dfm}

{ TScanProgressDlg }

procedure TScanProgressDlg.SetPercent(perc: integer);
begin
  ProgressBar.Position := perc;
  PercentLabel.Caption := IntToStr(perc)+'% complete';
end;

procedure TScanProgressDlg.FormShow(Sender: TObject);
begin
  SetPercent(0);
end;

procedure TScanProgressDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if NeverShowCbx.Checked then
    MainForm.UIConfig.ShowScanProgressDlg := False;
end;

end.
