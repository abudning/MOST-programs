LPARAMETERS toPatient
LOCAL loChoice,lnChoice,loEntry,loClaim,loService,lnI,lcMD,lnArea,lnCount
IF VARTYPE(toPatient)#"O" OR toPatient.keep_id<=0
    MESSAGEBOX("Select a patient first.",48,"Third Party Billing")
    RETURN
ENDIF
SET PROCEDURE TO thirdparty_store ADDITIVE
loChoice=CREATEOBJECT("TpChoiceForm")
loChoice.Show(1)
lnChoice=loChoice.nChoice
loChoice.Release()
DO CASE
CASE lnChoice=1
    loClaim=openpatientclaim(toPatient)
    IF VARTYPE(loClaim)="O"
        IF VAL(TRANSFORM(loClaim.id.Value))#toPatient.keep_id
            RETURN
        ENDIF
        FOR lnI=1 TO 5
            loService=GETPEM(loClaim,"service"+TRANSFORM(lnI))
            IF !EMPTY(ALLTRIM(TRANSFORM(loService.Value)))
                MESSAGEBOX("Finish the active billing before entering a new third party claim.",48,"Third Party Billing")
                RETURN
            ENDIF
        ENDFOR
        loClaim.type.Value="THIRD_PARTY"
        loClaim.type.Refresh()
        loClaim.service1.SetFocus()
    ENDIF
CASE lnChoice=2
    lcMD=ALLTRIM(toPatient.Combo2.Value)
    loEntry=CREATEOBJECT("TpEntryForm",toPatient.keep_id,lcMD)
    loEntry.Show(1)
    lnChoice=loEntry.nSaved
    loEntry.Release()
    IF lnChoice>0
        DO create_invoice WITH toPatient.keep_id
    ENDIF
CASE lnChoice=3
    DO create_invoice WITH toPatient.keep_id
CASE lnChoice=4
    DO FORM invoicehist WITH toPatient.keep_id
ENDCASE
toPatient.outstand_3p()
RETURN

DEFINE CLASS TpChoiceForm AS Form
    Caption="Third Party Billing - V16.64 TEST"
    Width=390
    Height=265
    AutoCenter=.T.
    BorderStyle=2
    MaxButton=.F.
    MinButton=.F.
    nChoice=0
    ADD OBJECT title AS Label WITH Caption="Choose a billing action",Left=20,Top=15,Width=350,FontBold=.T.
    ADD OBJECT claims AS TpChoiceButton WITH Caption="New bill through Claims",Left=20,Top=45,Width=350,Height=32,nAction=1
    ADD OBJECT manual AS TpChoiceButton WITH Caption="New manual invoice (up to 5 services)",Left=20,Top=85,Width=350,Height=32,nAction=2
    ADD OBJECT payment AS TpChoiceButton WITH Caption="Outstanding bills / Accept payment",Left=20,Top=125,Width=350,Height=32,nAction=3
    ADD OBJECT history AS TpChoiceButton WITH Caption="Paid billing history / Reprint",Left=20,Top=165,Width=350,Height=32,nAction=4
    ADD OBJECT cancel AS TpChoiceButton WITH Caption="Cancel",Left=270,Top=215,Width=100,Height=28,nAction=0,Cancel=.T.
    PROCEDURE QueryUnload
        NODEFAULT
        THIS.Hide()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpChoiceButton AS CommandButton
    nAction=0
    PROCEDURE Click
        THISFORM.nChoice=THIS.nAction
        THISFORM.Hide()
    ENDPROC
ENDDEFINE

