LPARAMETERS tcMostRoot

LOCAL lcMost, lcForm, lcName, lnControl, lcProperties
LOCAL ARRAY laHide[3]
lcMost=ADDBS(FULLPATH(tcMostRoot))
lcForm=lcMost+"FORMS\patients.scx"
laHide[1]="claims"
laHide[2]="letters"
laHide[3]="letter_list"

IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm,"sct"))
    ERROR "Patients form source is missing."
ENDIF

USE (lcForm) EXCLUSIVE ALIAS patients686
FOR lnControl=1 TO ALEN(laHide,1)
    lcName=laHide[lnControl]
    LOCATE FOR LOWER(ALLTRIM(objname))==lcName
    IF !FOUND()
        USE IN patients686
        ERROR "Patients control "+lcName+" was not found."
    ENDIF
    lcProperties=patients686.properties
    IF !("Visible = .F." $ lcProperties)
        IF "Visible = .T." $ lcProperties
            lcProperties=STRTRAN(lcProperties,"Visible = .T.","Visible = .F.",1,1,1)
        ELSE
            lcProperties=lcProperties+IIF(RIGHT(lcProperties,2)==CHR(13)+CHR(10),"",CHR(13)+CHR(10))+"Visible = .F."+CHR(13)+CHR(10)
        ENDIF
        REPLACE properties WITH lcProperties IN patients686
    ENDIF
ENDFOR
USE IN patients686
