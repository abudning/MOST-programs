* Full patient sheet output. Printer selection is handled by printer_router.prg.
PARAMETERS ident
LOCAL lcLabelFile, lcPrintLabel

IF TYPE("gc_localapp") == "C" AND !EMPTY(gc_localapp)
    lcLabelFile = ADDBS(gc_localapp) + "labels\patient_sheet.lbx"
ELSE
    lcLabelFile = ADDBS(JUSTPATH(SYS(16,0))) + "labels\patient_sheet.lbx"
ENDIF

IF !FILE(lcLabelFile)
    MESSAGEBOX("Patient sheet form not found:" + CHR(13) + lcLabelFile, ;
        16, "MOSt - Patient Sheet Printing")
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
