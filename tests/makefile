
DFLAGS=-D__TEST__
DCC=dcc32

# Namespaces
### UNIT -> NAMESPACE
# SysUtils -> System
# Windows -> Winapi
# Graphics -> Vcl
# Registry -> System.Win
# DB -> Data
# DBTables -> BDE
DFLAGS += -NSSystem;Winapi;Data;System.Win;Vcl;Vcl.Imaging;BDE;Web
#ALIASES+= -ADBXJSON=JSON

!include udomtest.dep

all : udomtest.exe .SYMBOLIC
	%null

test : udomtest.exe .SYMBOLIC
	udomtest.exe

udomtest.exe : $(SOURCES)
	$(DCC) $(DFLAGS) udomtest.dpr
