LOCAL lcForm, lcLog, lcMethods, lcOldExitTail, lcNewExitTail
LOCAL lcOldRelease, lcNewRelease, lnFormChanges, lnExitChanges

lcForm = "E:\MOST for chat\oms_vfp9_build\MOSt\FORMS\schedule.scx"
lcLog = "E:\MOST for chat\oms_vfp9_build\output\patch_schedule_v14.log"
lnFormChanges = 0
lnExitChanges = 0

SET SAFETY OFF
SET TALK OFF
SET EXCLUSIVE ON
ON ERROR DO PatchFailed WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog

TEXT TO lcOldExitTail NOSHOW
* Erick 2004.07.26
ThisForm.btnexit.Click
ENDTEXT

TEXT TO lcNewExitTail NOSHOW
* V14: close and remove the per-form undo history exactly once.
LOCAL lcHistoryFile, lcHistoryDir, lcTempDir, lcDeleteFile
lcHistoryFile = ALLTRIM(THISFORM.history_file)
THISFORM.history_file = ""

IF USED("undo_hstry")
    USE IN undo_hstry
ENDIF

IF NOT EMPTY(lcHistoryFile)
    lcHistoryDir = LOWER(ADDBS(JUSTPATH(FULLPATH(lcHistoryFile))))
    lcTempDir = LOWER(ADDBS(FULLPATH(SYS(2023))))
    IF lcHistoryDir == lcTempDir
        lcDeleteFile = FORCEEXT(lcHistoryFile, "dbf")
        IF FILE(lcDeleteFile)
            ERASE (lcDeleteFile)
        ENDIF
        lcDeleteFile = FORCEEXT(lcHistoryFile, "fpt")
        IF FILE(lcDeleteFile)
            ERASE (lcDeleteFile)
        ENDIF
        lcDeleteFile = FORCEEXT(lcHistoryFile, "cdx")
        IF FILE(lcDeleteFile)
            ERASE (lcDeleteFile)
        ENDIF
    ENDIF
ENDIF
ENDTEXT

TEXT TO lcOldRelease NOSHOW
PROCEDURE Release

NODEFAULT
this.QueryUnload
DODEFAULT()





ENDPROC
ENDTEXT

TEXT TO lcNewRelease NOSHOW
PROCEDURE Release

* V14: let the base Release invoke QueryUnload once.
NODEFAULT
DODEFAULT()

ENDPROC
ENDTEXT

USE (lcForm) EXCLUSIVE ALIAS patchschedule
SCAN
    lcMethods = methods
    IF EMPTY(lcMethods)
        LOOP
    ENDIF

    IF LOWER(ALLTRIM(objname)) == "scheduleform"
        IF lcOldExitTail $ lcMethods
            lcMethods = STRTRAN(lcMethods, lcOldExitTail, lcNewExitTail, 1, 1)
            lnFormChanges = lnFormChanges + 1
        ENDIF
        IF lcOldRelease $ lcMethods
            lcMethods = STRTRAN(lcMethods, lcOldRelease, lcNewRelease, 1, 1)
            lnFormChanges = lnFormChanges + 1
        ENDIF
        REPLACE methods WITH lcMethods
    ENDIF

    IF LOWER(ALLTRIM(objname)) == "btnexit"
        TEXT TO lcMethods NOSHOW
PROCEDURE Click
* V14: QueryUnload owns cleanup; do not close the alias here.
THISFORM.RELEASE
ENDPROC
ENDTEXT
        REPLACE methods WITH lcMethods
        lnExitChanges = lnExitChanges + 1
    ENDIF
ENDSCAN
USE IN patchschedule

IF lnFormChanges # 2 OR lnExitChanges # 1
    STRTOFILE("FAILED: expected 2 form changes and 1 Exit-button change; got " + ;
        TRANSFORM(lnFormChanges) + " and " + TRANSFORM(lnExitChanges) + CHR(13) + CHR(10), lcLog, 0)
    RETURN
ENDIF

STRTOFILE("SUCCESS: scheduler V14 cleanup patch applied (2 form changes, 1 Exit-button change)." + ;
    CHR(13) + CHR(10), lcLog, 0)
RETURN

PROCEDURE PatchFailed
    LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
    STRTOFILE("FAILED: " + TRANSFORM(tnError) + " " + TRANSFORM(tcMessage) + ;
        " at " + TRANSFORM(tcProgram) + " line " + TRANSFORM(tnLine) + CHR(13) + CHR(10), tcLog, 0)
    IF USED("patchschedule")
        USE IN patchschedule
    ENDIF
    RETURN
ENDPROC
