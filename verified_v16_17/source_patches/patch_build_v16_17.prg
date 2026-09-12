LOCAL lcRoot, lcMost, lcForms, lcPrograms, lcOutput, lcBackup, lcLog
LOCAL lcMethods, lnStart, lnNext, lcNewBlock, loRec, loFile, llFound
lcRoot="E:\MOST for chat\oms_vfp9_build\"
lcMost=lcRoot+"MOSt\"
lcForms=lcMost+"FORMS\"
lcPrograms=lcMost+"PROGRAMS\"
lcOutput=lcRoot+"output\"
lcBackup=lcRoot+"backup_v16_17_prescriptions_20260912\"
lcLog=lcOutput+"build_v16_17.log"
SET SAFETY OFF
SET EXCLUSIVE ON
ON ERROR DO BuildError WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog

IF !DIRECTORY(lcBackup)
    MD (lcBackup)
ENDIF
IF !DIRECTORY(lcBackup+"FORMS")
    MD (lcBackup+"FORMS")
ENDIF
IF !DIRECTORY(lcBackup+"PROGRAMS")
    MD (lcBackup+"PROGRAMS")
ENDIF
IF !FILE(lcBackup+"FORMS\patients.scx")
    COPY FILE (lcForms+"patients.scx") TO (lcBackup+"FORMS\patients.scx")
    COPY FILE (lcForms+"patients.sct") TO (lcBackup+"FORMS\patients.sct")
ENDIF
IF FILE(lcPrograms+"rxcenter.prg") AND !FILE(lcBackup+"PROGRAMS\rxcenter.prg")
    COPY FILE (lcPrograms+"rxcenter.prg") TO (lcBackup+"PROGRAMS\rxcenter.prg")
ENDIF
COPY FILE "C:\Users\abudn\Documents\Codex\2026-09-09\i-a\work\rxcenter.prg" TO (lcPrograms+"rxcenter.prg")

COMPILE (lcPrograms+"rxcenter.prg")

USE (lcForms+"patients.scx") EXCLUSIVE ALIAS v16patients
LOCATE FOR LOWER(ALLTRIM(objname))=="cmdemr"
IF !FOUND()
    ERROR "cmdEmr was not found in patients.scx"
ENDIF
lcMethods=v16patients.methods
IF !("V16.17 prescription history" $ lcMethods)
    lcMethods=STRTRAN(lcMethods,'laMenu[3]="Immunizations"','laMenu[3]="Prescription History"',1,1,1)
    lnStart=AT("CASE BAR() = 3",lcMethods)
    lnNext=AT("CASE BAR() = 5",SUBSTR(lcMethods,lnStart))
    IF lnStart=0 OR lnNext=0
        ERROR "The immunization menu handler could not be located"
    ENDIF
    lnNext=lnStart+lnNext-1
    lcNewBlock="CASE BAR() = 3 "+CHR(38)+CHR(38)+" V16.17 prescription history"+CHR(13)+CHR(10)+CHR(9)+"DO rxcenter WITH 'HISTORY',THISFORM,''"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(9)
    lcMethods=LEFT(lcMethods,lnStart-1)+lcNewBlock+SUBSTR(lcMethods,lnNext)
    REPLACE methods WITH lcMethods IN v16patients
ENDIF

LOCATE FOR LOWER(ALLTRIM(objname))=="cmdnewrx"
IF !FOUND()
    LOCATE FOR LOWER(ALLTRIM(objname))=="cmdemr"
    SCATTER MEMO NAME loRec
    APPEND BLANK
    GATHER NAME loRec MEMO
    REPLACE objname WITH "cmdNewRx", ;
        properties WITH STRTRAN(STRTRAN(STRTRAN(STRTRAN(properties,;
            "Left = 270","Left = 226",1,1,1),;
            'Caption = "EMR"','Caption = "New Rx"',1,1,1),;
            'Name = "cmdEmr"','Name = "cmdNewRx"',1,1,1),;
            "ForeColor = 0,0,255","ForeColor = 0,0,0",1,1,1), ;
        methods WITH "PROCEDURE Click"+CHR(13)+CHR(10)+;
            "* V16.17 new medication or glasses prescription"+CHR(13)+CHR(10)+;
            "IF THISFORM.error_found()"+CHR(13)+CHR(10)+CHR(9)+"RETURN"+CHR(13)+CHR(10)+"ENDIF"+CHR(13)+CHR(10)+;
            "DO rxcenter WITH 'NEW',THISFORM,''"+CHR(13)+CHR(10)+"ENDPROC"+CHR(13)+CHR(10) IN v16patients
    IF TYPE("v16patients.uniqueid")="C"
        REPLACE uniqueid WITH SYS(2015) IN v16patients
    ENDIF
ENDIF
USE IN v16patients

MODIFY PROJECT (lcMost+"most.pjx") NOWAIT
llFound=.F.
FOR EACH loFile IN _VFP.ActiveProject.Files
    IF UPPER(loFile.Name)==UPPER(lcPrograms+"rxcenter.prg")
        llFound=.T.
        EXIT
    ENDIF
ENDFOR
IF !llFound
    _VFP.ActiveProject.Files.Add(lcPrograms+"rxcenter.prg")
ENDIF
_VFP.ActiveProject.VersionNumber="1.7.614"
_VFP.ActiveProject.Close()

_GENMENU=lcRoot+"genmenu.prg"
SET DEFAULT TO (lcMost)
BUILD EXE (lcOutput+"MOST_V16_17_PRESCRIPTION_TEST.exe") FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS V16.17 prescription build "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,0)
ON ERROR
QUIT

PROCEDURE BuildError
    LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
    STRTOFILE("FAILED Error "+TRANSFORM(tnError)+": "+TRANSFORM(tcMessage)+CHR(13)+CHR(10)+;
        "Code: "+TRANSFORM(tcCode)+CHR(13)+CHR(10)+"Program: "+TRANSFORM(tcProgram)+;
        " line "+TRANSFORM(tnLine)+CHR(13)+CHR(10),tcLog,0)
    ON ERROR
    QUIT
ENDPROC
