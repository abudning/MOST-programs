* LetterBuilder eye-diagram helper, V16.66.4.
* Draws a clean monochrome bitmap with Win32 GDI and places it on the
* Windows clipboard. This avoids dependencies on Paint, modern Office,
* .NET, or browser clipboard support.

FUNCTION ShowEyeDiagram
LOCAL loDiagram
loDiagram=CREATEOBJECT("EyeDiagramForm")
loDiagram.Show(1)
loDiagram.Release()
RETURN
ENDFUNC

FUNCTION CopyEyeDiagram
LPARAMETERS toForm,tlQuiet
LOCAL lnScreenDC,lnMemoryDC,lnBitmap,lnOldBitmap,lnFont,lnOldFont,lnPen,lnOldPen
LOCAL lnResult,llCopied,lnWhiteBrush,lnOldBrush
IF VARTYPE(toForm)#"O"
    RETURN .F.
ENDIF
DECLARE INTEGER GetDC IN user32 INTEGER
DECLARE INTEGER ReleaseDC IN user32 INTEGER, INTEGER
DECLARE INTEGER CreateCompatibleDC IN gdi32 INTEGER
DECLARE INTEGER DeleteDC IN gdi32 INTEGER
DECLARE INTEGER CreateCompatibleBitmap IN gdi32 INTEGER, INTEGER, INTEGER
DECLARE INTEGER SelectObject IN gdi32 INTEGER, INTEGER
DECLARE INTEGER DeleteObject IN gdi32 INTEGER
DECLARE INTEGER CreatePen IN gdi32 INTEGER, INTEGER, INTEGER
DECLARE INTEGER CreateSolidBrush IN gdi32 INTEGER
DECLARE INTEGER Rectangle IN gdi32 INTEGER, INTEGER, INTEGER, INTEGER, INTEGER
DECLARE INTEGER MoveToEx IN gdi32 INTEGER, INTEGER, INTEGER, INTEGER
DECLARE INTEGER LineTo IN gdi32 INTEGER, INTEGER, INTEGER
DECLARE INTEGER SetBkMode IN gdi32 INTEGER, INTEGER
DECLARE INTEGER SetTextColor IN gdi32 INTEGER, INTEGER
DECLARE INTEGER SetTextAlign IN gdi32 INTEGER, INTEGER
DECLARE INTEGER TextOutA IN gdi32 INTEGER, INTEGER, INTEGER, STRING, INTEGER
DECLARE INTEGER CreateFontA IN gdi32 INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, STRING
DECLARE INTEGER OpenClipboard IN user32 INTEGER
DECLARE INTEGER EmptyClipboard IN user32
DECLARE INTEGER SetClipboardData IN user32 INTEGER, INTEGER
DECLARE INTEGER CloseClipboard IN user32
llCopied=.F.
lnScreenDC=GetDC(0)
lnMemoryDC=CreateCompatibleDC(lnScreenDC)
* The finished Word graphic is 60% of the original 640 x 260 output.
lnBitmap=CreateCompatibleBitmap(lnScreenDC,384,156)
lnOldBitmap=SelectObject(lnMemoryDC,lnBitmap)
lnWhiteBrush=CreateSolidBrush(RGB(255,255,255))
lnOldBrush=SelectObject(lnMemoryDC,lnWhiteBrush)
lnPen=CreatePen(0,2,RGB(0,0,0))
lnOldPen=SelectObject(lnMemoryDC,lnPen)
=Rectangle(lnMemoryDC,0,0,384,156)
=SetBkMode(lnMemoryDC,1)
=SetTextColor(lnMemoryDC,RGB(0,0,0))
* Two pointed almond-shaped eye outlines matching the clinical template.
=MoveToEx(lnMemoryDC,51,66,0)
=LineTo(lnMemoryDC,69,52)
=LineTo(lnMemoryDC,93,44)
=LineTo(lnMemoryDC,123,44)
=LineTo(lnMemoryDC,147,52)
=LineTo(lnMemoryDC,165,66)
=MoveToEx(lnMemoryDC,51,66,0)
=LineTo(lnMemoryDC,69,80)
=LineTo(lnMemoryDC,93,88)
=LineTo(lnMemoryDC,123,88)
=LineTo(lnMemoryDC,147,80)
=LineTo(lnMemoryDC,165,66)
=MoveToEx(lnMemoryDC,219,66,0)
=LineTo(lnMemoryDC,237,52)
=LineTo(lnMemoryDC,261,44)
=LineTo(lnMemoryDC,291,44)
=LineTo(lnMemoryDC,315,52)
=LineTo(lnMemoryDC,333,66)
=MoveToEx(lnMemoryDC,219,66,0)
=LineTo(lnMemoryDC,237,80)
=LineTo(lnMemoryDC,261,88)
=LineTo(lnMemoryDC,291,88)
=LineTo(lnMemoryDC,315,80)
=LineTo(lnMemoryDC,333,66)
* Head-tilt indicators lead outward from the lower eye positions.
=MoveToEx(lnMemoryDC,90,92,0)
=LineTo(lnMemoryDC,86,98)
=LineTo(lnMemoryDC,75,103)
=MoveToEx(lnMemoryDC,294,92,0)
=LineTo(lnMemoryDC,298,98)
=LineTo(lnMemoryDC,309,103)
* Fifteen-pixel type is proportionally larger than in the original output.
lnFont=CreateFontA(-15,0,0,0,400,0,0,0,0,0,0,0,0,"Arial")
lnOldFont=SelectObject(lnMemoryDC,lnFont)
=SetTextAlign(lnMemoryDC,6)
IF toForm.lDeviationOn
    =SetTextColor(lnMemoryDC,RGB(0,0,0))
    =GdiDiagramText(lnMemoryDC,toForm.topCentre.Value,192,3)
    =GdiDiagramText(lnMemoryDC,toForm.leftOuter.Value,25,59)
    =GdiDiagramText(lnMemoryDC,toForm.leftInner.Value,192,59)
    =GdiDiagramText(lnMemoryDC,toForm.rightOuter.Value,359,59)
    =GdiDiagramText(lnMemoryDC,toForm.leftBottom.Value,63,106)
    =GdiDiagramText(lnMemoryDC,toForm.bottomCentre.Value,192,127)
    =GdiDiagramText(lnMemoryDC,toForm.rightBottom.Value,321,106)
