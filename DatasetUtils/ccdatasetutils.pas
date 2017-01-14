unit ccdatasetutils;

{
  Dataset Utils - Delphi / Lazarus Helper
  ------------------------------------
  Author  : Tigor M Manurung
  Email   : tigor@tigorworks.com

  Helper for TDataset :)

}

interface

uses
  classes,sysutils,db;

type
  {$IFNDEF fpc}
    TDatasetLoopProc = reference to procedure();
    TDatasetLoopProcField = reference to procedure(AField: TFields);
  {$ENDIF}
  TCCDatasetHelper = class helper for TDataSet
    function ToJson: string;
    procedure SaveToCSV(const AFilename: string);
    function NotEof: Boolean;
    {$IFNDEF fpc}
      procedure WhileNotEof(OnLoop: TDatasetLoopProc);overload;
      procedure WhileNotEof(OnLoop: TDatasetLoopProcField);overload;
    {$ENDIF}
  end;

implementation

{ TCCDatasetHelper }

procedure TCCDatasetHelper.SaveToCSV(const AFilename: string);
var
  c: integer;
  header,row: string;
  rows: TStringList;
begin
  First;

  rows := TStringList.Create;
  try
    for c := 0 to Fields.Count - 1 do
      header := header + Fields[c].FieldName + ',';

    System.Delete(header,Length(header),1);

    rows.Add(header);

    while not Eof do
    begin
      row := '';
      for c := 0 to Fields.Count - 1 do
      begin
        case Fields[c].DataType of
          ftDate: row := row + '"' + FormatDateTime('yyyy-mm-dd',Fields[c].AsDateTime) + '",';
          ftDateTime: row := row + '"' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Fields[c].AsDateTime) + '",';
          else
            row := row + '"' + Fields[c].AsString + '",';
        end;
      end;

      System.Delete(row,Length(row),1);
      rows.Add(row);
      Next;
    end;
  finally
    if Trim(rows.Text) <> '' then
      rows.SaveToFile(AFilename);
    FreeAndNil(rows);
  end;


end;

function TCCDatasetHelper.ToJson: string;
var
  c: integer;
  jsonarray,jsonobject,_temp,row,rows: string;
begin
  jsonarray := '[%s]';
  jsonobject := '"%s":%s';
  First;

  rows := '';

  while not Eof do
  begin
    row := '';
    for c := 0 to Fields.Count - 1 do
    begin

      case Fields[c].DataType of
        ftLargeint,ftInteger,ftSmallint,ftWord: _temp := Format(jsonobject,[Fields[c].FieldName,Fields[c].AsString]);
        ftBoolean: 
          begin
            if Fields[c].AsBoolean then
              _temp := Format(jsonobject,[Fields[c].FieldName,Fields[c],'true'])
            else
              _temp := Format(jsonobject,[Fields[c].FieldName,Fields[c],'false'])  
          end;
        ftDate: _temp := Format(jsonobject,[Fields[c].FieldName,'"' + FormatDateTime('yyyy-mm-dd',Fields[c].AsDateTime) + '"']);
        ftDateTime: _temp := Format(jsonobject,[Fields[c].FieldName,'"' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Fields[c].AsDateTime) + '"']);
        else
          _temp := Format(jsonobject,[Fields[c].FieldName,format('"%s"',[Fields[c].AsString])])
      end;
      row := row + _temp + ',';
    end;
    System.Delete(row,Length(row),1);
    
    rows := Format('%s{%s},',[rows,row]);
    Next;
  end;

  System.Delete(rows,Length(rows),1);
  rows := Format(jsonarray,[rows]);
  result := rows;
end;

procedure TCCDatasetHelper.WhileNotEof(OnLoop: TDatasetLoopProcField);
var
  bkCurrent: TBookmark;
begin
  bkCurrent := Bookmark;
  while NotEof do
  begin
    OnLoop(Fields);
    Next;
  end;
  self.Bookmark := bkCurrent
end;

procedure TCCDatasetHelper.WhileNotEof(OnLoop: TDatasetLoopProc);
var
  bkCurrent: TBookmark;
begin
  bkCurrent := Bookmark;
  while NotEof do
  begin
    OnLoop();
    Next;
  end;
  self.Bookmark := bkCurrent
end;

function TCCDatasetHelper.NotEof: Boolean;
begin
  Result := not Eof;
end;

end.

//love u my little angle caca :) :*
