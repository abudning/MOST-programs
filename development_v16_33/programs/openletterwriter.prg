LPARAMETERS tnPatientId, toPatientForm, toClaimForm
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
        TRY
            loLetterForm.ZOrder(0)
        CATCH
        ENDTRY
        IF PCOUNT()>=3 AND VARTYPE(toClaimForm)=="O" AND VARTYPE(toPatientForm)=="O"
            lnLeft=MAX(toPatientForm.Left+toPatientForm.Width+4,toClaimForm.Left)
            lnTop=toClaimForm.Top+toClaimForm.Height+4
            loLetterForm.Left=MAX(0,MIN(lnLeft,_SCREEN.Width-loLetterForm.Width))
            loLetterForm.Top=MAX(0,MIN(lnTop,_SCREEN.Height-loLetterForm.Height))
        ENDIF
        FOR lnRow=1 TO loLetterForm.pageframe1.page1.MD.ListCount
            IF ALLTRIM(loLetterForm.pageframe1.page1.MD.List(lnRow,1))=="AB"
                loLetterForm.pageframe1.page1.MD.ListIndex=lnRow
                EXIT
            ENDIF
        ENDFOR
        loLetterForm.pageframe1.page1.MD.Click()
        IF llHasPatient AND lnOpenPatient#lnPatientId
            loLetterForm.pageframe1.page1.id.Click()
            loLetterForm.pageframe1.page1.search.Value=ALLTRIM(STR(lnPatientId))
            loLetterForm.pageframe1.page1.search.SetFocus()
            KEYBOARD "{ENTER}"
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
IF VARTYPE(loNewLetterForm)=="O"
    FOR lnRow=1 TO loNewLetterForm.pageframe1.page1.MD.ListCount
        IF ALLTRIM(loNewLetterForm.pageframe1.page1.MD.List(lnRow,1))==ALLTRIM(lcSelectedMd)
            loNewLetterForm.pageframe1.page1.MD.ListIndex=lnRow
            EXIT
        ENDIF
    ENDFOR
    loNewLetterForm.pageframe1.page1.MD.Click()
    IF llHasPatient
        loNewLetterForm.pageframe1.page1.id.Click()
        loNewLetterForm.pageframe1.page1.search.Value=ALLTRIM(STR(lnPatientId))
        loNewLetterForm.pageframe1.page1.search.SetFocus()
        KEYBOARD "{ENTER}"
    ENDIF
ENDIF
IF VARTYPE(loNewLetterForm)=="O"
    IF PCOUNT()>=3 AND VARTYPE(toClaimForm)=="O"
        lnLeft=MAX(toPatientForm.Left+toPatientForm.Width+4,toClaimForm.Left)
        lnTop=toClaimForm.Top+toClaimForm.Height+4
        lnLeft=MAX(0,MIN(lnLeft,_SCREEN.Width-loNewLetterForm.Width))
        lnTop=MAX(0,MIN(lnTop,_SCREEN.Height-loNewLetterForm.Height))
        loNewLetterForm.Left=lnLeft
        loNewLetterForm.Top=lnTop
    ELSE
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
    ENDIF
    loNewLetterForm.WindowState=0
    loNewLetterForm.Show()
ENDIF