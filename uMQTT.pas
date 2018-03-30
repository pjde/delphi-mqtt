unit uMQTT;
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

interface
uses
  Classes;

const
  MQTT_PROTOCOL   = 'MQIsdp';
  MQTT_VERSION    = 3;

  DefRetryTime  = 60;   // 6 seconds
  DefMaxRetries = 8;

  rsHdr           = 0;
  rsLen           = 1;
  rsVarHdr        = 2;
  rsPayload       = 3;

  frKEEPALIVE     = 0;    // keep alive exceeded
  frMAXRETRIES    = 1;

  rcACCEPTED      = 0;    // Connection Accepted
  rcPROTOCOL      = 1;    // Connection Refused: unacceptable protocol version
  rcIDENTIFIER    = 2;    // Connection Refused: identifier rejected
  rcSERVER        = 3;    // Connection Refused: server unavailable
  rcUSER          = 4;    // Connection Refused: bad user name or password
  rcAUTHORISED    = 5;    // Connection Refused: not authorised
                          // 6-255 Reserved for future use
  ny : array [boolean] of string = ('NO', 'YES');

type
  //  Message type
  TMQTTMessageType =
  (
//    mtReserved0,	  //  0	Reserved
    mtBROKERCONNECT,  //  0	Broker request to connect to Broker
    mtCONNECT,        //	1	Client request to connect to Broker
    mtCONNACK,        //	2	Connect Acknowledgment
    mtPUBLISH,        //	3	Publish message
    mtPUBACK,         //	4	Publish Acknowledgment
    mtPUBREC,         //	5	Publish Received (assured delivery part 1)
    mtPUBREL,         //	6	Publish Release (assured delivery part 2)
    mtPUBCOMP,        //	7	Publish Complete (assured delivery part 3)
    mtSUBSCRIBE,      //	8	Client Subscribe request
    mtSUBACK,         //	9	Subscribe Acknowledgment
    mtUNSUBSCRIBE,    // 10	Client Unsubscribe request
    mtUNSUBACK,       // 11	Unsubscribe Acknowledgment
    mtPINGREQ,        // 12	PING Request
    mtPINGRESP,       // 13	PING Response
    mtDISCONNECT,     // 14	Client is Disconnecting
    mtReserved15      // 15
  );

  TMQTTQOSType =
  (
    qtAT_MOST_ONCE,   //  0 At most once Fire and Forget        <=1
    qtAT_LEAST_ONCE,  //  1 At least once Acknowledged delivery >=1
    qtEXACTLY_ONCE,   //  2 Exactly once Assured delivery       =1
    qtReserved3	      //  3	Reserved
  );

  TMQTTStreamEvent = procedure (Sender : TObject; anID : Word; Retry : integer; aStream : TMemoryStream) of object;
  TMQTTMonEvent = procedure (Sender : TObject; aStr : string) of object;
  TMQTTCheckUserEvent = procedure (Sender : TObject; aUser, aPass : UTF8String; var Allowed : Boolean) of object;
  TMQTTPubResponseEvent = procedure (Sender : TObject; aMsg : TMQTTMessageType; anID : Word) of object;
  TMQTTIDEvent = procedure (Sender : TObject; anID : Word) of object;
  TMQTTAckEvent = procedure (Sender : TObject; aCode : Byte) of object;
  TMQTTDisconnectEvent = procedure (Sender : TObject; Graceful : Boolean) of object;
  TMQTTSubscriptionEvent = procedure (Sender : TObject; aTopic : UTF8String; var RequestedQos : TMQTTQOSType) of object;
  TMQTTSubscribeEvent = procedure (Sender : TObject; anID : Word; Topics : TStringList) of object;
  TMQTTUnsubscribeEvent = procedure (Sender : TObject; anID : Word; Topics : TStringList) of object;
  TMQTTSubAckEvent = procedure (Sender : TObject; anID : Word; Qoss : array of TMQTTQosType) of object;
  TMQTTFailureEvent = procedure (Sender : TObject; aReason : integer; var CloseClient : Boolean) of object;
  TMQTTMsgEvent = procedure (Sender : TObject; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; aRetained : boolean) of object;
  TMQTTRetainEvent = procedure (Sender : TObject; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType) of object;
  TMQTTRetainedEvent = procedure (Sender : TObject; Subscribed : UTF8String; var aTopic : UTF8String; var aMessage : AnsiString; var aQos : TMQTTQOSType) of object;
  TMQTTPublishEvent = procedure (Sender : TObject; anID : Word; aTopic : UTF8String; aMessage : AnsiString) of object;
  TMQTTClientIDEvent = procedure (Sender : TObject; var aClientID : UTF8String) of object;
  TMQTTConnectEvent = procedure (Sender : TObject;
                        Protocol : UTF8String;
                        Version : byte;
                        ClientID,
                        UserName, Password : UTF8String;
                        KeepAlive : Word; Clean : Boolean) of object;
  TMQTTWillEvent = procedure (Sender : TObject; aTopic, aMessage : UTF8String; aQos : TMQTTQOSType; aRetain : boolean) of object;
  TMQTTObituaryEvent = procedure (Sender : TObject; var aTopic, aMessage : UTF8String; var aQos : TMQTTQOSType) of object;
  TMQTTHeaderEvent = procedure (Sender : TObject; MsgType: TMQTTMessageType; Dup: Boolean; Qos: TMQTTQOSType; Retain: Boolean) of object;
  TMQTTSessionEvent = procedure (Sender : TObject; aClientID : UTF8String) of object;

  TMQTTParser = class
  private
    FOnSend: TMQTTStreamEvent;
    FTxStream : TMemoryStream;
    FRxStream : TMemoryStream;
    FKeepAliveCount : cardinal;
    FKeepAlive : Word;
    FWillFlag : boolean;
    FRxState, FRxMult, FRxVal : integer;
    FOnConnAck: TMQTTAckEvent;
    FOnUnsubAck: TMQTTIDEvent;
    FOnSubscribe: TMQTTSubscribeEvent;
    FOnPing: TNotifyEvent;
    FOnDisconnect: TNotifyEvent;
    FOnPingResp: TNotifyEvent;
    FOnPublish: TMQTTPublishEvent;
    FOnConnect: TMQTTConnectEvent;
    FOnUnsubscribe: TMQTTUnsubscribeEvent;
    FOnSubAck: TMQTTSubAckEvent;
    FOnSetWill: TMQTTWillEvent;
    FOnHeader: TMQTTHeaderEvent;
    FOnMon: TMQTTMonEvent;
    FOnPubAck: TMQTTIDEvent;
    FOnPubRel: TMQTTIDEvent;
    FOnPubComp: TMQTTIDEvent;
    FOnPubRec: TMQTTIDEvent;
    FMaxRetries: Word;
    FRetryTime: Word;
    FOnBrokerConnect: TMQTTConnectEvent;
    procedure SetKeepAlive(const Value: Word);
  public
    NosRetries : integer;
    RxMsg : TMQTTMessageType;
    RxQos : TMQTTQOSType;
    RxDup, RxRetain : Boolean;
    UserName, Password,
    WillTopic: UTF8String;
    WillMessage : UTF8String;
    WillRetain : Boolean;
    WillQos : TMQTTQOSType;
    ClientID : UTF8String;
    Clean : Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure Parse (aStream : TStream); overload;
    procedure Parse (aStr : AnsiString); overload;
    procedure SetWill (aTopic, aMessage : UTF8String; aQos : TMQTTQOSType; aRetain : boolean);
    function CheckKeepAlive : boolean;
    procedure Mon (aStr : string);
    // client
    procedure SendBrokerConnect (aClientID, aUsername, aPassword : UTF8String; aKeepAlive : Word; aClean : Boolean);  // non standard
    procedure SendConnect (aClientID, aUsername, aPassword : UTF8String; aKeepAlive : Word; aClean : Boolean);
    procedure SendPublish (anID : Word; aTopic: UTF8String; aMessage : AnsiString; aQOS : TMQTTQOSType; aDup : boolean = false; aRetain : boolean = false);
    procedure SendPing;
    procedure SendDisconnect;
    procedure SendSubscribe (anID : Word; aTopic : UTF8String; aQOS : TMQTTQOSType); overload;
    procedure SendSubscribe (anID : Word; Topics : TStringList); overload;
    procedure SendUnsubscribe (anID : Word; aTopic : UTF8String); overload;
    procedure SendUnsubscribe (anID : Word; Topics : TStringList); overload;
    // server
    procedure SendConnAck (aCode : byte);
    procedure SendPubAck (anID : Word);
    procedure SendPubRec (anID : Word);
    procedure SendPubRel (anID : Word; aDup : Boolean = false);
    procedure SendPubComp (anID : Word);
    procedure SendSubAck (anID : Word; Qoss : array of TMQTTQosType);
    procedure SendUnsubAck (anID : Word);
    procedure SendPingResp;
    property KeepAlive : Word read FKeepAlive write SetKeepAlive;
    property RetryTime : Word read FRetryTime write FRetryTime;
    property MaxRetries : Word read FMaxRetries write FMaxRetries;
    // client
    property OnConnAck : TMQTTAckEvent read FOnConnAck write FOnConnAck;
    property OnSubAck: TMQTTSubAckEvent read FOnSubAck write FOnSubAck;
    property OnPubAck : TMQTTIDEvent read FOnPubAck write FOnPubAck;
    property OnPubRel : TMQTTIDEvent read FOnPubRel write FOnPubRel;
    property OnPubRec : TMQTTIDEvent read FOnPubRec write FOnPubRec;
    property OnPubComp : TMQTTIDEvent read FOnPubComp write FOnPubComp;
    property OnUnsubAck : TMQTTIDEvent read FOnUnsubAck write FOnUnsubAck;
    property OnPingResp : TNotifyEvent read FOnPingResp write FOnPingResp;
    // server
    property OnBrokerConnect : TMQTTConnectEvent read FOnBrokerConnect write FOnBrokerConnect;  // non standard
    property OnConnect : TMQTTConnectEvent read FOnConnect write FOnConnect;
    property OnPublish : TMQTTPublishEvent read FOnPublish write FOnPublish;
    property OnPing : TNotifyEvent read FOnPing write FOnPing;
    property OnDisconnect : TNotifyEvent read FOnDisconnect write FOnDisconnect;
    property OnSubscribe : TMQTTSubscribeEvent read FOnSubscribe write FOnSubscribe;
    property OnUnsubscribe : TMQTTUnsubscribeEvent read FOnUnsubscribe write FOnUnsubscribe;
    property OnSetWill : TMQTTWillEvent read FOnSetWill write FOnSetWill;
    property OnHeader : TMQTTHeaderEvent read FOnHeader write FOnHeader;
    property OnMon : TMQTTMonEvent read FOnMon write FOnMon;
    property OnSend : TMQTTStreamEvent read FOnSend write FOnSend;
  end;

