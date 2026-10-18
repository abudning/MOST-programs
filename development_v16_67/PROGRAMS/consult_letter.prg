FUNCTION PrepareConsult
LPARAMETERS toForm
LOCAL loWord,loChart,loTimer,lcChartText,lcConsultText,lnVision,loError
LOCAL llWordAvailable,llPrepared

loWord=.NULL.
llWordAvailable=.F.
llPrepared=.F.
TRY
    loWord=GETOBJECT(,"Word.Application")
    llWordAvailable=VARTYPE(loWord)=="O"
CATCH
ENDTRY
IF !llWordAvailable
    MESSAGEBOX("Open the patient's chart in Word before preparing the consult.",48,"Consult")
    RETURN .F.
ENDIF

IF loWord.Documents.Count#1
    MESSAGEBOX("The patient chart must be the only Word document open before preparing the consult.",48,"Consult")
    RETURN .F.
ENDIF

TRY
    loChart=loWord.Documents.Item(1)
    lcChartText=loChart.Content.Text
    lnVision=RAT("VISION:",UPPER(lcChartText))
    IF lnVision=0
        lnVision=RAT("VISION",UPPER(lcChartText))
    ENDIF
    IF lnVision>0
        * Keep the latest examination entry, beginning with its final Vision heading.
        lcConsultText=SUBSTR(lcChartText,lnVision)
        lcConsultText=STRTRAN(lcConsultText,CHR(7),"")

        * Own the watcher at application level so LetterBuilder's New action
        * cannot discard it while refreshing its form state.
        IF PEMSTATUS(_SCREEN,"ConsultMergeTimer",5)
            _SCREEN.ConsultMergeTimer.Enabled=.F.
            REMOVEPROPERTY(_SCREEN,"ConsultMergeTimer")
        ENDIF

        loTimer=NEWOBJECT("ConsultMergeTimer","consult_letter.prg")
        loTimer.TargetForm=toForm
        loTimer.WordApp=loWord
        loTimer.ChartDocument=loChart
        loTimer.ChartName=loChart.FullName
        loTimer.InitialDocumentCount=loWord.Documents.Count
        loTimer.ConsultText=lcConsultText
        ADDPROPERTY(_SCREEN,"ConsultMergeTimer",loTimer)
        _SCREEN.ConsultMergeTimer.Enabled=.T.
        llPrepared=.T.
    ENDIF
CATCH TO loError
    MESSAGEBOX("The consultation information could not be prepared."+CHR(13)+loError.Message,16,"Consult")
ENDTRY
IF llPrepared
    MESSAGEBOX("Consult information is prepared."+CHR(13)+CHR(13)+;
        "Click New, choose the template, confirm the referring source, and click Word.",;
        64,"Consult")
ELSE
    IF lnVision=0
        MESSAGEBOX("The patient's chart does not contain a Vision section.",48,"Consult")
    ENDIF
ENDIF
RETURN llPrepared
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
        LOCAL loNew,loRange,loFind,lnDoc,lnAnswer,llFound,loError,llReenable,lcCandidateName
        THIS.Enabled=.F.
        llReenable=.F.
        TRY
            IF VARTYPE(THIS.WordApp)#"O" OR THIS.WordApp.Documents.Count=0
                llReenable=.T.
            ELSE
                * LetterBuilder closes the sole patient chart and opens the
                * merged consultation, so the document count can remain one.
                * Select the first open document whose full name differs from
                * the chart captured at preparation time.
                loNew=.NULL.
                FOR lnDoc=1 TO THIS.WordApp.Documents.Count
                    lcCandidateName=THIS.WordApp.Documents.Item(lnDoc).FullName
                    IF UPPER(ALLTRIM(lcCandidateName))#UPPER(ALLTRIM(THIS.ChartName))
                        loNew=THIS.WordApp.Documents.Item(lnDoc)
                        EXIT
                    ENDIF
                ENDFOR
                IF VARTYPE(loNew)=="O"
                    loNew.Activate()
                    THIS.WordApp.Visible=.T.
                    lnAnswer=MESSAGEBOX("Insert the prepared consultation information into this merged document?",4+32,"Consult")
                    IF lnAnswer=6
                        * Find the marker again after confirmation and replace only that marker.
                        loRange=loNew.Content.Duplicate
                        loFind=loRange.Find
                        loFind.ClearFormatting()
                        loFind.Text="*"
                        loFind.Forward=.T.
                        loFind.Wrap=0
                        llFound=loFind.Execute()
                        IF llFound
                            loRange.Text=THIS.ConsultText
                            loNew.Activate()
                            THIS.WordApp.Visible=.T.
                            THIS.ConsultText=""
                        ELSE
                            MESSAGEBOX("The consultation marker (*) is no longer present. No text was inserted.",48,"Consult")
                        ENDIF
                    ENDIF
                ELSE
                    llReenable=.T.
                ENDIF
            ENDIF
        CATCH TO loError
            MESSAGEBOX("The prepared consultation information could not be inserted."+CHR(13)+loError.Message,16,"Consult")
        ENDTRY
        IF llReenable
            THIS.Enabled=.T.
        ENDIF
    ENDPROC
ENDDEFINE
