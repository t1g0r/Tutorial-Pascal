unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  hfilereader;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure EventOnReadLine(AText: string);
    procedure EventOnEOF(Sender: TObject);
    procedure EventOnGetResult(AData: TMemoryStream);
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  FStart: Int64;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  fs: TFileStream;
  i: integer;
  s: string;
begin
  fs := TFileStream.Create(Edit1.Text,fmCreate or fmOpenWrite);
  fs.Position:=0;
  fs.Size:=0;
  for i:=1 to StrToInt(Edit2.Text) do
  begin
    s := 'caca caca caca caca caca caca caca caca caca caca caca caca ' + IntToStr(i) + #13#10;
    fs.Write(s[1],Length(s));
  end;
  fs.Free;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  AReader: TCCTextFileReader;
begin
  //Memo1.Lines.BeginUpdate;
  FStart:=GetTickCount64;
  AReader := TCCTextFileReader.Create(Edit1.Text);
  //AReader.OnReadLine:=@EventOnReadLine;
  AReader.OnGetResult:=@EventOnGetResult;
  AReader.execute;
end;

procedure TForm1.EventOnReadLine(AText: string);
begin

  Memo1.Lines.Add(AText);
end;

procedure TForm1.EventOnEOF(Sender: TObject);
begin
  //ShowMessage(AText);
  Memo1.Lines.EndUpdate;
end;

procedure TForm1.EventOnGetResult(AData: TMemoryStream);
begin
  //ShowMessageFmt('%d',[AData.Size]);
  Memo1.Lines.BeginUpdate;
  Memo1.Lines.LoadFromStream(AData);
  Memo1.Lines.EndUpdate;
  ShowMessageFmt('%f seconds!',[(GetTickCount64-FStart)/1000]);
end;

end.

