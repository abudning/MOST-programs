* MOSt V16.17 Prescription Centre
* VFP7-compatible shared optical records; Word is used only for optional import.
LPARAMETERS tcMode, toPatient, tcRxId
LOCAL loForm, lcMode
lcMode = UPPER(ALLTRIM(IIF(VARTYPE(tcMode)="C",tcMode,"HISTORY")))

DO CASE
CASE lcMode == "SELFTEST"
    LOCAL lcSample, lnODS, lnODC, lnODA, lnOSS, lnOSC, lnOSA, llParsed
    lcSample="Refraction: dil"+CHR(13)+CHR(10)+"OD: -2.00+2.25x100"+CHR(13)+CHR(10)+"OS: -1.75+2.50x80"
    llParsed=RxParseEye(lcSample,"OD",@lnODS,@lnODC,@lnODA) AND RxParseEye(lcSample,"OS",@lnOSS,@lnOSC,@lnOSA)
    =RxEnsureOpticalTable()
    STRTOFILE("PARSED="+TRANSFORM(llParsed)+CHR(13)+CHR(10)+;
        "OD="+TRANSFORM(lnODS)+","+TRANSFORM(lnODC)+","+TRANSFORM(lnODA)+CHR(13)+CHR(10)+;
        "OS="+TRANSFORM(lnOSS)+","+TRANSFORM(lnOSC)+","+TRANSFORM(lnOSA)+CHR(13)+CHR(10)+;
        "TABLE="+TRANSFORM(FILE(ADDBS(path_to_data)+"rxoptical.dbf"))+CHR(13)+CHR(10),tcRxId,0)
CASE lcMode == "NEW"
    loForm = CREATEOBJECT("RxChoiceForm")
    loForm.oPatient = toPatient
    loForm.Show(1)
CASE lcMode == "GLASSES"
    =RxEnsureOpticalTable()
    loForm = CREATEOBJECT("RxGlassesForm")
    loForm.oPatient = toPatient
    loForm.cRxId = IIF(VARTYPE(tcRxId)="C",tcRxId,"")
    loForm.LoadPatient()
    loForm.Show(1)
OTHERWISE
    =RxEnsureOpticalTable()
    loForm = CREATEOBJECT("RxHistoryForm")
    loForm.oPatient = toPatient
    loForm.LoadHistory()
    loForm.Show(1)
ENDCASE
RETURN


FUNCTION RxEnsureOpticalTable
LOCAL lcFile, lcOldSafety
lcFile = ADDBS(path_to_data) + "rxoptical.dbf"
IF FILE(lcFile)
    RETURN .T.
ENDIF
lcOldSafety = SET("SAFETY")
SET SAFETY OFF
CREATE TABLE (lcFile) FREE ;
    (RX_ID C(10), PAT_ID I, ISSUE_DATE D, EXAM_DATE D, EXP_DATE D, ;
     PRIMARY_MD C(10), STATUS C(12), OD_SPH N(7,2), OD_CYL N(7,2), OD_AXIS N(3), ;
     OS_SPH N(7,2), OS_CYL N(7,2), OS_AXIS N(3), OD_ADD N(6,2), OS_ADD N(6,2), ;
     OD_HPRISM N(6,2), OD_HBASE C(4), OD_VPRISM N(6,2), OD_VBASE C(4), ;
     OS_HPRISM N(6,2), OS_HBASE C(4), OS_VPRISM N(6,2), OS_VBASE C(4), ;
     PD_BINOC N(6,2), PD_OD N(6,2), PD_OS N(6,2), USE_TYPE C(30), ;
     NOTES M, SOURCE_TXT M, CREATED_AT T, CREATED_BY C(30), WORKSTN C(30), ;
     REPLACES_ID C(10))
USE (lcFile) EXCLUSIVE ALIAS rxsetup
INDEX ON RX_ID TAG RX_ID
INDEX ON PADL(TRANSFORM(PAT_ID),10,"0")+DTOS(ISSUE_DATE)+RX_ID TAG PATDATE
USE IN rxsetup
IF lcOldSafety == "ON"
    SET SAFETY ON
ENDIF
RETURN FILE(lcFile)
ENDFUNC


FUNCTION RxPatientName
LPARAMETERS toPatient
RETURN ALLTRIM(PROPER(toPatient.surname1.Value)) + ", " + ALLTRIM(PROPER(toPatient.firstname1.Value))
ENDFUNC


FUNCTION RxHtml
LPARAMETERS tcValue
LOCAL lcValue
lcValue=TRANSFORM(tcValue)
lcValue=STRTRAN(lcValue,"&","&amp;")
lcValue=STRTRAN(lcValue,"<","&lt;")
lcValue=STRTRAN(lcValue,">","&gt;")
lcValue=STRTRAN(lcValue,CHR(34),"&quot;")
RETURN lcValue
ENDFUNC


