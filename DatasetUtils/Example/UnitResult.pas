unit UnitResult;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormResult = class(TForm)
    Memo1: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormResult: TFormResult;

procedure ShowResult(AResult: string);

implementation

{$R *.dfm}

procedure ShowResult(AResult: string);
begin
  FormResult := TFormResult.Create(nil);
  FormResult.Memo1.Text := AResult;
  FormResult.ShowModal;
  FormResult.Free;
end;

end.