ENDIF
IF toForm.lMovementOn
    =SetTextColor(lnMemoryDC,RGB(255,0,0))
    =GdiDiagramText(lnMemoryDC,toForm.moveLeftTop.Value,116,24)
    =GdiDiagramText(lnMemoryDC,toForm.moveRightTop.Value,297,26)
    =GdiDiagramText(lnMemoryDC,toForm.moveLeftOuter.Value,77,69)
    =GdiDiagramText(lnMemoryDC,toForm.moveLeftInner.Value,153,68)
    =GdiDiagramText(lnMemoryDC,toForm.moveRightInner.Value,257,76)
    =GdiDiagramText(lnMemoryDC,toForm.moveRightOuter.Value,338,80)
    =GdiDiagramText(lnMemoryDC,toForm.moveLeftBottom.Value,111,122)
    =GdiDiagramText(lnMemoryDC,toForm.moveRightBottom.Value,285,129)
ENDIF
=SelectObject(lnMemoryDC,lnOldFont)
=SelectObject(lnMemoryDC,lnOldPen)
=SelectObject(lnMemoryDC,lnOldBrush)
=SelectObject(lnMemoryDC,lnOldBitmap)
=DeleteObject(lnFont)
=DeleteObject(lnPen)
=DeleteObject(lnWhiteBrush)
=DeleteDC(lnMemoryDC)
=ReleaseDC(0,lnScreenDC)
IF OpenClipboard(0)#0
    =EmptyClipboard()
    lnResult=SetClipboardData(2,lnBitmap)
    =CloseClipboard()
    llCopied=lnResult#0
ENDIF
IF !llCopied
    =DeleteObject(lnBitmap)
    IF PCOUNT()<2 OR !tlQuiet
        MESSAGEBOX("The diagram could not be copied. Close any program that is using the Clipboard and try again.",48,"Eye Diagram")
    ENDIF
