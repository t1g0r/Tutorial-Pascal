object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 211
  ClientWidth = 418
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
    Left = 112
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Start Copy'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ZConnection1: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    HostName = 'localhost'
    Port = 0
    Database = 'test'
    User = 'root'
    Password = 'root'
    Protocol = 'mysql'
    LibraryLocation = 
      'C:\MyStorage\Works\Java Logic Solution\Projects\Tutorial-Pascal\' +
      'SQLBulkCopy\example\Win32\Debug\libmysql32.dll'
    Left = 48
    Top = 24
  end
  object qSource: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 40
    Top = 88
  end
  object ZConnection2: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    HostName = 'localhost'
    Port = 0
    Database = 'test2'
    User = 'root'
    Password = 'root'
    Protocol = 'mysql'
    LibraryLocation = 
      'C:\MyStorage\Works\Java Logic Solution\Projects\Tutorial-Pascal\' +
      'SQLBulkCopy\example\Win32\Debug\libmysql32.dll'
    Left = 240
    Top = 32
  end
  object qDest: TZQuery
    Connection = ZConnection2
    Params = <>
    Left = 232
    Top = 96
  end
end
