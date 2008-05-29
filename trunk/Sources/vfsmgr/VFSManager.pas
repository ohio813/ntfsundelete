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

unit VFSManager;

interface

uses
  SysUtils, Classes, SyncObjs, VirtualTrees, PythonEngine;

const
  VFS_FLAG_CONTAINER = 1;
  VFS_FLAG_DELETED = 2;
  VFS_USER_FLAG1 = 4;
  VFS_USER_FLAG2 = 8;
  VFS_USER_FLAG3 = 16;
  VFS_USER_FLAG4 = 32;
  VFS_RESERVED_FLAG1 = 64;
  VFS_RESERVED_FLAG2 = 128;

  CT_UNKNOWN = 0;
  CT_DIRECTORY = 1;
  CT_DRIVE = 2;
  CT_IMAGE = 3;
  CT_SEARCH_RESULTS = 4;


type
  //PVirtualNode = pointer;
  PNTFSData = ^TNTFSData;
  TNTFSData = packed record
    Node: PVirtualNode;
    ContentsNode: PVirtualNode;
    case integer of
    0:  (                       // for NTFS files
          mft_ref: int64;
          DataStreamCount: integer;
        );
    1:  (
          VolumeObject: PPyObject;  // for  drives
          ScanPercent: integer;
        );
  end;

  PPoolElement = ^TPoolElement;
  TPoolElement = packed record
    NextFree: PPoolElement;
  end;
  TRecordPool = class
  private
    FBlocks: TList;
    FReallocationDelta: integer;
    FRecordSize: integer;
    FRecordsInPool: integer;
    FAllocated: integer;
    FFreeItems: integer;
    FFreeTop: PPoolElement;
    procedure AllocateBlk;
    procedure AddFreeItem(ptr: pointer);
  public
    constructor Create(ARecordSize, ReallocationDelta: integer);
    destructor Destroy;override;
    function XAlloc: pointer;
    procedure XFree(ptr: pointer);

    property RecordSize: integer read FRecordSize;
    property Allocated: integer read FAllocated;
    property FreeItems: integer read FFreeItems;
    property RecordsInPool: integer read FRecordsInPool;

  end;

  PVFSEntry = ^TVFSEntry;
  TVFSEntry = packed record
    Parent: PVFSEntry;
    Prev: PVFSEntry;
    Next: PVFSEntry;
    Flags: byte; // VFS_FLAG-s
    NameLength: byte;
    CreateDate: TDateTime;
    ModifyDate: TDateTime;
    Name: PWideChar;
    UserData: pointer;
    case integer of
    0: (FirstChild: PVFSEntry;
        ContainerType: byte;
        ContainerTag: word;);
    1: (DataSize: int64;);
  end;

  TVFSDirContentsChangeEvent = procedure (Sender: TObject; TargetDirEntry: PVFSEntry) of object;
  TVFSDirAddNewEntryEvent = procedure (Sender: TObject; TargetDirEntry: PVFSEntry; AddedEntry: PVFSEntry) of object;
  TVFSDirRemoveEntryEvent = procedure (Sender: TObject; TargetDirEntry: PVFSEntry; RemovedEntry: PVFSEntry) of object;
  TVFSMoveEntryEvent = procedure (Sender: TObject; TargetEntry, FromEntry, ToEntry: PVFSEntry) of object;
  TVFSChangeNotification = procedure (Sender: TObject; ChangedEntry: PVFSEntry) of object;
  TVFSSearchResultEvent = procedure (Sender: TObject; FoundEntry: PVFSEntry) of object;
  TVFSSearchProgressEvent = procedure (Sender: TObject; ProcessedFolders: Cardinal) of object;


  TVFSManager = class(TComponent)
  private
    { Private declarations }
    FEntryPool: TRecordPool;
    FName8Pool: TRecordPool;
    FName13Pool: TRecordPool;
    FName24Pool: TRecordPool;
    FName32Pool: TRecordPool;
    FName48Pool: TRecordPool;
    FName64Pool: TRecordPool;
    FName80Pool: TRecordPool;
    FName96Pool: TRecordPool;
    FName128Pool: TRecordPool;
    FName192Pool: TRecordPool;
    FName256Pool: TRecordPool;
    FOnDirAddNewEntry: TVFSDirAddNewEntryEvent;
    FOnDirContentsChange: TVFSDirContentsChangeEvent;
    FRoot: PVFSEntry;
    FSearchResults: TList;
    FOnDirRemoveEntry: TVFSDirRemoveEntryEvent;
    FOnChangeNotification: TVFSChangeNotification;
    FOnMoveEntry: TVFSMoveEntryEvent;
    FOnSearchResult: TVFSSearchResultEvent;
    FOnSearchStart: TNotifyEvent;
    FOnSearchFinish: TNotifyEvent;
    FSearchCS: TCriticalSection;
    FOnSearchProgress: TVFSSearchProgressEvent;
    function GetSearchResultCount: integer;
    function GetSeatchResult(idx: integer): PVFSEntry;
  protected
    { Protected declarations }
    procedure DoDirContentsChange(target_entry: PVFSEntry);
    procedure DoDirAddNewEntry(target_entry: PVFSEntry; new_entry: PVFSEntry);
    procedure DoDirRemoveEntry(target_entry: PVFSEntry; removed_entry: PVFSEntry);
    procedure DoMoveEntry(target_entry, from_entry, to_entry: PVFSEntry);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    procedure Reset;
    destructor Destroy;override;

    function AddName(name: WideString): PWideChar;

    function AddFile(FileName: WideString;
                      IsDeleted: boolean;
                      CreateDate, ModifyDate: TDateTime;
                      Parent: PVFSEntry;
                      UserData: pointer;
                      DataSize: int64): PVFSEntry;

    function AddDirectory(DirName: WideString;
                      IsDeleted: boolean;
                      CreateDate, ModifyDate: TDateTime;
                      Parent: PVFSEntry;
                      UserData: pointer): PVFSEntry;

    function AddDrive(DriveName: WideString; DriveLetter: char; UserData: pointer): PVFSEntry;

    function AddContainer(Name: WideString;
                      IsDeleted: boolean;
                      CreateDate, ModifyDate: TDateTime;
                      Parent: PVFSEntry;
                      UserData: pointer;
                      ContainerType: byte;
                      Tag: word): PVFSEntry;

    procedure RemoveNode(Node: PVFSEntry);
    procedure RemoveNodeAndFree(Node: PVFSEntry);
    procedure MoveNode(Node: PVFSEntry; NewParent: PVFSEntry);
    function EntryName(p: PVFSEntry): WideString;
    function PathForEntry(p: PVFSEntry): WideString;

    procedure PerformChangeNotification(Node: PVFSEntry);

    procedure AddSearchResult(entry: PVFSEntry);

    procedure ClearSearchResults;

    property Root: PVFSEntry read FRoot;
    property SearchResultCount: integer read GetSearchResultCount;
    property SearchResults[idx: integer]: PVFSEntry read GetSeatchResult;

  published
    { Published declarations }
    property OnDirContentsChange: TVFSDirContentsChangeEvent read FOnDirContentsChange write FOnDirContentsChange;
    property OnDirAddNewEntry: TVFSDirAddNewEntryEvent read FOnDirAddNewEntry write FOnDirAddNewEntry;
    property OnDirRemoveEntry: TVFSDirRemoveEntryEvent read FOnDirRemoveEntry write FOnDirRemoveEntry;
    property OnChangeNotification: TVFSChangeNotification read FOnChangeNotification write FOnChangeNotification;
    property OnMoveEntry: TVFSMoveEntryEvent read FOnMoveEntry write FOnMoveEntry;
    property OnSearchResult: TVFSSearchResultEvent read FOnSearchResult write FOnSearchResult;
    property OnSearchStart: TNotifyEvent read FOnSearchStart write FOnSearchStart;
    property OnSearchFinish: TNotifyEvent read FOnSearchFinish write FOnSearchFinish;
    property OnSearchProgress: TVFSSearchProgressEvent read FOnSearchProgress write FOnSearchProgress;
  end;


  function VFSIsDirectoryEntry(p: PVFSEntry): boolean;
  function VFSIsDriveEntry(p: PVFSEntry): boolean;
  function VFSIsContainerEntry(p: PVFSEntry): boolean;
  function VFSIsDeletedEntry(p: PVFSEntry): boolean;
  function VFSCheckUserFlag(p: PVFSEntry; flag_idx: integer): boolean;
  procedure VFSSetUserFlag(p: PVFSEntry; flag_idx: integer; Value: boolean);
  function VFSIsFileEntry(p: PVFSEntry): boolean;
  function VFSHasDeletedChildren(p: PVFSEntry): boolean;
  function VFSCheckContainerType(p: PVFSEntry; ct: byte): boolean;
  function WideStringFromBuffer(buffer: pointer; Len: integer): WideString;

