* Manual invoice storage, V16.64. Existing shared database structure is retained.
* Each invoice is one type-T claim. Guarantor.comments holds its five detail lines.
FUNCTION TpSaveBill
LPARAMETERS tcPath, tnPatient, tcMD, tdService, taLines, tcError
EXTERNAL ARRAY taLines
LOCAL lnArea, lnBill, lnI, lnCount, lnTotal, lcMemo, lcDescription
LOCAL loError, llTransaction
LOCAL ARRAY laMax[1]
tcError=""
lnArea=SELECT()
llTransaction=.F.
lnBill=0
lnCount=0
lnTotal=0
IF VARTYPE(tnPatient)#"N" OR tnPatient<=0 OR EMPTY(tcMD) OR EMPTY(tdService)
    tcError="Select a patient, billing physician, and service date."
    RETURN 0
ENDIF
IF ALEN(taLines,1)>5 OR ALEN(taLines,2)#2
    tcError="An invoice may contain up to five service lines."
    RETURN 0
ENDIF
lcMemo="MOST-THIRDPARTY-1"+CHR(13)+CHR(10)
FOR lnI=1 TO ALEN(taLines,1)
    lcDescription=ALLTRIM(taLines[lnI,1])
    IF EMPTY(lcDescription) AND taLines[lnI,2]=0
        LOOP
    ENDIF
    IF EMPTY(lcDescription) OR LEN(lcDescription)>80 OR ;
        taLines[lnI,2]<=0 OR taLines[lnI,2]>99999.99 OR ;
        ROUND(taLines[lnI,2],2)#taLines[lnI,2] OR ;
        CHR(13)$lcDescription OR CHR(10)$lcDescription OR CHR(9)$lcDescription
        tcError="Each service needs a description and a positive fee with at most two decimal places."
        RETURN 0
    ENDIF
    lnCount=lnCount+1
    lnTotal=lnTotal+taLines[lnI,2]
    lcMemo=lcMemo+lcDescription+CHR(9)+ALLTRIM(STR(taLines[lnI,2],12,2))+CHR(13)+CHR(10)
ENDFOR
IF lnCount=0 OR lnTotal>99999.99
    tcError="Enter at least one service. Invoice total must not exceed $99,999.99."
    RETURN 0
ENDIF
TRY
    IF TXNLEVEL()>0
        ERROR "Finish the current database operation before saving an invoice."
    ENDIF
    USE (ADDBS(tcPath)+"guarantor.dbf") AGAIN SHARED IN 0 ALIAS tpstore
    USE (ADDBS(tcPath)+"claims.dbf") AGAIN SHARED IN 0 ALIAS tpclaims
    USE (ADDBS(tcPath)+"parameter.dbf") AGAIN SHARED IN 0 ALIAS tpseq
    USE (ADDBS(tcPath)+"patients.dbf") AGAIN SHARED IN 0 ALIAS tppatient
    USE (ADDBS(tcPath)+"md.dbf") AGAIN SHARED IN 0 ALIAS tpmd
    SELECT tppatient
    LOCATE FOR id=m.tnPatient AND !DELETED()
    IF !FOUND() OR tppatient.inactive
        ERROR "The selected patient is missing or inactive."
    ENDIF
    SELECT tpmd
    LOCATE FOR ALLTRIM(mnemonic)==ALLTRIM(m.tcMD) AND payment<>0 AND !DELETED()
    IF !FOUND()
        ERROR "Select an active billing physician."
    ENDIF
    IF EMPTY(CURSORGETPROP("Database","tpclaims")) OR ;
        UPPER(CURSORGETPROP("Database","tpclaims"))#UPPER(CURSORGETPROP("Database","tpstore")) OR ;
        UPPER(CURSORGETPROP("Database","tpclaims"))#UPPER(CURSORGETPROP("Database","tpseq"))
        ERROR "Invoice storage and Claims must belong to the same MOSt database."
    ENDIF
    SELECT tpseq
    IF RECCOUNT()<4
        ERROR "The invoice number counter is missing."
    ENDIF
    GOTO 4
    IF !RLOCK("4","tpseq")
        ERROR "Another workstation is allocating an invoice number. Please retry."
    ENDIF
    SELECT tpstore
    IF !FLOCK("tpstore")
        ERROR "Another workstation is saving billing details. Please retry."
    ENDIF
    SELECT MAX(id) FROM tpstore INTO ARRAY laMax
    lnBill=MAX(1,INT(tpseq.data),NVL(laMax[1],0)+1)
    IF lnBill>=999999
        ERROR "The billing number range is exhausted."
    ENDIF
    BEGIN TRANSACTION
    llTransaction=.T.
    INSERT INTO tpstore (id,lname,fname,institutn,comments) VALUES ;
        (m.lnBill,tppatient.surname,tppatient.firstname,"Third Party Billing",m.lcMemo)
    INSERT INTO tpclaims (id,type,serv_date,num_serv,service,billing_md,fee_submited,fee_paid,guarantor,entry_date) ;
        VALUES (m.tnPatient,"T",m.tdService,1,"TPBLA",m.tcMD,m.lnTotal,0,m.lnBill,DATE())
    REPLACE data WITH m.lnBill+1 IN tpseq
    END TRANSACTION
    llTransaction=.F.