FUNCTION RxOpenMedication
LPARAMETERS toPatient, tnPrescId
LOCAL objName, oPrescr, lnRow
toPatient.MD = toPatient.lblprimaryFullname.Caption
toPatient.pat_address = ALLTRIM(toPatient.address1.Value)
toPatient.pat_city = PROPER(ALLTRIM(toPatient.addcombobox1.combo1.DisplayValue))
toPatient.postal_code = UPPER(toPatient.postal1.Value)
toPatient.pat_phone = TRANSFORM(toPatient.phone_home1.Value,'@R (999) 999-9999')
toPatient.current_md = ALLTRIM(toPatient.combo2.DisplayValue)
objName = "oPresc" + toPatient.Name
oPrescr = NEWOBJECT("prescription","prescription","",objName,;
    toPatient.id1.Value,RxPatientName(toPatient),toPatient,toPatient.lock_presc_edit,toPatient.lock_presc_print)
IF VARTYPE(tnPrescId)="N" AND tnPrescId>0 AND USED("c_avlpresc")
    SELECT c_avlpresc
    LOCATE FOR presc_id=tnPrescId
    IF FOUND()
        lnRow=RECNO("c_avlpresc")
        oPrescr.lstPresc.ListIndex=lnRow
        oPrescr.lstPresc.InteractiveChange()
    ENDIF
ENDIF
ACTIVATE WINDOW (oPrescr.Name) IN WINDOW (toPatient.Name)
RELEASE oPrescr
RETURN .T.
ENDFUNC


FUNCTION RxReadWordRefraction
LPARAMETERS tcSource, tdChartDate, tnODSph, tnODCyl, tnODAxis, tnOSSph, tnOSCyl, tnOSAxis
LOCAL loWord, loDoc, loRange, lcText, lcBlock, lnP, lnStart, lnEnd, llOD, llOS
tcSource=""
tdChartDate={}
tnODSph=0
tnODCyl=0
tnODAxis=0
tnOSSph=0
tnOSCyl=0
tnOSAxis=0
TRY
    loWord=GETOBJECT(,"Word.Application")
CATCH
    MESSAGEBOX("Open the patient's Word chart and highlight the complete Refraction block, then try again.",48,"MOSt - Import Refraction")
    RETURN .F.
ENDTRY
loDoc=loWord.ActiveDocument
IF VARTYPE(loDoc)#"O"
    RETURN .F.
ENDIF

* Prefer an intentional selection.  Otherwise find the last explicit Refraction heading.
lcText=ALLTRIM(STRTRAN(STRTRAN(loWord.Selection.Text,CHR(13),CHR(13)+CHR(10)),CHR(7),""))
IF LEN(lcText)>=12 AND ("REFRACTION" $ UPPER(lcText)) AND ("OD" $ UPPER(lcText)) AND ("OS" $ UPPER(lcText))
    lcBlock=lcText
ELSE
    lcBlock=""
    FOR lnP=loDoc.Paragraphs.Count TO 1 STEP -1
        lcText=ALLTRIM(STRTRAN(loDoc.Paragraphs(lnP).Range.Text,CHR(13),""))
        IF UPPER(LEFT(lcText,10))=="REFRACTION"
            lnStart=loDoc.Paragraphs(lnP).Range.Start
            lnEnd=loDoc.Paragraphs(MIN(lnP+3,loDoc.Paragraphs.Count)).Range.End
            loRange=loDoc.Range(lnStart,lnEnd)
            lcBlock=STRTRAN(loRange.Text,CHR(7),"")
            EXIT
        ENDIF
    ENDFOR
ENDIF
IF EMPTY(lcBlock)
    MESSAGEBOX("No complete Refraction block was found. Highlight the Refraction heading and both OD and OS lines, then try again.",48,"MOSt - Import Refraction")
    RETURN .F.
ENDIF
llOD=RxParseEye(lcBlock,"OD",@tnODSph,@tnODCyl,@tnODAxis)
llOS=RxParseEye(lcBlock,"OS",@tnOSSph,@tnOSCyl,@tnOSAxis)
IF !llOD OR !llOS
    MESSAGEBOX("The selected text does not contain a complete OD and OS sphere/cylinder/axis refraction. Nothing was imported.",48,"MOSt - Import Refraction")
    RETURN .F.
ENDIF
tcSource=ALLTRIM(lcBlock)
RETURN .T.
ENDFUNC


FUNCTION RxParseEye
LPARAMETERS tcText, tcEye, tnSphere, tnCylinder, tnAxis
LOCAL loRE, loMatches, loMatch, lcClean
lcClean=STRTRAN(STRTRAN(tcText,CHR(150),"-"),CHR(151),"-")
loRE=CREATEOBJECT("VBScript.RegExp")
loRE.Global=.F.
loRE.IgnoreCase=.T.
loRE.MultiLine=.T.
loRE.Pattern="(^|[\r\n])\s*"+tcEye+"\s*:?\s*([+-]?\d+(\.\d+)?)\s*([+-]\d+(\.\d+)?)\s*[xX]\s*(\d{1,3})"
loMatches=loRE.Execute(lcClean)
IF loMatches.Count=0
    RETURN .F.
