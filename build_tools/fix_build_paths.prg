LOCAL lcRoot, lcForm, lcLog

lcRoot = ADDBS(JUSTPATH(SYS(16)))
lcForm = lcRoot + "MOSt\forms\edt.scx"
lcLog = lcRoot + "output\path_fix.log"

SET SAFETY OFF
SET EXCLUSIVE ON
ON ERROR DO FixFailed WITH ERROR(), MESSAGE(), PROGRAM(), LINENO(), lcLog

USE (lcForm) EXCLUSIVE ALIAS edt_form
REPLACE ALL methods WITH STRTRAN(methods, ;
    "C:\program files\MOSt\CFHDR.H", "CFHDR.H") ;
    FOR "C:\program files\MOSt\CFHDR.H" $ methods
USE IN edt_form

STRTOFILE("Updated EDT include paths." + CHR(13) + CHR(10), lcLog, 0)
ON ERROR
QUIT

PROCEDURE FixFailed
    LPARAMETERS tnError, tcMessage, tcProgram, tnLine, tcLog
    STRTOFILE("FAILED: " + TRANSFORM(tnError) + " " + TRANSFORM(tcMessage) + ;
        " in " + TRANSFORM(tcProgram) + " line " + TRANSFORM(tnLine) + ;
        CHR(13) + CHR(10), tcLog, 0)
    ON ERROR
    QUIT
ENDPROC
