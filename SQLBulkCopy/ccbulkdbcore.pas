unit ccbulkdbcore;

interface

uses
  sysutils,classes,db,ccbulkinsert;

type
  TDatasetReader = class(TCCCustomReader)
  public
    function getRowCount: integer;override;
    function getColCount: integer;override;
    function getRowValue(ACol,ARow: integer): string;override;
  end;

  ICCDataset = interface(IInterface)
    procedure OpenQuery(ASQL: string);
    procedure ExecuteNonQuery(ASQL: string);
    //function Dataset: TDataSet;

    procedure setDataset(ADataset: TDataSet);
    function getDataset: TDataSet;
  end;

  TCCDataset = class(TInterfacedObject, ICCDataset)
  protected
    FDataset: TDataSet;
    procedure setDataset(ADataset: TDataSet);
    function getDataset: TDataSet;
  public
    procedure OpenQuery(ASQL: string); virtual;
    procedure ExecuteNonQuery(ASQL: string); virtual;
    property Dataset: TDataSet read getDataset write setDataset;
  end;

implementation

{ TDatasetReader }

function TDatasetReader.getColCount: integer;
begin
  inherited;
  result := TDataSet(getObject).FieldCount;
end;

function TDatasetReader.getRowCount: integer;
begin
  inherited;
  result := TDataSet(getObject).RecordCount;
end;

function TDatasetReader.getRowValue(ACol, ARow: integer): string;
var
  ActiveRecNo, Distance: Integer;
  Dataset: TDataSet;
begin
  Dataset := TDataSet(getObject);
  ActiveRecNo := DataSet.RecNo;
  if (ARow <> ActiveRecNo) then
    begin
      DataSet.DisableControls;
      try
        Distance := ARow - ActiveRecNo;
        DataSet.MoveBy(Distance);


      finally
        DataSet.EnableControls;
      end;
    end;

  Result := Dataset.Fields[ACol].AsString;
end;

{ TCCDataset }

procedure TCCDataset.ExecuteNonQuery(ASQL: string);
begin

end;

function TCCDataset.getDataset: TDataSet;
begin
  Result := FDataset;
end;

procedure TCCDataset.OpenQuery(ASQL: string);
begin

end;

procedure TCCDataset.setDataset(ADataset: TDataSet);
begin
  FDataset := ADataset;
end;

end.
