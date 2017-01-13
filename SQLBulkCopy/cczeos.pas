unit cczeos;

interface
uses
  classes,sysutils,ZDataset, Data.DB,
  ccbulkdbcore;

type
  TCCZeosDataset = class(TCCDataset)
  public
    procedure OpenQuery(ASQL: string);override;
    procedure ExecuteNonQuery(ASQL: string);override;
  end;

implementation

{ TCCUnidacDataset }

procedure TCCZeosDataset.ExecuteNonQuery(ASQL: string);
begin
  inherited;
  with TZQuery(getDataset) do
  begin
    Close;
    SQL.Text := ASQL;
    ExecSQL;
  end;
end;

procedure TCCZeosDataset.OpenQuery(ASQL: string);
begin
  inherited;
  with TZQuery(getDataset) do
  begin
    Close;
    SQL.Text := ASQL;
    Open;
  end;
end;

end.
