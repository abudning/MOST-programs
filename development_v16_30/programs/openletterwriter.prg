LPARAMETERS tnPatientId
LOCAL llHasPatient, lnPatientId, lnI, loLetterForm, loNewLetterForm, lnOpenPatient
llHasPatient=.F.
lnPatientId=0
IF PCOUNT()>=1 AND VARTYPE(tnPatientId)$"NIFYB"
    lnPatientId=INT(tnPatientId)
    llHasPatient=lnPatientId>0
ENDIF
FOR lnI=1 TO _SCREEN.FormCount
    loLetterForm=_SCREEN.Forms(lnI)
    IF UPPER(ALLTRIM(loLetterForm.Caption))=="LETTER BUILDER"
        lnOpenPatient=0
        TRY
            lnOpenPatient=VAL(TRANSFORM(loLetterForm.pageframe1.page1.patient_id.Value))
        CATCH
            lnOpenPatient=0
        ENDTRY
        loLetterForm.WindowState=0
        loLetterForm.Show()
        loLetterForm.SetFocus()
        IF llHasPatient AND lnOpenPatient#0 AND lnOpenPatient#lnPatientId
            MESSAGEBOX("LetterBuilder is already open for another patient."+CHR(13)+"Close it before opening letters for the current patient.",48,"MOSt - One LetterBuilder at a Time")
        ELSE
            MESSAGEBOX("LetterBuilder is already open.",64,"MOSt - One LetterBuilder at a Time")
        ENDIF
        RETURN
    ENDIF
ENDFOR
IF llHasPatient
    IF !USED("patients")
        MESSAGEBOX("The patient file is not available.",48,"MOSt - LetterBuilder")
        RETURN
    ENDIF
    SELECT patients
    LOCATE FOR patients.id=lnPatientId
    IF !FOUND()
        MESSAGEBOX("The selected patient could not be found.",48,"MOSt - LetterBuilder")
        RETURN
    ENDIF
ENDIF
* Open the LetterBuilder form only. No letter is opened or created here.
DO FORM letterform NAME loNewLetterForm
IF llHasPatient AND VARTYPE(loNewLetterForm)=="O"
    SELECT patients
    LOCATE FOR patients.id=lnPatientId
    IF FOUND()
        loNewLetterForm.Update()
    ENDIF
ENDIF
IF VARTYPE(loNewLetterForm)=="O"
    loNewLetterForm.WindowState=0
    loNewLetterForm.Show()
    loNewLetterForm.SetFocus()
ENDIF