const
  MsgNames : array [TMQTTMessageType] of string =
  (
//    'Reserved',	    //  0	Reserved
    'BROKERCONNECT',	//  0	Broker request to connect to Broker
    'CONNECT',        //	1	Client request to connect to Broker
    'CONNACK',        //	2	Connect Acknowledgment
    'PUBLISH',        //	3	Publish message
    'PUBACK',         //	4	Publish Acknowledgment
    'PUBREC',         //	5	Publish Received (assured delivery part 1)
    'PUBREL',         //	6	Publish Release (assured delivery part 2)
    'PUBCOMP',        //	7	Publish Complete (assured delivery part 3)
    'SUBSCRIBE',      //	8	Client Subscribe request
    'SUBACK',         //	9	Subscribe Acknowledgment
    'UNSUBSCRIBE',    // 10	Client Unsubscribe request
    'UNSUBACK',       // 11	Unsubscribe Acknowledgment
    'PINGREQ',        // 12	PING Request
    'PINGRESP',       // 13	PING Response
    'DISCONNECT',     // 14	Client is Disconnecting
    'Reserved15'      // 15
  );

  QOSNames : array [TMQTTQOSType] of string =
  (
    'AT_MOST_ONCE',   //  0 At most once Fire and Forget        <=1
    'AT_LEAST_ONCE',  //  1 At least once Acknowledged delivery >=1
    'EXACTLY_ONCE',   //  2 Exactly once Assured delivery       =1
    'RESERVED'	      //  3	Reserved
  );

