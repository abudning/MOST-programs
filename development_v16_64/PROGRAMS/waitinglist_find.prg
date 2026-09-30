LPARAMETERS tcWaitingApptId

* Open the Scheduler's existing Find Appointment results for the patient whose
* waiting-list item was clicked.  This routine is deliberately read-only.
LOCAL lcApptId, lnOldArea, lnOldRec, lnPatientId, lcNewPatient
LOCAL loScheduler, loCandidate, loFindPage, lnForm

lcApptId = ALLTRIM(TRANSFORM(tcWaitingApptId))
IF EMPTY(lcApptId) OR !USED("appointments")
    RETURN .F.
ENDIF

lnOldArea = SELECT()
SELECT appointments
lnOldRec = IIF(EOF() OR BOF(), 0, RECNO())
LOCATE FOR ALLTRIM(appointments.apptid) == lcApptId
IF !FOUND()
    SELECT (lnOldArea)
    RETURN .F.
ENDIF

lnPatientId = IIF(ISNULL(appointments.ID), 0, appointments.ID)
lcNewPatient = IIF(ISNULL(appointments.newpatient), "", appointments.newpatient)
IF lnOldRec > 0 AND lnOldRec <= RECCOUNT("appointments")
    GO lnOldRec IN appointments
ENDIF
SELECT (lnOldArea)

* The Waiting List is a separate top-level form, so find its visible Scheduler.
loScheduler = .NULL.
FOR lnForm = 1 TO _SCREEN.FormCount
    loCandidate = _SCREEN.Forms(lnForm)
    IF PEMSTATUS(loCandidate, "functionframe", 5) AND ;
            PEMSTATUS(loCandidate, "btnfind", 5) AND loCandidate.Visible
        loScheduler = loCandidate
        IF loCandidate.WindowState # 1
            EXIT
        ENDIF
    ENDIF
ENDFOR
IF VARTYPE(loScheduler) # "O" OR ISNULL(loScheduler)
    RETURN .F.
ENDIF

loScheduler.btnfind.Click()
loFindPage = loScheduler.functionframe.findpage

IF lnPatientId > 0
    loFindPage.lbl_newp.Visible = .F.
    loFindPage.search.Value = ALLTRIM(STR(lnPatientId))
    loFindPage.search.Valid()
    loFindPage.id_find.Click()
    RETURN .T.
ENDIF

* Unregistered patients are stored as surname C(20), firstname C(15), phone
* C(10).  Re-create the label layout already consumed by id_find.Click().
IF !EMPTY(ALLTRIM(lcNewPatient))
    loFindPage.search.Value = ""
    loFindPage.lbl_newp.Caption = ;
        PADR(ALLTRIM(SUBSTR(lcNewPatient, 1, 20)), 25) + ;
        PADR(ALLTRIM(SUBSTR(lcNewPatient, 21, 15)), 20) + ;
        ALLTRIM(SUBSTR(lcNewPatient, 36, 10))
    loFindPage.lbl_newp.Visible = .T.
    loFindPage.id_find.Click()
    RETURN .T.
ENDIF

RETURN .F.