CATCH TO loError
    IF llTransaction
        ROLLBACK
    ENDIF
    lnBill=0
    tcError=loError.Message
FINALLY
    IF USED("tpstore")
        USE IN tpstore
    ENDIF
    IF USED("tpclaims")
        USE IN tpclaims
    ENDIF
    IF USED("tpseq")
        USE IN tpseq
    ENDIF
    IF USED("tppatient")
        USE IN tppatient
    ENDIF
    IF USED("tpmd")
        USE IN tpmd
    ENDIF
    SELECT (lnArea)
ENDTRY
RETURN lnBill
ENDFUNC

FUNCTION TpBillMemo
LPARAMETERS tnBill
LOCAL lnArea,lcMemo
lcMemo=""
IF ISNULL(tnBill) OR VARTYPE(tnBill)#"N" OR tnBill<=0
    RETURN lcMemo
ENDIF
lnArea=SELECT()
TRY
    USE (ADDBS(path_to_data)+"guarantor.dbf") AGAIN SHARED IN 0 ALIAS tplookup
    SELECT tplookup
    LOCATE FOR id=m.tnBill AND !DELETED()
    IF FOUND() AND LEFT(comments,LEN("MOST-THIRDPARTY-1"))=="MOST-THIRDPARTY-1"
        lcMemo=comments
    ENDIF
FINALLY
    IF USED("tplookup")
        USE IN tplookup
    ENDIF
    SELECT (lnArea)
ENDTRY
RETURN lcMemo
ENDFUNC

FUNCTION TpDescription
LPARAMETERS tnBill,tcDefault
LOCAL lcMemo,lcLine
lcMemo=TpBillMemo(tnBill)
IF EMPTY(lcMemo)
    RETURN tcDefault
ENDIF
lcLine=GETWORDNUM(lcMemo,2,CHR(13)+CHR(10))
RETURN LEFT("Invoice #"+TRANSFORM(tnBill)+": "+GETWORDNUM(lcLine,1,CHR(9)),45)
ENDFUNC

FUNCTION TpHtml
LPARAMETERS tcText
LOCAL lcText
lcText=TRANSFORM(NVL(tcText,""))
lcText=STRTRAN(lcText,"&","&amp;")
lcText=STRTRAN(lcText,"<","&lt;")
lcText=STRTRAN(lcText,">","&gt;")
lcText=STRTRAN(lcText,CHR(34),"&quot;")
RETURN lcText
ENDFUNC

FUNCTION TpPreviewInvoice
LPARAMETERS tlNoOpen
LOCAL lnArea,lnRecord,lcHtml,lcFile,lcMemo,lcLine,lnI,lnTotal,lnPaid,loPreview,loError
LOCAL ARRAY laText[1]
lnArea=SELECT()
SELECT invoice
lnRecord=RECNO()
GO TOP
IF EOF()
    SELECT (lnArea)
    RETURN ""