procedure Register;

implementation


uses Math, AcedStrings;

  function VFSHasDeletedChildren(p: PVFSEntry): boolean;
  begin
    if VFSIsDriveEntry(p) then
      result := True
    else begin
      if VFSIsContainerEntry(p) then begin
        result := VFSIsDeletedEntry(p);
        p := p^.FirstChild;
        while p <> nil do begin
          if VFSIsDeletedEntry(p) then begin
            result := True;
            break;
          end else if VFSIsContainerEntry(p) then begin
            result := VFSHasDeletedChildren(p);
            if result then
              break;
          end;
          p := p^.Next;
        end;
      end else
        result := VFSIsDeletedEntry(p);
    end;
  end;

  function WideStringFromBuffer(buffer: pointer; Len: integer): WideString;
  var
    name_buffer: pwidechar;
    i: integer;
  begin
    name_buffer := buffer;
    result := '';
    for i := 0 to Len-1 do
      result := result + (name_buffer+i)^;
  end;

  function VFSIsContainerEntry(p: PVFSEntry): boolean;
  begin
    result := (p^.Flags and VFS_FLAG_CONTAINER = VFS_FLAG_CONTAINER);
  end;

  function VFSCheckContainerType(p: PVFSEntry; ct: byte): boolean;
  begin
    result := VFSIsContainerEntry(p) and (p^.ContainerType = ct); 
  end;

  function VFSIsFileEntry(p: PVFSEntry): boolean;
  begin
    result := (p^.Flags and VFS_FLAG_CONTAINER = 0);
  end;

  function VFSIsDeletedEntry(p: PVFSEntry): boolean;
  begin
    result := p^.Flags and VFS_FLAG_DELETED = VFS_FLAG_DELETED;
  end;

  function VFSIsDirectoryEntry(p: PVFSEntry): boolean;
  begin
    result := VFSIsContainerEntry(p) and (p^.ContainerType = CT_DIRECTORY);
  end;

  function VFSIsDriveEntry(p: PVFSEntry): boolean;
  begin
    result := VFSIsContainerEntry(p) and (p^.ContainerType = CT_DRIVE);
  end;

  function VFSCheckUserFlag(p: PVFSEntry; flag_idx: integer): boolean;
  begin
    case flag_idx of
    0: result := p^.Flags and VFS_USER_FLAG1 = VFS_USER_FLAG1;
    1: result := p^.Flags and VFS_USER_FLAG2 = VFS_USER_FLAG2;
    2: result := p^.Flags and VFS_USER_FLAG3 = VFS_USER_FLAG3;
    3: result := p^.Flags and VFS_USER_FLAG4 = VFS_USER_FLAG4;
    else
      Raise Exception.Create('Invalid user flag for VFSCheckUserFlag');
    end;
  end;

  procedure VFSSetUserFlag(p: PVFSEntry; flag_idx: integer; Value: boolean);
  begin
    if Value then begin
      case flag_idx of
      0: p^.Flags := p^.Flags or VFS_USER_FLAG1;
      1: p^.Flags := p^.Flags or VFS_USER_FLAG2;
      2: p^.Flags := p^.Flags or VFS_USER_FLAG3;
      3: p^.Flags := p^.Flags or VFS_USER_FLAG4;
      else
        Raise Exception.Create('Invalid user flag for VFSSetUserFlag');
      end;
    end else begin
      case flag_idx of
      0: p^.Flags := p^.Flags and not VFS_USER_FLAG1;
      1: p^.Flags := p^.Flags and not VFS_USER_FLAG2;
      2: p^.Flags := p^.Flags and not VFS_USER_FLAG3;
      3: p^.Flags := p^.Flags and not VFS_USER_FLAG4;
      else
        Raise Exception.Create('Invalid user flag for VFSSetUserFlag');
      end;
    end;
  end;

