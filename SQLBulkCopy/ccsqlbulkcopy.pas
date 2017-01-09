unit ccsqlbulkcopy;

interface

uses
  sysutils,classes,ccbulkdbcore,ccbulkinsert;

type
  TCCFieldMapRecord = class
    SourceField,DestinationField: string;
  end;

  TCCColumnMapping = class
  private
    FList: TList;
    function GetCount: integer;
  public
    constructor Create;
    destructor Destroy;
    procedure Add(ASourceField,ADestinationField: string);
    function GetItemMapping(i: integer): TCCFieldMapRecord;
    property Count: integer read GetCount;
  end;

  TCCSQLBulkCopy = class
  private
    FSourceConnection: ICCDataset;
    FDestinationTableName: string;
    FSourceTableName: string;
    FColumnMapping: TCCColumnMapping;
  public
    constructor Create(ADBConnection: ICCDataset);
    destructor Destroy;
    procedure WriteToServer(ADBDestination: ICCDataset);overload;
    procedure WriteToServer;overload;
    property ColumnMapping: TCCColumnMapping read FColumnMapping write FColumnMapping;
    property DestinationTableName: string read FDestinationTableName write FDestinationTableName;
    property SourceTableName: string read FSourceTableName write FSourceTableName;
  end;

implementation

{ TCCSQLBulkCopy }

constructor TCCSQLBulkCopy.Create(ADBConnection: ICCDataset);
begin
  FSourceConnection := ADBConnection;
  FColumnMapping := TCCColumnMapping.Create;
end;

procedure TCCSQLBulkCopy.WriteToServer(ADBDestination: ICCDataset);
var
  sSourceColumn,sDestinationColumn: string;
  ssql1: string;
  i: integer;
  ABulkInsert: TCCBulkInsert;
  ADatasetReader: TDatasetReader;
begin
  ABulkInsert := TCCBulkInsert.Create;
  try
    for i := 0 to FColumnMapping.Count - 1 do
    begin
      sSourceColumn := sSourceColumn + FColumnMapping.GetItemMapping(i).SourceField + ',';

      ABulkInsert.ColumnNames.Add(FColumnMapping.GetItemMapping(i).DestinationField);
    end;

    Delete(sSourceColumn,Length(sSourceColumn),1);
    Delete(sDestinationColumn,Length(sDestinationColumn),1);

    FSourceConnection.OpenQuery(Format('select %s from %s',[sSourceColumn,FSourceTableName]));
    FSourceConnection.getDataset.First;

    ABulkInsert.SingleStatement := True;
    ABulkInsert.Tablename := DestinationTableName;
    ABulkInsert.StartRow := 0;
    ABulkInsert.StartCol := 0;
    ABulkInsert.UpdateIfRecordExists := False;

    ADatasetReader := TDatasetReader.Create;
    ABulkInsert.Reader := ADatasetReader;
    ABulkInsert.ObjectSource := FSourceConnection.getDataset;


    ssql1 := ABulkInsert.getSQL;
    ADBDestination.ExecuteNonQuery(ssql1);

  finally
    FreeAndNil(ABulkInsert);
  end;

//  while not FSourceConnection.Dataset.Eof do
//  begin
//
//    FSourceConnection.Dataset.Next;
//  end;
end;

destructor TCCSQLBulkCopy.Destroy;
begin
  FreeAndNil(FColumnMapping);
end;

procedure TCCSQLBulkCopy.WriteToServer;
begin
  WriteToServer(FSourceConnection);
end;

{ TCCColumnMapping }

procedure TCCColumnMapping.Add(ASourceField, ADestinationField: string);
var
  AMap: TCCFieldMapRecord;
begin
  AMap := TCCFieldMapRecord.Create;
  AMap.SourceField      := ASourceField;
  AMap.DestinationField := ADestinationField;

  FList.Add(AMap);
end;

constructor TCCColumnMapping.Create;
begin
  FList := TList.Create;
end;

destructor TCCColumnMapping.Destroy;
begin
  FreeAndNil(FList);
end;

function TCCColumnMapping.GetCount: integer;
begin
  Result := FList.Count;
end;

function TCCColumnMapping.GetItemMapping(i: integer): TCCFieldMapRecord;
begin
  Result := TCCFieldMapRecord(FList[i]);
end;


end.
