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

unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, PythonEngine, StdCtrls, PythonMisc,
  VFSManager, ImgList, ExtCtrls, VirtualTrees, StdActns,
  ShellApi, ShlObj, SyncObjs, ActnList, Menus, Buttons,
  PythonGUIInputOutput, SysIcons, XPMan;


const
  PCM_BASE = $BF00;
  PCM_StartProgressBar = PCM_BASE + 1;
  PCM_NotifyProgressBar = PCM_BASE + 2;
  PCM_FinishProgressBar = PCM_BASE + 3;
  PCM_ShowMessage = PCM_BASE + 4;
  VFM_AddNewEntry = PCM_BASE + 5;
  VFM_MoveEntry = PCM_BASE + 6;
  VFM_ChangeNotification = PCM_BASE + 7;
  VFM_AddSearchResult = PCM_BASE + 8;
  PCM_InitSearch = PCM_BASE + 9;
  PCM_DoneSearch = PCM_BASE + 10;
  PCM_SetQVRowCount = PCM_BASE + 11;
  PCM_SetQVCaption = PCM_BASE + 12;
  PCM_SelectFolder = PCM_BASE + 18;
  PCM_NotifyRecoveryProgress = PCM_BASE + 19;
  PCM_RecoveryPanelInit = PCM_BASE + 20;
  PCM_RecoveryPanelDone = PCM_BASE + 21;
  PCM_EmitRecoveryMessage = PCM_BASE + 22;
  PCM_QuerySaveFileDlg = PCM_BASE + 23;
  PCM_ShowProgressDlg = PCM_BASE + 25;
  PCM_HideProgressDlg = PCM_BASE + 26;
  PCM_NotifyProgressDlg = PCM_BASE + 27;
  PCM_MarkEntry = PCM_BASE + 28;
  PCM_UnmarkEntry = PCM_BASE + 29;
  PCM_ExpandEntry =PCM_BASE + 30;
  PCM_SetSearchCaption = PCM_BASE + 31;
  PCM_SetScanPercent = PCM_BASE + 32;
  PCM_ShowScanDlg = PCM_BASE + 33;
  PCM_HideScanDlg = PCM_BASE + 34;
  PCM_ShowYesNoDlg = PCM_BASE + 35;

  VFM_ExpandEntryEx = PCM_BASE + 36;

  PCM_AppendLogMsg = PCM_BASE + 37;
  PCM_SetLastLogMsg = PCM_BASE + 38;

