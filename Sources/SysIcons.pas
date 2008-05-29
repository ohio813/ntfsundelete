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

unit SysIcons;

interface

uses Controls, Graphics;

type

    // The main purpose of this class is to copy icons
    // from system ImageList to a local one, and to perform appropriate mapping.
    TUndeleteImgList = class
    private

        FDeletedOverlay: Integer;
//        FShadowOverlay: Integer;

        FImageList: TImageList;
        FSysImageList: TImageList;

        FMapping: Array of Integer;
        FTempIcon: TIcon;

//        procedure CreateShadowImage;

        function GetMapped(Idx: Integer): Integer;
        function CopyFromSysImg(Idx: Integer): Integer;

    public

        constructor Create(Overlays: TImageList);
        destructor Destroy; override;

        function VolumeIdx(VolumeName: String): Integer;
        function FileIdx(FileName: String): Integer;
        function FolderIdx(Opened: Boolean): Integer;

        property DeletedOverlayIdx: Integer read FDeletedOverlay;
//        property ShadowOverlayIdx: Integer read FShadowOverlay;

        property ImageList: TImageList read FImageList;

    end;


function GetFileSysType(FileName: String): String;
function GetFileImageId(FileName: String): Integer;

function GetFolderImageId(Opened: Boolean): Integer;
function GetFolderSysType: String;

function GetSysImageId(Path: String): Integer;
function GetSysType(Path: String): String;

function GetDisplayName(Path: String): String;



implementation

uses Windows, Types, ShellApi, ShlObj, ImgList, CommCtrl;

{ TUndeleteImgList }

constructor TUndeleteImgList.Create(Overlays: TImageList);
var SFI: TSHFileInfo;
    OverlayIcon: TIcon;
begin
    // initializations
    SetLength(FMapping, 0);
    FImageList := TImageList.Create(Nil);
    FImageList.Handle := ImageList_Create(16,16, ILC_COLOR32 or ILC_MASK, 0, 16);
    FImageList.BkColor := clNone;
    FImageList.ImageType := itImage;
    FImageList.Width := 16;
    FImageList.Height := 16;
    FImageList.Masked := True;
//    FImageList.


    FTempIcon := TIcon.Create;
    FTempIcon.Transparent := True;
//    FTempIcon.

    FSysImageList := TImageList.Create(Nil);
    FSysImageList.ShareImages := True;

    FSysImageList.Handle := SHGetFileInfo('', 0, SFI, SizeOf(SFI), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);

    // Extract icon from the Overlays image list.

    OverlayIcon := TIcon.Create;
    Overlays.GetIcon(0, OverlayIcon);

    Assert(OverlayIcon <> Nil, 'Overlays should have 1 overlay icon. (But it haven''t.)');
    FDeletedOverlay := FImageList.AddIcon(OverlayIcon);
    Assert(FDeletedOverlay <> -1, 'Overlay icon for deleted files was not added to image list');

    OverlayIcon.Free;

    FImageList.Overlay(FDeletedOverlay, FDeletedOverlay);

//    CreateShadowImage;
end;

destructor TUndeleteImgList.Destroy;
begin
    FTempIcon.Free;
    FImageList.Free;

    inherited;
end;

{procedure TUndeleteImgList.CreateShadowImage;
var ShadowBitmap: Graphics.TBitmap;
    i, k: Integer;
begin

    ShadowBitmap := Graphics.TBitmap.Create;
    with ShadowBitmap do
    begin
        PixelFormat := pf8bit;
        Width := FImageList.Width;
        Height := FImageList.Height;

        Canvas.Brush.Color := clWindow;
        Canvas.FillRect(Rect(0, 0, Width, Height));

        for i := 0 to Width - 2 do
          for k := 0 to Height - 1 do
          begin
              if i mod 2 = 0 then
                  Canvas.Pixels[i + (k mod 2), k] := clGreen;
          end;
    end;
    FShadowOverlay := FImageList.AddMasked(ShadowBitmap, clGreen);
    Assert(FShadowOverlay <> -1, 'Shadow mask was not added to image list');
    ShadowBitmap.Free;

    FImageList.Overlay(FShadowOverlay, FShadowOverlay);
end;
}
function TUndeleteImgList.FileIdx(FileName: String): Integer;
begin
    Result := GetMapped(GetFileImageId(FileName));
