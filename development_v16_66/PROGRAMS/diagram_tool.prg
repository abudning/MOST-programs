* LetterBuilder eye-diagram helper, V16.66.1.
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
lnBitmap=CreateCompatibleBitmap(lnScreenDC,640,260)
lnOldBitmap=SelectObject(lnMemoryDC,lnBitmap)
lnWhiteBrush=CreateSolidBrush(RGB(255,255,255))
lnOldBrush=SelectObject(lnMemoryDC,lnWhiteBrush)
lnPen=CreatePen(0,2,RGB(0,0,0))
lnOldPen=SelectObject(lnMemoryDC,lnPen)
=Rectangle(lnMemoryDC,0,0,640,260)
=SetBkMode(lnMemoryDC,1)
=SetTextColor(lnMemoryDC,RGB(0,0,0))
* Two pointed almond-shaped eye outlines matching the clinical template.
=MoveToEx(lnMemoryDC,85,110,0)
=LineTo(lnMemoryDC,115,87)
=LineTo(lnMemoryDC,155,73)
=LineTo(lnMemoryDC,205,73)
=LineTo(lnMemoryDC,245,87)
=LineTo(lnMemoryDC,275,110)
=MoveToEx(lnMemoryDC,85,110,0)
=LineTo(lnMemoryDC,115,133)
=LineTo(lnMemoryDC,155,147)
=LineTo(lnMemoryDC,205,147)
=LineTo(lnMemoryDC,245,133)
=LineTo(lnMemoryDC,275,110)
=MoveToEx(lnMemoryDC,365,110,0)
=LineTo(lnMemoryDC,395,87)
=LineTo(lnMemoryDC,435,73)
=LineTo(lnMemoryDC,485,73)
=LineTo(lnMemoryDC,525,87)
=LineTo(lnMemoryDC,555,110)
=MoveToEx(lnMemoryDC,365,110,0)
=LineTo(lnMemoryDC,395,133)
=LineTo(lnMemoryDC,435,147)
=LineTo(lnMemoryDC,485,147)
=LineTo(lnMemoryDC,525,133)
=LineTo(lnMemoryDC,555,110)
lnFont=CreateFontA(-17,0,0,0,400,0,0,0,0,0,0,0,0,"Arial")
lnOldFont=SelectObject(lnMemoryDC,lnFont)
=SetTextAlign(lnMemoryDC,6)
=GdiDiagramText(lnMemoryDC,toForm.topCentre.Value,320,7)
=GdiDiagramText(lnMemoryDC,toForm.leftTop.Value,180,43)
=GdiDiagramText(lnMemoryDC,toForm.rightTop.Value,460,43)
=GdiDiagramText(lnMemoryDC,toForm.leftOuter.Value,42,99)
=GdiDiagramText(lnMemoryDC,toForm.leftInner.Value,315,99)
=GdiDiagramText(lnMemoryDC,toForm.rightInner.Value,325,137)
=GdiDiagramText(lnMemoryDC,toForm.rightOuter.Value,598,99)
=GdiDiagramText(lnMemoryDC,toForm.leftBottom.Value,160,174)
=GdiDiagramText(lnMemoryDC,toForm.bottomCentre.Value,320,211)
=GdiDiagramText(lnMemoryDC,toForm.rightBottom.Value,480,174)
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
    lnY=lnY+18
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
    Caption="Eye Diagram - V16.66.1"
    Width=670
    Height=370
    AutoCenter=.T.
    BorderStyle=2
    MaxButton=.F.
    MinButton=.F.
    BackColor=RGB(255,255,255)
    ADD OBJECT instructions AS Label WITH Caption="Enter measurements in the boxes around the diagram. Use | for a second line (example: 25XT|RH3).",Left=18,Top=12,Width=630,Height=30,WordWrap=.T.,BackStyle=0
    ADD OBJECT topCentre AS DiagramEntry WITH Left=285,Top=43,Width=100,Height=24
    ADD OBJECT leftTop AS DiagramEntry WITH Left=130,Top=70,Width=100,Height=24
    ADD OBJECT rightTop AS DiagramEntry WITH Left=440,Top=70,Width=100,Height=24
    ADD OBJECT leftOuter AS DiagramEntry WITH Left=12,Top=132,Width=92,Height=24
    ADD OBJECT leftInner AS DiagramEntry WITH Left=275,Top=132,Width=92,Height=24
    ADD OBJECT rightInner AS DiagramEntry WITH Left=303,Top=174,Width=92,Height=24
    ADD OBJECT rightOuter AS DiagramEntry WITH Left=566,Top=132,Width=92,Height=24
    ADD OBJECT leftBottom AS DiagramEntry WITH Left=110,Top=225,Width=110,Height=24
    ADD OBJECT bottomCentre AS DiagramEntry WITH Left=280,Top=266,Width=110,Height=24
    ADD OBJECT rightBottom AS DiagramEntry WITH Left=450,Top=225,Width=110,Height=24
    ADD OBJECT leye1 AS Line WITH Left=105,Top=112,Width=45,Height=16,LineSlant="/",BorderWidth=1
    ADD OBJECT leye2 AS Line WITH Left=150,Top=105,Width=75,Height=7,LineSlant="/",BorderWidth=1
    ADD OBJECT leye3 AS Line WITH Left=225,Top=105,Width=45,Height=18,LineSlant="\\",BorderWidth=1
    ADD OBJECT leye4 AS Line WITH Left=105,Top=159,Width=45,Height=16,LineSlant="\\",BorderWidth=1
    ADD OBJECT leye5 AS Line WITH Left=150,Top=175,Width=75,Height=7,LineSlant="\\",BorderWidth=1
    ADD OBJECT leye6 AS Line WITH Left=225,Top=160,Width=45,Height=15,LineSlant="/",BorderWidth=1
    ADD OBJECT reye1 AS Line WITH Left=400,Top=112,Width=45,Height=16,LineSlant="/",BorderWidth=1
    ADD OBJECT reye2 AS Line WITH Left=445,Top=105,Width=75,Height=7,LineSlant="/",BorderWidth=1
    ADD OBJECT reye3 AS Line WITH Left=520,Top=105,Width=45,Height=18,LineSlant="\\",BorderWidth=1
    ADD OBJECT reye4 AS Line WITH Left=400,Top=159,Width=45,Height=16,LineSlant="\\",BorderWidth=1
    ADD OBJECT reye5 AS Line WITH Left=445,Top=175,Width=75,Height=7,LineSlant="\\",BorderWidth=1
    ADD OBJECT reye6 AS Line WITH Left=520,Top=160,Width=45,Height=15,LineSlant="/",BorderWidth=1
    ADD OBJECT copyButton AS DiagramCopyButton WITH Caption="Copy Diagram",Left=258,Top=320,Width=115,Height=30,Default=.T.
    ADD OBJECT insertButton AS DiagramInsertButton WITH Caption="Insert into Word",Left=382,Top=320,Width=125,Height=30
    ADD OBJECT clearButton AS DiagramClearButton WITH Caption="Clear",Left=516,Top=320,Width=65,Height=30
    ADD OBJECT closeButton AS DiagramCloseButton WITH Caption="Close",Left=590,Top=320,Width=65,Height=30,Cancel=.T.
    PROCEDURE QueryUnload
        NODEFAULT
        THIS.Hide()
    ENDPROC
    PROCEDURE ClearEntries
        LOCAL lnI,loControl
        FOR lnI=1 TO THIS.ControlCount
            loControl=THIS.Controls(lnI)
            IF UPPER(loControl.Class)=="DIAGRAMENTRY"
                loControl.Value=""
            ENDIF
        ENDFOR
        THIS.topCentre.SetFocus()
    ENDPROC
ENDDEFINE

DEFINE CLASS DiagramEntry AS TextBox
    Value=""
    Alignment=2
    MaxLength=30
    FontName="Arial"
    FontSize=9
    ToolTipText="Use | for a second line"
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
        THISFORM.ClearEntries()
    ENDPROC
ENDDEFINE
DEFINE CLASS DiagramCloseButton AS CommandButton
    PROCEDURE Click
        THISFORM.Hide()
    ENDPROC
ENDDEFINE
