FUNCTION CreateConsultLetter
LOCAL lcTemplate,loWord,loChart,loNew,loFind,lcVision,lcText,lnAt,loError,loForm,lcMarker,lnStart,lnEnd
lcTemplate=""
TRY
    loForm=THISFORM
    lcTemplate=ALLTRIM(TRANSFORM(loForm.pageframe1.page1.file_name.Value))
CATCH
ENDTRY
IF EMPTY(lcTemplate)
    TRY
        IF USED("letterlist") AND !EMPTY(ALLTRIM(loForm.pageframe1.page1.letter_name.Value))
            SELECT letterlist
            LOCATE FOR !DELETED() AND UPPER(ALLTRIM(lettername))==UPPER(ALLTRIM(loForm.pageframe1.page1.letter_name.Value)) AND !EMPTY(ALLTRIM(location))
            IF FOUND()
                lcTemplate=ALLTRIM(letterlist.location)
            ENDIF
        ENDIF
    CATCH
    ENDTRY
ENDIF
IF EMPTY(lcTemplate) OR !FILE(lcTemplate)
    MESSAGEBOX("Choose a letter template first, then click Create Consult.",48,"Consult Letter")
    RETURN .F.
ENDIF
IF EMPTY(lcTemplate)
    RETURN .F.
ENDIF
TRY
    loWord=GETOBJECT(,"Word.Application")
    IF loWord.Documents.Count=0
        MESSAGEBOX("Open the patient's chart in Word before creating a consult letter.",48,"Consult Letter")
        RETURN .F.
    ENDIF
    loChart=loWord.ActiveDocument
    lcText=loChart.Content.Text
    lnAt=RAT("VISION",UPPER(lcText))
    IF lnAt=0
        lnAt=RAT("REFRACTION",UPPER(lcText))
    ENDIF
    IF lnAt=0
        MESSAGEBOX("No recent vision-to-plan, vision, or refraction section was found in the open patient chart.",48,"Consult Letter")
        RETURN .F.
    ENDIF
    lcVision=SUBSTR(lcText,lnAt)
    IF CHR(13)$lcVision
        lcVision=LEFT(lcVision,AT(CHR(13),lcVision)-1)
    ENDIF
    loNew=loWord.Documents.Add(lcTemplate)
    loFind=loNew.Content.Find
    loFind.Text="On examination"
    loFind.Forward=.T.
    loFind.Wrap=0
    IF loFind.Execute()
        loNew.Range(loFind.Parent.End,loFind.Parent.End).InsertAfter(CHR(13)+lcVision+CHR(13))
    ELSE
        loNew.Content.InsertAfter(CHR(13)+"On examination"+CHR(13)+lcVision+CHR(13))
    ENDIF
    loWord.Visible=.T.
    RETURN .T.
CATCH TO loError
    MESSAGEBOX("The consult letter could not be created."+CHR(13)+loError.Message,16,"Consult Letter")
    RETURN .F.
ENDTRY
ENDFUNC

DEFINE CLASS ConsultButton AS CommandButton
    Caption="Create Consult"
    Width=82
    Height=21
    FontSize=8
    PROCEDURE Click
        =CreateConsultLetter()
    ENDPROC
ENDDEFINE