function CodeNames (aCode : byte) : string;
function ExtractFileNameOnly (FileName : string) : string;
function FailureNames (aCode : byte) : string;
procedure DebugStr (aStr : string);

implementation

uses Windows, SysUtils;

function ExtractFileNameOnly (FileName : string) : string;
begin
  Result := ExtractFileName (FileName);
  SetLength (Result, Length (Result) - Length (ExtractFileExt (FileName)));
end;

function CodeNames (aCode : byte) : string;
begin
  case (aCode) of
    rcACCEPTED   : Result := 'ACCEPTED';                    // Connection Accepted
    rcPROTOCOL   : Result := 'PROTOCOL UNACCEPTABLE';       // Connection Refused: unacceptable protocol version
    rcIDENTIFIER : Result := 'IDENTIFIER REJECTED';         // Connection Refused: identifier rejected
    rcSERVER     : Result := 'SERVER UNAVILABLE';           // Connection Refused: server unavailable
    rcUSER       : Result := 'BAD LOGIN';                   // Connection Refused: bad user name or password
    rcAUTHORISED : Result := 'NOT AUTHORISED'
    else           Result := 'RESERVED ' + IntToStr (aCode);
  end;
end;

function FailureNames (aCode : byte) : string;
begin
  case (aCode) of
    frKEEPALIVE  : Result := 'KEEP ALIVE TIMEOUT';
    frMAXRETRIES : Result := 'MAX RETRIES EXCEEDED';
    else           Result := 'RESERVED ' + IntToStr (aCode);
  end;