procedure Register;
begin
  RegisterComponents('Drive Suite', [TVFSManager]);
end;

{ TRecordPool }

function TRecordPool.XAlloc: pointer;
begin
  if FFreeTop = nil then
    AllocateBlk;
  result := FFreeTop;
  FFreeTop := FFreeTop^.NextFree;
  inc(FAllocated);
  dec(FFreeItems);
end;

constructor TRecordPool.Create(ARecordSize, ReallocationDelta: integer);
begin
  inherited Create;
  FReallocationDelta := ReallocationDelta;
  FRecordSize := Max(ARecordSize, sizeof(TPoolElement));
  FBlocks := TList.Create;
  FRecordsInPool := 0;
  FAllocated := 0;
  FFreeItems := 0;
  FFreeTop := nil;
end;

destructor TRecordPool.Destroy;
var
  i: integer;
begin
  for i := 0 to FBlocks.Count -1 do
    FreeMem(FBlocks.Items[i]);
  inherited;
end;

procedure TRecordPool.XFree(ptr: pointer);
begin
  AddFreeItem(ptr);
  dec(FAllocated);
  inc(FFreeItems);
end;

procedure TRecordPool.AllocateBlk;
  function PtrAdd(p: pointer; c: cardinal): pointer;
  begin
    result := pointer(cardinal(p)+c);
  end;
