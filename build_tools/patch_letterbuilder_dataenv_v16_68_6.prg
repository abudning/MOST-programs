LPARAMETERS tcMostRoot

LOCAL lcMost, lcForm, lcMethods, lcBefore, lnStart, lnRelEnd, lnEnd
lcMost=ADDBS(FULLPATH(tcMostRoot))
lcForm=lcMost+"FORMS\letterform.scx"

IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm,"sct"))
    ERROR "LetterBuilder form source is missing."
ENDIF

USE (lcForm) EXCLUSIVE ALIAS lb686
LOCATE FOR LOWER(ALLTRIM(lb686.baseclass))=="dataenvironment"
IF !FOUND()
    USE IN lb686
    ERROR "LetterBuilder DataEnvironment was not found."
ENDIF

lcMethods=lb686.methods
TEXT TO lcBefore NOSHOW
PROCEDURE BeforeOpenTables
* V16.68.6: path_to_data comes from PARAMETER2.DATA_FILES. Do not let the
* form's relative ..\databases bindings resolve beside the local executable.
THIS.Cursor1.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor2.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor3.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor4.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor5.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor6.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor7.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor8.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor9.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor10.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor11.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor12.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor13.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor14.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor15.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor16.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor17.Database=oms_local_fullpath
ENDPROC
ENDTEXT

lnStart=ATC("PROCEDURE BeforeOpenTables",lcMethods)
IF lnStart=0
    lcMethods=lcMethods+IIF(EMPTY(lcMethods),"",CHR(13)+CHR(10))+lcBefore
ELSE
    lnRelEnd=ATC("ENDPROC",SUBSTR(lcMethods,lnStart))
    IF lnRelEnd=0
        USE IN lb686
        ERROR "LetterBuilder BeforeOpenTables is incomplete."
    ENDIF
    lnEnd=lnStart+lnRelEnd+LEN("ENDPROC")-2
    lcMethods=LEFT(lcMethods,lnStart-1)+lcBefore+SUBSTR(lcMethods,lnEnd+1)
ENDIF

REPLACE lb686.methods WITH lcMethods IN lb686
USE IN lb686
