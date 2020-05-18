program udomtest;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  // NTX
  ntxConst in '..\..\ntx\ntxConst.pas',
  ntxLog in '..\..\ntx\ntxLog.pas',
  ntxTestUnit in '..\..\ntx\ntxTestUnit.pas',
  ntxTestResult in '..\..\ntx\ntxTestResult.pas',
  ntxTestReport in '..\..\ntx\ntxTestReport.pas',
  // HELP UNITS
  udomtest_const, udomtest_init,
  // TEST
  microdom in '..\microdom.pas',
  FunctionsTest in 'FunctionsTest.pas',
  DomDocumentTest in 'DomDocumentTest.pas';

var
  trs: TntxTestResults;
  errorlevel: integer = 100;

begin
  trs:=nil;
  try
    try
      WriteLn('Starting ', ParamStr(0));
      errorlevel:=0;
      trs:=TntxTestResults.Create(BASE_OPTIONS);
      if Assigned(RegisteredTests) then
      begin
        RegisteredTests.Run(trs);
        WriteLn(trs.GetReport);
        if trs.FailedCount>0 then
          errorlevel:=1;
      end
    except
      on e: Exception do
      begin
        Writeln(e.ClassName, ': ', e.Message);
        errorlevel:=2;
      end;
    end;
  finally
    trs.Free;
    Halt(errorlevel);
  end;
end.