ENDIF
loMatch=loMatches.Item(0)
tnSphere=VAL(loMatch.SubMatches(1))
tnCylinder=VAL(loMatch.SubMatches(3))
tnAxis=VAL(loMatch.SubMatches(5))
RETURN BETWEEN(tnSphere,-30,30) AND BETWEEN(tnCylinder,-30,30) AND BETWEEN(tnAxis,0,180)
ENDFUNC


DEFINE CLASS RxChoiceForm AS Form
    Height=145
    Width=300
    AutoCenter=.T.
    BorderStyle=2
    MaxButton=.F.
    MinButton=.F.
    Caption="New Rx"
    oPatient=.NULL.
    ADD OBJECT lblTitle AS Label WITH Top=16,Left=20,Width=260,Height=20,Caption="Choose prescription type",FontBold=.T.,FontSize=11,Alignment=2
    ADD OBJECT cmdMedication AS RxMedicationButton WITH Top=55,Left=30,Width=110,Height=36,Caption="Medication"
    ADD OBJECT cmdGlasses AS RxGlassesButton WITH Top=55,Left=160,Width=110,Height=36,Caption="Glasses"
    ADD OBJECT cmdCancel AS RxCloseButton WITH Top=105,Left=110,Width=80,Height=25,Caption="Cancel"
ENDDEFINE

DEFINE CLASS RxMedicationButton AS CommandButton
    PROCEDURE Click
        LOCAL loPatient
        loPatient=THISFORM.oPatient
        THISFORM.Release()
        =RxOpenMedication(loPatient,0)
    ENDPROC
ENDDEFINE

DEFINE CLASS RxGlassesButton AS CommandButton
    PROCEDURE Click
        LOCAL loPatient
        loPatient=THISFORM.oPatient
        THISFORM.Release()
        DO rxcenter WITH "GLASSES",loPatient,""
    ENDPROC
ENDDEFINE

DEFINE CLASS RxCloseButton AS CommandButton
    PROCEDURE Click
        THISFORM.Release()
    ENDPROC
ENDDEFINE


