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
* V16.63: a different patient may have unfinished billing in an open Claims form.
* Do not drive that form through several old patient records. Leave it intact
* and ask the operator to finish; discard only a completely empty claim form.
FOR lnI=_SCREEN.FormCount TO 1 STEP -1
    loClaimForm=_SCREEN.Forms(lnI)
    IF UPPER(ALLTRIM(loClaimForm.Caption))=="CLAIMS"
        IF !EMPTY(ALLTRIM(TRANSFORM(loClaimForm.service1.Value))) OR ;
            !EMPTY(ALLTRIM(TRANSFORM(loClaimForm.service2.Value))) OR ;
            !EMPTY(ALLTRIM(TRANSFORM(loClaimForm.service3.Value))) OR ;
            !EMPTY(ALLTRIM(TRANSFORM(loClaimForm.service4.Value))) OR ;
            !EMPTY(ALLTRIM(TRANSFORM(loClaimForm.service5.Value)))
            MESSAGEBOX("Please finish the active billing before switching Claims to another patient.", ;
                48,"MOSt - Claims")
            loClaimForm.Show()
            RETURN loClaimForm
        ENDIF
        loClaimForm.Release()
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
