unit udomtest_init;

interface

uses
  // DELPHI VCL
  System.Classes,
  // NTX
  ntxTestResult
  // TESTLIB
  {$IFDEF TEST_DATA}
  , udomtest_data
  {$ENDIF}
  ;

type
  {$IFDEF TEST_DATA}
  TTestDataType = TMicroDomTestData;
  {$ENDIF}
  TTestProc = procedure(trs: TntxTestResults
    {$IFDEF TEST_DATA}; td: TTestDataType{$ENDIF});
  Tudom_TestListItem = class(TObject)
  private
    m_name: string;
    m_proc: TTestProc;
  public
    constructor Create(const AName: string; AProc: TTestProc);
    destructor Destroy; override;
  end;
  Tudom_TestList = class(TList)
  private
    m_only: Boolean;  // wenn True, werden nur die Testprozeduren mit 'Only' registriert
    procedure FreeItems;
    function GetItems(idx: integer): Tudom_TestListItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run(trs: TntxTestResults
      {$IFDEF TEST_DATA}; td: {$ENDIF});
    procedure AddTest(const nm: string; proc: TTestProc);
    function Only(const nm: string; proc: TTestProc): Tudom_TestList;
    property Items[idx: integer]: Tudom_TestListItem read GetItems; default;
  end;

function RegisterTest(const nm: string; proc: TTestProc): Tudom_TestList; overload;
function RegisterTest: Tudom_TestList; overload;

var
  RegisteredTests: Tudom_TestList = nil;

implementation

uses
  // DELPHI VCL
  System.SysUtils, WinApi.Windows;//, Win.Registry, WinApi.Windows, Vcl.Controls,
  // TESTLIB
  //PLZ_Func;

{ Es gibt zwei Möglichkeit, die Testprozedur zu registrieren:
  1) im Normalmodus - RegisterTest(<name>, <procedure>)
  2) im Only-Modus - RegisterTest.Only(<name>, <procedure>)
}

function RegisterTest: Tudom_TestList; overload;
begin
  if not Assigned(RegisteredTests) then
    RegisteredTests:=Tudom_TestList.Create;
  Result:=RegisteredTests;
end;

function RegisterTest(const nm: string; proc: TTestProc): Tudom_TestList; overload;
begin
  Result:=RegisterTest;
  // Wenn die Liste sich nicht im Only-Modus befindet
  if not Result.m_only then
    Result.AddTest(nm, proc);
end;

{ Tudom_TestListItem }

constructor Tudom_TestListItem.Create(const AName: string; AProc: TTestProc);
begin
  inherited Create;
  m_name:=AName;
  m_proc:=AProc;
end;

destructor Tudom_TestListItem.Destroy;
begin
  m_proc:=nil;
  m_name:='';
  inherited Destroy;
end;

{ Tudom_TestList }

constructor Tudom_TestList.Create;
begin
  inherited Create;
end;

destructor Tudom_TestList.Destroy;
begin
  FreeItems;
  inherited Destroy;
end;

procedure Tudom_TestList.FreeItems;
var
  i: integer;
  item: TObject;
begin
  for i:=0 to Count-1 do
  begin
    item:=inherited Items[i];
    inherited Items[i]:=nil;
    item.Free;
  end;
end;

function Tudom_TestList.GetItems(idx: integer): Tudom_TestListItem;
begin
  Result:=Tudom_TestListItem(inherited Items[idx]);
end;

procedure Tudom_TestList.AddTest(const nm: string; proc: TTestProc);
var
  newitem: Tudom_TestListItem;
begin
  newitem:=Tudom_TestListItem.Create(nm, proc);
  Add(newitem);
end;

function Tudom_TestList.Only(const nm: string;
  proc: TTestProc): Tudom_TestList;
begin
  if not m_only then
  begin
    FreeItems;
    Clear;
    m_only:=true;
  end;
  AddTest(nm, proc);
  Result:=Self;
end;

{*******************************************************************************
  Tudom_TestList.Run - 23.03.20 19:37
  by:  JL

Die Prozedur ruft alle registrierten Testprozeduren auf.
********************************************************************************}
procedure Tudom_TestList.Run(trs: TntxTestResults
  {$IFDEF TEST_DATA}; td: TTestDataType{$ENDIF});
var
  i: integer;
  item: Tudom_TestListItem;
  s: string;
begin
  // Wenn RegisterTest nie aufgerufen wurde, dann bleibt die Liste nicht
  // initialisiert.
  if Self=nil then
    Exit;
  for i:=0 to Count-1 do
  begin
    item:=Items[i];
    if Assigned(item) and Assigned(item.m_proc) then
    begin
      s:=Format('[TestList] Call test %s', [item.m_name]);
      OutputDebugString(PChar(s));
      try
        item.m_proc(trs{$IFDEF TEST_DATA}, td{$ENDIF});
      except
        on e: Exception do
        begin
          s:=Format('[TestList] Exception %s in test %s. Message is ''%s''',
            [e.ClassName, item.m_name, e.Message]);
          OutputDebugString(PChar(s));
        end;
      end;
    end;
  end;
end; {Tudom_TestList.Run}

initialization
finalization
  FreeAndNil(RegisteredTests);
end.
