unit unitmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, ComCtrls, ExtCtrls, ccbulkinsert;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    ListView1: TListView;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
const
  ROW_COUNT = 101;
var
  i: integer;
begin
  case PageControl1.ActivePageIndex of
  0:
    begin
      StringGrid1.RowCount:=ROW_COUNT;
      for i:=1 to ROW_COUNT-1 do
      begin
        with StringGrid1 do
        begin
          Cells[0,i] := Format('B-%d',[i]);
          Cells[1,i] := Format('Barang-%d',[i]);
          Cells[2,i] := Format('%d',[200 * i]);
          Cells[3,i] := Format('%d',[3]);
          Cells[4,i] := Format('%d',[StrToInt(Cells[2,i]) * StrToInt(Cells[3,i])]);
        end;

      end;
    end;
  1:
    begin
      ListView1.Items.BeginUpdate;
      for i:=1 to ROW_COUNT-1 do
      begin
        with ListView1.Items.Add do
        begin
          Caption:= Format('B-%d',[i]);
          SubItems.Add(Format('Barang-%d',[i]));
          SubItems.Add(Format('%d',[200 * i]));
          SubItems.Add(Format('%d',[3]));
          SubItems.Add(Format('%d',[StrToInt(SubItems[1]) * StrToInt(SubItems[2])]));
        end;

      end;
      ListView1.Items.EndUpdate;
    end;
  end;


end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    case PageControl1.ActivePageIndex of
    0:
      begin
        Memo1.Text := StringGrid1.getsql('dettrans',      // tablename
                       ['code','','price','qty',''],      // column names
                       [Format('id=%s',[Edit1.Text])],    // hidden data
                       1,                                 // start row
                       0,                                 // start col
                       CheckBox1.Checked);                // single statement
      end;
    1:
      begin
        Memo1.Text := ListView1.getsql('dettrans',        // tablename
                       ['code','','price','qty',''],      // column names
                       [Format('id=%s',[Edit1.Text])],    // hidden data
                       0,                                 // start row
                       0,                                 // start col
                       CheckBox1.Checked);                // single statement
      end;
    end;

end;


procedure TForm1.PageControl1Change(Sender: TObject);
begin
  StringGrid1.RowCount:=1;
  ListView1.Items.Clear;
  Memo1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  oBulkInsert: TCCBulkInsert;
begin
  oBulkInsert := TCCBulkInsert.Create;
  try
    oBulkInsert.ColumnNames.Add('code');
    oBulkInsert.ColumnNames.Add(''); //kosongkan apabila ingin kolomnya tidak discan
    oBulkInsert.ColumnNames.Add('price');
    oBulkInsert.ColumnNames.Add('qty');
    oBulkInsert.ColumnNames.Add('');
    oBulkInsert.SingleStatement:=CheckBox1.Checked; //single statement

    //start row index
    oBulkInsert.Tablename:='dettrans';
    case  PageControl1.ActivePageIndex of
          0:
            begin
              oBulkInsert.StartRow   :=1;
              oBulkInsert.GridSource := StringGrid1;
            end;
          1:
            begin
              oBulkInsert.StartRow   :=0;
              oBulkInsert.GridSource := ListView1;
            end;
    end;
    oBulkInsert.HiddenData.Add(Format('id=%s',[Edit1.Text]));
    Memo1.Text:= oBulkInsert.getSQL;
  finally
    FreeAndNil(oBulkInsert);
  end;
end;

end.

