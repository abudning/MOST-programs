LOCAL lcRoot, lcForms, lcMenu, lcBackup, lcLog, lcMethods, lcProps, lcCode
lcRoot = "E:\MOST for chat\oms_vfp9_build"
lcForms = ADDBS(lcRoot) + "MOSt\FORMS\"
lcMenu = ADDBS(lcRoot) + "MOSt\MENU\"
lcBackup = ADDBS(lcRoot) + "backup_v15_before_ohip_20260907\"
lcLog = ADDBS(lcRoot) + "output\direct_build_v16_4.log"
SET SAFETY OFF
SET EXCLUSIVE ON
ON ERROR DO BuildError WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog

IF !DIRECTORY(lcBackup + "FORMS")
    MD (lcBackup + "FORMS")
ENDIF
IF !DIRECTORY(lcBackup + "MENU")
    MD (lcBackup + "MENU")
ENDIF
IF !FILE(lcBackup + "FORMS\recreate_ohip.scx")
    COPY FILE (lcForms + "recreate_ohip.scx") TO (lcBackup + "FORMS\recreate_ohip.scx")
    COPY FILE (lcForms + "recreate_ohip.sct") TO (lcBackup + "FORMS\recreate_ohip.sct")
    COPY FILE (lcForms + "version.scx") TO (lcBackup + "FORMS\version.scx")
    COPY FILE (lcForms + "version.sct") TO (lcBackup + "FORMS\version.sct")
    COPY FILE (lcMenu + "main_menu.mnx") TO (lcBackup + "MENU\main_menu.mnx")
    COPY FILE (lcMenu + "main_menu.mnt") TO (lcBackup + "MENU\main_menu.mnt")
ENDIF

USE (lcMenu + "main_menu.mnx") EXCLUSIVE ALIAS v16menu
LOCATE FOR ALLTRIM(prompt) == "Create Submission"
IF FOUND()
    REPLACE v16menu.skipfor WITH "optioncheckfast('EDT')"
ENDIF
LOCATE FOR ALLTRIM(prompt) == "Recreate OHIP Submission"
IF FOUND()
    REPLACE v16menu.procedure WITH ;
        "LOCAL RecreateOHIP_parameter" + CHR(13)+CHR(10) + ;
        "RecreateOHIP_parameter = IIF(g_edt, 'EDT', '')" + CHR(13)+CHR(10) + ;
        "DO FORM recreate_ohip WITH RecreateOHIP_parameter"
ENDIF
USE IN v16menu

USE (lcForms + "recreate_ohip.scx") EXCLUSIVE ALIAS v16recreate
SCAN FOR !EMPTY(v16recreate.methods)
    lcMethods = v16recreate.methods
    lcMethods = STRTRAN(lcMethods, 'justdrive(path_to_data)+"\program files\MOSt\backup\EDT\"', 'ADDBS(gc_datadrive)+"backup\EDT\"', 1, -1, 1)
    lcMethods = STRTRAN(lcMethods, 'justdrive(path_to_data)+"\program files\MOSt\backup\"', 'ADDBS(gc_datadrive)+"backup\"', 1, -1, 1)
    lcMethods = STRTRAN(lcMethods, 'justdrive(path_to_data)+"\program files\MOSt\EDT\OUT"', 'ADDBS(gc_datadrive)+"EDT\OUT"', 1, -1, 1)
    REPLACE v16recreate.methods WITH lcMethods
ENDSCAN
USE IN v16recreate

USE (lcForms + "version.scx") EXCLUSIVE ALIAS v16version
LOCATE FOR LOWER(ALLTRIM(objname)) == "versionform"
lcMethods = v16version.methods
lcMethods = STRTRAN(lcMethods, "thisform.text2.value=g_expirydate", 'thisform.text2.value="No expiry"', 1, 1, 1)
REPLACE v16version.methods WITH lcMethods
LOCATE FOR LOWER(ALLTRIM(objname)) == "label3"
lcProps = v16version.properties
lcProps = STRTRAN(lcProps, 'Caption = "Expiry Date:"', 'Caption = "Licence:"', 1, 1, 1)
REPLACE v16version.properties WITH lcProps
USE IN v16version

_GENMENU = ADDBS(lcRoot) + "genmenu.prg"
SET DEFAULT TO (ADDBS(lcRoot) + "MOSt")
BUILD EXE (ADDBS(lcRoot) + "output\MOST_V16_4_FEE_CURSOR_TEST.exe") FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS: V16.4 isolated fee-import cursor build completed" + CHR(13)+CHR(10), lcLog, 0)
ON ERROR
QUIT

PROCEDURE BuildError
    LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
    STRTOFILE("FAILED: Error " + TRANSFORM(tnError) + ": " + TRANSFORM(tcMessage) + CHR(13)+CHR(10) + ;
        "Code: " + TRANSFORM(tcCode) + CHR(13)+CHR(10) + ;
        "Program: " + TRANSFORM(tcProgram) + ", line " + TRANSFORM(tnLine) + CHR(13)+CHR(10), tcLog, 0)
    ON ERROR
    QUIT
ENDPROC
