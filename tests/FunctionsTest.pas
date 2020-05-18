unit FunctionsTest;

interface

implementation

uses
  SysUtils,
  ntxTestUnit, ntxTestResult,
  microdom,
  udomtest_const, udomtest_init;

function PrtXMLTokenKind(const val: TXMLTokenKind): string;
const
  _names: array[TXMLTokenKind] of PChar = (
    'tokEOF', 'tokError', 'tokText', 'tokTag', 'tokOpenTag', 'tokCloseTag',
    'tokHeader', 'tokDoctype', 'tokComment', 'tokCDATA', 'tokPCDATA'
  );
begin
  Result:=StrPas(_names[val]);
end;

{*******************************************************************************
  Test_SkipSpaces - 12.05.20 12:34
  by:  JL
********************************************************************************}
procedure Test_SkipSpaces(trs: TntxTestResults);
const
  TESTNAME = 'procedure SkipSpaces';
var
  t: TntxTest;
begin
  t:=trs.NewTest(TESTNAME);
  t.Start;
  try
    t.Subtest('empty string').Start
      .Call(
        function(t: TntxTest): Boolean
        var
          ipos: integer;
        begin
          ipos:=1;
          SkipSpaces('', ipos);
          t.Eq(ipos, 1);
          Result:=true;
        end
      )
    .Done;
    t.Subtest('spaces only').Start
      .Call(
        function(t: TntxTest): Boolean
        var
          ipos: integer;
        begin
          ipos:=1;
          // 7 space chars
          SkipSpaces('       ', ipos);
          t.Eq(ipos, 8);
          Result:=true;
        end
      )
    .Done;
  finally
    t.Done;
  end;
end; {Test_SkipSpaces}

{*******************************************************************************
  Test_GetXMLToken - 13.05.20 21:20
  by:  JL
********************************************************************************}
procedure Test_GetXMLToken(trs: TntxTestResults);
const
  TESTNAME = 'function GetXMLToken';

  function Test(const xml: string; i, xPos: integer; xKind: TXMLTokenKind;
    const xVal: string): TntxCallFunction;
  begin
    Result:=function(t: TntxTest): Boolean
    var
      res: TXMLToken;
      ipos: integer;
    begin
      ipos:=i;
      res:=GetXMLToken(xml, ipos);
      t
        .Eq(ipos, xPos, 'ipos')
        .Eq(PrtXMLTokenKind(res.kind), PrtXMLTokenKind(xKind), 'kind')
        .Eq(res.value, xVal, 'value');
      Result:=true;
    end;
  end;

var
  t: TntxTest;
begin
  t:=trs.NewTest(TESTNAME);
  t.Start;
  try
    t.Subtest('empty string').Start
      .Call(Test('', 1, 1, tokEOF, ''))
    .Done;
    t.Subtest('text').Start
      .Call(Test('<a>text</a>', 4, 8, tokText, 'text'))
    .Done;
    t.Subtest('tag').Start
      .Call(Test('<a/><b>test</b>', 1, 5, tokTag, 'a'))
    .Done;
    t.Subtest('open tag').Start
      .Call(Test('<a/><b>test</b>', 5, 8, tokOpenTag, 'b'))
    .Done;
    t.Subtest('close tag').Start
      .Call(Test('<a/><b>test</b><c></c>', 12, 16, tokCloseTag, 'b'))
    .Done;
    t.Subtest('header').Start
      .Call(Test(XML_HEADER+'<a/><b>test</b><c></c>', 1, Length(XML_HEADER)+1,
        tokHeader, XML_HEADER_CONTENT))
    .Done;
    t.Subtest('DTD').Start
      .Call(Test(DTD+'<a><b>test</b><c></c></a>', 1, Length(DTD)+1,
        tokDoctype, DTD_CONTENT))
    .Done;
  finally
    t.Done;
  end;
end; {Test_GetXMLToken}

{*******************************************************************************
  Test_ScanChar - 13.05.20 23:03
  by:  JL
********************************************************************************}
procedure Test_ScanChar(trs: TntxTestResults);
const
  TESTNAME = 'function ScanChar';
var
  t: TntxTest;
begin
  t:=trs.NewTest(TESTNAME);
  t.Start;
  try
    t.Eq(ScanChar('', 1, ' '), 0, 'empty arguments');
    t.Eq(ScanChar('abc', 1, 'a'), 1, 'first char in string');
    t.Eq(ScanChar('abc', 2, 'a'), 0, 'behing first char in string');
    t.Eq(ScanChar('abc', 1, 'b'), 2, 'second char in string');
    t.Eq(ScanChar('abc', 2, 'b'), 2, 'second char in string');
    t.Eq(ScanChar('abc', 3, 'b'), 0, 'behind second char in string');
    t.Eq(ScanChar('abcdef', 1, 'f'), 6, 'last char in string, start from begin');
    t.Eq(ScanChar('abcdef', 6, 'f'), 6, 'last char in string, start from char');
    t.Eq(ScanChar('abcdef', 7, 'f'), 0, 'behind last char in string');
    t.Eq(ScanChar('ab"cd"ef', 1, 'c'), 0, 'char in "string"');
    t.Eq(ScanChar('ab"c''d"e''f', 1, ''''), 9, '"''" in "string" and behind');
  finally
    t.Done;
  end;
end; {Test_ScanChar}

initialization
begin
  RegisterTest('SkipSpaces', Test_SkipSpaces);
  RegisterTest('ScanChar', Test_ScanChar);
  RegisterTest.Only('GetXMLToken', Test_GetXMLToken);
end;

end.
