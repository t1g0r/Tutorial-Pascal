unit ccbulkinsert;

{$mode objfpc}{$H+}

{
catatan
-------------
-

todo
-------------
- multithread? :)
- save directly to db? :) DIY ;)
}

interface

uses
  Classes, SysUtils,Controls,grids,comctrls;

type

  TOnGetValue = procedure(var value: string; ACol: integer) of object;
  TOnGetSQL = procedure(ASQL: string) of object;

  ICCBulkInsert = interface(IInterface)
    function getSQL: string;
    function getRowCount: integer;
    function getValue(ACol,ARow: integer): string;
  end;

  ICCReader = interface(IInterface)
    procedure setControl(AControl: TWinControl);
    function getControl: TWinControl;
    function getRowCount: integer;
    function getColCount: integer;
    function getRowValue(ACol,ARow: integer): string;
    function getRowValue(ARow: integer): TStringList;
    procedure setLastPosition(ARow: integer);
    function getRecNo: integer;
    function firstRow: TStringList;
    function nextRow: TStringList;
    function prevRow: TStringList;
    function lastRow: TStringList;
    function isEOF: boolean;
  end;

  { TCCCustomReader }

  TCCCustomReader = class(TInterfacedObject,ICCReader)
  private
    FControl: TWinControl;
    FLastPosition: integer;
  public
    constructor Create;
    procedure setControl(AControl: TWinControl);
    function getControl: TWinControl;
    function getRowValue(ARow: integer): TStringList;
    procedure setLastPosition(ARow: integer);
    function getRecNo: integer;
    function firstRow: TStringList;
    function nextRow: TStringList;
    function prevRow: TStringList;
    function lastRow: TStringList;
    function isEOF: boolean;

    //method virtual abstract (must be implement)
    function getRowCount: integer;virtual;abstract;
    function getColCount: integer;virtual;abstract;
    function getRowValue(ACol,ARow: integer): string;virtual;abstract;
  end;

  { TCCStringGridReader }

  TCCStringGridReader = class(TCCCustomReader)
  public
    function getRowCount: integer;override;
    function getColCount: integer;override;
    function getRowValue(ACol,ARow: integer): string;override;
  end;

  { TCCListviewReader }

  TCCListviewReader = class(TCCCustomReader)
    public
      function getRowCount: integer;override;
      function getColCount: integer;override;
      function getRowValue(ACol,ARow: integer): string;override;
  end;

  { TCCBulkInsert }

  TCCBulkInsert = class(TInterfacedObject,ICCBulkInsert)
  private
    FColumnNames: TStringList;
    FGridSource: TWinControl;
    FHiddenData: TStringList;
    FRowCount: integer;
    FSingleStatement: boolean;
    FSQLInsertStatement: string;
    FStartCol: integer;
    FStartRow: integer;
    FTablename: string;
    FReader: ICCReader;
    fOnGetValue: TOnGetValue;
    function getRowCount: integer;
    procedure SetGridSource(AValue: TWinControl);
    procedure SetReader(AValue: ICCReader);
  public
    constructor Create;
    destructor Destroy;override;
    function getSQL: string;virtual;
    function getValue(ACol,ARow: integer): string;
    property Reader: ICCReader read FReader write SetReader;
    property StartRow: integer read FStartRow write FStartRow default 0;
    property StartCol: integer read FStartCol write FStartCol default 0;
    property GridSource: TWinControl read FGridSource write SetGridSource;
    property RowCount: integer read getRowCount write FRowCount;
    property Tablename: string read FTablename write FTablename;
    property HiddenData: TStringList read FHiddenData write FHiddenData;
    property ColumnNames: TStringList read FColumnNames write FColumnNames;
    property SingleStatement: boolean read FSingleStatement write FSingleStatement;
  end;

  { TCCBaseHelper }

  TCCBaseHelper = class helper for TWinControl
    function getSQL(ATablename: string ; AColumnNames: array of string ; AHiddenData: array of string ;AStartRow: integer = 0 ; AStartCol: integer = 0 ;ASingleStatement: Boolean = true): string;
  end;

  { TCCStringGridHelper }

  TCCStringGridHelper = class helper(TCCBaseHelper) for TStringGrid
  end;

  TCCListviewHelper = class helper(TCCBaseHelper) for TListView
  end;

