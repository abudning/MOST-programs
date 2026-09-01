LOCAL lcBase, lcLog, lcMethods, lnChanges
lcBase = ADDBS(JUSTPATH(SYS(16)))
lcLog = lcBase + "patch_edt_temp_result.txt"
lnChanges = 0
SET SAFETY OFF
SET TALK OFF
SET EXCLUSIVE ON
ON ERROR DO PatchFailed WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog

USE (lcBase + "edt.scx") EXCLUSIVE ALIAS patchedt
SCAN
    lcMethods = methods
    IF EMPTY(lcMethods)
        LOOP
    ENDIF

    lcMethods = STRTRAN(lcMethods, ;
        "IF !DIRECTORY('C:\Program Files\MOSt\TEMP\TEMPP')" + CHR(13) + CHR(10) + ;
        CHR(9) + "MKDIR('C:\Program Files\MOSt\TEMP\TEMPP')" + CHR(13) + CHR(10) + ;
        "ENDIF" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
        "THIS.folder_tempp = 'C:\Program Files\MOSt\TEMP\TEMPP\'", ;
        "THIS.folder_tempp = ADDBS(SYS(2023)) + 'MOST_EDT\'" + CHR(13) + CHR(10) + ;
        "IF !DIRECTORY(THIS.folder_tempp)" + CHR(13) + CHR(10) + ;
        CHR(9) + "MD (THIS.folder_tempp)" + CHR(13) + CHR(10) + ;
        "ENDIF")

    lcMethods = STRTRAN(lcMethods, ;
        'DELETE FILE "C:\Program Files\MOSt\TEMP\TEMPP\*.*"', ;
        'DELETE FILE (THISFORM.folder_tempp + "*.*")')
    lcMethods = STRTRAN(lcMethods, ;
        'm.TempFolderLoc = "C:\Program Files\MOSt\TEMP\TEMPP\"+aFilesToDownload(intStart,1)', ;
        'm.TempFolderLoc = THISFORM.folder_tempp + aFilesToDownload(intStart,1)')
    lcMethods = STRTRAN(lcMethods, ;
        "nn = ADIR(cTem_PFiles,'C:\Program Files\MOSt\TEMP\TEMPP\*.*')", ;
        'nn = ADIR(cTem_PFiles, THISFORM.folder_tempp + "*.*")')

    IF lcMethods # methods
        REPLACE methods WITH lcMethods
        lnChanges = lnChanges + 1
    ENDIF
ENDSCAN
USE IN patchedt
STRTOFILE("SUCCESS: Updated EDT methods: " + TRANSFORM(lnChanges) + CHR(13) + CHR(10), lcLog, 0)
RETURN

PROCEDURE PatchFailed
    LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
    STRTOFILE("FAILED" + CHR(13) + CHR(10) + ;
        "Error: " + TRANSFORM(tnError) + CHR(13) + CHR(10) + ;
        "Message: " + TRANSFORM(tcMessage) + CHR(13) + CHR(10) + ;
        "Code: " + TRANSFORM(tcCode) + CHR(13) + CHR(10) + ;
        "Program: " + TRANSFORM(tcProgram) + CHR(13) + CHR(10) + ;
        "Line: " + TRANSFORM(tnLine) + CHR(13) + CHR(10), tcLog, 0)
    IF USED("patchedt")
        USE IN patchedt
    ENDIF
    RETURN
ENDPROC
