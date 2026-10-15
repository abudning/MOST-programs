* Patient address label output. Printer selection is handled by printer_router.prg.
PARAMETERS ident
LOCAL lcLabelFile

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
LABEL FORM (lcLabelFile) FOR patients.ID=ident TO PRINTER NOCONSOLE
RETURN .T.
