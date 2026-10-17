LPARAMETERS tcWorkingRoot
CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE ON
SET TALK OFF
SET RESOURCE OFF
LOCAL lcRoot,lcMost,lcLog,loFile
IF VARTYPE(tcWorkingRoot)="C" AND !EMPTY(tcWorkingRoot)
    lcRoot=ADDBS(FULLPATH(tcWorkingRoot))
ELSE
    lcRoot=ADDBS(JUSTPATH(SYS(16)))
ENDIF
lcMost=lcRoot+"MOSt\"
lcLog=lcRoot+"output\build_v16_66_9_printer_fix.log"
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
IF !FILE(lcMost+"PROGRAMS\mostprintpatientoutput.prg")
    ERROR "The patient printer router is missing."
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
STRTOFILE("PROJECT PATCHED"+CHR(13)+CHR(10),lcLog,1)
MODIFY PROJECT (lcMost+"most.pjx") NOWAIT
STRTOFILE("PROJECT OPEN"+CHR(13)+CHR(10),lcLog,1)
_VFP.ActiveProject.VersionNumber="1.7.695"
loFile=_VFP.ActiveProject
loFile.Files.Add(lcMost+"PROGRAMS\thirdparty_freehand.prg")
loFile.Files.Add(lcMost+"PROGRAMS\thirdparty_store.prg")
loFile.Files.Add(lcMost+"PROGRAMS\thirdparty_history.prg")
loFile.Files.Add(lcMost+"PROGRAMS\resolve_chart_root.prg")
loFile.Files.Add(lcMost+"PROGRAMS\waitinglist_find.prg")
loFile.Files.Add(lcMost+"PROGRAMS\diagram_tool.prg")
loFile.Files.Add(lcMost+"PROGRAMS\mostprintpatientoutput.prg")
STRTOFILE("NATIVE HOME: "+loFile.HomeDir+CHR(13)+CHR(10),lcLog,1)
_GENMENU=lcRoot+"genmenu.prg"
_VFP.Visible=.T.
_SCREEN.Visible=.T.
_SCREEN.WindowState=2
STRTOFILE("BUILD START"+CHR(13)+CHR(10),lcLog,1)
loFile.Close()
BUILD EXE (lcRoot+"output\MOST_V16_66_9_1_7_695_PRINTER_FIX_RC.exe") FROM (lcMost+"most.pjx") RECOMPILE
LOCAL ARRAY laVersion[1]
IF AGETFILEVERSION(laVersion,lcRoot+"output\MOST_V16_66_9_1_7_695_PRINTER_FIX_RC.exe")=0 OR ALLTRIM(laVersion[4])#"1.7.695"
    ERROR "Executable was not created with the expected version."
ENDIF
STRTOFILE("SUCCESS V16.66.9 PRINTER FIX 1.7.695 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,1)
ON ERROR
QUIT

PROCEDURE BuildFailed
LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
STRTOFILE("ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10),tcLog,0)
ON ERROR
QUIT
ENDPROC
