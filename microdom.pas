unit microdom;

interface

uses
  Classes;

type
  TuDomElementList = class;
  TuDomElement = class(TObject)
  {$IFDEF __TEST__}public{$ELSE}private{$ENDIF}
    function GetValue: string;
  {$IFDEF __TEST__}public{$ELSE}protected{$ENDIF}
    m_name: string;
    m_values: TStringList;
    m_nodes: TuDomElementList;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const sXML: string): Boolean; virtual;
    property Name: string read m_name;
    property Value: string read GetValue;
    property ChildNodes: TuDomElementList read m_nodes;
  end;
  TuDomElementList = class(TList)
  end;
  TuDomDocument = class(TuDomElement)
  end;

type
  TXMLTokenKind = (
    tokEOF, tokError, tokText, tokTag, tokOpenTag, tokCloseTag, tokHeader,
    tokDoctype, tokComment, tokCDATA, tokPCDATA
  );
  TXMLToken = record
  kind: TXMLTokenKind;
  value: string;
  procedure ParseTag(const tag: string);
  end;

procedure SkipSpaces(const s: string; var ipos: integer);
function GetXMLToken(const xml: string; var ipos: integer): TXMLToken;
function ScanChar(const s: string; ipos: integer; c: char): integer;

implementation

uses
  Windows, SysUtils, StrUtils;

procedure _p(const fmt: string; const args: array of const);
var
  s: string;
begin
  s:=Format(fmt, args);
  OutputDebugString(PWideChar(s));
end;

procedure SkipSpaces(const s: string; var ipos: integer);
begin
  while (ipos<=Length(s)) and CharInSet(s[ipos], [' ', #9, #10, #13]) do
    Inc(ipos);
end;

function ScanChar(const s: string; ipos: integer; c: char): integer;
var
  cc,           // cc - current char
  sd: char;     // sd - string delimiter
  sqb: integer;
begin
  Result:=ipos;
  sd:=#0;
  sqb:=0;
  while Result<=Length(s) do
  begin
    cc:=s[Result];
    if sd<>#0 then
    begin
      if cc=sd then     // end of string
        sd:=#0;         // clear the flag 'in string'
    end
    else if (sqb=0) and (cc=c) then   // found
      Break
    else if cc='[' then
      Inc(sqb)
    else if cc=']' then
      Dec(sqb)
    else if CharInSet(cc, ['''', '"']) then
      sd:=cc;           // flag 'in string'
    Inc(Result);
  end;
  if Result>Length(s) then
    Result:=0;
end;

function GetXMLToken(const xml: string; var ipos: integer): TXMLToken;
var
  npos: integer;
begin
  if ipos>Length(xml) then
    Result.kind:=tokEOF
  else if xml[ipos]='<' then
  begin
    npos:=ScanChar(xml, ipos, '>');
    if npos=0 then
    begin
      Result.kind:=tokError;
      Result.value:='''>'' not found';
    end
    else begin
      Result.ParseTag(Copy(xml, ipos, npos-ipos+1));
      ipos:=npos+1;
    end;
  end
  else begin
    npos:=ScanChar(xml, ipos, '<');
    if npos=0 then
      npos:=Length(xml)+1;
    Result.kind:=tokText;
    Result.value:=Copy(xml, ipos, npos-ipos);
    ipos:=npos;
  end;
end;

{
  can be:
  <a/>          tokTag
  <a>           tokOpenTag
  </a>          tokCloseTag
  <?xml...>     tokHeader
  <!DOCTYPE...> tokDoctype
  <!-- -->      tokComment
}
procedure TXMLToken.ParseTag(const tag: string);
var
  l: integer;
  s: string;
begin
  l:=Length(tag);
  _p('> ParseTag(tag="%s")', [tag]);
  Assert(l>2, 'wrong length: "'+tag+'"');
  Assert(tag[1]='<', '< at begin expected: "'+tag+'"');
  Assert(tag[l]='>', '> at end expected: "'+tag+'"');
  kind:=tokError;
  value:='Syntax error';
  s:=Trim(Copy(tag, 2, l-2));
  l:=Length(s);
  _p('  ParseTag: content=[%s]', [s]);
  _p('  ParseTag: StartsStr(s, ?xml)=%d, EndsStr(s, ?)=%d',
    [ord(StartsStr('?xml ', s)), ord(EndsStr('?', s))]);
  if s[l]='/' then
  begin
    kind:=tokTag;
    Delete(s, l, 1);
  end
  else if s[1]='/' then
  begin
    kind:=tokCloseTag;
    Delete(s, 1, 1);
  end
  else if StartsStr('?xml ', s) and EndsStr('?', s) then
  begin
    kind:=tokHeader;
    Delete(s, l, 1);
    Delete(s, 1, 5);
  end
  else if StartsStr('!DOCTYPE', s) then
  begin
    kind:=tokDoctype;
    Delete(s, 1, 8);
  end
  else begin
    kind:=tokOpenTag;
  end;
  value:=Trim(s);
  _p('< ParseTag: value="%s"', [value]);
end;

{ TuDomElement }

constructor TuDomElement.Create;
begin
  inherited Create;
  m_values:=TStringList.Create;
  m_nodes:=TuDomElementList.Create;
end;

destructor TuDomElement.Destroy;
begin
  FreeAndNil(m_nodes);
  FreeAndNil(m_values);
  inherited Destroy;
end;

function TuDomElement.GetValue: string;
begin
  if m_values.Count=0 then
    Result:=''
  else if m_values.Count=1 then
    Result:=m_values[0]
  else
    Result:=Trim(m_values.Text);
end;

function TuDomElement.Parse(const sXML: string): Boolean;
begin
  Result:=false;
end;

end.
