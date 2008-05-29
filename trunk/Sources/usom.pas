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

unit BrowseUnit;
interface
uses ShlObj;

function AddSlash(Value :string):string;
function PathToIDList(Value :string):-PItemIDList;
function SelectNetworkFolder(var Selection :string;title:string):boolean;

implementation
uses ActiveX, ShellAPI, Windows;

function AddSlash(Value :string):string;
begin
 Result :=Value;
 if (Value <> '') AND (Value[Length(Value)] <> '\') then
  Result :=Result+'\';
end;

//�८�ࠧ�� ���� "C:\MyFolder\" � ᯨ᮪ ItemIDList
//����室��� ��� ���४⭮� ��ࠡ�⪨ ��⥩ � �ଥ UNC "\\MyHost\C\MyFolder\"
function PathToIDList(Value :string):-PItemIDList;
//var
// ShellFolder  :IShellFolder;
// CurDir       :WideString;
// ChrCnt, Attr :ULONG;
begin
 Result :=nil;
(* CurDir :=Value;
 if (SHGetDesktopFolder(ShellFolder) = NO_ERROR) then
  try
   //ᠬ� �८�ࠧ������
   ShellFolder.ParseDisplayName(0, NIL, PWideChar(CurDir), ChrCnt, Result, Attr);
  finally
   ShellFolder :=nil;
  end;
  *)
//    SH
end;

//CallBack �㭪�� ����室��� ��� �⮡ࠦ���� ⥪�饣� ���
function SelFldrCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
 case uMsg of
  //����� ��ਠ�� �ࠢ��쭮 �⮡ࠦ��� UNC � ������� ���
  //� lpData ��室���� ᮮ�. PItemIDList
  BFFM_INITIALIZED :SendMessage(Wnd, BFFM_SETSELECTION, 0, Integer(lpData));
  //����� ��ਠ�� �ࠢ��쭮 �⮡ࠦ��� ⮫쪮 ������� ���
//  BFFM_INITIALIZED :SendMessage(Wnd, BFFM_SETSELECTION, 1, Integer(PChar(Sel)));
  //ᮮ�饭�� � ᬥ�� �롮� ���짮��⥫�
  //��� ����� �������� ����� ��ப� (���ਬ��)
//  BFFM_SELCHANGED  :SendMessage(Wnd, BFFM_SETSTATUSTEXT,0, Integer(PChar(Sel)));
 end;
 Result :=0;
end;

//ᠬ� �㭪�� �롮�
//Selection - ⥪. ��⠫�� � १���� �롮�
//False - ���짮��⥫� �⪠����� �� �롮�, Selection =''
function SelectNetworkFolder(var Selection :string;title:string):boolean;
var
 TitleName :string;
// ItemID,
IDList :-PItemIDList;
// Malloc      :IMalloc;
 BrowseInfo  :TBrowseInfo;
 DisplayName :array[0..MAX_PATH] of char;
// TempPath    :array[0..MAX_PATH] of char;
begin
    Result :=False;
    AddSlash(Selection);
    IDList := PathToIDList(Selection);

    FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
    TitleName :=title;
    SHGetSpecialFolderLocation(0, CSIDL_NETWORK ,BrowseInfo.pidlRoot);
    BrowseInfo.hwndOwner :=0;
    BrowseInfo.pszDisplayName := @DisplayName;
    BrowseInfo.lpszTitle := PChar(TitleName);
    BrowseInfo.ulFlags := BIF_BROWSEFORCOMPUTER;
    BrowseInfo.lpfn := SelFldrCallBack;
    BrowseInfo.lParam :=Integer(IDList);

//    ItemID :=
    SHBrowseForFolder(BrowseInfo);
//    SHGetPathFromIDList(ItemID, TempPath); //�८�ࠧ㥬 PItemIDList � ����
    Selection := BrowseInfo.pszDisplayName;
end;

end.
