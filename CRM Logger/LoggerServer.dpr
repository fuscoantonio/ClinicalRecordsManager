program LoggerServer;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {ServerLogger};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServerLogger, ServerLogger);
  Application.Run;
end.
