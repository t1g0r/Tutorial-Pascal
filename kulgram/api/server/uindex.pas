unit uindex;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type
  TIndex = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TIndex.Get;
begin
  Write('Hello World!');
end;

initialization
  TIndex.Register('/', True);

end.
