unit hfilereader;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, syncobjs;

type

  TLineEvent = procedure(AData: string) of object;
  TResultEvent = procedure(AData: TMemoryStream) of object;


  { TCCLineReader }

  TCCLineReader = class(TThread)
  private
    FOnEOF: TNotifyEvent;
    FTextFile: TextFile;
    FLineStr: String;
    FCS: TCriticalSection;
    FOnReadLine: TLineEvent;
    FOutStream: TMemoryStream;
    procedure putLine;
  public
    constructor Create(var ATextFile: TextFile ; var ACS: TCriticalSection ; var outStream: TMemoryStream);
    property OnReadLine: TLineEvent read FOnReadLine write FOnReadLine;
    property OnEOF: TNotifyEvent read FOnEOF write FOnEOF;
    procedure execute;override;
  end;

  { TCCTextFileReader }

  TCCTextFileReader = class
  private
    FFilename: string;
    FOnGetResult: TResultEvent;
    FOnReadLine: TLineEvent;
    FTextFile: TextFile;
    FOutStream: TMemoryStream;
    isEOF: boolean;
    procedure EventOnEOF(Sender: TObject);
  public
    constructor Create(AFilename: string);
    destructor Destroy;override;
    procedure execute;
    property Filename: string read FFilename write FFilename;
    property OnReadLine: TLineEvent read FOnReadLine write FOnReadLine;
    property OnGetResult: TResultEvent read FOnGetResult write FOnGetResult;
  end;

implementation

{ TCCLineReader }

procedure TCCLineReader.putLine;
var
    StrLen: Integer;
    sLine: String;
begin
  ReadLn(FTextFile,FLineStr);
  sLine:=FLineStr + sLineBreak;
  StrLen:=Length(sLine);

  FOutStream.Write(Pointer(sLine)^,StrLen * SizeOf(Char));
  //FOutStream.Write(FLineStr[1],StrLen * SizeOf(FLineStr[1]));
  if Assigned(FOnReadLine) then
     FOnReadLine(FLineStr);
end;

constructor TCCLineReader.Create(var ATextFile: TextFile ; var ACS: TCriticalSection ; var outStream: TMemoryStream);
begin
  inherited Create(True);
  FreeOnTerminate:=True;
  FTextFile:=ATextFile;
  FCS:=ACS;
  FOutStream:=outStream;
  FOutStream.Size:=0;
end;

procedure TCCLineReader.execute;
begin
  while not EOF(FTextFile) do
  begin
    FCS.Enter;
    Synchronize(@putLine);
    FCS.Leave;
  end;

  if Assigned(FOnEOF) then
     FOnEOF(Self);
end;


{ TCCTextFileReader }

procedure TCCTextFileReader.EventOnEOF(Sender: TObject);
begin
  if isEOF then exit;

  //if Assigned(FOnEOF) then
     //FOnEOF(Self);

  FOutStream.Seek(0,soFromBeginning);
  if Assigned(FOnGetResult) then
     FOnGetResult(FOutStream);

  CloseFile(FTextFile);

  isEOF:=True;
end;

constructor TCCTextFileReader.Create(AFilename: string);
begin
  FFilename:=AFilename;
  FOutStream:=TMemoryStream.Create;
end;

destructor TCCTextFileReader.Destroy;
begin
  FreeAndNil(FOutStream);
  inherited Destroy;
end;

procedure TCCTextFileReader.execute;
const
  bufSize = 1024 * 1024 * 2; //1mb buffer
var
  AThread: TCCLineReader;
  cs: TCriticalSection;
  i: integer;
  buffer: array[1..bufSize] of byte;
begin
  if not FileExists(FFilename) then raise Exception.Create('File not found!');

  AssignFile(FTextFile,FFilename);
  Reset(FTextFile);
  SetTextBuf(FTextFile,buffer);//use 64kb read buffer

  cs := TCriticalSection.Create;
  FOutStream.Clear;
  FOutStream.Seek(0,soFromBeginning);

  for i:=1 to 1 do
  begin
    AThread := TCCLineReader.Create(FTextFile,cs,FOutStream);
    AThread.OnReadLine:=FOnReadLine;
    AThread.OnEOF:=@EventOnEOF;
    AThread.Start;
  end;
end;

end.

