unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,db, Datasnap.DBClient,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Datasnap.Provider,unitresult,Vcl.StdCtrls,

  //uses
  ccdatasetutils

  ;

type
  TForm1 = class(TForm)
    ClientDataSet1: TClientDataSet;
    ClientDataSet1dokterid: TLargeintField;
    ClientDataSet1namadokter: TStringField;
    ClientDataSet1jeniskelamin: TStringField;
    ClientDataSet1goldarah: TStringField;
    ClientDataSet1tgllahir: TDateField;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    DataSource1: TDataSource;
    DataSetProvider1: TDataSetProvider;
    Button1: TButton;
    Panel2: TPanel;
    edFind: TLabeledEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edFindChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  ShowResult(ClientDataSet1.ToJson);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ClientDataSet1.SaveToCSV('out.csv');
  ShowMessage(Format('saved to ''%s\out.csv''',
              [ExtractFilePath(Application.ExeName)]));
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  //  ClientDataSet1.First //sengaja dimark, utk test bookmark
  ClientDataSet1.WhileNotEof(
    procedure(AField: TFields)
    begin
      ShowMessage('Dokter : ' + AField.FieldByName('namadokter').AsString);
    end
  ,True //move first
  )
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ClientDataSet1.First;
  while ClientDataSet1.NotEof do
  begin
    ShowMessage('Dokter : ' + ClientDataSet1namadokter.AsString);
    ClientDataSet1.Next;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
//  ClientDataSet1.First //sengaja dimark, utk test bookmark
  ClientDataSet1.WhileNotEof(
    procedure
    begin
      ShowMessage('Dokter : ' + ClientDataSet1.FieldByName('namadokter').AsString);
    end
  ,False //move first
  )
end;

procedure TForm1.edFindChange(Sender: TObject);
var
  s: string;
begin
  ClientDataSet1.Filtered := False;

  s := Format('namadokter LIKE ''%%%s%%'' OR ' +
              'jeniskelamin LIKE ''%%%s%%''',[edFind.Text,edFind.Text,edFind.Text]);
  ClientDataSet1.Filter := s;

  ClientDataSet1.Filtered := True;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ClientDataSet1.LoadFromFile(ExtractFilePath(Application.ExeName) + 'data.xml');
end;

end.