end;

procedure DebugStr (aStr : string);
begin
  OutputDebugString (PChar (aStr));
end;

procedure AddByte (aStream : TStream; aByte: Byte);
begin
  aStream.Write (aByte, 1);
end;

procedure AddHdr (aStream : TStream; MsgType: TMQTTMessageType; Dup: Boolean;
  Qos: TMQTTQOSType; Retain: Boolean);
begin
  { Fixed Header Spec:
    bit	   |7 6	5	4	    | |3	     | |2	1	     |  |  0   |
    byte 1 |Message Type| |DUP flag| |QoS level|	|RETAIN| }
  AddByte (aStream, (Ord (MsgType) shl 4) + (ord (Dup) shl 3) + (ord (Qos) shl 1) + ord (Retain));
end;

procedure AddLength (aStream : TStream; aLen: integer);
var
  x : integer;
  dig : byte;
begin
  x := aLen;
  repeat
    dig := x mod 128;
    x := x div 128;
    if (x > 0) then
      dig := dig or $80;
    AddByte (aStream, dig);
  until (x = 0);
end;

procedure AddStr (aStream : TStream; aStr: UTF8String);
var
  l : integer;
begin
  l := length (aStr);
  AddByte (aStream, l div $100);
  AddByte (aStream, l mod $100);
  aStream.Write (aStr[1], length (aStr));
end;

function ReadByte (aStream : TStream) : Byte;
begin
  if aStream.Position = aStream.Size then
    Result := 0
  else
    aStream.Read (Result, 1);
end;

function ReadHdr (aStream : TStream; var MsgType: TMQTTMessageType; var Dup: Boolean;
  var Qos: TMQTTQOSType; var Retain: Boolean) : byte;
begin
  Result := ReadByte (aStream);
  { Fixed Header Spec:
    bit	   |7 6	5	4	    | |3	     | |2	1	     |  |  0   |
    byte 1 |Message Type| |DUP flag| |QoS level|	|RETAIN| }
  MsgType := TMQTTMessageType ((Result and $f0) shr 4);
  Dup := (Result and $08) > 0;
  Qos := TMQTTQOSType ((Result and $06) shr 1);
  Retain := (Result and $01) > 0;
end;

function ReadLength (aStream : TStream) : integer;
var
  mult : integer;
  x : byte;
begin
  mult := 0;
  Result := 0;
  repeat
    x := ReadByte (aStream);
    Result := Result + ((x and $7f) * mult);
  until (x and $80) <> 0;
end;

function ReadStr (aStream : TStream) : UTF8String;
var
  l : integer;
begin
  l := ReadByte (aStream) * $100 + ReadByte (aStream);
  if aStream.Position + l <= aStream.Size then
    begin
      SetLength (Result, l);
      aStream.Read (Result[1], l);
    end;
end;

{ TMQTTParser }

function TMQTTParser.CheckKeepAlive: boolean;
begin
  Result := true;
  if FKeepAliveCount > 0 then
    begin
      FKeepAliveCount := FKeepAliveCount - 1;
      Result := (FKeepAliveCount > 0);
    end;
end;

constructor TMQTTParser.Create;
begin
  KeepAlive := 10;
  FKeepAliveCount := 0;
  FMaxRetries := DefMaxRetries;
  FRetryTime := DefRetryTime;
  NosRetries := 0;
  ClientID := '';
  WillTopic := '';
  WillMessage := '';
  FWillFlag := false;
  WillQos := qtAT_LEAST_ONCE;
  WillRetain := false;
  Username := '';
  Password := '';
  FRxState := rsHdr;
  FRxMult := 0;
  FRxVal := 0;
  RxMsg := mtReserved15;
  RxQos := qtAT_MOST_ONCE;
  RxDup := false;
  RxRetain := false;
  FTxStream := TMemoryStream.Create;
  FRxStream := TMemoryStream.Create;
end;

destructor TMQTTParser.Destroy;
begin
  FTxStream.Free;
  FRxStream.Free;
  inherited;
end;

procedure TMQTTParser.Mon (aStr: string);
begin
  if Assigned (FOnMon) then FOnMon (Self, 'P ' + aStr);
