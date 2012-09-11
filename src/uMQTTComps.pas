unit uMQTTComps;

interface
uses
  Classes, uMQTT, OverbyteIcsWndControl, OverbyteIcsWSocket, OverbyteIcsWSocketS, Windows, Messages;


(*  Todo
    Finish Retain
*)
(*    Web Sites
http://www.alphaworks.ibm.com/tech/rsmb
http://www.mqtt.org

Permission to copy and display the MQ Telemetry Transport specification (the
"Specification"), in any medium without fee or royalty is hereby granted by Eurotech
and International Business Machines Corporation (IBM) (collectively, the "Authors"),
provided that you include the following on ALL copies of the Specification, or portions
thereof, that you make:
A link or URL to the Specification at one of
1. the Authors' websites.
2. The copyright notice as shown in the Specification.

The Authors each agree to grant you a royalty-free license, under reasonable,
non-discriminatory terms and conditions to their respective patents that they deem
necessary to implement the Specification. THE SPECIFICATION IS PROVIDED "AS IS,"
AND THE AUTHORS MAKE NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR
IMPLIED, INCLUDING, BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, OR TITLE; THAT THE
CONTENTS OF THE SPECIFICATION ARE SUITABLE FOR ANY PURPOSE; NOR THAT THE
IMPLEMENTATION OF SUCH CONTENTS WILL NOT INFRINGE ANY THIRD PARTY
PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS. THE AUTHORS WILL NOT
BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL
DAMAGES ARISING OUT OF OR RELATING TO ANY USE OR DISTRIBUTION OF THE
SPECIFICATION *)

const
  MinVersion = 3;

type
  TClient = class;
  TMQTTClient = class;
  TMQTTPacketStore = class;
  TMQTTMessageStore = class;

  TMQTTPacket = class
    ID : Word;
    Stamp : TDateTime;
    Counter : cardinal;
    Retries : integer;
    Publishing : Boolean;
    Msg : TMemoryStream;
    procedure Assign (From : TMQTTPacket);
    constructor Create;
    destructor Destroy; override;
  end;

  TMQTTMessage = class
    ID : Word;
    Stamp : TDateTime;
    LastUsed : TDateTime;
    Qos : TMQTTQOSType;
    Retained : boolean;
    Counter : cardinal;
    Retries : integer;
    Topic : UTF8String;
    Message : AnsiString;
    procedure Assign (From : TMQTTMessage);
    constructor Create;
    destructor Destroy; override;
  end;

  TMQTTSession = class
    ClientID : UTF8String;
    Stamp : TDateTime;
    InFlight : TMQTTPacketStore;
    Releasables : TMQTTMessageStore;
    constructor Create;
    destructor Destroy; override;
  end;

  TMQTTSessionStore = class
    List :  TList;
    Stamp : TDateTime;
    function GetItem (Index: Integer): TMQTTSession;
    procedure SetItem (Index: Integer; const Value: TMQTTSession);
    property Items [Index: Integer]: TMQTTSession read GetItem write SetItem; default;
    function Count : integer;
    procedure Clear;
    function GetSession (ClientID : UTF8String) : TMQTTSession;
    procedure StoreSession (ClientID : UTF8String; aClient : TClient); overload;
    procedure StoreSession (ClientID : UTF8String; aClient : TMQTTClient); overload;
    procedure DeleteSession (ClientID : UTF8String);
    procedure RestoreSession (ClientID : UTF8String; aClient : TClient); overload;
    procedure RestoreSession (ClientID : UTF8String; aClient : TMQTTClient); overload;
    constructor Create;
    destructor Destroy; override;
  end;

  TMQTTPacketStore = class
    List : TList;
    Stamp : TDateTime;
    function GetItem (Index: Integer): TMQTTPacket;
    procedure SetItem (Index: Integer; const Value: TMQTTPacket);
    property Items [Index: Integer]: TMQTTPacket read GetItem write SetItem; default;
    function Count : integer;
    procedure Clear;
    procedure Assign (From : TMQTTPacketStore);
    function AddPacket (anID : Word; aMsg : TMemoryStream; aRetry : cardinal; aCount : cardinal) : TMQTTPacket;
    procedure DelPacket (anID : Word);
    function GetPacket (anID : Word) : TMQTTPacket;
    procedure Remove (aPacket : TMQTTPacket);
    constructor Create;
    destructor Destroy; override;
  end;

  TMQTTMessageStore = class
    List : TList;
    Stamp : TDateTime;
    function GetItem (Index: Integer): TMQTTMessage;
    procedure SetItem (Index: Integer; const Value: TMQTTMessage);
    property Items [Index: Integer]: TMQTTMessage read GetItem write SetItem; default;
    function Count : integer;
    procedure Clear;
    procedure Assign (From : TMQTTMessageStore);
    function AddMsg (anID : Word; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; aRetry : cardinal; aCount : cardinal; aRetained : Boolean = false) : TMQTTMessage;
    procedure DelMsg (anID : Word);
    function GetMsg (anID : Word) : TMQTTMessage;
    procedure Remove (aMsg : TMQTTMessage);
    constructor Create;
    destructor Destroy; override;
  end;

  TClient = class (TWSocketClient)
  private
    FOnMon : TMQTTMonEvent;
    FGraceful : boolean;
    FBroker : Boolean;        // non standard
    FOnSubscriptionChange: TNotifyEvent;
    procedure DoSend (Sender : TObject; anID : Word; aRetry : integer; aStream : TMemoryStream);
    procedure RxSubscribe (Sender : TObject; anID : Word; Topics : TStringList);
    procedure RxUnsubscribe (Sender : TObject; anID : Word; Topics : TStringList);
    procedure RxPubAck (Sender : TObject; anID : Word);
    procedure RxPubRec (Sender : TObject; anID : Word);
    procedure RxPubRel (Sender : TObject; anID : Word);
    procedure RxPubComp (Sender : TObject; anID : Word);
  public
    Subscriptions : TStringList;
    Parser : TMQTTParser;
    InFlight : TMQTTPacketStore;
    Releasables : TMQTTMessageStore;
    procedure Mon (aStr : string);
    procedure DoData (Sender : TObject; ErrCode : Word);
    procedure DoSetWill (Sender : TObject; aTopic, aMessage : UTF8String; aQOS : TMQTTQOSType; aRetain : boolean);
    constructor Create (anOwner : TComponent); override;
    destructor Destroy; override;
    property OnSubscriptionChange : TNotifyEvent read FOnSubscriptionChange write FOnSubscriptionChange;
    property OnMon : TMQTTMonEvent read FOnMon write FOnMon;
  end;

  TMQTTClient = class (TComponent)
  private
    Timers : HWnd;
    FUsername, FPassword : UTF8String;
    FMessageID : Word;
    FHost : string;
    FPort : integer;
    FEnable, FOnline : Boolean;
    FGraceful : Boolean;
    FOnMon : TMQTTMonEvent;
    FOnOnline: TNotifyEvent;
    FOnOffline: TMQTTDisconnectEvent;
    FOnEnableChange: TNotifyEvent;
    FOnMsg: TMQTTMsgEvent;
    FOnFailure: TMQTTFailureEvent;
    FLocalBounce: Boolean;
    FAutoSubscribe: Boolean;
    FOnClientID : TMQTTClientIDEvent;
    FBroker: Boolean;     // non standard
    procedure DoSend (Sender : TObject; anID : Word; aRetry : integer; aStream : TMemoryStream);
    procedure RxConnAck (Sender : TObject; aCode : byte);
    procedure RxSubAck (Sender : TObject; anID : Word; Qoss : array of TMQTTQosType);
    procedure RxPubAck (Sender : TObject; anID : Word);
    procedure RxPubRec (Sender : TObject; anID : Word);
    procedure RxPubRel (Sender : TObject; anID : Word);
    procedure RxPubComp (Sender : TObject; anID : Word);
    procedure RxPublish (Sender : TObject; anID : Word; aTopic : UTF8String; aMessage : AnsiString);
    procedure RxUnsubAck (Sender : TObject; anID : Word);
    procedure LinkConnected (Sender: TObject; ErrCode: Word);
    procedure LinkClosed (Sender: TObject; ErrCode: Word);
    procedure LinkData (Sender: TObject; ErrCode: Word);
    procedure TimerProc (var aMsg : TMessage);
    function GetClientID: UTF8String;
    procedure SetClientID (const Value: UTF8String);
    function GetKeepAlive: Word;
    procedure SetKeepAlive(const Value: Word);
    function GetMaxRetries : integer;
    procedure SetMaxRetries(const Value: integer);
    function GetRetryTime : cardinal;
    procedure SetRetryTime (const Value : cardinal);
    function GetClean: Boolean;
    procedure SetClean(const Value: Boolean);
    function GetPassword: UTF8String;
    function GetUsername: UTF8String;
    procedure SetPassword(const Value: UTF8String);
    procedure SetUsername(const Value: UTF8String);
  public
    Link : TWSocket;
    Parser : TMQTTParser;
    InFlight : TMQTTPacketStore;
    Releasables : TMQTTMessageStore;
    Subscriptions : TStringList;
    function Enabled : boolean;
    function Online : boolean;
    function NextMessageID : Word;
    procedure Subscribe (aTopic : UTF8String; aQos : TMQTTQOSType); overload;
    procedure Subscribe (Topics : TStringList); overload;
    procedure Unsubscribe (aTopic : UTF8String); overload;
    procedure Unsubscribe (Topics : TStringList); overload;
    procedure Ping;
    procedure Publish (aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; aRetain : Boolean = false);
    procedure SetWill (aTopic, aMessage : UTF8String; aQos : TMQTTQOSType; aRetain : Boolean = false);
    procedure Mon (aStr : string);
    procedure Activate (Enable : Boolean);
    constructor Create (anOwner : TComponent); override;
    destructor Destroy; override;
  published
    property ClientID : UTF8String read GetClientID write SetClientID;
    property KeepAlive : Word read GetKeepAlive write SetKeepAlive;
    property MaxRetries : integer read GetMaxRetries write SetMaxRetries;
    property RetryTime : cardinal read GetRetryTime write SetRetryTime;
    property Clean : Boolean read GetClean write SetClean;
    property Broker : Boolean read FBroker write FBroker;   // no standard
    property AutoSubscribe : Boolean read FAutoSubscribe write FAutoSubscribe;
    property Username : UTF8String read GetUsername write SetUsername;
    property Password : UTF8String read GetPassword write SetPassword;
    property Host : string read FHost write FHost;
    property Port : integer read FPort write FPort;
    property LocalBounce : Boolean read FLocalBounce write FLocalBounce;
    property OnClientID : TMQTTClientIDEvent read FOnClientID write FOnClientID;
    property OnMon : TMQTTMonEvent read FOnMon write FOnMon;
    property OnOnline : TNotifyEvent read FOnOnline write FOnOnline;
    property OnOffline : TMQTTDisconnectEvent read FOnOffline write FOnOffline;
    property OnEnableChange : TNotifyEvent read FOnEnableChange write FOnEnableChange;
    property OnFailure : TMQTTFailureEvent read FOnFailure write FOnFailure;
    property OnMsg : TMQTTMsgEvent read FOnMsg write FOnMsg;
  end;

  TMQTTServer = class (TComponent)
  private
    FOnMon : TMQTTMonEvent;
    FOnClientsChange: TMQTTIDEvent;
    FOnCheckUser: TMQTTCheckUserEvent;
    Timers : HWnd;
    FPort : integer;
    FEnable : boolean;
    FOnBrokerOffline: TMQTTDisconnectEvent;
    FOnBrokerOnline: TNotifyEvent;
    FOnBrokerEnableChange: TNotifyEvent;
    FOnObituary: TMQTTObituaryEvent;
    FOnEnableChange: TNotifyEvent;
    FLocalBounce: Boolean;
    FOnSubscription: TMQTTSubscriptionEvent;
    FOnFailure: TMQTTFailureEvent;
    FMaxRetries: integer;
    FRetryTime: cardinal;
    FOnStoreSession: TMQTTSessionEvent;
    FOnRestoreSession: TMQTTSessionEvent;
    FOnDeleteSession: TMQTTSessionEvent;