ELSE
    IF PCOUNT()<2 OR !tlQuiet
        MESSAGEBOX("The diagram is on the Clipboard. Place the cursor in Word and choose Paste.",64,"Eye Diagram Copied")
    ENDIF
ENDIF
RETURN llCopied
ENDFUNC

FUNCTION GdiDiagramText
LPARAMETERS tnDC,tcValue,tnX,tnY
LOCAL lcText,lcLine,lnAt,lnY
lcText=ALLTRIM(TRANSFORM(tcValue))
lcText=STRTRAN(lcText,CHR(13)+CHR(10),"|")
lcText=STRTRAN(lcText,CHR(13),"|")
lcText=STRTRAN(lcText,CHR(10),"|")
lnY=tnY
DO WHILE !EMPTY(lcText)
    lnAt=AT("|",lcText)
    IF lnAt>0
        lcLine=LEFT(lcText,lnAt-1)
        lcText=SUBSTR(lcText,lnAt+1)
    ELSE
        lcLine=lcText
        lcText=""
    ENDIF
    lcLine=ALLTRIM(lcLine)
    IF !EMPTY(lcLine)
        =TextOutA(tnDC,tnX,lnY,lcLine,LEN(lcLine))
    ENDIF
    lnY=lnY+16
ENDDO
RETURN
ENDFUNC

FUNCTION InsertEyeDiagram
LPARAMETERS toForm
LOCAL loWord,loError
IF !CopyEyeDiagram(toForm,.T.)
    RETURN .F.
ENDIF
TRY
    loWord=GETOBJECT(,"Word.Application")
    IF loWord.Documents.Count=0
        MESSAGEBOX("Open the letter in Word and place the cursor where the diagram should appear.",48,"Insert Eye Diagram")
        RETURN .F.
    ENDIF
    loWord.Visible=.T.
    loWord.Activate()
    loWord.Selection.Paste()
    MESSAGEBOX("The diagram was inserted at the cursor in Word.",64,"Eye Diagram Inserted")
CATCH TO loError
    MESSAGEBOX("The diagram is on the Clipboard, but Word could not insert it automatically."+CHR(13)+CHR(13)+;
        "Place the cursor in the letter and choose Paste."+CHR(13)+CHR(13)+loError.Message,48,"Insert Eye Diagram")
    RETURN .F.
ENDTRY
RETURN .T.
ENDFUNC

DEFINE CLASS DiagramButton AS CommandButton
    Caption="Diagram"
    Width=68
    Height=21
    FontSize=8
    PROCEDURE Click
        =ShowEyeDiagram()
    ENDPROC
ENDDEFINE