end;

procedure TMQTTParser.Parse (aStr: AnsiString);
var
  aStream : TMemoryStream;
begin
  aStream := TMemoryStream.Create;
  aStream.Write (aStr[1], length (aStr));
  aStream.Seek (0, soFromBeginning);
  Parse (aStream);
  aStream.Free;
end;

procedure TMQTTParser.Reset;
begin
  FRxState := rsHdr;
  FRxStream.Clear;
  FTxStream.Clear;
  RxMsg := mtReserved15;
  RxDup := false;
  RxQOs := qtAT_MOST_ONCE;
  RxRetain := false;
end;

procedure TMQTTParser.Parse (aStream: TStream);
var
  x, fl, vr, wq : byte;
  id, ka : Word;
  wr, wf, un, ps, cl: Boolean;
  wt, wm, ci, pt : UTF8String;
  aStr, bStr : UTF8String;
  Str : AnsiString;
  Strs : TStringList;
  Qoss : array of TMQTTQOSType;
begin
  while aStream.Position <> aStream.Size do
    begin
      case FRxState of
        rsHdr :
          begin
            ReadHdr (aStream, RxMsg, RxDup, RxQos, RxRetain);
            FRxState := rsLen;
            FRxMult := 1;
            FRxVal := 0;
            if Assigned (FOnHeader) then FOnHeader (Self, RxMsg, RxDup, RxQos, RxRetain);
          end;
        rsLen :
          begin
            x := ReadByte (aStream);
            FRxVal := FRxVal + ((x and $7f) * FRxMult);
            FRxMult := FRxMult * $80;
            if (x and $80) = 0 then
              begin
                FKeepAliveCount := KeepAlive * 10;
                FRxStream.Clear;
                if FRxVal = 0 then
                  begin
                    case RxMsg of
                      mtPINGREQ     :
                        if Assigned (FOnPing) then FOnPing (Self);
                      mtPINGRESP    :
                        if Assigned (FOnPingResp) then FOnPingResp (Self);
                      mtDISCONNECT  :
                        if Assigned (FOnDisconnect) then FOnDisconnect (Self);
                      end;
                    FRxState := rsHdr;
                  end
                else
                  begin
                    FRxState := rsVarHdr;
                  end;
              end;
          end;
        rsVarHdr :
          begin
            x := ReadByte (aStream);
            FRxStream.Write (x, 1);
            FRxVal := FRxVal - 1;
            if FRxVal = 0 then
              begin
                FRxStream.Seek (0, soFromBeginning);
                case RxMsg of
                  mtBROKERCONNECT,
                  mtCONNECT  :
                    begin
                      pt := ReadStr (FRxStream);        // protocol
                      vr := ReadByte (FRxStream);       // version
                      fl := ReadByte (FRxStream);
                      ka := ReadByte (FRxStream) * $100 + ReadByte (FRxStream);
                      ci := ReadStr (FRxStream);
                      wf := (fl and $04) > 0;     // will flag
                      wr := (fl and $10) > 0;     // will retain
                      wq := (fl and $18) shr 3;   // will qos
                      un := (fl and $80) > 0;     // user name
                      ps := (fl and $40) > 0;     // pass word
                      cl := (fl and $02) > 0;     // clean
                      wt := '';
                      wm := '';
                      if wf then
                        begin
                          wt := ReadStr (FRxStream);        // will topic
                          wm := ReadStr (FRxStream);        // will message
                          if Assigned (FOnSetWill) then
                            FOnSetWill (Self, wt, wm, TMQTTQOSType (wq), wr);
                        end;
                      aStr := '';
                      bStr := '';
                      if un then aStr := ReadStr (FRxStream);        // username
                      if ps then bStr := ReadStr (FRxStream);        // password
                      if RxMsg = mtCONNECT then
                        begin
                          if Assigned (FOnConnect) then
                            FOnConnect (Self, pt, vr, ci, aStr, bStr, ka, cl);
                        end
                      else if RxMsg = mtBROKERCONNECT then
                        begin
                          if Assigned (FOnBrokerConnect) then
                            FOnBrokerConnect (Self, pt, vr, ci, aStr, bStr, ka, cl);
                        end;
                    end;
                  mtPUBLISH  :
                    if FRxStream.Size >= 4 then
                      begin
                        aStr := ReadStr (FRxStream);
                        if RxQos in [qtAT_LEAST_ONCE, qtEXACTLY_ONCE] then
                          id := ReadByte (FRxStream) * $100 + ReadByte (FRxStream)
                        else
                          id := 0;   // no id when RxQos = 0
                        SetLength (Str, FRxStream.Size - FRxStream.Position);
                        if length (Str) > 0 then FRxStream.Read (Str[1], length (Str));
                        if Assigned (FOnPublish) then FOnPublish (Self, id, aStr, Str);
                      end;
                  mtPUBACK,
                  mtPUBREC,
                  mtPUBREL,
                  mtPUBCOMP  :
                    if FRxStream.Size = 2 then
                      begin
                        id := ReadByte (FRxStream) * $100 + ReadByte (FRxStream);
                        case RxMsg of
                          mtPUBACK  : if Assigned (FOnPubAck) then FonPubAck (Self, id);
                          mtPUBREC  : if Assigned (FOnPubRec) then FonPubRec (Self, id);
                          mtPUBREL  : if Assigned (FOnPubRel) then FonPubRel (Self, id);
                          mtPUBCOMP : if Assigned (FOnPubComp) then FonPubComp (Self, id);
                        end;
                      end;
                  mtCONNACK     :
                    if FRxStream.Size = 2 then
                      begin
                        ReadByte (FRxStream);
                        id := ReadByte (FRxStream);
                        if Assigned (FOnConnAck) then
                          FOnConnAck (Self, id);
                      end;
                  mtSUBACK     :
                    if FRxStream.Size >= 2 then
                      begin
                        SetLength (Qoss, 0);
                        id := ReadByte (FRxStream) * $100 + ReadByte (FRxStream);
                        while FRxStream.Position < FRxStream.Size do
                          begin
                            SetLength (Qoss, Length (Qoss) + 1);
                            Qoss[Length (Qoss) - 1] := TMQTTQOSType (ReadByte (FRxStream) and $03);
                          end;
                        if Assigned (FOnSubAck) then FOnSubAck (Self, id, Qoss);
                      end;
                  mtUNSUBACK    :
                    if FRxStream.Size = 2 then
                      begin
                        ReadByte (FRxStream);
                        id := ReadByte (FRxStream);
                        if Assigned (FOnUnsubAck) then
                          FOnUnsubAck (Self, id);
                      end;
                  mtUNSUBSCRIBE  :
                   if FRxStream.Size >= 2 then
                      begin
                        id := ReadByte (FRxStream) * $100 + ReadByte (FRxStream);
                        Strs := TStringList.Create;
                        while FRxStream.Size >= FRxStream.Position + 2  do   // len
                          begin
                            aStr := ReadStr (FRxStream);
                            Strs.Add (string (aStr));
                          end;
                        if Assigned (FOnUnsubscribe) then FOnUnsubscribe (Self, id, Strs);
                        Strs.Free;
                      end;
                  mtSUBSCRIBE    :
                   if FRxStream.Size >= 2 then
                      begin
                        id := ReadByte (FRxStream) * $100 + ReadByte (FRxStream);
                        Strs := TStringList.Create;
                        while FRxStream.Size >= FRxStream.Position + 3  do   // len + qos
                          begin
                            aStr := ReadStr (FRxStream);
                            x := ReadByte (FRxStream) and $03;
                            Strs.AddObject (string (aStr), TObject (x));
                          end;
                        if Assigned (FOnSubscribe) then FOnSubscribe (Self, id, Strs);
                        Strs.Free;
                      end;
                end;
                FKeepAliveCount := KeepAlive * 10;
                FRxState := rsHdr;
              end;
          end;
      end;
    end;