ENDIF
lcHtml="<html><head><meta http-equiv='Content-Type' content='text/html; charset=windows-1252'>"
lcHtml=lcHtml+"<title>Third Party Invoice</title><style>body{font-family:Arial;margin:30px;color:#000}"
lcHtml=lcHtml+".office{text-align:center;line-height:1.4}.meta{width:100%;margin:18px 0}.meta td{border:0;padding:3px}h1{font-size:22px}"
lcHtml=lcHtml+"table{width:100%;border-collapse:collapse}th,td{padding:8px;border:1px solid #bbb;text-align:left}th{background:#e9eef5}.money{text-align:right;white-space:nowrap}"
lcHtml=lcHtml+".totals{text-align:right;line-height:1.8;margin-top:20px}.footer{margin-top:35px;text-align:center;font-size:11px}@media print{.tools{display:none}body{margin:10mm}}</style></head><body>"
lcHtml=lcHtml+"<div class='tools'><button type='button' onclick='window.print()'>Print invoice</button> &nbsp; You can also use Ctrl+P.</div>"
lcHtml=lcHtml+"<div class='office'><b>Dr. "+TpHtml(ALLTRIM(invoice.md_firs)+" "+ALLTRIM(invoice.md_surn))+"</b>"
IF TYPE("invoice.md_address")="C"
    lcHtml=lcHtml+"<br>"+TpHtml(ALLTRIM(invoice.md_address))
ENDIF
IF TYPE("invoice.md_city")="C" AND TYPE("invoice.md_prov")="C" AND TYPE("invoice.md_postal")="C"
    lcHtml=lcHtml+"<br>"+TpHtml(ALLTRIM(invoice.md_city)+" "+ALLTRIM(invoice.md_prov)+" "+ALLTRIM(invoice.md_postal))
ENDIF
IF TYPE("invoice.md_phone_w")="C"
    lcHtml=lcHtml+"<br>Tel: "+TpHtml(ALLTRIM(invoice.md_phone_w))
ENDIF
lcHtml=lcHtml+"</div><hr>"
lcHtml=lcHtml+"<h1>Third Party Invoice</h1><table class='meta'><tr><td><b>DATE:</b> "+TpHtml(DTOC(invoice.serv_date))+"</td><td><b>INVOICE #:</b> "+TpHtml(invoice.guarantor)+"</td></tr><tr><td><b>Customer ID:</b> "+TpHtml(invoice.id)+"</td><td><b>Payment Terms:</b> Due on receipt</td></tr></table><p><b>To:</b><br>"
lcHtml=lcHtml+TpHtml(ALLTRIM(invoice.address))+"<br>"+TpHtml(ALLTRIM(invoice.city)+" "+ALLTRIM(invoice.prov)+" "+ALLTRIM(invoice.postal))+"</p>"
lcHtml=lcHtml+"<p><b>Patient Name:</b> "+TpHtml(ALLTRIM(invoice.firstname)+" "+ALLTRIM(invoice.surname))+"<br><b>Billing MD:</b> "+TpHtml(ALLTRIM(invoice.md_firs)+" "+ALLTRIM(invoice.md_surn))+"</p>"
lcHtml=lcHtml+"<table><thead><tr><th>Qty</th><th>Description</th><th class='money'>Unit Price</th><th class='money'>Line Total</th></tr></thead><tbody>"
lnTotal=0
lnPaid=0
SCAN
    lnTotal=lnTotal+invoice.fee_submit
    lnPaid=lnPaid+invoice.fee_paid
    lcMemo=TpBillMemo(invoice.guarantor)
    IF EMPTY(lcMemo)
        lcHtml=lcHtml+"<tr><td>"+ALLTRIM(STR(MAX(1,invoice.num_serv),12,0))+"</td><td>"+TpHtml(ALLTRIM(invoice.service)+" - "+ALLTRIM(invoice.feedesc))+"</td><td class='money'>$"+ALLTRIM(STR(invoice.fee_submit/MAX(1,invoice.num_serv),12,2))+"</td><td class='money'>$"+ALLTRIM(STR(invoice.fee_submit,12,2))+"</td></tr>"
    ELSE
        lcHtml=lcHtml+"<tr><td>1</td><td colspan='3'><b>Invoice #"+TRANSFORM(invoice.guarantor)+"</b></td></tr>"
        =ALINES(laText,lcMemo,.T.)
        FOR lnI=2 TO ALEN(laText)
            lcLine=laText[lnI]
            IF !EMPTY(lcLine)
                lcHtml=lcHtml+"<tr><td>1</td><td>"+TpHtml(GETWORDNUM(lcLine,1,CHR(9)))+"</td><td class='money'>$"+TpHtml(GETWORDNUM(lcLine,2,CHR(9)))+"</td><td class='money'>$"+TpHtml(GETWORDNUM(lcLine,2,CHR(9)))+"</td></tr>"
            ENDIF
        ENDFOR
    ENDIF
