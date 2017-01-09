unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UniProvider, MySQLUniProvider, Data.DB,
  MemDS, DBAccess, Uni,ccsqlbulkcopy,ccunidac, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    dbconn: TUniConnection;
    qSource: TUniQuery;
    MySQL: TMySQLUniProvider;
    Button1: TButton;
    dbconn2: TUniConnection;
    qDest: TUniQuery;
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
  dataset,datasetDestination: TCCUnidacDataset;
begin
  //set dataset source
  dataset := TCCUnidacDataset.Create;
  dataset.Dataset := qSource;

  //set dataset destination
  datasetDestination := TCCUnidacDataset.Create;
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

end;

end.