type
  TVFMMessage = record
    code: integer;
    ChangedEntry, TargetEntry, TargetDirEntry, AddedEntry: PVFSEntry;
    FromEntry, ToEntry: PVFSEntry;
  end;
  PVFMMessage = ^TVFMMessage;
  TYesNoDlgMessage = record
    Msg: pchar;
    result: integer;
  end;
  PYesNoDlgMessage = ^TYesNoDlgMessage;

  TRecoveryProgressMessage = record
    CurrentFileProgress,
    TotalProgress,
    TotalFiles,
    ProcessedFiles,
    RemainFiles: integer;

    CurrentFileName,
    EstTime,
    ElapsTime,
    TimeLeft: pchar;
  end;
  PRecoveryProgressMessage = ^TRecoveryProgressMessage;

  TShowProgressDlgMessage = record
    caption: pchar;
    task_caption: pchar;
  end;
  PShowProgressDlgMessage = ^TShowProgressDlgMessage;

  TRecoveryMsgType = (rmtMessage = 1, rmtError = 2, rmtWarning = 3, rmtSuccess = 4);
  TRecoveryMsg = record
    Time: TDateTime;
    MsgType: TRecoveryMsgType;
    Text: string;
  end;
  PRecoveryMsg = ^TRecoveryMsg;

  TConfigFileRecord = record
    ShowScanProgressDlg: boolean;
    CCreateDateVisible, CNameVisible,
    CModifyDateVisible, CSizeVisible,
    CMFTRefVisible, CDataStreamsVisible: boolean;
    SCreateDateVisible, SNameVisible,
    SModifyDateVisible, SSizeVisible,
    SMFTRefVisible, SDataStreamsVisible,
    SPathVisible: boolean;
    QuickViewVisible: boolean;
    HighlightDeletedPath: boolean;
  end;

  TUIConfiguration = class
  private
    FConf: TConfigFileRecord;
    procedure MakeDefaultConfiguration;
    function GetConfigFilePath: string;
  public
    procedure Load;
    procedure Save;
    property ShowScanProgressDlg: boolean read FConf.ShowScanProgressDlg write FConf.ShowScanProgressDlg;
    property CCreateDateVisible: boolean read FConf.CCreateDateVisible write FConf.CCreateDateVisible;
    property CNameVisible: boolean read FConf.CNameVisible write FConf.CNameVisible;
    property CModifyDateVisible: boolean read FConf.CModifyDateVisible write FConf.CModifyDateVisible;
    property CSizeVisible: boolean read FConf.CSizeVisible write FConf.CSizeVisible;
    property CMFTRefVisible: boolean read FConf.CMFTRefVisible write FConf.CMFTRefVisible;
    property CDataStreamsVisible: boolean read FConf.CDataStreamsVisible write FConf.CDataStreamsVisible;
    property SCreateDateVisible: boolean read FConf.SCreateDateVisible write FConf.SCreateDateVisible;
    property SNameVisible: boolean read FConf.SNameVisible write FConf.SNameVisible;
    property SModifyDateVisible: boolean read FConf.SModifyDateVisible write FConf.SModifyDateVisible;
    property SSizeVisible: boolean read FConf.SSizeVisible write FConf.SSizeVisible;
    property SMFTRefVisible: boolean read FConf.SMFTRefVisible write FConf.SMFTRefVisible;
    property SDataStreamsVisible: boolean read FConf.SDataStreamsVisible write FConf.SDataStreamsVisible;
    property SPathVisible: boolean read FConf.SPathVisible write FConf.SPathVisible;
    property QuickViewVisible: boolean read FConf.QuickViewVisible write FConf.QuickViewVisible;
    property HighlightDeletedPath: boolean read FConf.HighlightDeletedPath write FConf.HighlightDeletedPath;
  end;


  TMainForm = class(TForm)
    ImageList1: TImageList;
    ilOverlays: TImageList;
    VFSManager1: TVFSManager;
    MainMenu1: TMainMenu;
    MainActionList: TActionList;
    File1: TMenuItem;
    SaveAs1: TMenuItem;
    ActionExit: TFileExit;
    N1: TMenuItem;
    Exit1: TMenuItem;
    PopupMenu1: TPopupMenu;
    SaveAs2: TMenuItem;
    N2: TMenuItem;
    ActionProperties: TAction;
    Properties1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Properties2: TMenuItem;
    ActionSaveAs: TAction;
    SaveFileDlg: TSaveDialog;
    ActionSearch: TAction;
    Actions1: TMenuItem;
    ActionSelectAll: TAction;
    ActionMarkAll: TAction;
    ActionMarkSelected: TAction;
    Clearselection1: TMenuItem;
    Markselected1: TMenuItem;
    Selectall1: TMenuItem;
    Properties3: TMenuItem;
    N5: TMenuItem;
    ActionUnmarkAll: TAction;
    ActionUnmarkSelected: TAction;
    Unmarkall1: TMenuItem;
    ActionUnmarkSelected1: TMenuItem;
    ActionStopCurrentTask: TAction;
    ActionPauseCurrentTask: TAction;
    ActionResumeCurrentTask: TAction;
    PageControl1: TPageControl;
    BrowseSheet: TTabSheet;
    SearchSheet: TTabSheet;
    DirTree: TVirtualStringTree;
    Splitter1: TSplitter;
    Panel1: TPanel;
    Label1: TLabel;
    SearchMaskCombo: TComboBox;
    ActionUpFolder: TAction;
    ActionExecuteScript: TAction;
    RecentScripts: TPopupMenu;
    ExecuteScriptMenuItem: TMenuItem;
    N6: TMenuItem;
    Panel2: TPanel;
    QuickViewPanel: TPanel;
    Splitter2: TSplitter;
    ContentsList: TVirtualStringTree;
    QuickView: TVirtualStringTree;
    Panel4: TPanel;
    Label6: TLabel;
    QVFileNameLabel: TLabel;
    appMod: TPythonModule;
    PyVFSEntryType: TPythonType;
    ActionCancelSearch: TAction;
    ActionSaveChecked: TAction;
    Label7: TLabel;
    LocationCb: TComboBox;
    TabSheet2: TTabSheet;
    Panel5: TPanel;
    Label8: TLabel;
    CBXRecoveryFolder: TComboBox;
    RecoveryBrowseFolderButton: TButton;
    GroupBox1: TGroupBox;
    RBAutorenameIfExist: TRadioButton;
    RBAskForName: TRadioButton;
    RBSkipThoseFiles: TRadioButton;
    RBOverwrite: TRadioButton;
    GroupBox2: TGroupBox;
    CBRecoverFolderStructure: TCheckBox;
    CBRecoverAllDataStreams: TCheckBox;
    Panel6: TPanel;
    Panel8: TPanel;
    CurrentFileRecoveryProgressBar: TProgressBar;
    CurrentFileRecoveryPercentLabel: TLabel;
    CurrentRecoveryFileLabel: TLabel;
    Label10: TLabel;
    TotalRecoveryProgressBar: TProgressBar;
    Panel7: TPanel;
    TotalRecoveryPercentLabel: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    RecoveryTotalFilesLabel: TLabel;
    RecoveryProcessedLabel: TLabel;
    RecoveryRemainLabel: TLabel;
    Bevel1: TBevel;
    Label26: TLabel;
    RecoveryStartButton: TButton;
    RecoverySkipFileButton: TButton;
    RecoveryStopButton: TButton;
    GroupBox3: TGroupBox;
    RBUncheckAllProcessed: TRadioButton;
    RBUnckeckSuccessProcessed: TRadioButton;
    Label9: TLabel;
    RecoveryProtocol: TVirtualStringTree;
    ToolBar2: TToolBar;
    RMessagesFilterButton: TToolButton;
    RSuccessesFilterButton: TToolButton;
    RWarningsFilterButton: TToolButton;
    RErrorsFilterButton: TToolButton;
    Bevel2: TBevel;
    ToolButton9: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    RBDoNotUncheck: TRadioButton;
    Markall1: TMenuItem;
    Markselected2: TMenuItem;
    Selectall2: TMenuItem;
    Unmarkselected1: TMenuItem;
    Selectall3: TMenuItem;
    ActionGoTo: TAction;
    PopupGotoMenu: TMenuItem;
    N7: TMenuItem;
    OpenScriptDlg: TOpenDialog;
    CBDeleteUnsuccessful: TCheckBox;
    SearchActionLabel: TLabel;
    SearchNotifyTimer: TTimer;
    ColumnsMenu: TPopupMenu;
    ColumnNameItem: TMenuItem;
    ColumnCreatedateItem: TMenuItem;
    ColumnModifydateItem: TMenuItem;
    ColumnSizeItem: TMenuItem;
    ColumnMFTrefItem: TMenuItem;
    ColumnDatastreamsItem: TMenuItem;
    ColumnPathItem: TMenuItem;
    ActionViewNameColumn: TAction;
    ActionViewCreatedateColumn: TAction;
    ActionViewModifyDateColumn: TAction;
    ActionViewSizeColumn: TAction;
    ActionViewDataStreamsColumn: TAction;
    ActionViewPathColumn: TAction;
    ActionViewMFTRefColumn: TAction;
    ViewMenu: TMenuItem;
    Columns1: TMenuItem;
    ActionViewNameColumn1: TMenuItem;
    ActionViewCreatedateColumn1: TMenuItem;
    ActionViewModifyDateColumn1: TMenuItem;
    ActionViewSizeColumn1: TMenuItem;
    Goto1: TMenuItem;
    ActionViewDataStreamsColumn1: TMenuItem;
    ActionViewPathColumn1: TMenuItem;
    ActionViewQuickView: TAction;
    Quickview1: TMenuItem;
    RecoveryPauseButton: TButton;
    Panel3: TPanel;
    QuickViewSPanel: TPanel;
    QuickViewS: TVirtualStringTree;
    Panel10: TPanel;
    Label11: TLabel;
    QVSFileNameLabel: TLabel;
    SearchList: TVirtualStringTree;
    Splitter3: TSplitter;
    ToolButton1: TToolButton;
    SaveLogButton: TToolButton;
    AdvancedSearchPanel: TPanel;
    cbxCaseSens: TCheckBox;
    cbxSrchFolds: TCheckBox;
    cbxSrchFiles: TCheckBox;
    cbxDeletedEntries: TCheckBox;
    cbxNonDeletedEntries: TCheckBox;
    cbxModification: TCheckBox;
    Label2: TLabel;
    dtpModifyFrom: TDateTimePicker;
    dtpModifyTo: TDateTimePicker;
    Label3: TLabel;
    cbxCreated: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    dtpCreateFrom: TDateTimePicker;
    dtpCreateTo: TDateTimePicker;
    cbxSizeFrom: TCheckBox;
    cbxSizeTo: TCheckBox;
    SizeToEdit: TEdit;
    SizeFromEdit: TEdit;
    SizeFromRB: TComboBox;
    SizeToRB: TComboBox;
    rbSimpleSearch: TRadioButton;
    rbAdvancedSearch: TRadioButton;
    cbSimpleSearchOnlyDeletedFiles: TCheckBox;
    SaveRecoveryLogDlg: TSaveDialog;
    SearchButton: TButton;
    Help1: TMenuItem;
    miHomePage: TMenuItem;
    N3: TMenuItem;
    miAbout: TMenuItem;
    XPManifest1: TXPManifest;
    ActionFilterDeletedFiles1: TMenuItem;
    VFSMgrUpdateTimer: TTimer;
    ActionFilterDeletedFiles: TAction;
    ActionViewLogging: TAction;
    Viewlog1: TMenuItem;
    procedure VFSManager1MoveEntry(Sender: TObject; TargetEntry, FromEntry,
      ToEntry: PVFSEntry);
    procedure VFSManager1DirAddNewEntry(Sender: TObject; TargetDirEntry,
      AddedEntry: PVFSEntry);
    procedure VFSManager1ChangeNotification(Sender: TObject;
      ChangedEntry: PVFSEntry);
    procedure DirTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure DirTreeGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure DirTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ContentsListGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure ContentsListGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure ContentsListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ContentsListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MainActionListUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure ActionPropertiesExecute(Sender: TObject);
    procedure DirTreeChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure ContentsListDblClick(Sender: TObject);
    procedure ContentsListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ActionSearchExecute(Sender: TObject);
    procedure ContentsListChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure ContentsListChecking(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
    procedure DirTreeChecking(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var NewState: TCheckState; var Allowed: Boolean);
    procedure DirTreeChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure ActionSelectAllExecute(Sender: TObject);
    procedure ActionMarkAllExecute(Sender: TObject);
    procedure ActionMarkSelectedExecute(Sender: TObject);
    procedure ActionUnmarkAllExecute(Sender: TObject);
    procedure ActionUnmarkSelectedExecute(Sender: TObject);
    procedure VFSManager1SearchResult(Sender: TObject;
      FoundEntry: PVFSEntry);
    procedure SearchListInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure ToolButton4Click(Sender: TObject);
    procedure ContentsListHeaderClick(Sender: TVTHeader;
      Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure ActionExecuteScriptExecute(Sender: TObject);
    procedure ContentsListChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure appModInitialization(Sender: TObject);
    procedure PyVFSEntryTypeInitialization(Sender: TObject);
    procedure ActionCancelSearchExecute(Sender: TObject);
    procedure QuickViewGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure RecoveryBrowseFolderButtonClick(Sender: TObject);
    procedure RecoveryStartButtonClick(Sender: TObject);
    procedure RecoverySkipFileButtonClick(Sender: TObject);
    procedure RecoveryStopButtonClick(Sender: TObject);
    procedure cbxModificationClick(Sender: TObject);
    procedure cbxCreatedClick(Sender: TObject);
    procedure RecoveryProtocolGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure applyRecoveryFilter(Sender: TObject);
    procedure RecoveryProtocolPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure ContentsListInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure DirTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure SearchListChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure ActionGoToExecute(Sender: TObject);
    procedure ActionSaveAsExecute(Sender: TObject);
    procedure DirTreeInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure DirTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SearchNotifyTimerTimer(Sender: TObject);
    procedure SearchListHeaderClick(Sender: TVTHeader;
      Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure ActionViewNameColumnExecute(Sender: TObject);
    procedure ActionViewCreatedateColumnExecute(Sender: TObject);
    procedure ActionViewModifyDateColumnExecute(Sender: TObject);
    procedure ActionViewSizeColumnExecute(Sender: TObject);
    procedure ActionViewMFTRefColumnExecute(Sender: TObject);
    procedure ActionViewDataStreamsColumnExecute(Sender: TObject);
    procedure ActionViewPathColumnExecute(Sender: TObject);
    procedure ActionViewQuickViewExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure RecoveryPauseButtonClick(Sender: TObject);
    procedure QuickViewSGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure SearchListChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure cbxSizeFromClick(Sender: TObject);
    procedure cbxSizeToClick(Sender: TObject);
    procedure rbAdvancedSearchClick(Sender: TObject);
    procedure SaveLogButtonClick(Sender: TObject);
    procedure DirTreeGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: WideString);
    procedure miHomePageClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure ActionFilterDeletedFilesExecute(Sender: TObject);
    procedure VFSMgrUpdateTimerTimer(Sender: TObject);
    procedure DirTreeBeforeItemPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var CustomDraw: Boolean);
    procedure DirTreePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure ContentsListPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure ActionViewLoggingExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FPython: TPython;
    FLockSearchColumns: boolean;

    FRecoveryProtocol: TList;
    FRecoveryProtocolVisual: TList;
    FContentsList: TList;
    FVFSMgrMsgCS: TCriticalSection;
    FVFSMrgMsgList: TList;

    FApplicationClosed: boolean;
    FNTFSData: TRecordPool;
    FSelectedNodeTree: TBaseVirtualTree;
    FQVBuffer: array[0..65535] of byte;
    FQVSBuffer: array[0..65535] of byte;
    FLastSelectedFolder: widestring;
    FUIConfig: TUIConfiguration;

    FUndeleteImgList: TUndeleteImgList;

    procedure SetColumnVisible(column: integer; vis: boolean);

    procedure AddRecoveryMessage(MsgType: TRecoveryMsgType; mess: string);
    procedure ClearRecoveryMessages;

    procedure _DoExecutePyScript(context: pointer);

    procedure _PCM_ShowMessage(var Message: TMessage); message PCM_ShowMessage;
    procedure _PCM_ShowScanDlg(var Message: TMessage); message PCM_ShowScanDlg;
    procedure _PCM_InitSearch(var Message: TMessage); message PCM_InitSearch;
    procedure _PCM_DoneSearch(var Message: TMessage); message PCM_DoneSearch;
    procedure _PCM_SetQVRowCount(var Message: TMessage); message PCM_SetQVRowCount;
    procedure _PCM_SetQVCaption(var Message: TMessage); message PCM_SetQVCaption;
    procedure _PCM_SelectFolder(var Message: TMessage); message PCM_SelectFolder;
    procedure _PCM_NotifyRecoveryProgress(var Message: TMessage); message PCM_NotifyRecoveryProgress;
    procedure _PCM_RecoveryPanelInit(var Message: TMessage); message PCM_RecoveryPanelInit;
    procedure _PCM_RecoveryPanelDone(var Message: TMessage); message PCM_RecoveryPanelDone;
    procedure _PCM_EmitRecoveryMessage(var Message: TMessage); message PCM_EmitRecoveryMessage;
    procedure _PCM_QuerySaveFileDlg(var Message: TMessage); message PCM_QuerySaveFileDlg;
    procedure _PCM_ShowProgressDlg(var Message: TMessage); message PCM_ShowProgressDlg;
    procedure _PCM_HideProgressDlg(var Message: TMessage); message PCM_HideProgressDlg;
    procedure _PCM_HideScanDlg(var Message: TMessage); message PCM_HideScanDlg;
    procedure _PCM_NotifyProgressDlg(var Message: TMessage); message PCM_NotifyProgressDlg;
    procedure _PCM_MarkEntry(var Message: TMessage); message PCM_MarkEntry;
    procedure _PCM_UnMarkEntry(var Message: TMessage); message PCM_UnMarkEntry;
    procedure _PCM_ExpandEntry(var Message: TMessage); message PCM_ExpandEntry;
    procedure _PCM_SetSearchCaption(var Message: TMessage); message PCM_SetSearchCaption;
    procedure _PCM_SetScanPercent(var Message: TMessage); message PCM_SetScanPercent;
    procedure _PCM_ShowYesNoDlg(var Message: TMessage); message PCM_ShowYesNoDlg;
    procedure _PCM_AppendLogMsg(var Message: TMessage); message PCM_AppendLogMsg;
    procedure _PCM_SetLastLogMsg(var Message: TMessage); message PCM_SetLastLogMsg;

    procedure process_vfs_message(msg: PVFMMessage);
    procedure _VFM_AddNewEntry(p: PVFMMessage);
    procedure _VFM_MoveEntry(r: PVFMMessage);
    procedure _VFM_ChangeNotification(p: PVFMMessage);
    procedure _VFM_ExpandEntryEx(p: PVFMMessage);


    procedure OnInitPythonModules(Sender: TObject);
    function _PyApp_StartProgressBar(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_NotifyProgressBar(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_FinishProgressBar(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_ShowMessageModal(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_GetRootEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsDeleted(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsContainer(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsDirectory(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsFile(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsChecked(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetName(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetNext(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetPrev(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetParent(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetFirstChild(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetMFTRef(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetDataSize(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetPath(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetCreateDate(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetModifyDate(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetVolumeObject(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsDrive(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsDriveScanned(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsDriveNotScanned(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryIsDriveScanning(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryCheckUserFlag(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntrySetUserFlag(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryGetID(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_HasConsole(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_FileNameMatches(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_GetCWD(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_AddSearchResult(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_GetSearchParams(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_InitSearch(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_DoneSearch(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SetQVRowCount(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_VolumeForEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_GetFocusedFile(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SetQVCaption(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SetQVData(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SelectFolder(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_AddDirectoryEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_AddFileEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_NotifyChangeEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SetupVolumeObject(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_MoveEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_NTFSDate2DateTime(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_GetRecoveryParams(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_NotifyRecoveryProgress(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_RecoveryPanelInit(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_RecoveryPanelDone(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EmitRecoveryMessage(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SaveDlgQuery(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_ShowProgressDlg(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_HideProgressDlg(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_ShowScanDlg(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_HideScanDlg(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_NotifyProgressDlg(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_MarkEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_UnmarkEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryHasMarkedChildren(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_ExpandEntry(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SetSearchCaption(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SetScanPercent(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_EntryHasUnkEntryParent(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_GetSearchResultCount(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_ShowYesNoDlg(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_ExpandEntryEx(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_AppendLogMsg(_self, args: PPyObject): PPyObject;cdecl;
    function _PyApp_SetLastLogMsg(_self, args: PPyObject): PPyObject;cdecl;

    function HasUnkEntryParent(E: PVFSEntry): boolean;
    procedure MarkEntry(E: PVFSEntry);
    procedure UnmarkEntry(E: PVFSEntry);
    function GetSelectedNode: PVirtualNode;
    function DriveNodeForEntry(entry: PVFSEntry): PVFSEntry;
    function GetCWD: PVirtualNode;
    function GetCWDEntry: PVFSEntry;
    //procedure AddContentsEntry(E: PVFSEntry);
    procedure RecursiveMark(E: PVFSEntry; Marked: boolean);
    procedure UprecurseUnmark(E: PVFSEntry);

    function MapVFSEntry(E: PVFSEntry): PPyObject;

    function SelectFolder(var folder: widestring): boolean;

    procedure SynchronizeChecksOn(tree: TBaseVirtualTree);
    function GetSelectedFile: PVFSEntry;
    function HasMarkedChildren(entry: PVFSEntry): boolean;

  public
    { P ublic declarations }
    property SelectedNode: PVirtualNode read GetSelectedNode;
    property SelectedFile: PVFSEntry read GetSelectedFile;
    //property SelectedNodeTree: TBaseVirtualTree read FSelectedNodeTree;
    property CWD: PVirtualNode read GetCWD;
    property CWDEntry: PVFSEntry read GetCWDEntry;

    property Python: TPython read FPython;
    property UIConfig: TUIConfiguration read FUIConfig;
  end;

  TPyVFSEntry = record
    ob_refcnt: Integer;
    ob_type: PPyTypeObject;
    TargetEntry: PVFSEntry;
  end;
  PPyVFSEntry = ^TPyVFSEntry;


  function PyVFSEntry_Repr(_self: PPyObject): PPyObject; cdecl;
  procedure PyVFSEntry_Dealloc(_self: PPyObject);cdecl;
  function  PyVFSEntry_getattr(_self : PPyObject; key : PChar) : PPyObject; cdecl;
  function PyVFSEntry_Check(_self: PPyObject): boolean;cdecl;

var
  MainForm: TMainForm;

implementation

  uses
    ScanProgressDlgUnit, PropertiesDlgUnit, AcedStrings, ProgressDlgUnit, DateUtils,
  AboutDlgUnit, LoggingFormUnit;

  function  PyVFSEntry_getattr(_self : PPyObject; key : PChar) : PPyObject; cdecl;
  begin
    result := nil;
    with GetPythonEngine do
      PyErr_SetString (PyExc_AttributeError^, PChar(Format('Unknown attribute "%s"',[key])));
  end;

  function PyVFSEntry_Repr(_self: PPyObject): PPyObject; cdecl;
  begin
    with GetPythonEngine do
      result := PyString_FromString(pchar('<VFSEntry object at '+IntToHex(cardinal(_self), 8)+' >'));
  end;

  procedure PyVFSEntry_Dealloc(_self: PPyObject);cdecl;
  begin
    Dispose(_self);
  end;

  function PyVFSEntry_Check(_self: PPyObject): boolean;cdecl;
  begin
    result := _self^.ob_type = MainForm.PyVFSEntryType.TheTypePtr;
  end;

{$R *.dfm}

    function NTFSDate2DateTime(dt: int64): TDateTime;
    var
      X: int64;
    begin
      X := 299*365 + 70;
      X := X * 24 * 3600;
      X := X * 10000000;
      result := ((dt - X) / 1.0e+7) / (3600 * 24) + 1.0/12.0;
    end;


procedure TMainForm.VFSManager1MoveEntry(Sender: TObject; TargetEntry,
  FromEntry, ToEntry: PVFSEntry);
var
  p: PVFMMessage;
begin
  new(p);
  p^.code := VFM_MoveEntry;
  p^.TargetEntry := TargetEntry;
  p^.FromEntry := FromEntry;
  p^.ToEntry := ToEntry;
  FVFSMgrMsgCS.Enter;
  FVFSMrgMsgList.Add(p);
  FVFSMgrMsgCS.Leave;
end;

procedure TMainForm.VFSManager1DirAddNewEntry(Sender: TObject; TargetDirEntry,
  AddedEntry: PVFSEntry);
var
  p: PVFMMessage;
begin
  new(p);
  p^.code := VFM_AddNewEntry;
  p^.TargetDirEntry := TargetDirEntry;
  p^.AddedEntry := AddedEntry;
  FVFSMgrMsgCS.Enter;
  FVFSMrgMsgList.Add(p);
  FVFSMgrMsgCS.Leave;
end;

procedure TMainForm.VFSManager1ChangeNotification(Sender: TObject;
  ChangedEntry: PVFSEntry);
var
  p: PVFMMessage;
begin
  new(p);
  p^.code := VFM_ChangeNotification;
  p^.ChangedEntry := ChangedEntry;
  FVFSMgrMsgCS.Enter;
  FVFSMrgMsgList.Add(p);
  FVFSMgrMsgCS.Leave;
end;

procedure TMainForm.DirTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  p: ^PVFSEntry;
  percent: integer;
begin
  p := Sender.GetNodeData(Node);
  CellText := VFSManager1.EntryName(p^);
  if (p^ <> nil) and VFSIsDriveEntry(p^) then begin
    CellText := GetDisplayName(CellText + '\');
    percent := PNTFSData(p^.UserData)^.ScanPercent;
    if (percent < 100) and (percent >= 0) then
      CellText := CellText + '. Scan: '+IntToStr(PNTFSData(p^.UserData)^.ScanPercent)+'%';
  end;
end;

procedure TMainForm.DirTreeGetNodeDataSize(
  Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := sizeof (pointer);
end;

procedure TMainForm.DirTreeGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  p: ^PVFSEntry;
begin
  p := Sender.GetNodeData(Node);
  if p^ = nil then
    Exit;

  if (Kind = ikOverlay) then
  begin
    if (VFSIsDeletedEntry(p^)) then
        ImageIndex := FUndeleteImgList.DeletedOverlayIdx;
  end;

  if not VFSHasDeletedChildren(p^) and ActionFilterDeletedFiles.Checked then
    Ghosted := True;

  if Kind in [ikNormal, ikSelected] then
  begin
      if VFSIsDirectoryEntry(p^) then
      begin
        if Kind = ikSelected then
            ImageIndex := FUndeleteImgList.FolderIdx(true)
        else
            ImageIndex := FUndeleteImgList.FolderIdx(false);
      end
       else
      if VFSIsDriveEntry(p^) then
        ImageIndex := FUndeleteImgList.VolumeIdx(VFSManager1.EntryName(p^) + '\');
{      else if VFSCheckContainerType(p^, CT_SEARCH_RESULTS) then
        ImageIndex := 13;}
  end;
end;

procedure TMainForm.ContentsListGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := sizeof(pointer);
end;

procedure TMainForm.ContentsListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  p: ^PVFSEntry;
begin
  CellText := '';
  p := Sender.GetNodeData(Node);
  if Column = 0 then begin
    CellText := VFSManager1.EntryName(p^);
    if VFSIsDriveEntry(p^) then
        CellText := GetDisplayName(CellText + '\');
  end;
  case Column of
    1:  if VFSIsFileEntry(p^) or VFSIsDirectoryEntry(p^) then begin
          if p^.CreateDate <> 0 then
            CellText := DateToStr(p^.CreateDate);
        end;
    2:  if VFSIsFileEntry(p^) or VFSIsDirectoryEntry(p^) then begin
          if p^.ModifyDate <> 0 then
            CellText := DateToStr(p^.ModifyDate)
        end;
    3:  if VFSIsFileEntry(p^) then begin
          if p^.DataSize < 1 shl 10 then
            CellText := IntToStr(p^.DataSize) + ' B'
          else if p^.DataSize < 1 shl 20 then
            CellText := IntToStr(p^.DataSize shr 10) + ' KB'
          else if p^.DataSize < 1 shl 30 then
            CellText := IntToStr(p^.DataSize shr 20) + ' MB'
          else
            CellText := IntToStr(p^.DataSize shr 30) + ' GB'

        end else
          CellText := '';
  end;
  if (VFSIsFileEntry(p^) or VFSIsDirectoryEntry(p^)) and (p^.UserData <> nil) and (PNTFSData(p^.UserData)^.mft_ref >= 0) then begin
    case Column of
    4:  CellText := IntToStr(PNTFSData(p^.UserData)^.mft_ref);
    5:  CellText := IntToStr(PNTFSData(p^.UserData)^.DataStreamCount);
    end;
  end;
  if Column = 6 then
    CellText := VFSManager1.PathForEntry(p^);
end;

procedure TMainForm.ContentsListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  p: ^PVFSEntry;
begin
  if Column = 0 then begin
      p := Sender.GetNodeData(Node);

      if (p = nil) or (p^ = nil) then
        Exit;

      if not VFSHasDeletedChildren(p^) and ActionFilterDeletedFiles.Checked then
        Ghosted := True;

      if (Kind = ikOverlay) then
        if (VFSIsDeletedEntry(p^)) then
            ImageIndex := FUndeleteImgList.DeletedOverlayIdx; //DEL_OVERLAY_ID

      if Kind in [ikNormal, ikSelected] then
      begin
          if VFSIsFileEntry(p^) then
            ImageIndex := FUndeleteImgList.FileIdx(VFSManager1.EntryName(p^))
          else if VFSIsDirectoryEntry(p^) then
            ImageIndex := FUndeleteImgList.FolderIdx(false)
          else if VFSIsDriveEntry(p^) then
            ImageIndex := FUndeleteImgList.VolumeIdx(VFSManager1.EntryName(p^) + '\');
      end;
  end;
end;

procedure TMainForm.ContentsListCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  p1, p2: ^PVFSEntry;
  DS1, DS2: int64;
  E: TDateTime;
begin
  p1 := Sender.GetNodeData(Node1);
  p2 := Sender.GetNodeData(Node2);
  result := 0;
  if Column = 0 then begin
    if VFSIsContainerEntry(p1^) and not VFSIsContainerEntry(p2^) then
      Result := -1
    else if not VFSIsContainerEntry(p1^) and VFSIsContainerEntry(p2^) then begin
      Result := 1;
    end else if p1^.ContainerType <> p2^.ContainerType then begin
      if p1^.ContainerType < p2^.ContainerType then
        Result := -1
      else
        Result := 1;
    end else if (p1^.Name <> nil) and (p2^.Name <> nil) then
      result := CompareText(WideStringFromBuffer(p1^.Name, p1^.NameLength), WideStringFromBuffer(p2^.Name, p2^.NameLength));
  end else if Column = 1 then begin
    E := p1^.CreateDate - p2^.CreateDate;
    if E < 0 then
      Result := -1
    else if E > 0 then
      Result := 1;
  end else if Column = 2 then begin
    E := p1^.ModifyDate - p2^.ModifyDate;
    if E < 0 then
      result := -1
    else if E > 0 then
      result := 1;
  end else if Column = 3 then begin
    DS1 := 0;
    DS2 := 0;
    if VFSIsFileEntry(p1^) then
      DS1 := p1^.DataSize;
    if VFSIsFileEntry(p2^) then
      DS2 := p2^.DataSize;
    if DS1 < DS2 then
      result := -1
    else if DS1 > DS2 then
      result := 1;
  end else if Column = 4 then begin
    DS1 := 0;
    DS2 := 0;
    if VFSIsFileEntry(p1^) or VFSIsDirectoryEntry(p1^) then
      DS1 := PNTFSData(p1^.UserData)^.mft_ref;
    if VFSIsFileEntry(p2^) or VFSIsDirectoryEntry(p2^) then
      DS2 := PNTFSData(p2^.UserData)^.mft_ref;
    if DS1 < DS2 then
      result := -1
    else if DS1 > DS2 then
      result := 1;
  end else if Column = 5 then begin
    DS1 := 0;
    DS2 := 0;
    if VFSIsFileEntry(p1^) or VFSIsDirectoryEntry(p1^) then
      DS1 := PNTFSData(p1^.UserData)^.DataStreamCount;
    if VFSIsFileEntry(p2^) or VFSIsDirectoryEntry(p2^) then
      DS2 := PNTFSData(p2^.UserData)^.DataStreamCount;
    if ds1 < ds2 then
      result := -1
    else if DS1 > DS2 then
      result := 1;
  end;
end;

procedure LogAllDrives;
var tmp: array[0..1024] of Char;
    Res: array[0..30] of String;
    p: Char;
    Str: String;
    i, c: Integer;
begin
  GetLogicalDriveStrings(1024, tmp);
  p := tmp[0];
  c := 0;
  i := 0;
  Str := '';

  while p <> #0 do
  begin
    while p <> #0 do
    begin
      Str := Str + p;
      Inc(i);
      p := tmp[i];
    end;
    Res[c] := Str;
    Inc(c);
    Inc(i);
    Str := '';
    p := tmp[i];
  end;

{  LoggingForm.LogRich.Lines.Append('');
  LoggingForm.LogRich.Lines.Append('');}

  // Dump to log
  for i := 0 to c - 1 do
    LoggingForm.LogRich.Lines.Append(format('%s - %d', [Res[i], GetDriveType(PChar(Res[i]))]));

  LoggingForm.LogRich.Lines.Append('');
  LoggingForm.LogRich.Lines.Append('');      
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  PN: PNTFSData;
  Mask: DWord;
  RootVTV: PVirtualNode;
  DriveCount: integer;
  DriveStrings: string;
  DrvMap: dword;
  DrvLetter: Byte;
  DrvPath, LocalDrivesName: String;
  FixedDiskImage: Integer;
  E: PVFSEntry;
  i: Integer;
  p: PVFMMessage;

begin
  FUIConfig := TUIConfiguration.Create;
  FUIConfig.Load;
  FVFSMgrMsgCS := TCriticalSection.Create;
  FVFSMrgMsgList := TList.Create;

  CurrentRecoveryFileLabel.Caption := '';
  CurrentFileRecoveryPercentLabel.Caption := '';
  TotalRecoveryPercentLabel.Caption := '';
  RecoveryTotalFilesLabel.Caption := '';
  RecoveryProcessedLabel.Caption := '';
  RecoveryRemainLabel.Caption := '';
  //RecoveryEstimatedLabel.Caption := '';
  //RecoveryElapsedLabel.Caption := '';
  //RecoveryTimeLeftLabel.Caption := '';
  SearchActionLabel.Caption := '';

  FUndeleteImgList := TUndeleteImgList.Create(ilOverlays);

  DirTree.Images := FUndeleteImgList.ImageList;      // ilOverlays;//
  ContentsList.Images := FUndeleteImgList.ImageList;
  SearchList.Images := FUndeleteImgList.ImageList;

  dtpModifyFrom.Date := Date;
  dtpModifyTo.Date := Date;
  dtpCreateFrom.Date := Date;
  dtpCreateTo.Date := Date;
  FContentsList := TList.Create;
  FRecoveryProtocol := TList.Create;
  FRecoveryProtocolVisual := TList.Create;

  FLastSelectedFolder := '';
  FApplicationClosed := false;
  FPython := TPython.Create(True);
  FPython.OnInitModules := OnInitPythonModules;
  FPython.Resume;

  RootVTV := DirTree.AddChild(nil, VFSManager1.Root);
  FNTFSData := TRecordPool.Create(sizeof(TNTFSData), 2048);
  PN := FNTFSData.XAlloc;
  PN^.mft_ref := -1;
  PN^.Node := RootVTV;
  //PN^.ContentsNode := nil;
  VFSManager1.Root^.UserData := PN;

  DriveCount := GetLogicalDriveStrings(0, nil);
  SetLength(DriveStrings, DriveCount);
  GetLogicalDriveStrings(DriveCount, PChar(DriveStrings));

  DrvMap := GetLogicalDrives;
  Mask := 1;
  DrvLetter := ord('A');

  LocalDrivesName := '';
  FixedDiskImage := -1;

  for i := 1 to 26 do begin
    if DrvMap and Mask = Mask then begin
      DrvPath := Chr(DrvLetter)+':';

      if GetDriveType(PChar(DrvPath)) in  [DRIVE_FIXED, DRIVE_REMOVABLE] then begin
        if FixedDiskImage = -1 then
          FixedDiskImage := GetSysImageId(DrvPath);

        PN := FNTFSData.XAlloc;
        PN^.VolumeObject := nil;
        PN^.Node := nil;
        PN^.ScanPercent := -1;
        //PN^.ContentsNode :=nil;
        E := VFSManager1.AddDrive(DrvPath, char(drvletter), PN);

        LocationCb.Items.AddObject(DrvPath, TObject(E));

        if LocalDrivesName = '' then
          LocalDrivesName := Chr(DrvLetter)+':'
        else
          LocalDrivesName := LocalDrivesName + ', ' + Chr(DrvLetter)+':';
      end;

    end;

    Mask := Mask shl 1;
    Inc(DrvLetter);
  end;

  LocationCb.Items.AddObject('All drives', TObject(1));
  LocationCb.ItemIndex := 0;

  PN := FNTFSData.XAlloc;
  PN^.Node := nil;
  PN^.mft_ref := -1;
//  PN^.ContentsNode := nil;
//  DirTree.Expanded[RootVTV] := True;

  new(p);
  p^.code := VFM_ExpandEntryEx;
  p^.TargetEntry := VFSManager1.Root;
  FVFSMgrMsgCS.Enter;
  FVFSMrgMsgList.Add(p);
  FVFSMgrMsgCS.Leave;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  VFSMgrUpdateTimer.Enabled := False;
  UIConfig.Save;
  FApplicationClosed := true;
  FPython.PushLine('pyue.ue_runtime.on_application_close()');
  FPython.Terminate;

  FPython.PushTerminate;
  FPython.WaitFor;
  CanClose := True;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
    FreeAndNil(FUndeleteImgList);
end;

function TMainForm.GetSelectedNode: PVirtualNode;
begin
  result := nil;
  FSelectedNodeTree := nil;
  if ActiveControl = DirTree then begin
    FSelectedNodeTree := DirTree;
    result := DirTree.FocusedNode;
  end else if ActiveControl = ContentsList then begin
    FSelectedNodeTree := ContentsList;
    result := ContentsList.FocusedNode;
  end else if ActiveControl = SearchList then begin
    FSelectedNodeTree := SearchList;
    Result := SearchList.FocusedNode;
  end;
end;

procedure TMainForm.MainActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
Var
  v, IsContentsActive: boolean;
  H: TVTHeader;
begin
  H := nil;
  if PageControl1.TabIndex = 0 then begin
    H := ContentsList.Header;
    ActionViewPathColumn.Visible := False;
  end else if PageControl1.TabIndex = 1 then begin
    H := SearchList.Header;
    ActionViewPathColumn.Visible := True;
    ActionViewPathColumn.Checked := coVisible in H.Columns[6].Options;
  end;
  if PageControl1.TabIndex in [0, 1] then begin
    ActionViewNameColumn.Visible := True;
    ActionViewCreatedateColumn.Visible := True;
    ActionViewModifyDateColumn.Visible := True;
    ActionViewSizeColumn.Visible := True;
    ActionViewMFTRefColumn.Visible := True;
    ActionViewDataStreamsColumn.Visible := True;
    ActionViewNameColumn.Checked := coVisible in H.Columns[0].Options;
    ActionViewCreatedateColumn.Checked := coVisible in H.Columns[1].Options;
    ActionViewModifyDateColumn.Checked := coVisible in H.Columns[2].Options;
    ActionViewSizeColumn.Checked := coVisible in H.Columns[3].Options;
    ActionViewMFTRefColumn.Checked := coVisible in H.Columns[4].Options;
    ActionViewDataStreamsColumn.Checked := coVisible in H.Columns[5].Options;
    ViewMenu.Visible := True;
  end else begin
    ActionViewNameColumn.Visible := False;
    ActionViewCreatedateColumn.Visible := False;
    ActionViewModifyDateColumn.Visible := False;
    ActionViewSizeColumn.Visible := False;
    ActionViewMFTRefColumn.Visible := False;
    ActionViewDataStreamsColumn.Visible := False;
    ViewMenu.Visible := False;
  end;


  v := (ActiveControl = SearchList) and (SearchList.FocusedNode <> nil);
  ActionGoto.Enabled := v;
  PopupGotoMenu.Visible := v;
  ActionExecuteScript.Enabled := True;
  ActionSaveAs.Enabled := SelectedFile <> nil;

  ActionProperties.Enabled := SelectedNode <> nil;

  IsContentsActive := (ActiveControl = ContentsList) or (ActiveControl = SearchList);
  ActionMarkAll.Enabled := IsContentsActive;
  ActionMarkSelected.Enabled := IsContentsActive;
  ActionSelectAll.Enabled := IsContentsActive;
  ActionUnMarkAll.Enabled := IsContentsActive;
  ActionUnMarkSelected.Enabled := IsContentsActive;
  ActionSearch.Enabled := True;
  ActionCancelSearch.Enabled := true;
  ActionUpFolder.Enabled := (CWD <> nil) and (CWD <> DirTree.RootNode);

  Handled := True;
end;

procedure TMainForm.ActionPropertiesExecute(Sender: TObject);
var
  CurrentSelectedEntry: ^PVFSEntry;
  PN: PNTFSData;
  drive_entry: PVFSEntry;
begin
  if SelectedNode <> nil then begin
    CurrentSelectedEntry := ContentsList.GetNodeData(SelectedNode);
    if VFSIsDirectoryEntry(CurrentSelectedEntry^) or VFSIsFileEntry(CurrentSelectedEntry^) then begin
      drive_entry := DriveNodeForEntry(CurrentSelectedEntry^);
      if (drive_entry <> nil) and (drive_entry^.UserData <> nil) then begin
        PN := drive_entry^.UserData;
        PropertiesDlg.PrepareFor(FPython, PN^.VolumeObject, PNTFSData(CurrentSelectedEntry^.UserData)^.mft_ref);
        PropertiesDlg.ShowModal;
      end else
        raise Exception.Create('Unknown internal error 803');
    end else if VFSIsDriveEntry(CurrentSelectedEntry^) then begin
    end;
  end;
end;

function TMainForm.DriveNodeForEntry(entry: PVFSEntry): PVFSEntry;
var
  p: PVFSEntry;
begin
  result := nil;
  p := entry;
  while (p <> nil) and (p^.Parent <> VFSManager1.Root) do
    p := p^.Parent;
  if VFSIsDriveEntry(p) then
    result := p;
end;

procedure TMainForm.DirTreeChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  p: ^PVFSEntry;
  t: PVFSEntry;
  N: PVirtualNode;
begin
  ContentsList.RootNodeCount := 0;
  FContentsList.Clear;
  p := DirTree.GetNodeData(Node);
  if (p <> nil) and VFSIsContainerEntry(p^) then begin
    if (p <> nil) and VFSIsDriveEntry(p^) and not VFSCheckUserFlag(p^, 0) then begin
      LoggingForm.LogRich.Lines.Append('Scan requested. ');
      LoggingForm.LogRich.Lines.Append('');
      FPython.PushLine('pyue.ue_runtime.scan_drive()');
      VFSSetUserFlag(p^, 0, True);
    end;
      t := p^.FirstChild;
      while t <> nil do begin
        FContentsList.Add(t);
        t := t^.Next;
      end;
  end;
  ContentsList.RootNodeCount := FContentsList.Count;
end;

procedure TMainForm.ContentsListDblClick(Sender: TObject);
var
  p: ^PVFSEntry;
  Node: PVirtualNode;
begin
  if ContentsList.FocusedNode <> nil then begin
    p := ContentsList.GetNodeData(ContentsList.FocusedNode);
    if (p <> nil) and VFSIsContainerEntry(p^) then begin
      Node := PNTFSData(p^.UserData)^.Node;
      DirTree.Expanded[Node] := true;
      DirTree.Selected[Node] := true;
      DirTree.FocusedNode := Node;
    end;
  end;
end;

procedure TMainForm.ContentsListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = $d then
    ContentsListDblClick(Sender);
end;

procedure TMainForm.ActionSearchExecute(Sender: TObject);
var
  X: int64;
begin
  try
    if cbxSizeFrom.Checked then
      StrToInt64(SizeFromEdit.Text);
    if cbxSizeTo.Checked then
      StrToInt64(SizeToEdit.Text);
  except
    ShowMessage('Invalid size limit value. Search not started.');
    exit;
  end;
  VFSManager1.ClearSearchResults;
  PageControl1.ActivePageIndex := 1;
  VFSManager1.ClearSearchResults;
  SearchList.RootNodeCount := 0;
  SearchNotifyTimer.Enabled := True;
  FPython.PushLine('pyue.ue_runtime.search_files()');
end;

function TMainForm.GetCWD: PVirtualNode;
begin
  result := DirTree.FocusedNode;
end;


function TMainForm.GetCWDEntry: PVFSEntry;
var
  vc: PVirtualNode;
  R: ^PVFSEntry;
begin
  result := nil;
  vc := CWD;
  if vc <> nil then begin
    R := DirTree.GetNodeData(vc);
    result := R^;
  end;
end;

procedure TMainForm.ContentsListChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  E: ^PVFSEntry;
begin
  E := Sender.GetNodeData(Node);
  if E^ <> nil then begin
    RecursiveMark(E^, not VFSCheckUserFlag(E^, 1));
    if VFSCheckUserFlag(E^, 1) then
      Node.CheckState := csCheckedNormal
    else begin
      Node.CheckState := csUncheckedNormal;
      UprecurseUnmark(E^);
    end;
    SynchronizeChecksOn(SearchList);
    
  end;
end;

procedure TMainForm.ContentsListChecking(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
var
  E: ^PVFSEntry;
begin
  E := Sender.GetNodeData(Node);
  Allowed := True;
  if E^ <> nil then begin
    if VFSCheckUserFlag(E^, 1) then
      NewState := csUncheckedNormal
    else
      NewState := csCheckedNormal;
  end;
end;

procedure TMainForm.DirTreeChecking(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
var
  E: ^PVFSEntry;
begin
  E := DirTree.GetNodeData(Node);
  Allowed := True;
  if E^ <> nil then begin
    if VFSCheckUserFlag(E^, 1) then
      NewState := csUncheckedNormal
    else
      NewState := csCheckedNormal;
  end;
end;

procedure TMainForm.DirTreeChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  E: ^PVFSEntry;
begin
  E := DirTree.GetNodeData(Node);
  if E^ <> nil then begin
    if not VFSCheckUserFlag(E^, 1) then
      RecursiveMark(E^, True)
    else begin
      RecursiveMark(E^, False);
      UprecurseUnmark(E^);
    end;
  end;
  SynchronizeChecksOn(ContentsList);
  ContentsList.Repaint;
  SynchronizeChecksOn(SearchList);
end;

procedure TMainForm.MarkEntry(E: PVFSEntry);
var
  PN: PNTFSData;
begin
  VFSSetUserFlag(E, 1, True);
  PN := PNTFSData(E^.UserData);
  if PN^.Node <> nil then begin
    PN^.Node^.CheckState := csCheckedNormal;
    DirTree.RepaintNode( PN^.Node );
  end;
end;

procedure TMainForm.UnmarkEntry(E: PVFSEntry);
var
  PN: PNTFSData;
begin
  VFSSetUserFlag(E, 1, False);
  PN := PNTFSData(E^.UserData);
  if PN^.Node <> nil then begin
    PN^.Node^.CheckState := csUncheckedNormal;
    DirTree.RepaintNode( PN^.Node );
  end;
end;

procedure TMainForm.RecursiveMark(E: PVFSEntry; Marked: boolean);
var
  PR: procedure (E: PVFSEntry) of object;
  is_forced_mark: boolean;

  procedure DoRecurseChildren(X: PVFSEntry);
  begin
    if (ActionFilterDeletedFiles.Checked and VFSHasDeletedChildren(X)) or (not ActionFilterDeletedFiles.Checked) or is_forced_mark then begin
      X := X^.FirstChild;
      while X <> nil do begin
        if (ActionFilterDeletedFiles.Checked and VFSHasDeletedChildren(X)) or (not ActionFilterDeletedFiles.Checked) or is_forced_mark then
          PR(X);
        if VFSIsContainerEntry(X) then
          DoRecurseChildren(X);
        X := X^.Next;
      end;
    end;
  end;

  procedure DoRecurseParents(X: PVFSEntry);
  begin
    X := X^.Parent;
    if (X <> nil) then begin
      PR(X);
      DoRecurseParents(X);
    end;
  end;

begin
  is_forced_mark := (ActionFilterDeletedFiles.Checked and not VFSHasDeletedChildren(E)) or not Marked;
  if Marked then
    PR := MarkEntry
  else
    PR := UnmarkEntry;
  PR(E);
  if VFSIsContainerEntry(E) then
    DoRecurseChildren(E);
  if Marked then
    DoRecurseParents(E);
end;

procedure TMainForm.ActionSelectAllExecute(Sender: TObject);
begin
  (ActiveControl as TVirtualStringTree).SelectAll(False);
end;

procedure TMainForm.ActionMarkAllExecute(Sender: TObject);
var
  N: PVirtualNode;
  E: ^PVFSEntry;
  S: TVirtualStringTree;
begin
  S := (ActiveControl as TVirtualStringTree);
  N := S.TopNode;
  while N <> nil do begin
    E := S.GetNodeData(N);
    RecursiveMark(E^, True);
    N^.CheckState := csCheckedNormal;
    N := S.GetNext(N);
  end;
  S.Repaint;
  if S = ContentsList then
    SynchronizeChecksOn(SearchList)
  else
    SynchronizeChecksOn(ContentsList);
end;

procedure TMainForm.ActionMarkSelectedExecute(Sender: TObject);
var
  N: PVirtualNode;
  E: ^PVFSEntry;
  S: TVirtualStringTree;
begin
  S := (ActiveControl as TVirtualStringTree);
  N := S.TopNode;
  while N <> nil do begin
    if S.Selected[N] then begin
      E := S.GetNodeData(N);
      RecursiveMark(E^, True);
      N^.CheckState := csCheckedNormal;
    end;
    N := S.GetNext(N);
  end;
  if S = ContentsList then
    SynchronizeChecksOn(SearchList)
  else begin
    SynchronizeChecksOn(ContentsList);
    SynchronizeChecksOn(SearchList);
  end;
  S.Repaint;
end;

procedure TMainForm.ActionUnmarkAllExecute(Sender: TObject);
var
  N: PVirtualNode;
  E: ^PVFSEntry;
  S: TVirtualStringTree;
begin
  S := (ActiveControl as TVirtualStringTree);
  N := S.TopNode;
  while N <> nil do begin
    E := S.GetNodeData(N);
    RecursiveMark(E^, False);
    N^.CheckState := csUncheckedNormal;
    N := S.GetNext(N);
  end;
  S.Repaint;
  if S = ContentsList then
    SynchronizeChecksOn(SearchList)
  else
    SynchronizeChecksOn(ContentsList);
end;

procedure TMainForm.ActionUnmarkSelectedExecute(Sender: TObject);
var
  N: PVirtualNode;
  E: ^PVFSEntry;
  S: TVirtualStringTree;
begin
  S := (ActiveControl as TVirtualStringTree);
  N := S.TopNode;
  while N <> nil do begin
    if S.Selected[N] then begin
      E := S.GetNodeData(N);
      RecursiveMark(E^, False);
      N^.CheckState := csUncheckedNormal;
    end;
    N := S.GetNext(N);
  end;
  if S = ContentsList then
    SynchronizeChecksOn(SearchList)
  else begin
    SynchronizeChecksOn(ContentsList);
    SynchronizeChecksOn(SearchList);
  end;
  S.Repaint;
end;

procedure TMainForm.VFSManager1SearchResult(Sender: TObject;
  FoundEntry: PVFSEntry);
begin
  SendMessage(Handle, VFM_AddSearchResult, 0, cardinal(FoundEntry));
  Application.ProcessMessages;
end;

{ TApplicationTask }


procedure TMainForm.SearchListInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  p: ^PVFSEntry;
begin
  p := SearchList.GetNodeData(Node);
  p^ := VFSManager1.SearchResults[Node^.Index];
  Node^.CheckType := ctCheckBox;
  if VFSCheckUserFlag(p^, 1) then
    Node^.CheckState := csCheckedNormal
  else
    Node^.CheckState := csUncheckedNormal;
end;

procedure TMainForm.ToolButton4Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 1;
end;

procedure TMainForm.ContentsListHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button = mbLeft then begin
    if Column < 6 then begin
      if Column = Sender.SortColumn then begin
        if Sender.SortDirection = sdAscending then
          Sender.SortDirection := sdDescending
        else
          Sender.SortDirection := sdAscending
      end else
        Sender.SortColumn := Column;
    end;
  end;
end;

procedure TMainForm.ActionExecuteScriptExecute(Sender: TObject);
var
  p: pchar;
begin
  if OpenScriptDlg.Execute then begin
    p := AllocStr(OpenScriptDlg.FileName);
    FPython.PushMethod(_DoExecutePyScript, p);
  end;
end;

procedure TMainForm.ContentsListChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  p: ^PVFSEntry;

begin
  p := Sender.GetNodeData(Node);
  QuickView.Clear;
  FillChar(FQVBuffer, sizeof(FQVBuffer), 0);
  if (p <> nil) and (SelectedFile <> nil) then
    FPython.PushLine('pyue.ue_runtime.update_quickview()');
end;

procedure TMainForm.OnInitPythonModules(Sender: TObject);
begin
  appMod.Engine := FPython.PythonEngine;
  PyVFSEntryType.Engine := FPython.PythonEngine;
  FPython.PythonEngine.InitScript.Add('import pyue.ue_runtime');
  FPython.PythonEngine.InitScript.Add('import pyue.reports');
  FPython.PythonEngine.InitScript.Add('import thread');
  FPython.PythonEngine.InitScript.Add('import app');
end;

procedure TMainForm.appModInitialization(Sender: TObject);
begin
  with Sender as TPythonModule do begin
    AddDelphiMethod('StartProgressBar', _PyApp_StartProgressBar, '');
    AddDelphiMethod('NotifyProgressBar', _PyApp_NotifyProgressBar, '');
    AddDelphiMethod('FinishProgressBar', _PyApp_FinishProgressBar, '');
    AddDelphiMethod('ShowMessageModal', _PyApp_ShowMessageModal, '');
    AddDelphiMethod('GetRootEntry', _PyApp_GetRootEntry, '');
    AddDelphiMethod('EntryIsDeleted', _PyApp_EntryIsDeleted, '');
    AddDelphiMethod('EntryIsContainer', _PyApp_EntryIsContainer, '');
    AddDelphiMethod('EntryIsDirectory', _PyApp_EntryIsDirectory, '');
    AddDelphiMethod('EntryIsDrive', _PyApp_EntryIsDrive, '');
    AddDelphiMethod('EntryIsFile', _PyApp_EntryIsFile, '');
    AddDelphiMethod('EntryIsChecked', _PyApp_EntryIsChecked, '');
    AddDelphiMethod('EntryGetName', _PyApp_EntryGetName, '');
    AddDelphiMethod('EntryGetNext', _PyApp_EntryGetNext, '');
    AddDelphiMethod('EntryGetPrev', _PyApp_EntryGetPrev, '');
    AddDelphiMethod('EntryGetParent', _PyApp_EntryGetParent, '');
    AddDelphiMethod('EntryGetFirstChild', _PyApp_EntryGetFirstChild, '');
    AddDelphiMethod('EntryGetMFTRef', _PyApp_EntryGetMFTRef, '');
    AddDelphiMethod('EntryGetCreateDate', _PyApp_EntryGetCreateDate, '');
    AddDelphiMethod('EntryGetModifyDate', _PyApp_EntryGetModifyDate, '');
    AddDelphiMethod('EntryGetDataSize', _PyApp_EntryGetDataSize, '');
    AddDelphiMethod('EntryGetVolumeObject', _PyApp_EntryGetVolumeObject, '');
    AddDelphiMethod('VolumeForEntry', _PyApp_VolumeForEntry, '');

    AddDelphiMethod('FileNameMatches', _PyApp_FileNameMatches, '');
    AddDelphiMethod('GetCWD', _PyApp_GetCWD, '');
    AddDelphiMethod('AddSearchResult', _PyApp_AddSearchResult, '');
    AddDelphiMethod('GetSearchParams', _PyApp_GetSearchParams, '');
    AddDelphiMethod('InitSearch', _PyApp_InitSearch, '');
    AddDelphiMethod('DoneSearch', _PyApp_DoneSearch, '');
    AddDelphiMethod('SetQVRowCount', _PyApp_SetQVRowCount, '');
    AddDelphiMethod('SetQVCaption', _PyApp_SetQVCaption, '');
    AddDelphiMethod('GetFocusedFile',_PyApp_GetFocusedFile, '');
    AddDelphiMethod('SetQVData', _PyApp_SetQVData, '');
    AddDelphiMethod('SelectFolder', _PyApp_SelectFolder, '');
    AddDelphiMethod('AddDirectoryEntry', _PyApp_AddDirectoryEntry, '');
    AddDelphiMethod('AddFileEntry', _PyApp_AddFileEntry, '');
    AddDelphiMethod('NotifyChangeEntry', _PyApp_NotifyChangeEntry, '');
    AddDelphiMethod('SetupVolumeObject', _PyApp_SetupVolumeObject, '');
    AddDelphiMethod('MoveEntry', _PyApp_MoveEntry, '');
    AddDelphiMethod('NTFSDate2DateTime', _PyApp_NTFSDate2DateTime, '');
    AddDelphiMethod('GetRecoveryParams', _PyApp_GetRecoveryParams, '');
    AddDelphiMethod('NotifyRecoveryProgress', _PyApp_NotifyRecoveryProgress, '');
    AddDelphiMethod('RecoveryPanelInit', _PyApp_RecoveryPanelInit, '');
    AddDelphiMethod('RecoveryPanelDone', _PyApp_RecoveryPanelDone, '');
    AddDelphiMethod('EmitRecoveryMessage', _PyApp_EmitRecoveryMessage, '');
    AddDelphiMethod('SaveDlgQuery', _PyApp_SaveDlgQuery, '');
    AddDelphiMethod('ShowProgressDlg', _PyApp_ShowProgressDlg, '');
    AddDelphiMethod('HideProgressDlg', _PyApp_HideProgressDlg, '');
    AddDelphiMethod('NotifyProgressDlg', _PyApp_NotifyProgressDlg, '');
    AddDelphiMethod('EntryGetPath', _PyApp_EntryGetPath, '');
    AddDelphiMethod('MarkEntry', _PyApp_MarkEntry, '');
    AddDelphiMethod('UnmarkEntry', _PyApp_UnMarkEntry, '');
    AddDelphiMethod('EntryHasMarkedChildren', _PyApp_EntryHasMarkedChildren, '');
    AddDelphiMethod('ExpandEntry', _PyApp_ExpandEntry, '');
    AddDelphiMethod('SetSearchCaption', _PyApp_SetSearchCaption, '');
    AddDelphiMethod('SetScanPercent', _PyApp_SetScanPercent, '');
    AddDelphiMethod('EntryIsDriveScanned', _PyApp_EntryIsDriveScanned, '');
    AddDelphiMethod('EntryIsDriveScanning', _PyApp_EntryIsDriveScanning, '');
    AddDelphiMethod('EntryHasUnkEntryParent', _PyApp_EntryHasUnkEntryParent, '');
    AddDelphiMethod('EntryIsDriveNotScanned', _PyApp_EntryIsDriveNotScanned, '');
    AddDelphiMethod('GetSearchResultCount', _PyApp_GetSearchResultCount, '');
    AddDelphiMethod('EntrySetUserFlag', _PyApp_EntrySetUserFlag, '');
    AddDelphiMethod('EntryCheckUserFlag', _PyApp_EntryCheckUserFlag, '');
    AddDelphiMethod('ShowScanDlg', _PyApp_ShowScanDlg, '');
    AddDelphiMethod('HideScanDlg', _PyApp_HideScanDlg, '');
    AddDelphiMethod('ShowYesNoDlg', _PyApp_ShowYesNoDlg, '');
    AddDelphiMethod('HasConsole', _PyApp_HasConsole, '');
    AddDelphiMethod('ExpandEntryEx', _PyApp_ExpandEntryEx, '');
    AddDelphiMethod('EntryGetID', _PyApp_EntryGetID, '');
    AddDelphiMethod('AppendLogMsg', _PyApp_AppendLogMsg, '');
    AddDelphiMethod('SetLastLogMsg', _PyApp_SetLastLogMsg, '');
  end;
end;

function TMainForm._PyApp_FinishProgressBar(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, '', []) <> 0 then begin
      SendMessage(Handle, PCM_FinishProgressBar, 0, 0);
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TMainForm._PyApp_NotifyProgressBar(_self,
  args: PPyObject): PPyObject;
var
  perc: double;
begin
  result := nil;
  with GetPythonEngine do begin
    if PyArg_ParseTuple(args, 'd', [@perc]) <> 0 then begin
      PostMessage(Handle, PCM_NotifyProgressBar, 0, round(perc));
      result := Py_None;
      Py_INCREF(Py_None);
    end;
  end;
end;

function TMainForm._PyApp_StartProgressBar(_self,
  args: PPyObject): PPyObject;
var
  s: pchar;
  W: PwideChar;
  ss: string;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@W]) <> 0 then begin
        ss := W;
        s := pchar(ss);
        SendMessage(Handle, PCM_StartProgressBar, 0, cardinal(AllocStr(s)));
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

function TMainForm._PyApp_ShowMessageModal(_self,
  args: PPyObject): PPyObject;
var
  s: pchar;
  W: PWideChar;
  ss: string;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@W]) <> 0 then begin
        ss := W;
        s := pchar(ss);
        SendMessage(Handle, PCM_ShowMessage, 0, cardinal(AllocStr(s)));
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm.PyVFSEntryTypeInitialization(Sender: TObject);
begin
  with Sender as TPythonType do begin
    with TheType do begin
      tp_basicsize := sizeof(TPyVFSEntry);
      tp_dealloc   := PyVFSEntry_Dealloc;
      tp_getattr := PyVFSEntry_getattr;
      tp_repr := PyVFSEntry_Repr;
      tp_str := PyVFSEntry_Repr;
    end;
  end;
end;

function TMainForm.MapVFSEntry(E: PVFSEntry): PPyObject;
var
  p: PPyVFSEntry;
begin
  if E <> nil then begin
    new(p);
    p^.ob_refcnt := 1;
    p^.ob_type := PyVFSEntryType.TheTypePtr;
    p^.TargetEntry := E;
    result := PPyObject(p);
  end else with GetPythonEngine do begin
    result := Py_None;
    Py_INCREF(Py_None);
  end;
end;

function TMainForm._PyApp_GetRootEntry(_self, args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then
        result := MapVFSEntry(VFSManager1.Root);
    end;
  end;
end;

function TMainForm._PyApp_EntryGetCreateDate(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := PyFloat_FromDouble(PE^.TargetEntry^.CreateDate);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetFirstChild(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsContainerEntry(PE^.TargetEntry) then
            result := MapVFSEntry(PE^.TargetEntry^.FirstChild)
          else
            PyErr_SetString(PyExc_TypeError^, 'Non-container entry cannot have children nodes');
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetMFTRef(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsFileEntry(PE^.TargetEntry) or VFSIsDirectoryEntry(PE^.TargetEntry) then
            result := PyLong_FromLongLong(PNTFSData(Pe^.TargetEntry^.UserData)^.mft_ref)
          else
            PyErr_SetString(PyExc_TypeError^, 'Non-file-system objects cannot have MFTref');
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetModifyDate(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := PyFloat_FromDouble(PE^.TargetEntry^.ModifyDate);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetName(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := PyUnicode_FromWideString(VFSManager1.EntryName(PE^.TargetEntry));
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetNext(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := MapVFSEntry(PE^.TargetEntry^.Next);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetParent(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := MapVFSEntry(PE^.TargetEntry^.Parent);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetPrev(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := MapVFSEntry(PE^.TargetEntry^.Prev);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetVolumeObject(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsDriveEntry(PE^.TargetEntry) then begin
            if PNTFSData(PE^.TargetEntry^.UserData)^.VolumeObject <> nil then
              result := PNTFSData(PE^.TargetEntry^.UserData)^.VolumeObject
            else
              result := Py_None;
            Py_INCREF(result);
          end else
            PyErr_SetString(PyExc_TypeError^, 'Non-drive entries has no volume objects');
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryIsChecked(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSCheckUserFlag(PE^.TargetEntry, 1) then
            result := PyInt_FromLong(1)
          else
            result := PyInt_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryIsContainer(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsContainerEntry(PE^.TargetEntry) then
            result := PyInt_FromLong(1)
          else
            result := PyInt_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryIsDeleted(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsDeletedEntry(PE^.TargetEntry) then
            result := PyInt_FromLong(1)
          else
            result := PyInt_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryIsDirectory(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsDirectoryEntry(PE^.TargetEntry) then
            result := PyInt_FromLong(1)
          else
            result := PyInt_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryIsFile(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsFileEntry(PE^.TargetEntry) then
            result := PyInt_FromLong(1)
          else
            result := PyInt_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_FileNameMatches(_self,
  args: PPyObject): PPyObject;
var
  S, M: PWideChar;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'uu', [@S, @M]) <> 0 then begin
        if G_ValidateWildStr(S, M) then
          result := PyInt_FromLong(1)
        else
          result := PyInt_FromLong(0);
      end;
    end;
  end;
end;

function TMainForm._PyApp_GetCWD(_self, args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then
        result := MapVFSEntry(CWDEntry);
    end;
  end;
end;

procedure TMainForm._PCM_ShowMessage(var Message: TMessage);
begin
  ShowMessage(pchar(Message.LParam));
  FreeStr(pchar(Message.LParam));
end;

procedure TMainForm._VFM_AddNewEntry(p: PVFMMessage);
var
  pd, od: PNTFSData;
  par: PVFSEntry;
begin
  if (p^.TargetDirEntry <> nil) and VFSIsContainerEntry(p^.AddedEntry) then begin
    pd := p^.TargetDirEntry^.UserData;
    od := p^.AddedEntry^.UserData;
    od^.Node := DirTree.AddChild(pd^.Node, p^.AddedEntry);
    od^.Node^.CheckType := ctCheckBox;
  end;
  if (p^.TargetDirEntry <> nil) and (p^.TargetDirEntry = CWDEntry) then begin
    FContentsList.Add(p^.AddedEntry);
  end;
  dispose(p);
end;

procedure TMainForm._VFM_ChangeNotification(p: PVFMMessage);
var
  pd: PNTFSData;
begin
  pd := p^.ChangedEntry^.UserData;
  {if DirTree.IsVisible[pd^.Node] then
    DirTree.RepaintNode(pd^.Node);}
  if (p^.ChangedEntry^.Parent = CWDEntry) and (CWDEntry <> nil) then begin
    ContentsList.RootNodeCount := FContentsList.Count;
    ContentsList.ReinitNode(PNTFSData(p^.ChangedEntry^.UserData)^.ContentsNode, False);
  end;
  dispose(p);
end;

procedure TMainForm._VFM_MoveEntry(r: PVFMMessage);
var
  p, np: PNTFSData;
  di: integer;
  par: PVFSEntry;
begin
  p := r^.TargetEntry^.UserData;
  np := r^.ToEntry^.UserData;
  DirTree.MoveTo(p^.Node, np^.Node, amAddChildFirst, False);
  if CWDEntry = r^.ToEntry then begin
    FContentsList.Add(r^.TargetEntry);
  end else if (CWDEntry = r^.FromEntry) and (r^.FromEntry <> nil) then begin
    p := r^.TargetEntry^.UserData;
    if p <> nil then begin
      di := FContentsList.IndexOf(r^.TargetEntry);
      if di >= 0 then begin
        ContentsList.DeleteNode(PNTFSData(r^.TargetEntry^.UserData)^.ContentsNode, True);
        FContentsList.Delete(di);
      end;
    end;
  end;
  {if VFSHasDeletedChildren( r^.TargetEntry ) then begin

  end;}
  dispose(r);
end;

function TMainForm._PyApp_AddSearchResult(_self,
  args: PPyObject): PPyObject;
var
  T: PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@T]) <> 0 then begin
        if PyVFSEntry_Check(T) then begin
          VFSManager1.AddSearchResult(PPyVFSEntry(T)^.TargetEntry);
          result := Py_None;
          Py_INCREF(Py_None);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_GetSearchParams(_self,
  args: PPyObject): PPyObject;
  function Bool2Py(b: boolean): PPyObject;
  begin
    if b then
      result := GetPythonEngine.PyBool_FromLong(1)
    else
      result := GetPythonEngine.PyBool_FromLong(0);
  end;
var
  X: PVFSEntry;
  S: string;
  T: string;
begin
 result := nil;
 if not FApplicationClosed then begin
   with GetPythonEngine do begin
     if PyArg_ParseTuple(args, '', []) <> 0 then begin
       result := PyDict_New();
       PyDict_SetItemString(result, 'masks', PyString_FromString(pchar(SearchMaskCombo.Text)));
       X := PVFSEntry(LocationCb.Items.Objects[LocationCb.ItemIndex]);
       if integer(X) = 1 then
         PyDict_SetItemString(result, 'look_in', PyInt_FromLong(1))
       else
         PyDict_SetItemString(result, 'look_in', MapVFSEntry(X));
       if rbAdvancedSearch.Checked then begin
         PyDict_SetItemString(result, 'case_sensitive', Bool2Py(cbxCaseSens.Checked));
         PyDict_SetItemString(result, 'search_folders', Bool2Py(cbxSrchFolds.Checked));
         PyDict_SetItemString(result, 'search_files', Bool2Py(cbxSrchFiles.Checked));
         PyDict_SetItemString(result, 'deleted_entries', Bool2Py(cbxDeletedEntries.Checked));
         PyDict_SetItemString(result, 'non_deleted_entries', Bool2Py(cbxNonDeletedEntries.Checked));
         PyDict_SetItemString(result, 'use_modify_filter', Bool2Py(cbxModification.Checked));
         PyDict_SetItemString(result, 'use_create_filter', Bool2Py(cbxCreated.Checked));
         if cbxModification.Checked then begin
           PyDict_SetItemString(result, 'modify_from', PyFloat_FromDouble(DateOf(dtpModifyFrom.Date)));
           PyDict_SetItemString(result, 'modify_to', PyFloat_FromDouble(DateOf(dtpModifyTo.Date)));
         end;
         if cbxCreated.Checked then begin
           PyDict_SetItemString(result, 'created_from', PyFloat_FromDouble(DateOf(dtpCreateFrom.Date)));
           PyDict_SetItemString(result, 'created_to', PyFloat_FromDouble(DateOf(dtpCreateTo.Date)));
         end;
         if cbxSizeFrom.Checked then begin
           S := SizeFromEdit.Text + ' ' + SizeFromRB.Text;
           PyDict_SetItemString(result, 'size_from', PyString_FromString(pchar(S)));
         end;
         if cbxSizeTo.Checked then begin
           T := SizeToEdit.Text + ' ' + SizeToRB.Text;
           PyDict_SetItemString(result, 'size_to', PyString_FromString(pchar(T)));
         end;
       end else begin
         PyDict_SetItemString(result, 'case_sensitive', Bool2Py(False));
         PyDict_SetItemString(result, 'search_folders', Bool2Py(True));
         PyDict_SetItemString(result, 'search_files', Bool2Py(True));
         PyDict_SetItemString(result, 'deleted_entries', Bool2Py(True));
         PyDict_SetItemString(result, 'non_deleted_entries', Bool2Py(not cbSimpleSearchOnlyDeletedFiles.Checked));
         PyDict_SetItemString(result, 'use_modify_filter', Bool2Py(False));
         PyDict_SetItemString(result, 'use_create_filter', Bool2Py(False));
       end;
     end;
   end;
 end;
end;

function TMainForm._PyApp_DoneSearch(_self, args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        SendMessage(Handle, PCM_DoneSearch, 0, 0);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

function TMainForm._PyApp_InitSearch(_self, args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        SendMessage(Handle, PCM_InitSearch, 0, 0);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm._PCM_DoneSearch(var Message: TMessage);
begin
  SearchButton.Action := ActionSearch;
  SearchNotifyTimer.Enabled := false;
  SearchList.TreeOptions.AutoOptions := SearchList.TreeOptions.AutoOptions + [toAutoScroll];
  SearchList.RootNodeCount := VFSManager1.SearchResultCount;
  SearchList.Header.SortColumn := 0;
  SearchActionLabel.Caption := '';
  //SearchList.Header.Options := SearchList.Header.Options + [hoVisible];
  SearchList.Header.SortColumn := -1;
  FLockSearchColumns := False;
  //SearchList.SortTree(0, sdAscending);
end;

procedure TMainForm._PCM_InitSearch(var Message: TMessage);
begin
  SearchList.Header.SortColumn := -1;
  SearchButton.Action := ActionCancelSearch;
  SearchList.TreeOptions.AutoOptions := SearchList.TreeOptions.AutoOptions - [toAutoScroll];
  //SearchList.Header.Options := SearchList.Header.Options - [hoVisible];
  FLockSearchColumns := True;
end;

procedure TMainForm.ActionCancelSearchExecute(Sender: TObject);
begin
  FPython.PushLine('pyue.ue_runtime.cancel_search()');
end;

function TMainForm._PyApp_SetQVRowCount(_self, args: PPyObject): PPyObject;
var
  R: cardinal;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'I', [@R]) <> 0 then begin
        SendMessage(Handle, PCM_SetQVRowCount, 0, R);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm._PCM_SetQVRowCount(var Message: TMessage);
begin
  if PageControl1.TabIndex = 0 then
    QuickView.RootNodeCount := Message.LParam
  else if PageControl1.TabIndex = 1 then
    QuickViewS.RootNodeCount := Message.LParam;
end;

function TMainForm._PyApp_VolumeForEntry(_self, args: PPyObject): PPyObject;
var
  T: PPyObject;
  R: PVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@T]) <> 0 then begin
        if PyVFSEntry_Check(T) then begin
          R := DriveNodeForEntry( PPyVFSEntry(T)^.TargetEntry);
          if (R <> nil) and (VFSIsDriveEntry(R)) and (PNTFSData(R^.UserData)^.VolumeObject <> nil) then begin
            Py_INCREF(PNTFSData(R^.UserData)^.VolumeObject);
            result := PNTFSData(R^.UserData)^.VolumeObject;
          end else begin
            result := Py_None;
            Py_INCREF(Py_None);
          end;
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_GetFocusedFile(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        result := MapVFSEntry(SelectedFile);
      end;
    end;
  end;
end;

function TMainForm._PyApp_SetQVCaption(_self, args: PPyObject): PPyObject;
var
  s: pchar;
  W: PWideChar;
  ss: string;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@W]) <> 0 then begin
        ss := W;
        s := pchar(ss);
        s := AllocStr(s);
        SendMessage(Handle,PCM_SetQVCaption, 0, cardinal(s));
        FreeStr(s);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm._PCM_SetQVCaption(var Message: TMessage);
begin
  if PageControl1.TabIndex = 0 then
    QVFileNameLabel.Caption := pchar(Message.LParam)
  else if PageControl1.TabIndex = 1 then
    QVSFileNameLabel.Caption := pchar(Message.LParam);
end;

function TMainForm._PyApp_SetQVData(_self, args: PPyObject): PPyObject;
var
  Data: PPyObject;
  C: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@Data]) <> 0 then begin
        if PyString_Check(Data) then begin
          C := PyString_Size(Data);
          if C > sizeof(FQVBuffer) then
            C := sizeof(FQVBuffer);
          if PageControl1.TabIndex = 0 then
            move(PyString_AsString(Data)^, FQVBuffer, C)
          else if PageControl1.TabIndex = 1 then
            move(PyString_AsString(Data)^, FQVSBuffer, C);
          result := Py_None;
          Py_INCREF(Py_None);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.QuickViewGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  i, pos: integer;
begin
  case Column of
  0:  CellText := IntToHex(Node^.Index*16, 8);
  1:  begin
        pos := Node^.Index*16;
        if pos + 16 < sizeof(FQVBuffer) then begin
          CellText := '';
          for i := 0 to 15 do
            CellText := CellText + IntToHex(FQVBuffer[pos+i], 2) + ' ';
        end;
      end;
  2:  begin
        pos := Node^.Index*16;
        if pos + 16 < sizeof(FQVBuffer) then begin
          CellText := '';
          for i := 0 to 15 do
            if FQVBuffer[pos+i] >= 32 then
              CellText := CellText + chr(FQVBuffer[pos+i])
            else
              CellText := CellText + '.';
        end;
      end;
  end;
end;

procedure CoTaskMemFree(pv: Pointer); stdcall; external 'ole32.dll' name 'CoTaskMemFree';

function TMainForm.SelectFolder(var folder: widestring): boolean;
var
  IDList: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of char;
  ResultPath: array[0..MAX_PATH] of widechar;
begin
  Result :=False;
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.pidlRoot := nil;
  BrowseInfo.hwndOwner := Handle;
  BrowseInfo.pszDisplayName := @DisplayName;
  BrowseInfo.lpszTitle := 'Select folder';
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  BrowseInfo.lpfn := nil;
  BrowseInfo.lParam := 0;
  IdList := SHBrowseForFolder(BrowseInfo);
  if IdList <> nil then begin
    SHGetPathFromIDListW(IdList, @ResultPath);
    folder := ResultPath;
    FLastSelectedFolder := folder;
    result := True;
    CoTaskMemFree(IDList);
  end;
end;

procedure TMainForm._PCM_SelectFolder(var Message: TMessage);
begin
 //
end;

function TMainForm._PyApp_SelectFolder(_self, args: PPyObject): PPyObject;
var
  Folder: WideString;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if Pyarg_ParseTuple(args, '', []) <> 0 then begin
        if SelectFolder(Folder) then begin
          result := PyUnicode_FromWideString(Folder);
        end else begin
          result := Py_None;
          Py_INCREF(Py_None);
        end;
      end;
    end;
  end;
end;

function TMainForm._PyApp_AddDirectoryEntry(_self,
  args: PPyObject): PPyObject;
var
  OwnData: PNTFSData;
  mft_ref: int64;
  DataStreamCount: cardinal;
  AName: PWideChar;
  _IsDeleted: integer;
  IsDeleted: boolean;
  Parent: PPyObject;
  R: PVFSEntry;
  CD, MD: double;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'OLIuidd', [@Parent, @mft_ref, @DataStreamCount, @AName, @_IsDeleted, @CD, @MD]) <> 0 then begin
        if PyVFSEntry_Check(Parent) then begin
          IsDeleted := False;
          if _IsDeleted <> 0 then
            IsDeleted := True;
          OwnData := FNTFSData.XAlloc;
          OwnData^.mft_ref := mft_ref;
          OwnData^.Node := nil;
          //OwnData^.ContentsNode := nil;
          OwnData^.DataStreamCount := DataStreamCount;
          R := VFSManager1.AddDirectory(AName, IsDeleted, CD, MD, PPyVFSEntry(Parent)^.TargetEntry, OwnData);
          result := MapVFSEntry(R);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_AddFileEntry(_self, args: PPyObject): PPyObject;
var
  OwnData: PNTFSData;
  mft_ref: int64;
  DataStreamCount: cardinal;
  AName: PWideChar;
  _IsDeleted: integer;
  IsDeleted: boolean;
  Parent: PPyObject;
  R: PVFSEntry;
  CD, MD: double;
  DataSize: int64;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'OLLIuidd', [@Parent, @mft_ref, @DataSize, @DataStreamCount, @AName, @_IsDeleted, @CD, @MD]) <> 0 then begin
        if PyVFSEntry_Check(Parent) then begin
          IsDeleted := False;
          if _IsDeleted <> 0 then
            IsDeleted := True;
          OwnData := FNTFSData.XAlloc;
          OwnData^.mft_ref := mft_ref;
          OwnData^.Node := nil;
          //OwnData^.ContentsNode := nil;
          OwnData^.DataStreamCount := DataStreamCount;
          R := VFSManager1.AddFile(AName, IsDeleted, Cd, MD, PPyVFSEntry(Parent)^.TargetEntry, OwnData, DataSize);
          result := MapVFSEntry(R);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_NotifyChangeEntry(_self,
  args: PPyObject): PPyObject;
var
  Nod: PPyObject;
  E: PVFSEntry;
  AName: PWideChar;
  CD, MD: double;
  _IsDeleted: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'Ouddi', [@nod, @AName, @CD, @MD, @_IsDeleted]) <> 0 then begin
        if PyVFSEntry_Check(Nod) then begin
          E := PPyVFSEntry(Nod)^.TargetEntry;
          E^.Name := VFSManager1.AddName(AName);
          E^.NameLength := length(AName);
          E^.CreateDate := CD;
          E^.ModifyDate := MD;
          if _IsDeleted <> 0 then
            E^.Flags := E^.Flags or VFS_FLAG_DELETED
          else
            E^.Flags := E^.Flags and not VFS_FLAG_DELETED;
          VFSManager1.PerformChangeNotification(E);
          result := Py_None;
          Py_INCREF(Py_None);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_SetupVolumeObject(_self,
  args: PPyObject): PPyObject;
var
  Entry: PPyObject;
  Volume: PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'OO', [@Entry, @Volume]) <> 0 then begin
        if PyVFSEntry_Check(Entry) then begin
          if VFSIsDriveEntry(PPyVFSEntry(Entry)^.TargetEntry) then begin
            PNTFSData(PPyVFSEntry(Entry)^.TargetEntry^.UserData)^.VolumeObject := Volume;
            Py_INCREF(Volume);
            result := Py_None;
            Py_INCREF(Py_None);
          end else
            PyErr_SetString(PyExc_TypeError^, 'Drive entry expected');
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFS entry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_MoveEntry(_self, args: PPyObject): PPyObject;
var
  Entry, NewNode: PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'OO', [@Entry, @NewNode]) <> 0 then begin
        if PyVFSEntry_Check(Entry) and PyVFSEntry_Check(NewNode) then begin
          VFSManager1.MoveNode(PPyVFSEntry(Entry)^.TargetEntry, PPyVFSEntry(NewNode)^.TargetEntry);
          result := Py_None;
          Py_INCREF(Py_None);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_NTFSDate2DateTime(_self,
  args: PPyObject): PPyObject;
var
  D: int64;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'L', [@D]) <> 0 then begin
        result := PyFloat_FromDouble(NTFSDate2DateTime(D));
      end;
    end;
  end;
end;

procedure TMainForm.RecoveryBrowseFolderButtonClick(Sender: TObject);
var
  Folder: WideString;
begin
  if SelectFolder(Folder) then begin
    CBXRecoveryFolder.Text := Folder;
  end;
end;


function TMainForm._PyApp_GetRecoveryParams(_self,
  args: PPyObject): PPyObject;
var
  uncheck_option, naming_option: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        result := PyDict_New;
        naming_option := 0;
        if RBAskForName.Checked then
          naming_option := 1
        else if RBSkipThoseFiles.Checked then
          naming_option := 2
        else if RBOverwrite.Checked then
          naming_option := 3;
        uncheck_option := 0;
        if RBUncheckAllProcessed.Checked then
          uncheck_option := 1
        else if RBDoNotUncheck.Checked then
          uncheck_option := 2;

        PyDict_SetItemString(result, 'recovery_folder', PyUnicode_FromWideString(CBXRecoveryFolder.Text));
        PyDict_SetItemString(result, 'naming', PyInt_FromLong(naming_option));
        PyDict_SetItemString(result, 'recover_folder_structure', PyBool_FromLong(integer(CBRecoverFolderStructure.Checked)));
        PyDict_SetItemString(result, 'recover_all_data_strems', PyBool_FromLong(integer(CBRecoverAllDataStreams.Checked)));
        PyDict_SetItemString(result, 'delete_unsuccessful', PyBool_FromLong(integer(CBDeleteUnsuccessful.Checked)));
        PyDict_SetItemString(result, 'unchecking', PyLong_FromLong(uncheck_option));
      end;
    end;
  end;
end;

function TMainForm._PyApp_NotifyRecoveryProgress(_self,
  args: PPyObject): PPyObject;
var
  CurrentFileProgress, TotalProgress, TotalFiles, ProcessedFiles, RemainFiles: integer;
  EstTime, ElapsTime, TimeLeft: pchar;
  M: PRecoveryProgressMessage;
  WCurrentFileName: PWideChar;
  SCurrentFileName: string;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'uiiiiisss', [@WCurrentFileName,
                  @CurrentFileProgress, @TotalProgress,
                  @TotalFiles, @ProcessedFiles, @RemainFiles,
                  @EstTime, @ElapsTime, @TimeLeft]) <> 0 then begin
         new(M);
         SCurrentFileName := WCurrentFileName;
         M^.CurrentFileName := AllocStr(SCurrentFileName);
         M^.CurrentFileProgress := CurrentFileProgress;
         M^.TotalProgress := TotalProgress;
         M^.TotalFiles := TotalFiles;
         M^.ProcessedFiles := ProcessedFiles;
         M^.RemainFiles := RemainFiles;
         M^.EstTime := AllocStr(EstTime);
         M^.ElapsTime := AllocStr(ElapsTime);
         M^.TimeLeft := AllocStr(TimeLeft);
         SendMessage(HAndle, PCM_NotifyRecoveryProgress, 0, integer(M));
         FreeStr(M^.CurrentFileName);
         FreeStr(M^.EstTime);
         FreeStr(M^.ElapsTime);
         FreeStr(M^.TimeLeft);
         dispose(M);
         result := Py_None;
         Py_INCREF(result);
      end;
    end;
  end;
end;


procedure TMainForm._PCM_NotifyRecoveryProgress(var Message: TMessage);
var
  M: PRecoveryProgressMessage;
begin
  M := PRecoveryProgressMessage(Message.LParam);
  CurrentRecoveryFileLabel.Caption := M^.CurrentFileName;
  CurrentFileRecoveryProgressBar.Position := M^.CurrentFileProgress;
  TotalRecoveryProgressBar.Position := M^.TotalProgress;
  CurrentFileRecoveryPercentLabel.Caption := IntToStr(M^.CurrentFileProgress) + '%';
  TotalRecoveryPercentLabel.Caption := IntToStr(M^.TotalProgress) + '%';
  RecoveryTotalFilesLabel.Caption := IntToStr(M^.TotalFiles);
  RecoveryProcessedLabel.Caption := IntToStr(M^.ProcessedFiles);
  RecoveryRemainLabel.Caption := IntToStr(M^.RemainFiles);
  //RecoveryEstimatedLabel.Caption := M^.EstTime;
  //RecoveryElapsedLabel.Caption := M^.ElapsTime;
  //RecoveryTimeLeftLabel.Caption := M^.TimeLeft;
end;

function TMainForm._PyApp_RecoveryPanelDone(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        SendMessage(Handle, PCM_RecoveryPanelDone, 0, 0);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

function TMainForm._PyApp_RecoveryPanelInit(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        SendMessage(Handle, PCM_RecoveryPanelInit, 0, 0);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm._PCM_RecoveryPanelDone(var Message: TMessage);
begin
  RecoveryStartButton.Enabled := True;
  RecoveryStopButton.Enabled := False;
  RecoverySkipFileButton.Enabled := False;
  RecoveryPauseButton.Enabled := False;
  CurrentFileRecoveryPercentLabel.Caption := '';
  CurrentFileRecoveryProgressBar.Position := 0;
  TotalRecoveryProgressBar.Position := 0;
  TotalRecoveryPercentLabel.Caption := '';
  CurrentRecoveryFileLabel.Caption := '';
end;

procedure TMainForm._PCM_RecoveryPanelInit(var Message: TMessage);
begin
  ClearRecoveryMessages;
  RecoveryStartButton.Enabled := False;
  RecoveryStopButton.Enabled := True;
  RecoveryPauseButton.Enabled := True;
  RecoverySkipFileButton.Enabled := True;
  RecoveryProcessedLabel.Caption := '';
  RecoveryTotalFilesLabel.Caption := '';
  RecoveryRemainLabel.Caption := '';
  //RecoveryEstimatedLabel.Caption := '';
  //RecoveryElapsedLabel.Caption := '';
  //RecoveryTimeLeftLabel.Caption := '';
end;

procedure TMainForm.RecoveryStartButtonClick(Sender: TObject);
var
  Folder: WideString;
begin
  if length(CBXRecoveryFolder.Text) > 0 then begin
    FPython.PushLine('pyue.ue_runtime.start_recovery()');
    CBXRecoveryFolder.Items.Insert(0, CBXRecoveryFolder.Text);
  end else begin
    if SelectFolder(Folder) then begin
      CBXRecoveryFolder.Text := Folder;
      FPython.PushLine('pyue.ue_runtime.start_recovery()');
      CBXRecoveryFolder.Items.Insert(0, CBXRecoveryFolder.Text);
    end;
  end;
end;

procedure TMainForm._PCM_EmitRecoveryMessage(var Message: TMessage);
begin
  AddRecoveryMessage(TRecoveryMsgType( Message.WParam ), pchar(Message.LParam));
end;

function TMainForm._PyApp_EmitRecoveryMessage(_self,
  args: PPyObject): PPyObject;
var
  s: pchar;
  W: PWideChar;
  ss: string;
  T: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'iu', [@T, @W]) <> 0 then begin
        ss := W;
        s := pchar(ss);
        s := AllocStr(s);
        SendMessage(Handle, PCM_EmitRecoveryMessage, T, integer(s));
        FreeStr(s);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm.RecoverySkipFileButtonClick(Sender: TObject);
begin
  FPython.PushLine('pyue.ue_runtime.recovery_skip_current_file()');
end;

procedure TMainForm.RecoveryStopButtonClick(Sender: TObject);
begin
  FPython.PushLine('pyue.ue_runtime.recovery_stop()');
end;

procedure TMainForm.cbxModificationClick(Sender: TObject);
begin
  Label2.Enabled := cbxModification.Checked;
  Label3.Enabled := cbxModification.Checked;
  dtpModifyFrom.Enabled := cbxModification.Checked;
  dtpModifyTo.Enabled := cbxModification.Checked;
end;

procedure TMainForm.cbxCreatedClick(Sender: TObject);
begin
  Label4.Enabled := cbxCreated.Checked;
  Label5.Enabled := cbxCreated.Checked;
  dtpCreateFrom.Enabled := cbxCreated.Checked;
  dtpCreateTo.Enabled := cbxCreated.Checked;
end;

function TMainForm._PyApp_EntryIsDrive(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsDriveEntry(PE^.TargetEntry) then
            result := PyBool_FromLong(1)
          else
            result := PyBool_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetDataSize(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if VFSIsFileEntry(PE^.TargetEntry) or VFSIsDirectoryEntry(PE^.TargetEntry) then
            result := PyLong_FromLongLong(Pe^.TargetEntry^.DataSize)
          else
            PyErr_SetString(PyExc_TypeError^, 'Non-file-system objects cannot have data size');
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm.AddRecoveryMessage(MsgType: TRecoveryMsgType;
  mess: string);
var
  p: PRecoveryMsg;
begin
  new(p);
  p^.Time := time;
  p^.MsgType := MsgType;
  p^.Text := mess;
  FRecoveryProtocol.Add(p);
  case MsgType of
  rmtMessage: begin
                if RMessagesFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
              end;
  rmtError:   begin
                if RErrorsFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
              end;
  rmtWarning: begin
                if RWarningsFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
              end;
  rmtSuccess: begin
                if RSuccessesFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
              end;
  end;
  RecoveryProtocol.RootNodeCount := FRecoveryProtocolVisual.Count;
end;

procedure TMainForm.ClearRecoveryMessages;
var
  i: integer;
begin
  for i := 0 to FRecoveryProtocol.Count-1 do
    dispose(FRecoveryProtocol.Items[i]);
  FRecoveryProtocol.Clear;
  FRecoveryProtocolVisual.Clear;
  RecoveryProtocol.RootNodeCount := 0;
end;

  function MsgType2Str(mt: TRecoveryMsgType): string;
  begin
    case mt of
    rmtMessage: result := 'Message';
    rmtError:   Result := 'Error  ';
    rmtWarning: Result := 'Warning';
    rmtSuccess: Result := 'Success';
    end;
  end;

procedure TMainForm.RecoveryProtocolGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
  case Column of
  0: CellText := IntToStr(Node^.Index+1);
  1: CellText := TimeToStr(PRecoveryMsg(FRecoveryProtocolVisual.Items[Node^.Index])^.Time);
  2: CellText := MsgType2Str(PRecoveryMsg(FRecoveryProtocolVisual.Items[Node^.Index])^.MsgType);
  3: CellText := PRecoveryMsg(FRecoveryProtocolVisual.Items[Node^.Index])^.Text;
  end;
end;

procedure TMainForm.applyRecoveryFilter(Sender: TObject);
var
  i: integer;
  p: PRecoveryMsg;
begin
  RecoveryProtocol.RootNodeCount := 0;
  FRecoveryProtocolVisual.Clear;
  for i := 0 to FRecoveryProtocol.Count-1 do begin
    p := FRecoveryProtocol.Items[i];
    case p^.MsgType of
    rmtMessage: if RMessagesFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
    rmtError:   if RErrorsFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
    rmtWarning: if RWarningsFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
    rmtSuccess: if RSuccessesFilterButton.Down then
                  FRecoveryProtocolVisual.Add(p);
    end;
  end;
  RecoveryProtocol.RootNodeCount := FRecoveryProtocolVisual.Count;
end;

procedure TMainForm.RecoveryProtocolPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  p: PRecoveryMsg;
begin
  p := PRecoveryMsg(FRecoveryProtocolVisual.Items[Node^.Index]);
  case p^.MsgType of
  rmtError: TargetCanvas.Font.Color := clRed;
  rmtWarning: TargetCanvas.Font.Color := clBlue;
  rmtMessage: TargetCanvas.Font.Color := clGreen;
  end;
end;

procedure TMainForm.ContentsListInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  p: ^PVFSEntry;
begin
  p := Sender.GetNodeData(Node);
  try
    p^ := FContentsList.Items[Node^.Index];
  except
    exit;
  end;
  PNTFSData(p^.UserData)^.ContentsNode := Node;
  Node^.CheckType := ctCheckBox;
  if VFSCheckUserFlag(p^, 1) then
    Node^.CheckState := csCheckedNormal
  else
    Node^.CheckState := csUncheckedNormal;
end;

procedure TMainForm.DirTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  p1, p2: ^PVFSEntry;
begin
  p1 := Sender.GetNodeData(Node1);
  p2 := Sender.GetNodeData(Node2);
  result := 0;
  if (p1^.Name <> nil) and (p2^.Name <> nil) then
    result := CompareText(VFSManager1.EntryName(p1^), VFSManager1.EntryName(p2^));
end;

procedure TMainForm.SearchListChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  E: ^PVFSEntry;
begin
  E := Sender.GetNodeData(Node);
  if E^ <> nil then begin
    RecursiveMark(E^, not VFSCheckUserFlag(E^, 1));
    if VFSCheckUserFlag(e^, 1) then
      Node^.CheckState := csCheckedNormal
    else begin
      Node^.CheckState := csUncheckedNormal;
      UprecurseUnmark(E^);
    end;
    SynchronizeChecksOn(ContentsList);
    SynchronizeChecksOn(SearchList);
    SearchList.Repaint;
  end;
end;

procedure TMainForm.SynchronizeChecksOn(tree: TBaseVirtualTree);
var
  p: PVirtualNode;
  T: ^PVFSEntry;
begin
  p := tree.TopNode;
  while p <> nil do begin
    T := tree.GetNodeData(p);
    if (T <> nil) then begin
      if VFSCheckUserFlag(T^, 1) then
        p^.CheckState := csCheckedNormal
      else
        p^.CheckState := csUncheckedNormal;
    end;
    p := tree.GetNext(p);
  end;
end;


procedure TMainForm._PCM_QuerySaveFileDlg(var Message: TMessage);
type
  ppc = ^pchar;
var
  F: ppc;
  x: pchar;
begin
  F := ppc(Message.LParam);
  x := F^;
  SaveFileDlg.FileName := x;
  FreeStr(F^);
  F^ := nil;
  if SaveFileDlg.Execute then
    F^ := AllocStr(SaveFileDlg.FileName);
end;

function TMainForm._PyApp_SaveDlgQuery(_self, args: PPyObject): PPyObject;
var
  W: pwidechar;
  src_file_name: pchar;
  ss: string;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@w]) <> 0 then begin
        ss := w;
        src_file_name := pchar(ss);
        src_file_name := AllocStr(src_file_name);
        SendMessage(handle, PCM_QuerySaveFileDlg, 0, integer(@src_file_name));
        if src_file_name <> nil then begin
          result := PyString_FromString(src_file_name);
          FreeStr(src_file_name);
        end else begin
          result := Py_None;
          Py_INCREF(Py_None);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.ActionGoToExecute(Sender: TObject);
var
  N: PVirtualNode;
  E: ^PVFSEntry;
  _NewCWD: PVFSEntry;
begin
  N := SearchList.FocusedNode;
  E := SearchList.GetNodeData(N);
  if (E <> nil) and (E^ <> nil) then begin
    if VFSIsContainerEntry(E^) then
      _NewCWD := E^
    else
      _NewCWD := E^.Parent;
    if (_NewCWD <> nil) and (PNTFSData(_NewCWD^.UserData)^.Node <> nil) then begin
      PageControl1.ActivePageIndex := 0;
      DirTree.VisiblePath[PNTFSData(_NewCWD^.UserData)^.Node] := True;
      DirTree.FocusedNode := PNTFSData(_NewCWD^.UserData)^.Node;
      DirTree.Selected[PNTFSData(_NewCWD^.UserData)^.Node] := True;
      DirTree.ScrollIntoView(PNTFSData(_NewCWD^.UserData)^.Node, True, True);
      if VFSIsContainerEntry(E^) then
        ActiveControl := DirTree
      else begin
        ActiveControl := ContentsList;
        ContentsList.ClearSelection;
        ContentsList.Selected[ PNTFSData(E^.UserData)^.ContentsNode ] := True;
        ContentsList.FocusedNode := PNTFSData(E^.UserData)^.ContentsNode;
        ContentsListChange(ContentsList, ContentsList.FocusedNode);
      end;
    end;
  end;
end;

procedure TMainForm._DoExecutePyScript(context: pointer);
var
  func , args: PPyObject;
begin
  with GetPythonEngine do begin
    func := FindFunction('pyue.ue_runtime', 'execute_script');
    if func <> nil then begin
      args := PyTuple_New(1);
      PyTuple_SetItem(args, 0, PyString_FromString(context));
      Py_XDECREF(PyObject_CallObject(func, args));
      if PyErr_Occurred <> nil then begin
        PyErr_Print();
        PyErr_Clear();
      end;
      Py_DECREF(func);
      Py_DECREF(args);
    end;
  end;
end;

procedure TMainForm.ActionSaveAsExecute(Sender: TObject);
begin
  FPython.PushLine('pyue.ue_runtime.save_as()');
end;


function TMainForm.GetSelectedFile: PVFSEntry;
var
  p: PVirtualNode;
  E: ^PVFSEntry;
begin
  result := nil;
  if ActiveControl = ContentsList then begin
    p := ContentsList.FocusedNode;
    if p <> nil then begin
      E := ContentsList.GetNodeData(P);
      if (E <> nil) and (E^ <> nil) and VFSIsFileEntry(E^) then
        result := E^;
    end;
  end else if ActiveControl = SearchList then begin
    p := SearchList.FocusedNode;
    if p <> nil then begin
      E := SearchList.GetNodeData(P);
      if (E <> nil) and (E^ <> nil) and VFSIsFileEntry(E^) then
        result := E^;
    end;
  end;
end;

procedure TMainForm._PCM_NotifyProgressDlg(var Message: TMessage);
begin
  ProgressDlg.ProgressBar.Position := Message.LParam;
end;

procedure TMainForm._PCM_HideProgressDlg(var Message: TMessage);
begin
  ProgressDlg.ModalResult := mrCancel;
  ProgressDlg.Close;
end;

procedure TMainForm._PCM_ShowProgressDlg(var Message: TMessage);
var
  p: PShowProgressDlgMessage;
begin
  p := PShowProgressDlgMessage(Message.LParam);
  ProgressDlg.ProgressBar.Position := 0;
  ProgressDlg.Caption := p^.caption;
  ProgressDlg.ActionLabel.Caption := p^.task_caption;
  FreeStr(p^.caption);
  FreeStr(p^.task_caption);
  dispose(p);
  ProgressDlg.ShowModal;
end;

function TMainForm._PyApp_HideProgressDlg(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        PostMessage(Handle, PCM_HideProgressDlg, 0, 0);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

function TMainForm._PyApp_NotifyProgressDlg(_self,
  args: PPyObject): PPyObject;
var
  perc: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'i', [@perc]) <> 0 then begin
        SendMessage(Handle, PCM_NotifyProgressDlg, 0, perc);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

function TMainForm._PyApp_ShowProgressDlg(_self,
  args: PPyObject): PPyObject;
var
  p: PShowProgressDlgMessage;
  caption, task_name: PWideChar;
  s: string;
  _caption, _task_name: pchar;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'uu', [@caption, @task_name]) <> 0 then begin
        s := caption;
        _caption := AllocStr(s);
        s := task_name;
        _task_name := AllocStr(s);
        new(p);
        p^.caption := _caption;
        p^.task_caption := _task_name;
        PostMessage(Handle, PCM_ShowProgressDlg, 0, integer(p));
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetPath(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := PyUnicode_FromWideString(VFSManager1.PathForEntry(PE^.TargetEntry));
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_MarkEntry(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          SendMessage(Handle, PCM_MarkEntry, 0, integer(PE^.TargetEntry));
          Py_INCREF(Py_None);
          result := Py_None;
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_UnmarkEntry(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          SendMessage(Handle, PCM_UnMarkEntry, 0, integer(PE^.TargetEntry));
          Py_INCREF(Py_None);
          result := Py_None;
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm._PCM_MarkEntry(var Message: TMessage);
begin
  MarkEntry(PVFSEntry(Message.LParam));
  SynchronizeChecksOn(ContentsList);
  SynchronizeChecksOn(SearchList);
  if PageControl1.ActivePageIndex = 0 then
    ContentsList.Repaint
  else if PageControl1.ActivePageIndex = 1 then
    SearchSheet.Repaint;
end;

procedure TMainForm._PCM_UnMarkEntry(var Message: TMessage);
begin
  UnMarkEntry(PVFSEntry(Message.LParam));
  SynchronizeChecksOn(ContentsList);
  SynchronizeChecksOn(SearchList);
  if PageControl1.ActivePageIndex = 0 then
    ContentsList.Repaint
  else if PageControl1.ActivePageIndex = 1 then
    SearchSheet.Repaint;
end;

function TMainForm.HasMarkedChildren(entry: PVFSEntry): boolean;
begin
  result := false;
  if VFSIsContainerEntry(entry) then begin
    entry := entry^.FirstChild;
    while (entry <> nil) and not result do begin
      result := VFSCheckUserFlag(entry, 1);
      if not result then
        result := HasMarkedChildren(entry);
      entry := entry^.Next;
    end;
  end;
end;

function TMainForm._PyApp_EntryHasMarkedChildren(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := PyBool_FromLong(integer(HasMarkedChildren(PE^.TargetEntry)));
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm.DirTreeInitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  E: ^PVFSEntry;
begin
  E := Sender.GetNodeData(Node);
  if VFSIsDriveEntry(E^) then begin
    InitialStates := InitialStates + [ivsHasChildren];
  end;
end;

procedure TMainForm._PCM_ExpandEntry(var Message: TMessage);
var
  p: PVFSEntry;
begin
  p := PVFSEntry(Message.LParam);
  if VFSIsContainerEntry(p) and (PNTFSData(p^.UserData)^.Node <> nil) then
    DirTree.Expanded[PNTFSData(p^.UserData)^.Node] := True;
end;

function TMainForm._PyApp_ExpandEntry(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          SendMessage(Handle, PCM_ExpandEntry, 0, integer(PE^.TargetEntry));
          result := Py_None;
          Py_INCREF(Py_None);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm.DirTreeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
begin
  if Button = mbLeft then begin
    Node := DirTree.GetNodeAt(X, Y);
    DirTree.FocusedNode := Node;
    DirTree.Selected[Node] := True;
  end;
end;

function TMainForm._PyApp_SetSearchCaption(_self,
  args: PPyObject): PPyObject;
var
  s: pchar;
  W: PWideChar;
  ss: string;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@W]) <> 0 then begin
        ss := W;
        s := pchar(ss);
        SendMessage(Handle, PCM_SetSearchCaption, 0, cardinal(AllocStr(s)));
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm._PCM_SetSearchCaption(var Message: TMessage);
var
  s: pchar;
begin
  s := pchar(Message.LParam);
  SearchActionLabel.Caption := s;
  FreeStr(s);
end;

function TMainForm._PyApp_SetScanPercent(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
  i: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'Oi', [@PE, @i]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) and VFSIsDriveEntry(PE^.TargetEntry) then begin
          SendMessage(Handle, PCM_SetScanPercent, i, integer(PE^.TargetEntry));
          result := Py_None;
          Py_INCREF(Py_None);
        end else
          PyErr_SetString(PyExc_TypeError^, 'Drive VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm._PCM_SetScanPercent(var Message: TMessage);
var
  E: PVFSEntry;
  N: PVirtualNode;
begin
  E := PVFSEntry(Message.LParam);
  N := PNTFSData(E^.UserData)^.Node;
  PNTFSData(E^.UserData)^.ScanPercent := Message.WParam;
  DirTree.Text[N, -1] := '';
  DirTree.RepaintNode(N);
  if ScanProgressDlg.Visible and (ScanProgressDlg.ActiveEntry = E) then
    ScanProgressDlg.SetPercent(Message.WParam);
end;

function TMainForm._PyApp_EntryIsDriveScanned(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) and (VFSIsDriveEntry(PE^.TargetEntry)) then begin
          if PNTFSData(PE^.TargetEntry^.UserData)^.ScanPercent >= 100 then
            result := PyBool_FromLong(1)
          else
            result := PyBool_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm.SearchNotifyTimerTimer(Sender: TObject);
begin
  SearchList.RootNodeCount := VFSManager1.SearchResultCount;
end;

procedure TMainForm.SearchListHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button = mbLeft then begin
    if FLockSearchColumns and (PageControl1.ActivePageIndex = 1) then
      exit;
    if Column < 6 then begin
      if Column = Sender.SortColumn then begin
        if Sender.SortDirection = sdAscending then
          Sender.SortDirection := sdDescending
        else
          Sender.SortDirection := sdAscending
      end else
        Sender.SortColumn := Column;
      SearchList.SortTree(Sender.SortColumn, Sender.SortDirection);
    end;
  end;
end;

function TMainForm._PyApp_EntryIsDriveScanning(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
  perc: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) and (VFSIsDriveEntry(PE^.TargetEntry)) then begin
          perc := PNTFSData(PE^.TargetEntry^.UserData)^.ScanPercent;
          if (perc < 0) and (perc >= 100) then
            result := PyBool_FromLong(0)
          else
            result := PyBool_FromLong(1);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm.HasUnkEntryParent(E: PVFSEntry): boolean;
begin
  if E^.Parent <> nil then
    result := (PNTFSData(E^.Parent^.UserData)^.mft_ref = -7) or HasUnkEntryParent(E^.Parent)
  else
    result := False;
end;

function TMainForm._PyApp_EntryHasUnkEntryParent(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if HasUnkEntryParent(PE^.TargetEntry) then
            result := PyBool_FromLong(1)
          else
            result := PyBool_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryIsDriveNotScanned(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) and (VFSIsDriveEntry(PE^.TargetEntry)) then begin
          if PNTFSData(PE^.TargetEntry^.UserData)^.ScanPercent < 0 then
            result := PyBool_FromLong(1)
          else
            result := PyBool_FromLong(0);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_GetSearchResultCount(_self,
  args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if Pyarg_ParseTuple(args, '', []) <> 0 then begin
        result := PyInt_FromLong(VFSManager1.SearchResultCount);
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntryCheckUserFlag(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
  fi: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'Oi', [@PE, @fi]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if (fi >= 0) and (fi <= 3) then begin
            if VFSCheckUserFlag(pe^.TargetEntry, fi) then
              result := PyBool_FromLong(1)
            else
              result := PyBool_FromLong(0);
          end else
            PyErr_SetString(PyExc_TypeError^, 'invalid flag index');
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

function TMainForm._PyApp_EntrySetUserFlag(_self,
  args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
  v, fi: integer;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'Oii', [@PE, @fi, @v]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          if (fi >= 0) and (fi <= 3) then begin
            if v = 0 then
              VFSSetUserFlag(PE^.TargetEntry, fi, False)
            else
              VFSSetUserFlag(PE^.TargetEntry, fi, True);
            result := Py_None;
            Py_INCREF(Py_None);
          end else
            PyErr_SetString(PyExc_TypeError^, 'invalid flag index');
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm.ActionViewNameColumnExecute(Sender: TObject);
begin
  ActionViewNameColumn.Checked := not ActionViewNameColumn.Checked;
  SetColumnVisible(0, ActionViewNameColumn.Checked);
  if PageControl1.TabIndex = 0 then
    UIConfig.CNameVisible := ActionViewNameColumn.Checked
  else if PageControl1.TabIndex = 1 then
    UIConfig.SNameVisible := ActionViewNameColumn.Checked;
end;

procedure TMainForm.ActionViewCreatedateColumnExecute(Sender: TObject);
begin
  ActionViewCreatedateColumn.Checked := not ActionViewCreatedateColumn.Checked;
  SetColumnVisible(1, ActionViewCreatedateColumn.Checked);
  if PageControl1.TabIndex = 0 then
    UIConfig.CCreateDateVisible := ActionViewCreatedateColumn.Checked
  else if PageControl1.TabIndex = 1 then
    UIConfig.SCreateDateVisible := ActionViewCreatedateColumn.Checked;
end;

procedure TMainForm.SetColumnVisible(column: integer; vis: boolean);
begin
  if PageControl1.TabIndex = 0 then begin
    if vis then
      ContentsList.Header.Columns[column].Options := ContentsList.Header.Columns[column].Options + [coVisible]
    else
      ContentsList.Header.Columns[column].Options := ContentsList.Header.Columns[column].Options - [coVisible];
  end else if PageControl1.TabIndex = 1 then begin
    if vis then
      SearchList.Header.Columns[column].Options := SearchList.Header.Columns[column].Options + [coVisible]
    else
      SearchList.Header.Columns[column].Options := SearchList.Header.Columns[column].Options - [coVisible];
  end;
end;

procedure TMainForm.ActionViewModifyDateColumnExecute(Sender: TObject);
begin
  ActionViewModifyDateColumn.Checked := not ActionViewModifyDateColumn.Checked;
  SetColumnVisible(2, ActionViewModifyDateColumn.Checked);
  if PageControl1.TabIndex = 0 then
    UIConfig.CModifyDateVisible := ActionViewModifyDateColumn.Checked
  else if PageControl1.TabIndex = 1 then
    UIConfig.SModifyDateVisible := ActionViewModifyDateColumn.Checked;
end;

procedure TMainForm.ActionViewSizeColumnExecute(Sender: TObject);
begin
  ActionViewSizeColumn.Checked := not ActionViewSizeColumn.Checked;
  SetColumnVisible(3, ActionViewSizeColumn.Checked);
  if PageControl1.TabIndex = 0 then
    UIConfig.CSizeVisible := ActionViewSizeColumn.Checked
  else if PageControl1.TabIndex = 1 then
    UIConfig.SSizeVisible := ActionViewSizeColumn.Checked;
end;

procedure TMainForm.ActionViewMFTRefColumnExecute(Sender: TObject);
begin
  ActionViewMFTRefColumn.Checked := not ActionViewMFTRefColumn.Checked;
  SetColumnVisible(4, ActionViewMFTRefColumn.Checked);
  if PageControl1.TabIndex = 0 then
    UIConfig.CMFTRefVisible := ActionViewMFTRefColumn.Checked
  else if PageControl1.TabIndex = 1 then
    UIConfig.SMFTRefVisible := ActionViewMFTRefColumn.Checked;
end;

procedure TMainForm.ActionViewDataStreamsColumnExecute(Sender: TObject);
begin
  ActionViewDataStreamsColumn.Checked := not ActionViewDataStreamsColumn.Checked;
  SetColumnVisible(5, ActionViewDataStreamsColumn.Checked);
  if PageControl1.TabIndex = 0 then
    UIConfig.CDataStreamsVisible := ActionViewDataStreamsColumn.Checked
  else if PageControl1.TabIndex = 1 then
    UIConfig.SDataStreamsVisible := ActionViewDataStreamsColumn.Checked;
end;

procedure TMainForm.ActionViewPathColumnExecute(Sender: TObject);
begin
  ActionViewPathColumn.Checked := not ActionViewPathColumn.Checked;
  SetColumnVisible(6, ActionViewPathColumn.Checked);
  UIConfig.SPathVisible := ActionViewPathColumn.Checked;
end;

procedure TMainForm.ActionViewQuickViewExecute(Sender: TObject);
begin
  ActionViewQuickView.Checked := not ActionViewQuickView.Checked;
  QuickViewPanel.Visible := ActionViewQuickView.Checked;
  QuickViewSPanel.Visible := ActionViewQuickView.Checked;
  Splitter2.Visible := ActionViewQuickView.Checked;
  Splitter3.Visible := ActionViewQuickView.Checked;
  UIConfig.QuickViewVisible := ActionViewQuickView.Checked;
end;

function TMainForm._PyApp_ShowScanDlg(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) and (VFSIsDriveEntry(PE^.TargetEntry)) then begin
          if UIConfig.ShowScanProgressDlg then
            PostMessage(Handle, PCM_ShowScanDlg, 0, integer(PE^.TargetEntry));
          result := Py_None;
          Py_INCREF(Py_None);
        end else
          PyErr_SetString(PyExc_TypeError^, 'Drive VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm._PCM_ShowScanDlg(var Message: TMessage);
var
  E: PVFSEntry;
begin
  E := PVFSEntry(Message.LParam);
  if not ScanProgressDlg.Visible then begin
    ScanProgressDlg.ActiveEntry := E;
    ScanProgressDlg.ShowModal;
  end;
end;

function TMainForm._PyApp_HideScanDlg(_self, args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        PostMessage(Handle, PCM_HideScanDlg, 0, 0);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm._PCM_HideScanDlg(var Message: TMessage);
begin
  ScanProgressDlg.ModalResult := mrCancel;
  ScanProgressDlg.Close;
end;

{ TUIConfiguration }

function TUIConfiguration.GetConfigFilePath: string;
begin
  result := ParamStr(0);
  result[length(result)] := 'i';
  result[length(result)-1] := 'u';
  result[length(result)-2] := 'c';
end;

procedure TUIConfiguration.Load;
var
  f: file of TConfigFileRecord;
begin
  MakeDefaultConfiguration;
  Assign(F, GetConfigFilePath);
  {$I-}
  Reset(F);
  if IOResult <> 0 then
    exit;
  BlockRead(F, FConf, 1);
  if IOResult <> 0 then begin
    System.Close(F);
    exit;
  end;
  {$I+}
  system.Close(f);

  with MainForm.ContentsList.Header do begin
    if CNameVisible then
      Columns[0].Options := Columns[0].Options + [coVisible]
    else
      Columns[0].Options := Columns[0].Options - [coVisible];
    if CCreateDateVisible then
      Columns[1].Options := Columns[1].Options + [coVisible]
    else
      Columns[1].Options := Columns[1].Options - [coVisible];
    if CModifyDateVisible then
      Columns[2].Options := Columns[2].Options + [coVisible]
    else
      Columns[2].Options := Columns[2].Options - [coVisible];
    if CSizeVisible then
      Columns[3].Options := Columns[3].Options + [coVisible]
    else
      Columns[3].Options := Columns[3].Options - [coVisible];
    if CMFTRefVisible then
      Columns[4].Options := Columns[4].Options + [coVisible]
    else
      Columns[4].Options := Columns[4].Options - [coVisible];
    if CDataStreamsVisible then
      Columns[5].Options := Columns[5].Options + [coVisible]
    else
      Columns[5].Options := Columns[5].Options - [coVisible];
  end;
  with MainForm.SearchList.Header do begin
    if SNameVisible then
      Columns[0].Options := Columns[0].Options + [coVisible]
    else
      Columns[0].Options := Columns[0].Options - [coVisible];
    if SCreateDateVisible then
      Columns[1].Options := Columns[1].Options + [coVisible]
    else
      Columns[1].Options := Columns[1].Options - [coVisible];
    if SModifyDateVisible then
      Columns[2].Options := Columns[2].Options + [coVisible]
    else
      Columns[2].Options := Columns[2].Options - [coVisible];
    if SSizeVisible then
      Columns[3].Options := Columns[3].Options + [coVisible]
    else
      Columns[3].Options := Columns[3].Options - [coVisible];
    if SMFTRefVisible then
      Columns[4].Options := Columns[4].Options + [coVisible]
    else
      Columns[4].Options := Columns[4].Options - [coVisible];
    if SDataStreamsVisible then
      Columns[5].Options := Columns[5].Options + [coVisible]
    else
      Columns[5].Options := Columns[5].Options - [coVisible];
    if SPathVisible then
      Columns[6].Options := Columns[6].Options + [coVisible]
    else
      Columns[6].Options := Columns[6].Options - [coVisible];
  end;
  MainForm.QuickViewPanel.Visible := QuickViewVisible;
  MainForm.Splitter2.Visible := QuickViewVisible;
  MainForm.QuickViewSPanel.Visible := QuickViewVisible;
  MainForm.Splitter3.Visible := QuickViewVisible;
  MainForm.ActionViewQuickView.Checked := QuickViewVisible;
  MainForm.ActionFilterDeletedFiles.Checked := HighlightDeletedPath;
end;

procedure TUIConfiguration.MakeDefaultConfiguration;
begin
  with FConf do begin
    ShowScanProgressDlg := True;
    CCreateDateVisible := False;
    CNameVisible := True;
    CModifyDateVisible := True;
    CSizeVisible := True;
    CMFTRefVisible := False;
    CDataStreamsVisible := False;
    SCreateDateVisible := False;
    SNameVisible := True;
    SModifyDateVisible := True;
    SSizeVisible := True;
    SMFTRefVisible := False;
    SDataStreamsVisible := False;
    SPathVisible := True;
    QuickViewVisible := False;
    HighlightDeletedPath := True;
  end;
end;

procedure TUIConfiguration.Save;
var
  f: file of TConfigFileRecord;
begin
  Assign(F, GetConfigFilePath);
  {$I-}
  Rewrite(F);
  if IOResult <> 0 then
    exit;
  BlockWrite(F, FConf, 1);
  system.Close(f);
  {$I+}
end;

procedure TMainForm.UprecurseUnmark(E: PVFSEntry);
begin
  E := E^.Parent;
  if (E <> nil) and (not HasMarkedChildren(E)) then begin
    UnmarkEntry(E);
    UprecurseUnmark(E);
  end;
end;

procedure TMainForm.PageControl1Change(Sender: TObject);
begin
  if PageControl1.TabIndex in [0, 1] then
    ViewMenu.Visible := True
  else
    ViewMenu.Visible := False;
end;

procedure TMainForm.RecoveryPauseButtonClick(Sender: TObject);
begin
  FPython.PushLine('pyue.ue_runtime.recovery_pause()');
end;

procedure TMainForm.QuickViewSGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  i, pos: integer;
begin
  case Column of
  0:  CellText := IntToHex(Node^.Index*16, 8);
  1:  begin
        pos := Node^.Index*16;
        if pos + 16 < sizeof(FQVSBuffer) then begin
          CellText := '';
          for i := 0 to 15 do
            CellText := CellText + IntToHex(FQVSBuffer[pos+i], 2) + ' ';
        end;
      end;
  2:  begin
        pos := Node^.Index*16;
        if pos + 16 < sizeof(FQVSBuffer) then begin
          CellText := '';
          for i := 0 to 15 do
            if FQVSBuffer[pos+i] >= 32 then
              CellText := CellText + chr(FQVSBuffer[pos+i])
            else
              CellText := CellText + '.';
        end;
      end;
  end;
end;

procedure TMainForm.SearchListChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  p: ^PVFSEntry;
begin
  p := Sender.GetNodeData(Node);
  QuickViewS.Clear;
  FillChar(FQVSBuffer, sizeof(FQVSBuffer), 0);
  if (p <> nil) and (SelectedFile <> nil) then
    FPython.PushLine('pyue.ue_runtime.update_quickview()');
end;

procedure TMainForm.cbxSizeFromClick(Sender: TObject);
begin
  SizeFromEdit.Enabled := cbxSizeFrom.Checked;
  SizeFromRB.Enabled := cbxSizeFrom.Checked;
end;

procedure TMainForm.cbxSizeToClick(Sender: TObject);
begin
  SizeToEdit.Enabled := cbxSizeTo.Checked;
  SizeToRB.Enabled := cbxSizeTo.Checked;
end;

procedure TMainForm.rbAdvancedSearchClick(Sender: TObject);
begin
  cbSimpleSearchOnlyDeletedFiles.Enabled := rbSimpleSearch.Checked;
  AdvancedSearchPanel.Visible := rbAdvancedSearch.Checked;
end;

procedure TMainForm.SaveLogButtonClick(Sender: TObject);
var
  F: System.text;
  i: integer;
  R: PRecoveryMsg;
begin
  if SaveRecoveryLogDlg.Execute then begin
    System.Assign(F, SaveRecoveryLogDlg.FileName);
    {$I-}
    Rewrite(F);
    if IOResult <> 0 then begin
      ShowMessage('Cannot open log file. Error code: '+IntToStr(IoResult));
      exit;
    end;
    for i := 0 to FRecoveryProtocolVisual.Count-1 do begin
      R := PRecoveryMsg(FRecoveryProtocolVisual.Items[i]);
      Writeln(F, i+1, ' ', DateTimeToStr(r^.Time), ' ', MsgType2Str(r^.MsgType), ' ', R^.Text);
    end;
    System.Close(f);
    {$I+}
  end;
end;

procedure TMainForm.DirTreeGetHint(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: WideString);
var
  e: ^PVFSEntry;
begin
  e := Sender.GetNodeData(Node);
  if (e <> nil) and VFSIsDriveEntry(e^) and not VFSCheckUserFlag(e^, 0)then begin
    HintText := 'Click on drive, which contains files you want to recover';
  end;
end;

procedure TMainForm._PCM_ShowYesNoDlg(var Message: TMessage);
var
  msg: pchar;
begin
  msg := PYesNoDlgMessage(Message.LParam)^.Msg;
  PYesNoDlgMessage(Message.LParam)^.result := MessageDlg(msg, mtWarning, [mbYes, mbNo], 0);
end;

function TMainForm._PyApp_ShowYesNoDlg(_self, args: PPyObject): PPyObject;
var
  P: PYesNoDlgMessage;
  W: PwideChar;
  ss: string;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@W]) <> 0 then begin
        ss := W;
        new(P);
        P^.Msg := AllocStr(ss);
        P^.result := 0;
        SendMessage(Handle, PCM_ShowYesNoDlg, 0, cardinal(P));
        result := PyInt_FromLong(P^.result);
        FreeStr(P^.Msg);
        dispose(P);
      end;
    end;
  end;
end;

procedure TMainForm.miHomePageClick(Sender: TObject);
begin
    ShellExecute(Handle, 'open', 'http://www.ntfsundelete.com/', Nil,
                 Nil, SW_SHOW);
end;

procedure TMainForm.miAboutClick(Sender: TObject);
var Form: TAboutForm;
begin
    Form := TAboutForm.Create(Self);
    Form.ShowModal;
    Form.Free;
end;

procedure TMainForm.ActionFilterDeletedFilesExecute(Sender: TObject);
begin
  ActionFilterDeletedFiles.Checked := not ActionFilterDeletedFiles.Checked;
  FUIConfig.HighlightDeletedPath := ActionFilterDeletedFiles.Checked;
  DirTree.Repaint;
  ContentsList.Repaint;
end;


procedure TMainForm.VFSMgrUpdateTimerTimer(Sender: TObject);
var
  i: integer;
  msg: PVFMMessage;
begin
  if not FApplicationClosed then begin
    FVFSMgrMsgCS.Enter;
    for i := 0 to FVFSMrgMsgList.Count - 1 do begin
      msg := FVFSMrgMsgList.Items[i];
      process_vfs_message(msg);
    end;
    FVFSMrgMsgList.Clear;
    FVFSMgrMsgCS.Leave;
     ContentsList.RootNodeCount := FContentsList.Count;
  end;
  ContentsList.Repaint;
  DirTree.Repaint;
end;

procedure TMainForm.process_vfs_message(msg: PVFMMessage);
begin
  if msg^.code = VFM_AddNewEntry then
    _VFM_AddNewEntry(msg)
  else if msg^.code = VFM_MoveEntry then
    _VFM_MoveEntry(msg)
  else if msg^.code = VFM_ChangeNotification then
    _VFM_ChangeNotification(msg)
  else if msg^.code = VFM_ExpandEntryEx then
    _VFM_ExpandEntryEx(msg);
end;

function TMainForm._PyApp_HasConsole(_self, args: PPyObject): PPyObject;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, '', []) <> 0 then begin
        if Python.PythonEngine.UseWindowsConsole then
          result := PyBool_FromLong(1)
        else
          Result := PyBool_FromLong(0);
      end;
    end;
  end;
end;

procedure TMainForm._VFM_ExpandEntryEx(p: PVFMMessage);
begin
  if VFSIsContainerEntry(p^.TargetEntry) and (PNTFSData(p^.TargetEntry^.UserData)^.Node <> nil) then
    DirTree.Expanded[PNTFSData(p^.TargetEntry^.UserData)^.Node] := True;
  dispose(p);
end;

function TMainForm._PyApp_ExpandEntryEx(_self, args: PPyObject): PPyObject;
var
  Entry: PPyObject;
  p: PVFMMessage;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@Entry]) <> 0 then begin
        if PyVFSEntry_Check(Entry) then begin
          new(p);
          p^.code := VFM_ExpandEntryEx;
          p^.TargetEntry := PPyVFSEntry(Entry)^.TargetEntry;
          FVFSMgrMsgCS.Enter;
          FVFSMrgMsgList.Add(p);
          FVFSMgrMsgCS.Leave;
          result := Py_None;
          Py_INCREF(Py_None);
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;


procedure TMainForm.DirTreeBeforeItemPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var CustomDraw: Boolean);
begin
  TargetCanvas.Font.Color := clRed;
end;

procedure TMainForm.DirTreePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  E: ^PVFSEntry;
begin
  if ActionFilterDeletedFiles.Checked then begin
    E := Sender.GetNodeData(Node);
    if (E <> nil) and (E^ <> nil) and not VFSHasDeletedChildren(E^) then begin
      TargetCanvas.Font.Color := $b0b0b0;
    end;
  end;
end;

procedure TMainForm.ContentsListPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  E: ^PVFSEntry;
begin
  if ActionFilterDeletedFiles.Checked then begin
    E := Sender.GetNodeData(Node);
    if (E <> nil) and (E^ <> nil) and not VFSHasDeletedChildren(E^) then begin
      TargetCanvas.Font.Color := $b0b0b0;
    end;
  end;
end;

function TMainForm._PyApp_EntryGetID(_self, args: PPyObject): PPyObject;
var
  PE: PPyVFSEntry;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'O', [@PE]) <> 0 then begin
        if PyVFSEntry_Check(PPyObject(PE)) then begin
          result := PyLong_FromUnsignedLong(cardinal(PE^.TargetEntry));
        end else
          PyErr_SetString(PyExc_TypeError^, 'VFSEntry object needed');
      end;
    end;
  end;
end;

procedure TMainForm.ActionViewLoggingExecute(Sender: TObject);
begin
  ActionViewLogging.Checked := not ActionViewLogging.Checked;
  if ActionViewLogging.Checked then begin
    LoggingForm.Show;
  end else begin
    LoggingForm.Hide;
  end;
end;

function TMainForm._PyApp_AppendLogMsg(_self, args: PPyObject): PPyObject;
var
  W: PWideChar;
  ss: string;
  s: pchar;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@W]) <> 0 then begin
        ss := W;
        s := AllocStr(ss);
        SendMessage(Handle, PCM_AppendLogMsg, 0, cardinal(s));
        FreeStr(s);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm._PCM_AppendLogMsg(var Message: TMessage);
begin
  LoggingForm.LogRich.Lines.Append(pchar(Message.LParam));
end;

procedure TMainForm._PCM_SetLastLogMsg(var Message: TMessage);
begin
  if LoggingForm.LogRich.Lines.Count > 0 then
    LoggingForm.LogRich.Lines.Strings[LoggingForm.LogRich.Lines.Count-1] := pchar(Message.LParam)
  else
    LoggingForm.LogRich.Lines.Append(pchar(Message.LParam));
end;

function TMainForm._PyApp_SetLastLogMsg(_self, args: PPyObject): PPyObject;
var
  W: PWideChar;
  ss: string;
  s: pchar;
begin
  result := nil;
  if not FApplicationClosed then begin
    with GetPythonEngine do begin
      if PyArg_ParseTuple(args, 'u', [@W]) <> 0 then begin
        ss := W;
        s := AllocStr(ss);
        SendMessage(Handle, PCM_SetLastLogMsg, 0, cardinal(s));
        FreeStr(s);
        result := Py_None;
        Py_INCREF(Py_None);
      end;
    end;
  end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
//    LogAllDrives;
end;

end.
