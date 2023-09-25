program PRM;

uses
  Vcl.Forms,
  Main in 'Main.pas' {FMain},
  DM in 'DM.pas' {FDM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFDM, FDM);
  Application.Run;
end.
