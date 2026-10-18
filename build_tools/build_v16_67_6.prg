LPARAMETERS tcWorkingRoot
CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE ON
SET TALK OFF
SET RESOURCE OFF
LOCAL lcRoot,lcMost,lcLog,loFile,lcOms,lcOmsText,lcNeedle,lcReplace
LOCAL lnNeed,llFound,lcNativeName,loNative
LOCAL ARRAY laNeeded[9]
lcRoot=ADDBS(FULLPATH(tcWorkingRoot))
lcMost=lcRoot+"MOSt\"
lcLog=lcRoot+"output\build_v16_67_6.log"
IF !DIRECTORY(lcRoot+"output")
    MD (lcRoot+"output")
ENDIF
ON ERROR DO BuildFailed WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
STRTOFILE("START"+CHR(13)+CHR(10),lcLog,0)
IF !FILE(lcMost+"most.pjx") OR !FILE(lcRoot+"genmenu.prg") OR ;
        !FILE(lcMost+"PROGRAMS\consult_letter.prg") OR ;
        !FILE(lcMost+"PROGRAMS\mostprintpatientoutput.prg") OR ;
        !FILE(lcMost+"PROGRAMS\mostopenhelp.prg")
    ERROR "The isolated V16.67.6 source is incomplete."
ENDIF
IF !FILE(lcMost+"databases\oms.dbc") OR !FILE(lcMost+"databases\oms.dct") OR !FILE(lcMost+"databases\oms.dcx")
    ERROR "The isolated source is missing OMS database metadata."
ENDIF

* V16.67.6 is a workstation code-only build. It must coexist temporarily with
* the legacy server without invoking the old database upgrade program.
lcOms=lcMost+"PROGRAMS\oms.prg"
lcOmsText=FILETOSTR(lcOms)
IF !("llV1674CodeOnly" $ lcOmsText)
    lcOmsText=STRTRAN(lcOmsText, ;
        "LOCAL llV1615CodeOnly, llLegacySchemaVersion", ;
        "LOCAL llV1615CodeOnly, llLegacySchemaVersion, llV1674CodeOnly",1,1,0)
    lcNeedle='llLegacySchemaVersion = normalized_version(server_database_ver) <= normalized_version("1.7.609")'
    lcReplace=lcNeedle+CHR(13)+CHR(10)+ ;
        'llV1674CodeOnly = normalized_version(m_current_most_ver) == normalized_version("1.7.701")'
    lcOmsText=STRTRAN(lcOmsText,lcNeedle,lcReplace,1,1,0)
    lcOmsText=STRTRAN(lcOmsText, ;
        "AND !llV1615CodeOnly AND !llLegacySchemaVersion", ;
        "AND !llV1615CodeOnly AND !llLegacySchemaVersion AND !llV1674CodeOnly",1,-1,0)
    IF OCCURS("!llV1674CodeOnly",lcOmsText)<2
        ERROR "Could not install the V16.67.6 legacy-server guard."
    ENDIF
    STRTOFILE(lcOmsText,lcOms,0)
ENDIF

SET DEFAULT TO (lcMost)
SET PATH TO (lcMost+";"+lcMost+"PROGRAMS;"+lcMost+"FORMS;"+lcMost+"Classes;"+lcMost+"MENU;"+lcMost+"ICONS;"+lcMost+"REPORTS;"+lcMost+"labels")
USE (lcMost+"most.pjx") EXCLUSIVE ALIAS patchproject
RECALL FOR type='d' AND FILE(STRTRAN(name,CHR(0),'')) IN patchproject
REPLACE name WITH LOWER(lcMost+"most.pjx")+CHR(0), homedir WITH LOWER(lcMost)+CHR(0) FOR type='H' IN patchproject
REPLACE ALL homedir WITH LOWER(lcMost)+CHR(0) FOR !EMPTY(homedir) IN patchproject
DELETE FOR exclude AND type<>'H' AND !FILE(STRTRAN(name,CHR(0),'')) IN patchproject
DELETE FOR LOWER(JUSTFNAME(STRTRAN(name,CHR(0),"")))="dispcrnt.prg" IN patchproject
DELETE FOR LOWER(JUSTFNAME(STRTRAN(name,CHR(0),"")))="printer_router.prg" IN patchproject
USE IN patchproject

MODIFY PROJECT (lcMost+"most.pjx") NOWAIT
_VFP.ActiveProject.VersionNumber="1.7.701"
loFile=_VFP.ActiveProject
laNeeded[1]="thirdparty_freehand.prg"
laNeeded[2]="thirdparty_store.prg"
laNeeded[3]="thirdparty_history.prg"
laNeeded[4]="resolve_chart_root.prg"
laNeeded[5]="waitinglist_find.prg"
laNeeded[6]="diagram_tool.prg"
laNeeded[7]="mostprintpatientoutput.prg"
laNeeded[8]="mostopenhelp.prg"
laNeeded[9]="consult_letter.prg"
FOR lnNeed=1 TO ALEN(laNeeded,1)
    llFound=.F.
    FOR EACH loNative IN loFile.Files
        lcNativeName=LOWER(JUSTFNAME(loNative.Name))
        IF lcNativeName==laNeeded[lnNeed]
            llFound=.T.
            EXIT
        ENDIF
    ENDFOR
    IF !llFound
        loFile.Files.Add(lcMost+"PROGRAMS\"+laNeeded[lnNeed])
    ENDIF
ENDFOR

_GENMENU=lcRoot+"genmenu.prg"
_VFP.Visible=.T.
_SCREEN.Visible=.T.
_SCREEN.WindowState=2
STRTOFILE("BUILD START"+CHR(13)+CHR(10),lcLog,1)
loFile.Close()
BUILD EXE (lcRoot+"output\MOST_V16_67_6_1_7_701_XP_TEST.exe") FROM (lcMost+"most.pjx") RECOMPILE
LOCAL ARRAY laVersion[1]
IF AGETFILEVERSION(laVersion,lcRoot+"output\MOST_V16_67_6_1_7_701_XP_TEST.exe")=0 OR ALLTRIM(laVersion[4])#"1.7.701"
    ERROR "Executable was not created at version 1.7.701."
ENDIF
STRTOFILE("SUCCESS V16.67.6 1.7.701 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,1)
ON ERROR
QUIT

PROCEDURE BuildFailed
LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
STRTOFILE("ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10),tcLog,0)
ON ERROR
QUIT
ENDPROC
