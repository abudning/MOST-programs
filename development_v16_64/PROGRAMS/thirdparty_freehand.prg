* V16.64 Third Party Billing - free-hand bill scaffold
* The physical Guarantor table remains compatible with existing history.

FUNCTION EnsureThirdPartyLines
LPARAMETERS tcDataPath
LOCAL lcFile
lcFile=ADDBS(tcDataPath)+"thirdparty_lines.dbf"
IF !FILE(lcFile)
    CREATE TABLE (lcFile) (BILL_ID C(16), LINE_NO N(2), DESCRIPTION C(80), AMOUNT N(10,2))
ENDIF
RETURN lcFile
ENDFUNC

DEFINE CLASS ThirdPartyFreehandForm AS Form
    Caption="Third Party Billing"
    Width=620
    Height=390
    AutoCenter=.T.
    WindowType=1
    cBillId=""
    nPatientId=0

    ADD OBJECT lblTitle AS Label WITH Caption="Third Party Billing", Left=15, Top=12, Width=250, FontBold=.T., FontSize=14
    ADD OBJECT lblPatient AS Label WITH Caption="Patient:", Left=15, Top=42, Width=560
    ADD OBJECT grdLines AS Grid WITH Left=15, Top=70, Width=580, Height=220, ColumnCount=2, RecordSource="csrThirdPartyLines"
    ADD OBJECT lblTotal AS Label WITH Caption="Total: $0.00", Left=390, Top=300, Width=200, FontBold=.T.
    ADD OBJECT cmdPrint AS CommandButton WITH Caption="Print", Left=260, Top=335, Width=80
    ADD OBJECT cmdCancel AS CommandButton WITH Caption="Cancel", Left=355, Top=335, Width=80

    PROCEDURE Init
        LOCAL lcData, lnI
        lcData=EnsureThirdPartyLines(path_to_data)
        IF !USED("csrThirdPartyLines")
            CREATE CURSOR csrThirdPartyLines (line_no N(2), description C(80), amount N(10,2))
            FOR lnI=1 TO 5
                INSERT INTO csrThirdPartyLines VALUES (lnI,"",0)
            ENDFOR
        ENDIF
        THIS.grdLines.RecordSource="csrThirdPartyLines"
        THIS.grdLines.Column1.Header1.Caption="Service"
        THIS.grdLines.Column1.Width=430
        THIS.grdLines.Column2.Header1.Caption="Fee"
        THIS.grdLines.Column2.Width=100
        THIS.RefreshTotal()
    ENDPROC

    PROCEDURE RefreshTotal
        SELECT csrThirdPartyLines
        SUM amount TO lnTotal
        THIS.lblTotal.Caption="Total: $"+TRANSFORM(NVL(lnTotal,0),"999,999.99")
    ENDPROC

    PROCEDURE cmdCancel.Click
        THISFORM.Release()
    ENDPROC
ENDDEFINE
