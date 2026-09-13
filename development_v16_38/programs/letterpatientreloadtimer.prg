DEFINE CLASS LetterPatientReloadTimer AS Timer
    Interval=400
    Enabled=.F.
    TargetForm=.NULL.
    PatientId=""
    SavedLeft=0
    SavedTop=0
    SavedState=0
    Phase=1

    PROCEDURE Timer
        LOCAL loForm
        THIS.Enabled=.F.
        loForm=THIS.TargetForm
        IF VARTYPE(loForm)#"O"
            RETURN
        ENDIF
        IF THIS.Phase=1
            loForm.pageframe1.page1.id.Click()
            loForm.pageframe1.page1.search.Value=THIS.PatientId
            loForm.pageframe1.page1.search.SetFocus()
            loForm.pageframe1.page1.search.Valid()
            * Build the existing-letter list directly; do not depend on focus events.
            loForm.onemd_letterlist()
            loForm.pageframe1.page1.list_letters.Refresh()
            loForm.Refresh()
            THIS.Phase=2
            THIS.Interval=500
            THIS.Enabled=.T.
        ELSE
            loForm.WindowState=THIS.SavedState
            IF THIS.SavedState=0
                loForm.Left=THIS.SavedLeft
                loForm.Top=THIS.SavedTop
            ENDIF
            THIS.Enabled=.F.
        ENDIF
    ENDPROC
ENDDEFINE