object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'MQTT Server / Client Demo'
  ClientHeight = 426
  ClientWidth = 831
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 220
    Width = 27
    Height = 13
    Caption = 'Client'
  end
  object CIDTxt: TLabel
    Left = 370
    Top = 8
    Width = 3
    Height = 13
    AutoSize = False
  end
  object Label4: TLabel
    Left = 370
    Top = 220
    Width = 30
    Height = 13
    Caption = 'Online'
  end
  object COnlineTxt: TLabel
    Left = 406
    Top = 220
    Width = 15
    Height = 13
    Caption = 'NO'
  end
  object CEnableTxt: TLabel
    Left = 348
    Top = 220
    Width = 15
    Height = 13
    Caption = 'NO'
  end
  object Label3: TLabel
    Left = 304
    Top = 220
    Width = 38
    Height = 13
    Caption = 'Enabled'
  end
  object Label1: TLabel
    Left = 8
    Top = 6
    Width = 32
    Height = 13
    Caption = 'Server'
  end
  object Label5: TLabel
    Left = 431
    Top = 248
    Width = 91
    Height = 13
    Caption = 'Subscription Topics'
  end
  object Label6: TLabel
    Left = 582
    Top = 283
    Width = 42
    Height = 13
    Caption = 'Message'
  end
  object SClientsTxt: TLabel
    Left = 412
    Top = 6
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label9: TLabel
    Left = 370
    Top = 6
    Width = 32
    Height = 13
    Caption = 'Clients'
  end
  object Label7: TLabel
    Left = 737
    Top = 243
    Width = 85
    Height = 13
    Caption = 'Quality of Service'
  end
  object Label8: TLabel
    Left = 45
    Top = 220
    Width = 42
    Height = 13
    Caption = 'Last Msg'
  end
  object CMsgTxt: TLabel
    Left = 93
    Top = 220
    Width = 40
    Height = 13
    Caption = '<none>'
  end
  object Label11: TLabel
    Left = 46
    Top = 6
    Width = 42
    Height = 13
    Caption = 'Last Msg'
  end
  object SMsgTxt: TLabel
    Left = 94
    Top = 6
    Width = 40
    Height = 13
    Caption = '<none>'
  end
  object Label10: TLabel
    Left = 466
    Top = 155
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object Label13: TLabel
    Left = 653
    Top = 220
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object Label14: TLabel
    Left = 173
    Top = 6
    Width = 19
    Height = 13
    Caption = 'Qos'
  end
  object SQosTxt: TLabel
    Left = 198
    Top = 6
    Width = 3
    Height = 13
    Caption = ' '
  end
  object Label16: TLabel
    Left = 173
    Top = 220
    Width = 19
    Height = 13
    Caption = 'Qos'
  end
  object CQosTxt: TLabel
    Left = 198
    Top = 220
    Width = 6
    Height = 13
    Caption = '  '
  end
  object Label15: TLabel
    Left = 304
    Top = 6
    Width = 38
    Height = 13
    Caption = 'Enabled'
  end
  object SEnableTxt: TLabel
    Left = 348
    Top = 6
    Width = 15
    Height = 13
    Caption = 'NO'
  end
  object Label18: TLabel
    Left = 581
    Top = 247
    Width = 25
    Height = 13
    Caption = 'Topic'
  end
  object ClientIDTxt: TLabel
    Left = 683
    Top = 179
    Width = 38
    Height = 13
    Caption = 'ClientID'
  end
  object PixTxt: TLabel
    Left = 618
    Top = 2
    Width = 193
    Height = 13
    Alignment = taCenter
    AutoSize = False
  end
  object Label12: TLabel
    Left = 653
    Top = 196
    Width = 22
    Height = 13
    Caption = 'Host'
  end
  object Memo1: TMemo
    Left = 2
    Top = 20
    Width = 421
    Height = 183
    ScrollBars = ssVertical
    TabOrder = 0
    OnDblClick = Memo1DblClick
  end
  object Button15: TButton
    Left = 431
    Top = 15
    Width = 69
    Height = 27
    Caption = 'Start'
    TabOrder = 1
    OnClick = Button15Click
  end
  object Button16: TButton
    Left = 501
    Top = 15
    Width = 69
    Height = 27
    Caption = 'Stop'
    TabOrder = 2
    OnClick = Button16Click
  end
  object Memo2: TMemo
    Left = 7
    Top = 234
    Width = 279
    Height = 194
    ScrollBars = ssVertical
    TabOrder = 3
    OnDblClick = Memo2DblClick
  end
  object Button17: TButton
    Left = 501
    Top = 214
    Width = 69
    Height = 27
    Caption = 'Stop'
    TabOrder = 4
    OnClick = Button17Click
  end
  object Button18: TButton
    Left = 431
    Top = 214
    Width = 69
    Height = 27
    Caption = 'Start'
    TabOrder = 5
    OnClick = Button18Click
  end
  object Button22: TButton
    Left = 429
    Top = 48
    Width = 80
    Height = 27
    Caption = 'Show Clients'
    TabOrder = 6
    OnClick = Button22Click
  end
  object Button24: TButton
    Left = 581
    Top = 373
    Width = 69
    Height = 25
    Caption = 'Publish'
    TabOrder = 7
    OnClick = Button24Click
  end
  object rb1: TRadioButton
    Left = 735
    Top = 259
    Width = 87
    Height = 17
    Caption = 'At Most Once'
    TabOrder = 8
    OnClick = rb1Click
  end
  object rb2: TRadioButton
    Tag = 1
    Left = 735
    Top = 275
    Width = 91
    Height = 17
    Caption = 'At Least Once'
    Checked = True
    TabOrder = 9
    TabStop = True
    OnClick = rb1Click
  end
  object rb3: TRadioButton
    Tag = 2
    Left = 735
    Top = 291
    Width = 87
    Height = 17
    Caption = 'Exactly Once'
    TabOrder = 10
    OnClick = rb1Click
  end
  object Button1: TButton
    Left = 431
    Top = 399
    Width = 69
    Height = 25
    Caption = 'Show'
    TabOrder = 11
    OnClick = Button1Click
  end
  object PortTxt: TEdit
    Left = 497
    Top = 152
    Width = 85
    Height = 21
    TabOrder = 12
    Text = '1883'
    OnKeyPress = PortTxtKeyPress
  end
  object Button2: TButton
    Left = 429
    Top = 113
    Width = 80
    Height = 27
    Caption = 'Brokers'
    TabOrder = 13
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 573
    Top = 214
    Width = 69
    Height = 27
    Caption = 'Kill'
    TabOrder = 14
    OnClick = Button3Click
  end
  object CPortTxt: TEdit
    Left = 683
    Top = 217
    Width = 85
    Height = 21
    TabOrder = 15
    Text = '1883'
    OnKeyPress = PortTxtKeyPress
  end
  object BounceBox: TCheckBox
    Left = 517
    Top = 49
    Width = 97
    Height = 17
    Caption = ' Local Bounce'
    TabOrder = 16
    OnClick = BounceBoxClick
  end
  object TopicsTxt: TMemo
    Left = 431
    Top = 263
    Width = 144
    Height = 104
    Lines.Strings = (
      'update/memo'
      'update/png/+'
      'will/#')
    TabOrder = 17
  end
  object Button5: TButton
    Left = 431
    Top = 373
    Width = 69
    Height = 25
    Caption = 'Subscribe'
    TabOrder = 18
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 506
    Top = 373
    Width = 69
    Height = 25
    Caption = 'Unsubscribe'
    TabOrder = 19
    OnClick = Button6Click
  end
  object TopicTxt: TEdit
    Left = 581
    Top = 263
    Width = 146
    Height = 21
    TabOrder = 20
    Text = 'update/memo'
  end
  object MsgBox: TMemo
    Left = 582
    Top = 298
    Width = 145
    Height = 69
    Lines.Strings = (
      'WARNING'
      'Coolant Leak.'
      'Primary Cooling System.'
      'Reactor 5.')
    TabOrder = 21
  end
  object CMBox: TCheckBox
    Left = 517
    Top = 65
    Width = 97
    Height = 17
    Caption = 'Client Monitor'
    Checked = True
    State = cbChecked
    TabOrder = 22
  end
  object CMBox2: TCheckBox
    Left = 735
    Top = 361
    Width = 97
    Height = 17
    Caption = 'Client Monitor'
    Checked = True
    State = cbChecked
    TabOrder = 23
  end
  object BounceBox2: TCheckBox
    Left = 735
    Top = 345
    Width = 97
    Height = 17
    Caption = ' Local Bounce'
    TabOrder = 24
    OnClick = BounceBox2Click
  end
  object CleanBox2: TCheckBox
    Left = 735
    Top = 312
    Width = 97
    Height = 17
    Caption = 'Clean'
    TabOrder = 25
    OnClick = CleanBox2Click
  end
  object Button4: TButton
    Left = 774
    Top = 216
    Width = 53
    Height = 23
    Caption = 'Update'
    TabOrder = 26
    OnClick = Button4Click
  end
  object Memo3: TMemo
    Left = 292
    Top = 234
    Width = 133
    Height = 189
    TabOrder = 27
    OnDblClick = Memo3DblClick
  end
  object RetainBox: TCheckBox
    Left = 735
    Top = 327
    Width = 97
    Height = 17
    Caption = 'Retain'
    TabOrder = 28
    OnClick = RetainBoxClick
  end
  object Button8: TButton
    Left = 556
    Top = 399
    Width = 50
    Height = 25
    Caption = 'Send'
    TabOrder = 29
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 769
    Top = 378
    Width = 50
    Height = 25
    Caption = 'Off'
    TabOrder = 30
    OnClick = Button9Click
  end
  object JTxt: TEdit
    Left = 674
    Top = 380
    Width = 33
    Height = 21
    TabOrder = 31
    Text = '3'
    OnKeyPress = JTxtKeyPress
  end
  object Edit1: TEdit
    Left = 618
    Top = 403
    Width = 89
    Height = 21
    TabOrder = 32
    Text = '3'
  end
  object Button10: TButton
    Left = 717
    Top = 378
    Width = 50
    Height = 25
    Caption = 'On'
    TabOrder = 33
    OnClick = Button10Click
  end
  object AddrTxt: TEdit
    Left = 683
    Top = 193
    Width = 129
    Height = 21
    TabOrder = 34
    Text = '10.0.0.2'
  end
  object TTServer: TMQTTServer
    MaxRetries = 4
    RetryTime = 60
    Port = 1883
    LocalBounce = False
    OnFailure = TTServerFailure
    OnStoreSession = TTServerStoreSession
    OnRestoreSession = TTServerRestoreSession
    OnDeleteSession = TTServerDeleteSession
    OnBrokerOnline = TTServerBrokerOnline
    OnBrokerOffline = TTServerBrokerOffline
    OnBrokerEnableChange = TTServerBrokerEnableChange
    OnEnableChange = TTServerEnableChange
    OnSubscription = TTServerSubscription
    OnClientsChange = TTServerClientsChange
    OnCheckUser = TTServerCheckUser
    OnObituary = TTServerObituary
    OnMon = TTServerMon
    Left = 526
    Top = 102
  end
  object TTClient: TMQTTClient
    KeepAlive = 10
    MaxRetries = 8
    RetryTime = 60
    Clean = True
    Broker = False
    AutoSubscribe = False
    Username = 'admin'
    Password = 'password'
    Host = 'localhost'
    Port = 1883
    LocalBounce = False
    OnClientID = TTClientClientID
    OnMon = TTClientMon
    OnOnline = TTClientOnline
    OnOffline = TTClientOffline
    OnEnableChange = TTClientEnableChange
    OnFailure = TTClientFailure
    OnMsg = TTClientMsg
    Left = 564
    Top = 102
  end
end
