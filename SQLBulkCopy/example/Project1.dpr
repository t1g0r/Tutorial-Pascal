program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  ccsqlbulkcopy in '..\ccsqlbulkcopy.pas',
  ccbulkdbcore in '..\ccbulkdbcore.pas',
  ccunidac in '..\ccunidac.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
