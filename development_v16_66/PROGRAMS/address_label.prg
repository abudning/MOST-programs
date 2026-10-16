* Patient address label output. Printer selection is handled by printer_router.prg.
PARAMETERS ident
LOCAL lcLabelFile, lcPrintLabel

=MostPrintLog("DIRECT ENTRY address_label; patient-id type=" + VARTYPE(ident))
MESSAGEBOX("Direct address-label routine reached." + CHR(13)+CHR(13) + ;
    "Diagnostic log: " + ADDBS(SYS(2023)) + "MOSt_Label_Print.log", ;
    64, "MOSt V16.66.8 Printer Trace")

IF TYPE("gc_localapp") == "C" AND !EMPTY(gc_localapp)
    lcLabelFile = ADDBS(gc_localapp) + "labels\patients_address.lbx"
ELSE
    lcLabelFile = ADDBS(JUSTPATH(SYS(16,0))) + "labels\patients_address.lbx"
ENDIF

IF !FILE(lcLabelFile)
    MESSAGEBOX("Patient address label form not found:" + CHR(13) + lcLabelFile, ;
        16, "MOSt - Label Printing")
    RETURN .F.
ENDIF

SELECT patients
lcPrintLabel = MostPrepareLabel(lcLabelFile)
IF EMPTY(lcPrintLabel)
    RETURN .F.
ENDIF
TRY
    LABEL FORM (lcPrintLabel) FOR patients.ID=ident TO PRINTER NOCONSOLE
FINALLY
    =MostCleanupLabel(lcPrintLabel)
ENDTRY
RETURN .T.
