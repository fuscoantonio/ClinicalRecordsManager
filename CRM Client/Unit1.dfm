object GestionaleCartellaClinica: TGestionaleCartellaClinica
  Left = 0
  Top = 0
  Caption = 'GestionaleCartellaClinica'
  ClientHeight = 457
  ClientWidth = 846
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Background: TImage
    Left = 0
    Top = -1
    Width = 846
    Height = 457
  end
  object InsertMenu: TButton
    Left = 240
    Top = 60
    Width = 83
    Height = 37
    Caption = 'Insert Menu'
    TabOrder = 0
    OnClick = InsertMenuClick
  end
  object EnterButton: TButton
    Left = 368
    Top = 276
    Width = 83
    Height = 37
    Caption = 'Enter'
    TabOrder = 1
    Visible = False
    OnClick = EnterButtonClick
  end
  object SelectMenu: TButton
    Left = 512
    Top = 60
    Width = 83
    Height = 37
    Caption = 'Select Menu'
    TabOrder = 2
    OnClick = SelectMenuClick
  end
  object Memo: TMemo
    Left = 0
    Top = 319
    Width = 846
    Height = 137
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 319
    Width = 846
    Height = 137
    DataSource = DataSource1
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object OraSession1: TOraSession
    Options.Direct = True
    Username = 'antonio'
    Server = 
      'database-1.cdd9nujedfvr.us-east-2.rds.amazonaws.com:1521:databas' +
      'e'
    Connected = True
    Left = 424
    Top = 8
    EncryptedPassword = '9EFF91FF8BFF90FF91FF96FF90FFCEFF'
  end
  object OraQuery1: TOraQuery
    Session = OraSession1
    SQL.Strings = (
      '')
    Left = 632
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = OraQuery1
    Left = 272
    Top = 8
  end
  object OraSQL1: TOraSQL
    Session = OraSession1
    Left = 88
    Top = 8
  end
end