implementation

{ TCCBaseHelper }

function TCCBaseHelper.getSQL(ATablename: string;
  AColumnNames: array of string ; AHiddenData: array of string;
  AStartRow: integer; AStartCol: integer; ASingleStatement: Boolean): string;
var
  FAdapter: TCCBulkInsert;
  i: integer;
begin
  FAdapter := TCCBulkInsert.Create;
  try
     for i:=0 to length(AColumnNames)-1 do
       FAdapter.ColumnNames.Add(AColumnNames[i]);

     for i:=0 to length(AHiddenData)-1 do
       FAdapter.HiddenData.Add(AHiddenData[i]);

    FAdapter.Tablename := ATablename;
    FAdapter.StartRow:= AStartRow;
    FAdapter.StartCol:=AStartCol;
    FAdapter.SingleStatement:=ASingleStatement;

    FAdapter.GridSource := self;
    Result := FAdapter.getSQL;
  finally
    FreeAndNil(FAdapter);
  end;
end;



{ TCCListviewReader }

function TCCListviewReader.getRowCount: integer;
begin
  Result := TListView(FControl).Items.Count;
end;

function TCCListviewReader.getColCount: integer;
begin
  Result := TListView(FControl).ColumnCount;
end;

function TCCListviewReader.getRowValue(ACol, ARow: integer): string;
var
  ret: String;
begin
  ret:='';
  with TListView(FControl).Items.Item[ARow] do
  begin
    if ACol = 0 then
       ret:=Caption
    else
      ret:=SubItems[ACol-1];
  end;
  Result := ret;
end;

{ TCCStringGridReader }

function TCCStringGridReader.getRowCount: integer;
begin
  Result := TStringGrid(FControl).RowCount;
end;

function TCCStringGridReader.getColCount: integer;
begin
  Result := TStringGrid(FControl).ColCount;
end;

function TCCStringGridReader.getRowValue(ACol, ARow: integer): string;
var
  s: string;
begin
  s := TStringGrid(FControl).Cells[ACol,ARow];
  Result := s;
end;

{ TCCCustomReader }

constructor TCCCustomReader.Create;
begin
  FLastPosition:=-1;
end;

procedure TCCCustomReader.setControl(AControl: TWinControl);
begin
  FControl := AControl;
end;

function TCCCustomReader.getControl: TWinControl;
begin
  Result := FControl;
end;

function TCCCustomReader.getRowValue(ARow: integer): TStringList;
var
  i: integer;
begin
  Result := TStringList.Create;
  for i:=0 to getColCount-1 do
  begin
    Result.Add(getRowValue(i,ARow));
  end;
end;

procedure TCCCustomReader.setLastPosition(ARow: integer);
begin
  FLastPosition:=ARow;
end;


function TCCCustomReader.getRecNo: integer;
begin
  Result := FLastPosition;
end;

function TCCCustomReader.firstRow: TStringList;
begin
  FLastPosition:=0;
  Result:=getRowValue(FLastPosition);
end;

function TCCCustomReader.nextRow: TStringList;
begin
  if FLastPosition < getRowCount-1 then
     inc(FLastPosition,1);

  Result:=getRowValue(FLastPosition);
end;

function TCCCustomReader.prevRow: TStringList;
begin
  if FLastPosition>0 then
     Inc(FLastPosition,-1);
  Result:=getRowValue(FLastPosition);
end;

function TCCCustomReader.lastRow: TStringList;
begin
  FLastPosition:=getRowCount-1;
  Result:=getRowValue(FLastPosition);
end;

function TCCCustomReader.isEOF: boolean;
begin
  result := FLastPosition = getRowCount-1;
end;

{ TCCBulkInsert }

function TCCBulkInsert.getSQL: string;
var
  i,c: integer;
  slTemp: TStringList;
  scolumn,srow,srow_,sql,_temp: string;