var
  P: pointer;
  i: integer;
begin
  P := AllocMem(FRecordSize * FReallocationDelta);
  if p = nil then
    raise Exception.Create('Not enough memory');
  FBlocks.Add(p);
  for i := 0 to FReallocationDelta-1 do
    AddFreeItem(PtrAdd(P, i*FRecordSize));
  inc(FRecordsInPool, FReallocationDelta);
  inc(FFreeItems, FReallocationDelta);
end;

procedure TRecordPool.AddFreeItem(ptr: pointer);
begin
  PPoolElement(ptr)^.NextFree := FFreeTop;
  FFreeTop := PPoolElement(ptr);
end;

{ TVFSManager }

function TVFSManager.AddContainer(Name: WideString; IsDeleted: boolean;
  CreateDate, ModifyDate: TDateTime; Parent: PVFSEntry; UserData: pointer;
  ContainerType: byte; Tag: word): PVFSEntry;
var
  NP: PWideChar;
  EP: PVFSEntry;
begin
  if Parent = nil then
    Parent := FRoot;
  // Parent can be nil anyway while initialization
  if (Parent <> nil) and not VFSIsContainerEntry(Parent) then
    raise Exception.Create('Cannot add a child file to non-directory parent');
  NP := AddName(Name);
  EP := FEntryPool.XAlloc;
  EP^.NameLength := length(Name);
  EP^.Name := NP;
  EP^.Parent := Parent;
  EP^.Flags := VFS_FLAG_CONTAINER;
  if IsDeleted then
    EP^.Flags := VFS_FLAG_CONTAINER or VFS_FLAG_DELETED;
  EP^.CreateDate := CreateDate;
  EP^.ModifyDate := ModifyDate;
  EP^.UserData := UserData;
  EP^.Next := nil;
  EP^.Prev := nil;
  EP^.FirstChild := nil;
  EP^.ContainerType := ContainerType;
  EP^.ContainerTag := Tag;
  if Parent <> nil then begin
    EP^.Next := Parent^.FirstChild;
    if (Parent^.FirstChild <> nil) then
      Parent^.FirstChild^.Prev := EP;
    Parent^.FirstChild := EP;
  end;
  result := EP;
  DoDirAddNewEntry(Parent, Result);
  DoDirContentsChange(Parent);
end;

function TVFSManager.AddDirectory(DirName: WideString; IsDeleted: boolean;
  CreateDate, ModifyDate: TDateTime; Parent: PVFSEntry;
  UserData: pointer): PVFSEntry;
begin
  result := AddContainer(DirName, IsDeleted, CreateDate, ModifyDate,Parent, UserData, CT_DIRECTORY, 0);
end;

function TVFSManager.AddDrive(DriveName: WideString;
  DriveLetter: char; UserData: pointer): PVFSEntry;
begin
  result := AddContainer(DriveName, False, time, time, Root, UserData, CT_DRIVE, word(DriveLetter));
end;

function TVFSManager.AddFile(FileName: WideString; IsDeleted: boolean;
  CreateDate, ModifyDate: TDateTime; Parent: PVFSEntry; UserData: pointer;
  DataSize: int64): PVFSEntry;
var
  NP: PWideChar;
  EP: PVFSEntry;
begin
  if Parent = nil then
    Parent := FRoot;
  // Parent can be nil anyway while initialization
  if (Parent <> nil) and not VFSIsContainerEntry(Parent) then
    raise Exception.Create('Cannot add a child file to non-directory parent');
  NP := AddName(FileName);
  EP := FEntryPool.XAlloc;
  EP^.NameLength := length(FileName);
  EP^.Name := NP;
  EP^.Parent := Parent;
  EP^.Flags := 0;
  if IsDeleted then
    EP^.Flags := VFS_FLAG_DELETED;
  EP^.CreateDate := CreateDate;
  EP^.ModifyDate := ModifyDate;
  EP^.DataSize := DataSize;
  EP^.UserData := UserData;
  EP^.Next := nil;
  EP^.Prev := nil;
  if Parent <> nil then begin
    EP^.Next := Parent^.FirstChild;
    if (Parent^.FirstChild <> nil) then
      Parent^.FirstChild^.Prev := EP;
    Parent^.FirstChild := EP;
  end;
  result := EP;
  DoDirAddNewEntry(Parent, Result);
  DoDirContentsChange(Parent);