end;

procedure TMQTTParser.SendConnect (aClientID, aUsername, aPassword : UTF8String; aKeepAlive : Word; aClean : Boolean);
var
  s : TMemoryStream;
  x : byte;
begin
  KeepAlive := aKeepAlive;

  FTxStream.Clear;        // dup, qos, retain not used
  AddHdr (FTxStream, mtCONNECT, false, qtAT_LEAST_ONCE, false);
  s := TMemoryStream.Create;
  // generate payload
  AddStr (s, aClientID);
  if FWillFlag then
    begin
      AddStr (s, WillTopic);
      AddStr (s, WillMessage);
    end;
  if length (aUserName) > 0 then
    AddStr (s, aUserName);
  if length (aPassword) > 0 then
    AddStr (s, aPassword);
        // finish fixed header
  AddLength (FTxStream, 12 + s.Size);
      // variable header
  AddStr (FTxStream, MQTT_PROTOCOL);         // 00 06  MQIsdp  (8)
  AddByte (FTxStream, MQTT_VERSION);         // 3              (1)
  x := 0;
  if length (aUserName) > 0 then
    x := x or $80;
  if length (aPassword) > 0 then
    x := x or $40;
  if FWillFlag then
    begin
      x := x or $04;
      if WillRetain then
        x := x or $10;
      x := x or (ord (WillQos) shl 3);
    end;
  if Clean then
    x := x or $02;
  AddByte (FTxStream, x);                    //              (1)
  AddByte (FTxStream, aKeepAlive div $100);  //              (1)
  AddByte (FTxStream, aKeepAlive mod $100);  //              (1)
  // payload
  s.Seek (0, soFromBeginning);
  FTxStream.CopyFrom (s, s.Size);
  s.Free;
  if Assigned (FOnSend) then FOnSend (Self, 0, 0, FTxStream);
