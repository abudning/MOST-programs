LPARAMETERS toPatientForm
LOCAL lnPatientId, lnI, loClaimForm, lcBillingMd, llClaimWasOpen
PUBLIC gcClaimsSessionBillingMd
gcClaimsSessionBillingMd=""
llClaimWasOpen=.F.
FOR lnI=1 TO _SCREEN.FormCount
    loClaimForm=_SCREEN.Forms(lnI)
    IF UPPER(ALLTRIM(loClaimForm.Caption))=="CLAIMS"
        llClaimWasOpen=.T.
        TRY
            lcBillingMd=ALLTRIM(TRANSFORM(loClaimForm.billing_md.Value))
            IF EMPTY(lcBillingMd) AND PEMSTATUS(loClaimForm,"cSessionBillingMd",5)
                lcBillingMd=ALLTRIM(TRANSFORM(loClaimForm.cSessionBillingMd))
            ENDIF
            gcClaimsSessionBillingMd=lcBillingMd
        CATCH
        ENDTRY
        EXIT
    ENDIF
ENDFOR
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
            =CaptureClaimSessionBillingMd(loClaimForm)
            IF VAL(ALLTRIM(TRANSFORM(loClaimForm.id.Value)))=lnPatientId
                IF loClaimForm.Visible
                    loClaimForm.ZOrder(0)
                ELSE
                    loClaimForm.Show()
                    loClaimForm.ZOrder(0)
                ENDIF
                IF loClaimForm.type.Enabled
                    loClaimForm.type.SetFocus()
                ELSE
                    loClaimForm.serv_date1.SetFocus()
                ENDIF
                =RestoreClaimSessionBillingMd(loClaimForm)
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
        =CaptureClaimSessionBillingMd(loClaimForm)
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
        * Reuse an empty Claims form instead of closing and recreating it.
        * This preserves the selected claim type (for example, OHIP) and is
        * much faster when switching the active patient from Claims or L+C.
        TRY
            loClaimForm.id.Value=ALLTRIM(STR(lnPatientId))
            IF loClaimForm.id.Valid()
                IF loClaimForm.Visible
                    loClaimForm.ZOrder(0)
                ELSE
                    loClaimForm.Show()
                    loClaimForm.ZOrder(0)
                ENDIF
                =RestoreClaimSessionBillingMd(loClaimForm)
                RETURN loClaimForm
            ENDIF
        CATCH
        ENDTRY
        * If the existing form cannot be updated safely, fall through to the
        * normal new-form path.
        * Dispose of an empty stale instance. Otherwise each failed reuse
        * remains in _SCREEN.Forms and is exposed one at a time when Exit is
        * clicked, forcing the operator to close the form repeatedly.
        TRY
            loClaimForm.Release()
        CATCH
        ENDTRY
    ENDIF
ENDFOR
DO FORM enter_claims WITH ALLTRIM(STR(lnPatientId)) NAME loClaimForm
IF VARTYPE(loClaimForm)=="O"
    =EnsureClaimSessionBillingMd(loClaimForm)
    DO PositionClaim WITH loClaimForm, toPatientForm
    RETURN loClaimForm
ENDIF
RETURN .NULL.

FUNCTION EnsureClaimSessionBillingMd
LPARAMETERS toClaimForm
IF VARTYPE(toClaimForm)#"O"
    RETURN .F.
ENDIF
IF !PEMSTATUS(toClaimForm,"cSessionBillingMd",5)
    ADDPROPERTY(toClaimForm,"cSessionBillingMd","")
ENDIF
RETURN .T.
ENDFUNC

FUNCTION CaptureClaimSessionBillingMd
LPARAMETERS toClaimForm
LOCAL lcBillingMd
IF !EnsureClaimSessionBillingMd(toClaimForm)
    RETURN .F.
ENDIF
lcBillingMd=ALLTRIM(TRANSFORM(toClaimForm.billing_md.Value))
IF !EMPTY(lcBillingMd)
    toClaimForm.cSessionBillingMd=lcBillingMd
    gcClaimsSessionBillingMd=lcBillingMd
ELSE
    lcBillingMd=ALLTRIM(gcClaimsSessionBillingMd)
    IF !EMPTY(lcBillingMd)
        toClaimForm.cSessionBillingMd=lcBillingMd
    ENDIF
ENDIF
RETURN .T.
ENDFUNC

FUNCTION RestoreClaimSessionBillingMd
LPARAMETERS toClaimForm
IF !EnsureClaimSessionBillingMd(toClaimForm)
    RETURN .F.
ENDIF
IF EMPTY(ALLTRIM(toClaimForm.cSessionBillingMd)) AND !EMPTY(ALLTRIM(gcClaimsSessionBillingMd))
    toClaimForm.cSessionBillingMd=ALLTRIM(gcClaimsSessionBillingMd)
ENDIF
IF !EMPTY(ALLTRIM(toClaimForm.cSessionBillingMd))
    toClaimForm.billing_md.Value=toClaimForm.cSessionBillingMd
    toClaimForm.billing_md.Refresh()
ENDIF
RETURN .T.
ENDFUNC

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
