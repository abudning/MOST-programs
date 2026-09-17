CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE ON
SET TALK OFF
SET RESOURCE OFF
LOCAL lcRoot,lcMost,lcLog,loFile
lcRoot="C:\Users\abudn\Documents\Codex\2026-09-15\ple\work\v16_63_build\"
lcMost=lcRoot+"MOSt\"
lcLog=lcRoot+"output\build_v16_62.log"
ON ERROR DO BuildFailed WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
STRTOFILE("START"+CHR(13)+CHR(10),lcLog,0)
SET DEFAULT TO (lcMost)
SET PATH TO (lcMost+";"+lcMost+"PROGRAMS;"+lcMost+"FORMS;"+lcMost+"Classes;"+lcMost+"MENU;"+lcMost+"ICONS;"+lcMost+"REPORTS;"+lcMost+"labels")
USE (lcMost+"most.pjx") EXCLUSIVE ALIAS patchproject
REPLACE name WITH LOWER(lcMost+"most.pjx")+CHR(0), homedir WITH LOWER(lcMost)+CHR(0) FOR type='H' IN patchproject
REPLACE ALL homedir WITH LOWER(lcMost)+CHR(0) FOR !EMPTY(homedir) IN patchproject
* Keep excluded database/table metadata present for the legacy linker.
DELETE FOR exclude AND type<>'H' AND !FILE(STRTRAN(name,CHR(0),'')) IN patchproject
* Retain the generated V16.60 menus; this repair does not modify menu definitions.
* Retain native menu entries to avoid duplicate object-file names.
DELETE FOR LOWER(JUSTFNAME(STRTRAN(name,CHR(0),"")))="dispcrnt.prg" IN patchproject
USE IN patchproject
STRTOFILE("PROJECT PATCHED"+CHR(13)+CHR(10),lcLog,1)
MODIFY PROJECT (lcMost+"most.pjx") NOWAIT
STRTOFILE("PROJECT OPEN"+CHR(13)+CHR(10),lcLog,1)
_VFP.ActiveProject.VersionNumber="1.7.664"
loFile=_VFP.ActiveProject
STRTOFILE("NATIVE HOME: "+loFile.HomeDir+CHR(13)+CHR(10),lcLog,1)
FOR EACH loNative IN loFile.Files
 IF !FILE(loNative.Name)
  STRTOFILE("MISSING NATIVE: "+loNative.Name+CHR(13)+CHR(10),lcLog,1)
 ENDIF
ENDFOR
_GENMENU=lcRoot+"genmenu.prg"
_VFP.Visible=.T.
_SCREEN.Visible=.T.
STRTOFILE("BUILD START"+CHR(13)+CHR(10),lcLog,1)
loFile.Close()
BUILD EXE (lcRoot+"output\MOST_V16_63_XP_CLAIMS_REPAIR.exe") FROM (lcMost+"most.pjx") RECOMPILE
STRTOFILE("SUCCESS V16.63 1.7.664 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,0)
ON ERROR
QUIT
PROCEDURE BuildFailed
LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
STRTOFILE("ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10),tcLog,0)
ON ERROR
QUIT
ENDPROC

















