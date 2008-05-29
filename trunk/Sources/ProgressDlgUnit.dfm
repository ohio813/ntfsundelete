object ProgressDlg: TProgressDlg
  Left = 239
  Top = 268
  BorderStyle = bsDialog
  Caption = 'Dialog'
  ClientHeight = 117
  ClientWidth = 392
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object ActionLabel: TLabel
    Left = 16
    Top = 16
    Width = 102
    Height = 13
    Caption = '[ current action label ]'
  end
  object CancelBtn: TButton
    Left = 159
    Top = 76
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
    OnClick = CancelBtnClick
  end
  object ProgressBar: TProgressBar
    Left = 16
    Top = 40
    Width = 361
    Height = 16
    TabOrder = 1
  end
end
