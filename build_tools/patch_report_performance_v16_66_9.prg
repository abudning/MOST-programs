LPARAMETERS tcDailyScx,tcCheckinScx
LOCAL lcMethods,lnDaily,lnCheckin,lcNeedle,lcReplacement

USE (FULLPATH(tcDailyScx)) EXCLUSIVE IN 0 ALIAS patchdaily
SELECT patchdaily
LOCATE FOR "PROCEDURE selection" $ methods
IF !FOUND()
    ERROR "Daily Summary selection method was not found."
ENDIF
lcMethods=methods
lnDaily=0
lnDaily=lnDaily+OCCURS("SELE claims->ID,claims->accounting",lcMethods)
lcMethods=STRTRAN(lcMethods,"SELE claims->ID,claims->accounting",;
    "SELE patients->surname,patients->firstname,claims->ID,claims->accounting",1,-1,0)
lnDaily=lnDaily+OCCURS("SELE submited->ID,submited->accounting",lcMethods)
lcMethods=STRTRAN(lcMethods,"SELE submited->ID,submited->accounting",;
    "SELE patients->surname,patients->firstname,submited->ID,submited->accounting",1,-1,0)
lnDaily=lnDaily+OCCURS("claims->STATUS FROM claims WHERE ;",lcMethods)
lcMethods=STRTRAN(lcMethods,"claims->STATUS FROM claims WHERE ;",;
    "claims->STATUS FROM claims LEFT OUTER JOIN patients ON claims->ID=patients->ID WHERE ;",1,-1,0)
lnDaily=lnDaily+OCCURS("submited->STATUS FROM submited WHERE ;",lcMethods)
lcMethods=STRTRAN(lcMethods,"submited->STATUS FROM submited WHERE ;",;
    "submited->STATUS FROM submited LEFT OUTER JOIN patients ON submited->ID=patients->ID WHERE ;",1,-1,0)

LOCAL lcOldPatientLoop,lcNewPatientLoop
lcOldPatientLoop="SELE patients"+CHR(13)+CHR(10)+;
    "SET ORDER TO TAG ID"+CHR(13)+CHR(10)+;
    "SELE daily"+CHR(13)+CHR(10)+;
    "SET RELA TO ID INTO patients"+CHR(13)+CHR(10)+;
    "SCAN ALL"+CHR(13)+CHR(10)+;
    CHR(9)+"SELE patients"+CHR(13)+CHR(10)+;
    CHR(9)+"IF !EOF()"+CHR(13)+CHR(10)+;
    CHR(9)+CHR(9)+"REPL daily.surname WITH patients.surname"+CHR(13)+CHR(10)+;
    CHR(9)+CHR(9)+"REPL daily.firstname WITH patients.firstname"+CHR(13)+CHR(10)+;
    CHR(9)+"ENDIF"+CHR(13)+CHR(10)+;
    CHR(9)+"SELE daily"+CHR(13)+CHR(10)+;
    "ENDSCAN"+CHR(13)+CHR(10)+;
    "SET RELA TO"+CHR(13)+CHR(10)+;
    "GO TOP"
lcNewPatientLoop="* Patient names are already joined into the date-filtered local cursor."+CHR(13)+CHR(10)+;
    "SELE daily"+CHR(13)+CHR(10)+"GO TOP"
IF lcOldPatientLoop $ lcMethods
    lcMethods=STRTRAN(lcMethods,lcOldPatientLoop,lcNewPatientLoop,1,1,0)
    lnDaily=lnDaily+1
ENDIF
IF lnDaily#9
    ERROR "Daily Summary patch count was "+TRANSFORM(lnDaily)+" instead of 9."
ENDIF
REPLACE methods WITH lcMethods
USE IN patchdaily

USE (FULLPATH(tcCheckinScx)) EXCLUSIVE IN 0 ALIAS patchcheckin
SELECT patchcheckin
LOCATE FOR "PROCEDURE selection" $ methods
IF !FOUND()
    ERROR "Check-In selection method was not found."
ENDIF
lcMethods=methods
lnCheckin=0
IF "DTOS(CHECKIN.DATE) >= strCheckdate1" $ lcMethods
    lcMethods=STRTRAN(lcMethods,"DTOS(CHECKIN.DATE) >= strCheckdate1",;
        "CHECKIN.DATE >= strCheckdate3",1,1,0)
    lnCheckin=lnCheckin+1
ENDIF
IF "DTOS(CHECKIN.DATE) <= strCheckdate2" $ lcMethods
    lcMethods=STRTRAN(lcMethods,"DTOS(CHECKIN.DATE) <= strCheckdate2",;
        "CHECKIN.DATE <= strCheckdate4",1,1,0)
    lnCheckin=lnCheckin+1
ENDIF
lcNeedle="FROM claims) AND ;"
lcReplacement="FROM claims WHERE claims.serv_date >= strCheckdate3 .AND. "+;
    "claims.serv_date <= strCheckdate4) AND ;"
IF lcNeedle $ lcMethods
    lcMethods=STRTRAN(lcMethods,lcNeedle,lcReplacement,1,1,0)
    lnCheckin=lnCheckin+1
ENDIF
IF lnCheckin#3
    ERROR "Check-In patch count was "+TRANSFORM(lnCheckin)+" instead of 3."
ENDIF
REPLACE methods WITH lcMethods
USE IN patchcheckin
RETURN
