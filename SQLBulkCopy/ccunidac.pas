unit ccunidac;

interface
uses
  classes,sysutils,UniProvider, MySQLUniProvider, Data.DB,
  MemDS, DBAccess, Uni,ccbulkdbcore;

type
  TCCUnidacDataset = class(TCCDataset)
  public
    procedure OpenQuery(ASQL: string);override;
    procedure ExecuteNonQuery(ASQL: string);override;
  end;

implementation

{ TCCUnidacDataset }

procedure TCCUnidacDataset.ExecuteNonQuery(ASQL: string);
begin
  inherited;
  with TUniQuery(getDataset) do
  begin
    Close;
    SQL.Text := ASQL;
    Execute;
  end;
end;

procedure TCCUnidacDataset.OpenQuery(ASQL: string);
begin
  inherited;
  with TUniQuery(getDataset) do
  begin
    Close;
    SQL.Text := ASQL;
    Execute;
  end;
end;

end.
