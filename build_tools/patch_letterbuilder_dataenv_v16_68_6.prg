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
* Prefer the mapped workstation database folder. Fall back to the validated
* Parameters 2 value, including the legacy case where it points one level
* above the databases folder.
LOCAL lcDataRoot
lcDataRoot=""
IF FILE("K:\Program Files\MOSt\databases\oms.dbc") AND FILE("K:\Program Files\MOSt\databases\letters.dbc")
    lcDataRoot="K:\Program Files\MOSt\databases\"
ELSE
    IF FILE("K:\Program Files (x86)\MOSt\databases\oms.dbc") AND FILE("K:\Program Files (x86)\MOSt\databases\letters.dbc")
        lcDataRoot="K:\Program Files (x86)\MOSt\databases\"
    ENDIF
ENDIF
IF EMPTY(lcDataRoot) AND TYPE("path_to_data")=="C"
    lcDataRoot=ADDBS(ALLTRIM(path_to_data))
    IF !FILE(lcDataRoot+"oms.dbc") AND FILE(lcDataRoot+"databases\oms.dbc")
        lcDataRoot=lcDataRoot+"databases\"
    ENDIF
ENDIF
IF !FILE(lcDataRoot+"oms.dbc") OR !FILE(lcDataRoot+"letters.dbc")
    ERROR "LetterBuilder cannot find oms.dbc and letters.dbc in the mapped K: database folder or the Parameters 2 DATA_FILES folder."
ENDIF
THIS.Cursor1.Database=lcDataRoot+"letters.dbc"
THIS.Cursor2.Database=lcDataRoot+"oms.dbc"
THIS.Cursor3.Database=lcDataRoot+"letters.dbc"
THIS.Cursor4.Database=lcDataRoot+"letters.dbc"
THIS.Cursor5.Database=lcDataRoot+"letters.dbc"
THIS.Cursor6.Database=lcDataRoot+"letters.dbc"
THIS.Cursor7.Database=lcDataRoot+"oms.dbc"
THIS.Cursor8.Database=lcDataRoot+"oms.dbc"
THIS.Cursor9.Database=lcDataRoot+"oms.dbc"
THIS.Cursor10.Database=lcDataRoot+"oms.dbc"
THIS.Cursor11.Database=lcDataRoot+"oms.dbc"
THIS.Cursor12.Database=lcDataRoot+"oms.dbc"
THIS.Cursor13.Database=lcDataRoot+"oms.dbc"
THIS.Cursor14.Database=lcDataRoot+"oms.dbc"
THIS.Cursor15.Database=lcDataRoot+"oms.dbc"
THIS.Cursor16.Database=lcDataRoot+"oms.dbc"
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
