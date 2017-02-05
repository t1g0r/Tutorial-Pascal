unit uanggota;

{$mode objfpc}{$H+}

interface

uses
  BrookAction,BrookUtils,udm,fpjson,classes,sysutils;

type

  { TAnggota }

  TAnggota = class(TBrookAction)
  public
    procedure Get; override;
    procedure Post; override;
  end;

implementation

procedure TAnggota.Get;
var
  jarr: TJSONArray;
  job: TJSONObject;
begin
  with dm.qAct do
  begin
    Close;
    SQL.Text:='select * from anggota';
    Open;

    jarr := TJSONArray.Create;
    try
      first;
      while not EOF do
      begin
        job := TJSONObject.Create;
        job.Add('id',FieldByName('id').AsInteger);
        job.Add('nama',FieldByName('nama').AsString);
        job.Add('alamat',FieldByName('alamat').AsString);
        job.Add('gender',FieldByName('gender').AsString);
        Next;
        jarr.Add(job);
      end;
      Write(jarr.AsJSON);

    finally
      jarr.Free;
    end;
  end;
end;

procedure TAnggota.Post;
var
  asql: string;
  adata: TJSONData;
  o: TJSONObject;
begin
  asql:='';
  try
    adata := GetJSON(Fields.Text);

  except
    Write('JSON ERROR!');
    exit;
  end;

  case Values.Values['aksi'] of
    'tambah':
      begin
        asql := Format('insert into anggota(nama,alamat,gender)' +
                'values(''%s'',''%s'',''%s'')',
                [adata.FindPath('nama').AsString,adata.FindPath('alamat').AsString,
                adata.FindPath('gender').AsString]);
      end;
    'ubah':
      begin
        asql := Format('update anggota set nama=''%s'', alamat=''%s'',gender=''%s''' +
                ' where id=''%s''',[adata.FindPath('nama').AsString,adata.FindPath('alamat').AsString,
                adata.FindPath('gender').AsString,adata.FindPath('id').AsString]);
      end;
  end;

  o := TJSONObject.Create;
  try
    if asql <> '' then
    begin
      with dm.qAct do
      begin
        Close;
        SQL.Text:=asql;
        try
          ExecSQL;
          o.Add('result','sukses');
          o.Add('deskripsi','oke nih');
          o.Add('tracesql',asql);
        except
          on E: Exception do
          begin
             o.Add('result','gagal');
             o.Add('deskripsi',E.Message);
             o.Add('tracesql',asql);
          end;

        end;
      end;
    end;
    Write(o.AsJSON)
  finally
    o.Free
  end;
end;

initialization
  dm := Tdm.Create(nil);
  TAnggota.Register('/anggota/',rmGet);
  TAnggota.Register('/anggota/:aksi',rmPost);
end.