ENDSCAN
GO TOP
lcHtml=lcHtml+"</tbody></table><div class='totals'>Subtotal: $"+ALLTRIM(STR(lnTotal,12,2))+"<br>Paid: $"+ALLTRIM(STR(lnPaid,12,2))+"<br><b>"+;
    IIF(lnPaid>lnTotal,"Credit balance: $","Balance due: $")+ALLTRIM(STR(ABS(lnTotal-lnPaid),12,2))+"</b></div><div class='footer'><b>Make all checks payable to Dr. "+TpHtml(ALLTRIM(invoice.md_firs)+" "+ALLTRIM(invoice.md_surn))+"</b><br>"+TpHtml(ALLTRIM(invoice.md_address))+" | Telephone: "+TpHtml(ALLTRIM(invoice.md_phone_w))+"</div></body></html>"
IF lnRecord<=RECCOUNT()
    GOTO lnRecord
ENDIF
SELECT (lnArea)
lcFile=ADDBS(SYS(2023))+"MOST_ThirdParty_"+SYS(2015)+".htm"
STRTOFILE(lcHtml,lcFile,0)
IF !tlNoOpen
    TRY
        loPreview=CREATEOBJECT("TpInvoicePreview",lcFile)
        loPreview.Show(1)
        loPreview.Release()
    CATCH TO loError
        MESSAGEBOX("The saved invoice could not be opened for printing. "+loError.Message,48,"Third Party Billing")
    ENDTRY
ENDIF
RETURN lcFile
ENDFUNC

DEFINE CLASS TpInvoicePreview AS Form
    Caption="Invoice review - V16.64.4 TEST"
    Width=1000
    Height=720
    AutoCenter=.T.
    ADD OBJECT browser AS OleControl WITH OleClass="Shell.Explorer.2",Left=140,Top=10,Width=840,Height=680
    ADD OBJECT printButton AS TpInvoicePrint WITH Caption="Print invoice",Left=10,Top=18,Width=115,Height=32
    ADD OBJECT exitInvoice AS TpInvoiceExit WITH Caption="Exit",Left=10,Top=58,Width=115,Height=32,Cancel=.T.
    ADD OBJECT help AS Label WITH Caption="Ctrl+P also works inside the invoice.",Left=10,Top=105,Width=115,WordWrap=.T.
    PROCEDURE Init
        LPARAMETERS tcFile
        THIS.browser.Object.Silent=.F.
        THIS.browser.Object.Navigate(FULLPATH(tcFile))
    ENDPROC
    PROCEDURE PrintInvoice
        LOCAL loError
        IF THIS.browser.Object.Busy OR THIS.browser.Object.ReadyState<>4
            MESSAGEBOX("Please wait for the invoice to finish loading.",64,"Invoice printing")
            RETURN
        ENDIF
        TRY
            THIS.browser.SetFocus()
            THIS.browser.Object.ExecWB(6,1)
        CATCH TO loError
            TRY
                THIS.browser.Object.Document.parentWindow.print()
            CATCH
                MESSAGEBOX("Click inside the invoice and press Ctrl+P to open the print dialog."+CHR(13)+loError.Message,48,"Invoice printing")
            ENDTRY
        ENDTRY
    ENDPROC
    PROCEDURE QueryUnload
        NODEFAULT
        THIS.Hide()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpInvoicePrint AS CommandButton
    PROCEDURE Click
        THISFORM.PrintInvoice()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpInvoiceExit AS CommandButton
    PROCEDURE Click
        THISFORM.Hide()
    ENDPROC
ENDDEFINE