DEFINE CLASS RxGlassesForm AS Form
    Height=520
    Width=610
    AutoCenter=.T.
    BorderStyle=2
    MaxButton=.F.
    MinButton=.F.
    Caption="Glasses Rx"
    oPatient=.NULL.
    cRxId=""
    lReadOnly=.F.
    ADD OBJECT lblPatient AS Label WITH Top=8,Left=12,Width=580,Height=20,FontBold=.T.,Caption="Patient"
    ADD OBJECT lblDates AS Label WITH Top=38,Left=12,Width=90,Height=18,Caption="Exam / Issue:"
    ADD OBJECT txtExam AS TextBox WITH Top=35,Left=105,Width=85,Height=22,Value={}
    ADD OBJECT txtIssue AS TextBox WITH Top=35,Left=200,Width=85,Height=22,Value={}
    ADD OBJECT lblMD AS Label WITH Top=39,Left=305,Width=75,Height=18,Caption="Prescriber:"
    ADD OBJECT txtMD AS TextBox WITH Top=35,Left=380,Width=90,Height=22,Value=""
    ADD OBJECT lblHeader AS Label WITH Top=76,Left=15,Width=560,Height=18,Caption="Eye       Sphere       Cylinder       Axis       Add",FontBold=.T.
    ADD OBJECT lblOD AS Label WITH Top=105,Left=20,Width=30,Height=20,Caption="OD",FontBold=.T.
    ADD OBJECT txtODSph AS TextBox WITH Top=100,Left=75,Width=75,Height=24,Value=0.00,InputMask="999.99"
    ADD OBJECT txtODCyl AS TextBox WITH Top=100,Left=175,Width=75,Height=24,Value=0.00,InputMask="999.99"
    ADD OBJECT txtODAxis AS TextBox WITH Top=100,Left=275,Width=60,Height=24,Value=0,InputMask="999"
    ADD OBJECT txtODAdd AS TextBox WITH Top=100,Left=365,Width=75,Height=24,Value=0.00,InputMask="999.99"
    ADD OBJECT lblOS AS Label WITH Top=139,Left=20,Width=30,Height=20,Caption="OS",FontBold=.T.
    ADD OBJECT txtOSSph AS TextBox WITH Top=134,Left=75,Width=75,Height=24,Value=0.00,InputMask="999.99"
    ADD OBJECT txtOSCyl AS TextBox WITH Top=134,Left=175,Width=75,Height=24,Value=0.00,InputMask="999.99"
    ADD OBJECT txtOSAxis AS TextBox WITH Top=134,Left=275,Width=60,Height=24,Value=0,InputMask="999"
    ADD OBJECT txtOSAdd AS TextBox WITH Top=134,Left=365,Width=75,Height=24,Value=0.00,InputMask="999.99"
    ADD OBJECT lblPrism AS Label WITH Top=176,Left=15,Width=570,Height=18,Caption="Prism (optional):       Horizontal / Base                 Vertical / Base",FontBold=.T.
    ADD OBJECT txtODHP AS TextBox WITH Top=201,Left=75,Width=55,Height=22,Value=0.00
    ADD OBJECT txtODHB AS TextBox WITH Top=201,Left=135,Width=45,Height=22,Value=""
    ADD OBJECT txtODVP AS TextBox WITH Top=201,Left=250,Width=55,Height=22,Value=0.00
    ADD OBJECT txtODVB AS TextBox WITH Top=201,Left=310,Width=45,Height=22,Value=""
    ADD OBJECT txtOSHP AS TextBox WITH Top=231,Left=75,Width=55,Height=22,Value=0.00
    ADD OBJECT txtOSHB AS TextBox WITH Top=231,Left=135,Width=45,Height=22,Value=""
    ADD OBJECT txtOSVP AS TextBox WITH Top=231,Left=250,Width=55,Height=22,Value=0.00
    ADD OBJECT txtOSVB AS TextBox WITH Top=231,Left=310,Width=45,Height=22,Value=""
    ADD OBJECT lblPrismOD AS Label WITH Top=205,Left=20,Width=30,Height=18,Caption="OD"
    ADD OBJECT lblPrismOS AS Label WITH Top=235,Left=20,Width=30,Height=18,Caption="OS"
    ADD OBJECT lblPD AS Label WITH Top=271,Left=15,Width=60,Height=18,Caption="PD:"
    ADD OBJECT txtPDB AS TextBox WITH Top=267,Left=75,Width=60,Height=22,Value=0.00
    ADD OBJECT txtPDOD AS TextBox WITH Top=267,Left=145,Width=60,Height=22,Value=0.00
    ADD OBJECT txtPDOS AS TextBox WITH Top=267,Left=215,Width=60,Height=22,Value=0.00
    ADD OBJECT lblUse AS Label WITH Top=271,Left=295,Width=35,Height=18,Caption="Use:"
    ADD OBJECT txtUse AS TextBox WITH Top=267,Left=335,Width=155,Height=22,Value=""
    ADD OBJECT lblNotes AS Label WITH Top=306,Left=15,Width=50,Height=18,Caption="Notes:"
    ADD OBJECT edtNotes AS EditBox WITH Top=302,Left=75,Width=415,Height=55,Value=""
    ADD OBJECT lblSource AS Label WITH Top=366,Left=15,Width=110,Height=18,Caption="Imported source:"
    ADD OBJECT edtSource AS EditBox WITH Top=384,Left=15,Width=575,Height=65,Value="",ReadOnly=.T.
    ADD OBJECT cmdImport AS RxImportButton WITH Top=462,Left=15,Width=130,Height=28,Caption="Import from Word"
    ADD OBJECT cmdDraft AS RxDraftButton WITH Top=462,Left=170,Width=90,Height=28,Caption="Save Draft"
    ADD OBJECT cmdIssue AS RxIssueButton WITH Top=462,Left=270,Width=90,Height=28,Caption="Issue Rx"
    ADD OBJECT cmdPreview AS RxPreviewButton WITH Top=462,Left=370,Width=110,Height=28,Caption="Preview/Print"
    ADD OBJECT cmdClose AS RxCloseButton WITH Top=462,Left=500,Width=90,Height=28,Caption="Close"

    PROCEDURE LoadPatient
        THIS.lblPatient.Caption="Patient: "+RxPatientName(THIS.oPatient)+"     DOB: "+DTOC(THIS.oPatient.dob1.Value)
        THIS.txtIssue.Value=DATE()
        THIS.txtExam.Value=DATE()
        THIS.txtMD.Value=ALLTRIM(THIS.oPatient.combo2.DisplayValue)
        IF !EMPTY(THIS.cRxId)
            THIS.LoadExisting()
        ENDIF
    ENDPROC

    PROCEDURE LoadExisting
        LOCAL lcFile
        lcFile=ADDBS(path_to_data)+"rxoptical.dbf"
        USE (lcFile) SHARED AGAIN ALIAS rxview
        LOCATE FOR RX_ID==THIS.cRxId
        IF FOUND()
            THIS.txtIssue.Value=rxview.issue_date
            THIS.txtExam.Value=rxview.exam_date
            THIS.txtMD.Value=rxview.primary_md
            THIS.txtODSph.Value=rxview.od_sph
            THIS.txtODCyl.Value=rxview.od_cyl
            THIS.txtODAxis.Value=rxview.od_axis
            THIS.txtOSSph.Value=rxview.os_sph
            THIS.txtOSCyl.Value=rxview.os_cyl
            THIS.txtOSAxis.Value=rxview.os_axis
            THIS.txtODAdd.Value=rxview.od_add
            THIS.txtOSAdd.Value=rxview.os_add
            THIS.txtODHP.Value=rxview.od_hprism
            THIS.txtODHB.Value=rxview.od_hbase
            THIS.txtODVP.Value=rxview.od_vprism
            THIS.txtODVB.Value=rxview.od_vbase
            THIS.txtOSHP.Value=rxview.os_hprism
            THIS.txtOSHB.Value=rxview.os_hbase
            THIS.txtOSVP.Value=rxview.os_vprism
            THIS.txtOSVB.Value=rxview.os_vbase
            THIS.txtPDB.Value=rxview.pd_binoc
            THIS.txtPDOD.Value=rxview.pd_od
            THIS.txtPDOS.Value=rxview.pd_os
            THIS.txtUse.Value=rxview.use_type
            THIS.edtNotes.Value=rxview.notes
            THIS.edtSource.Value=rxview.source_txt
            IF UPPER(ALLTRIM(rxview.status))=="DRAFT"
                THIS.Caption="Glasses Rx - DRAFT"
                THIS.SetReadOnly(.F.)
            ELSE
                THIS.Caption="Glasses Rx - "+ALLTRIM(rxview.status)+" (read only)"
                THIS.SetReadOnly(.T.)
            ENDIF
        ENDIF
        USE IN rxview
    ENDPROC

    PROCEDURE SetReadOnly
        LPARAMETERS tlReadOnly
        LOCAL lnI, loControl
        THIS.lReadOnly=tlReadOnly
        FOR lnI=1 TO THIS.ControlCount
            loControl=THIS.Controls(lnI)
            IF INLIST(LOWER(loControl.BaseClass),"textbox","editbox")
                loControl.ReadOnly=tlReadOnly
            ENDIF
        ENDFOR
        THIS.cmdImport.Enabled=!tlReadOnly
        THIS.cmdDraft.Enabled=!tlReadOnly
        THIS.cmdIssue.Enabled=!tlReadOnly
    ENDPROC

    PROCEDURE SaveRx
        LPARAMETERS tcStatus
        LOCAL lcFile, lcId, lcUser, lcWork, llExisting
        IF !BETWEEN(VAL(THIS.txtODAxis.Value),0,180) OR !BETWEEN(VAL(THIS.txtOSAxis.Value),0,180)
            MESSAGEBOX("Axis must be between 0 and 180.",48,"MOSt - Glasses Rx")
            RETURN .F.
        ENDIF
        IF UPPER(tcStatus)=="ISSUED"
            IF EMPTY(THIS.txtMD.Value) OR EMPTY(THIS.txtIssue.Value)
                MESSAGEBOX("Prescriber and issue date are required.",48,"MOSt - Glasses Rx")
                RETURN .F.
            ENDIF
            IF MESSAGEBOX("Issue this glasses prescription? It will become read-only.",4+32+256,"MOSt - Glasses Rx")#6
                RETURN .F.
            ENDIF
        ENDIF
        lcFile=ADDBS(path_to_data)+"rxoptical.dbf"
        lcId=IIF(EMPTY(THIS.cRxId),SYS(2015),THIS.cRxId)
        lcUser=LEFT(GETENV("USERNAME"),30)
        lcWork=LEFT(GETENV("COMPUTERNAME"),30)
        USE (lcFile) SHARED AGAIN ALIAS rxsave
        llExisting=.F.
        IF !EMPTY(THIS.cRxId)
            LOCATE FOR rx_id==THIS.cRxId AND UPPER(ALLTRIM(status))=="DRAFT"
            llExisting=FOUND()
        ENDIF
        IF !llExisting
            APPEND BLANK
        ENDIF
        IF !RLOCK("rxsave")
            USE IN rxsave
            MESSAGEBOX("The prescription could not be locked for saving.",16,"MOSt - Glasses Rx")
            RETURN .F.
        ENDIF
        REPLACE rx_id WITH lcId, pat_id WITH INT(THIS.oPatient.id1.Value), ;
            issue_date WITH THIS.txtIssue.Value, exam_date WITH THIS.txtExam.Value, ;
            primary_md WITH ALLTRIM(THIS.txtMD.Value), status WITH UPPER(tcStatus), ;
            od_sph WITH VAL(THIS.txtODSph.Value), od_cyl WITH VAL(THIS.txtODCyl.Value), od_axis WITH VAL(THIS.txtODAxis.Value), ;
            os_sph WITH VAL(THIS.txtOSSph.Value), os_cyl WITH VAL(THIS.txtOSCyl.Value), os_axis WITH VAL(THIS.txtOSAxis.Value), ;
            od_add WITH VAL(THIS.txtODAdd.Value), os_add WITH VAL(THIS.txtOSAdd.Value), ;
            od_hprism WITH VAL(THIS.txtODHP.Value), od_hbase WITH ALLTRIM(THIS.txtODHB.Value), ;
            od_vprism WITH VAL(THIS.txtODVP.Value), od_vbase WITH ALLTRIM(THIS.txtODVB.Value), ;
            os_hprism WITH VAL(THIS.txtOSHP.Value), os_hbase WITH ALLTRIM(THIS.txtOSHB.Value), ;
            os_vprism WITH VAL(THIS.txtOSVP.Value), os_vbase WITH ALLTRIM(THIS.txtOSVB.Value), ;
            pd_binoc WITH VAL(THIS.txtPDB.Value), pd_od WITH VAL(THIS.txtPDOD.Value), pd_os WITH VAL(THIS.txtPDOS.Value), ;
            use_type WITH ALLTRIM(THIS.txtUse.Value), notes WITH THIS.edtNotes.Value, ;
            source_txt WITH THIS.edtSource.Value, created_at WITH DATETIME(), created_by WITH lcUser, workstn WITH lcWork IN rxsave
        UNLOCK IN rxsave
        FLUSH IN rxsave
        USE IN rxsave
        THIS.cRxId=lcId
        IF UPPER(tcStatus)=="ISSUED"
            THIS.Caption="Glasses Rx - ISSUED (read only)"
            THIS.SetReadOnly(.T.)
        ENDIF
        MESSAGEBOX("Glasses prescription saved as "+UPPER(tcStatus)+".",64,"MOSt - Glasses Rx")
        RETURN .T.
    ENDPROC

    PROCEDURE PreviewRx
        LOCAL lcFile, lcStatus, lcHtml, lcOD, lcOS, lcAdd, lcPrism, lcPD
        lcFile=ADDBS(SYS(2023))+"MOST_Glasses_Rx_"+IIF(EMPTY(THIS.cRxId),SYS(2015),THIS.cRxId)+".htm"
        lcStatus=IIF(THIS.lReadOnly,"ISSUED","DRAFT - NOT A VALID PRESCRIPTION")
        lcOD=TRANSFORM(THIS.txtODSph.Value)+"  "+TRANSFORM(THIS.txtODCyl.Value)+" x "+TRANSFORM(THIS.txtODAxis.Value)
        lcOS=TRANSFORM(THIS.txtOSSph.Value)+"  "+TRANSFORM(THIS.txtOSCyl.Value)+" x "+TRANSFORM(THIS.txtOSAxis.Value)
        lcAdd="OD "+TRANSFORM(THIS.txtODAdd.Value)+" / OS "+TRANSFORM(THIS.txtOSAdd.Value)
        lcPrism="OD H "+TRANSFORM(THIS.txtODHP.Value)+" "+THIS.txtODHB.Value+", V "+TRANSFORM(THIS.txtODVP.Value)+" "+THIS.txtODVB.Value+;
            " | OS H "+TRANSFORM(THIS.txtOSHP.Value)+" "+THIS.txtOSHB.Value+", V "+TRANSFORM(THIS.txtOSVP.Value)+" "+THIS.txtOSVB.Value
        lcPD="Binocular "+TRANSFORM(THIS.txtPDB.Value)+"; OD "+TRANSFORM(THIS.txtPDOD.Value)+"; OS "+TRANSFORM(THIS.txtPDOS.Value)
        lcHtml="<html><head><title>Glasses Prescription</title><style>body{font-family:Arial;margin:40px;color:#000}h1{font-size:24px}.status{font-weight:bold;color:#900}table{border-collapse:collapse;width:100%;margin-top:20px}th,td{border:1px solid #777;padding:10px;text-align:left}.sign{margin-top:55px;border-top:1px solid #000;width:320px}</style></head><body>"+;
            "<h1>Glasses Prescription</h1><p class='status'>"+RxHtml(lcStatus)+"</p>"+;
            "<p><b>Patient:</b> "+RxHtml(RxPatientName(THIS.oPatient))+" &nbsp; <b>DOB:</b> "+RxHtml(DTOC(THIS.oPatient.dob1.Value))+"</p>"+;
            "<p><b>Exam date:</b> "+RxHtml(DTOC(THIS.txtExam.Value))+" &nbsp; <b>Issue date:</b> "+RxHtml(DTOC(THIS.txtIssue.Value))+"</p>"+;
            "<table><tr><th>Eye</th><th>Sphere</th><th>Cylinder</th><th>Axis</th><th>Add</th></tr>"+;
            "<tr><td>OD</td><td>"+RxHtml(THIS.txtODSph.Value)+"</td><td>"+RxHtml(THIS.txtODCyl.Value)+"</td><td>"+RxHtml(THIS.txtODAxis.Value)+"</td><td>"+RxHtml(THIS.txtODAdd.Value)+"</td></tr>"+;
            "<tr><td>OS</td><td>"+RxHtml(THIS.txtOSSph.Value)+"</td><td>"+RxHtml(THIS.txtOSCyl.Value)+"</td><td>"+RxHtml(THIS.txtOSAxis.Value)+"</td><td>"+RxHtml(THIS.txtOSAdd.Value)+"</td></tr></table>"+;
            "<p><b>Prism:</b> "+RxHtml(lcPrism)+"</p><p><b>PD:</b> "+RxHtml(lcPD)+"</p><p><b>Use:</b> "+RxHtml(THIS.txtUse.Value)+"</p>"+;
            "<p><b>Notes:</b> "+RxHtml(THIS.edtNotes.Value)+"</p><p><b>Prescribing MD:</b> "+RxHtml(THIS.txtMD.Value)+"</p>"+;
            "<p class='sign'>Prescriber signature</p></body></html>"
        STRTOFILE(lcHtml,lcFile,0)
        DECLARE INTEGER ShellExecute IN shell32 INTEGER,STRING,STRING,STRING,STRING,INTEGER
        =ShellExecute(0,"open",lcFile,"","",1)
        RETURN .T.
    ENDPROC