end;

procedure TMQTTParser.SendBrokerConnect(aClientID, aUsername,
  aPassword: UTF8String; aKeepAlive: Word; aClean: Boolean);
var
  s : TMemoryStream;
  x : byte;
begin
  KeepAlive := aKeepAlive;
  FTxStream.Clear;        // dup, qos, retain not used
  AddHdr (FTxStream, mtBROKERCONNECT, false, qtAT_LEAST_ONCE, false);
  s := TMemoryStream.Create;
  // generate payload
  AddStr (s, aClientID);
  if FWillFlag then
    begin
      AddStr (s, WillTopic);
      AddStr (s, WillMessage);
    end;
  if length (aUserName) > 0 then
    AddStr (s, aUserName);
  if length (aPassword) > 0 then
    AddStr (s, aPassword);
        // finish fixed header
  AddLength (FTxStream, 12 + s.Size);
      // variable header
  AddStr (FTxStream, MQTT_PROTOCOL);         // 00 06  MQIsdp  (8)
  AddByte (FTxStream, MQTT_VERSION);         // 3              (1)
  x := 0;
  if length (aUserName) > 0 then
    x := x or $80;
  if length (aPassword) > 0 then
    x := x or $40;
  if FWillFlag then
    begin
      x := x or $04;
      if WillRetain then
        x := x or $10;
      x := x or (ord (WillQos) shl 3);
    end;
  if Clean then
    x := x or $02;
  AddByte (FTxStream, x);                    //              (1)
  AddByte (FTxStream, aKeepAlive div $100);  //              (1)
  AddByte (FTxStream, aKeepAlive mod $100);  //              (1)
  // payload
  s.Seek (0, soFromBeginning);
  FTxStream.CopyFrom (s, s.Size);
  s.Free;
  if Assigned (FOnSend) then FOnSend (Self, 0, 0, FTxStream);
end;

procedure TMQTTParser.SendConnAck (aCode: byte);
begin
  FTxStream.Clear;        // dup, qos, retain not used
  AddHdr (FTxStream, mtCONNACK, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 2);
  AddByte (FTxStream, 0);                    // reserved      (1)
  AddByte (FTxStream, aCode);         //                (1)
  if Assigned (FOnSend) then FOnSend (Self, 0, 0, FTxStream);
end;

procedure TMQTTParser.SendPublish (anID : Word; aTopic : UTF8String; aMessage : AnsiString; aQos : TMQTTQOSType; aDup : boolean = false; aRetain : boolean = false);
var
  s : TMemoryStream;
begin
  FTxStream.Clear;     // dup qos and retain used
  AddHdr (FTxStream, mtPUBLISH, aDup, aQos, aRetain);
  s := TMemoryStream.Create;
  AddStr (s, aTopic);
  if aQos in [qtAT_LEAST_ONCE, qtEXACTLY_ONCE] then
    begin
      AddByte (s, anID div $100);
      AddByte (s, anID mod $100);
    end;
  if length (aMessage) > 0 then s.Write (aMessage[1], length (aMessage));
  // payload
  s.Seek (0, soFromBeginning);
  AddLength (FTxStream, s.Size);
  FTxStream.CopyFrom (s, s.Size);
  s.Free;
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendPubAck (anID: Word);
begin
  FTxStream.Clear;        // dup, qos, retain not used
  AddHdr (FTxStream, mtPUBACK, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 2);
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendPubRec (anID: Word);
begin
  FTxStream.Clear;       // dup, qos, retain are used
  AddHdr (FTxStream, mtPUBREC, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 2);
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendPubRel (anID: Word; aDup : Boolean = false);
begin
  FTxStream.Clear;
  AddHdr (FTxStream, mtPUBREL, aDup, qtAT_LEAST_ONCE, false);
  AddLength (FTxStream, 2);
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendPubComp (anID: Word);
begin
  FTxStream.Clear;        // dup, qos, retain not used
  AddHdr (FTxStream, mtPUBCOMP, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 2);
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendSubscribe (anID : Word; aTopic : UTF8String; aQOS : TMQTTQOSType);
begin
  FTxStream.Clear;                // qos and dup used
  AddHdr (FTxStream, mtSUBSCRIBE, false, qtAT_LEAST_ONCE, false);
  AddLength (FTxStream, 5 + length (aTopic));
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  AddStr (FTxStream, aTopic);
  AddByte (FTxStream, ord (aQos));
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendSubscribe (anID: Word; Topics: TStringList);
var
  i : integer;
  s : TMemoryStream;
