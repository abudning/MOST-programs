* Patient label output. Printer selection is handled by printer_router.prg.
PARAMETERS ident
LOCAL lcLabelFile, lcPrintLabel, lnPatientMatches

IF TYPE("gc_localapp") == "C" AND !EMPTY(gc_localapp)
    lcLabelFile = ADDBS(gc_localapp) + "labels\patients.lbx"
ELSE
    lcLabelFile = ADDBS(JUSTPATH(SYS(16,0))) + "labels\patients.lbx"
ENDIF

IF !FILE(lcLabelFile)
    =MostPrintLog("Patient label STOP form missing=" + lcLabelFile)
    MESSAGEBOX("Patient label form not found:" + CHR(13) + lcLabelFile, ;
        16, "MOSt - Label Printing")
    RETURN .F.
ENDIF

SELECT patients
=MostPrintLog("Patient label alias selected; records=" + TRANSFORM(RECCOUNT("patients")) + ;
    "; ID field type=" + TYPE("patients.ID") + "; requested type=" + VARTYPE(ident))
LOCATE FOR patients.ID=ident
lnPatientMatches = IIF(FOUND("patients"), 1, 0)
=MostPrintLog("Patient label patient found=" + TRANSFORM(lnPatientMatches=1))
IF lnPatientMatches = 0
    MESSAGEBOX("MOSt could not find the selected patient record for the label." + ;
        CHR(13)+CHR(13) + "Diagnostic log: " + ADDBS(SYS(2023)) + ;
        "MOSt_Label_Print.log", 48, "MOSt - Diagnostic Print")
    RETURN .F.
ENDIF
lcPrintLabel = MostPrepareLabel(lcLabelFile)
IF EMPTY(lcPrintLabel)
    =MostPrintLog("Patient label STOP temporary form not prepared")
    RETURN .F.
ENDIF
TRY
    =MostPrintLog("Before LABEL FORM; active printer=" + SET("PRINTER", 2))
    LABEL FORM (lcPrintLabel) FOR patients.ID=ident TO PRINTER NOCONSOLE
    =MostPrintLog("After LABEL FORM; command returned without an error")
CATCH TO loPatientLabelError
    =MostPrintLog("LABEL FORM ERROR " + TRANSFORM(loPatientLabelError.ErrorNo) + ": " + ;
        loPatientLabelError.Message + "; procedure=" + loPatientLabelError.Procedure + ;
        "; line=" + TRANSFORM(loPatientLabelError.LineNo))
    MESSAGEBOX("The patient label command failed." + CHR(13)+CHR(13) + ;
        loPatientLabelError.Message + CHR(13)+CHR(13) + ;
        "Diagnostic log: " + ADDBS(SYS(2023)) + "MOSt_Label_Print.log", ;
        16, "MOSt - Diagnostic Print")
    RETURN .F.
FINALLY
    =MostCleanupLabel(lcPrintLabel)
ENDTRY
RETURN .T.
