unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls,fphttpclient,fpjson,jsonparser;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnTambah: TButton;
    btnUbah: TButton;
    btnBuka: TButton;
    edId: TEdit;
    edNama: TEdit;
    edAlamat: TEdit;
    edGender: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    sgData: TStringGrid;
    procedure btnBukaClick(Sender: TObject);
    procedure btnTambahClick(Sender: TObject);
    procedure btnUbahClick(Sender: TObject);
    procedure sgDataSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    procedure ClearForm;
    procedure LoadData;
    //karena tambah dan ubah apinya hampir mirip, maka disederhanakan
    //dan dibuat 1 fungsi
    function SimpanData(aksi: string): Boolean;
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnBukaClick(Sender: TObject);
begin
  LoadData;
end;

procedure TForm1.btnTambahClick(Sender: TObject);
begin
  if SimpanData('tambah') then
     ShowMessage('Data berhasil disimpan!')
  else
    ShowMessage('Data gagal disimpan!');

end;

procedure TForm1.btnUbahClick(Sender: TObject);
begin
  if SimpanData('ubah') then
     ShowMessage('Data berhasil disimpan!')
  else
    ShowMessage('Data gagal disimpan!');
end;

procedure TForm1.sgDataSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if aRow = 0 then exit;

  edId.Text := sgData.Cells[0,aRow];
  edNama.Text := sgData.Cells[1,aRow];
  edAlamat.Text := sgData.Cells[2,aRow];
  edGender.Text := sgData.Cells[3,aRow];
end;

procedure TForm1.ClearForm;
var
  i: integer;
begin
  for i:=0 to ComponentCount-1 do
    if Components[i] is TEdit then
       TEdit(Components[i]).Clear;
end;

procedure TForm1.LoadData;
var
  ret: string;
  adata: TJSONData;
  aarr: TJSONArray;
  i: integer;
begin
  //fpc >= 2.7.1
  ret   := TFPCustomHTTPClient.SimpleGet('http://kulgram.tigorworks.com/demo.cgi/anggota/');
  adata := GetJSON(trim(ret));

  aarr  := TJSONArray(adata);

  sgData.RowCount := aarr.Count+1;
  for i:=0 to aarr.Count-1 do
  begin
    with sgData do
    begin
      Cells[0,i+1] := aarr[i].FindPath('id').AsString;
      Cells[1,i+1] := aarr[i].FindPath('nama').AsString;
      Cells[2,i+1] := aarr[i].FindPath('alamat').AsString;
      Cells[3,i+1] := aarr[i].FindPath('gender').AsString;
    end;
  end;
end;

function TForm1.SimpanData(aksi: string): Boolean;
var
  aurl: string;
  odata: TJSONObject;
  oret: TJSONData;
  ret: String;
  bret: boolean;
begin
  aurl := 'http://kulgram.tigorworks.com/demo.cgi/anggota/' + aksi;
  odata := TJSONObject.Create;
  try
    odata.Add('id',edId.Text);
    odata.Add('nama',edNama.Text);
    odata.Add('alamat',edAlamat.Text);
    odata.Add('gender',edGender.Text);
    with TFPHTTPClient.Create(nil) do
    begin
      ret := FormPost(aurl,odata.AsJSON);
      oret := GetJSON(Trim(ret));
      bret := oret.FindPath('result').AsString = 'sukses';
    end;

    Result := bret;
    ClearForm;
    LoadData;
  finally
    odata.Free;
  end;
end;

end.

