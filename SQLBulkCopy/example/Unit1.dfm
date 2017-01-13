object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 352
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 40
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Start Copy'
    TabOrder = 0
    OnClick = Button1Click
  end
  object dbconn: TUniConnection
    ProviderName = 'MySQL'
    Database = 'test'
    Username = 'root'
    Server = 'localhost'
    Connected = True
    LoginPrompt = False
    Left = 24
    Top = 24
    EncryptedPassword = '8DFF90FF90FF8BFF'
  end
  object qSource: TUniQuery
    Connection = dbconn
    Left = 64
    Top = 24
  end
  object MySQL: TMySQLUniProvider
    Left = 104
    Top = 24
  end
  object dbconn2: TUniConnection
    ProviderName = 'MySQL'
    Database = 'test2'
    Username = 'root'
    Server = 'localhost'
    Connected = True
    LoginPrompt = False
    Left = 24
    Top = 216
    EncryptedPassword = '8DFF90FF90FF8BFF'
  end
  object qDest: TUniQuery
    Connection = dbconn2
    Left = 72
    Top = 216
  end
end