DEFINE CLASS TpEntryForm AS Form
    Caption="Manual Third Party Invoice - V16.64 TEST"
    Width=675
    Height=365
    AutoCenter=.T.
    BorderStyle=2
    MaxButton=.F.
    MinButton=.F.
    nPatient=0
    nSaved=0
    lSaving=.F.
    ADD OBJECT patient AS Label WITH Left=18,Top=14,Width=625,FontBold=.T.
    ADD OBJECT dateLabel AS Label WITH Caption="Service date",Left=18,Top=47,Width=85
    ADD OBJECT serviceDate AS TextBox WITH Left=106,Top=43,Width=110,Value=DATE()
    ADD OBJECT mdLabel AS Label WITH Caption="Billing MD",Left=260,Top=47,Width=75
    ADD OBJECT billingMD AS TextBox WITH Left=340,Top=43,Width=55,MaxLength=2
    ADD OBJECT descLabel AS Label WITH Caption="Service description",Left=18,Top=83,Width=480
    ADD OBJECT feeLabel AS Label WITH Caption="Fee ($)",Left=537,Top=83,Width=95
    ADD OBJECT total AS Label WITH Caption="Total: $0.00",Left=450,Top=278,Width=200,FontBold=.T.,Alignment=1
    ADD OBJECT save AS TpSaveButton WITH Caption="Save invoice",Left=410,Top=315,Width=115,Height=30
    ADD OBJECT cancel AS TpCancelButton WITH Caption="Cancel",Left=540,Top=315,Width=110,Height=30,Cancel=.T.
    PROCEDURE Init
        LPARAMETERS tnPatient,tcMD
        LOCAL lnI,lcName,lnArea,loControl
        THIS.nPatient=tnPatient
        THIS.billingMD.Value=tcMD
        lnArea=SELECT()
        USE (ADDBS(path_to_data)+"patients.dbf") AGAIN SHARED IN 0 ALIAS tpentrypatient
        SELECT tpentrypatient
        LOCATE FOR id=m.tnPatient AND !DELETED()
        THIS.patient.Caption="Patient #"+TRANSFORM(tnPatient)+": "+ALLTRIM(surname)+", "+ALLTRIM(firstname)
        USE IN tpentrypatient
        SELECT (lnArea)
        FOR lnI=1 TO 5
            lcName="description"+TRANSFORM(lnI)
            THIS.AddObject(lcName,"TextBox")
            loControl=GETPEM(THIS,lcName)
            WITH loControl
                .Left=18
                .Top=104+(lnI-1)*33
                .Width=505
                .Height=26
                .MaxLength=80
                .Value=""
                .Visible=.T.
                .TabIndex=lnI*2+2
            ENDWITH
            lcName="amount"+TRANSFORM(lnI)
            THIS.AddObject(lcName,"TpAmount")
            loControl=GETPEM(THIS,lcName)
            WITH loControl
                .Left=537
                .Top=104+(lnI-1)*33
                .Width=113
                .Height=26
                .Visible=.T.
                .TabIndex=lnI*2+3
            ENDWITH
        ENDFOR
    ENDPROC
    PROCEDURE UpdateTotal
        LOCAL lnI,lnTotal,loControl
        lnTotal=0
        FOR lnI=1 TO 5
            loControl=GETPEM(THIS,"amount"+TRANSFORM(lnI))
            lnTotal=lnTotal+loControl.Value
        ENDFOR
        THIS.total.Caption="Total: $"+ALLTRIM(STR(lnTotal,12,2))
    ENDPROC
    PROCEDURE SaveInvoice
        LOCAL lnI,lcError,lnBill,loControl
        LOCAL ARRAY laLines[5,2]
        IF THIS.lSaving OR THIS.nSaved>0
            RETURN
        ENDIF
        FOR lnI=1 TO 5
            loControl=GETPEM(THIS,"description"+TRANSFORM(lnI))
            laLines[lnI,1]=loControl.Value
            loControl=GETPEM(THIS,"amount"+TRANSFORM(lnI))
            laLines[lnI,2]=loControl.Value
        ENDFOR
        THIS.lSaving=.T.
        lnBill=TpSaveBill(path_to_data,THIS.nPatient,UPPER(ALLTRIM(THIS.billingMD.Value)),THIS.serviceDate.Value,@laLines,@lcError)
        THIS.lSaving=.F.
        IF lnBill=0
            MESSAGEBOX(lcError,48,"Invoice was not saved")
            RETURN
        ENDIF
        THIS.nSaved=lnBill
        THIS.Hide()
    ENDPROC
    PROCEDURE QueryUnload
        NODEFAULT
        THIS.Hide()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpAmount AS TextBox
    Value=0.00
    InputMask="99999.99"
    Format="K"
    Alignment=1
    PROCEDURE LostFocus
        THISFORM.UpdateTotal()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpSaveButton AS CommandButton
    PROCEDURE Click
        THISFORM.SaveInvoice()
    ENDPROC
ENDDEFINE
DEFINE CLASS TpCancelButton AS CommandButton
    PROCEDURE Click
        THISFORM.Hide()
    ENDPROC
ENDDEFINE
