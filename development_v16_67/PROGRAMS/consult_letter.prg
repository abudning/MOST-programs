FUNCTION PrepareConsult
LPARAMETERS toForm
LOCAL loWord,loChart,loTimer,lcChartText,lcConsultText,lnVision,loError

TRY
    loWord=GETOBJECT(,"Word.Application")
CATCH
    MESSAGEBOX("Open the patient's chart in Word before preparing the consult.",48,"Consult")
    RETURN .F.
ENDTRY

IF loWord.Documents.Count#1
    MESSAGEBOX("The patient chart must be the only Word document open before preparing the consult.",48,"Consult")
    RETURN .F.
ENDIF

TRY
    loChart=loWord.Documents.Item(1)
    lcChartText=loChart.Content.Text
    lnVision=RAT("VISION:",UPPER(lcChartText))
    IF lnVision=0
        MESSAGEBOX("The patient's chart does not contain a Vision: section.",48,"Consult")
        RETURN .F.
    ENDIF

    * Keep the latest examination entry, beginning with its final Vision: heading.
    lcConsultText=SUBSTR(lcChartText,lnVision)
    lcConsultText=STRTRAN(lcConsultText,CHR(7),"")

    IF PEMSTATUS(toForm,"ConsultMergeTimer",5)
        TRY
            toForm.ConsultMergeTimer.Enabled=.F.
        CATCH
        ENDTRY
        REMOVEPROPERTY(toForm,"ConsultMergeTimer")
    ENDIF

    loTimer=NEWOBJECT("ConsultMergeTimer","consult_letter.prg")
    loTimer.TargetForm=toForm
    loTimer.WordApp=loWord
    loTimer.ChartDocument=loChart
    loTimer.ChartName=loChart.FullName
    loTimer.InitialDocumentCount=loWord.Documents.Count
    loTimer.ConsultText=lcConsultText
    ADDPROPERTY(toForm,"ConsultMergeTimer",loTimer)
    toForm.ConsultMergeTimer.Enabled=.T.

    MESSAGEBOX("Consult information is prepared."+CHR(13)+CHR(13)+;
        "Click New, choose the template, confirm the referring source, and click Word.",;
        64,"Consult")
    RETURN .T.
CATCH TO loError
    MESSAGEBOX("The consultation information could not be prepared."+CHR(13)+loError.Message,16,"Consult")
ENDTRY
RETURN .F.
ENDFUNC

DEFINE CLASS ConsultButton AS CommandButton
    Caption="Consult"
    Width=55
    Height=21
    FontSize=8
    PROCEDURE Click
        =PrepareConsult(THISFORM)
    ENDPROC
ENDDEFINE

DEFINE CLASS ConsultMergeTimer AS Timer
    Interval=250
    Enabled=.F.
    TargetForm=.NULL.
    WordApp=.NULL.
    ChartDocument=.NULL.
    ChartName=""
    InitialDocumentCount=0
    ConsultText=""
    NewDocumentTicks=0

    PROCEDURE Timer
        LOCAL loNew,loRange,loFind,lnDoc,lnAnswer,llFound,loError
        THIS.Enabled=.F.
        TRY
            IF VARTYPE(THIS.WordApp)#"O" OR THIS.WordApp.Documents.Count<=THIS.InitialDocumentCount
                THIS.Enabled=.T.
                RETURN
            ENDIF

            loNew=.NULL.
            FOR lnDoc=THIS.InitialDocumentCount+1 TO THIS.WordApp.Documents.Count
                loRange=THIS.WordApp.Documents.Item(lnDoc).Content.Duplicate
                loFind=loRange.Find
                loFind.ClearFormatting()
                loFind.Text="*"
                loFind.Forward=.T.
                loFind.Wrap=0
                IF loFind.Execute()
                    loNew=THIS.WordApp.Documents.Item(lnDoc)
                    EXIT
                ENDIF
            ENDFOR

            IF VARTYPE(loNew)#"O"
                THIS.NewDocumentTicks=THIS.NewDocumentTicks+1
                IF THIS.NewDocumentTicks<40
                    THIS.Enabled=.T.
                    RETURN
                ENDIF
                MESSAGEBOX("The merged document opened, but its consultation insertion marker (*) was not found. No text was inserted.",48,"Consult")
                RETURN
            ENDIF

            loNew.Activate()
            THIS.WordApp.Visible=.T.
            lnAnswer=MESSAGEBOX("Insert the prepared consultation information into this merged document?",4+32,"Consult")
            IF lnAnswer#6
                RETURN
            ENDIF

            * Find the marker again after confirmation and replace only that marker.
            loRange=loNew.Content.Duplicate
            loFind=loRange.Find
            loFind.ClearFormatting()
            loFind.Text="*"
            loFind.Forward=.T.
            loFind.Wrap=0
            llFound=loFind.Execute()
            IF !llFound
                MESSAGEBOX("The consultation marker (*) is no longer present. No text was inserted.",48,"Consult")
                RETURN
            ENDIF
            loRange.Text=THIS.ConsultText
            loNew.Activate()
            THIS.WordApp.Visible=.T.
            THIS.ConsultText=""
        CATCH TO loError
            MESSAGEBOX("The prepared consultation information could not be inserted."+CHR(13)+loError.Message,16,"Consult")
        ENDTRY
    ENDPROC
ENDDEFINE
