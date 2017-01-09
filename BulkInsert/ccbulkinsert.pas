unit ccbulkinsert;

//{$mode objfpc}{$H+}

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
    function getObject: TObject;
    procedure setObject(AObject: TObject);
    function getRowCount: integer;
    function getColCount: integer;
    function getRowValue(ACol,ARow: integer): string;overload;
    function getRowValue(ARow: integer): TStringList;overload;
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
    FObject: TObject;
    FLastPosition: integer;
  public
    constructor Create;
    function getObject: TObject;
    procedure setObject(AObject: TObject);
    procedure setControl(AControl: TWinControl);
    function getControl: TWinControl;
    function getRowValue(ARow: integer): TStringList;overload;
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
    function getRowValue(ACol,ARow: integer): string;overload;virtual;abstract;
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
    FObjectSource: TObject;
    FRowCount: integer;
    FSingleStatement: boolean;
    FSQLInsertStatement: string;
    FSQLUpdateStatement: string;
    FStartCol: integer;
    FStartRow: integer;
    FTablename: string;
    FReader: ICCReader;
    fOnGetValue: TOnGetValue;
    FColMustExists: integer;
    FUpdateIfRecordExists: boolean;
    FColumnKeyIndex: integer;
    FColumnKeyName: string;
    FHiddenRowForInsertOnly: Boolean;
    function getRowCount: integer;
    procedure SetGridSource(AValue: TWinControl);
    procedure SetObjectSource(AValue: TObject);
    procedure SetReader(AValue: ICCReader);
  public
    constructor Create;
    destructor Destroy;override;
    function getSQL: string;virtual;
    function getValue(ACol,ARow: integer): string;
    property UpdateIfRecordExists: boolean read FUpdateIfRecordExists write FUpdateIfRecordExists;
    property HiddenRowForInsertOnly: Boolean read FHiddenRowForInsertOnly write FHiddenRowForInsertOnly;
    property ColumnKeyName: string read FColumnKeyName write FColumnKeyName;
    property ColumnKeyIndex: integer read FColumnKeyIndex write FColumnKeyIndex; //pointing to column PK to activating updateifrecordexists
    property Reader: ICCReader read FReader write SetReader;
    property StartRow: integer read FStartRow write FStartRow default 0;
    property StartCol: integer read FStartCol write FStartCol default 0;
    property GridSource: TWinControl read FGridSource write SetGridSource;
    property ObjectSource: TObject read FObjectSource write SetObjectSource;
    property RowCount: integer read getRowCount write FRowCount;
    property Tablename: string read FTablename write FTablename;
    property HiddenData: TStringList read FHiddenData write FHiddenData;
    property ColumnNames: TStringList read FColumnNames write FColumnNames;
    property SingleStatement: boolean read FSingleStatement write FSingleStatement;
    property ColMustExists: integer read FColMustExists write FColMustExists;
  end;

  { TCCBaseHelper }

  TCCBaseHelper = class helper for TWinControl
    function getSQL(ATablename: string ; AColumnNames: array of string ;
             AHiddenData: array of string ;AStartRow: integer = 0 ; AStartCol: integer = 0 ;
             ASingleStatement: Boolean = true ; AColMustExists: integer = -1 ; AUpdateIfRecordExists : Boolean = false  ;
             ACustomReader: TCCCustomReader = nil): string;
  end;

  { TCCStringGridHelper }

  TCCStringGridHelper = class helper(TCCBaseHelper) for TStringGrid
  end;

  TCCListviewHelper = class helper(TCCBaseHelper) for TListView
  end;


function getUUID: string;

implementation

function getUUID: string;
var
  Uid: TGuid;
  ret: HResult;
begin
  ret := CreateGuid(Uid);
  if ret = S_OK then
     result := GuidToString(Uid);


end;

{ TCCBaseHelper }

function TCCBaseHelper.getSQL(ATablename: string;
  AColumnNames: array of string ; AHiddenData: array of string;
  AStartRow: integer; AStartCol: integer ;
  ASingleStatement: Boolean ;
  AColMustExists: integer ; AUpdateIfRecordExists : Boolean ; ACustomReader: TCCCustomReader): string;
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
    FAdapter.ColMustExists := AColMustExists;
    FAdapter.UpdateIfRecordExists := AUpdateIfRecordExists;
    FAdapter.SingleStatement:=ASingleStatement;

    if ACustomReader <> nil then
      FAdapter.Reader := ACustomReader;

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
  Result := TListView(FControl).Columns.Count;
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

function TCCCustomReader.getObject: TObject;
begin
  Result := FObject;;
end;

