* Central printer routing for patient-screen output, V16.66.8.
* LABEL_PRINTER and MAIN_PRINTER are workstation-local PARAMETER2 settings.

FUNCTION MostPrintPatientOutput
LPARAMETERS tcOutputKind, tnPatientId, tcRadiologyText
LOCAL lcKind, lcPurpose, lcConfigured, lcPrevious, lcSelected, llPrinted

lcKind = UPPER(ALLTRIM(IIF(VARTYPE(tcOutputKind)="C", tcOutputKind, "")))
lcPurpose = IIF(lcKind == "D", "patient sheet", "patient label")
lcConfigured = ""

IF lcKind == "D"
    IF TYPE("main_printer") == "C"
        lcConfigured = ALLTRIM(main_printer)
    ENDIF
ELSE
    IF TYPE("label_printer") == "C"
        lcConfigured = ALLTRIM(label_printer)
    ENDIF
ENDIF

lcSelected = MostResolvePrinter(lcConfigured, lcPurpose)
IF EMPTY(lcSelected)
    RETURN .F.
ENDIF

lcPrevious = ALLTRIM(SET("PRINTER", 2))
llPrinted = .F.

TRY
    SET PRINTER TO NAME (lcSelected)
    IF UPPER(ALLTRIM(SET("PRINTER", 2))) # UPPER(lcSelected)
        MESSAGEBOX("Windows did not select the " + lcPurpose + " printer:" + CHR(13) + ;
            lcSelected, 16, "MOSt - Printer Not Available")
        RETURN .F.
    ENDIF

    DO CASE
    CASE lcKind == "A"
        patient_label(tnPatientId)
    CASE lcKind == "B"
        address_label(tnPatientId)
    CASE lcKind == "D"
        patient_sheet(tnPatientId)
    CASE lcKind == "E"
        radiology_label(tnPatientId, tcRadiologyText)
    OTHERWISE
        MESSAGEBOX("Unknown patient print selection: " + lcKind, 16, "MOSt - Printing")
        RETURN .F.
    ENDCASE
    llPrinted = .T.
CATCH TO loPrintError
    MESSAGEBOX("The " + lcPurpose + " could not be printed." + CHR(13)+CHR(13) + ;
        "Printer: " + lcSelected + CHR(13) + ;
        "Error: " + loPrintError.Message, 16, "MOSt - Printing")
FINALLY
    SET PRINTER OFF
    IF !EMPTY(lcPrevious) AND MostPrinterInstalled(lcPrevious)
        SET PRINTER TO NAME (lcPrevious)
    ELSE
        SET PRINTER TO DEFAULT
    ENDIF
ENDTRY

RETURN llPrinted
ENDFUNC


FUNCTION MostResolvePrinter
LPARAMETERS tcConfigured, tcPurpose
LOCAL lcConfigured, lcPurpose, lcSelected

lcConfigured = ALLTRIM(IIF(VARTYPE(tcConfigured)="C", tcConfigured, ""))
lcPurpose = IIF(VARTYPE(tcPurpose)="C" AND !EMPTY(tcPurpose), tcPurpose, "output")

IF !EMPTY(lcConfigured) AND MostPrinterInstalled(lcConfigured)
    RETURN lcConfigured
ENDIF

IF EMPTY(lcConfigured)
    MESSAGEBOX("No " + lcPurpose + " printer is configured for this workstation." + ;
        CHR(13)+CHR(13) + "Choose a printer for this job. To make it permanent, " + ;
        "select the printer in Setup > Local Parameters.", 48, "MOSt - Select Printer")
ELSE
    MESSAGEBOX("The configured " + lcPurpose + " printer is not installed:" + ;
        CHR(13) + lcConfigured + CHR(13)+CHR(13) + ;
        "Choose a printer for this job. To make it permanent, update " + ;
        "Setup > Local Parameters.", 48, "MOSt - Printer Not Found")
ENDIF

lcSelected = GETPRINTER()
IF EMPTY(lcSelected)
    RETURN ""
ENDIF

RETURN lcSelected
ENDFUNC


FUNCTION MostPrinterInstalled
LPARAMETERS tcPrinter
LOCAL ARRAY laPrinters[1]
LOCAL lnPrinters, lnPrinter, lcWanted

lcWanted = UPPER(ALLTRIM(IIF(VARTYPE(tcPrinter)="C", tcPrinter, "")))
IF EMPTY(lcWanted)
    RETURN .F.
ENDIF

lnPrinters = APRINTERS(laPrinters)
FOR lnPrinter = 1 TO lnPrinters
    IF UPPER(ALLTRIM(laPrinters[lnPrinter, 1])) == lcWanted
        RETURN .T.
    ENDIF
ENDFOR

RETURN .F.
ENDFUNC


FUNCTION MostPrepareLabel
LPARAMETERS tcSourceLabel
LOCAL lcSource, lcSourceMemo, lcTempLabel, lcTempMemo

lcSource = ALLTRIM(IIF(VARTYPE(tcSourceLabel)="C", tcSourceLabel, ""))
IF EMPTY(lcSource) OR !FILE(lcSource)
    RETURN ""
ENDIF

lcSourceMemo = FORCEEXT(lcSource, "lbt")
lcTempLabel = ADDBS(SYS(2023)) + "most_" + SYS(2015) + ".lbx"
lcTempMemo = FORCEEXT(lcTempLabel, "lbt")

TRY
    COPY FILE (lcSource) TO (lcTempLabel)
    IF FILE(lcSourceMemo)
        COPY FILE (lcSourceMemo) TO (lcTempMemo)
    ENDIF

    USE (lcTempLabel) EXCLUSIVE ALIAS mostlabelmeta
    SELECT mostlabelmeta
    LOCATE FOR objtype=1 AND objcode=53
    IF FOUND("mostlabelmeta")
        REPLACE expr WITH "", tag WITH "", tag2 WITH "" IN mostlabelmeta
    ENDIF
    USE IN mostlabelmeta
CATCH TO loLabelError
    IF USED("mostlabelmeta")
        USE IN mostlabelmeta
    ENDIF
    =MostCleanupLabel(lcTempLabel)
    MESSAGEBOX("The label form could not be prepared for the selected printer." + ;
        CHR(13)+CHR(13) + loLabelError.Message, 16, "MOSt - Label Printing")
    RETURN ""
ENDTRY

RETURN lcTempLabel
ENDFUNC


FUNCTION MostCleanupLabel
LPARAMETERS tcTempLabel
LOCAL lcTempLabel, lcTempMemo

lcTempLabel = ALLTRIM(IIF(VARTYPE(tcTempLabel)="C", tcTempLabel, ""))
IF EMPTY(lcTempLabel)
    RETURN .T.
ENDIF
lcTempMemo = FORCEEXT(lcTempLabel, "lbt")

IF FILE(lcTempLabel)
    ERASE (lcTempLabel)
ENDIF
IF FILE(lcTempMemo)
    ERASE (lcTempMemo)
ENDIF
RETURN .T.
ENDFUNC
