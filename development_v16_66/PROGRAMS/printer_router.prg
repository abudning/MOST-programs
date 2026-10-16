* Central printer routing for patient-screen output, V16.66.8.
* LABEL_PRINTER and MAIN_PRINTER are workstation-local PARAMETER2 settings.

FUNCTION MostPrintPatientOutput
LPARAMETERS tcOutputKind, tnPatientId, tcRadiologyText
LOCAL lcKind, lcPurpose, lcConfigured, lcPrevious, lcSelected, llPrinted, lcLog

lcKind = UPPER(ALLTRIM(IIF(VARTYPE(tcOutputKind)="C", tcOutputKind, "")))
lcPurpose = IIF(lcKind == "D", "patient sheet", "patient label")
lcConfigured = ""
lcLog = ADDBS(SYS(2023)) + "MOSt_Label_Print.log"
=STRTOFILE("MOSt patient printing diagnostic" + CHR(13)+CHR(10), lcLog, 0)
=MostPrintLog("START kind=" + lcKind + "; patient-id type=" + VARTYPE(tnPatientId))
MESSAGEBOX("Printer trace started." + CHR(13)+CHR(13) + ;
    "Output type: " + lcKind + CHR(13) + ;
    "Diagnostic log: " + lcLog, 64, "MOSt V16.66.8 Printer Trace Diagnostic")

IF lcKind == "D"
    IF TYPE("main_printer") == "C"
        lcConfigured = ALLTRIM(main_printer)
    ENDIF
ELSE
    IF TYPE("label_printer") == "C"
        lcConfigured = ALLTRIM(label_printer)
    ENDIF
ENDIF

=MostPrintLog("Configured printer=" + IIF(EMPTY(lcConfigured), "<empty>", lcConfigured))
=MostLogInstalledPrinters()
lcSelected = MostResolvePrinter(lcConfigured, lcPurpose)
IF EMPTY(lcSelected)
    =MostPrintLog("STOP no printer selected")
    RETURN .F.
ENDIF

lcPrevious = ALLTRIM(SET("PRINTER", 2))
=MostPrintLog("Printer before selection=" + IIF(EMPTY(lcPrevious), "<empty>", lcPrevious))
llPrinted = .F.

TRY
    SET PRINTER TO NAME (lcSelected)
    =MostPrintLog("Requested printer=" + lcSelected + "; active printer=" + SET("PRINTER", 2))
    IF UPPER(ALLTRIM(SET("PRINTER", 2))) # UPPER(lcSelected)
        =MostPrintLog("STOP Windows did not select requested printer")
        MESSAGEBOX("Windows did not select the " + lcPurpose + " printer:" + CHR(13) + ;
            lcSelected, 16, "MOSt - Printer Not Available")
        RETURN .F.
    ENDIF

    DO CASE
    CASE lcKind == "A"
        llPrinted = patient_label(tnPatientId)
    CASE lcKind == "B"
        llPrinted = address_label(tnPatientId)
    CASE lcKind == "D"
        llPrinted = patient_sheet(tnPatientId)
    CASE lcKind == "E"
        radiology_label(tnPatientId, tcRadiologyText)
        llPrinted = .T.
    OTHERWISE
        =MostPrintLog("STOP unknown output selection")
        MESSAGEBOX("Unknown patient print selection: " + lcKind, 16, "MOSt - Printing")
        RETURN .F.
    ENDCASE
    =MostPrintLog("Output routine returned " + TRANSFORM(llPrinted))
CATCH TO loPrintError
    =MostPrintLog("ERROR " + TRANSFORM(loPrintError.ErrorNo) + ": " + ;
        loPrintError.Message + "; procedure=" + loPrintError.Procedure + ;
        "; line=" + TRANSFORM(loPrintError.LineNo))
    MESSAGEBOX("The " + lcPurpose + " could not be printed." + CHR(13)+CHR(13) + ;
        "Printer: " + lcSelected + CHR(13) + ;
        "Error: " + loPrintError.Message + CHR(13)+CHR(13) + ;
        "Diagnostic log: " + lcLog, 16, "MOSt - Printing")
