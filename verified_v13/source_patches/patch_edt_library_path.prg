LOCAL lcBase, lcLog, lcMethods, lnChanges
lcBase = ADDBS(JUSTPATH(SYS(16)))
lcLog = lcBase + "patch_edt_library_path_result.txt"
lnChanges = 0
SET SAFETY OFF
SET TALK OFF
SET EXCLUSIVE ON
ON ERROR DO PatchFailed WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog

USE (lcBase + "edt.scx") EXCLUSIVE ALIAS patchedtlib
SCAN
    lcMethods = methods
    IF EMPTY(lcMethods)
        LOOP
    ENDIF
    lcMethods = STRTRAN(lcMethods, ;
        'localArea = "C:\program files\MOSt\"', ;
        'localArea = ADDBS(JUSTPATH(SYS(16,0)))')
    lcMethods = STRTRAN(lcMethods, ;
        'SET LIBRARY TO "C:\program files\MOSt\CVF50.FLL" ADDITIVE', ;
        'SET LIBRARY TO (localArea + "CVF50.FLL") ADDITIVE')
    IF lcMethods # methods
        REPLACE methods WITH lcMethods
        lnChanges = lnChanges + 1
    ENDIF
ENDSCAN
USE IN patchedtlib
STRTOFILE("SUCCESS: Updated EDT library-path methods: " + TRANSFORM(lnChanges) + CHR(13) + CHR(10), lcLog, 0)
RETURN

PROCEDURE PatchFailed
    LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
    STRTOFILE("FAILED: " + TRANSFORM(tnError) + " " + TRANSFORM(tcMessage) + ;
        " at " + TRANSFORM(tcProgram) + " line " + TRANSFORM(tnLine) + CHR(13) + CHR(10), tcLog, 0)
    IF USED("patchedtlib")
        USE IN patchedtlib
    ENDIF
    RETURN
ENDPROC
