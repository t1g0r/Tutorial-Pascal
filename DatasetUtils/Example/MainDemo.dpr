program MainDemo;

uses
  Vcl.Forms,
  UnitMain in 'UnitMain.pas' {Form1},
  ccdatasetutils in '..\ccdatasetutils.pas',
  UnitResult in 'UnitResult.pas' {FormResult};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormResult, FormResult);
  Application.Run;
end.