FINALLY
    SET PRINTER OFF
    IF !EMPTY(lcPrevious) AND MostPrinterInstalled(lcPrevious)
        SET PRINTER TO NAME (lcPrevious)
    ELSE
        SET PRINTER TO DEFAULT
    ENDIF
    =MostPrintLog("Printer restored=" + SET("PRINTER", 2))
ENDTRY

IF llPrinted
    MESSAGEBOX("MOSt completed the patient-label print command." + CHR(13)+CHR(13) + ;
        "Printer: " + lcSelected + CHR(13) + ;
        "Diagnostic log: " + lcLog, 64, "MOSt - Diagnostic Print")
ELSE
    MESSAGEBOX("MOSt did not complete the patient-label print command." + CHR(13)+CHR(13) + ;
        "Diagnostic log: " + lcLog, 48, "MOSt - Diagnostic Print")
ENDIF

RETURN llPrinted
ENDFUNC


FUNCTION MostPrintLog
LPARAMETERS tcMessage
LOCAL lcLog, lcText
lcLog = ADDBS(SYS(2023)) + "MOSt_Label_Print.log"
lcText = TTOC(DATETIME(), 1) + " | " + ;
    IIF(VARTYPE(tcMessage)="C", tcMessage, TRANSFORM(tcMessage)) + CHR(13)+CHR(10)
=STRTOFILE(lcText, lcLog, 1)
RETURN lcLog
ENDFUNC


FUNCTION MostLogInstalledPrinters
LOCAL ARRAY laLogPrinters[1]
LOCAL lnLogPrinters, lnLogPrinter, lcPrinterList
lcPrinterList = ""
lnLogPrinters = APRINTERS(laLogPrinters)
FOR lnLogPrinter = 1 TO lnLogPrinters
    lcPrinterList = lcPrinterList + IIF(EMPTY(lcPrinterList), "", " | ") + ;
        ALLTRIM(laLogPrinters[lnLogPrinter, 1])
ENDFOR
=MostPrintLog("Installed printers (" + TRANSFORM(lnLogPrinters) + ")=" + lcPrinterList)
RETURN lnLogPrinters
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
    =MostPrintLog("Prepare label STOP source missing=" + lcSource)
    RETURN ""
ENDIF

lcSourceMemo = FORCEEXT(lcSource, "lbt")
lcTempLabel = ADDBS(SYS(2023)) + "most_" + SYS(2015) + ".lbx"
lcTempMemo = FORCEEXT(lcTempLabel, "lbt")
=MostPrintLog("Prepare label source=" + lcSource + "; temp=" + lcTempLabel)

TRY
    COPY FILE (lcSource) TO (lcTempLabel)
    IF FILE(lcSourceMemo)
        COPY FILE (lcSourceMemo) TO (lcTempMemo)
    ENDIF

    USE (lcTempLabel) EXCLUSIVE ALIAS mostlabelmeta
    SELECT mostlabelmeta
    LOCATE FOR objtype=1 AND objcode=53
    IF FOUND("mostlabelmeta")
        =MostPrintLog("Saved environment found; clearing printer metadata")
        REPLACE expr WITH "", tag WITH "", tag2 WITH "" IN mostlabelmeta
    ELSE
        =MostPrintLog("No saved environment record found")
    ENDIF
    USE IN mostlabelmeta
    =MostPrintLog("Prepared label exists=" + TRANSFORM(FILE(lcTempLabel)) + ;
        "; memo exists=" + TRANSFORM(FILE(lcTempMemo)))
CATCH TO loLabelError
    IF USED("mostlabelmeta")
        USE IN mostlabelmeta
    ENDIF
    =MostCleanupLabel(lcTempLabel)
    =MostPrintLog("Prepare label ERROR " + TRANSFORM(loLabelError.ErrorNo) + ": " + ;
        loLabelError.Message)
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
=MostPrintLog("Cleaned temporary label=" + lcTempLabel)
RETURN .T.
ENDFUNC
