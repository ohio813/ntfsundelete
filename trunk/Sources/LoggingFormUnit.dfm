object LoggingForm: TLoggingForm
  Left = 280
  Top = 328
  Width = 518
  Height = 341
  BorderStyle = bsSizeToolWin
  Caption = 'Log'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object LogRich: TRichEdit
    Left = 0
    Top = 0
    Width = 510
    Height = 307
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
end
