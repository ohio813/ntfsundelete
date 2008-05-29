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

program NTFSUndelete;

uses
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  PropertiesDlgUnit in 'PropertiesDlgUnit.pas' {PropertiesDlg},
  PythonMisc in 'PythonMisc.pas',
  ProgressDlgUnit in 'ProgressDlgUnit.pas' {ProgressDlg},
  SysIcons in 'SysIcons.pas',
  ScanProgressDlgUnit in 'ScanProgressDlgUnit.pas' {ScanProgressDlg},
  AboutDlgUnit in 'AboutDlgUnit.pas' {AboutForm},
  LoggingFormUnit in 'LoggingFormUnit.pas' {LoggingForm},
  VFSManager in 'vfsmgr\VFSManager.pas',
  VFSMgr in 'vfsmgr\VFSMgr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'NTFS Undelete';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TLoggingForm, LoggingForm);
  Application.CreateForm(TPropertiesDlg, PropertiesDlg);
  Application.CreateForm(TProgressDlg, ProgressDlg);
  Application.CreateForm(TScanProgressDlg, ScanProgressDlg);
  Application.Run;
end.