begin
  FTxStream.Clear;     // dup qos and retain used
  AddHdr (FTxStream, mtSUBSCRIBE, false, qtAT_LEAST_ONCE, false);
  s := TMemoryStream.Create;
  AddByte (s, anID div $100);
  AddByte (s, anID mod $100);
  for i := 0 to Topics.Count - 1 do
    begin
      AddStr (s, UTF8String (Topics[i]));
      AddByte (s, byte (Topics.Objects[i]) and $03);
    end;
  // payload
  s.Seek (0, soFromBeginning);
  AddLength (FTxStream, s.Size);
  FTxStream.CopyFrom (s, s.Size);
  s.Free;
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendUnsubscribe (anID: Word; Topics: TStringList);
var
  i : integer;
  s : TMemoryStream;
begin
  FTxStream.Clear;      // qos and dup used
  AddHdr (FTxStream, mtUNSUBSCRIBE, false, qtAT_LEAST_ONCE, false);
  s := TMemoryStream.Create;
  AddByte (s, anID div $100);
  AddByte (s, anID mod $100);
  for i := 0 to Topics.Count - 1 do
    AddStr (s, UTF8String (Topics[i]));
  // payload
  s.Seek (0, soFromBeginning);
  AddLength (FTxStream, s.Size);
  FTxStream.CopyFrom (s, s.Size);
  s.Free;
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;


procedure TMQTTParser.SendSubAck (anID: Word; Qoss : array of TMQTTQOSType);
var
  i : integer;
begin
  FTxStream.Clear;      // dup, qos, retain not used
  AddHdr (FTxStream, mtSUBACK, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 2 + length (Qoss));
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  for i := low (Qoss) to high (Qoss) do
    AddByte (FTxStream, ord (Qoss[i]));
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendUnsubscribe (anID: Word; aTopic: UTF8String);
begin
  FTxStream.Clear;      // qos and dup used
  AddHdr (FTxStream, mtUNSUBSCRIBE, false, qtAT_LEAST_ONCE, false);
  AddLength (FTxStream, 4 + length (aTopic));
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  AddStr (FTxStream, aTopic);
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendUnsubAck (anID: Word);
begin
  FTxStream.Clear;        // dup, qos, retain not used
  AddHdr (FTxStream, mtUNSUBACK, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 2);
  AddByte (FTxStream, anID div $100);
  AddByte (FTxStream, anID mod $100);
  if Assigned (FOnSend) then FOnSend (Self, anID, 0, FTxStream);
end;

procedure TMQTTParser.SendPing;
begin
  FTxStream.Clear;        // dup, qos, retain not used
  AddHdr (FTxStream, mtPINGREQ, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 0);
  if Assigned (FOnSend) then FOnSend (Self, 0, 0, FTxStream);
end;

procedure TMQTTParser.SendPingResp;
begin
  FTxStream.Clear;         // dup, qos, retain not used
  AddHdr (FTxStream, mtPINGRESP, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 0);
  if Assigned (FOnSend) then FOnSend (Self, 0, 0, FTxStream);
end;

procedure TMQTTParser.SendDisconnect;
begin
  FTxStream.Clear;
  AddHdr (FTxStream, mtDISCONNECT, false, qtAT_MOST_ONCE, false);
  AddLength (FTxStream, 0);
  if Assigned (FOnSend) then FOnSend (Self, 0, 0, FTxStream);
end;

procedure TMQTTParser.SetKeepAlive (const Value: Word);
begin
  FKeepAlive := Value;
  FKeepAliveCount := Value * 10;
end;

procedure TMQTTParser.SetWill (aTopic, aMessage : UTF8String; aQos : TMQTTQOSType; aRetain : boolean);
begin
  WillTopic := aTopic;
  WillMessage := aMessage;
  WillRetain := aRetain;
  WillQos := aQos;
  FWillFlag := (length (aTopic) > 0) and (length (aMessage) > 0);
end;

end.
