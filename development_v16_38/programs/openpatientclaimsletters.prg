LOCAL lnI, loPatients, loClaims, lnPatientId, llPatientsNew
llPatientsNew=.F.
loPatients=.NULL.
loClaims=.NULL.
lnPatientId=0
FOR lnI=1 TO _SCREEN.FormCount
    IF UPPER(ALLTRIM(_SCREEN.Forms(lnI).Caption))=="PATIENTS"
        loPatients=_SCREEN.Forms(lnI)
        EXIT
    ENDIF
ENDFOR
IF VARTYPE(loPatients)#"O"
    mcounter=mcounter+1
    DO FORM patients WITH "" NAME loPatients
    llPatientsNew=.T.
ENDIF
IF VARTYPE(loPatients)#"O"
    MESSAGEBOX("The Patients screen could not be opened.",16,"MOSt")
    RETURN
ENDIF
IF llPatientsNew
    loPatients.WindowState=0
    loPatients.Left=0
    loPatients.Top=0
ENDIF
loPatients.Show()
TRY
    lnPatientId=INT(loPatients.keep_id)
CATCH
    lnPatientId=0
ENDTRY
IF lnPatientId<=0 AND USED("patients") AND !EOF("patients")
    lnPatientId=patients.id
ENDIF
loClaims=openpatientclaim(loPatients)
IF lnPatientId>0
    DO openletterwriter WITH lnPatientId, loPatients, loClaims
ELSE
    DO openletterwriter
ENDIF