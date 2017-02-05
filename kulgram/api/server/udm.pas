unit udm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql55conn, mysql56conn, sqldb, FileUtil,inifiles;

type

  { Tdm }

  Tdm = class(TDataModule)
    dbconn: TMySQL56Connection;
    qAct: TSQLQuery;
    SQLTransact: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  dm: Tdm;

implementation

{$R *.lfm}

{ Tdm }

procedure Tdm.DataModuleCreate(Sender: TObject);
var
  config: TIniFile;
begin
  config := TIniFile.Create('config.ini');
  try
    with dbConn do
    begin
      Close;
      HostName    := config.ReadString('database','hostname','localhost');
      Port        := config.ReadInteger('database','port',3306);
      DatabaseName:= config.ReadString('database','database','tigoscom_kulgram');
      UserName    := config.ReadString('database','username','root');
      Password    := config.ReadString('database','password','abcd3');
      Open;
    end;
  finally
    FreeAndNil(config);
  end;

end;

end.

