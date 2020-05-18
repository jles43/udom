unit DomDocumentTest;

interface

implementation

uses
  // NTX
  ntxTestUnit, ntxTestResult,
  // unit to be tested
  microdom,
  // HELP UNITS
  udomtest_init;

{*******************************************************************************
  Test_DomDocument - 12.05.20 11:56
  by:  JL
********************************************************************************}
procedure Test_DomDocument(trs: TntxTestResults);
const
  TESTNAME = 'class TuDomDocument';
var
  t: TntxTest;
  dd: TuDomDocument;
begin
  t:=trs.NewTest(TESTNAME);
  t.Start;
  dd:=nil;
  try
    t.Subtest('constructor').Start
      .Call(
        function(t: TntxTest): Boolean
        begin
          dd:=TuDomDocument.Create;
          Result:=true;
        end
      )
    .Done;
    t.Subtest('Parse').Start
      .Call(
        function(t: TntxTest): Boolean
        var
          res: Boolean;
        begin
          res:=dd.Parse('<ROOT>value</ROOT>');
          t
            .Eq(res, true, 'result value')
            .Eq(dd.Name, 'ROOT', 'root tag')
            .Eq(dd.Value, 'value', 'value')
            .Eq(dd.ChildNodes.Count, 0, 'count of child nodes');
          Result:=true;
        end
      )
    .Done;
  finally
    if Assigned(dd) then
      t.Subtest('destructor').Start
        .Call(
          function(t: TntxTest): Boolean
          begin
            dd.Free;
            Result:=true;
          end
        )
      .Done;
    t.Done;
  end;
end; {Test_DomDocument}

initialization
begin
  RegisterTest('TuDomDocument', Test_DomDocument);
end;

end.
