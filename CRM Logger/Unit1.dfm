object ServerLogger: TServerLogger
  Left = 0
  Top = 0
  Caption = 'ServerLogger'
  ClientHeight = 451
  ClientWidth = 601
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Background: TImage
    Left = 0
    Top = 0
    Width = 601
    Height = 453
  end
  object UnsentLogs: TButton
    Left = 256
    Top = 48
    Width = 89
    Height = 33
    Caption = 'Unsent Logs'
    TabOrder = 0
    OnClick = UnsentLogsClick
  end
  object DumpLogs: TButton
    Left = 120
    Top = 112
    Width = 89
    Height = 33
    Caption = 'Dump All Logs'
    TabOrder = 1
    Visible = False
    OnClick = DumpLogsClick
  end
  object DumpLogsByDate: TButton
    Left = 120
    Top = 184
    Width = 89
    Height = 33
    Caption = 'Logs By Date'
    TabOrder = 2
    Visible = False
    OnClick = DumpLogsByDateClick
  end
  object StringGrid1: TStringGrid
    Left = 16
    Top = 264
    Width = 568
    Height = 179
    TabOrder = 3
  end
  object ShowLogs: TButton
    Left = 96
    Top = 48
    Width = 89
    Height = 33
    Caption = 'Show Logs'
    TabOrder = 4
    OnClick = ShowLogsClick
  end
  object UploadIniLogger: TButton
    Left = 336
    Top = 104
    Width = 113
    Height = 33
    Caption = 'Upload Ini Logger'
    TabOrder = 5
    Visible = False
    OnClick = UploadIniLoggerClick
  end
  object DownloadIniLogger: TButton
    Left = 336
    Top = 176
    Width = 113
    Height = 33
    Caption = 'Download Ini Logger'
    TabOrder = 6
    Visible = False
    OnClick = DownloadIniLoggerClick
  end
  object IniMenu: TButton
    Left = 424
    Top = 48
    Width = 89
    Height = 33
    Caption = 'Ini Menu'
    TabOrder = 7
    OnClick = IniMenuClick
  end
  object UploadIniClient: TButton
    Left = 152
    Top = 104
    Width = 113
    Height = 33
    Caption = 'Upload Ini Client'
    TabOrder = 8
    Visible = False
    OnClick = UploadIniClientClick
  end
  object DownloadIniClient: TButton
    Left = 152
    Top = 176
    Width = 113
    Height = 33
    Caption = 'Download Ini Client'
    TabOrder = 9
    Visible = False
    OnClick = DownloadIniClientClick
  end
  object IdTCPServer1: TIdTCPServer
    Active = True
    Bindings = <>
    DefaultPort = 9898
    OnExecute = IdTCPServer1Execute
  end
  object OraSQL1: TOraSQL
    Session = OraSession1
    Left = 64
  end
  object OraSession1: TOraSession
    Options.Direct = True
    Username = 'antonio'
    Server = 
      'database-1.cdd9nujedfvr.us-east-2.rds.amazonaws.com:1521:databas' +
      'e'
    Connected = True
    Left = 128
    EncryptedPassword = '9EFF91FF8BFF90FF91FF96FF90FFCEFF'
  end
end