DEFINE CLASS EyeDiagramForm AS Form
    Caption="Eye Diagram - V16.66.4"
    Width=670
    Height=430
    AutoCenter=.T.
    BorderStyle=2
    MaxButton=.F.
    MinButton=.F.
    BackColor=RGB(255,255,255)
    lDeviationOn=.T.
    lMovementOn=.T.
    cUndo1=""
    cUndo2=""
    ADD OBJECT instructions AS Label WITH Caption="Enter deviations in black and movements in red. Use | for a second line. The toggles control entry and diagram output.",Left=18,Top=10,Width=630,Height=30,WordWrap=.T.,BackStyle=0
    ADD OBJECT deviationToggle AS DiagramLayerToggle WITH Caption="Deviations: ON",Left=195,Top=42,Width=130,Height=28,Value=1,Tag="D"
    ADD OBJECT movementToggle AS DiagramLayerToggle WITH Caption="Movements: ON",Left=335,Top=42,Width=130,Height=28,Value=1,Tag="M"
    ADD OBJECT topCentre AS DiagramEntry WITH Left=285,Top=75,Width=100,Height=24
    ADD OBJECT leftOuter AS DiagramEntry WITH Left=12,Top=164,Width=92,Height=24
    ADD OBJECT leftInner AS DiagramEntry WITH Left=289,Top=164,Width=92,Height=24
    ADD OBJECT rightOuter AS DiagramEntry WITH Left=566,Top=164,Width=92,Height=24
    ADD OBJECT leftBottom AS DiagramEntry WITH Left=55,Top=260,Width=110,Height=24
    ADD OBJECT bottomCentre AS DiagramEntry WITH Left=280,Top=298,Width=110,Height=24
    ADD OBJECT rightBottom AS DiagramEntry WITH Left=505,Top=260,Width=110,Height=24
    ADD OBJECT moveLeftTop AS MovementEntry WITH Left=165,Top=87,Width=70,Height=24
    ADD OBJECT moveRightTop AS MovementEntry WITH Left=435,Top=87,Width=70,Height=24
    ADD OBJECT moveLeftOuter AS MovementEntry WITH Left=78,Top=139,Width=70,Height=24
    ADD OBJECT moveLeftInner AS MovementEntry WITH Left=233,Top=139,Width=70,Height=24
    ADD OBJECT moveRightInner AS MovementEntry WITH Left=367,Top=151,Width=70,Height=24
    ADD OBJECT moveRightOuter AS MovementEntry WITH Left=522,Top=151,Width=70,Height=24
    ADD OBJECT moveLeftBottom AS MovementEntry WITH Left=155,Top=273,Width=70,Height=24
    ADD OBJECT moveRightBottom AS MovementEntry WITH Left=445,Top=285,Width=70,Height=24
    ADD OBJECT leye1 AS Line WITH Left=105,Top=144,Width=45,Height=16,LineSlant="/",BorderWidth=1
    ADD OBJECT leye2 AS Line WITH Left=150,Top=137,Width=75,Height=7,LineSlant="/",BorderWidth=1
    ADD OBJECT leye3 AS Line WITH Left=225,Top=137,Width=45,Height=18,LineSlant="\\",BorderWidth=1
    ADD OBJECT leye4 AS Line WITH Left=105,Top=191,Width=45,Height=16,LineSlant="\\",BorderWidth=1
    ADD OBJECT leye5 AS Line WITH Left=150,Top=207,Width=75,Height=7,LineSlant="\\",BorderWidth=1
    ADD OBJECT leye6 AS Line WITH Left=225,Top=192,Width=45,Height=15,LineSlant="/",BorderWidth=1
    ADD OBJECT reye1 AS Line WITH Left=400,Top=144,Width=45,Height=16,LineSlant="/",BorderWidth=1
    ADD OBJECT reye2 AS Line WITH Left=445,Top=137,Width=75,Height=7,LineSlant="/",BorderWidth=1
    ADD OBJECT reye3 AS Line WITH Left=520,Top=137,Width=45,Height=18,LineSlant="\\",BorderWidth=1
    ADD OBJECT reye4 AS Line WITH Left=400,Top=191,Width=45,Height=16,LineSlant="\\",BorderWidth=1
    ADD OBJECT reye5 AS Line WITH Left=445,Top=207,Width=75,Height=7,LineSlant="\\",BorderWidth=1
    ADD OBJECT reye6 AS Line WITH Left=520,Top=192,Width=45,Height=15,LineSlant="/",BorderWidth=1
    ADD OBJECT leftTilt AS Line WITH Left=125,Top=222,Width=25,Height=28,LineSlant="/",BorderWidth=1
    ADD OBJECT rightTilt AS Line WITH Left=490,Top=222,Width=25,Height=28,LineSlant="\\",BorderWidth=1
    ADD OBJECT copyButton AS DiagramCopyButton WITH Caption="Copy Diagram",Left=170,Top=370,Width=115,Height=30,Default=.T.
    ADD OBJECT insertButton AS DiagramInsertButton WITH Caption="Insert into Word",Left=294,Top=370,Width=125,Height=30
    ADD OBJECT clearButton AS DiagramClearButton WITH Caption="Clear Active",Left=428,Top=370,Width=90,Height=30
    ADD OBJECT undoButton AS DiagramUndoButton WITH Caption="Undo",Left=527,Top=370,Width=60,Height=30,Enabled=.F.
    ADD OBJECT closeButton AS DiagramCloseButton WITH Caption="Close",Left=596,Top=370,Width=60,Height=30,Cancel=.T.

    PROCEDURE Init
        THIS.RefreshLayers()
    ENDPROC

    PROCEDURE QueryUnload
        NODEFAULT
        THIS.Hide()
    ENDPROC

    PROCEDURE SerializeEntries
        LOCAL lcSep
        lcSep=CHR(30)
        RETURN TRANSFORM(THIS.topCentre.Value)+lcSep+TRANSFORM(THIS.leftOuter.Value)+lcSep+;
            TRANSFORM(THIS.leftInner.Value)+lcSep+TRANSFORM(THIS.rightOuter.Value)+lcSep+;
            TRANSFORM(THIS.leftBottom.Value)+lcSep+TRANSFORM(THIS.bottomCentre.Value)+lcSep+;
            TRANSFORM(THIS.rightBottom.Value)+lcSep+TRANSFORM(THIS.moveLeftTop.Value)+lcSep+;
            TRANSFORM(THIS.moveRightTop.Value)+lcSep+TRANSFORM(THIS.moveLeftOuter.Value)+lcSep+;
            TRANSFORM(THIS.moveLeftInner.Value)+lcSep+TRANSFORM(THIS.moveRightInner.Value)+lcSep+;
            TRANSFORM(THIS.moveRightOuter.Value)+lcSep+TRANSFORM(THIS.moveLeftBottom.Value)+lcSep+;
            TRANSFORM(THIS.moveRightBottom.Value)
    ENDPROC

    PROCEDURE RestoreEntries
        LPARAMETERS tcState
        LOCAL ARRAY laValue[15]
        LOCAL lcWork,lcSep,lnI,lnAt
        lcWork=tcState
        lcSep=CHR(30)
        FOR lnI=1 TO 14
            lnAt=AT(lcSep,lcWork)
            IF lnAt=0
                RETURN
            ENDIF
            laValue[lnI]=LEFT(lcWork,lnAt-1)
            lcWork=SUBSTR(lcWork,lnAt+1)
        ENDFOR
        laValue[15]=lcWork
        THIS.topCentre.Value=laValue[1]
        THIS.leftOuter.Value=laValue[2]
        THIS.leftInner.Value=laValue[3]
        THIS.rightOuter.Value=laValue[4]
        THIS.leftBottom.Value=laValue[5]
        THIS.bottomCentre.Value=laValue[6]
        THIS.rightBottom.Value=laValue[7]
        THIS.moveLeftTop.Value=laValue[8]
        THIS.moveRightTop.Value=laValue[9]
        THIS.moveLeftOuter.Value=laValue[10]
        THIS.moveLeftInner.Value=laValue[11]
        THIS.moveRightInner.Value=laValue[12]
        THIS.moveRightOuter.Value=laValue[13]
        THIS.moveLeftBottom.Value=laValue[14]
        THIS.moveRightBottom.Value=laValue[15]
    ENDPROC

    PROCEDURE PushUndo
        LPARAMETERS tcState
        IF EMPTY(tcState) OR tcState==THIS.SerializeEntries()
            RETURN
        ENDIF
        IF tcState==THIS.cUndo1
            RETURN
        ENDIF
        THIS.cUndo2=THIS.cUndo1
        THIS.cUndo1=tcState
        THIS.undoButton.Enabled=.T.
    ENDPROC

    PROCEDURE UndoLast
        LOCAL lcCurrent
        IF EMPTY(THIS.cUndo1)
            RETURN
        ENDIF
        lcCurrent=THIS.SerializeEntries()
        THIS.RestoreEntries(THIS.cUndo1)
        THIS.cUndo1=THIS.cUndo2
        THIS.cUndo2=""
        THIS.undoButton.Enabled=!EMPTY(THIS.cUndo1)
        THIS.RefreshLayers()
    ENDPROC

    PROCEDURE RefreshLayers
        LOCAL lnI,loControl
        THIS.lDeviationOn=THIS.deviationToggle.Value=1
        THIS.lMovementOn=THIS.movementToggle.Value=1
        THIS.deviationToggle.Caption="Deviations: "+IIF(THIS.lDeviationOn,"ON","OFF")
        THIS.movementToggle.Caption="Movements: "+IIF(THIS.lMovementOn,"ON","OFF")
        FOR lnI=1 TO THIS.ControlCount
            loControl=THIS.Controls(lnI)
            IF UPPER(loControl.Class)=="DIAGRAMENTRY"
                loControl.Visible=THIS.lDeviationOn
                loControl.Enabled=THIS.lDeviationOn
            ELSE
                IF UPPER(loControl.Class)=="MOVEMENTENTRY"
                    loControl.Visible=THIS.lMovementOn
                    loControl.Enabled=THIS.lMovementOn
                ENDIF
            ENDIF
        ENDFOR
    ENDPROC

    PROCEDURE ClearActive
        LOCAL lcBefore,lnAnswer,lnI,loControl
        IF !THIS.lDeviationOn AND !THIS.lMovementOn
            RETURN
        ENDIF
        IF THIS.lDeviationOn AND THIS.lMovementOn
            lnAnswer=MESSAGEBOX("Clear all deviation and movement entries?",36,"Clear Active Entries")
            IF lnAnswer#6
                RETURN
            ENDIF
        ENDIF
        lcBefore=THIS.SerializeEntries()
        FOR lnI=1 TO THIS.ControlCount
            loControl=THIS.Controls(lnI)
            IF UPPER(loControl.Class)=="DIAGRAMENTRY" AND THIS.lDeviationOn
                loControl.Value=""
            ELSE
                IF UPPER(loControl.Class)=="MOVEMENTENTRY" AND THIS.lMovementOn
                    loControl.Value=""
                ENDIF
            ENDIF
        ENDFOR
        THIS.PushUndo(lcBefore)
    ENDPROC
