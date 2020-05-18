unit udomtest_const;

interface

uses
  ntxConst;

const
  // ntoFailureOnly
  // ntoLog
  BASE_OPTIONS = [{ntoFailureOnly, }ntoLog];
  XML_HEADER_CONTENT = 'version="1.0" encoding="Windows-1252"';
  XML_HEADER = '<?xml '+XML_HEADER_CONTENT+'?>';
  DTD_CONTENT = 'a[<!ELEMENT a ANY >]';
  DTD = '<!DOCTYPE '+DTD_CONTENT+'>';

implementation

end.
