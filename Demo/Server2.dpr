program Server2;

uses
  Forms,
  uServer2 in 'uServer2.pas' {MainForm},
  uMQTT in 'uMQTT.pas',
  uBrokers in 'uBrokers.pas' {BrokerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TBrokerForm, BrokerForm);
  Application.Run;
end.
