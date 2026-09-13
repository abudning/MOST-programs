LPARAMETERS tnPatientId, toPatientForm
LOCAL llHasPatient, lnPatientId, lnI, loLetterForm, loNewLetterForm, lnOpenPatient
LOCAL lcSelectedMd, lnRow, lnTop, lnLeft
llHasPatient=.F.
lnPatientId=0
lcSelectedMd="AB"
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
    FOR lnRow=1 TO loNewLetterForm.pageframe1.page1.MD.ListCount
        IF ALLTRIM(loNewLetterForm.pageframe1.page1.MD.List(lnRow,1))==ALLTRIM(lcSelectedMd)
            loNewLetterForm.pageframe1.page1.MD.ListIndex=lnRow
            EXIT
        ENDIF
    ENDFOR
    SELECT patients
    LOCATE FOR patients.id=lnPatientId
    IF FOUND()
        loNewLetterForm.Update()
    ENDIF
ENDIF
IF VARTYPE(loNewLetterForm)=="O"
    IF PCOUNT()>=2 AND VARTYPE(toPatientForm)=="O"
        IF toPatientForm.Top+toPatientForm.Height+4+loNewLetterForm.Height<=_SCREEN.Height
            lnLeft=MAX(0,MIN(toPatientForm.Left,_SCREEN.Width-loNewLetterForm.Width))
            lnTop=toPatientForm.Top+toPatientForm.Height+4
        ELSE
            lnLeft=toPatientForm.Left+toPatientForm.Width+4
            lnTop=MAX(0,MIN(toPatientForm.Top,_SCREEN.Height-loNewLetterForm.Height))
            IF lnLeft+loNewLetterForm.Width>_SCREEN.Width
                lnLeft=MAX(0,_SCREEN.Width-loNewLetterForm.Width)
            ENDIF
        ENDIF
        loNewLetterForm.Left=lnLeft
        loNewLetterForm.Top=lnTop
    ENDIF
    loNewLetterForm.WindowState=0
    loNewLetterForm.Show()
ENDIF