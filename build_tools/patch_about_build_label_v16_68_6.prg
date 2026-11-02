LPARAMETERS tcMostRoot

LOCAL lcMost, lcForm, lcMethods, lcNeedle, lcNewLine
lcMost=ADDBS(FULLPATH(tcMostRoot))
lcForm=lcMost+"FORMS\version.scx"
lcNeedle="thisform.text4.value=g_custno"
lcNewLine='thisform.text4.value="V16.68.6"'

IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm,"sct"))
    ERROR "Help About MOSt form source is missing."
ENDIF

USE (lcForm) EXCLUSIVE ALIAS about686
LOCATE FOR LOWER(ALLTRIM(objname))=="versionform"
IF !FOUND()
    USE IN about686
    ERROR "Help About MOSt form was not found."
ENDIF

lcMethods=about686.methods
IF !(LOWER(lcNewLine) $ LOWER(lcMethods))
    IF OCCURS(LOWER(lcNeedle),LOWER(lcMethods))#1
        USE IN about686
        ERROR "Help About MOSt client-number assignment was not unique."
    ENDIF
    REPLACE methods WITH STRTRAN(lcMethods,lcNeedle,lcNewLine,1,1,1) IN about686
ENDIF
USE IN about686
