object MainForm: TMainForm
  Left = 250
  Top = 111
  Width = 807
  Height = 568
  BiDiMode = bdRightToLeft
  Caption = 'NTFS Undelete'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 799
    Height = 514
    ActivePage = BrowseSheet
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object BrowseSheet: TTabSheet
      Caption = 'Browse'
      object Splitter1: TSplitter
        Left = 262
        Top = 0
        Height = 486
      end
      object DirTree: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 262
        Height = 486
        Align = alLeft
        Header.AutoSizeIndex = -1
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'MS Sans Serif'
        Header.Font.Style = []
        Header.MainColumn = -1
        Header.Options = [hoAutoResize, hoColumnResize, hoDrag]
        HintMode = hmHint
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        TreeOptions.AutoOptions = [toAutoDropExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages, toGhostedIfUnfocused]
        TreeOptions.SelectionOptions = [toRightClickSelect]
        OnBeforeItemPaint = DirTreeBeforeItemPaint
        OnChange = DirTreeChange
        OnChecked = DirTreeChecked
        OnChecking = DirTreeChecking
        OnCompareNodes = DirTreeCompareNodes
        OnGetText = DirTreeGetText
        OnPaintText = DirTreePaintText
        OnGetImageIndex = DirTreeGetImageIndex
        OnGetHint = DirTreeGetHint
        OnGetNodeDataSize = DirTreeGetNodeDataSize
        OnInitNode = DirTreeInitNode
        OnMouseDown = DirTreeMouseDown
        Columns = <>
      end
      object Panel2: TPanel
        Left = 265
        Top = 0
        Width = 526
        Height = 486
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Splitter2: TSplitter
          Left = 0
          Top = 340
          Width = 526
          Height = 3
          Cursor = crVSplit
          Align = alBottom
          Visible = False
        end
        object QuickViewPanel: TPanel
          Left = 0
          Top = 343
          Width = 526
          Height = 143
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
          Visible = False
          object QuickView: TVirtualStringTree
            Left = 0
            Top = 16
            Width = 526
            Height = 127
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Lucida Console'
            Font.Pitch = fpFixed
            Font.Style = []
            Header.AutoSizeIndex = 0
            Header.Font.Charset = DEFAULT_CHARSET
            Header.Font.Color = clWindowText
            Header.Font.Height = -11
            Header.Font.Name = 'MS Sans Serif'
            Header.Font.Style = []
            Header.Options = [hoColumnResize, hoDrag, hoVisible]
            Header.Style = hsFlatButtons
            Indent = 0
            ParentFont = False
            TabOrder = 0
            TreeOptions.PaintOptions = [toHideFocusRect, toHideSelection, toShowButtons, toShowDropmark, toShowVertGridLines, toThemeAware, toUseBlendedImages, toAlwaysHideSelection]
            OnGetText = QuickViewGetText
            Columns = <
              item
                Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
                Position = 0
                Width = 90
                WideText = 'Address:'
              end
              item
                Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
                Position = 1
                Width = 350
                WideText = 'HEX'
              end
              item
                Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
                Position = 2
                Width = 150
                WideText = 'Text'
              end>
            WideDefaultText = ''
          end
          object Panel4: TPanel
            Left = 0
            Top = 0
            Width = 526
            Height = 16
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object Label6: TLabel
              Left = 0
              Top = 0
              Width = 62
              Height = 16
              Align = alLeft
              Caption = ' Quick view: '
            end
            object QVFileNameLabel: TLabel
              Left = 62
              Top = 0
              Width = 66
              Height = 16
              Align = alLeft
              Caption = ' not available '
            end
          end
        end
        object ContentsList: TVirtualStringTree
          Left = 0
          Top = 0
          Width = 526
          Height = 340
          Align = alClient
          Header.AutoSizeIndex = 0
          Header.Font.Charset = DEFAULT_CHARSET
          Header.Font.Color = clWindowText
          Header.Font.Height = -11
          Header.Font.Name = 'MS Sans Serif'
          Header.Font.Style = []
          Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
          Header.PopupMenu = ColumnsMenu
          Header.SortColumn = 0
          Header.Style = hsFlatButtons
          HintMode = hmHint
          Indent = 0
          LineMode = lmBands
          LineStyle = lsCustomStyle
          ParentShowHint = False
          PopupMenu = PopupMenu1
          ShowHint = True
          TabOrder = 1
          TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toGhostedIfUnfocused]
          TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
          OnChange = ContentsListChange
          OnChecked = ContentsListChecked
          OnChecking = ContentsListChecking
          OnCompareNodes = ContentsListCompareNodes
          OnDblClick = ContentsListDblClick
          OnGetText = ContentsListGetText
          OnPaintText = ContentsListPaintText
          OnGetImageIndex = ContentsListGetImageIndex
          OnGetHint = DirTreeGetHint
          OnGetNodeDataSize = ContentsListGetNodeDataSize
          OnHeaderClick = ContentsListHeaderClick
          OnInitNode = ContentsListInitNode
          OnKeyDown = ContentsListKeyDown
          Columns = <
            item
              Position = 0
              Width = 300
              WideText = 'Name'
            end
            item
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
              Position = 1
              Width = 70
              WideText = 'Date Created'
            end
            item
              Position = 2
              Width = 90
              WideText = 'Date Modified'
            end
            item
              Alignment = taRightJustify
              Position = 3
              Width = 70
              WideText = 'Size'
            end
            item
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
              Position = 4
              WideText = 'MFT Ref.'
            end
            item
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
              Position = 5
              WideText = 'Data Streams'
            end>
        end
      end
    end
    object SearchSheet: TTabSheet
      Caption = 'Search'
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 321
        Height = 486
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 8
          Top = 18
          Width = 47
          Height = 13
          Caption = 'File mask:'
        end
        object Label7: TLabel
          Left = 8
          Top = 50
          Width = 38
          Height = 13
          Caption = 'Look in:'
        end
        object SearchActionLabel: TLabel
          Left = 16
          Top = 368
          Width = 121
          Height = 49
          AutoSize = False
          Caption = '[ search action label ]'
          WordWrap = True
        end
        object SearchMaskCombo: TComboBox
          Left = 72
          Top = 16
          Width = 233
          Height = 21
          ItemHeight = 0
          TabOrder = 0
          Text = '*.*'
          Items.Strings = (
            '*.*'
            '*.doc, *.xls, *.ppt'
            '*.mdb, *.gdb, *.dbf, *.db, *.btr'
            '*.nrg, *.iso'
            '*.exe, *.dll, *.sys'
            '*.jp*, *.gif, *.tiff, *.bmp, *.pcx'
            '*.mp3, *.mp4, *.mpeg, *.avi, *.divx'
            '*.sln, *.vcproj, *.c*, *.h*, *.rc, *.pas, *.dpr, *.py')
        end
        object LocationCb: TComboBox
          Left = 72
          Top = 48
          Width = 233
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 1
        end
        object AdvancedSearchPanel: TPanel
          Left = 8
          Top = 136
          Width = 305
          Height = 177
          BevelOuter = bvNone
          TabOrder = 2
          Visible = False
          object Label2: TLabel
            Left = 27
            Top = 75
            Width = 26
            Height = 13
            Caption = 'From:'
            Enabled = False
          end
          object Label3: TLabel
            Left = 27
            Top = 101
            Width = 16
            Height = 13
            Caption = 'To:'
            Enabled = False
          end
          object Label4: TLabel
            Left = 171
            Top = 77
            Width = 26
            Height = 13
            Caption = 'From:'
            Enabled = False
          end
          object Label5: TLabel
            Left = 171
            Top = 99
            Width = 16
            Height = 13
            Caption = 'To:'
            Enabled = False
          end
          object cbxCaseSens: TCheckBox
            Left = 8
            Top = 0
            Width = 97
            Height = 17
            Caption = 'Case sensitive'
            TabOrder = 0
          end
          object cbxSrchFolds: TCheckBox
            Left = 112
            Top = 0
            Width = 97
            Height = 17
            Caption = 'Folders'
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
          object cbxSrchFiles: TCheckBox
            Left = 112
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Files'
            Checked = True
            State = cbChecked
            TabOrder = 2
          end
          object cbxDeletedEntries: TCheckBox
            Left = 8
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Deleted entries'
            Checked = True
            State = cbChecked
            TabOrder = 3
          end
          object cbxNonDeletedEntries: TCheckBox
            Left = 8
            Top = 32
            Width = 113
            Height = 17
            Caption = 'Non-deleted entries'
            TabOrder = 4
          end
          object cbxModification: TCheckBox
            Left = 8
            Top = 56
            Width = 97
            Height = 17
            Caption = 'Date Modified:'
            TabOrder = 5
            OnClick = cbxModificationClick
          end
          object dtpModifyFrom: TDateTimePicker
            Left = 59
            Top = 73
            Width = 89
            Height = 21
            Date = 0.665341064806853000
            Time = 0.665341064806853000
            Enabled = False
            TabOrder = 6
          end
          object dtpModifyTo: TDateTimePicker
            Left = 59
            Top = 97
            Width = 89
            Height = 21
            Date = 39080.665992476840000000
            Time = 39080.665992476840000000
            Enabled = False
            TabOrder = 7
          end
          object cbxCreated: TCheckBox
            Left = 152
            Top = 56
            Width = 97
            Height = 17
            Caption = 'Date Created:'
            TabOrder = 8
            OnClick = cbxCreatedClick
          end
          object dtpCreateFrom: TDateTimePicker
            Left = 211
            Top = 72
            Width = 89
            Height = 21
            Date = 39080.667271585640000000
            Time = 39080.667271585640000000
            Enabled = False
            TabOrder = 9
          end
          object dtpCreateTo: TDateTimePicker
            Left = 211
            Top = 101
            Width = 89
            Height = 21
            Date = 39080.667380636570000000
            Time = 39080.667380636570000000
            Enabled = False
            TabOrder = 10
          end
          object cbxSizeFrom: TCheckBox
            Left = 8
            Top = 128
            Width = 65
            Height = 17
            Caption = 'Size from:'
            TabOrder = 11
            OnClick = cbxSizeFromClick
          end
          object cbxSizeTo: TCheckBox
            Left = 8
            Top = 152
            Width = 73
            Height = 17
            Caption = 'Size up to:'
            TabOrder = 12
            OnClick = cbxSizeToClick
          end
          object SizeToEdit: TEdit
            Left = 88
            Top = 148
            Width = 73
            Height = 21
            Enabled = False
            TabOrder = 13
            Text = '0'
          end
          object SizeFromEdit: TEdit
            Left = 88
            Top = 124
            Width = 73
            Height = 21
            Enabled = False
            TabOrder = 14
            Text = '0'
          end
          object SizeFromRB: TComboBox
            Left = 168
            Top = 124
            Width = 49
            Height = 21
            Style = csDropDownList
            Enabled = False
            ItemHeight = 0
            ItemIndex = 0
            TabOrder = 15
            Text = 'Bytes'
            Items.Strings = (
              'Bytes'
              'KB'
              'MB'
              'GB')
          end
          object SizeToRB: TComboBox
            Left = 168
            Top = 148
            Width = 49
            Height = 21
            Style = csDropDownList
            Enabled = False
            ItemHeight = 0
            ItemIndex = 0
            TabOrder = 16
            Text = 'Bytes'
            Items.Strings = (
              'Bytes'
              'KB'
              'MB'
              'GB')
          end
        end
        object rbSimpleSearch: TRadioButton
          Left = 8
          Top = 80
          Width = 113
          Height = 17
          Caption = 'Simple search'
          Checked = True
          TabOrder = 3
          TabStop = True
          OnClick = rbAdvancedSearchClick
        end
        object rbAdvancedSearch: TRadioButton
          Left = 8
          Top = 120
          Width = 113
          Height = 17
          Caption = 'Advanced search'
          TabOrder = 4
          OnClick = rbAdvancedSearchClick
        end
        object cbSimpleSearchOnlyDeletedFiles: TCheckBox
          Left = 16
          Top = 96
          Width = 193
          Height = 17
          Caption = 'Search only deleted files and folders'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object SearchButton: TButton
          Left = 104
          Top = 328
          Width = 75
          Height = 25
          Action = ActionSearch
          Default = True
          TabOrder = 6
        end
      end
      object Panel3: TPanel
        Left = 321
        Top = 0
        Width = 470
        Height = 486
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel3'
        TabOrder = 1
        object Splitter3: TSplitter
          Left = 0
          Top = 340
          Width = 470
          Height = 3
          Cursor = crVSplit
          Align = alBottom
        end
        object QuickViewSPanel: TPanel
          Left = 0
          Top = 343
          Width = 470
          Height = 143
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
          Visible = False
          object QuickViewS: TVirtualStringTree
            Left = 0
            Top = 16
            Width = 470
            Height = 127
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Lucida Console'
            Font.Pitch = fpFixed
            Font.Style = []
            Header.AutoSizeIndex = 0
            Header.Font.Charset = DEFAULT_CHARSET
            Header.Font.Color = clWindowText
            Header.Font.Height = -11
            Header.Font.Name = 'MS Sans Serif'
            Header.Font.Style = []
            Header.Options = [hoColumnResize, hoDrag, hoVisible]
            Header.Style = hsFlatButtons
            Indent = 0
            ParentFont = False
            TabOrder = 0
            TreeOptions.PaintOptions = [toHideFocusRect, toHideSelection, toShowButtons, toShowDropmark, toShowVertGridLines, toThemeAware, toUseBlendedImages, toAlwaysHideSelection]
            OnGetText = QuickViewSGetText
            Columns = <
              item
                Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
                Position = 0
                Width = 90
                WideText = 'Address:'
              end
              item
                Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
                Position = 1
                Width = 350
                WideText = 'HEX'
              end
              item
                Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
                Position = 2
                Width = 150
                WideText = 'Text'
              end>
            WideDefaultText = ''
          end
          object Panel10: TPanel
            Left = 0
            Top = 0
            Width = 470
            Height = 16
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object Label11: TLabel
              Left = 0
              Top = 0
              Width = 62
              Height = 13
              Align = alLeft
              Caption = ' Quick view: '
            end
            object QVSFileNameLabel: TLabel
              Left = 62
              Top = 0
              Width = 66
              Height = 13
              Align = alLeft
              Caption = ' not available '
            end
          end
        end
        object SearchList: TVirtualStringTree
          Left = 0
          Top = 0
          Width = 470
          Height = 340
          Align = alClient
          Header.AutoSizeIndex = 0
          Header.Font.Charset = DEFAULT_CHARSET
          Header.Font.Color = clWindowText
          Header.Font.Height = -11
          Header.Font.Name = 'MS Sans Serif'
          Header.Font.Style = []
          Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
          Header.PopupMenu = ColumnsMenu
          Header.SortColumn = 0
          Header.Style = hsFlatButtons
          Indent = 0
          PopupMenu = PopupMenu1
          StateImages = ImageList1
          TabOrder = 1
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toGhostedIfUnfocused]
          TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
          OnChange = SearchListChange
          OnChecked = SearchListChecked
          OnChecking = ContentsListChecking
          OnCompareNodes = ContentsListCompareNodes
          OnGetText = ContentsListGetText
          OnGetImageIndex = ContentsListGetImageIndex
          OnGetNodeDataSize = ContentsListGetNodeDataSize
          OnHeaderClick = SearchListHeaderClick
          OnInitNode = SearchListInitNode
          Columns = <
            item
              Position = 0
              Width = 200
              WideText = 'Name'
            end
            item
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
              Position = 1
              Width = 70
              WideText = 'Create date'
            end
            item
              Position = 2
              Width = 70
              WideText = 'Modify date'
            end
            item
              Position = 3
              Width = 70
              WideText = 'Size'
            end
            item
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
              Position = 4
              Width = 70
              WideText = 'MFT ref'
            end
            item
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
              Position = 5
              WideText = 'Data streams'
            end
            item
              Position = 6
              Width = 300
              WideText = 'Path'
            end>
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Recover marked files'
      ImageIndex = 3
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 313
        Height = 494
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Label8: TLabel
          Left = 8
          Top = 8
          Width = 85
          Height = 13
          Caption = 'Destination folder:'
        end
        object CBXRecoveryFolder: TComboBox
          Left = 8
          Top = 24
          Width = 265
          Height = 21
          ItemHeight = 0
          TabOrder = 0
        end
        object RecoveryBrowseFolderButton: TButton
          Left = 280
          Top = 24
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = RecoveryBrowseFolderButtonClick
        end
        object GroupBox1: TGroupBox
          Left = 8
          Top = 56
          Width = 289
          Height = 57
          Caption = 'If file exists: '
          TabOrder = 2
          object RBAutorenameIfExist: TRadioButton
            Left = 8
            Top = 16
            Width = 113
            Height = 17
            Caption = 'Autorename'
            TabOrder = 0
          end
          object RBAskForName: TRadioButton
            Left = 8
            Top = 32
            Width = 113
            Height = 17
            Caption = 'Ask for new name'
            Checked = True
            TabOrder = 1
            TabStop = True
          end
          object RBSkipThoseFiles: TRadioButton
            Left = 128
            Top = 16
            Width = 113
            Height = 17
            Caption = 'Skip'
            TabOrder = 2
          end
          object RBOverwrite: TRadioButton
            Left = 128
            Top = 32
            Width = 113
            Height = 17
            Caption = 'Overwrite'
            TabOrder = 3
          end
        end
        object GroupBox2: TGroupBox
          Left = 8
          Top = 120
          Width = 289
          Height = 73
          Caption = ' Recovery options: '
          TabOrder = 3
          object CBRecoverFolderStructure: TCheckBox
            Left = 8
            Top = 16
            Width = 145
            Height = 17
            Caption = 'Recover folder structure'
            Checked = True
            State = cbChecked
            TabOrder = 0
          end
          object CBRecoverAllDataStreams: TCheckBox
            Left = 8
            Top = 32
            Width = 137
            Height = 17
            Caption = 'Recover all data streams'
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
          object CBDeleteUnsuccessful: TCheckBox
            Left = 8
            Top = 48
            Width = 201
            Height = 17
            Caption = 'Do not recover damaged files'
            Checked = True
            State = cbChecked
            TabOrder = 2
          end
        end
        object RecoveryStartButton: TButton
          Left = 16
          Top = 304
          Width = 75
          Height = 25
          Caption = 'Recover'
          Default = True
          TabOrder = 4
          OnClick = RecoveryStartButtonClick
        end
        object RecoverySkipFileButton: TButton
          Left = 104
          Top = 304
          Width = 75
          Height = 25
          Caption = 'Skip file'
          Enabled = False
          TabOrder = 5
          OnClick = RecoverySkipFileButtonClick
        end
        object RecoveryStopButton: TButton
          Left = 192
          Top = 304
          Width = 75
          Height = 25
          Caption = 'Stop'
          Enabled = False
          TabOrder = 6
          OnClick = RecoveryStopButtonClick
        end
        object GroupBox3: TGroupBox
          Left = 8
          Top = 200
          Width = 289
          Height = 73
          Caption = ' Misc options: '
          TabOrder = 7
          object RBUncheckAllProcessed: TRadioButton
            Left = 8
            Top = 32
            Width = 153
            Height = 17
            Caption = 'Unmark all processed files'
            TabOrder = 0
          end
          object RBUnckeckSuccessProcessed: TRadioButton
            Left = 8
            Top = 16
            Width = 201
            Height = 17
            Caption = 'Unmark successfully processed files'
            Checked = True
            TabOrder = 1
            TabStop = True
          end
          object RBDoNotUncheck: TRadioButton
            Left = 8
            Top = 48
            Width = 89
            Height = 17
            Caption = 'Do not unmark'
            TabOrder = 2
          end
        end
        object RecoveryPauseButton: TButton
          Left = 104
          Top = 336
          Width = 75
          Height = 25
          Caption = 'Pause'
          Enabled = False
          TabOrder = 8
          OnClick = RecoveryPauseButtonClick
        end
      end
      object Panel6: TPanel
        Left = 313
        Top = 0
        Width = 478
        Height = 486
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object CurrentFileRecoveryPercentLabel: TLabel
          Left = 0
          Top = 33
          Width = 48
          Height = 13
          Align = alTop
          Alignment = taCenter
          Caption = '[ percent ]'
        end
        object Label10: TLabel
          Left = 0
          Top = 46
          Width = 73
          Height = 13
          Align = alTop
          Caption = 'Total progress: '
        end
        object TotalRecoveryPercentLabel: TLabel
          Left = 0
          Top = 75
          Width = 48
          Height = 13
          Align = alTop
          Alignment = taCenter
          Caption = '[ percent ]'
        end
        object Bevel1: TBevel
          Left = 0
          Top = 146
          Width = 478
          Height = 4
          Align = alTop
          Shape = bsTopLine
        end
        object Label26: TLabel
          Left = 0
          Top = 150
          Width = 66
          Height = 13
          Align = alTop
          Caption = 'Recovery log:'
        end
        object Bevel2: TBevel
          Left = 0
          Top = 163
          Width = 478
          Height = 4
          Align = alTop
          Shape = bsSpacer
        end
        object Panel8: TPanel
          Left = 0
          Top = 0
          Width = 478
          Height = 17
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object CurrentRecoveryFileLabel: TLabel
            Left = 56
            Top = 0
            Width = 61
            Height = 13
            Align = alClient
            Caption = '[ current file ]'
            WordWrap = True
          end
          object Label9: TLabel
            Left = 0
            Top = 0
            Width = 56
            Height = 13
            Align = alLeft
            Caption = 'Current file: '
          end
        end
        object CurrentFileRecoveryProgressBar: TProgressBar
          Left = 0
          Top = 17
          Width = 478
          Height = 16
          Align = alTop
          TabOrder = 1
        end
        object TotalRecoveryProgressBar: TProgressBar
          Left = 0
          Top = 59
          Width = 478
          Height = 16
          Align = alTop
          TabOrder = 2
        end
        object Panel7: TPanel
          Left = 0
          Top = 88
          Width = 478
          Height = 58
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 3
          object Label14: TLabel
            Left = 0
            Top = 8
            Width = 48
            Height = 13
            Caption = 'Total files:'
          end
          object Label15: TLabel
            Left = 0
            Top = 24
            Width = 53
            Height = 13
            Caption = 'Processed:'
          end
          object Label16: TLabel
            Left = 0
            Top = 40
            Width = 53
            Height = 13
            Caption = 'Remaining:'
          end
          object RecoveryTotalFilesLabel: TLabel
            Left = 72
            Top = 8
            Width = 53
            Height = 13
            Caption = '[ total files ]'
          end
          object RecoveryProcessedLabel: TLabel
            Left = 72
            Top = 24
            Width = 82
            Height = 13
            Caption = '[ processed files ]'
          end
          object RecoveryRemainLabel: TLabel
            Left = 72
            Top = 40
            Width = 43
            Height = 13
            Caption = '[ remain ]'
          end
        end
        object RecoveryProtocol: TVirtualStringTree
          Left = 0
          Top = 196
          Width = 478
          Height = 298
          Align = alClient
          Header.AutoSizeIndex = 0
          Header.Font.Charset = DEFAULT_CHARSET
          Header.Font.Color = clWindowText
          Header.Font.Height = -11
          Header.Font.Name = 'MS Sans Serif'
          Header.Font.Style = []
          Header.Options = [hoColumnResize, hoDrag, hoVisible]
          Header.Style = hsFlatButtons
          Indent = 0
          Margin = 0
          TabOrder = 4
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
          TreeOptions.SelectionOptions = [toFullRowSelect]
          OnGetText = RecoveryProtocolGetText
          OnPaintText = RecoveryProtocolPaintText
          Columns = <
            item
              Position = 0
              Width = 29
              WideText = 'N'
            end
            item
              Position = 1
              Width = 60
              WideText = 'Time'
            end
            item
              Position = 2
              Width = 60
              WideText = 'Type'
            end
            item
              Position = 3
              Width = 300
              WideText = 'Message'
            end>
        end
        object ToolBar2: TToolBar
          Left = 0
          Top = 167
          Width = 478
          Height = 29
          ButtonHeight = 19
          ButtonWidth = 73
          EdgeInner = esNone
          EdgeOuter = esNone
          Flat = True
          List = True
          ShowCaptions = True
          TabOrder = 5
          Wrapable = False
          object SaveLogButton: TToolButton
            Left = 0
            Top = 0
            Caption = 'Save log...'
            ImageIndex = 5
            OnClick = SaveLogButtonClick
          end
          object ToolButton1: TToolButton
            Left = 73
            Top = 0
            Enabled = False
            ImageIndex = 4
          end
          object RMessagesFilterButton: TToolButton
            Left = 146
            Top = 0
            Caption = '  Messages '
            Down = True
            Style = tbsCheck
            OnClick = applyRecoveryFilter
          end
          object ToolButton9: TToolButton
            Left = 219
            Top = 0
            Width = 8
            Caption = 'ToolButton9'
            ImageIndex = 4
            Style = tbsDivider
          end
          object RSuccessesFilterButton: TToolButton
            Left = 227
            Top = 0
            Caption = '  Successes '
            Down = True
            ImageIndex = 1
            Style = tbsCheck
            OnClick = applyRecoveryFilter
          end
          object ToolButton12: TToolButton
            Left = 300
            Top = 0
            Width = 8
            Caption = 'ToolButton12'
            ImageIndex = 5
            Style = tbsDivider
          end
          object RWarningsFilterButton: TToolButton
            Left = 308
            Top = 0
            Caption = '  Warnings  '
            Down = True
            ImageIndex = 2
            Style = tbsCheck
            OnClick = applyRecoveryFilter
          end
          object ToolButton13: TToolButton
            Left = 381
            Top = 0
            Width = 8
            Caption = 'ToolButton13'
            ImageIndex = 6
            Style = tbsDivider
          end
          object RErrorsFilterButton: TToolButton
            Left = 389
            Top = 0
            Caption = '  Errors  '
            Down = True
            ImageIndex = 3
            Style = tbsCheck
            OnClick = applyRecoveryFilter
          end
        end
      end
    end
  end
  object ImageList1: TImageList
    Left = 120
    Top = 312
    Bitmap = {
      494C010111001300040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
      0000000000000000000000000000000000000000000000000000000000000000
      0000007F0000005F2000003F0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000009F
      200000BF400000DF200000BF4000007F4000009F200000BF400000BF40000040
      4000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000BF
      400000DF20000080800000808000008080000080800000808000008080000080
      800000606000007F4000007F4000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000BF
      000000FF00000080800000808000006060000060600000808000006060000020
      2000008080000060600000606000004040000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000003F00000000000020
      2000007F400000DF200000808000008080000060600000000000000000000000
      0000000000000000000000000000002020000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000007F0000007F00000000000000
      0000000000000040400000FF0000009F60000080800000606000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000BF0000BF3F0000DF
      2000007F00000000000000202000009F2000009F600000808000006060000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000BF000000
      3F00005F200000DF2000003F00000000000000DF2000009F6000008080000020
      2000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000003F000000DF200000DF200000DF
      2000003F0000003F000000BF4000003F000000BF400000BF4000008080000040
      4000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000005F2000009F6000009F6000009F
      600000DF200000BF0000003F000000DF2000007F000000808000008080000040
      4000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000040400000606000006060000080
      800000808000009F600000DF200000FF0000007F000000808000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000404000008080000080
      8000008080000080800000808000007F40000060600000606000002020000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000007F
      7F00005F5F00007F7F0000606000002020000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007F7F
      7F00007F7F00FF00000000404000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000007F
      7F00003F3F00007F7F0000606000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000020
      2000002020000040400000202000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F5F5F500DDDD
      DD00D1D1D100D1D1D100D1D1D100D1D1D100D1D1D100D1D1D100D1D1D100D1D1
      D100D1D1D100DDDDDD00F5F5F500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FCFCFC00D5D5D5009191
      9100717171007171710071717100717171007171710071717100717171007171
      71007171710095959500DDDDDD0000000000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F0F0F000BC897800BF8B
      7A00BC897900BA867700B7827600B3807400AF7C7200AA796F00A7746D00A370
      6B009E6C690071717100D1D1D10000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF00000000000000000000000000000000000000FF
      FF000000000000FFFF000000000000FFFF000000000000FFFF000000000000FF
      FF000000000000FFFF0000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000C6C6C6000000
      00000084840000000000000000000000000000000000C3C3C300C18E7B00DAB5
      AA00F0C3B800EEC1B700EDBFB300ECBDB200EABBAF00EAB9AD00E8B6AA00E7B5
      A800A06E6A0071717100D1D1D10000000000FFFF000000000000FFFFFF007F7F
      7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F
      7F007F7F7F0000000000FFFF000000000000000000000000000000FFFF000000
      000000FFFF000000000000FFFF000000000000FFFF000000000000FFFF000000
      000000FFFF000000000000FFFF00000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000C6C6C6000000
      000000848400000000000000000000000000000000007FA8D300877EA400D0B0
      B000FFEAD600FFE5CC00FFE3C700FFDFBF00FFDBB800FFD9B200FFD3A800FFD2
      A500A3716B0071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF00000000000000000000000000000000000000FF
      FF000000000000FFFF0000000000000000000000000000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000000000000000
      00000084840000000000000000000000000000000000BCE3FE004D95E0008B80
      A300DBB7B200FFE9D400FFE5CC00FFE2C600FFDFBF00FFDBB800FFD9B200FFD3
      A800A7746D0071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000000000000000000000FFFF000000
      000000FFFF0000000000000000000000000000FFFF000000000000FFFF000000
      000000FFFF000000000000FFFF00000000000000000000000000000000000000
      0000008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000A6C3D7005196
      DF008F81A200DFC2B400D6B2A300D2A89A00E1BBA500F4D1B400FFDBB800FFD9
      B200AB78700071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF00000000000000000000000000000000000000FF
      FF000000000000FFFF000000000000FFFF000000000000FFFF000000000000FF
      FF000000000000FFFF0000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000000000000084
      8400008484000000000000000000000000000000000000000000E2BCA000B0C9
      D600ABABB500CEA99400F6E5BB00FEFDD800EFE2CE00DDBAA500F4D1B300FFDA
      B500AF7C710071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000000000000000000000FFFF000000
      000000000000000000000000000000000000000000000000000000FFFF000000
      000000FFFF000000000000FFFF00000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000008484000000000000000000000000000000000000000000E2BCA000E7D9
      CE00DBB6A600F6E3B700FFF9CA00FFFFEC00FFFFFD00E7D7C300E1BBA500FFDF
      BE00B280730071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF00000000000000000000000000000000000000FF
      FF00000000000000000000000000000000000000000000FFFF000000000000FF
      FF000000000000FFFF0000000000000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000008484000000000000000000000000000000000000000000E2BCA000ECDF
      D400DBBBA500FEE5B300FFF5C500FFFFE700FFFFEC00FEFBD000CEA69600FFE1
      C400B783750071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000000000000000000000FFFF000000
      000000FFFF0000000000000000000000000000FFFF000000000000FFFF000000
      000000FFFF000000000000FFFF00000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000000000000000000000000000000000000000000000000000E2BCA000EFE2
      D800E1C6AF00F6E7C500FFEFC000FFFACB00FFFDD200F6E7B900D5B09F00FFE5
      CC00BA86770071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF00000000000000000000000000000000000000FF
      FF000000000000FFFF000000000000FFFF000000000000FFFF000000000000FF
      FF000000000000FFFF0000000000000000000000000000000000000000000000
      00000084840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C6000000000000000000000000000000000000000000E2BCA000F3E6
      DB00E7D3CA00E9D8CC00F6E7D300FEE8B700F6E1B300D3AC9300EFD4C300FFDA
      C800BD89790071717100D1D1D10000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E2BCA000F6E9
      DE0000000000DCC4BD00D6B9A300DAB89C00D8B09900E7CFC300F3D0C000F2A4
      9E00BF8B7A0080808000D8D8D80000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF00000000000000000000000000000000000000FF
      FF000000000000FFFF000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E2BCA000FAED
      E200000000000000000000000000FFFEFD00FFF9F300FFF6ED009B6B6A009B6B
      6A009B6B6A00AEAEAE00ECECEC0000000000FFFF000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E2BCA000FFF2
      E50000000000000000000000000000000000FFFDFA00FFF9F2009B6B6A00DEA7
      7E00BAA69D00E3E3E300FCFCFC0000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F0C19700ECBD
      9600E6B99600E1B49500DAAF9400D4AB9400CEA69200CAA392009B6B6A00D7C4
      B900ECECEC00FCFCFC000000000000000000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000003009600080098000B00
      990010009B0015009C0019009E001E009F0021009F002500A1002700A1002700
      A1002700A1002500A10000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000300AB000806E9000C08ED00120A
      F100180CF5001D0CF700240DFA00290FFC003011FF003212FF003612FF003813
      FF003813FF003600A50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000600AE000B61FF00126AFF00186F
      FF002075FF00277DFF003083FF00388BFF00408FFF004692FF004D96FF004E98
      FF005199FF004A00A90000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000900B0000F66FF00186FFF002075
      FF00297EFF003084FF003C8DFF004894FF00529AFF005CA0FF0062A5FF0067A7
      FF006AA8FF006200AD00000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000000
      0000000000000000000000000000000000000C00B100146CFF001D73FF00257C
      FF003084FF003F8EFF004D96FF00599FFF0064A6FF0071ACFF007BB3FF0080B5
      FF0087B8FF007B00B000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400000000000000000000000000000000000F00B4001970FF00227AFF002D82
      FF003C8DFF004A95FF00599FFF006AA8FF007AB2FF0089B9FF0096BFFF009DC3
      FF00A2C6FF001500B50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF000000
      0000008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000001200B5001D73FF00277DFF003586
      FF004692FF00589EFF006AA8FF007BB3FF008EBBFF00A1C5FF00B0CCFF00BDD1
      FF00C3D3FF001500B50000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000001500B5002075FF002C80FF003C8D
      FF004E98FF0062A5FF0077AFFF008DBAFF00A2C6FF00B6CEFF00C9D8FF00D9DD
      FF00E1E1FF001500B50000000000000000000000000000000000FFFFFF000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000084848400000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001600B500227AFF003083FF004290
      FF00559DFF006DA9FF0084B6FF009CC1FF00B3CDFF00CED9FF00E1E1FF00E1E1
      FF00E1E1FF001500B50000000000000000000000000000000000FFFFFF000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      0000000000000000000000000000000000001800B500247BFF003285FF004692
      FF005CA0FF0071ACFF008DBAFF00A7C7FF00C3D3FF00E1E1FF00E1E1FF00E1E1
      FF00E1E1FF001500B50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000000000000000000000000000000000C6C6C60000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      0000000000000000000000000000000000001800B500247BFF003285FF004894
      FF005DA1FF0077AFFF0092BCFF00B0CCFF00CED9FF00E1E1FF00E1E1FF00E1E1
      FF00E1E1FF001500B5000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000000000000000000000000000000000C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001600B500227AFF003285FF004692
      FF005DA1FF007AB2FF0096BFFF00B3CDFF00D4DCFF00E1E1FF00E1E1FF00E1E1
      FF00E104DA001500B50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001400B5002075FF003083FF004491
      FF005CA0FF0077AFFF0096BFFF00B3CDFF00D4DCFF00E1E1FF00E1E1FF00E104
      DA001500B500E1E1FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001000B4001D73FF002A7FFF003F8E
      FF00559DFF006EABFF008DBAFF00ADCBFF00CED9FF00E1E1FF00E104DA001500
      B500E1E1FF00E1E1FF0000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000C00B100183DFF002545FF00354D
      FF004A58FF006060FF007A6BFF009273FF00B07DFF00C904D8001500B500E1E1
      FF00E1E1FF00E1E1FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000800B0001200B4001E00B9002C00
      BD003F00C3005500C5006A00CA008401D0009D02D3001500B500E1E1FF00E1E1
      FF00E1E1FF00E1E1FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000982626009D272700A128
      2800A6292900AA2A2A00AD2B2B00B12C2C00B32C2C00B62D2D00B72D2D00B72D
      2D00B72D2D00B62D2D0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF000000000000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF000000000000972534009D426C00A2457000A747
      7500AC4A7900B04B7C00B54D7F00B84F8200BC518500BE528600C0528700C154
      8900C1548900C02F2F0000000000000000000000000000000000000000000000
      0000000000000000000000000000F6F6F600EEEEEE00F4F4F400FDFDFD000000
      000000000000000000000000000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000000000009B263600A1A1A100A7A7A700ACAC
      AC00B2B2B200B7B7B700BCBCBC00C1C1C100C5C5C500C8C8C800CBCBCB00CCCC
      CC00CDCDCD00CA32320000000000000000000000000000000000000000000000
      0000FDFDFD00F1F1F100D9D9D900ABABAB008A8A8A00A3A3A300D0D0D000EDED
      ED00FAFAFA00000000000000000000000000FFFF000000000000FFFFFF007F7F
      7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F
      7F007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF007F7F
      7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F007F7F
      7F007F7F7F0000000000FFFF0000000000009F273700A5A5A500ACACAC00B2B2
      B200B8B8B800BDBDBD00C3C3C300C9C9C900CECECE00D2D2D200D5D5D500D7D7
      D700D8D8D800D535350000000000000000000000000000000000FAFAFA00EDED
      ED00CFCFCF0093939300676767008E848400524D4D004A4A4A005D5D5D008989
      8900C0C0C000E5E5E500F6F6F60000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000A2283800A9A9A900B0B0B000B6B6
      B600BDBDBD00C4C4C400CBCBCB00D1D1D100D6D6D600DBDBDB00DFDFDF00E1E1
      E100E3E3E300DF373700000000000000000000000000EBEBEB00C0C0C0008181
      8100757575008D8D8D00A5A5A500757070003F3C3C00494444005A5252004E4C
      4C005656560072727200A8A8A800DCDCDC00FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000A5293A00ADADAD00B4B4B400BBBB
      BB00C3C3C300CACACA00D1D1D100D8D8D800DEDEDE00E4E4E400E8E8E800EBEB
      EB00EDEDED00E93A3A000000000000000000F1F1F1008989890089898900C9C9
      C900A3A3A30080808000828282007D7C7C004E4E4E00717171007D7D7D00746E
      6E007465650056515100525252007B7B7B00FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000A82A3B00B0B0B000B7B7B700BFBF
      BF00C8C8C800D0D0D000D8D8D800DFDFDF00E6E6E600ECECEC00F1F1F100F5F5
      F500F7F7F700F23C3C000000000000000000A6A6A600AEAEAE00989898008282
      8200A4A4A400B9B9B900D1D1D1008E8E8E00797979006C6C6C00818181006262
      620034343400B79898008A7777006B6B6B00FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000AA2A3B00B2B2B200BABABA00C3C3
      C300CCCCCC00D5D5D500DDDDDD00E5E5E500EDEDED00F3F3F300F9F9F900FDFD
      FD00FFFFFF00FB3E3E000000000000000000A0A0A0009C9C9C00B5B5B500C7C7
      C700E1E1E100E6E6E600D0D0D000D8D8D800D1D1D100C3C3C3009A9999007D78
      78004643430093818100847676007D7D7D00FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000AB2A3B00B4B4B400BCBCBC00C6C6
      C600CFCFCF00D9D9D900E2E2E200EAEAEA00F2F2F200FAFAFA00FFFFFF00FFFF
      FF00FFFFFF00FF3F3F000000000000000000BABABA00D3D3D300DEDEDE00C7C7
      C700E1E1E100DFDFDF00F2F2F200FCFCFC00ECECEC00DFDFDF00F7F7F700EEEA
      EA00DECCCC008F8A8A008D898900E7E7E700FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000AC2A3B00B5B5B500BEBEBE00C8C8
      C800D2D2D200DBDBDB00E5E5E500EEEEEE00F7F7F700FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FF3F3F000000000000000000E3E3E300E0E0E000BBBBBB007979
      79006C6C6C00B8B8B800F2F2F200FCFCFC00ECECEC00DFDFDF00F7F7F700CACA
      CA00C1C1C100CBCBCB00F9F9F90000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000AC2A3B00B5B5B500BEBEBE00C9C9
      C900D3D3D300DDDDDD00E7E7E700F1F1F100FAFAFA00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FF3F3F000000000000000000000000000000000000000000ECEC
      EC00DBDBDB00C8C8C800D5D5D500E6E6E600CDCDCD00D4D4D400D4D4D400FCFC
      FC0000000000000000000000000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000AB2A3B00B4B4B400BEBEBE00C8C8
      C800D3D3D300DEDEDE00E8E8E800F2F2F200FCFCFC00FFFFFF00FFFFFF00FFFF
      FF00FF3F5C00FF3F3F0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000FFFF000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F7F7F0000000000FFFF000000000000A92A3B00B2B2B200BCBCBC00C7C7
      C700D2D2D200DDDDDD00E8E8E800F2F2F200FCFCFC00FFFFFF00FFFFFF00FF3F
      5C00FF3F3F00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF000000000000FFFF000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF000000000000A6293A00B0B0B000B9B9B900C4C4
      C400CFCFCF00DADADA00E5E5E500F0F0F000FAFAFA00FFFFFF00FF3F5C00FF3F
      3F00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF000000000000A2283800AC809C00B688A500BF8F
      AE00CA98B900D4A0C200DEA8CC00E7B0D500F1B7DF00F93E5A00FF3F3F00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF000000000000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000000000009E273700A7293A00B12C3E00BA2E
      4100C4304600CF334800D8354D00E2385200EB3A5500F43C3C00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F6F6F600DFDFDF00D6D6
      D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6
      D600D6D6D600D6D6D600DFDFDF00F6F6F60000000000BDBDFF007474FF005E5E
      FF005E5EFF005E5EFF005E5EFF005E5EFF005E5EFF005E5EFF005E5EFF005E5E
      FF005E5EFF005E5EFF007474FF00BDBDFF0000000000F5F5F500DDDDDD00D1D1
      D100D1D1D100D1D1D100D1D1D100D1D1D100D1D1D100D1D1D100D1D1D100D1D1
      D100D1D1D100DDDDDD00F5F5F5000000000000000000BCBDFF007074FF005258
      FF005258FF005258FF005258FF005258FF005258FF005258FF005258FF005258
      FF005258FF007074FF00BCBDFF0000000000F6F6F600C8C8C800838383006D6D
      6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D
      6D006D6D6D006D6D6D0083838300C8C8C800BDBDFF003F3FFF000000FF000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000FF003F3FFF00F5F5F500C5C5C500898989007171
      7100717171007171710071717100717171007171710071717100717171007171
      71007171710089898900C5C5C500F5F5F500BCBDFF00393FFF000000EA000000
      D4000000D4000000D4000000D4000000D4000000D4000000D4000000D4000000
      D4000000D4000000EA00393FFF00BCBDFF00DFDFDF001D82B5001B81B300187E
      B000167CAE001379AB001076A8000D73A5000B71A300086EA000066C9E00046A
      9C0002689A00016799004C4C4C00838383007474FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000DA000000FF00DDDDDD000D73A5000D73A5000D73
      A5000D73A5000D73A5000D73A5000D73A5000D73A5000D73A5000D73A5000D73
      A5000D73A5006565650089898900DDDDDD007074FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000C7000000EA007074FF002287BA0067CCFF002085B80099FF
      FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4
      FF003BA0D30099FFFF00016799006E6E6E000000FF000047FF000000FF0000E1
      FF000059FF000059FF000059FF000059FF000059FF000059FF000059FF000059
      FF000005FF0000E1FF000000FF000000F900199AC6001C9CC7009CFFFF006CD7
      FF006CD7FF006CD7FF006CD7FF006CD7FF006CD7FF006CD7FF006CD7FF006CD7
      FF002999BF000D73A50071717100D1D1D1000004FF000005FF0002E1FF000066
      FF000066FF000066FF000066FF000066FF000066FF000066FF000066FF000066
      FF000003FF000000FF000000D4005258FF00258ABD0067CCFF00278CBF0099FF
      FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0
      FF0044A9DC0099FFFF0002689A006D6D6D000000FF000047FF000000FF0000E1
      FF000079FF000079FF000079FF000079FF000079FF000079FF000079FF000079
      FF00000EFF0000E1FF000000FF000000F800199AC6001A9AC6007AE4F0009CFF
      FF007CE3FF007CE3FF007CE3FF007CE3FF007CE3FF007CE3FF007CE3FF007CDF
      FF0043B2DE001A7B9D0065656500B9B9B9000004FF000004FF000089FF0002E1
      FF000085FF000085FF000085FF000085FF000085FF000085FF000085FF00007B
      FF00001FFF000000FB000000C7002329FF00288DC00067CCFF002D92C50099FF
      FF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EB
      FF004EB3E60099FFFF00046A9C006D6D6D000000FF000047FF000000FF0000E1
      FF000099FF000099FF000099FF000099FF000099FF000099FF000099FF000099
      FF00001AFF0000E1FF000000FF000000F800199AC60026A2CF0040B8D7009CFF
      FF0084EBFF0084EBFF0084EBFF0084EBFF0084EBFF0084EBFF0084EBFF0084E7
      FF0043BAEF00199AC60065656500898989000004FF00000BFF000027FF0002E1
      FF00009DFF00009DFF00009DFF00009DFF00009DFF00009DFF00009DFF000092
      FF00002AFF000004FF000000C7000000EA002A8FC20067CCFF003398CB0099FF
      FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7
      FF0057BCEF0099FFFF00066C9E006D6D6D000000FF000047FF000000FF0000E1
      FF0000C2FF0000C2FF0000C2FF0000C2FF0000C2FF0000C2FF0000C2FF0000C2
      FF000028FF0000E1FF000000FF000000F800199AC60043B3E20021A0C900A5FF
      FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7
      FF0053BEE7005CBCCE000D73A500717171000004FF000020FF000009FF0009E1
      FF0000C3FF0000C3FF0000C3FF0000C3FF0000C3FF0000C3FF0000C3FF0000C3
      FF000031FF00002FFF000000FF000000D4002D92C5006FD4FF003499CC0099FF
      FF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FF
      FF0060C5F80099FFFF00086EA0006E6E6E000000FF000059FF000000FF0000E1
      FF0000E1FF0000E1FF0000E1FF0000E1FF0000E1FF0000E1FF0000E1FF0000E1
      FF000039FF0000E1FF000000FF000000F900199AC60070D5FD00199AC60089F0
      F7009CFFFF009CFFFF009CFFFF009CFFFF009CFFFF009CFFFF009CFFFF009CFF
      FF005BC7FF0096F9FB00197B9B00717171000004FF000062FF000004FF0000AD
      FF0002E1FF0002E1FF0002E1FF0002E1FF0002E1FF0002E1FF0002E1FF0002E1
      FF000042FF0000C9FF000000FA000000D4002F94C7007BE0FF002D92C5000000
      0000000000000000000000000000000000000000000000000000000000000000
      000081E6FF00000000000B71A3008C8C8C000000FF000079FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008BFF00000000000000FF000000FF00199AC60084D7FF00199AC6006CBF
      DA000000000000000000F7FBFF00000000000000000000000000000000000000
      000084E7FF0000000000197EA100898989000004FF000066FF000004FF000032
      FF000000000000000000C2D3FF00000000000000000000000000000000000000
      00000092FF00000000000000FF000000EA003196C90085EBFF0081E6FF002D92
      C5002D92C5002D92C5002D92C5002D92C5002D92C500288DC0002489BC002085
      B8001C81B4001B81B3001B81B300DFDFDF000000FF000099FF00008BFF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF007474FF00199AC60084EBFF0050C1E200199A
      C600199AC600199AC600199AC600199AC600199AC600199AC600199AC600199A
      C600199AC600199AC6001989B100C5C5C5000004FF00009DFF000037FF000004
      FF000004FF000004FF000004FF000004FF000004FF000004FF000004FF000004
      FF000004FF000004FF000000FF00393FFF003398CB0091F7FF008EF4FF008EF4
      FF008EF4FF008EF4FF008EF4FF00000000000000000000000000000000000000
      0000167CAE008C8C8C00DEDEDE00000000000000FF0000C2FF0000B8FF0000B8
      FF0000B8FF0000B8FF0000B8FF00000000000000000000000000000000000000
      00000000FF000000FF007373FF0000000000199AC6009CF3FF008CF3FF008CF3
      FF008CF3FF008CF3FF008CF3FF00000000000000000000000000000000000000
      0000199AC6001A7B9D00C5C5C500F5F5F5000004FF0002B6FF0000B6FF0000B6
      FF0000B6FF0000B6FF0000B6FF00000000000000000000000000000000000000
      00000004FF000000FB00393FFF00BCBDFF003499CC000000000099FFFF0099FF
      FF0099FFFF0099FFFF0000000000258ABD002287BA001F84B7001D82B5001B81
      B300187EB000DFDFDF00F7F7F700000000000000FF000000000000E1FF0000E1
      FF0000E1FF0000E1FF00000000000000FF000000FF000000FF000000FF000000
      FF000000FF007474FF00C2C2FF0000000000199AC600000000009CFFFF009CFF
      FF009CFFFF009CFFFF0000000000199AC600199AC600199AC600199AC600199A
      C600199AC600DDDDDD00F5F5F500000000000004FF000000000002E1FF0002E1
      FF0002E1FF0002E1FF00000000000004FF000004FF000004FF000004FF000004
      FF000004FF007074FF00BCBDFF0000000000000000003499CC00000000000000
      000000000000000000002A8FC200C8C8C800F6F6F60000000000000000000000
      000000000000000000000000000000000000000000000000FF00000000000000
      000000000000000000000000FF003F3FFF00BDBDFF0000000000000000000000
      0000000000000000000000000000000000000000000022A2CE00000000000000
      00000000000000000000199AC600C5C5C500F5F5F50000000000000000000000
      00000000000000000000000000000000000000000000000BFF00000000000000
      000000000000000000000004FF00393FFF00BCBDFF0000000000000000000000
      00000000000000000000000000000000000000000000000000003499CC003398
      CB003196C9002F94C700DFDFDF00F6F6F6000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF007474FF00BDBDFF000000000000000000000000000000
      000000000000000000000000000000000000000000000000000022A2CE0022A2
      CE0022A2CE0022A2CE00DDDDDD00F5F5F5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000BFF00000B
      FF00000BFF00000BFF007074FF00BCBDFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF00E01F000000000000C001000000000000
      C000000000000000C000000000000000A010000000000000001E000000000000
      800F000000000000800F000000000000000F000000000000000F000000000000
      000F000000000000001F000000000000C03F000000000000C0FF000000000000
      C0FF000000000000E1FF000000000000FF7EC001FFFFFFFFBFFF800100018000
      F00380010001AAAAE003800100019554E00380011FF1A80AE00380011FF19554
      E003C0011931A8AA2003C00119319054E002C0011931A8AAE003C00119319554
      E003C0011931AAAAE003C0011FF18001E003C8011FF1CA7FFFFFCE010001E0FF
      BF7DCF010001FFFF7F7EC0030001FFFF8003FFFFFFFFFFFF0003FFFFFE49FFFF
      000307C1FE49001F000307C1FFFF000F000307C1FFFF000700030101C7C70003
      00030001C7C7000100030001C387000000030001C007001F00038003C007001F
      0003C107C007001F0003C107C0078FF10003E38FC007FFF90003E38FF39FFF75
      0003E38FF39FFF8F0003FFFFF39FFFFFFFFFFFFFFFFF8003FFFF000100010003
      FE1F000100010003F007000100010003C0011FF11FF1000380001DF11FF10003
      00001CF11831000300001C711831000300001C311831000300001C7118310003
      00011CF118310003E00F1DF11FF10003FFFF1FF11FF10003FFFF000100010003
      FFFF000100010003FFFF000100010003FFFFFFFFFFFFFFFF8000800080018001
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000001FF41FF40DF40DF4
      000000000000000001F101F101F001F04201420142014201BC7FBC7FBC7FBC7F
      C0FFC0FFC0FFC0FFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object VFSManager1: TVFSManager
    OnDirAddNewEntry = VFSManager1DirAddNewEntry
    OnChangeNotification = VFSManager1ChangeNotification
    OnMoveEntry = VFSManager1MoveEntry
    OnSearchResult = VFSManager1SearchResult
    Left = 88
    Top = 312
  end
  object MainMenu1: TMainMenu
    Images = ImageList1
    Left = 24
    Top = 312
    object File1: TMenuItem
      Caption = '&File'
      object SaveAs1: TMenuItem
        Action = ActionSaveAs
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = ActionExit
      end
    end
    object ViewMenu: TMenuItem
      Caption = '&View'
      object Columns1: TMenuItem
        Caption = 'Columns'
        object ActionViewNameColumn1: TMenuItem
          Action = ActionViewNameColumn
        end
        object ActionViewCreatedateColumn1: TMenuItem
          Action = ActionViewCreatedateColumn
        end
        object ActionViewModifyDateColumn1: TMenuItem
          Action = ActionViewModifyDateColumn
        end
        object ActionViewSizeColumn1: TMenuItem
          Action = ActionViewSizeColumn
        end
        object Goto1: TMenuItem
          Action = ActionViewMFTRefColumn
        end
        object ActionViewDataStreamsColumn1: TMenuItem
          Action = ActionViewDataStreamsColumn
        end
        object ActionViewPathColumn1: TMenuItem
          Action = ActionViewPathColumn
        end
      end
      object Quickview1: TMenuItem
        Action = ActionViewQuickView
        Caption = 'Hex Preview'
      end
      object ActionFilterDeletedFiles1: TMenuItem
        Action = ActionFilterDeletedFiles
      end
    end
    object Actions1: TMenuItem
      Caption = 'Actions'
      object Clearselection1: TMenuItem
        Action = ActionMarkAll
      end
      object Markselected1: TMenuItem
        Action = ActionMarkSelected
      end
      object Selectall1: TMenuItem
        Action = ActionSelectAll
      end
      object Unmarkall1: TMenuItem
        Action = ActionUnmarkAll
      end
      object ActionUnmarkSelected1: TMenuItem
        Action = ActionUnmarkSelected
      end
      object N5: TMenuItem
        Caption = '-'
        Visible = False
      end
      object Properties3: TMenuItem
        Action = ActionProperties
        Visible = False
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object miHomePage: TMenuItem
        Caption = 'NTFS Undelete Home Page...'
        OnClick = miHomePageClick
      end
      object Viewlog1: TMenuItem
        Action = ActionViewLogging
        Caption = 'Application log...'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object miAbout: TMenuItem
        Caption = 'About...'
        OnClick = miAboutClick
      end
    end
  end
  object MainActionList: TActionList
    Images = ImageList1
    OnUpdate = MainActionListUpdate
    Left = 56
    Top = 312
    object ActionExit: TFileExit
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit|Quits the application'
      ImageIndex = 43
    end
    object ActionProperties: TAction
      Category = 'File'
      Caption = 'Properties'
      OnExecute = ActionPropertiesExecute
    end
    object ActionSaveAs: TAction
      Category = 'File'
      Caption = 'Save as...'
      ImageIndex = 12
      OnExecute = ActionSaveAsExecute
    end
    object ActionSearch: TAction
      Category = 'Search'
      Caption = 'Search ...'
      Hint = 'Search files by mask'
      ImageIndex = 9
      OnExecute = ActionSearchExecute
    end
    object ActionSelectAll: TAction
      Caption = 'Select all'
      ShortCut = 16449
      OnExecute = ActionSelectAllExecute
    end
    object ActionMarkAll: TAction
      Caption = 'Mark all'
      ShortCut = 16416
      OnExecute = ActionMarkAllExecute
    end
    object ActionMarkSelected: TAction
      Caption = 'Mark selected'
      ShortCut = 8224
      OnExecute = ActionMarkSelectedExecute
    end
    object ActionUnmarkAll: TAction
      Caption = 'Unmark all'
      ShortCut = 16469
      OnExecute = ActionUnmarkAllExecute
    end
    object ActionUnmarkSelected: TAction
      Caption = 'Unmark selected'
      ShortCut = 8277
      OnExecute = ActionUnmarkSelectedExecute
    end
    object ActionStopCurrentTask: TAction
      Caption = 'Stop current task'
      Hint = 'Stop current task'
      ImageIndex = 6
    end
    object ActionPauseCurrentTask: TAction
      Caption = 'Pause task'
      Hint = 'Pause current task'
      ImageIndex = 14
    end
    object ActionResumeCurrentTask: TAction
      Caption = 'ActionResumeCurrentTask'
      Hint = 'Resume current task'
      ImageIndex = 5
    end
    object ActionUpFolder: TAction
      Caption = 'Level up'
      ImageIndex = 15
    end
    object ActionExecuteScript: TAction
      Caption = 'Execute script ...'
      ImageIndex = 16
      ShortCut = 32837
      OnExecute = ActionExecuteScriptExecute
    end
    object ActionCancelSearch: TAction
      Category = 'Search'
      Caption = 'Stop search'
      OnExecute = ActionCancelSearchExecute
    end
    object ActionSaveChecked: TAction
      Category = 'File'
      Caption = 'Save checked...'
    end
    object ActionGoTo: TAction
      Category = 'Search'
      Caption = 'Go to'
      ImageIndex = 10
      OnExecute = ActionGoToExecute
    end
    object ActionViewNameColumn: TAction
      Category = 'View'
      Caption = 'Name'
      OnExecute = ActionViewNameColumnExecute
    end
    object ActionViewCreatedateColumn: TAction
      Category = 'View'
      Caption = 'Create date'
      OnExecute = ActionViewCreatedateColumnExecute
    end
    object ActionViewModifyDateColumn: TAction
      Category = 'View'
      Caption = 'Modify date'
      OnExecute = ActionViewModifyDateColumnExecute
    end
    object ActionViewSizeColumn: TAction
      Category = 'View'
      Caption = 'Size'
      OnExecute = ActionViewSizeColumnExecute
    end
    object ActionViewDataStreamsColumn: TAction
      Category = 'View'
      Caption = 'Data streams'
      OnExecute = ActionViewDataStreamsColumnExecute
    end
    object ActionViewPathColumn: TAction
      Category = 'View'
      Caption = 'Path'
      OnExecute = ActionViewPathColumnExecute
    end
    object ActionViewMFTRefColumn: TAction
      Category = 'View'
      Caption = 'MFT ref'
      OnExecute = ActionViewMFTRefColumnExecute
    end
    object ActionViewQuickView: TAction
      Category = 'View'
      Caption = 'Quick view'
      OnExecute = ActionViewQuickViewExecute
    end
    object ActionFilterDeletedFiles: TAction
      Category = 'View'
      Caption = 'Highlight paths with deleted entries'
      Checked = True
      OnExecute = ActionFilterDeletedFilesExecute
    end
    object ActionViewLogging: TAction
      Category = 'View'
      Caption = 'Application log'
      OnExecute = ActionViewLoggingExecute
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 504
    Top = 264
    object PopupGotoMenu: TMenuItem
      Action = ActionGoTo
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object SaveAs2: TMenuItem
      Action = ActionSaveAs
    end
    object Markall1: TMenuItem
      Action = ActionMarkAll
    end
    object Markselected2: TMenuItem
      Action = ActionMarkSelected
    end
    object Selectall2: TMenuItem
      Action = ActionUnmarkAll
    end
    object Unmarkselected1: TMenuItem
      Action = ActionUnmarkSelected
    end
    object Selectall3: TMenuItem
      Action = ActionSelectAll
    end
    object N2: TMenuItem
      Caption = '-'
      Visible = False
    end
    object Properties1: TMenuItem
      Action = ActionProperties
      Visible = False
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 392
    Top = 264
    object Properties2: TMenuItem
      Action = ActionProperties
    end
  end
  object SaveFileDlg: TSaveDialog
    Left = 152
    Top = 312
  end
  object RecentScripts: TPopupMenu
    Images = ImageList1
    Left = 452
    Top = 266
    object ExecuteScriptMenuItem: TMenuItem
      Action = ActionExecuteScript
      Default = True
    end
    object N6: TMenuItem
      Caption = '-'
    end
  end
  object appMod: TPythonModule
    OnInitialization = appModInitialization
    ModuleName = 'app'
    Errors = <>
    Left = 20
    Top = 274
  end
  object PyVFSEntryType: TPythonType
    OnInitialization = PyVFSEntryTypeInitialization
    TypeName = 'PyVFSEntry'
    Prefix = 'Create'
    Module = appMod
    Services.Basic = [bsGetAttr, bsSetAttr, bsRepr, bsStr]
    Services.InplaceNumber = []
    Services.Number = []
    Services.Sequence = []
    Services.Mapping = []
    Left = 52
    Top = 274
  end
  object OpenScriptDlg: TOpenDialog
    DefaultExt = '*.py'
    Filter = 'Python scripts|*.py'
    Left = 84
    Top = 274
  end
  object SearchNotifyTimer: TTimer
    Enabled = False
    OnTimer = SearchNotifyTimerTimer
    Left = 116
    Top = 274
  end
  object ilOverlays: TImageList
    Left = 32
    Top = 352
    Bitmap = {
      494C010101000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000080000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF00000080000000
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000FF00000080000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      80000000FF000000000000000000000000000000000000000000000000000000
      FF00000080000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF00000080000000FF00000000000000000000000000000000000000FF000000
      80000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF00000080000000FF0000000000000000000000FF00000080000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF00000080000000FF000000FF00000080000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF0000008000000080000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF0000008000000080000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF00000080000000FF000000FF00000080000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF00000080000000FF0000000000000000000000FF00000080000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF00000080000000FF00000000000000000000000000000000000000FF000000
      80000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      80000000FF000000000000000000000000000000000000000000000000000000
      FF00000080000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF00000080000000
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000FF00000080000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000080000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF0000000000009FF9000000000000
      8FF1000000000000C7E3000000000000E3C7000000000000F18F000000000000
      F81F000000000000FC3F000000000000FC3F000000000000F81F000000000000
      F18F000000000000E3C7000000000000C7E30000000000008FF1000000000000
      9FF9000000000000FFFF00000000000000000000000000000000000000000000
      000000000000}
  end
  object ColumnsMenu: TPopupMenu
    Left = 152
    Top = 274
    object ColumnNameItem: TMenuItem
      Action = ActionViewNameColumn
    end
    object ColumnCreatedateItem: TMenuItem
      Action = ActionViewCreatedateColumn
      Caption = 'Date Created'
    end
    object ColumnModifydateItem: TMenuItem
      Action = ActionViewModifyDateColumn
      Caption = 'Date Modified'
    end
    object ColumnSizeItem: TMenuItem
      Action = ActionViewSizeColumn
    end
    object ColumnMFTrefItem: TMenuItem
      Action = ActionViewMFTRefColumn
      Caption = 'MFT Ref.'
    end
    object ColumnDatastreamsItem: TMenuItem
      Action = ActionViewDataStreamsColumn
    end
    object ColumnPathItem: TMenuItem
      Action = ActionViewPathColumn
    end
  end
  object SaveRecoveryLogDlg: TSaveDialog
    DefaultExt = '*.log'
    FileName = 'Recovery.log'
    Filter = 'Log files|*.log'
    Left = 188
    Top = 312
  end
  object XPManifest1: TXPManifest
    Left = 480
    Top = 120
  end
  object VFSMgrUpdateTimer: TTimer
    OnTimer = VFSMgrUpdateTimerTimer
    Left = 20
    Top = 240
  end
end
