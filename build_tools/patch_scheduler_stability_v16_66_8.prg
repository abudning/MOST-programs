LPARAMETERS tcSourceRoot
LOCAL lcRoot
lcRoot = ADDBS(FULLPATH(tcSourceRoot))
SET SAFETY OFF
SET EXCLUSIVE ON
SET TALK OFF

=PatchScheduleForm(lcRoot + "FORMS\schedule.scx")
=PatchScheduleForm(lcRoot + "FORMS\schedule_addNew.scx")
RETURN

FUNCTION PatchScheduleForm
LPARAMETERS tcForm
LOCAL lcMethods, lcProperties, lnChanged

IF !FILE(tcForm)
    ERROR "Scheduler form not found: " + tcForm
ENDIF

USE (tcForm) EXCLUSIVE ALIAS patchschedule
lnChanged = 0

SCAN FOR !DELETED()
    lcMethods = patchschedule.methods
    lcProperties = patchschedule.properties

    * The form code assigns this object after a schedule click. Older forms did
    * not define it, producing error 1925 and leaving later actions half-complete.
    IF LOWER(ALLTRIM(patchschedule.objname)) == "scheduleform" AND ;
            !("getschedule_item" $ LOWER(lcProperties))
        lcProperties = lcProperties + IIF(EMPTY(lcProperties), "", CHR(13)+CHR(10)) + ;
            "getSchedule_item = .NULL." + CHR(13)+CHR(10)
        REPLACE properties WITH lcProperties IN patchschedule
        lnChanged = lnChanged + 1
    ENDIF

    * Numeric and health-card searches must verify an exact index hit. EOF()
    * alone can accept the next indexed patient when a seek does not match.
    IF "seek val(this.value)" $ LOWER(lcMethods)
        lcMethods = STRTRAN(lcMethods, ;
            "            seek val(this.value)" + CHR(13)+CHR(10) + ;
            "            if eof()", ;
            "            seek val(this.value)" + CHR(13)+CHR(10) + ;
            "            if !found() .or. patients.id # val(this.value)", 1, -1, 1)
        lcMethods = STRTRAN(lcMethods, ;
            "            seek alltrim(this.value)" + CHR(13)+CHR(10) + ;
            "            if eof()", ;
            "            seek alltrim(this.value)" + CHR(13)+CHR(10) + ;
            "            if !found() .or. alltrim(patients.healthnum) # alltrim(this.value)", 1, -1, 1)
    ENDIF

    * Switching a grid from a temporary table back to PATIENTS can recreate its
    * columns. Restore the expected shape before assigning ControlSource values.
    IF "PROCEDURE selection" $ lcMethods
        lcMethods = STRTRAN(lcMethods, ;
            'THISFORM.functionframe.apptpage.grid1.RECORDSOURCE="patients"', ;
            'THISFORM.functionframe.apptpage.grid1.RECORDSOURCE="patients"' + CHR(13)+CHR(10) + ;
            "        THISFORM.functionframe.apptpage.grid1.ColumnCount=17", 1, -1, 1)
        lcMethods = STRTRAN(lcMethods, ;
            'THISFORM.functionframe.findPage.grid2.RECORDSOURCE="patients"', ;
            'THISFORM.functionframe.findPage.grid2.RECORDSOURCE="patients"' + CHR(13)+CHR(10) + ;
            "        THISFORM.functionframe.findPage.grid2.ColumnCount=17", 1, -1, 1)
        lcMethods = STRTRAN(lcMethods, ;
            CHR(9)+"SELE (THISFORM.ALIAS)" + CHR(13)+CHR(10) + ;
            CHR(9)+"m_id=ID", ;
            CHR(9)+"IF EMPTY(THISFORM.ALIAS) OR !USED(THISFORM.ALIAS)" + CHR(13)+CHR(10) + ;
            CHR(9)+CHR(9)+"MESSAGEBOX('The patient search result is no longer available. Please search again.',48,'MOSt Scheduler')" + CHR(13)+CHR(10) + ;
            CHR(9)+CHR(9)+"RETURN" + CHR(13)+CHR(10) + ;
            CHR(9)+"ENDIF" + CHR(13)+CHR(10) + ;
            CHR(9)+"SELE (THISFORM.ALIAS)" + CHR(13)+CHR(10) + ;
            CHR(9)+"m_id=ID", 1, -1, 1)
    ENDIF

    * Do not feed an empty/corrupt appointment date into the XP DTPicker.
    IF "procedure aselection" $ LOWER(lcMethods) AND ;
            !("selected appointment has no valid date" $ LOWER(lcMethods))
        lcMethods = STRTRAN(lcMethods, ;
            CHR(9)+"xkeep_APPTID=apptid", ;
            CHR(9)+"xkeep_APPTID=apptid" + CHR(13)+CHR(10) + ;
            CHR(9)+"IF VARTYPE(xkeep_DATE)#'T' OR EMPTY(xkeep_DATE)" + CHR(13)+CHR(10) + ;
            CHR(9)+CHR(9)+"THISFORM.refresh_enabled = .T." + CHR(13)+CHR(10) + ;
            CHR(9)+CHR(9)+"MESSAGEBOX('The selected appointment has no valid date and cannot be opened.',48,'MOSt Scheduler')" + CHR(13)+CHR(10) + ;
            CHR(9)+CHR(9)+"RETURN" + CHR(13)+CHR(10) + ;
            CHR(9)+"ENDIF", 1, -1, 1)
    ENDIF

    IF lcMethods # patchschedule.methods
        REPLACE methods WITH lcMethods IN patchschedule
        lnChanged = lnChanged + 1
    ENDIF
ENDSCAN

USE IN patchschedule
* Idempotent: a form that already contains every applicable repair is valid.
RETURN lnChanged
ENDFUNC
