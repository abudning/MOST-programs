CLEAR ALL
SET EXCLUSIVE OFF
SET SAFETY OFF
SET TALK OFF
SET MULTILOCKS ON
SET RESOURCE OFF
PUBLIC path_to_data
LOCAL loEntry,lcPreview,lcHtml
LOCAL lcRepo,lcRoot,lcFixture,lcError,lnBill,lnSecond,lnBad,lnBefore,loError,lnI
LOCAL ARRAY laLines[5,2]
lcRepo=ADDBS(FULLPATH(""))
lcRoot=ADDBS(SYS(2023))
lcFixture=lcRoot+"tp_fixture_"+SYS(2015)+"\"
MD (lcFixture)
SET DEFAULT TO (lcFixture)
SET PROCEDURE TO (FULLPATH("development_v16_64\PROGRAMS\thirdparty_store.prg",lcRepo)) ADDITIVE
SET PROCEDURE TO (FULLPATH("development_v16_64\PROGRAMS\thirdparty_freehand.prg",lcRepo)) ADDITIVE
TRY
    CREATE DATABASE fixture
    CREATE TABLE guarantor (id N(6),lname C(30),fname C(20),institutn C(40),comments M)
    CREATE TABLE claims (id N(6),type C(1),serv_date D,num_serv N(2),service C(5),;
        billing_md C(2),fee_submited N(9,2),fee_paid N(9,2),guarantor N(6),entry_date D)
    CREATE TABLE parameter (data N(8))
    INSERT INTO parameter VALUES (0)
    INSERT INTO parameter VALUES (1)
    INSERT INTO parameter VALUES (0)
    INSERT INTO parameter VALUES (1)
    CREATE TABLE patients (id N(6),surname C(30),firstname C(20),inactive L)
    INSERT INTO patients VALUES (1,"TEST","PATIENT",.F.)
    CREATE TABLE md (mnemonic C(2))
    INSERT INTO md VALUES ("AB")
    CLOSE TABLES ALL
    path_to_data=lcFixture
    FOR lnI=1 TO 5
        laLines[lnI,1]=""
        laLines[lnI,2]=0
    ENDFOR
    laLines[1,1]="Contact lens"
    laLines[1,2]=125.25
    laLines[2,1]="Fitting"
    laLines[2,2]=40.50
    lnBill=TpSaveBill(lcFixture,1,"AB",DATE(),@laLines,@lcError)
    IF lnBill#1
        ERROR "First save failed: "+lcError
    ENDIF
    USE claims IN 0 SHARED
    IF claims.type#"T" OR claims.fee_submited#165.75 OR claims.guarantor#1
        ERROR "Saved claim total or link incorrect."
    ENDIF
    USE IN claims
    lnSecond=TpSaveBill(lcFixture,1,"AB",DATE(),@laLines,@lcError)
    IF lnSecond#2
        ERROR "Second invoice number not unique: "+lcError
    ENDIF
    laLines[1,1]=""
    lnBad=TpSaveBill(lcFixture,1,"AB",DATE(),@laLines,@lcError)
    IF lnBad#0 OR EMPTY(lcError)
        ERROR "Invalid line accepted."
    ENDIF
    laLines[1,1]="Contact lens"
    lnBad=TpSaveBill(lcFixture,999,"AB",DATE(),@laLines,@lcError)
    IF lnBad#0
        ERROR "Missing patient accepted."
    ENDIF
    laLines[1,2]=300
    * Force the second write to fail and verify the detail write is rolled back.
    USE claims EXCLUSIVE IN 0
    ALTER TABLE claims SET CHECK fee_submited < 200 ERROR "Synthetic failure"
    USE IN claims
    lnBad=TpSaveBill(lcFixture,1,"AB",DATE(),@laLines,@lcError)
    IF lnBad#0
        ERROR "Synthetic claim failure was not reported."
    ENDIF
    USE guarantor IN 0 SHARED
    COUNT FOR !DELETED() TO lnBefore
    IF lnBefore#2
        ERROR "Failed save left orphan billing details."
    ENDIF
    USE parameter IN 0 SHARED
    SELECT parameter
    GOTO 4
    IF data#3
        ERROR "Failed save changed invoice number counter."
    ENDIF
    * Exercise actual form construction, total calculation, and saved memo rendering.
    loEntry=CREATEOBJECT("TpEntryForm",1,"AB")
    loEntry.amount1.Value=125.25
    loEntry.amount2.Value=40.50
    loEntry.UpdateTotal()
    IF !("165.75"$loEntry.total.Caption)
        ERROR "Form total did not update."
    ENDIF
    loEntry.Release()
    IF !("Contact lens"$TpBillMemo(1)) OR !("Fitting"$TpBillMemo(1))
        ERROR "Stored descriptions could not be retrieved."
    ENDIF
    CREATE CURSOR invoice (id N(6),firstname C(20),surname C(30),address C(35),city C(20),prov C(2),postal C(6),;
        md_firs C(15),md_surn C(25),serv_date D,service C(5),feedesc C(45),fee_submit N(9,2),fee_paid N(9,2),guarantor N(6))
    INSERT INTO invoice VALUES (1,"PATIENT","TEST","1 Test Street","Test City","ON","A1A1A1","Test","Doctor",DATE(),"TPBLA","",165.75,40.50,1)
    lcPreview=TpPreviewInvoice(.T.)
    lcHtml=FILETOSTR(lcPreview)
    IF !("Contact lens"$lcHtml) OR !("Fitting"$lcHtml) OR !("125.25"$lcHtml) OR "Guarantor"$lcHtml
        ERROR "Invoice preview lost service lines or payment balance."
    ENDIF
    STRTOFILE(lcHtml,lcRoot+"tp_synthetic_preview.htm",0)
    * Simulate the existing SCATTER/GATHER move to paid history and reprint it.
    SELECT invoice
    REPLACE fee_paid WITH fee_submit
    SCATTER MEMVAR
    CREATE CURSOR tphistory (id N(6),guarantor N(6),fee_submit N(9,2),fee_paid N(9,2))
    APPEND BLANK
    GATHER MEMVAR
    IF tphistory.guarantor#1 OR EMPTY(TpBillMemo(tphistory.guarantor))
        ERROR "Paid-history transfer lost manual invoice details."
    ENDIF
    SELECT invoice
    lcPreview=TpPreviewInvoice(.T.)
    IF !("Balance due: $0.00"$FILETOSTR(lcPreview))
        ERROR "Paid invoice preview did not show zero balance."
    ENDIF
    REPLACE fee_paid WITH 200 IN invoice
    lcPreview=TpPreviewInvoice(.T.)
    IF !("Credit balance: $34.25"$FILETOSTR(lcPreview))
        ERROR "Overpaid invoice did not show a credit balance."
    ENDIF
    FOR lnI=1 TO 5
        laLines[lnI,1]="Service "+TRANSFORM(lnI)+" & <review>"
        laLines[lnI,2]=1.25
    ENDFOR
    lnBill=TpSaveBill(lcFixture,1,"AB",DATE(),@laLines,@lcError)
    IF lnBill#3
        ERROR "Five-line invoice was not saved: "+lcError
    ENDIF
    SELECT invoice
    REPLACE guarantor WITH lnBill, fee_submit WITH 6.25, fee_paid WITH 0
    lcPreview=TpPreviewInvoice(.T.)
    lcHtml=FILETOSTR(lcPreview)
    FOR lnI=1 TO 5
        IF !("Service "+TRANSFORM(lnI)+" &amp; &lt;review&gt;"$lcHtml)
            ERROR "Five-line preview lost a line or HTML escaping."
        ENDIF
    ENDFOR
    IF !("Balance due: $6.25"$lcHtml) OR !("window.print()"$lcHtml) OR RECNO("invoice")#1
        ERROR "Print control, total, or invoice cursor position incorrect."
    ENDIF
    STRTOFILE("PASS: five lines, HTML escaping, print control, credit balance, form, partial/paid preview, history link, save, cents, unique IDs, validation, and rollback"+CHR(13)+CHR(10)+lcFixture,lcRoot+"tp_store_test.log",0)
CATCH TO loError
    STRTOFILE("FAIL: "+loError.Message+" line "+TRANSFORM(loError.LineNo)+CHR(13)+CHR(10)+lcFixture,lcRoot+"tp_store_test.log",0)
ENDTRY
CLOSE DATABASES ALL
QUIT