ENDDEFINE

DEFINE CLASS RxImportButton AS CommandButton
    PROCEDURE Click
        LOCAL lcSource, ldDate, lnODS, lnODC, lnODA, lnOSS, lnOSC, lnOSA
        IF RxReadWordRefraction(@lcSource,@ldDate,@lnODS,@lnODC,@lnODA,@lnOSS,@lnOSC,@lnOSA)
            IF MESSAGEBOX("Complete refraction found:"+CHR(13)+;
                "OD "+TRANSFORM(lnODS)+" "+TRANSFORM(lnODC)+" x "+TRANSFORM(lnODA)+CHR(13)+;
                "OS "+TRANSFORM(lnOSS)+" "+TRANSFORM(lnOSC)+" x "+TRANSFORM(lnOSA)+CHR(13)+CHR(13)+;
                "Copy these values into the glasses prescription?",4+32+256,"MOSt - Confirm Refraction")=6
                THISFORM.txtODSph.Value=lnODS
                THISFORM.txtODCyl.Value=lnODC
                THISFORM.txtODAxis.Value=lnODA
                THISFORM.txtOSSph.Value=lnOSS
                THISFORM.txtOSCyl.Value=lnOSC
                THISFORM.txtOSAxis.Value=lnOSA
                THISFORM.edtSource.Value=lcSource
            ENDIF
        ENDIF
    ENDPROC
