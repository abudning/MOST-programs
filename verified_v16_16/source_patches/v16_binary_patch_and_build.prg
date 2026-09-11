LOCAL lcRoot, lcForms, lcMenu, lcBackup, lcLog, lcMethods, lcProps, lcCode
lcRoot = "E:\MOST for chat\oms_vfp9_build"
lcForms = ADDBS(lcRoot) + "MOSt\FORMS\"
lcMenu = ADDBS(lcRoot) + "MOSt\MENU\"
lcBackup = ADDBS(lcRoot) + "backup_v15_before_ohip_20260907\"
lcLog = ADDBS(lcRoot) + "output\direct_build_v16_16.log"
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

* V16.13: point the Fee Codes form at the configured server database.
IF !FILE(lcBackup + "FORMS\fees.scx")
    COPY FILE (lcForms + "fees.scx") TO (lcBackup + "FORMS\fees.scx")
    COPY FILE (lcForms + "fees.sct") TO (lcBackup + "FORMS\fees.sct")
ENDIF
USE (lcForms + "fees.scx") EXCLUSIVE ALIAS v16feesform
LOCATE FOR LOWER(ALLTRIM(baseclass)) == "dataenvironment"
IF FOUND() AND !"V16.13 server fee database" $ v16feesform.methods
    lcMethods = v16feesform.methods + CHR(13)+CHR(10) + ;
        "PROCEDURE BeforeOpenTables" + CHR(13)+CHR(10) + ;
        "* V16.13 server fee database" + CHR(13)+CHR(10) + ;
        "THIS.Cursor1.Database = ADDBS(path_to_data) + 'oms.dbc'" + CHR(13)+CHR(10) + ;
        "THIS.Cursor3.Database = ADDBS(path_to_data) + 'oms.dbc'" + CHR(13)+CHR(10) + ;
        "ENDPROC" + CHR(13)+CHR(10)
    REPLACE v16feesform.methods WITH lcMethods
ENDIF
LOCATE FOR LOWER(ALLTRIM(baseclass)) == "dataenvironment"
IF FOUND() AND "V16.13 server fee database" $ v16feesform.methods AND ;
        !"V16.14 suppress path echo" $ v16feesform.methods
    lcMethods = STRTRAN(v16feesform.methods, ;
        "PROCEDURE BeforeOpenTables" + CHR(13)+CHR(10), ;
        "PROCEDURE BeforeOpenTables" + CHR(13)+CHR(10) + ;
        "* V16.14 suppress path echo" + CHR(13)+CHR(10) + ;
        "SET TALK OFF" + CHR(13)+CHR(10), 1, 1, 1)
    REPLACE v16feesform.methods WITH lcMethods
ENDIF

USE IN v16feesform

* V16.16: use the detected workstation folder instead of the XP-only
* C:\Program Files\MOSt\LABELS path in Setup > Modify Labels.
USE (lcMenu + "main_menu.mnx") EXCLUSIVE ALIAS v16labelmenu
LOCATE FOR ALLTRIM(prompt) == "Modify Labels"
IF FOUND()
    REPLACE v16labelmenu.procedure WITH ;
        "LOCAL pwok, lcLabelsPath" + CHR(13)+CHR(10) + ;
        "DO FORM supervisor_Login TO pwok" + CHR(13)+CHR(10) + ;
        "IF pwok > 0" + CHR(13)+CHR(10) + ;
        CHR(9) + "lcLabelsPath = ADDBS(gc_localapp) + 'LABELS'" + CHR(13)+CHR(10) + ;
        CHR(9) + "IF DIRECTORY(lcLabelsPath)" + CHR(13)+CHR(10) + ;
        CHR(9)+CHR(9) + "SET SYSMENU TO DEFAULT" + CHR(13)+CHR(10) + ;
        CHR(9)+CHR(9) + "CD (lcLabelsPath)" + CHR(13)+CHR(10) + ;
        CHR(9)+CHR(9) + "MODIFY LABEL" + CHR(13)+CHR(10) + ;
        CHR(9)+CHR(9) + "QUIT" + CHR(13)+CHR(10) + ;
        CHR(9) + "ELSE" + CHR(13)+CHR(10) + ;
        CHR(9)+CHR(9) + "MESSAGEBOX('Label folder not found: ' + lcLabelsPath, 16, 'MOSt Warning')" + CHR(13)+CHR(10) + ;
        CHR(9) + "ENDIF" + CHR(13)+CHR(10) + ;
        "ENDIF"
ENDIF
USE IN v16labelmenu

* V16.15: the Claims form must use the configured shared database for fees.
* Other cursors retain their existing configuration; only the fee lookup is
* redirected so claim entry cannot silently use a stale workstation copy.
IF !FILE(lcBackup + "FORMS\enter_claims.scx")
    COPY FILE (lcForms + "enter_claims.scx") TO (lcBackup + "FORMS\enter_claims.scx")
    COPY FILE (lcForms + "enter_claims.sct") TO (lcBackup + "FORMS\enter_claims.sct")
ENDIF
USE (lcForms + "enter_claims.scx") EXCLUSIVE ALIAS v16claimsform
LOCATE FOR LOWER(ALLTRIM(baseclass)) == "dataenvironment"
IF FOUND() AND !"V16.15 server fee database" $ v16claimsform.methods
    lcMethods = v16claimsform.methods + CHR(13)+CHR(10) + ;
        "PROCEDURE BeforeOpenTables" + CHR(13)+CHR(10) + ;
        "* V16.15 server fee database" + CHR(13)+CHR(10) + ;
        "SET TALK OFF" + CHR(13)+CHR(10) + ;
        "THIS.Cursor4.Database = ADDBS(path_to_data) + 'oms.dbc'" + CHR(13)+CHR(10) + ;
        "ENDPROC" + CHR(13)+CHR(10)
    REPLACE v16claimsform.methods WITH lcMethods
ENDIF
USE IN v16claimsform

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
BUILD EXE (ADDBS(lcRoot) + "output\MOST_V16_16_LABEL_PATH_TEST.exe") FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS: V16.16 dynamic label path build completed" + CHR(13)+CHR(10), lcLog, 0)
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
