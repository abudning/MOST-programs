CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE ON
LOCAL lcRoot, lcMost, lcPrograms, lcForms, lcMenu, lcOutput, lcBackup, lcLog
LOCAL lcOms, lcText, lcOld, lcNew, lcProps, lcMethods, lnStart, lnRelEnd, lnEnd, lcNewClick
lcRoot="E:\MOST for chat\oms_vfp9_build\"
lcMost=lcRoot+"MOSt\"
lcPrograms=lcMost+"PROGRAMS\"
lcForms=lcMost+"FORMS\"
lcMenu=lcMost+"MENU\"
lcOutput=lcRoot+"output\"
lcBackup=lcRoot+"backup_v16_30_xp_patient_letters_20260913\"
lcLog=lcOutput+"build_v16_30_xp_patient_letters.log"
ON ERROR DO BuildError WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
IF !DIRECTORY(lcBackup)
    MD (lcBackup)
    MD (lcBackup+"PROGRAMS")
    MD (lcBackup+"FORMS")
    MD (lcBackup+"MENU")
ENDIF
COPY FILE (lcPrograms+"oms.prg") TO (lcBackup+"PROGRAMS\oms.prg")
COPY FILE (lcForms+"version.scx") TO (lcBackup+"FORMS\version.scx")
COPY FILE (lcForms+"version.sct") TO (lcBackup+"FORMS\version.sct")
COPY FILE (lcForms+"patients.scx") TO (lcBackup+"FORMS\patients.scx")
COPY FILE (lcForms+"patients.sct") TO (lcBackup+"FORMS\patients.sct")
COPY FILE (lcMenu+"main_menu.mnx") TO (lcBackup+"MENU\main_menu.mnx")
COPY FILE (lcMenu+"main_menu.mnt") TO (lcBackup+"MENU\main_menu.mnt")
IF FILE(lcPrograms+"openletterwriter.prg")
    COPY FILE (lcPrograms+"openletterwriter.prg") TO (lcBackup+"PROGRAMS\openletterwriter.prg")
ENDIF
COPY FILE "C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\openletterwriter_v16_30.prg" TO (lcPrograms+"openletterwriter.prg")

lcOms=lcPrograms+"oms.prg"
lcText=FILETOSTR(lcOms)
lcOld='normalized_version("1.7.625"), normalized_version("1.7.626"), normalized_version("1.7.627"), normalized_version("1.7.628"), normalized_version("1.7.629"), normalized_version("1.7.630")) ;'
lcNew='normalized_version("1.7.625"), normalized_version("1.7.626"), normalized_version("1.7.627"), normalized_version("1.7.628"), normalized_version("1.7.629"), normalized_version("1.7.630"), normalized_version("1.7.631")) ;'
IF lcOld $ lcText
    STRTOFILE(STRTRAN(lcText,lcOld,lcNew,1,1,1),lcOms,0)
ELSE
    IF !('normalized_version("1.7.631")' $ lcText)
        ERROR "Version guard could not be patched"
    ENDIF
ENDIF

USE (lcForms+"version.scx") EXCLUSIVE ALIAS v30version
SCAN
    lcProps=v30version.properties
    lcMethods=v30version.methods
    IF "V16.29" $ lcProps
        REPLACE properties WITH STRTRAN(lcProps,"V16.29","V16.30",1,-1,1) IN v30version
    ENDIF
    IF "V16.29" $ lcMethods
        REPLACE methods WITH STRTRAN(lcMethods,"V16.29","V16.30",1,-1,1) IN v30version
    ENDIF
ENDSCAN
USE IN v30version

* Replace only the patient-screen Letters button Click method.
USE (lcForms+"patients.scx") EXCLUSIVE ALIAS v30patients
LOCATE FOR UPPER(ALLTRIM(v30patients.objname))=="LETTERS" AND UPPER(ALLTRIM(v30patients.parent))=="PATIENTS"
IF !FOUND()
    ERROR "Patient-screen Letters button was not found"
ENDIF
lcMethods=v30patients.methods
IF !("V16.30 SINGLE LETTERBUILDER" $ lcMethods)
    lnStart=ATC("PROCEDURE Click",lcMethods)
    IF lnStart=0
        ERROR "Patient Letters Click method was not found"
    ENDIF
    lnRelEnd=ATC("ENDPROC",SUBSTR(lcMethods,lnStart))
    IF lnRelEnd=0
        ERROR "Patient Letters Click method end was not found"
    ENDIF
    lnEnd=lnStart+lnRelEnd+LEN("ENDPROC")-2
    TEXT TO lcNewClick NOSHOW
PROCEDURE Click
* V16.30 SINGLE LETTERBUILDER - open the form only, scoped to current patient.
IF THISFORM.error_found()
    RETURN
ENDIF
IF !USED("patients") OR EOF("patients")
    MESSAGEBOX("Select a patient before opening LetterBuilder.",48,"MOSt - LetterBuilder")
    RETURN
ENDIF
DO openletterwriter WITH patients.id
ENDPROC
    ENDTEXT
    REPLACE methods WITH LEFT(lcMethods,lnStart-1)+lcNewClick+SUBSTR(lcMethods,lnEnd+1) IN v30patients
ENDIF
USE IN v30patients

* Route Patients > Letter Builder through the same singleton launcher.
USE (lcMenu+"main_menu.mnx") EXCLUSIVE ALIAS v30menu
LOCATE FOR UPPER(ALLTRIM(v30menu.prompt))=="LETTER BUILDER" AND UPPER(ALLTRIM(v30menu.levelname))=="PATIENTS"
IF !FOUND()
    ERROR "Patients menu Letter Builder item was not found"
ENDIF
REPLACE proctype WITH 1, procedure WITH "DO openletterwriter" IN v30menu
USE IN v30menu

* Confirm the preceding XP lock repair is still present.
USE (lcForms+"letterform.scx") SHARED ALIAS v30lettercheck
LOCATE FOR UPPER(ALLTRIM(v30lettercheck.objname))=="WORD" AND "PAGE1" $ UPPER(v30lettercheck.parent)
IF !FOUND() OR !("V16.29 XP MULTI-WORKSTATION LETTER LOCK" $ v30lettercheck.methods)
    ERROR "V16.29 LetterBuilder lock repair is missing"
ENDIF
USE IN v30lettercheck

CD (lcMost)
_GENMENU=lcRoot+"genmenu.prg"
SET DEFAULT TO (lcMost)
BUILD EXE (lcOutput+"MOST_V16_30_XP_PATIENT_LETTERS.exe") FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS V16.30 1.7.631 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,0)
ON ERROR
QUIT

PROCEDURE BuildError
LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
LOCAL lcError
lcError="ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10)
STRTOFILE(lcError,tcLog,0)
MESSAGEBOX(lcError,16,"MOSt V16.30 build")
CANCEL
ENDPROC
