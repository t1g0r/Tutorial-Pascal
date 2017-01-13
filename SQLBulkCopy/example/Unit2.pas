unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  Vcl.StdCtrls,

  //lib uses
  ccsqlbulkcopy,cczeos

  ;

type
  TForm1 = class(TForm)
    ZConnection1: TZConnection;
    qSource: TZQuery;
    Button1: TButton;
    ZConnection2: TZConnection;
    qDest: TZQuery;
    procedure Button1Click(Sender: TObject);
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
var
  bulkCopy: TCCSQLBulkCopy;
  dataset,datasetDestination: TCCZeosDataset;
begin
  //set dataset source
  dataset := TCCZeosDataset.Create;
  dataset.Dataset := qSource;

  //set dataset destination
  datasetDestination := TCCZeosDataset.Create;
  datasetDestination.Dataset := qDest;

  bulkCopy := TCCSQLBulkCopy.Create(dataset);
  bulkCopy.SourceTableName := 'personal_info';
  bulkCopy.DestinationTableName := 'personal2';

  bulkCopy.ColumnMapping.Add('id','id2');
  bulkCopy.ColumnMapping.Add('name','name2');
  bulkCopy.ColumnMapping.Add('address','address2');
  bulkCopy.ColumnMapping.Add('phone','phone2');

  //write to server
  bulkCopy.WriteToServer;
  bulkCopy.WriteToServer(datasetDestination);
  ShowMessage('Copy Done.');
end;

end.