ENDDEFINE

DEFINE CLASS RxDraftButton AS CommandButton
    PROCEDURE Click
        =THISFORM.SaveRx("DRAFT")
    ENDPROC
ENDDEFINE

DEFINE CLASS RxIssueButton AS CommandButton
    PROCEDURE Click
        =THISFORM.SaveRx("ISSUED")
    ENDPROC
ENDDEFINE

DEFINE CLASS RxPreviewButton AS CommandButton
    PROCEDURE Click
        =THISFORM.PreviewRx()
    ENDPROC
ENDDEFINE


DEFINE CLASS RxHistoryForm AS Form
    Height=390
    Width=700
    AutoCenter=.T.
    BorderStyle=2
    MaxButton=.F.
    MinButton=.F.
    Caption="Prescription History"
    oPatient=.NULL.
    ADD OBJECT lblPatient AS Label WITH Top=8,Left=10,Width=670,Height=20,FontBold=.T.,Caption="Patient"
    ADD OBJECT grdHistory AS Grid WITH Top=35,Left=10,Width=680,Height=300,RecordSource="",DeleteMark=.F.,AllowAddNew=.F.,AllowDelete=.F.,AllowCellSelection=.F.,ReadOnly=.T.
    ADD OBJECT cmdView AS RxHistoryViewButton WITH Top=350,Left=490,Width=90,Height=27,Caption="View"
    ADD OBJECT cmdClose AS RxCloseButton WITH Top=350,Left=600,Width=90,Height=27,Caption="Close"

    PROCEDURE LoadHistory
        LOCAL lcRxFile, lcPresFile, lcGenFile, lcBrandFile
        THIS.lblPatient.Caption="Patient: "+RxPatientName(THIS.oPatient)+"     DOB: "+DTOC(THIS.oPatient.dob1.Value)
        CREATE CURSOR csrRxHistory (sortdate T, rxtype C(12), description C(90), prescriber C(12), status C(12), sourceid C(12), numid I)
        lcRxFile=ADDBS(path_to_data)+"rxoptical.dbf"
        IF FILE(lcRxFile)
            USE (lcRxFile) SHARED AGAIN ALIAS rxh
            SCAN FOR pat_id=INT(THIS.oPatient.id1.Value)
                INSERT INTO csrRxHistory VALUES (DTOT(rxh.issue_date),"GLASSES",;
                    "OD "+TRANSFORM(rxh.od_sph)+" "+TRANSFORM(rxh.od_cyl)+"x"+TRANSFORM(rxh.od_axis)+;
                    " / OS "+TRANSFORM(rxh.os_sph)+" "+TRANSFORM(rxh.os_cyl)+"x"+TRANSFORM(rxh.os_axis),;
                    rxh.primary_md,rxh.status,rxh.rx_id,0)
            ENDSCAN
            USE IN rxh
        ENDIF
        lcPresFile=ADDBS(path_to_data)+"prescription.dbf"
        lcGenFile=ADDBS(path_to_data)+"generic.dbf"
        lcBrandFile=ADDBS(path_to_data)+"brandname.dbf"
        IF FILE(lcPresFile)
            USE (lcPresFile) SHARED AGAIN ALIAS rxp
            IF FILE(lcGenFile)
                USE (lcGenFile) SHARED AGAIN ALIAS rxg
                SET ORDER TO TAG gener_id IN rxg
            ENDIF
            IF FILE(lcBrandFile)
                USE (lcBrandFile) SHARED AGAIN ALIAS rxb
                SET ORDER TO TAG brand_id IN rxb
            ENDIF
            SCAN FOR rxp.pat_id=INT(THIS.oPatient.id1.Value)
                LOCAL lcDesc
                lcDesc="Medication"
                IF USED("rxg") AND SEEK(rxp.gener_id,"rxg","gener_id")
                    lcDesc=ALLTRIM(rxg.gen_name)
                ENDIF
                IF USED("rxb") AND SEEK(rxp.brand_id,"rxb","brand_id") AND !EMPTY(rxb.brand_name)
                    lcDesc=lcDesc+" ("+ALLTRIM(rxb.brand_name)+")"
                ENDIF
                INSERT INTO csrRxHistory VALUES (rxp.date_rec,"MEDICATION",lcDesc,rxp.primary_md,"ISSUED","",rxp.presc_id)
            ENDSCAN
            USE IN rxp
            IF USED("rxg")
                USE IN rxg
            ENDIF
            IF USED("rxb")
                USE IN rxb
            ENDIF
        ENDIF
        SELECT csrRxHistory
        INDEX ON DTOS(TTOD(sortdate))+TTOC(sortdate,2) TAG rxdate DESCENDING
        GO TOP
        THIS.grdHistory.RecordSource="csrRxHistory"
        THIS.grdHistory.ColumnCount=5
        THIS.grdHistory.Columns(1).ControlSource="csrRxHistory.sortdate"
        THIS.grdHistory.Columns(1).Header1.Caption="Date"
        THIS.grdHistory.Columns(1).Width=105
        THIS.grdHistory.Columns(2).ControlSource="csrRxHistory.rxtype"
        THIS.grdHistory.Columns(2).Header1.Caption="Type"
        THIS.grdHistory.Columns(2).Width=85
        THIS.grdHistory.Columns(3).ControlSource="csrRxHistory.description"
        THIS.grdHistory.Columns(3).Header1.Caption="Prescription"
        THIS.grdHistory.Columns(3).Width=310
        THIS.grdHistory.Columns(4).ControlSource="csrRxHistory.prescriber"
        THIS.grdHistory.Columns(4).Header1.Caption="MD"
        THIS.grdHistory.Columns(4).Width=65
        THIS.grdHistory.Columns(5).ControlSource="csrRxHistory.status"
        THIS.grdHistory.Columns(5).Header1.Caption="Status"
        THIS.grdHistory.Columns(5).Width=85
        THIS.grdHistory.Refresh()
    ENDPROC

    PROCEDURE Destroy
        IF USED("csrRxHistory")
            USE IN csrRxHistory
        ENDIF
        DODEFAULT()
    ENDPROC
ENDDEFINE

DEFINE CLASS RxHistoryViewButton AS CommandButton
    PROCEDURE Click
        LOCAL lcType, lcId, lnId, loPatient
        IF !USED("csrRxHistory") OR RECCOUNT("csrRxHistory")=0
            RETURN
        ENDIF
        SELECT csrRxHistory
        lcType=ALLTRIM(rxtype)
        lcId=ALLTRIM(sourceid)
        lnId=numid
        loPatient=THISFORM.oPatient
        THISFORM.Hide()
        IF lcType=="GLASSES"
            DO rxcenter WITH "GLASSES",loPatient,lcId
        ELSE
            =RxOpenMedication(loPatient,lnId)
        ENDIF
        THISFORM.Show()
    ENDPROC
ENDDEFINE
