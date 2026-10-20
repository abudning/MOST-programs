DEFINE CLASS LetterPatientReloadTimer AS Timer
    Interval=100
    Enabled=.F.
    TargetForm=.NULL.
    PatientId=""
    SavedLeft=0
    SavedTop=0
    SavedState=0

    PROCEDURE Timer
        LOCAL loForm
        THIS.Enabled=.F.
        loForm=THIS.TargetForm
        IF VARTYPE(loForm)#"O"
            RETURN
        ENDIF

        * Complete the legacy second patient load directly after one UI cycle.
        loForm.pageframe1.page1.id.Click()
        loForm.pageframe1.page1.search.Value=THIS.PatientId
        loForm.pageframe1.page1.search.SetFocus()
        loForm.pageframe1.page1.search.Valid()
        loForm.Update()
        loForm.onemd_letterlist()
        loForm.pageframe1.page1.letter_name.SetFocus()
        IF loForm.pageframe1.page1.list_letters.ListCount>0
            loForm.pageframe1.page1.list_letters.Selected(1)=.T.
            loForm.pageframe1.page1.list_letters.Click()
        ENDIF
        loForm.pageframe1.page1.list_letters.Refresh()
        loForm.Refresh()

        loForm.WindowState=THIS.SavedState
        IF THIS.SavedState=0
            loForm.Left=THIS.SavedLeft
            loForm.Top=THIS.SavedTop
        ENDIF
    ENDPROC
ENDDEFINE