end;

function TVFSManager.AddName(name: WideString): PWideChar;
var
  L: integer;
  p: PWideChar;
  X: PWideChar;
begin
  if name <> '' then begin
    L := length(name);
    if L <= 8 then
      P := FName8Pool.XAlloc
    else if L <= 13 then
      P := FName13Pool.XAlloc
    else if L <= 24 then
      P := FName24Pool.XAlloc
    else if L <= 32 then
      P := FName32Pool.XAlloc
    else if L <= 48 then
      P := FName48Pool.XAlloc
    else if L <= 64 then
      P := FName64Pool.XAlloc
    else if L <= 80 then
      P := FName80Pool.XAlloc
    else if L <= 96 then
      P := FName96Pool.XAlloc
    else if L <= 128 then
      P := FName128Pool.XAlloc
    else if L <= 192 then
      P := FName192Pool.XAlloc
    else if L <= 256 then
      P := FName256Pool.XAlloc
    else
      Raise Exception.Create('Invalid file name. Length > 256');
    X := PWideChar(name);
    Move(X^, P^, L*sizeof(WideChar));
    result := P;
  end else
    result := nil;
end;

constructor TVFSManager.Create(AOwner: TComponent);
begin
  inherited;
  FSearchCS := TCriticalSection.Create;
  FSearchResults := TList.Create;
  FRoot := nil;
  FEntryPool := nil;
  FName8Pool := nil;
  FName13Pool := nil;
  FName24Pool := nil;
  FName32Pool := nil;
  FName48Pool := nil;
  FName64Pool := nil;
  FName80Pool := nil;
  FName96Pool := nil;
  FName128Pool := nil;
  FName192Pool := nil;
  FName256Pool := nil;
  Reset;
end;

destructor TVFSManager.Destroy;
begin
  FSearchCS.Free;
  FEntryPool.Free;
  FName8Pool.Free;
  FName13Pool.Free;
  FName24Pool.Free;
  FName32Pool.Free;
  FName48Pool.Free;
  FName64Pool.Free;
  FName80Pool.Free;
  FName96Pool.Free;
  FName128Pool.Free;
  FName192Pool.Free;
  FName256Pool.Free;
  FSearchResults.Free;
  inherited;
end;

procedure TVFSManager.DoDirAddNewEntry(target_entry, new_entry: PVFSEntry);
begin
  if Assigned (FOnDirAddNewEntry) then begin
    FOnDirAddNewEntry(self, target_entry, new_entry);
  end;
end;

procedure TVFSManager.DoDirContentsChange(target_entry: PVFSEntry);
begin
  if Assigned(FOnDirContentsChange) then begin
    FOnDirContentsChange(self, target_entry);
  end;
end;

procedure TVFSManager.DoDirRemoveEntry(target_entry,
  removed_entry: PVFSEntry);
begin
  if assigned (FOnDirRemoveEntry) then begin
    FOnDirRemoveEntry(self, target_entry, removed_entry);
  end;
end;

procedure TVFSManager.DoMoveEntry(target_entry, from_entry,
  to_entry: PVFSEntry);
begin
  if Assigned (FOnMoveEntry) then
    FOnMoveEntry(self, target_entry, from_entry, to_entry);
end;

procedure TVFSManager.MoveNode(Node, NewParent: PVFSEntry);
var
  tmpParent: PVFSEntry;
begin
  if NewParent = nil then
    NewParent := FRoot;
  if not VFSIsContainerEntry(NewParent) then
    raise Exception.Create('Cannot move node to non-directory parent');
  if Node^.Parent = NewParent then
    exit;
  RemoveNode(Node);
  if NewParent^.FirstChild <> nil then
    NewParent^.FirstChild^.Prev := Node;
  Node^.Prev := nil;
  Node^.Next := NewParent^.FirstChild;
  tmpParent := Node^.Parent;
  Node^.Parent := NewParent;
  NewParent^.FirstChild := Node;
  //DoDirAddNewEntry(NewParent, Node);
  DoMoveEntry(Node, tmpParent, NewParent);
  DoDirContentsChange(NewParent);