begin
  result := '';
  if SingleStatement then
     FSQLInsertStatement:='insert into %TABLENAME%(%COLUMNS%)values'
  else
      FSQLInsertStatement:='insert into %TABLENAME%(%COLUMNS%)values(%VALUES%);';
  if (getRowCount - StartRow) < 1 then exit;
  //get format column
  // (column1,column2,...,columnN)
  scolumn:='';
  srow_:='';
  //hidden column
  for i:=0 to FHiddenData.Count-1 do
  begin
      scolumn:=Format('%s%s,',[scolumn,Trim(Copy(FHiddenData[i],1,Pos('=',FHiddenData[i])-1))]);
      srow_ := Format('%s''%s'',',[srow_,Trim(Copy(FHiddenData[i],Pos('=',FHiddenData[i])+1,Length(FHiddenData[i])))]);
  end;

  for i:=FStartCol to ColumnNames.Count-1 do
  begin
    if Trim(ColumnNames[i]) = '' then Continue;
    scolumn:=scolumn + ColumnNames[i] + ',';
  end;

  Delete(scolumn,length(scolumn),1);

  slTemp := TStringList.Create;
  try

    for i:=FStartRow to getRowCount-1 do
    begin
      srow := srow_;
      //get data for all column
      for c:=FStartCol to ColumnNames.Count-1 do
      begin
        if Trim(ColumnNames[c]) = '' then Continue;
        srow := Format('%s''%s'',',[srow,getValue(c,i)]);
      end;

      delete(srow,Length(srow),1);
      if not SingleStatement then
      begin
        sql := FSQLInsertStatement;
        sql := StringReplace(sql,'%TABLENAME%',FTablename,[rfReplaceAll]);
        sql := StringReplace(sql,'%COLUMNS%',scolumn,[rfReplaceAll]);
        sql := StringReplace(sql,'%VALUES%',srow,[rfReplaceAll]);
        slTemp.Add(sql);
      end
      else
        sql := Format('%s(%s),',[sql,srow]);

    end;
    if SingleStatement then
    begin
      delete(sql,Length(sql),1);
      _temp := FSQLInsertStatement;
      _temp := StringReplace(_temp,'%TABLENAME%',FTablename,[rfReplaceAll]);
      _temp := StringReplace(_temp,'%COLUMNS%',scolumn,[rfReplaceAll]);
      sql := _temp + sql + ';';

    end
    else
        sql := slTemp.Text;

    result := sql;
  finally
    FreeAndNil(slTemp);
  end;
end;


function TCCBulkInsert.getValue(ACol, ARow: integer): string;
var
  s: string;
begin
  s := FReader.getRowValue(ACol,ARow);
  //triggering event
  if Assigned(fOnGetValue) then
     fOnGetValue(s,ACol);

  Result := s;
end;


function TCCBulkInsert.getRowCount: integer;
begin
  if Assigned(FReader) then
     Result := FReader.getRowCount
  else
    Result := 0;
end;

procedure TCCBulkInsert.SetGridSource(AValue: TWinControl);
begin
  if FGridSource=AValue then Exit;
  FGridSource:=AValue;

  if AValue is TStringGrid then
     SetReader(TCCStringGridReader.Create)
  else if AValue is TListView then
       SetReader(TCCListviewReader.Create);

  if Assigned(FReader) then
     FReader.setControl(AValue);
end;

procedure TCCBulkInsert.SetReader(AValue: ICCReader);
begin
  if FReader=AValue then Exit;
  FReader:=AValue;
  FReader.setLastPosition(StartRow-1);
end;

constructor TCCBulkInsert.Create;
begin
  FColumnNames := TStringList.Create;
  FHiddenData := TStringList.Create;
  FSingleStatement:=False;
end;

destructor TCCBulkInsert.Destroy;
begin
  FreeAndNil(FColumnNames);
  FreeAndNil(FHiddenData);
  inherited Destroy;
end;

end.

//love u my little angle caca :) :*
