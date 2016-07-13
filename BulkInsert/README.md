# BulkInsert

> Dibuat oleh 	: ***Tigor Mangatur Manurung***

> berkat semangat : ***Caca (Clara Nathania Manurung)***


Bulkinsert merupakan komponen non visual (non-vcl) untuk memudahkan melakukan generate sql terhadap grid. 

### Teknologi
Library ini saya buat dengan menggunakan lazarus 1.6 FPC 3.0, namun saya rasa library ini bisa digunakan di delphi karena saya tidak menggunakan komponen-komponen khusus.

### Contoh Penggunaan

```pascal

uses
	...,ccbulkinsert;


//cara 1
oBulkInsert := TCCBulkInsert.Create;
  try
    oBulkInsert.ColumnNames.Add('code');
    oBulkInsert.ColumnNames.Add(''); //kosongkan apabila ingin kolomnya tidak discan
    oBulkInsert.ColumnNames.Add('price');
    oBulkInsert.ColumnNames.Add('qty');
    oBulkInsert.ColumnNames.Add('');
    oBulkInsert.SingleStatement:=CheckBox1.Checked; //single statement
    oBulkInsert.StartRow   := 0;
    oBulkInsert.GridSource := StringGrid1;
    oBulkInsert.HiddenData.Add(Format('id=%s',[Edit1.Text]));

    //get sql
    Memo1.Text:= oBulkInsert.getSQL;
  finally
    FreeAndNil(oBulkInsert);
  end;     


  //cara 2
  Memo1.Text := StringGrid1.getSQL('dettrans',      // tablename
                       ['code','','price','qty',''],      // column names
                       [Format('id=%s',[Edit1.Text])],    // hidden data
                       1,                                 // start row
                       0,                                 // start col
                       CheckBox1.Checked);                // single statement
```


### Kelebihan
dapat dicustom dengan mudah untuk membaca grid2 yang lainnya, cukup dengan menginherite class **TCCListviewReader**, seperti contoh listbox dibawah ini :
```pascal
//class THiddenValue untuk menyimpan data listbox (hanya sebagai contoh)
THiddenValue = class
    data1,data2,data3,data4: string;
  public
    constructor Create(Adata1,Adata2,Adata3,Adata4: string);
  end; 

TListboxReader = class(TCCCustomReader)
  public
    function getRowCount: integer;override;
    function getColCount: integer;override;
    function getRowValue(ACol,ARow: integer): string;override;
  end; 


//lalu supaya menjadi helper, buat class helper dengan turunan TCCBaseHelper
TCCListboxHelper = class helper(TCCBaseHelper) for TListBox
end; 

//implementation

{ TListboxReader } 

function TListboxReader.getRowCount: integer;
begin
  //gunakan getControl untuk mendapatkan control parent
  Result := TListBox(getControl).Count;
end;

function TListboxReader.getColCount: integer;
begin
  Result := 5;
end;

function TListboxReader.getRowValue(ACol, ARow: integer): string;
begin
  case ACol of
    0:
      Result := TListBox(getControl).Items[ARow];
    1:
      Result := THiddenValue(TListBox(getControl).Items.Objects[ARow]).data1;
    2:
      Result := THiddenValue(TListBox(getControl).Items.Objects[ARow]).data2;
    3:
      Result := THiddenValue(TListBox(getControl).Items.Objects[ARow]).data3;
    4:
      Result := THiddenValue(TListBox(getControl).Items.Objects[ARow]).data4;
  end;
end;  
```

### Pengembangan
Library ini saya buat hanya iseng2 saja, tidak ada garansi bahwa library ini akan terus dikembangkan. silahkan menggunakan dan mengembangkannya..sukur2 dishare kembali :)

### FAQ
- ***kenapa tidak membuat library yang langsung memasukkan data ke database???*** tidak apa2, sengaja dibuat hanya sampai generate sql saja :)
- ***Sebenarnya untuk apa library ini?*** salah satu contoh penggunaan library ini bisa diterapkan untuk form transaksi yang terdapat grid untuk menampung item barang yang akan disimpan ke database bersamaan


### Kesimpulan
:)