//    FOnRetain: TMQTTRetainEvent;
//    FOnGetRetained: TMQTTRetainedEvent;
    procedure TimerProc (var aMsg : TMessage);
    procedure DoMon (Sender: TObject; aStr : string);
    // broker events
    procedure BkrOnline (Sender : TObject);
    procedure BkrOffline (Sender : TObject; Graceful : boolean);
    procedure BkrEnableChanged (Sender : TObject);
    procedure BkrSubscriptionChange (Sender : TObject);
    procedure BkrMsg (Sender : TObject; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; aRetained : boolean);
    // socket events
    procedure DoClientConnect (Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure DoClientDisconnect (Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure DoClientCreate (Sender: TObject; Client: TWSocketClient);
    // parser events
    procedure RxDisconnect (Sender : TObject);
    procedure RxPing (Sender : TObject);
    procedure RxPublish (Sender : TObject; anID : Word; aTopic : UTF8String; aMessage : AnsiString);
    procedure RxHeader (Sender : TObject; MsgType: TMQTTMessageType; Dup: Boolean;
                        Qos: TMQTTQOSType; Retain: Boolean);
    procedure RxConnect (Sender : TObject;
                        aProtocol : UTF8String;
                        aVersion : byte;
                        aClientID,
                        aUserName, aPassword : UTF8String;
                        aKeepAlive : Word; aClean : Boolean);
    procedure RxBrokerConnect (Sender : TObject;      // non standard
                        aProtocol : UTF8String;
                        aVersion : byte;
                        aClientID,
                        aUserName, aPassword : UTF8String;
                        aKeepAlive : Word; aClean : Boolean);
    procedure SetMaxRetries (const Value: integer);
    procedure SetRetryTime (const Value: cardinal);
  public
    FOnMonHdr : TMQTTHeaderEvent;
    Server : TWSocketServer;
    MessageID : Word;
    Brokers : TList;    // of wsocket
    Sessions : TMQTTSessionStore;
    Retained : TMQTTMessageStore;
    function NextMessageID : Word;
    procedure Mon (aStr : string);
    procedure Activate (Enable : boolean);
    procedure LoadBrokers (anIniFile : string);
    procedure StoreBrokers (anIniFile : string);
    function GetClient (aParser : TMQTTParser) : TClient; overload;
    function GetClient (aClientID : UTF8String) : TClient; overload;

    procedure PublishToAll (From : TObject; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; wasRetained : boolean = false);
    function Enabled : boolean;
    function AddBroker (aHost : string; aPort : integer) : TMQTTClient;
    procedure SyncBrokerSubscriptions (aBroker : TMQTTClient);
    constructor Create (anOwner : TComponent); override;
    destructor Destroy; override;
  published
    property MaxRetries : integer read FMaxRetries write SetMaxRetries;
    property RetryTime : cardinal read FRetryTime write SetRetryTime;   // in secs
    property Port : integer read FPort write FPort;
    property LocalBounce : Boolean read FLocalBounce write FLocalBounce;
    property OnFailure : TMQTTFailureEvent read FOnFailure write FOnFailure;
    property OnStoreSession : TMQTTSessionEvent read FOnStoreSession write FOnStoreSession;
    property OnRestoreSession : TMQTTSessionEvent read FOnRestoreSession write FOnRestoreSession;
    property OnDeleteSession : TMQTTSessionEvent read FOnDeleteSession write FOnDeleteSession;
//    property OnRetain : TMQTTRetainEvent read FOnRetain write FOnRetain;
//    property OnGetRetained : TMQTTRetainedEvent read FOnGetRetained write FOnGetRetained;
    property OnBrokerOnline : TNotifyEvent read FOnBrokerOnline write FOnBrokerOnline;
    property OnBrokerOffline : TMQTTDisconnectEvent read FOnBrokerOffline write FOnBrokerOffline;
    property OnBrokerEnableChange : TNotifyEvent read FOnBrokerEnableChange write FOnBrokerEnableChange;
    property OnEnableChange : TNotifyEvent read FOnEnableChange write FOnEnableChange;
    property OnSubscription : TMQTTSubscriptionEvent read FOnSubscription write FOnSubscription;
    property OnClientsChange : TMQTTIDEvent read FOnClientsChange write FOnClientsChange;
    property OnCheckUser : TMQTTCheckUserEvent read FOnCheckUser write FOnCheckUser;
    property OnObituary : TMQTTObituaryEvent read FOnObituary write FOnObituary;
    property OnMon : TMQTTMonEvent read FOnMon write FOnMon;
  end;

procedure Register;
function SubTopics (aTopic : UTF8String) : TStringList;
function IsSubscribed (aSubscription, aTopic : UTF8String) : boolean;

implementation

uses
  SysUtils, IniFiles;

procedure Register;
begin
  RegisterComponents ('MQTT', [TMQTTServer, TMQTTClient]);
end;


function StateStr (aState: TSocketState): string;
begin
  case aState of
    wsInvalidState    : result := 'Invalid State';
    wsOpened          : result := 'Opened';
    wsBound           : result := 'Bound';
    wsConnecting      : Result := 'Connecting';
    wsSocksConnected  : Result := 'Sock Connected';
    wsConnected       : result := 'Connected';
    wsAccepting       : result := 'Accepting';
    wsListening       : result := 'Listening';
    wsClosed          : result := 'Closed';
  end;
end;

function SubTopics (aTopic : UTF8String) : TStringList;
var
  i : integer;
begin
  Result := TStringList.Create;
  Result.Add ('');
  for i := 1 to length (aTopic) do
    begin
      if aTopic[i] = '/' then
        Result.Add('')
      else
        Result[Result.Count - 1] := Result[Result.Count - 1] + Char (aTopic[i]);
    end;
end;

function IsSubscribed (aSubscription, aTopic : UTF8String) : boolean;
var
  s, t : TStringList;
  i : integer;
  MultiLevel : Boolean;
begin
  s := SubTopics (aSubscription);
  t := SubTopics (aTopic);
  MultiLevel := (s[s.Count - 1] = '#');   // last field is #
  if not MultiLevel then
    Result := (s.Count = t.Count)
  else
    Result := (s.Count <= t.Count + 1);
  if Result then
    begin
      for i := 0 to s.Count - 1 do
        begin
          if (i >= t.Count) then Result := MultiLevel
          else if (i = s.Count - 1) and (s[i] = '#') then break
          else if s[i] = '+' then continue    // they match
          else
            Result := Result and (s[i] = t[i]);
          if not Result then break;
        end;
    end;
  s.Free;
  t.Free;
end;

procedure SetDup (aStream : TMemoryStream; aState : boolean);
var
  x : byte;
begin
  if aStream.Size = 0 then exit;
  aStream.Seek (0, soFromBeginning);
  aStream.Read (x, 1);
  x := (x and $F7) or (ord (aState) * $08);
  aStream.Seek (0, soFromBeginning);
  aStream.Write (x, 1);
end;

{ TClient }

constructor TClient.Create (anOwner: TComponent);
begin
  inherited;
  FBroker := false;       // non standard
  Parser := TMQTTParser.Create;
  Parser.OnSend := DoSend;
  Parser.OnSetWill := DoSetWill;
  Parser.OnSubscribe := RxSubscribe;
  Parser.OnUnsubscribe := RxUnsubscribe;
  Parser.OnPubAck := RxPubAck;
  Parser.OnPubRel := RxPubRel;
  Parser.OnPubRec := RxPubRec;
  Parser.OnPubComp := RxPubComp;
  InFlight := TMQTTPacketStore.Create;
  Releasables := TMQTTMessageStore.Create;
  Subscriptions := TStringList.Create;
  OnDataAvailable := DoData;
end;

destructor TClient.Destroy;
begin
  InFlight.Clear;
  InFlight.Free;
  Releasables.Clear;
  Releasables.Free;
  Parser.Free;
  Subscriptions.Free;
  inherited;
end;

procedure TClient.DoData (Sender: TObject; ErrCode: Word);
begin
  if ErrCode = 0 then Parser.Parse (ReceiveStrA);
end;

procedure TClient.DoSend (Sender: TObject; anID : Word; aRetry : integer; aStream: TMemoryStream);
var
  x : byte;
begin
  if State = wsConnected then
    begin
      aStream.Seek (0, soFromBeginning);
      aStream.Read (x, 1);
      if (TMQTTQOSType ((x and $06) shr 1) in [qtAT_LEAST_ONCE, qtEXACTLY_ONCE]) and
         (TMQTTMessageType ((x and $f0) shr 4) in [{mtPUBREL,} mtPUBLISH, mtSUBSCRIBE, mtUNSUBSCRIBE]) and
         (anID > 0) then
        begin
          InFlight.AddPacket (anID, aStream, aRetry, Parser.RetryTime);      // start disabled
          mon (string (Parser.ClientID) + ' Message ' + IntToStr (anID) + ' created.');
        end;
      Send (aStream.Memory, aStream.Size);
      Sleep (0);
    end;
end;

procedure TClient.DoSetWill (Sender: TObject; aTopic, aMessage: UTF8String;
  aQos : TMQTTQOSType; aRetain: boolean);
begin
  Parser.WillTopic := aTopic;
  Parser.WillMessage := aMessage;
  Parser.WillQos := aQos;
  Parser.WillRetain := aRetain;
end;

procedure TClient.Mon (aStr: string);
begin
  if Assigned (FOnMon) then FOnMon (Self, aStr);
end;

procedure TClient.RxPubAck (Sender: TObject; anID: Word);
begin
  InFlight.DelPacket (anID);
  Mon (string (Parser.ClientID) + ' ACK Message ' + IntToStr (anID) + ' disposed of.');
end;

procedure TClient.RxPubComp (Sender: TObject; anID: Word);
begin
  InFlight.DelPacket (anID);
  Mon (string (Parser.ClientID) + ' COMP Message ' + IntToStr (anID) + ' disposed of.');
end;

procedure TClient.RxPubRec (Sender: TObject; anID: Word);
var
  aPacket : TMQTTPacket;
begin
  aPacket := InFlight.GetPacket (anID);
  if aPacket <> nil then
    begin
      aPacket.Counter := Parser.RetryTime;
      if aPacket.Publishing then
        begin
          aPacket.Publishing := false;
          Mon (string (Parser.ClientID) + ' REC Message ' + IntToStr (anID) + ' recorded.');
        end
      else
        Mon (string (Parser.ClientID) + ' REC Message ' + IntToStr (anID) + ' already recorded.');
    end
  else
    Mon (string (Parser.ClientID) + ' REC Message ' + IntToStr (anID) + ' not found.');
  Parser.SendPubRel (anID);
end;

procedure TClient.RxPubRel (Sender: TObject; anID: Word);
var
  aMsg : TMQTTMessage;
begin
  aMsg := Releasables.GetMsg (anID);
  if (aMsg <> nil) and (Owner.Owner is TMQTTServer) then
    begin
      Mon (string (Parser.ClientID) + ' REL Message ' + IntToStr (anID) + ' publishing @ ' + QOSNames[aMsg.Qos]);
      TMQTTServer (Owner.Owner).PublishToAll (Self, aMsg.Topic, aMsg.Message, aMsg.Qos);
      Releasables.Remove (aMsg);
      aMsg.Free;
      Mon (string (Parser.ClientID) + ' REL Message ' + IntToStr (anID) + ' removed from storage.');
    end
  else
    Mon (string (Parser.ClientID) + ' REL Message ' + IntToStr (anID) + ' has been already removed from storage.');
  Parser.SendPubComp (anID);
end;

procedure TClient.RxSubscribe (Sender: TObject; anID: Word; Topics: TStringList);
var
  x : cardinal;
  q : TMQTTQOSType;
  i, j : integer;
  found : boolean;
  Qoss : array of TMQTTQOSType;
  aServer : TMQTTServer;
  bMsg : TMQTTMessage;
  aQos : TMQTTQOSType;
begin
  SetLength (Qoss, Topics.Count);
  aServer := nil;
  if Owner is TWSocketServer then
    if Owner.Owner is TMQTTServer then
      aServer := TMQTTServer (Owner.Owner);
  if aServer = nil then exit;
  for i := 0 to Topics.Count - 1 do
    begin
      found := false;
      x := cardinal (Topics.Objects[i]) and $03;
      q := TMQTTQOSType (x);
      if Assigned (aServer.FOnSubscription) then
        aServer.FOnSubscription (Self, UTF8String (Topics[i]), q);
      for j := 0 to Subscriptions.Count - 1 do
        if Subscriptions[j] = Topics[i] then
          begin
            found := true;
            Subscriptions.Objects[j] := TObject (q);
            break;
          end;
      if not found then
        begin
          Subscriptions.AddObject (Topics[i], TObject (q));
        end;
      Qoss[i] := q;
      for j := 0 to aServer.Retained.Count - 1 do     // set retained
        begin
          bMsg := aServer.Retained[j];
          if IsSubscribed (UTF8String (Topics[i]), bMsg.Topic) then
            begin
              aQos := bMsg.Qos;
              if q < aQos then aQos := q;
              bMsg.LastUsed := Now;
              Parser.SendPublish (aServer.NextMessageID, bMsg.Topic, bMsg.Message, aQos, false, true);
            end;
        end;
    end;
  if Parser.RxQos = qtAT_LEAST_ONCE then Parser.SendSubAck (anID, Qoss);
  if Assigned (FOnSubscriptionChange) then FOnSubscriptionChange (Self);
end;

procedure TClient.RxUnsubscribe (Sender: TObject; anID: Word; Topics: TStringList);
var
  i, j : integer;
  changed : boolean;
begin
  changed := false;
  for i := 0 to Topics.Count - 1 do
    begin
      for j := Subscriptions.Count - 1 downto 0 do
        begin
          if Subscriptions[j] = Topics[i] then
            begin
              Subscriptions.Delete (j);
              changed := true;
            end;
        end;
    end;
  if changed and  Assigned (FOnSubscriptionChange) then
    FOnSubscriptionChange (Self);
  if Parser.RxQos = qtAT_LEAST_ONCE then Parser.SendUnSubAck (anID);
end;

{ TMQTTServer }

procedure TMQTTServer.Activate (Enable: boolean);
var
  i : integer;
begin
  if FEnable = Enable then exit;
  if (Enable) then
    begin
      Server.Banner := '';
      Server.Addr := '0.0.0.0';
      Server.Port := IntToStr (FPort);
      Server.Proto := 'tcp';
      Server.ClientClass := TClient;
      try
        Server.Listen;
        FEnable := true;
      except
        FEnable := false;
        end;
      if FEnable then SetTimer (Timers, 3, 100, nil);
    end
  else
    begin
      FEnable := false;
      for i := 0 to Server.ClientCount - 1 do
        try
          TClient (Server.Client[i]).Close;
        except
        end;
      try
        Server.Close;
      except
      end;
      KillTimer (Timers, 1);
      KillTimer (Timers, 2);
      KillTimer (Timers, 3);
    end;
  if Assigned (FOnEnableChange) then
    FOnEnableChange (Self);
end;

function TMQTTServer.AddBroker (aHost: string; aPort: integer): TMQTTClient;
begin
  Result := TMQTTClient.Create (Self);
  Result.Host := aHost;
  Result.Port := aPort;
  Result.Broker := true;
  Result.LocalBounce := false;
  Result.OnOnline := BkrOnline;
  Result.OnOffline := BkrOffline;
  Result.OnEnableChange := BkrEnableChanged;
  Result.OnMsg := BkrMsg;
  Brokers.Add (Result);
end;

procedure TMQTTServer.BkrEnableChanged (Sender: TObject);
begin
  if Assigned (FOnBrokerEnableChange) then
    FOnBrokerEnableChange (Sender);
end;

procedure TMQTTServer.BkrOffline (Sender: TObject; Graceful: boolean);
begin
  TMQTTClient (Sender).Subscriptions.Clear;
  if Assigned (FOnBrokerOffline) then
    FOnBrokerOffline (Sender, Graceful);
end;

procedure TMQTTServer.BkrOnline(Sender: TObject);
begin
  SyncBrokerSubscriptions (TMQTTClient (Sender));
  if Assigned (FOnBrokerOnline) then
    FOnBrokerOnline (Sender);
end;

procedure TMQTTServer.BkrMsg (Sender: TObject; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; aRetained : boolean);
var
  aBroker : TMQTTClient;
  i : integer;
  aMsg : TMQTTMessage;
begin
  aBroker := TMQTTClient (Sender);
  mon ('Received Retained Message from a Broker - Retained ' + ny[aRetained]);
  if aRetained then
    begin
      mon ('Retaining "' + string (aTopic) + '" @ ' + QOSNames[aQos]);
      for i := Retained.Count - 1 downto 0 do
        begin
          aMsg := Retained[i];
          if aMsg.Topic = aTopic then
            begin
              Retained.Remove (aMsg);
              aMsg.Free;
              break;
            end;
        end;
      Retained.AddMsg (0, aTopic, aMessage, aQos, 0, 0);
    end
  else
    mon ('Received Message from a Broker - Publishing..');
  PublishToAll (Sender, aTopic, aMessage, aBroker.Parser.RxQos, aRetained);
end;

procedure TMQTTServer.BkrSubscriptionChange(Sender: TObject);
var
  i : integer;
begin
  mon ('Subscriptions changed...');
  for i := 0 to Brokers.Count - 1 do
    SyncBrokerSubscriptions (TMQTTClient (Brokers[i]));
end;

constructor TMQTTServer.Create (anOwner: TComponent);
begin
  inherited;
  Timers := AllocateHWnd (TimerProc);
  MessageID := 1000;
  FOnMonHdr := nil;
  FPort := 1883;
  FMaxRetries := DefMaxRetries;
  FRetryTime := DefRetryTime;
  Brokers := TList.Create;
  Sessions := TMQTTSessionStore.Create;
  Retained := TMQTTMessageStore.Create;
  Server := TWSocketServer.Create (Self);
  Server.OnClientCreate := DoClientCreate;
  Server.OnClientDisconnect := DoClientDisconnect;
  Server.OnClientConnect := DoClientConnect;
end;

destructor TMQTTServer.Destroy;
var
  i : integer;
begin
  DeallocateHWnd (Timers);
  for i := 0 to Brokers.Count - 1 do
    TMQTTClient (Brokers[i]).Free;
  Brokers.Free;
  Retained.Free;
  Sessions.Free;
  Activate (false);
  Server.Free;
  inherited;
end;

procedure TMQTTServer.RxPing (Sender: TObject);
begin
  if not (Sender is TMQTTParser) then exit;
  TMQTTParser (Sender).SendPingResp;
end;

procedure TMQTTServer.RxPublish (Sender: TObject; anID: Word; aTopic : UTF8String;
  aMessage: AnsiString);
var
  aParser : TMQTTParser;
  aClient : TClient;
  aMsg : TMQTTMessage;
  i : integer;

begin
  if not (Sender is TMQTTParser) then exit;
  aParser := TMQTTParser (Sender);
  aClient := GetClient (aParser);
  if aClient = nil then exit;
  if aParser.RxRetain then
    begin
      mon ('Retaining "' + string (aTopic) + '" @ ' + QOSNames[aParser.RxQos]);
      for i := Retained.Count - 1 downto 0 do
        begin
          aMsg := Retained[i];
          if aMsg.Topic = aTopic then
            begin
              Retained.Remove (aMsg);
              aMsg.Free;
              break;
            end;
        end;
      Retained.AddMsg (0, aTopic, aMessage, aParser.RxQos, 0, 0);
    end;
  case aParser.RxQos of
    qtAT_MOST_ONCE  :
      PublishToAll (aClient, aTopic, aMessage, aParser.RxQos, aParser.RxRetain);
    qtAT_LEAST_ONCE :
      begin
        aParser.SendPubAck (anID);
        PublishToAll (aClient, aTopic, aMessage, aParser.RxQos, aParser.RxRetain);
      end;
    qtEXACTLY_ONCE  :
      begin
        aMsg := aClient.Releasables.GetMsg (anID);
        if aMsg = nil then
          begin
            aClient.Releasables.AddMsg (anID, aTopic, aMessage, aParser.RxQos, 0, 0);
            mon (string (aClient.Parser.ClientID) + ' Message ' + IntToStr (anID) + ' stored and idle.');
          end
        else
          mon (string (aClient.Parser.ClientID) + ' Message ' + IntToStr (anID) + ' already stored.');
        aParser.SendPubRec (anID);
      end;
  end;
end;

procedure TMQTTServer.LoadBrokers (anIniFile: string);
var
  i : integer;
  Sections : TStringList;
  aBroker : TMQTTClient;
  EnFlag : Boolean;
begin
  for i := 0 to Brokers.Count - 1 do
    TMQTTClient (Brokers[i]).Free;
  Brokers.Clear;
  Sections := TStringList.Create;
  with TIniFile.Create (anIniFile) do
    begin
      ReadSections (Sections);
      for i := 0 to Sections.Count - 1 do
        begin
          if Copy (Sections[i], 1, 6) = 'BROKER' then
            begin
              aBroker := AddBroker ('', 0);
              aBroker.Host := ReadString (Sections[i], 'Prim Host', '');
              aBroker.Port := ReadInteger (Sections[i], 'Port', 1883);
              EnFlag := ReadBool (Sections[i], 'Enabled', false);
              if EnFlag then aBroker.Activate (true);
            end;
        end;
      Free;
    end;
  Sections.Free;
end;

procedure TMQTTServer.SetMaxRetries (const Value: integer);
var
  i : integer;
begin
  FMaxRetries := Value;
  for i := 0 to Server.ClientCount - 1 do
    TClient (Server.Client[i]).Parser.MaxRetries := Value;
 for i := 0 to Brokers.Count - 1 do
    TMQTTClient (Brokers[i]).Parser.MaxRetries := Value;
end;

procedure TMQTTServer.SetRetryTime (const Value: cardinal);
var
  i : integer;
begin
  FRetryTime := Value;
  for i := 0 to Server.ClientCount - 1 do
    TClient (Server.Client[i]).Parser.KeepAlive := Value;
 for i := 0 to Brokers.Count - 1 do
    TMQTTClient (Brokers[i]).Parser.KeepAlive := Value;
end;

procedure TMQTTServer.StoreBrokers (anIniFile: string);
var
  i : integer;
  aBroker : TMQTTClient;
  Sections : TStringList;
begin
  Sections := TStringList.Create;
  with TIniFile.Create (anIniFile) do
    begin
      ReadSections (Sections);
      for i := 0 to Sections.Count - 1 do
        if Copy (Sections[i], 1, 6) = 'BROKER' then
          EraseSection (Sections[i]);
      for i := 0 to Brokers.Count - 1 do
        begin
          aBroker := Brokers[i];
          WriteString (format ('BROKER%.3d', [i]), 'Prim Host', aBroker.Host);
          WriteInteger (format ('BROKER%.3d', [i]), 'Port', aBroker.Port);
          WriteBool (format ('BROKER%.3d', [i]), 'Enabled', aBroker.Enabled);
        end;
      Free;
    end;
  Sections.Free;
end;

procedure TMQTTServer.SyncBrokerSubscriptions (aBroker: TMQTTClient);
var
  i, j, k : integer;
  x : cardinal;
  ToSub, ToUnsub : TStringList;
  aClient : TClient;
  found : boolean;
begin
  ToSub := TStringList.Create;
  ToUnsub := TStringList.Create;
  for i := 0 to Server.ClientCount - 1 do
    begin
      aClient := TClient (Server.Client[i]);
      for j := 0 to aClient.Subscriptions.Count - 1 do
        begin
          found := false;
          for k := 0 to ToSub.Count - 1 do
            begin
              if aClient.Subscriptions[j] = ToSub[k] then
                begin
                  found := true;
                  break;
                end;
            end;
          if not found then ToSub.AddObject (aClient.Subscriptions[j], aClient.Subscriptions.Objects[j]);
        end;
    end;
  // add no longer used to unsubscribe
  for i := aBroker.Subscriptions.Count - 1 downto 0 do
    begin
      found := false;
      for j := 0 to ToSub.Count - 1 do
        begin
          if aBroker.Subscriptions[i] = ToSub[j] then
            begin
              x := cardinal (aBroker.Subscriptions.Objects[i]) and $03;      // change to highest
              if x > (cardinal (ToSub.Objects[j]) and $03) then
                ToSub.Objects[j] := TObject (x);
              found := true;
              break;
            end;
        end;
      if not found then
        ToUnsub.AddObject (aBroker.Subscriptions[i], aBroker.Subscriptions.Objects[i]);
    end;
  // remove those already subscribed to
  for i := 0 to aBroker.Subscriptions.Count - 1 do
    begin
      for j := ToSub.Count - 1 downto 0 do
        begin
          if aBroker.Subscriptions[i] = ToSub[j] then
            ToSub.Delete (j);     // already subscribed
        end;
    end;
  for i := 0 to ToSub.Count - 1 do
    aBroker.Subscribe (UTF8String (ToSub[i]), TMQTTQOSType (cardinal (ToSub.Objects[i]) and $03));
  for i := 0 to ToUnsub.Count - 1 do
    aBroker.Unsubscribe (UTF8String (ToUnsub[i]));
  ToSub.Free;
  ToUnsub.Free;
end;

procedure TMQTTServer.Mon (aStr: string);
begin
  if Assigned (FOnMon) then FOnMon (Self, aStr);
end;

function TMQTTServer.NextMessageID: Word;
var
  i, j : integer;
  Unused : boolean;
  aMsg : TMQTTPacket;
  aClient : TClient;
begin
  repeat
    Unused := true;
    MessageID := MessageID + 1;
    if MessageID = 0 then MessageID := 1;   // exclude 0
    for i := 0 to Server.ClientCount - 1 do
      begin
        aClient := TClient (Server.Client[i]);
        for j := 0 to aClient.InFlight.Count - 1 do
          begin
            aMsg := aClient.InFlight[j];
            if aMsg.ID = MessageID then
              begin
                Unused := false;
                break;
              end;
          end;
        if not Unused then break;
      end;
  until Unused;
  Result := MessageID;
end;

procedure TMQTTServer.PublishToAll (From : TObject; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; wasRetained : boolean);
var
  i, j : integer;
  sent : boolean;
  aClient : TClient;
  aBroker : TMQTTClient;
  bQos : TMQTTQOSType;
begin
  mon ('Publishing -- Was Retained ' + ny[wasRetained]);
  for i := 0 to Server.ClientCount - 1 do
    begin
      aClient := TClient (Server.Client[i]);
      if (aClient = From) and (aClient.FBroker) then continue;  // don't send back to self if broker - non standard
      //not LocalBounce then continue;
      sent := false;
      for j := 0 to aClient.Subscriptions.Count - 1 do
        begin
          if IsSubscribed (UTF8String (aClient.Subscriptions[j]), aTopic) then
            begin
              bQos := TMQTTQOSType (cardinal (aClient.Subscriptions.Objects[j]) and $03);
              if aClient.FBroker then
                 mon ('Publishing to Broker ' + string (aClient.Parser.ClientID) + ' "' + string (aTopic) + '" Retained ' + ny[wasRetained and aClient.FBroker])

              else
                mon ('Publishing to Client ' + string (aClient.Parser.ClientID) + ' "' + string (aTopic) + '"');
              if bQos > aQos then bQos := aQos;
              aClient.Parser.SendPublish (NextMessageID, aTopic, aMessage, bQos, false, wasRetained and aClient.FBroker);
              sent := true;
              break;    // only do first
            end;
        end;
      if (not sent) and (wasRetained) and (aClient.FBroker) then
        begin
          mon ('Forwarding Retained message to broker');
          aClient.Parser.SendPublish (NextMessageID, aTopic, aMessage, qtAT_LEAST_ONCE, false, true);
        end;
    end;
  for i := 0 to Brokers.Count - 1 do    // brokers get all messages -> downstream
    begin
      aBroker := TMQTTClient (Brokers[i]);
      if aBroker = From then continue;
      if not aBroker.Enabled then continue;
    //  if aBroker then
      mon ('Publishing to Broker ' + string (aBroker.ClientID) + ' "' + string (aTopic) + '" @ ' + QOSNames[aQos] + ' Retained ' + ny[wasretained]);
      aBroker.Publish (aTopic, aMessage, aQos, wasRetained);
   end;
end;

procedure TMQTTServer.TimerProc (var aMsg: TMessage);
var
  i, j : integer;
  bPacket : TMQTTPacket;
  aClient : TClient;
  WillClose : Boolean;
begin
  if aMsg.Msg = WM_TIMER then
    begin
      KillTimer (Timers, aMsg.WParam);
  //    Mon ('Timer ' + IntToStr (aMsg.WParam) + ' triggered');
      case aMsg.WParam of
        3 : begin
              for i := Server.ClientCount - 1 downto 0 do
                begin
                  aClient := TClient (Server.Client[i]);
                  if not aClient.Parser.CheckKeepAlive then
                    begin
                      WillClose := true;
                      if Assigned (FOnFailure) then FOnFailure (aClient, frKEEPALIVE, WillClose);
                      if WillClose then aClient.CloseDelayed;
                    end
                  else
                    begin
                      for j := aClient.InFlight.Count - 1 downto 0 do
                        begin
                          bPacket := aClient.InFlight[j];
                          if bPacket.Counter > 0 then
                            begin
                              bPacket.Counter := bPacket.Counter - 1;
                              if bPacket.Counter = 0 then
                                begin
                                  bPacket.Retries := bPacket.Retries + 1;
                                  if bPacket.Retries <= aClient.Parser.MaxRetries then
                                    begin
                                      if bPacket.Publishing then
                                        begin
                                          aClient.InFlight.List.Remove (bPacket);
                                          mon ('Message ' + IntToStr (bPacket.ID) + ' disposed of..');
                                          mon ('Re-issuing Message ' + inttostr (bPacket.ID) + ' Retry ' + inttostr (bPacket.Retries));
                                          SetDup (bPacket.Msg, true);
                                          aClient.DoSend (aClient.Parser, bPacket.ID, bPacket.Retries, bPacket.Msg);
                                          bPacket.Free;
                                        end
                                      else
                                        begin
                                          mon ('Re-issuing PUBREL Message ' + inttostr (bPacket.ID) + ' Retry ' + inttostr (bPacket.Retries));
                                          aClient.Parser.SendPubRel (bPacket.ID, true);
                                          bPacket.Counter := aClient.Parser.RetryTime;
                                        end;
                                    end
                                  else
                                    begin
                                      WillClose := true;
                                      if Assigned (FOnFailure) then FOnFailure (Self, frMAXRETRIES, WillClose);
                                      if WillClose then aClient.CloseDelayed;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
              SetTimer (Timers, 3, 100, nil);
            end;
        end;
  end;
end;

procedure TMQTTServer.DoClientConnect (Sender: TObject; Client: TWSocketClient;
  Error: Word);
begin
  if Sender = Server then
    Mon ('Client Connected...');
end;

procedure TMQTTServer.DoClientCreate (Sender: TObject; Client: TWSocketClient);
begin
  with TClient (Client) do
    begin
      Parser.OnPing := RxPing;
      Parser.OnDisconnect := RxDisconnect;
      Parser.OnPublish := RxPublish;
      Parser.OnPubRec := RxPubRec;
      Parser.OnConnect := RxConnect;
      Parser.OnBrokerConnect := RxBrokerConnect;    // non standard
      Parser.OnHeader := RxHeader;
      Parser.MaxRetries := FMaxRetries;
      Parser.RetryTime := FRetryTime;
      OnMon := DoMon;
      OnSubscriptionChange := BkrSubscriptionChange;
  end;
end;

procedure TMQTTServer.DoClientDisconnect (Sender: TObject;
  Client: TWSocketClient; Error: Word);
var
  aTopic, aMessage : UTF8String;
  aQos : TMQTTQOSType;
begin
  with TClient (Client) do
    begin
      Mon ('Client Disconnected.  Graceful ' + ny[TClient (Client).FGraceful]);
      if (InFlight.Count > 0) or (Releasables.Count > 0) then
        begin
          if Assigned (FOnStoreSession) then
            FOnStoreSession (Client, Parser.ClientID)
          else
            Sessions.StoreSession (Parser.ClientID, TClient (Client));
        end;
      if not FGraceful then
        begin
          aTopic := Parser.WillTopic;
          aMessage := Parser.WillMessage;
          aQos := Parser.WillQos;
          if Assigned (FOnObituary) then
            FOnObituary (Client, aTopic, aMessage, aQos);
          PublishToAll (nil, aTopic, AnsiString (aMessage), aQos);
        end;
    end;
  if Assigned (FOnClientsChange) then
    FOnClientsChange (Server, Server.ClientCount - 1);
end;

procedure TMQTTServer.DoMon (Sender: TObject; aStr: string);
begin
  Mon (aStr);
end;

function TMQTTServer.Enabled: boolean;
begin
  Result := FEnable;
end;

function TMQTTServer.GetClient (aClientID: UTF8String): TClient;
var
  i : integer;
begin
  for i := 0 to Server.ClientCount - 1 do
    begin
      Result := TClient (Server.Client[i]);
      if Result.Parser.ClientID = aClientID then exit;
    end;
(*  for i := 0 to BrokerServer.ClientCount - 1 do
    begin
      Result := TClient (BrokerServer.Client[i]);
      if Result.Parser.ClientID = aClientID then exit;
    end;       *)
  Result := nil;
end;

function TMQTTServer.GetClient (aParser: TMQTTParser): TClient;
var
  i : integer;
begin
  for i := 0 to Server.ClientCount - 1 do
    begin
      Result := TClient (Server.Client[i]);
      if Result.Parser = aParser then exit;
    end;
(*  for i := 0 to BrokerServer.ClientCount - 1 do
    begin
      Result := TClient (BrokerServer.Client[i]);
      if Result.Parser = aParser then exit;
    end;       *)
  Result := nil;
end;


procedure TMQTTServer.RxBrokerConnect(Sender: TObject; aProtocol: UTF8String;
  aVersion: byte; aClientID, aUserName, aPassword: UTF8String; aKeepAlive: Word;
  aClean: Boolean);
var
  aClient : TClient;
begin
  if not (Sender is TMQTTParser) then exit;
  aClient := GetClient (TMQTTParser (Sender));
  if aClient = nil then exit;
  aClient.FBroker := true;
  RxConnect (Sender, aProtocol, aVersion, aClientID, aUserName, aPassword, aKeepAlive, aClean);
end;

procedure TMQTTServer.RxConnect (Sender: TObject; aProtocol: UTF8String;
  aVersion: byte; aClientID, aUserName, aPassword: UTF8String; aKeepAlive: Word;
  aClean: Boolean);
var
  aClient : TClient;
  aServer : TWSocketServer;
  Allowed : Boolean;
begin
  Allowed := false;
  if not (Sender is TMQTTParser) then exit;
  aClient := GetClient (TMQTTParser (Sender));
  if aClient = nil then exit;
  aServer := TWSocketServer (aClient.Owner);
  aClient.FGraceful := true;
  if Assigned (FOnCheckUser) then
    FOnCheckUser (aServer, aUserName, aPassword, Allowed);
  if Allowed then
    begin
      if aVersion < MinVersion then
        begin
          aClient.Parser.SendConnAck (rcPROTOCOL);  // identifier rejected
          aClient.CloseDelayed;
        end
      else if (length (aClientID) < 1) or (length (aClientID) > 23) then
        begin
          aClient.Parser.SendConnAck (rcIDENTIFIER);  // identifier rejected
          aClient.CloseDelayed;
        end
      else if GetClient (aClientID) <> nil then
        begin
          aClient.Parser.SendConnAck (rcIDENTIFIER);  // identifier rejected
          aClient.CloseDelayed;
        end
      else
        begin
      //    mon ('Client ID ' + ClientID + ' User '  + striUserName + ' Pass ' + PassWord);
          aClient.Parser.Username := aUserName;
          aClient.Parser.Password := aPassword;
          aClient.Parser.ClientID := aClientID;
          aClient.Parser.KeepAlive := aKeepAlive;
          aClient.Parser.Clean := aClean;
          mon ('Clean ' + ny[aClean]);
          if not aClean then
            begin
              if Assigned (FOnRestoreSession) then
                FOnRestoreSession (aClient, aClientID)
              else
                Sessions.RestoreSession (aClientID, aClient);
            end;
          if Assigned (FOnDeleteSession) then
            FOnDeleteSession (aClient, aClientID)
          else
            Sessions.DeleteSession (aClientID);
          aClient.Parser.SendConnAck (rcACCEPTED);
          aClient.FGraceful := false;
          mon ('Accepted. Is Broker ' + ny[aClient.FBroker]);
          if Assigned (FOnClientsChange) then
            FOnClientsChange (aServer, aServer.ClientCount);
        end;
    end
  else
    begin
      aClient.Parser.SendConnAck (rcUSER);
      aClient.CloseDelayed;
    end;
end;

procedure TMQTTServer.RxDisconnect (Sender: TObject);
var
  aClient : TClient;
begin
  if not (Sender is TMQTTParser) then exit;
  aClient := GetClient (TMQTTParser (Sender));
  if aClient = nil then exit;
  aClient.FGraceful := true;
end;

procedure TMQTTServer.RxHeader (Sender: TObject; MsgType: TMQTTMessageType;
  Dup: Boolean; Qos: TMQTTQOSType; Retain: Boolean);
begin
  if Assigned (FOnMonHdr) then FOnMonHdr (Self, MsgType, Dup, Qos, Retain);
end;

{ TMQTTClient }

procedure TMQTTClient.Activate (Enable: Boolean);
begin
  if Enable = FEnable then exit;
  FEnable := Enable;
  try
    if (Link.State = wsConnected) then
      begin
        Parser.SendDisconnect;
        FGraceful := true;
      end;
    Link.CloseDelayed;
  except
    end;
  if Enable then
    SetTimer (Timers, 1, 100, nil)
  else
    begin
      KillTimer (Timers, 1);
      KillTimer (Timers, 2);
      KillTimer (Timers, 3);
    end;
  if Assigned (FOnEnableChange) then FOnEnableChange (Self);
end;

constructor TMQTTClient.Create (anOwner: TComponent);
begin
  inherited;
  FHost := '';
  FUsername := '';
  FPassword := '';
  FPort := 1883;
  FEnable := false;
  FGraceful := false;
  FOnline := false;
  FBroker := false;         // non standard
  FLocalBounce := false;
  FAutoSubscribe := false;
  FMessageID := 0;
  Subscriptions := TStringList.Create;
  Releasables := TMQTTMessageStore.Create;
  Parser := TMQTTParser.Create;
  Parser.OnSend := DoSend;
  Parser.OnConnAck := RxConnAck;
  Parser.OnPublish := RxPublish;
  Parser.OnSubAck := RxSubAck;
  Parser.OnUnsubAck := RxUnsubAck;
  Parser.OnPubAck := RxPubAck;
  Parser.OnPubRel := RxPubRel;
  Parser.OnPubRec := RxPubRec;
  Parser.OnPubComp := RxPubComp;
  Parser.KeepAlive := 10;
  Timers := AllocateHWnd (TimerProc);
  InFlight := TMQTTPacketStore.Create;
  Link := TWSocket.Create (Self);
  Link.OnDataAvailable := LinkData;
  Link.OnSessionConnected := LinkConnected;
  Link.OnSessionClosed := LinkClosed;
end;

destructor TMQTTClient.Destroy;
begin
  Releasables.Clear;
  Releasables.Free;
  Subscriptions.Free;
  InFlight.Clear;
  InFlight.Free;
  KillTimer (Timers, 1);
  KillTimer (Timers, 2);
  KillTimer (Timers, 3);
  DeAllocateHWnd (Timers);
  try
    Link.Close;
  finally
    Link.Free;
  end;
  Parser.Free;
  inherited;
end;

procedure TMQTTClient.RxConnAck (Sender: TObject; aCode: byte);
var
  i : integer;
  x : cardinal;
begin
  Mon ('Connection ' + codenames(aCode));
  if aCode = rcACCEPTED then
    begin
      FOnline := true;
      FGraceful := false;
      SetTimer (Timers, 3, 100, nil);  // start retry counters
      if Assigned (FOnOnline) then FOnOnline (Self);
      if (FAutoSubscribe) and (Subscriptions.Count > 0) then
        begin
          for i := 0 to Subscriptions.Count - 1 do
            begin
              x := cardinal (Subscriptions.Objects[i]) and $03;
              Parser.SendSubscribe (NextMessageID, UTF8String (Subscriptions[i]), TMQTTQOSType (x));
            end;
        end;
    end
  else
    Activate (false); // not going to connect
end;
// publishing
procedure TMQTTClient.RxPublish (Sender: TObject; anID: Word; aTopic : UTF8String;
  aMessage : AnsiString);
var
  aMsg : TMQTTMessage;
begin
  case Parser.RxQos of
    qtAT_MOST_ONCE  :
      if Assigned (FOnMsg) then FOnMsg (Self, aTopic, aMessage, Parser.RxQos, Parser.RxRetain);
    qtAT_LEAST_ONCE :
      begin
        Parser.SendPubAck (anID);
        if Assigned (FOnMsg) then FOnMsg (Self, aTopic, aMessage, Parser.RxQos, Parser.RxRetain);
      end;
    qtEXACTLY_ONCE  :
      begin
        Parser.SendPubRec (anID);
        aMsg := Releasables.GetMsg (anID);
        if aMsg = nil then
          begin
            Releasables.AddMsg (anID, aTopic, aMessage, Parser.RxQos, 0, 0, Parser.RxRetain);
            mon ('Message ' + IntToStr (anID) + ' stored and idle.');
          end
        else
          mon ('Message ' + IntToStr (anID) + ' already stored.');
      end;
  end;
end;

procedure TMQTTClient.RxPubAck (Sender: TObject; anID: Word);
begin
  InFlight.DelPacket (anID);
  Mon ('ACK Message ' + IntToStr (anID) + ' disposed of.');
end;

procedure TMQTTClient.RxPubComp (Sender: TObject; anID: Word);
begin
  InFlight.DelPacket (anID);
  Mon ('COMP Message ' + IntToStr (anID) + ' disposed of.');
end;

procedure TMQTTClient.RxPubRec (Sender: TObject; anID: Word);
var
  aPacket : TMQTTPacket;
begin
  aPacket := InFlight.GetPacket (anID);
  if aPacket <> nil then
    begin
      aPacket.Counter := Parser.RetryTime;
      if aPacket.Publishing then
        begin
          aPacket.Publishing := false;
          Mon ('REC Message ' + IntToStr (anID) + ' recorded.');
        end
      else
        Mon ('REC Message ' + IntToStr (anID) + ' already recorded.');
    end
  else
    Mon ('REC Message ' + IntToStr (anID) + ' not found.');
  Parser.SendPubRel (anID);
end;

procedure TMQTTClient.RxPubRel (Sender: TObject; anID: Word);
var
  aMsg : TMQTTMessage;
begin
  aMsg := Releasables.GetMsg (anID);
  if aMsg <> nil then
    begin
      Mon ('REL Message ' + IntToStr (anID) + ' publishing @ ' + QOSNames[aMsg.Qos]);
      if Assigned (FOnMsg) then FOnMsg (Self, aMsg.Topic, aMsg.Message, aMsg.Qos, aMsg.Retained);
      Releasables.Remove (aMsg);
      aMsg.Free;
      Mon ('REL Message ' + IntToStr (anID) + ' removed from storage.');
    end
  else
    Mon ('REL Message ' + IntToStr (anID) + ' has been already removed from storage.');
  Parser.SendPubComp (anID);
end;

procedure TMQTTClient.SetClean (const Value: Boolean);
begin
  Parser.Clean := Value;
end;

procedure TMQTTClient.SetClientID (const Value: UTF8String);
begin
  Parser.ClientID := Value;
end;

procedure TMQTTClient.SetKeepAlive (const Value: Word);
begin
  Parser.KeepAlive := Value;
end;

procedure TMQTTClient.SetMaxRetries (const Value: integer);
begin
  Parser.MaxRetries := Value;
end;

procedure TMQTTClient.SetPassword (const Value: UTF8String);
begin
  Parser.Password := Value;
end;

procedure TMQTTClient.SetRetryTime (const Value: cardinal);
begin
  Parser.RetryTime := Value;
end;

procedure TMQTTClient.SetUsername (const Value: UTF8String);
begin
  Parser.UserName := Value;
end;

procedure TMQTTClient.SetWill (aTopic, aMessage : UTF8String; aQos: TMQTTQOSType;
  aRetain: Boolean);
begin
  Parser.SetWill (aTopic, aMessage, aQos, aRetain);
end;

procedure TMQTTClient.Subscribe (Topics: TStringList);
var
  j : integer;
  i, x : cardinal;
  anID : Word;
  found : boolean;
begin
  if Topics = nil then exit;
  anID := NextMessageID;
  for i := 0 to Topics.Count - 1 do
    begin
      found := false;
      // 255 denotes acked
      if i > 254 then
        x := (cardinal (Topics.Objects[i]) and $03)
      else
        x := (cardinal (Topics.Objects[i]) and $03) + (anID shl 16) + (i shl 8) ;
      for j := 0 to Subscriptions.Count - 1 do
        if Subscriptions[j] = Topics[i] then
          begin
            found := true;
            Subscriptions.Objects[j] := TObject (x);
            break;
          end;
      if not found then
        Subscriptions.AddObject (Topics[i], TObject (x));
    end;
  Parser.SendSubscribe (anID, Topics);
end;

procedure TMQTTClient.Subscribe (aTopic: UTF8String; aQos: TMQTTQOSType);
var
  i : integer;
  x : cardinal;
  found : boolean;
  anID : Word;
begin
  if aTopic = '' then exit;
  found := false;
  anID := NextMessageID;
  x := ord (aQos) + (anID shl 16);
  for i := 0 to Subscriptions.Count - 1 do
    if Subscriptions[i] = string (aTopic) then
      begin
        found := true;
        Subscriptions.Objects[i] := TObject (x);
        break;
      end;
  if not found then
    Subscriptions.AddObject (string (aTopic), TObject (x));
  Parser.SendSubscribe (anID, aTopic, aQos);
end;

procedure TMQTTClient.DoSend (Sender: TObject; anID : Word; aRetry : integer; aStream: TMemoryStream);
var
  x : byte;
begin
  if Link.State = wsConnected then
    begin
      KillTimer (Timers, 2);       // 75% of keep alive
      if KeepAlive > 0 then SetTimer (Timers, 2, KeepAlive * 750, nil);
      aStream.Seek (0, soFromBeginning);
      aStream.Read (x, 1);
      if (TMQTTQOSType ((x and $06) shr 1) in [qtAT_LEAST_ONCE, qtEXACTLY_ONCE]) and
         (TMQTTMessageType ((x and $f0) shr 4) in [{mtPUBREL,} mtPUBLISH, mtSUBSCRIBE, mtUNSUBSCRIBE]) and
         (anID > 0) then
        begin
          InFlight.AddPacket (anID, aStream, aRetry, Parser.RetryTime);
          mon ('Message ' + IntToStr (anID) + ' created.');
        end;
      Link.Send (aStream.Memory, aStream.Size);
      Sleep (0);
    end;
end;

function TMQTTClient.Enabled: boolean;
begin
  Result := FEnable;
end;

function TMQTTClient.GetClean: Boolean;
begin
  Result := Parser.Clean;
end;

function TMQTTClient.GetClientID: UTF8String;
begin
  Result := Parser.ClientID;
end;

function TMQTTClient.GetKeepAlive: Word;
begin
  Result := Parser.KeepAlive;
end;

function TMQTTClient.GetMaxRetries: integer;
begin
  Result := Parser.MaxRetries;
end;

function TMQTTClient.GetPassword: UTF8String;
begin
  Result := Parser.Password;
end;

function TMQTTClient.GetRetryTime: cardinal;
begin
  Result := Parser.RetryTime;
end;

function TMQTTClient.GetUsername: UTF8String;
begin
  Result := Parser.UserName;
end;

procedure TMQTTClient.RxSubAck (Sender: TObject; anID: Word; Qoss : array of TMQTTQosType);
var
  j : integer;
  i, x : cardinal;
begin
  InFlight.DelPacket (anID);
  Mon ('Message ' + IntToStr (anID) + ' disposed of.');
  for i := low (Qoss) to high (Qoss) do
    begin
      if i > 254 then break;      // only valid for first 254
      for j := 0 to Subscriptions.Count - 1 do
        begin
          x := cardinal (Subscriptions.Objects[j]);
          if (hiword (x) = anID) and ((x and $0000ff00) shr 8 = i) then
            Subscriptions.Objects[j] :=  TObject ($ff00 + ord (Qoss[i]));
        end;
    end;
end;

procedure TMQTTClient.RxUnsubAck (Sender: TObject; anID: Word);
begin
  InFlight.DelPacket (anID);
  Mon ('Message ' + IntToStr (anID) + ' disposed of.');
end;

procedure TMQTTClient.LinkConnected (Sender: TObject; ErrCode: Word);
var
  aClientID : UTF8String;

  function TimeString : UTF8string;
  begin
//  86400  secs
    Result := UTF8String (IntToHex (Trunc (Date), 5) + IntToHex (Trunc (Frac (Time) * 864000), 7));
  end;

begin
  if ErrCode = 0 then
    begin
      FGraceful := false;    // still haven't connected but expect to
      Parser.Reset;
   //   mon ('Time String : ' + Timestring);
   //=   mon ('xaddr ' + Link.GetXAddr);
      aClientID := ClientID;
      if aClientID = '' then
        aClientID := 'CID' + UTF8String (Link.GetXPort); // + TimeString;
      if Assigned (FOnClientID) then
        FOnClientID (Self, aClientID);
      ClientID := aClientID;
      if Parser.Clean then
        begin
          InFlight.Clear;
          Releasables.Clear;
        end;
      if FBroker then
        Parser.SendBrokerConnect (aClientID, Parser.UserName, Parser.Password, KeepAlive, Parser.Clean)
      else
        Parser.SendConnect (aClientID, Parser.UserName, Parser.Password, KeepAlive, Parser.Clean);
    end;
end;

procedure TMQTTClient.LinkData (Sender: TObject; ErrCode: Word);
begin
  if ErrCode = 0 then Parser.Parse (Link.ReceiveStrA);
end;

procedure TMQTTClient.Mon(aStr: string);
begin
  if Assigned (FOnMon) then FOnMon (Self, aStr);
end;

function TMQTTClient.NextMessageID: Word;
var
  i : integer;
  Unused : boolean;
  aMsg : TMQTTPacket;
begin
  repeat
    Unused := true;
    FMessageID := FMessageID + 1;
    if FMessageID = 0 then FMessageID := 1;   // exclude 0
    for i := 0 to InFlight.Count - 1 do
      begin
        aMsg := InFlight.List[i];
        if aMsg.ID = FMessageID then
          begin
            Unused := false;
            break;
          end;
      end;
  until Unused;
  Result := FMessageID;
end;

function TMQTTClient.Online: boolean;
begin
  Result := FOnline;
end;

procedure TMQTTClient.Ping;
begin
  Parser.SendPing;
end;

procedure TMQTTClient.Publish (aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; aRetain : Boolean);
var
  i : integer;
  found : boolean;
begin
  if FLocalBounce and Assigned (FOnMsg) then
    begin
      found := false;
      for i := 0 to Subscriptions.Count - 1 do
        if IsSubscribed (UTF8String (Subscriptions[i]), aTopic) then
          begin
            found := true;
            break;
          end;
      if found then
        begin
          Parser.RxQos := aQos;
          FOnMsg (Self, aTopic, aMessage, aQos, false);
        end;
    end;
  Parser.SendPublish (NextMessageID, aTopic, aMessage, aQos, false, aRetain);
end;

procedure TMQTTClient.TimerProc (var aMsg: TMessage);
var
  i : integer;
  bPacket : TMQTTPacket;
  WillClose : Boolean;
begin
  if aMsg.Msg = WM_TIMER then
    begin
      KillTimer (Timers, aMsg.WParam);
      case aMsg.WParam of
        1 : begin
              Mon ('Connecting to ' + Host + ' on Port ' + IntToStr (Port));
              Link.Addr := Host;
              Link.Port := IntToStr (Port);
              Link.Proto := 'tcp';
              try
                Link.Connect;
              except
              end;
            end;
        2 : Ping;
        3 : begin         // send duplicates
              for i := InFlight.Count - 1 downto 0 do
                begin
                  bPacket := InFlight.List[i];
                  if bPacket.Counter > 0 then
                    begin
                      bPacket.Counter := bPacket.Counter - 1;
                      if bPacket.Counter = 0 then
                        begin
                          bPacket.Retries := bPacket.Retries + 1;
                          if bPacket.Retries <=  MaxRetries then
                            begin
                              if bPacket.Publishing then
                                begin
                                  InFlight.List.Remove (bPacket);
                                  mon ('Message ' + IntToStr (bPacket.ID) + ' disposed of..');
                                  mon ('Re-issuing Message ' + inttostr (bPacket.ID) + ' Retry ' + inttostr (bPacket.Retries));
                                  SetDup (bPacket.Msg, true);
                                  DoSend (Parser, bPacket.ID, bPacket.Retries, bPacket.Msg);
                                  bPacket.Free;
                                end
                              else
                                begin
                                  mon ('Re-issuing PUBREL Message ' + inttostr (bPacket.ID) + ' Retry ' + inttostr (bPacket.Retries));
                                  Parser.SendPubRel (bPacket.ID, true);
                                  bPacket.Counter := Parser.RetryTime;
                                end;
                            end
                          else
                            begin
                              WillClose := true;
                              if Assigned (FOnFailure) then FOnFailure (Self, frMAXRETRIES, WillClose);
                              if WillClose then Link.CloseDelayed;
                            end;
                        end;
                    end;
                end;
              SetTimer (Timers, 3, 100, nil);
            end;
      end;
    end;
end;

procedure TMQTTClient.Unsubscribe (Topics: TStringList);
var
  i, J : integer;
begin
  if Topics = nil then exit;
  for i := 0 to Topics.Count - 1 do
    begin
      for j := Subscriptions.Count - 1 downto 0 do
        if Subscriptions[j] = Topics[i] then
          begin
            Subscriptions.Delete (j);
            break;
          end;
    end;
  Parser.SendUnsubscribe (NextMessageID, Topics);
end;

procedure TMQTTClient.Unsubscribe (aTopic: UTF8String);
var
  i : integer;
begin
  if aTopic = '' then exit;
  for i := Subscriptions.Count - 1 downto 0 do
    if Subscriptions[i] = string (aTopic) then
      begin
        Subscriptions.Delete (i);
        break;
      end;
  Parser.SendUnsubscribe (NextMessageID, aTopic);
end;

procedure TMQTTClient.LinkClosed (Sender: TObject; ErrCode: Word);
begin
//  Mon ('Link Closed...');
  KillTimer (Timers, 2);
  KillTimer (Timers, 3);
  if Assigned (FOnOffline) and (FOnline) then
    FOnOffline (Self, FGraceful);
  FOnline := false;
  if FEnable then SetTimer (Timers, 1, 6000, nil);
end;

{ TMQTTPacketStore }

function TMQTTPacketStore.AddPacket (anID : Word; aMsg : TMemoryStream; aRetry : cardinal; aCount : cardinal) : TMQTTPacket;
begin
  Result := TMQTTPacket.Create;
  Result.ID := anID;
  Result.Counter := aCount;
  Result.Retries := aRetry;
  aMsg.Seek (0, soFromBeginning);
  Result.Msg.CopyFrom (aMsg, aMsg.Size);
  List.Add (Result);
end;

procedure TMQTTPacketStore.Assign (From : TMQTTPacketStore);
var
  i : integer;
  aPacket, bPacket : TMQTTPacket;
begin
  Clear;
  for i := 0 to From.Count - 1 do
    begin
      aPacket := From[i];
      bPacket := TMQTTPacket.Create;
      bPacket.Assign (aPacket);
      List.Add (bPacket);
    end;
end;

procedure TMQTTPacketStore.Clear;
var
  i : integer;
begin
  for i := 0 to List.Count - 1 do
    TMQTTPacket (List[i]).Free;
  List.Clear;
end;

function TMQTTPacketStore.Count: integer;
begin
  Result := List.Count;
end;

constructor TMQTTPacketStore.Create;
begin
  Stamp := Now;
  List := TList.Create;
end;

procedure TMQTTPacketStore.DelPacket (anID: Word);
var
  i : integer;
  aPacket : TMQTTPacket;
begin
  for i := List.Count - 1 downto 0 do
    begin
      aPacket := List[i];
      if aPacket.ID = anID then
        begin
          List.Remove (aPacket);
          aPacket.Free;
          exit;
        end;
    end;
end;

destructor TMQTTPacketStore.Destroy;
begin
  Clear;
  List.Free;
  inherited;
end;

function TMQTTPacketStore.GetItem (Index: Integer): TMQTTPacket;
begin
  if (Index >= 0) and (Index < Count) then
    Result := List[Index]
  else
    Result := nil;
end;

function TMQTTPacketStore.GetPacket (anID: Word): TMQTTPacket;
var
  i : integer;
begin
  for i := 0 to List.Count - 1 do
    begin
      Result := List[i];
      if Result.ID = anID then exit;
    end;
  Result := nil;
end;

procedure TMQTTPacketStore.Remove (aPacket : TMQTTPacket);
begin
  List.Remove (aPacket);
end;

procedure TMQTTPacketStore.SetItem (Index: Integer; const Value: TMQTTPacket);
begin
  if (Index >= 0) and (Index < Count) then
    List[Index] := Value;
end;

{ TMQTTPacket }

procedure TMQTTPacket.Assign (From: TMQTTPacket);
begin
  ID := From.ID;
  Stamp := From.Stamp;
  Counter := From.Counter;
  Retries := From.Retries;
  Msg.Clear;
  From.Msg.Seek (0, soFromBeginning);
  Msg.CopyFrom (From.Msg, From.Msg.Size);
  Publishing := From.Publishing;
end;

constructor TMQTTPacket.Create;
begin
  ID := 0;
  Stamp := Now;
  Publishing := true;
  Counter := 0;
  Retries := 0;
  Msg := TMemoryStream.Create;
end;

destructor TMQTTPacket.Destroy;
begin
  Msg.Free;
  inherited;
end;

{ TMQTTMessage }

procedure TMQTTMessage.Assign (From: TMQTTMessage);
begin
  ID := From.ID;
  Stamp := From.Stamp;
  LastUsed := From.LastUsed;
  Retained := From.Retained;
  Counter := From.Counter;
  Retries := From.Retries;
  Topic := From.Topic;
  Message := From.Message;
  Qos := From.Qos;
end;

constructor TMQTTMessage.Create;
begin
  ID := 0;
  Stamp := Now;
  LastUsed := Stamp;
  Retained := false;
  Counter := 0;
  Retries := 0;
  Qos := qtAT_MOST_ONCE;
  Topic := '';
  Message := '';
end;

destructor TMQTTMessage.Destroy;
begin
  inherited;
end;

{ TMQTTMessageStore }

function TMQTTMessageStore.AddMsg (anID: Word; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType;
  aRetry, aCount: cardinal; aRetained : Boolean) : TMQTTMessage;
begin
  Result := TMQTTMessage.Create;
  Result.ID := anID;
  Result.Topic := aTopic;
  Result.Message := aMessage;
  Result.Qos := aQos;
  Result.Counter := aCount;
  Result.Retries := aRetry;
  Result.Retained := aRetained;
  List.Add (Result);
end;

procedure TMQTTMessageStore.Assign (From: TMQTTMessageStore);
var
  i : integer;
  aMsg, bMsg : TMQTTMessage;
begin
  Clear;
  for i := 0 to From.Count - 1 do
    begin
      aMsg := From[i];
      bMsg := TMQTTMessage.Create;
      bMsg.Assign (aMsg);
      List.Add (bMsg);
    end;
end;

procedure TMQTTMessageStore.Clear;
var
  i : integer;
begin
  for i := 0 to List.Count - 1 do
    TMQTTMessage (List[i]).Free;
  List.Clear;
end;

function TMQTTMessageStore.Count: integer;
begin
  Result := List.Count;
end;

constructor TMQTTMessageStore.Create;
begin
  Stamp := Now;
  List := TList.Create;
end;

procedure TMQTTMessageStore.DelMsg (anID: Word);
var
  i : integer;
  aMsg : TMQTTMessage;
begin
  for i := List.Count - 1 downto 0 do
    begin
      aMsg := List[i];
      if aMsg.ID = anID then
        begin
          List.Remove (aMsg);
          aMsg.Free;
          exit;
        end;
    end;
end;

destructor TMQTTMessageStore.Destroy;
begin
  Clear;
  List.Free;
  inherited;
end;

function TMQTTMessageStore.GetItem (Index: Integer): TMQTTMessage;
begin
  if (Index >= 0) and (Index < Count) then
    Result := List[Index]
  else
    Result := nil;
end;

function TMQTTMessageStore.GetMsg (anID: Word): TMQTTMessage;
var
  i : integer;
begin
  for i := 0 to List.Count - 1 do
    begin
      Result := List[i];
      if Result.ID = anID then exit;
    end;
  Result := nil;
end;

procedure TMQTTMessageStore.Remove (aMsg: TMQTTMessage);
begin
  List.Remove (aMsg);
end;

procedure TMQTTMessageStore.SetItem (Index: Integer; const Value: TMQTTMessage);
begin
  if (Index >= 0) and (Index < Count) then
    List[Index] := Value;
end;

{ TMQTTSession }

constructor TMQTTSession.Create;
begin
  ClientID := '';
  Stamp := Now;
  InFlight := TMQTTPacketStore.Create;
  Releasables := TMQTTMessageStore.Create;
end;

destructor TMQTTSession.Destroy;
begin
  InFlight.Clear;
  InFlight.Free;
  Releasables.Clear;
  Releasables.Free;
  inherited;
end;

{ TMQTTSessionStore }

procedure TMQTTSessionStore.Clear;
var
  i : integer;
begin
  for i := 0 to List.Count - 1 do
    TMQTTSession (List[i]).Free;
  List.Clear;
end;

function TMQTTSessionStore.Count: integer;
begin
  Result := List.Count;
end;

constructor TMQTTSessionStore.Create;
begin
  Stamp := Now;
  List := TList.Create;
end;

procedure TMQTTSessionStore.DeleteSession (ClientID: UTF8String);
var
  aSession : TMQTTSession;
begin
  aSession := GetSession (ClientID);
  if aSession <> nil then
    begin
      List.Remove (aSession);
      aSession.Free;
    end;
end;

destructor TMQTTSessionStore.Destroy;
begin
  Clear;
  List.Free;
  inherited;
end;

function TMQTTSessionStore.GetItem (Index: Integer): TMQTTSession;
begin
  if (Index >= 0) and (Index < Count) then
    Result := List[Index]
  else
    Result := nil;
end;

function TMQTTSessionStore.GetSession (ClientID: UTF8String): TMQTTSession;
var
  i : integer;
begin
  for i := 0 to List.Count - 1 do
    begin
      Result := List[i];
      if Result.ClientID = ClientID then exit;
    end;
  Result := nil;
end;

procedure TMQTTSessionStore.RestoreSession (ClientID: UTF8String;
  aClient: TClient);
var
  aSession : TMQTTSession;
begin
  aClient.InFlight.Clear;
  aClient.Releasables.Clear;
  aSession := GetSession (ClientID);
  if aSession <> nil then
    begin
      aClient.InFlight.Assign (aSession.InFlight);
      aClient.Releasables.Assign (aSession.Releasables);
    end;
end;

procedure TMQTTSessionStore.RestoreSession (ClientID: UTF8String;
  aClient: TMQTTClient);
var
  aSession : TMQTTSession;
begin
  aClient.InFlight.Clear;
  aClient.Releasables.Clear;
  aSession := GetSession (ClientID);
  if aSession <> nil then
    begin
      aClient.InFlight.Assign (aSession.InFlight);
      aClient.Releasables.Assign (aSession.Releasables);
    end;
end;

procedure TMQTTSessionStore.StoreSession (ClientID: UTF8String;
  aClient: TMQTTClient);
var
  aSession : TMQTTSession;
begin
  aSession := GetSession (ClientID);
  if aSession <> nil then
    begin
      aSession := TMQTTSession.Create;
      aSession.ClientID := ClientID;
      List.Add (aSession);
    end;

  aSession.InFlight.Assign (aClient.InFlight);
  aSession.Releasables.Assign (aClient.Releasables);
end;

procedure TMQTTSessionStore.StoreSession (ClientID: UTF8String;
  aClient: TClient);
var
  aSession : TMQTTSession;
begin
  aClient.InFlight.Clear;
  aClient.Releasables.Clear;
  aSession := GetSession (ClientID);
  if aSession <> nil then
    begin
      aSession := TMQTTSession.Create;
      aSession.ClientID := ClientID;
      List.Add (aSession);
    end;
  aSession.InFlight.Assign (aClient.InFlight);
  aSession.Releasables.Assign (aClient.Releasables);
end;

procedure TMQTTSessionStore.SetItem (Index: Integer; const Value: TMQTTSession);
begin
  if (Index >= 0) and (Index < Count) then
    List[Index] := Value;
end;

end.
