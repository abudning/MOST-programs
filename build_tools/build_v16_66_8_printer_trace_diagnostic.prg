LPARAMETERS tcWorkingRoot
CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE ON
SET TALK OFF
SET RESOURCE OFF
LOCAL lcRoot,lcMost,lcLog,loFile,lcOms,lcOmsText,lcStartupMarker
IF VARTYPE(tcWorkingRoot)="C" AND !EMPTY(tcWorkingRoot)
    lcRoot=ADDBS(FULLPATH(tcWorkingRoot))
ELSE
    lcRoot=ADDBS(JUSTPATH(SYS(16)))
ENDIF
lcMost=lcRoot+"MOSt\"
lcLog=lcRoot+"output\build_v16_66_8_printer_trace_diagnostic.log"
IF !DIRECTORY(lcRoot+"output")
    MD (lcRoot+"output")
ENDIF
ON ERROR DO BuildFailed WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
STRTOFILE("START"+CHR(13)+CHR(10),lcLog,0)
IF !FILE(lcMost+"most.pjx") OR !FILE(lcRoot+"genmenu.prg")
    ERROR "Supply an isolated full MOSt source copy and local genmenu.prg."
ENDIF
IF !FILE(lcMost+"databases\oms.dbc") OR !FILE(lcMost+"databases\oms.dct") OR !FILE(lcMost+"databases\oms.dcx")
    ERROR "The isolated source copy is missing OMS database procedure metadata."
ENDIF
IF !FILE(lcMost+"PROGRAMS\printer_router.prg")
    ERROR "The printer trace router is missing."
ENDIF
* Make it unmistakable that the workstation launched this diagnostic EXE.
lcOms=lcMost+"PROGRAMS\oms.prg"
lcStartupMarker='STRTOFILE("STARTUP DIRECT-PRINT BUILD 3 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),ADDBS(SYS(2023))+"MOSt_Label_Print.log",0)'+CHR(13)+CHR(10)+ ;
    'MESSAGEBOX("DIRECT-PRINT BUILD 3 is running."+CHR(13)+CHR(13)+"Diagnostic log: "+ADDBS(SYS(2023))+"MOSt_Label_Print.log",64,"MOSt V16.66.8 Printer Trace")'
lcOmsText=FILETOSTR(lcOms)
IF !(lcStartupMarker $ lcOmsText)
    lcOmsText=STRTRAN(lcOmsText,"SET EXCLUSIVE OFF", ;
        "SET EXCLUSIVE OFF"+CHR(13)+CHR(10)+lcStartupMarker,1,1,1)
    IF !(lcStartupMarker $ lcOmsText)
        ERROR "Could not add the printer-trace startup marker."
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
USE IN patchproject
STRTOFILE("PROJECT PATCHED"+CHR(13)+CHR(10),lcLog,1)
MODIFY PROJECT (lcMost+"most.pjx") NOWAIT
STRTOFILE("PROJECT OPEN"+CHR(13)+CHR(10),lcLog,1)
* Keep the working scheduler's embedded version so this diagnostic does not
* invoke the legacy database-upgrade path. The final printer fix will advance.
_VFP.ActiveProject.VersionNumber="1.7.694"
loFile=_VFP.ActiveProject
loFile.Files.Add(lcMost+"PROGRAMS\thirdparty_freehand.prg")
loFile.Files.Add(lcMost+"PROGRAMS\thirdparty_store.prg")
loFile.Files.Add(lcMost+"PROGRAMS\thirdparty_history.prg")
loFile.Files.Add(lcMost+"PROGRAMS\resolve_chart_root.prg")
loFile.Files.Add(lcMost+"PROGRAMS\waitinglist_find.prg")
loFile.Files.Add(lcMost+"PROGRAMS\diagram_tool.prg")
loFile.Files.Add(lcMost+"PROGRAMS\printer_router.prg")
STRTOFILE("NATIVE HOME: "+loFile.HomeDir+CHR(13)+CHR(10),lcLog,1)
FOR EACH loNative IN loFile.Files
 IF !FILE(loNative.Name)
  STRTOFILE("MISSING NATIVE: "+loNative.Name+CHR(13)+CHR(10),lcLog,1)
 ENDIF
ENDFOR
_GENMENU=lcRoot+"genmenu.prg"
_VFP.Visible=.T.
_SCREEN.Visible=.T.
_SCREEN.WindowState=2
STRTOFILE("BUILD START"+CHR(13)+CHR(10),lcLog,1)
loFile.Close()
BUILD EXE (lcRoot+"output\MOST_V16_66_8_1_7_694_PRINTER_TRACE_DIAGNOSTIC.exe") FROM (lcMost+"most.pjx") RECOMPILE
LOCAL ARRAY laVersion[1]
IF AGETFILEVERSION(laVersion,lcRoot+"output\MOST_V16_66_8_1_7_694_PRINTER_TRACE_DIAGNOSTIC.exe")=0 OR ALLTRIM(laVersion[4])#"1.7.694"
    ERROR "Executable was not created with the expected version."
ENDIF
STRTOFILE("SUCCESS V16.66.8 PRINTER TRACE DIAGNOSTIC 1.7.694 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,1)
ON ERROR
QUIT

PROCEDURE BuildFailed
LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
STRTOFILE("ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10),tcLog,0)
ON ERROR
QUIT
ENDPROC
