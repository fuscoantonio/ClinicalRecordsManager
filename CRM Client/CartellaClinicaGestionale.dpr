program CartellaClinicaGestionale;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {GestionaleCartellaClinica},
  Logger in 'Logger.pas',
  Startup in 'Startup.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGestionaleCartellaClinica, GestionaleCartellaClinica);
  Application.Run;
end.
