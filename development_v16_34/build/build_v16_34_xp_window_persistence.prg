CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE ON
LOCAL lcRoot,lcMost,lcPrograms,lcForms,lcMenu,lcOutput,lcBackup,lcLog
LOCAL lcOms,lcText,lcOld,lcNew,lcProps,lcMethods,lnStart,lnRelEnd,lnEnd,lcNewClick,loMenu
lcRoot="E:\MOST for chat\oms_vfp9_build\"
lcMost=lcRoot+"MOSt\"
lcPrograms=lcMost+"PROGRAMS\"
lcForms=lcMost+"FORMS\"
lcMenu=lcMost+"MENU\"
lcOutput=lcRoot+"output\"
lcBackup=lcRoot+"backup_v16_34_xp_window_persistence_20260913\"
lcLog=lcOutput+"build_v16_34_xp_window_persistence.log"
ON ERROR DO BuildError WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
IF !DIRECTORY(lcBackup)
 MD (lcBackup)
 MD (lcBackup+"PROGRAMS")
 MD (lcBackup+"FORMS")
 MD (lcBackup+"MENU")
ENDIF
COPY FILE (lcPrograms+"oms.prg") TO (lcBackup+"PROGRAMS\oms.prg")
COPY FILE (lcPrograms+"openletterwriter.prg") TO (lcBackup+"PROGRAMS\openletterwriter.prg")
COPY FILE (lcForms+"version.scx") TO (lcBackup+"FORMS\version.scx")
COPY FILE (lcForms+"version.sct") TO (lcBackup+"FORMS\version.sct")
COPY FILE (lcForms+"patients.scx") TO (lcBackup+"FORMS\patients.scx")
COPY FILE (lcForms+"patients.sct") TO (lcBackup+"FORMS\patients.sct")
COPY FILE (lcMenu+"main_menu.mnx") TO (lcBackup+"MENU\main_menu.mnx")
COPY FILE (lcMenu+"main_menu.mnt") TO (lcBackup+"MENU\main_menu.mnt")
COPY FILE "C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\openletterwriter_v16_34.prg" TO (lcPrograms+"openletterwriter.prg")
COPY FILE "C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\openpatientclaim_v16_34.prg" TO (lcPrograms+"openpatientclaim.prg")
COPY FILE "C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\openpatientclaimsletters_v16_34.prg" TO (lcPrograms+"openpatientclaimsletters.prg")
lcOms=lcPrograms+"oms.prg"
lcText=FILETOSTR(lcOms)
lcOld='normalized_version("1.7.630"), normalized_version("1.7.631"), normalized_version("1.7.632"), normalized_version("1.7.633"), normalized_version("1.7.634")) ;'
lcNew=STRTRAN(lcOld,'normalized_version("1.7.634")) ;','normalized_version("1.7.634"), normalized_version("1.7.635")) ;')
IF lcOld $ lcText
 STRTOFILE(STRTRAN(lcText,lcOld,lcNew,1,1,1),lcOms,0)
ELSE
 IF !('normalized_version("1.7.635")' $ lcText)
  ERROR "Version guard could not be patched"
 ENDIF
ENDIF
USE (lcForms+"version.scx") EXCLUSIVE ALIAS v34version
SCAN
 lcProps=v34version.properties
 lcMethods=v34version.methods
 IF "V16.33" $ lcProps
  REPLACE properties WITH STRTRAN(lcProps,"V16.33","V16.34",1,-1,1) IN v34version
 ENDIF
 IF "V16.33" $ lcMethods
  REPLACE methods WITH STRTRAN(lcMethods,"V16.33","V16.34",1,-1,1) IN v34version
 ENDIF
ENDSCAN
USE IN v34version
USE (lcForms+"patients.scx") EXCLUSIVE ALIAS v34patients
LOCATE FOR UPPER(ALLTRIM(v34patients.objname))=="CLAIMS" AND UPPER(ALLTRIM(v34patients.parent))=="PATIENTS"
IF !FOUND()
 ERROR "Patients Claims button was not found"
ENDIF
lcMethods=v34patients.methods
lnStart=ATC("PROCEDURE Click",lcMethods)
lnRelEnd=ATC("ENDPROC",SUBSTR(lcMethods,lnStart))
lnEnd=lnStart+lnRelEnd+LEN("ENDPROC")-2
TEXT TO lcNewClick NOSHOW
PROCEDURE Click
* V16.34 POSITION CLAIMS TO THE RIGHT OF PATIENTS
IF THISFORM.error_found()
 RETURN
ENDIF
DO openpatientclaim WITH THISFORM
ENDPROC
ENDTEXT
REPLACE methods WITH LEFT(lcMethods,lnStart-1)+lcNewClick+SUBSTR(lcMethods,lnEnd+1) IN v34patients
LOCATE FOR UPPER(ALLTRIM(v34patients.objname))=="LETTERS" AND UPPER(ALLTRIM(v34patients.parent))=="PATIENTS"
IF FOUND() AND "V16.33 SINGLE LETTERBUILDER" $ v34patients.methods
 REPLACE methods WITH STRTRAN(v34patients.methods,"V16.33 SINGLE LETTERBUILDER","V16.34 SINGLE LETTERBUILDER",1,1,1) IN v34patients
ENDIF
USE IN v34patients
USE (lcMenu+"main_menu.mnx") EXCLUSIVE ALIAS v34menu
LOCATE FOR UPPER(ALLTRIM(v34menu.prompt))=="PATIENT / CLAIMS / LETTERS" AND UPPER(ALLTRIM(v34menu.levelname))=="PATIENTS"
IF !FOUND()
 LOCATE FOR UPPER(ALLTRIM(v34menu.prompt))=="LETTER BUILDER" AND UPPER(ALLTRIM(v34menu.levelname))=="PATIENTS"
 SCATTER NAME loMenu MEMO
 APPEND BLANK
 GATHER NAME loMenu MEMO
 REPLACE prompt WITH "Patient / Claims / Letters" IN v34menu
 REPLACE procedure WITH "DO openpatientclaimsletters" IN v34menu
 REPLACE itemnum WITH "  4" IN v34menu
ENDIF
LOCATE FOR objtype=2 AND UPPER(ALLTRIM(name))=="PATIENTS"
IF FOUND()
 REPLACE numitems WITH 4 IN v34menu
ENDIF
USE IN v34menu
CD (lcMost)
_GENMENU=lcRoot+"genmenu.prg"
SET DEFAULT TO (lcMost)
BUILD EXE (lcOutput+"MOST_V16_34_XP_WINDOW_PERSISTENCE.exe") FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS V16.34 1.7.635 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,0)
ON ERROR
QUIT
PROCEDURE BuildError
LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
LOCAL lcError
lcError="ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10)
STRTOFILE(lcError,tcLog,0)
MESSAGEBOX(lcError,16,"MOSt V16.34 build")
CANCEL
ENDPROC