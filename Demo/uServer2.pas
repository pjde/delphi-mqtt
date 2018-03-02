unit uServer2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OverbyteIcsWndControl, OverbyteIcsWSocket, OverbyteIcsWSocketS, uMQTT,
  StdCtrls, uMQTTComps, ExtCtrls {, GR32_RangeBars};

type
  TMainForm = class (TForm)
    Memo1: TMemo;
    Button15: TButton;
    Button16: TButton;
    Memo2: TMemo;
    Button17: TButton;
    Button18: TButton;
    Button22: TButton;
    Button24: TButton;
    Label2: TLabel;
    CIDTxt: TLabel;
    Label4: TLabel;
    COnlineTxt: TLabel;
    CEnableTxt: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SClientsTxt: TLabel;
    Label9: TLabel;
    rb1: TRadioButton;
    rb2: TRadioButton;
    rb3: TRadioButton;
    Label7: TLabel;
    Button1: TButton;
    Label8: TLabel;
    CMsgTxt: TLabel;
    Label11: TLabel;
    SMsgTxt: TLabel;
    PortTxt: TEdit;
    Label10: TLabel;
    Button2: TButton;
    Button3: TButton;
    CPortTxt: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    SQosTxt: TLabel;
    Label16: TLabel;
    CQosTxt: TLabel;
    Label15: TLabel;
    SEnableTxt: TLabel;
    BounceBox: TCheckBox;
    TopicsTxt: TMemo;
    Button5: TButton;
    Button6: TButton;
    TopicTxt: TEdit;
    Label18: TLabel;
    MsgBox: TMemo;
    CMBox: TCheckBox;
    CMBox2: TCheckBox;
    BounceBox2: TCheckBox;
    CleanBox2: TCheckBox;
    ClientIDTxt: TLabel;
    TTServer: TMQTTServer;
    TTClient: TMQTTClient;
    PixTxt: TLabel;
    Button4: TButton;
    Memo3: TMemo;
    RetainBox: TCheckBox;
    Button8: TButton;
    Button9: TButton;
    JTxt: TEdit;
    Edit1: TEdit;
    Button10: TButton;
    AddrTxt: TEdit;
    Label12: TLabel;

    procedure FormCreate (Sender : TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Memo2DblClick(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure rb1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PortTxtKeyPress(Sender: TObject; var Key: Char);
    procedure Button3Click(Sender: TObject);
    procedure BounceBoxClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure BounceBox2Click(Sender: TObject);
    procedure CleanBox2Click(Sender: TObject);
    procedure TTClientFailure(Sender: TObject; aReason: Integer;
      var CloseClient: Boolean);
    procedure TTClientMon(Sender: TObject; aStr: string);
    procedure TTClientEnableChange(Sender: TObject);
    procedure TTClientMsg (Sender: TObject; aTopic: UTF8String;
      aMessage: AnsiString; aQos : TMQTTQOSType; aRetained : Boolean);
    procedure TTClientOffline(Sender: TObject; Graceful: Boolean);
    procedure TTClientOnline(Sender: TObject);
    procedure TTServerCheckUser(Sender: TObject; aUser, aPass: UTF8String;
      var Allowed: Boolean);
    procedure TTServerClientsChange(Sender: TObject; anID: Word);
    procedure TTServerFailure(Sender: TObject; aReason: Integer;
      var CloseClient: Boolean);
    procedure TTServerEnableChange(Sender: TObject);
    procedure TTServerMon(Sender: TObject; aStr: string);
    procedure TTServerRestoreSession(Sender: TObject; aClientID: UTF8String);
    procedure TTServerStoreSession(Sender: TObject; aClientID: UTF8String);
    procedure TTServerDeleteSession(Sender: TObject; aClientID: UTF8String);
    procedure TTServerObituary(Sender: TObject; var aTopic,
      aMessage: UTF8String; var aQos: TMQTTQOSType);
    procedure TTServerSubscription(Sender: TObject; aTopic: UTF8String;
      var RequestedQos: TMQTTQOSType);
    procedure TTServerBrokerOffline(Sender: TObject; Graceful: Boolean);
    procedure TTServerBrokerOnline(Sender: TObject);
    procedure TTServerBrokerEnableChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure TTClientClientID(Sender: TObject; var aClientID: UTF8String);
    procedure Memo3DblClick(Sender: TObject);
    procedure RetainBoxClick(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure JTxtKeyPress(Sender: TObject; var Key: Char);
    procedure GaugeBar1UserChange(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    aQos : TMQTTQOSType;
    aRetain : Boolean;
    procedure StoreSettings;
    procedure LoadSettings;
    procedure SMonHeader (Sender : TObject; aMsgType: TMQTTMessageType; aDup: Boolean;
                        aQos: TMQTTQOSType; aRetain: Boolean);
    procedure CMonHeader (Sender : TObject; aMsgType: TMQTTMessageType; aDup: Boolean;
                        aQos: TMQTTQOSType; aRetain: Boolean);
  end;

var
  MainForm: TMainForm;

implementation

uses uBrokers, IniFiles;

{$R *.dfm}
{ TForm1 }

procedure TMainForm.BounceBox2Click(Sender: TObject);
begin
  TTClient.LocalBounce := BounceBox2.Checked;
end;

procedure TMainForm.BounceBoxClick(Sender: TObject);
begin
  TTServer.LocalBounce := BounceBox.Checked;
end;

procedure TMainForm.Button10Click(Sender: TObject);
begin
  TTClient.Publish ('csi/pnl/set/state/' + UTF8String (JTxt.Text), '1', qtAT_MOST_ONCE, false);
end;

procedure TMainForm.Button15Click(Sender: TObject);
begin
  TTServer.Port := StrToIntDef (PortTxt.Text, 1883);
  TTServer.Activate (true);
end;

procedure TMainForm.Button16Click (Sender: TObject);
begin
  TTServer.Activate(false);
end;

procedure TMainForm.Button17Click (Sender: TObject);
begin
  TTClient.Activate (false);
end;

procedure TMainForm.Button18Click (Sender: TObject);
begin
  TTClient.Host := AddrTxt.Text;
  TTClient.Port := StrToIntDef (CPortTxt.Text, 1883);
  TTClient.Activate (true);
end;

procedure TMainForm.Button1Click (Sender: TObject);
var
  j : integer;
  x : cardinal;
begin
  memo2.Lines.Add ('');
  memo2.Lines.Add('------ Client ' + string (TTClient.Parser.ClientID) + ' -------');
  memo2.Lines.Add (format ('Username "%s" Password "%s"', [TTClient.Parser.Username, TTClient.Parser.Password]));
  memo2.Lines.Add (format ('Keep Alive "%d" Retry Time "%d" Max Retries "%d"', [TTClient.Parser.KeepAlive, TTClient.Parser.RetryTime, TTClient.Parser.MaxRetries]));
  memo2.Lines.Add (format ('Will Topic "%s" Message "%s" @ %s', [TTClient.Parser.WillTopic, TTClient.Parser.WillMessage, QosNames [TTClient.Parser.WillQos]]));
  memo2.Lines.Add ('Subscriptions ----');
  for j := 0 to TTClient.Subscriptions.Count - 1 do
    begin
      x := cardinal (TTClient.Subscriptions.Objects[j]) and $03;
      if (cardinal (TTClient.Subscriptions.Objects[j]) shr 8) and $ff = $ff then
        memo2.Lines.Add ('  "' + TTClient.Subscriptions[j] + '" @ ' + QOSNames[TMQTTQOSType (x)] + ' Acked.')
      else
        memo2.Lines.Add ('  "' + TTClient.Subscriptions[j] + '" @ ' + QOSNames[TMQTTQOSType (x)]);
    end;
end;

procedure TMainForm.Button22Click(Sender: TObject);
var
  i, j : integer;
  aClient : TClient;
  x : cardinal;
begin
  for i := 0 to TTServer.Server.ClientCount - 1 do
    begin
      aClient := TClient (TTServer.Server.Client[i]);
      memo1.Lines.Add ('');
      memo1.Lines.Add('------ Client ' + string (aClient.Parser.ClientID) + ' -------');
      memo1.Lines.Add (format ('Username "%s" Password "%s"', [aClient.Parser.Username, aClient.Parser.Password]));
      memo1.Lines.Add (format ('Keep Alive "%d" Retry Time "%d" Max Retries "%d"', [aClient.Parser.KeepAlive, aClient.Parser.RetryTime, aClient.Parser.MaxRetries]));
      memo1.Lines.Add (format ('Will Topic "%s" Message "%s" @ %s', [aClient.Parser.WillTopic, aClient.Parser.WillMessage, QosNames [aClient.Parser.WillQos]]));
      memo1.Lines.Add ('Subscriptions ----');
      for j := 0 to aClient.Subscriptions.Count - 1 do
        begin
          x := cardinal (aClient.Subscriptions.Objects[j]) and $03;
          memo1.Lines.Add ('  "' + aClient.Subscriptions[j] + '" @ ' + QOSNames[TMQTTQOSType (x)]);
        end;
    end;
end;

procedure TMainForm.Button24Click (Sender: TObject);
var
  i, x : integer;
  aStr : AnsiString;
begin
  aStr := '';
  for i := 0 to MsgBox.Lines.Count - 1 do
    begin
      x := length (MsgBox.Lines[i]);
      aStr := aStr + AnsiChar (x div $100) + AnsiChar (x mod $100) + AnsiString (MsgBox.Lines[i]);
    end;
  TTClient.Publish (UTF8String (TopicTxt.Text), aStr, aQos, aRetain);
end;

procedure TMainForm.Button2Click (Sender: TObject);
begin
  BrokerForm.FServer := TTServer;
  BrokerForm.Show;
end;

procedure TMainForm.Button3Click (Sender: TObject);
begin
  try
    TTClient.Link.Close;
  except
  end;
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  TTClient.Publish ('request/png/' + TTClient.ClientID, '?', qtEXACTLY_ONCE);
end;

procedure TMainForm.Button5Click (Sender: TObject);
var
  s : TStringlist;
  i : integer;
begin
  s := TStringList.Create;
  for i := 0 to TopicsTxt.Lines.Count - 1 do
    s.AddObject(TopicsTxt.Lines[i], TObject (aQos));
  TTClient.Subscribe (s);
  s.Free;
end;

procedure TMainForm.Button6Click(Sender: TObject);
var
  s : TStringlist;
  i : integer;
begin
  s := TStringList.Create;
  for i := 0 to TopicsTxt.Lines.Count - 1 do
    s.Add (TopicsTxt.Lines[i]);
  TTClient.Unsubscribe (s);
  s.Free;
end;

procedure TMainForm.Button8Click(Sender: TObject);
begin
  TTClient.Publish ('csi/pnl/set/text/' + UTF8String (JTxt.Text), AnsiString (Edit1.Text), qtAT_MOST_ONCE, false);
end;

procedure TMainForm.Button9Click(Sender: TObject);
begin
  TTClient.Publish ('csi/pnl/set/state/' + UTF8String (JTxt.Text), '0', qtAT_MOST_ONCE, false);
end;

procedure TMainForm.CleanBox2Click(Sender: TObject);
begin
  TTClient.Clean := CleanBox2.Checked;
end;

procedure TMainForm.CMonHeader(Sender: TObject; aMsgType: TMQTTMessageType;
  aDup: Boolean; aQos: TMQTTQOSType; aRetain: Boolean);
begin
  CMsgTxt.Caption := MsgNames[aMsgType];
  CQosTxt.Caption := QosNames[aQos];
end;

procedure TMainForm.FormCreate (Sender: TObject);
begin
  aQos := qtAT_LEAST_ONCE;
  aRetain := false;
  LoadSettings;
  // load retained messages
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // store retained messages
  StoreSettings;
end;

procedure TMainForm.FormShow (Sender: TObject);
begin
  PortTxt.Text := IntToStr (TTServer.Port);
  CPortTxt.Text := IntToStr (TTClient.Port);
  AddrTxt.Text := TTClient.Host;
  BounceBox.Checked := TTServer.LocalBounce;
  BounceBox2.Checked := TTClient.LocalBounce;
  rb1.Checked := (aQos = qtAT_MOST_ONCE);
  rb2.Checked := (aQos = qtAT_LEAST_ONCE);
  rb3.Checked := (aQos = qtEXACTLY_ONCE);
  CleanBox2.Checked := TTClient.Clean;
  ClientIDTxt.Caption := '';
  TTServer.FOnMonHdr := SMonHeader;
  TTClient.Parser.OnHeader := CMonHeader;
  RetainBox.Checked := aRetain;
end;

procedure TMainForm.GaugeBar1UserChange(Sender: TObject);
begin
//  TTClient.Publish ('csi/pnl/set/amount/' + UTF8String (JTxt.Text), AnsiString (IntToStr (GaugeBar1.Position)), qtAT_MOST_ONCE, false);
end;

procedure TMainForm.JTxtKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet (Key, ['0'..'9', #8]) then Key := #0;
end;

procedure TMainForm.LoadSettings;
var
  anIniFile : string;
begin
  anIniFile := ChangeFileExt (Application.ExeName, '.ini');
  with TIniFile.Create (anIniFile) do
    begin
      TTServer.Port := ReadInteger ('SERVER', 'Port', 1883);
      TTServer.LocalBounce := ReadBool ('SERVER', 'Local Bounce', true);
      TTClient.Host := ReadString ('CLIENT', 'Host', 'localhost');
      TTClient.Port := ReadInteger ('CLIENT', 'Port', 1883);
      TTClient.LocalBounce := ReadBool ('CLIENT', 'Local Bounce', false);
      aQos := TMQTTQOSType (ReadInteger ('CLIENT', 'Qos', 1));
      CMBox.Checked := ReadBool ('SERVER', 'Monitor', true);
      CMBox2.Checked := ReadBool ('CLIENT', 'Monitor', true);
      Free;
    end;
end;

procedure TMainForm.StoreSettings;
var
  anIniFile : string;
begin
  anIniFile := ChangeFileExt (Application.ExeName, '.ini');
  with TIniFile.Create (anIniFile) do
    begin
      WriteInteger ('SERVER', 'Port', TTServer.Port);
      WriteBool ('SERVER', 'Local Bounce', TTServer.LocalBounce);
      writeString ('CLIENT', 'Host', TTClient.Host);
      WriteInteger ('CLIENT', 'Port', TTClient.Port);
      WriteInteger ('CLIENT', 'Qos', ord (aQos));
      WriteBool ('CLIENT', 'Local Bounce', TTClient.LocalBounce);
      WriteBool ('SERVER', 'Monitor', CMBox.Checked);
      WriteBool ('CLIENT', 'Monitor', CMBox2.Checked);
      Free;
    end;
end;

procedure TMainForm.TTClientClientID(Sender: TObject;
  var aClientID: UTF8String);
begin
  TTClient.SetWill ('will/' + aClientID, 'I''ve had it folks..', qtEXACTLY_ONCE);
end;

procedure TMainForm.TTClientEnableChange(Sender: TObject);
begin
  CEnableTxt.Caption := ny[TMQTTClient (Sender).Enabled];
  if TMQTTClient (Sender).Enabled then
    memo2.Lines.Add ('Client is enabled.')
  else
    memo2.Lines.Add ('Client is disabled.');
end;

procedure TMainForm.TTClientFailure(Sender: TObject; aReason: Integer;
  var CloseClient: Boolean);
begin
  memo2.Lines.Add ('---- Failure Reported ' + FailureNames (aReason));
end;

procedure TMainForm.TTClientMon (Sender: TObject; aStr: string);
begin
  if CMBox2.Checked then memo2.Lines.Add (aStr);
end;

procedure TMainForm.TTClientMsg (Sender: TObject; aTopic: UTF8String;
  aMessage: AnsiString; aQos : TMQTTQOSType; aRetained : boolean);
var
  i, x : integer;
  aStr : string;
  ForMe : boolean;
  t : TStringList;
begin                                 // Sender TMQTTClient
  memo2.Lines.Add ('MESSAGE "' + string (aTopic) + '".');
  memo2.Lines.Add (IntToStr (length (aMessage)) + ' byte(s) @ ' + QOSNames[aQos]);
  if aRetained then
    memo2.Lines.Add('This is a Retained message.');
  t := SubTopics (aTopic);
  if t[0] = 'will' then
    memo2.Lines.Add (string (aMessage))
  else if t.Count >= 2 then
    begin
      if t[0] = 'update' then
        begin
          if t[1] = 'memo' then
            begin
              ForMe := true;
              if (t.Count > 2) then ForMe := (t[2] = string (TTClient.ClientID));
              if ForMe then
                begin
                  Memo3.Lines.Clear;
                  i := 1;
                  while (i + 1) <= length (aMessage) do
                    begin
                      aStr := '';
                      x := ord (aMessage[i]) * $100 + ord (aMessage[i + 1]);
                      i := i + 2;
                      if (x > 0) then
                        begin
                          aStr := Copy (string (aMessage), i, x);
                          i := i + x;
                        end;
                      memo3.Lines.Add (aStr);
                    end;  // while
                  if aRetained then memo3.Lines.Add ('(Retained)');
                end;  // forme
            end;   // [t[1]
        end;    // t[0]
    end;  // t.Count >= 2
  memo2.Lines.Add ('MESSAGE END');
  t.Free;
end;

procedure TMainForm.TTClientOffline(Sender: TObject; Graceful: Boolean);
begin
  COnlineTxt.Caption := 'NO';
  ClientIDTxt.Caption := '';
  if Graceful then
    memo2.Lines.Add ('Client Gracefully Disconnected.')
  else
    memo2.Lines.Add ('Client Terminated Unexpectedly.');
end;

procedure TMainForm.TTClientOnline(Sender: TObject);
begin
  COnlineTxt.Caption := 'YES';
  memo2.Lines.Add ('Client is online.');
  ClientIDTxt.Caption := string (TTClient.Parser.ClientID);
  Button5Click (Button5);
end;

procedure TMainForm.TTServerBrokerEnableChange(Sender: TObject);
begin
  if BrokerForm.Visible then BrokerForm.RefreshTree;
end;

procedure TMainForm.TTServerBrokerOffline(Sender: TObject; Graceful: Boolean);
begin
  if BrokerForm.Visible then BrokerForm.RefreshTree;
end;

procedure TMainForm.TTServerBrokerOnline(Sender: TObject);
begin
  if BrokerForm.Visible then BrokerForm.RefreshTree;
end;

procedure TMainForm.TTServerCheckUser(Sender: TObject; aUser, aPass: UTF8String;
  var Allowed: Boolean);
begin
  memo1.Lines.Add ('Login Approval Username "' + string (aUser) + '" Password "' + string (aPass) + '".');
  Allowed := true;
end;

procedure TMainForm.TTServerClientsChange (Sender: TObject; anID: Word);
begin
  SClientsTxt.Caption := IntToStr (anID);
end;

procedure TMainForm.TTServerDeleteSession (Sender: TObject;
  aClientID: UTF8String);
begin
  memo1.Lines.Add ('Delete Session for "' + string (aClientID) + '".');
end;

procedure TMainForm.TTServerEnableChange (Sender: TObject);
begin
  SEnableTxt.Caption := ny[TTServer.Enabled];
end;

procedure TMainForm.TTServerFailure (Sender: TObject; aReason: Integer;
  var CloseClient: Boolean);
begin
  memo1.Lines.Add ('---- Failure Reported ' + FailureNames (aReason));
end;

procedure TMainForm.TTServerMon(Sender: TObject; aStr: string);
begin
  if CMBox.Checked then memo1.Lines.Add (aStr);
end;

procedure TMainForm.TTServerObituary(Sender: TObject; var aTopic,
  aMessage: UTF8String; var aQos: TMQTTQOSType);
begin
  if not (Sender is TClient) then exit;
  memo1.Lines.Add ('Obituary Approval "' + string (aTopic) + '" with message "' + string (aMessage) + '"');
  with TClient (Sender) do
    begin
      aMessage := Parser.ClientID + ' failed at ' + UTF8String (TimeToStr (Now)) + ' - ' + aMessage;
    end;
end;

procedure TMainForm.TTServerRestoreSession(Sender: TObject;
  aClientID: UTF8String);
begin
  memo1.Lines.Add ('Restore Session for "' + string (aClientID) + '".');
end;

procedure TMainForm.TTServerStoreSession(Sender: TObject;
  aClientID: UTF8String);
begin
  memo1.Lines.Add ('Store Session for "' + string (aClientID) + '".');
end;

procedure TMainForm.TTServerSubscription(Sender: TObject; aTopic: UTF8String;
  var RequestedQos: TMQTTQOSType);
begin
   memo1.Lines.Add ('Subscription Approval "' + string (aTopic) + '" @ ' + QOSNames [RequestedQOS]);
end;

procedure TMainForm.Memo1DblClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TMainForm.Memo2DblClick(Sender: TObject);
begin
  memo2.Lines.Clear;
end;

procedure TMainForm.Memo3DblClick(Sender: TObject);
begin
  Memo3.Lines.Clear;
end;

procedure TMainForm.PortTxtKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet (Key, ['0'..'9', #8]) then Key := #0;
end;

procedure TMainForm.rb1Click (Sender: TObject);
begin
  aQos := TMQTTQOSType (TRadioButton (Sender).Tag);
end;

procedure TMainForm.RetainBoxClick(Sender: TObject);
begin
  aRetain := RetainBox.Checked;
end;

procedure TMainForm.SMonHeader(Sender: TObject; aMsgType: TMQTTMessageType;
  aDup: Boolean; aQos: TMQTTQOSType; aRetain: Boolean);
begin
  SMsgTxt.Caption := MsgNames[aMsgType];
  SQosTxt.Caption := QosNames[aQos];
end;


end.
