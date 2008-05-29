object ScanProgressDlg: TScanProgressDlg
  Left = 315
  Top = 276
  BorderStyle = bsDialog
  Caption = 'Information'
  ClientHeight = 238
  ClientWidth = 313
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 273
    Height = 33
    AutoSize = False
    Caption = 
      'Drive is being scanned for deleted files. This can take several ' +
      'minutes.'
    WordWrap = True
  end
  object PercentLabel: TLabel
    Left = 16
    Top = 168
    Width = 281
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = '[ complete label ]'
  end
  object Label2: TLabel
    Left = 56
    Top = 80
    Width = 241
    Height = 41
    AutoSize = False
    Caption = 
      'It is recommended to wait for scan process completion to maximiz' +
      'e recovery result.'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object Label3: TLabel
    Left = 16
    Top = 80
    Width = 32
    Height = 13
    Caption = 'Note:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 16
    Top = 56
    Width = 239
    Height = 13
    Caption = 'You can close this window, scanning will continue.'
  end
  object CancelBtn: TButton
    Left = 191
    Top = 196
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Close'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object NeverShowCbx: TCheckBox
    Left = 24
    Top = 200
    Width = 129
    Height = 17
    Caption = 'Never show this dialog'
    TabOrder = 1
  end
  object ProgressBar: TProgressBar
    Left = 16
    Top = 144
    Width = 281
    Height = 16
    TabOrder = 2
  end
end
