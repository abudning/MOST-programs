LOCAL lcRoot, lcMost, lcPrograms, lcForms, lcOutput, lcBackup, lcLog
LOCAL lcOms, lcText, lcOld, lcNew, lcProps, lcMethods, lcPatientMethods, lnFaxMenuStart, lnMenuShow, lnFaxCaseStart, lnEndCase
lcRoot="E:\MOST for chat\oms_vfp9_build\"
lcMost=lcRoot+"MOSt\"
lcPrograms=lcMost+"PROGRAMS\"
lcForms=lcMost+"FORMS\"
lcOutput=lcRoot+"output\"
lcBackup=lcRoot+"backup_v16_28_rx_repair_20260912\"
lcLog=lcOutput+"build_v16_28_rx_repair.log"
SET SAFETY OFF
SET EXCLUSIVE ON
ON ERROR DO BuildError WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
IF !DIRECTORY(lcBackup)
    MD (lcBackup)
    MD (lcBackup+"PROGRAMS")
    MD (lcBackup+"FORMS")
ENDIF
COPY FILE (lcPrograms+"rxcenter.prg") TO (lcBackup+"PROGRAMS\rxcenter.prg")
COPY FILE (lcPrograms+"oms.prg") TO (lcBackup+"PROGRAMS\oms.prg")
COPY FILE (lcForms+"version.scx") TO (lcBackup+"FORMS\version.scx")
COPY FILE (lcForms+"version.sct") TO (lcBackup+"FORMS\version.sct")
COPY FILE (lcForms+"patients.scx") TO (lcBackup+"FORMS\patients.scx")
COPY FILE (lcForms+"patients.sct") TO (lcBackup+"FORMS\patients.sct")
COPY FILE "C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\rxcenter_v16_28.prg" TO (lcPrograms+"rxcenter.prg")
lcOms=lcPrograms+"oms.prg"
lcText=FILETOSTR(lcOms)
lcOld='normalized_version("1.7.625"), normalized_version("1.7.626"), normalized_version("1.7.627"), normalized_version("1.7.628")) ;'
lcNew='normalized_version("1.7.625"), normalized_version("1.7.626"), normalized_version("1.7.627"), normalized_version("1.7.628"), normalized_version("1.7.629")) ;'
IF lcOld $ lcText
    STRTOFILE(STRTRAN(lcText,lcOld,lcNew,1,1,1),lcOms,0)
ELSE
    IF !('normalized_version("1.7.629")' $ lcText)
        ERROR "Version guard could not be patched"
    ENDIF
ENDIF
USE (lcForms+"version.scx") EXCLUSIVE ALIAS v18version
SCAN
    lcProps=v18version.properties
    lcMethods=v18version.methods
    IF "V16.24" $ lcProps
        REPLACE properties WITH STRTRAN(lcProps,"V16.27","V16.28",1,-1,1) IN v18version
    ENDIF
    IF "V16.24" $ lcMethods
        REPLACE methods WITH STRTRAN(lcMethods,"V16.27","V16.28",1,-1,1) IN v18version
    ENDIF
ENDSCAN
USE IN v18version
USE (lcForms+"patients.scx") EXCLUSIVE ALIAS v23patients
LOCATE FOR LOWER(ALLTRIM(objname))=="cmdemr"
IF !FOUND()
    ERROR "Rx menu button was not found in patients.scx"
ENDIF
lcPatientMethods=v23patients.methods
lcPatientMethods=STRTRAN(lcPatientMethods,"LOCAL laMenu[9]","LOCAL laMenu[7]",1,1,1)
lnFaxMenuStart=AT('laMenu[8]="\-"',lcPatientMethods)
lnMenuShow=AT("THISFORM.oMenuShortcut.ShowMenu",lcPatientMethods)
IF lnFaxMenuStart>0 AND lnMenuShow>lnFaxMenuStart
    lcPatientMethods=LEFT(lcPatientMethods,lnFaxMenuStart-1)+SUBSTR(lcPatientMethods,lnMenuShow)
ENDIF
lnFaxCaseStart=AT("CASE BAR() = 9",lcPatientMethods)
lnEndCase=RAT("ENDCASE",lcPatientMethods)
IF lnFaxCaseStart>0 AND lnEndCase>lnFaxCaseStart
    lcPatientMethods=LEFT(lcPatientMethods,lnFaxCaseStart-1)+SUBSTR(lcPatientMethods,lnEndCase)
ENDIF
REPLACE methods WITH lcPatientMethods IN v23patients
USE IN v23patients
MODIFY PROJECT (lcMost+"most.pjx") NOWAIT
_VFP.ActiveProject.VersionNumber="1.7.629"
_VFP.ActiveProject.Close()
_GENMENU=lcRoot+"genmenu.prg"
SET DEFAULT TO (lcMost)
BUILD EXE (lcOutput+"MOST_V16_28_RX_REPAIR.exe") FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS V16.28 1.7.629 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,0)
ON ERROR
QUIT

PROCEDURE BuildError
LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
STRTOFILE("FAILED Error "+TRANSFORM(tnError)+": "+TRANSFORM(tcMessage)+CHR(13)+CHR(10)+;
    "Code: "+TRANSFORM(tcCode)+CHR(13)+CHR(10)+"Program: "+TRANSFORM(tcProgram)+" line "+TRANSFORM(tnLine)+CHR(13)+CHR(10),tcLog,0)
ON ERROR
QUIT
ENDPROC
