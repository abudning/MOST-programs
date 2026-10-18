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

FUNCTION ConfirmConsultInsert
LPARAMETERS toWord
RETURN WordOwnedConsultMessage(toWord,;
    "Insert the prepared consultation information into this merged document?",;
    4+32)
ENDFUNC

FUNCTION WordOwnedConsultMessage
LPARAMETERS toWord,tcText,tnType
LOCAL lnWordHwnd,lnAnswer
lnWordHwnd=0
lnAnswer=0
TRY
    lnWordHwnd=toWord.Hwnd
    DECLARE INTEGER MessageBox IN user32.dll AS ConsultMessageBox ;
        INTEGER hWnd, STRING lpText, STRING lpCaption, INTEGER uType
    * Own every workflow message with Word and keep the merged document in front.
    lnAnswer=ConsultMessageBox(lnWordHwnd,tcText,"Consult",tnType+65536+262144)
CATCH
    * Retain a safe fallback on older Word versions that do not expose Hwnd.
    lnAnswer=MESSAGEBOX(tcText,tnType+4096,"Consult")
ENDTRY
RETURN lnAnswer
ENDFUNC

FUNCTION FindConsultMarkerInRange
LPARAMETERS toSourceRange
LOCAL loRange,loFind,llFound
loRange=.NULL.
llFound=.F.
TRY
    loRange=toSourceRange.Duplicate
    loFind=loRange.Find
    loFind.ClearFormatting()
    loFind.Text="[[CONSULT]]"
    loFind.Forward=.T.
    loFind.Wrap=0
    loFind.MatchWildcards=.F.
    loFind.MatchCase=.F.
    loFind.MatchWholeWord=.F.
    llFound=loFind.Execute()
CATCH
    llFound=.F.
ENDTRY
IF llFound
    RETURN loRange
ENDIF
RETURN .NULL.
ENDFUNC

FUNCTION FindConsultMarker
LPARAMETERS toDocument
LOCAL loRange,loStory,loNext,loShape,lnStory,lnLink
loRange=.NULL.

* Main text, headers, footers, footnotes, endnotes, comments and text-frame
* stories can each contain template text. Search every available Word story.
FOR lnStory=1 TO 17
    loStory=.NULL.
    TRY
        loStory=toDocument.StoryRanges.Item(lnStory)
    CATCH
    ENDTRY
    lnLink=0
    DO WHILE VARTYPE(loStory)=="O" AND lnLink<100
        loRange=FindConsultMarkerInRange(loStory)
        IF VARTYPE(loRange)=="O"
            RETURN loRange
        ENDIF
        loNext=.NULL.
        TRY
            loNext=loStory.NextStoryRange
        CATCH
        ENDTRY
        loStory=loNext
        lnLink=lnLink+1
    ENDDO
ENDFOR

* Also inspect document-level floating text boxes directly. Some older Word
* templates do not expose these through StoryRanges until they are selected.
TRY
    FOR EACH loShape IN toDocument.Shapes
        IF loShape.TextFrame.HasText
            loRange=FindConsultMarkerInRange(loShape.TextFrame.TextRange)
            IF VARTYPE(loRange)=="O"
                RETURN loRange
            ENDIF
        ENDIF
    ENDFOR
CATCH
ENDTRY
RETURN .NULL.
ENDFUNC

FUNCTION BringConsultWordToFront
LPARAMETERS toWord,toDocument
LOCAL lnWordHwnd
TRY
    toDocument.Activate()
    toWord.Visible=.T.
    lnWordHwnd=toWord.Hwnd
    DECLARE INTEGER ShowWindow IN user32.dll AS ConsultShowWindow ;
        INTEGER hWnd, INTEGER nCmdShow
    DECLARE INTEGER SetForegroundWindow IN user32.dll AS ConsultSetForeground ;
        INTEGER hWnd
    =ConsultShowWindow(lnWordHwnd,5)
    =ConsultSetForeground(lnWordHwnd)
CATCH
ENDTRY
RETURN .T.
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
    FocusDocument=.NULL.
    FocusTicks=0

    PROCEDURE Timer
        LOCAL loNew,loRange,lnDoc,lnAnswer,loError,llReenable,lcCandidateName
        THIS.Enabled=.F.
        llReenable=.F.
        IF THIS.FocusTicks>0
            =BringConsultWordToFront(THIS.WordApp,THIS.FocusDocument)
            THIS.FocusTicks=THIS.FocusTicks-1
            IF THIS.FocusTicks>0
                THIS.Enabled=.T.
            ENDIF
            RETURN
        ENDIF
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
                    lnAnswer=ConfirmConsultInsert(THIS.WordApp)
                    IF lnAnswer=6
                        * Search the main body and all template story/text-box ranges.
                        loRange=FindConsultMarker(loNew)
                        IF VARTYPE(loRange)=="O"
                            loRange.Text=THIS.ConsultText
                            THIS.ConsultText=""
                            * Prevent the timer's owner form from reclaiming focus
                            * when this event returns. It reopens normally later.
                            TRY
                                THIS.TargetForm.Hide()
                            CATCH
                            ENDTRY
                            THIS.FocusDocument=loNew
                            THIS.FocusTicks=3
                            THIS.Enabled=.T.
                        ELSE
                            =WordOwnedConsultMessage(THIS.WordApp,;
                                "The consultation marker [[CONSULT]] is not present. No text was inserted.",;
                                48)
                            TRY
                                THIS.TargetForm.Hide()
                            CATCH
                            ENDTRY
                            THIS.FocusDocument=loNew
                            THIS.FocusTicks=3
                            THIS.Enabled=.T.
                        ENDIF
                    ENDIF
                ELSE
                    llReenable=.T.
                ENDIF
            ENDIF
        CATCH TO loError
            =WordOwnedConsultMessage(THIS.WordApp,;
                "The prepared consultation information could not be inserted."+CHR(13)+loError.Message,;
                16)
            TRY
                THIS.FocusDocument=loNew
                THIS.FocusTicks=3
                THIS.Enabled=.T.
            CATCH
            ENDTRY
        ENDTRY
        IF llReenable
            THIS.Enabled=.T.
        ENDIF
    ENDPROC
ENDDEFINE
