unit uBrokers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uMQTTComps, VirtualTrees, Buttons, StdCtrls;

type
  TDataRec = record
    Broker : TMQTTClient;
  end;
  PDataRec = ^TDataRec;

  TBrokerForm = class(TForm)
    MonTree: TVirtualStringTree;
    IPTxt: TEdit;
    PortTxt: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    DelBtn: TButton;
    AddBtn: TButton;
    BitBtn1: TBitBtn;
    StartBtn: TButton;
    StopBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure MonTreeGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure FormShow(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure MonTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure BitBtn1Click(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
    procedure PortTxtKeyPress(Sender: TObject; var Key: Char);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure IPTxtChange(Sender: TObject);
    procedure MonTreeChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    { Private declarations }
    procedure UpdateBtnStatus;

  public
    { Public declarations }
    FServer : TMQTTServer;
    procedure Sync;
    procedure RefreshTree;
  end;

var
  BrokerForm: TBrokerForm;

procedure ShowBrokerForm (anOwner : TComponent; aServer : TMQTTServer);

implementation


{$R *.dfm}

procedure ShowBrokerForm (anOwner : TComponent; aServer : TMQTTServer);
var
  aForm : TBrokerForm;
begin
  aForm := TBrokerForm.Create (anOwner);
  aForm.FServer := aServer;
  aForm.Show;
end;

{ TForm2 }

procedure TBrokerForm.AddBtnClick(Sender: TObject);
var
  aBroker : TMQTTClient;
  aNode : PVirtualNode;
  aData : PDataRec;
begin
  if FServer = nil then exit;
  aBroker := FServer.AddBroker (IPTxt.Text, StrToIntDef (PortTxt.Text, 1883));
  Sync;
  aNode := MonTree.GetFirst (false);
  while aNode <> nil do
    begin
      aData := MonTree.GetNodeData (aNode);
      if aData.Broker = aBroker then
        begin
          MonTree.Selected[aNode] := true;
          aNode := nil;
        end
      else
        aNode := MonTree.GetNext (aNode, false);
    end;
end;

procedure TBrokerForm.BitBtn1Click (Sender: TObject);
begin
  hide;
end;

procedure TBrokerForm.DelBtnClick(Sender: TObject);
var
  aNode : PVirtualNode;
  aData : PDataRec;
begin
  if FServer = nil then exit;
  aNode := MonTree.GetFirstSelected (false);
  if aNode = nil then exit;
  aData := MonTree.GetNodeData (aNode);
  FServer.Brokers.Remove (aData.Broker);
  aData.Broker.Free;
  Sync;
end;

procedure TBrokerForm.FormCreate (Sender: TObject);
begin
  FServer := nil;
end;

procedure TBrokerForm.FormShow (Sender: TObject);
begin
  Sync;
  UpdateBtnStatus;
end;

procedure TBrokerForm.IPTxtChange(Sender: TObject);
begin
  UpdateBtnStatus;
end;

procedure TBrokerForm.MonTreeChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  UpdateBtnStatus;
end;

procedure TBrokerForm.MonTreeGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
   NodeDataSize := SizeOf (TDataRec);
end;

procedure TBrokerForm.MonTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
const
  ny : array [boolean] of string = ('NO', 'YES');
var
  aData : PDataRec;
begin
  aData := Sender.GetNodeData (Node);
  if FServer = nil then
    CellText := ''
  else if FServer.Brokers.IndexOf (aData.Broker) >= 0 then
    begin
      case Column of
        0 : CellText := aData.Broker.Host;
        1 : CellText := IntToStr (aData.Broker.Port);
        2 : Celltext := ny[aData.Broker.Enabled];
        3 : CellText := ny[aData.Broker.Online];
       end;
    end
  else
    CellText := '';
end;

procedure TBrokerForm.PortTxtKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet (Key, ['0'..'9', #8]) then Key := #0;
end;

procedure TBrokerForm.RefreshTree;
begin
  MonTree.Invalidate;
end;

procedure TBrokerForm.StartBtnClick(Sender: TObject);
var
  aNode : PVirtualNode;
  aData : PDataRec;
begin
  if FServer = nil then exit;
  aNode := MonTree.GetFirstSelected (false);
  if aNode = nil then exit;
  aData := MonTree.GetNodeData (aNode);
  aData.Broker.Activate (true);
  MonTree.Invalidate;
end;

procedure TBrokerForm.StopBtnClick(Sender: TObject);
var
  aNode : PVirtualNode;
  aData : PDataRec;
begin
  if FServer = nil then exit;
  aNode := MonTree.GetFirstSelected (false);
  if aNode = nil then exit;
  aData := MonTree.GetNodeData (aNode);
  aData.Broker.Activate (false);
  MonTree.Invalidate;
end;

procedure TBrokerForm.Sync;
var
  i, x : integer;
  aData : PDataRec;
  aNode, bNode : PVirtualNode;
begin
  if FServer = nil then
    begin
      MonTree.Clear;
      exit;
    end;
  MonTree.BeginUpdate;
  x := 0;
  aNode := MonTree.GetFirst (false);
  while (aNode <> nil) and (x < FServer.Brokers.Count)  do
    begin
      aData := MonTree.GetNodeData (aNode);
      aData.Broker := FServer.Brokers[x];
      x := x + 1;
      aNode := MonTree.GetNext (aNode, false);
    end;
  if aNode = nil then   // ran out of existing
    begin
      for i := x to FServer.Brokers.Count - 1 do
        begin
          aNode := MonTree.AddChild (nil);
          aData := MonTree.GetNodeData (aNode);
          aData.Broker := FServer.Brokers[x];
        end;
    end
  else     // delete any extra
    begin
      while aNode <> nil do
        begin
          bNode := MonTree.GetNext (aNode, false);
          MonTree.DeleteNode (aNode, false);
          aNode := bNode;
        end;
    end;
  MonTree.EndUpdate;
end;

procedure TBrokerForm.UpdateBtnStatus;
begin
  AddBtn.Enabled := (length (IPTxt.Text) > 0);
  DelBtn.Enabled := MonTree.GetFirstSelected (false) <> nil;
  StartBtn.Enabled := MonTree.GetFirstSelected (false) <> nil;
  StopBtn.Enabled := MonTree.GetFirstSelected (false) <> nil;
end;

end.
