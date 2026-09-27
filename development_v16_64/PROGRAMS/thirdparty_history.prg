FUNCTION TpShowPaidHistory
LPARAMETERS tnPatient
LOCAL loHistory,loError
SET PROCEDURE TO thirdparty_store ADDITIVE
TRY
    loHistory=CREATEOBJECT("TpPaidHistory",tnPatient)
    loHistory.Show(1)
    loHistory.Release()
CATCH TO loError
    MESSAGEBOX("Paid history could not be opened. "+loError.Message,48,"Third Party Billing")
ENDTRY
RETURN
ENDFUNC

DEFINE CLASS TpPaidHistory AS Form
    Caption="Paid third party billing history - V16.64.4 TEST"
    DataSession=2
    Width=850
    Height=470
    AutoCenter=.T.
    nPatient=0
    nHistoryRows=0
    ADD OBJECT patientTitle AS Label WITH Left=15,Top=15,Width=800,Height=24,FontBold=.T.
    ADD OBJECT historyGrid AS Grid WITH Left=15,Top=50,Width=815,Height=320,ReadOnly=.T.,DeleteMark=.F.,RecordMark=.F.,ColumnCount=6
    ADD OBJECT summary AS Label WITH Left=15,Top=385,Width=800,Height=24
    ADD OBJECT previewButton AS TpHistoryPreview WITH Left=535,Top=420,Width=175,Height=30,Caption="Review / Print selected"
    ADD OBJECT closeButton AS TpHistoryClose WITH Left=725,Top=420,Width=100,Height=30,Caption="Exit",Cancel=.T.
    PROCEDURE Init
        LPARAMETERS tnPatient
        LOCAL lnI,lcPath
        THIS.nPatient=tnPatient
        lcPath=ADDBS(path_to_data)
        USE (lcPath+"submited.dbf") AGAIN SHARED NOUPDATE IN 0 ALIAS tphsubmitted
        USE (lcPath+"patients.dbf") AGAIN SHARED NOUPDATE IN 0 ALIAS tphpatient
        USE (lcPath+"md.dbf") AGAIN SHARED NOUPDATE IN 0 ALIAS tphmd
        USE (lcPath+"fees.dbf") AGAIN SHARED NOUPDATE IN 0 ALIAS tphfees
        SELECT tphpatient
        LOCATE FOR id=m.tnPatient AND !DELETED()
        THIS.patientTitle.Caption="Patient #"+TRANSFORM(tnPatient)+": "+ALLTRIM(firstname)+" "+ALLTRIM(surname)
        SELECT h.id,h.serv_date,h.service,h.num_serv,h.billing_md,;
            h.fee_submited AS fee_submit,h.fee_paid,h.guarantor,h.status,;
            NVL(f.feedesc,"") AS feedesc,;
            h.fee_submited-h.fee_paid AS balance,;
            p.firstname,p.surname,p.address,p.city,p.province AS prov,p.postal,;
            NVL(d.firstname,"") AS md_firs,NVL(d.surname,"") AS md_surn,;
            NVL(d.address,"") AS md_address,NVL(d.city,"") AS md_city,;
            "ON" AS md_prov,NVL(d.postal,"") AS md_postal,;
            NVL(d.phone_work,"") AS md_phone_w ;
            FROM tphsubmitted h JOIN tphpatient p ON h.id=p.id ;
            LEFT JOIN tphmd d ON h.billing_md=d.mnemonic ;
            LEFT JOIN tphfees f ON LEFT(h.service,4)=ALLTRIM(f.service) ;
            WHERE h.id=m.tnPatient AND h.type="T" AND !DELETED("h") ;
            AND UPPER(ALLTRIM(NVL(h.status,"")))<>"DELET" ;
            ORDER BY h.serv_date DESC,h.guarantor DESC INTO CURSOR invoice READWRITE
        SELECT invoice
        SCAN
            REPLACE feedesc WITH TpDescription(guarantor,feedesc)
        ENDSCAN
        GO TOP
        WITH THIS.historyGrid
            .RecordSource="invoice"
            .Column1.ControlSource="invoice.serv_date"
            .Column1.Header1.Caption="Service date"
            .Column1.Width=100
            .Column2.ControlSource="invoice.guarantor"
            .Column2.Header1.Caption="Invoice #"
            .Column2.Width=90
            .Column3.ControlSource="invoice.feedesc"
            .Column3.Header1.Caption="Description"
            .Column3.Width=285
            .Column4.ControlSource="invoice.fee_submit"
            .Column4.Header1.Caption="Fee"
            .Column4.Width=105
            .Column5.ControlSource="invoice.fee_paid"
            .Column5.Header1.Caption="Paid"
            .Column5.Width=105
            .Column6.ControlSource="invoice.balance"
            .Column6.Header1.Caption="Balance"
            .Column6.Width=100
        ENDWITH
        THIS.previewButton.Enabled=RECCOUNT("invoice")>0
        THIS.nHistoryRows=RECCOUNT("invoice")
        THIS.summary.Caption=IIF(RECCOUNT("invoice")=0,;
            "No paid third party history was found for this patient.",;
            TRANSFORM(RECCOUNT("invoice"))+" saved history lines. Select an invoice to review or print.")
    ENDPROC
    PROCEDURE PreviewSelected
        LPARAMETERS tlNoOpen
        LOCAL lnRecord,lnInvoice,lcMD,lcFile,lcFilter
        SELECT invoice
        IF EOF() OR RECCOUNT()=0
            RETURN
        ENDIF
        lnRecord=RECNO()
        lnInvoice=NVL(guarantor,0)
        lcMD=billing_md
        TRY
            IF lnInvoice>0
                lcFilter="NVL(invoice.guarantor,0)="+TRANSFORM(lnInvoice)+" AND invoice.billing_md='"+STRTRAN(lcMD,"'","''")+"'"
            ELSE
                lcFilter='RECNO("invoice")='+TRANSFORM(lnRecord)
            ENDIF
            SET FILTER TO &lcFilter
            lcFile=TpPreviewInvoice(tlNoOpen)
        FINALLY
            SELECT invoice
            SET FILTER TO
            GO lnRecord
        ENDTRY
        RETURN lcFile
    ENDPROC
    PROCEDURE QueryUnload
        NODEFAULT
        THIS.Hide()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpHistoryPreview AS CommandButton
    PROCEDURE Click
        THISFORM.PreviewSelected()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpHistoryClose AS CommandButton
    PROCEDURE Click
        THISFORM.Hide()
    ENDPROC
ENDDEFINE