ENDDEFINE

DEFINE CLASS DiagramEntry AS TextBox
    Value=""
    Alignment=2
    MaxLength=30
    FontName="Arial"
    FontSize=9
    ForeColor=RGB(0,0,0)
    cBeforeEdit=""
    ToolTipText="Deviation: use | for a second line"
    PROCEDURE GotFocus
        THIS.cBeforeEdit=THISFORM.SerializeEntries()
    ENDPROC
    PROCEDURE LostFocus
        THISFORM.PushUndo(THIS.cBeforeEdit)
    ENDPROC
ENDDEFINE

DEFINE CLASS MovementEntry AS DiagramEntry
    ForeColor=RGB(255,0,0)
    ToolTipText="Movement: use | for a second line"
ENDDEFINE

DEFINE CLASS DiagramLayerToggle AS CheckBox
    Style=1
    FontBold=.T.
    PROCEDURE Click
        IF THIS.Value=0
            IF UPPER(THIS.Tag)=="D" AND THISFORM.movementToggle.Value=0
                THIS.Value=1
                MESSAGEBOX("At least one diagram layer must remain active.",48,"Eye Diagram")
            ENDIF
            IF UPPER(THIS.Tag)=="M" AND THISFORM.deviationToggle.Value=0
                THIS.Value=1
                MESSAGEBOX("At least one diagram layer must remain active.",48,"Eye Diagram")
            ENDIF
        ENDIF
        THISFORM.RefreshLayers()
    ENDPROC
ENDDEFINE

DEFINE CLASS DiagramCopyButton AS CommandButton
    PROCEDURE Click
        =CopyEyeDiagram(THISFORM,.F.)
    ENDPROC
ENDDEFINE
DEFINE CLASS DiagramInsertButton AS CommandButton
    PROCEDURE Click
        =InsertEyeDiagram(THISFORM)
    ENDPROC
ENDDEFINE
DEFINE CLASS DiagramClearButton AS CommandButton
    PROCEDURE Click
        THISFORM.ClearActive()
    ENDPROC
ENDDEFINE
DEFINE CLASS DiagramUndoButton AS CommandButton
    PROCEDURE Click
        THISFORM.UndoLast()
    ENDPROC
ENDDEFINE
DEFINE CLASS DiagramCloseButton AS CommandButton
    PROCEDURE Click
        THISFORM.Hide()
    ENDPROC
ENDDEFINE
