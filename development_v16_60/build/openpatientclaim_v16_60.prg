LPARAMETERS toPatientForm
LOCAL lnPatientId, lnI, loClaimForm, lcBillingMd
lnPatientId=0
IF VARTYPE(toPatientForm)=="O"
    TRY
        lnPatientId=INT(toPatientForm.keep_id)
    CATCH
        lnPatientId=0
    ENDTRY
ENDIF
IF lnPatientId<=0 AND USED("patients") AND !EOF("patients")
    lnPatientId=patients.id
ENDIF
IF lnPatientId<=0
    MESSAGEBOX("Select a patient before opening Claims.",48,"MOSt - Claims")
    RETURN .NULL.
ENDIF
* Reuse Claims already open for this patient.
FOR lnI=1 TO _SCREEN.FormCount
    loClaimForm=_SCREEN.Forms(lnI)
    IF UPPER(ALLTRIM(loClaimForm.Caption))=="CLAIMS"
        TRY
            IF VAL(ALLTRIM(TRANSFORM(loClaimForm.id.Value)))=lnPatientId
                loClaimForm.Show()
                TRY
                    loClaimForm.ZOrder(0)
                CATCH
                ENDTRY
                IF loClaimForm.type.Enabled
                    loClaimForm.type.SetFocus()
                ELSE
                    loClaimForm.serv_date1.SetFocus()
                ENDIF
                RETURN loClaimForm
            ENDIF
        CATCH
        ENDTRY
    ENDIF
ENDFOR
* V16.60 Reuse an existing Claims window and retain its billing MD for the next patient.
FOR lnI=1 TO _SCREEN.FormCount
    loClaimForm=_SCREEN.Forms(lnI)
    IF UPPER(ALLTRIM(loClaimForm.Caption))=="CLAIMS"
        TRY
            IF .T.
                lcBillingMd=""
                TRY
                    lcBillingMd=ALLTRIM(TRANSFORM(loClaimForm.billing_md.Value))
                CATCH
                ENDTRY
                loClaimForm.id.Value=ALLTRIM(STR(lnPatientId))
                loClaimForm.id.SetFocus()
                KEYBOARD "{ENTER}"
                DOEVENTS FORCE
                DOEVENTS FORCE
                IF !EMPTY(lcBillingMd)
                    TRY
                        loClaimForm.billing_md.Value=lcBillingMd
                        loClaimForm.billing_md.Refresh()
                    CATCH
                    ENDTRY
                ENDIF
                loClaimForm.Show()
                TRY
                    loClaimForm.ZOrder(0)
                CATCH
                ENDTRY
                RETURN loClaimForm
            ENDIF
        CATCH
        ENDTRY
    ENDIF
ENDFOR
DO FORM enter_claims WITH ALLTRIM(STR(lnPatientId)) NAME loClaimForm
IF VARTYPE(loClaimForm)=="O"
    DO PositionClaim WITH loClaimForm, toPatientForm
    RETURN loClaimForm
ENDIF
RETURN .NULL.

PROCEDURE PositionClaim
LPARAMETERS toClaimForm, toPatientForm
LOCAL lnLeft, lnTop
IF VARTYPE(toClaimForm)#"O"
    RETURN
ENDIF
lnLeft=0
lnTop=0
IF VARTYPE(toPatientForm)=="O"
    lnLeft=toPatientForm.Left+toPatientForm.Width+4
    lnTop=toPatientForm.Top
ENDIF
lnLeft=MAX(0,MIN(lnLeft,_SCREEN.Width-toClaimForm.Width))
lnTop=MAX(0,MIN(lnTop,_SCREEN.Height-toClaimForm.Height))
toClaimForm.WindowState=0
toClaimForm.Left=lnLeft
toClaimForm.Top=lnTop
toClaimForm.Show()
ENDPROC