end;

function TUndeleteImgList.FolderIdx(Opened: Boolean): Integer;
begin
    Result := GetMapped(GetFolderImageId(Opened));
end;

function TUndeleteImgList.VolumeIdx(VolumeName: String): Integer;
begin
    Result := GetMapped(GetSysImageId(VolumeName));
end;


// Other functions

function GetFileSysType(FileName: String): String;
var SFI: TSHFileInfo;
begin
   if SHGetFileInfo(PChar(FileName),
              FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(TSHFileInfo),
              SHGFI_USEFILEATTRIBUTES or SHGFI_TYPENAME) <> 0 then
       Result := SFI.szTypeName
   else
       Result := '';
end;

function GetFileImageId(FileName: String): Integer;
var
  SFI: TSHFileInfo;
begin

  if SHGetFileInfo(PChar(String(FileName)), FILE_ATTRIBUTE_NORMAL, SFI,
         SizeOf(TSHFileInfo),
         SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_USEFILEATTRIBUTES) = 0 then
    Result := -1
  else
    Result := SFI.iIcon;
end;

function GetFolderImageId(Opened: Boolean): Integer;
var Flags: DWord;
    SFI: TSHFileInfo;
begin
    Flags := SHGFI_USEFILEATTRIBUTES or SHGFI_SYSICONINDEX;
    if Opened then
      Flags := Flags or SHGFI_OPENICON;

    Result := -1;
    if SHGetFileInfo(PChar('C:\123\'), FILE_ATTRIBUTE_DIRECTORY, SFI, SizeOf(TSHFileInfo),  Flags) <> 0 then
      Result := SFI.iIcon;
end;

function GetSysImageId(Path: String): Integer;
var
  SFI: TSHFileInfo;
begin
  if SHGetFileInfo(PChar(Path), 0, SFI,
         SizeOf(TSHFileInfo),
         SHGFI_SYSICONINDEX or SHGFI_SMALLICON) = 0 then
    Result := -1
  else
    Result := SFI.iIcon;
end;

function GetSysType(Path: String): String;
var SFI: TSHFileInfo;
begin
   if SHGetFileInfo(PChar(Path),
              0, SFI, SizeOf(TSHFileInfoW),
              SHGFI_TYPENAME) <> 0 then
       Result := SFI.szTypeName
    else
        Result := '';
end;

function GetDisplayName(Path: String): String;
var SFI: TSHFileInfo;
begin
   if SHGetFileInfo(PChar(Path),
              0, SFI, SizeOf(TSHFileInfo),
              SHGFI_DISPLAYNAME) <> 0 then
       Result := SFI.szDisplayName
    else
        Result := '';
end;

function GetFolderSysType: String;
var SFI: TSHFileInfo;
begin
    if SHGetFileInfo(PChar(''),
              FILE_ATTRIBUTE_DIRECTORY, SFI, SizeOf(TSHFileInfo),
              SHGFI_USEFILEATTRIBUTES or SHGFI_TYPENAME) <> 0 then
        Result := SFI.szTypeName
    else
        Result := '';
end;

function TUndeleteImgList.GetMapped(Idx: Integer): Integer;
var Len: Integer;
    i: Integer;
begin
    if Idx < 0 then
    begin
        Result := -1;
        Exit;
    end;

    if Idx > Length(FMapping) - 1 then
    begin
        Len := Length(FMapping);
        SetLength(FMapping, Idx + 1);
        for i := Len to Idx - 1 do
            FMapping[i] := -1;
        FMapping[Idx] := CopyFromSysImg(Idx);
    end
     else
    if FMapping[Idx] = -1 then
        FMapping[Idx] := CopyFromSysImg(Idx);

    Result := FMapping[Idx];
end;

function TUndeleteImgList.CopyFromSysImg(Idx: Integer): Integer;
begin
    FSysImageList.GetIcon(Idx, FTempIcon);
    Result := FImageList.AddIcon(FTempIcon);
end;

end.