procedure TCCCustomReader.setObject(AObject: TObject);
begin
  FObject := AObject;
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
  scolumn,srow,srow_,sql,sqlupdate,shiddenrowupdate,_temp,swhere: string;
begin
  result := '';
  sql := '';
  sqlupdate := '';
  FSQLUpdateStatement := 'update %TABLENAME% SET %VALUES% WHERE %WHERE%;';
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
      shiddenrowupdate := Format('%s%s=''%s'',',[shiddenrowupdate,Trim(Copy(FHiddenData[i],1,Pos('=',FHiddenData[i])-1)),
                                  Trim(Copy(FHiddenData[i],Pos('=',FHiddenData[i])+1,Length(FHiddenData[i])))]);
  end;

  for i:=FStartCol to ColumnNames.Count-1 do
  begin
    if Trim(ColumnNames[i]) = '' then Continue;
    scolumn:=scolumn + ColumnNames[i] + ',';
  end;

  Delete(scolumn,length(scolumn),1);
  //Delete(shiddenrowupdate,length(shiddenrowupdate),1);

  slTemp := TStringList.Create;
  try

    for i:=FStartRow to getRowCount-1 do
    begin
      srow := '';

      if (UpdateIfRecordExists) and (getValue(FColumnKeyIndex,i) <> '') then
      begin
        if (FHiddenRowForInsertOnly = False) then
          srow := shiddenrowupdate
      end
      else
        srow := srow_;

      if ColMustExists > -1 then
      begin
        if getValue(ColMustExists,i) = '' then
          Continue;
      end;

      //get data for all column
      for c:=FStartCol to ColumnNames.Count-1 do
      begin
        if Trim(ColumnNames[c]) = '' then Continue;


        //if update activated
        if (UpdateIfRecordExists) and (getValue(FColumnKeyIndex,i) <> '') then
        begin //update
          srow := Format('%s%s=''%s'',',[srow,ColumnNames[c],getValue(c,i)]);
        end
        else  //insert
          srow := Format('%s''%s'',',[srow,getValue(c,i)]);
      end;

      delete(srow,Length(srow),1);

      if (UpdateIfRecordExists) and (getValue(FColumnKeyIndex,i) <> '') then
      begin
        //if auto update activated

        swhere := Format('%s=''%s''',[FColumnKeyName,getValue(FColumnKeyIndex,i)]);
        sqlupdate := sqlupdate + FSQLUpdateStatement;

        sqlupdate := StringReplace(sqlupdate,'%TABLENAME%',FTablename,[rfReplaceAll]);
        sqlupdate := StringReplace(sqlupdate,'%VALUES%',srow,[rfReplaceAll]);
        sqlupdate := StringReplace(sqlupdate,'%WHERE%',swhere,[rfReplaceAll]);
        sqlupdate := StringReplace(sqlupdate,'#UUID#',getUUID,[rfReplaceAll]);
      end
      else
      begin

        if not SingleStatement then
        begin
          sql := FSQLInsertStatement;
          sql := StringReplace(sql,'%TABLENAME%',FTablename,[rfReplaceAll]);
          sql := StringReplace(sql,'%COLUMNS%',scolumn,[rfReplaceAll]);
          sql := StringReplace(sql,'%VALUES%',srow,[rfReplaceAll]);
          sql := StringReplace(sql,'%WHERE%',swhere,[rfReplaceAll]);
          sql := StringReplace(sql,'#UUID#',getUUID,[rfReplaceAll]);
          slTemp.Add(sql);
        end
        else
          sql := Format('%s(%s),',[sql,srow]);
      end;

      sql := StringReplace(sql,'#UUID#',getUUID,[rfReplaceAll]);
    end;  //end for row


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

    Delete(sqlupdate,Length(sqlupdate),1);

    result := sql + sqlupdate;
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

procedure TCCBulkInsert.SetObjectSource(AValue: TObject);
begin
  if FObjectSource=AValue then Exit;

  FObjectSource:=AValue;

  FReader.setObject(AValue);
end;

procedure TCCBulkInsert.SetReader(AValue: ICCReader);
begin
  if FReader=AValue then Exit;
  FReader:=AValue;
  FReader.setLastPosition(StartRow-1);
end;

constructor TCCBulkInsert.Create;
begin
  FUpdateIfRecordExists := False;
  FHiddenRowForInsertOnly := False;
  FColumnNames := TStringList.Create;
  FHiddenData := TStringList.Create;
  FSingleStatement:=False;
  ColMustExists := -1;
end;

destructor TCCBulkInsert.Destroy;
begin
  FreeAndNil(FColumnNames);
  FreeAndNil(FHiddenData);
  inherited Destroy;
end;

end.

//love u my little angle caca :) :*
