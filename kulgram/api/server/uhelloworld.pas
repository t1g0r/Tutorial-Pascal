unit uhelloworld;

{$mode objfpc}{$H+}

interface

uses
  classes,sysutils,BrookAction,BrookUtils,udm,fpjson;

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
    procedure Post; override;
  end;

implementation

procedure TMyAction.Get;
begin
  if values.values['nama'] = '' then
    Write('hello!')
  else
    Write('Hello ' + Values.Values['nama'] + '!');
end;

procedure TMyAction.Post;
begin
  Write('Hello ' + Values.Values['nama'] + '!');
end;

initialization
  dm := Tdm.Create(nil);
  TMyAction.Register('/hello/:nama',rmGet);
  TMyAction.Register('/hello/:nama',rmPost);

end.