end;

procedure TVFSManager.PerformChangeNotification(Node: PVFSEntry);
begin
  if Assigned (FOnChangeNotification) then begin
    FOnChangeNotification(self, Node);
  end;
  if Node^.Parent <> nil then begin
    DoDirContentsChange(Node^.Parent);
  end;
end;

procedure TVFSManager.RemoveNode(Node: PVFSEntry);
begin
  if Node^.Prev <> nil then
    Node^.Prev^.Next := Node^.Next;
  if Node^.Next <> nil then
    Node^.Next^.Prev := Node^.Prev;
  if (Node^.Parent <> nil) and (Node^.Parent^.FirstChild = Node) then
    Node^.Parent^.FirstChild := Node^.Next;
  DoDirRemoveEntry(Node^.Parent, Node);
  DoDirContentsChange(Node^.Parent);
end;

procedure TVFSManager.RemoveNodeAndFree(Node: PVFSEntry);
begin
  RemoveNode(Node);
  FEntryPool.XFree(Node);
end;

procedure TVFSManager.Reset;
begin
  FSearchResults.Clear;
  if FEntryPool <> nil then
    FEntryPool.Free;
  if FName8Pool <> nil then
    FName8Pool.Free;
  if FName13Pool <> nil then
    FName13Pool.Free;
  if FName24Pool <> nil then
    FName24Pool.Free;
  if FName32Pool <> nil then
    FName32Pool.Free;
  if FName48Pool <> nil then
    FName48Pool.Free;
  if FName64Pool <> nil then
    FName64Pool.Free;
  if FName80Pool <> nil then
    FName80Pool.Free;
  if FName96Pool <> nil then
    FName96Pool.Free;
  if FName128Pool <> nil then
    FName128Pool.Free;
  if FName192Pool <> nil then
    FName192Pool.Free;
  if FName256Pool <> nil then
    FName256Pool.Free;
  FRoot := nil;
  FEntryPool := TRecordPool.Create(Sizeof(TVFSEntry), 4096);
  FName8Pool := TRecordPool.Create(8*sizeof(WideChar), 2048);
  FName13Pool := TRecordPool.Create(13*sizeof(WideChar), 2048);
  FName24Pool := TRecordPool.Create(24*sizeof(WideChar), 2048);
  FName32Pool := TRecordPool.Create(32*sizeof(WideChar), 2048);
  FName48Pool := TRecordPool.Create(48*sizeof(WideChar), 1024);
  FName64Pool := TRecordPool.Create(64*sizeof(WideChar), 512);
  FName80Pool := TRecordPool.Create(80*sizeof(WideChar), 512);
  FName96Pool := TRecordPool.Create(96*sizeof(WideChar), 256);
  FName128Pool := TRecordPool.Create(128*sizeof(WideChar), 256);
  FName192Pool := TRecordPool.Create(192*sizeof(WideChar), 128);
  FName256Pool := TRecordPool.Create(256*sizeof(WideChar), 64);
  FRoot := AddContainer('Drives', false, date, date, nil, nil, 0,0);
end;

function TVFSManager.GetSearchResultCount: integer;
begin
  result := FSearchResults.Count;
end;

function TVFSManager.GetSeatchResult(idx: integer): PVFSEntry;
begin
  result := FSearchResults[idx];
end;

procedure TVFSManager.ClearSearchResults;
begin
  FSearchResults.Clear;
end;

function TVFSManager.EntryName(p: PVFSEntry): WideString;
begin
  if p^.Name <> nil then
    result := WideStringFromBuffer(p^.Name, p^.NameLength)
  else begin
    if VFSIsDirectoryEntry(p) then
      result := 'Lost Folder#'+IntToStr(PNTFSData(p^.UserData)^.mft_ref)
    else
      result := 'Lost File';
  end;
end;

function TVFSManager.PathForEntry(p: PVFSEntry): WideString;
var
  S: string;
begin
  result := '';
  if (p <> nil) and (p <> FRoot) then begin
    S := PathForEntry(p^.Parent);
    if S <> '' then
      result := S + '\' + EntryName(p)
    else
      result := EntryName(p);
  end;
end;

procedure TVFSManager.AddSearchResult(entry: PVFSEntry);
begin
  FSearchCS.Enter;
  FSearchResults.Add(entry);
  FSearchCS.Leave;
  if Assigned(FOnSearchResult) then
    FOnSearchResult(self, entry);
end;

{ TVFSSearchThread }


end.
