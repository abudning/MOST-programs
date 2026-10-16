LPARAMETERS tcWorkingRoot, tcFormOverride
LOCAL lcRoot, lcForm, lcMethods, lnChanged, lnRoutes, llFoundButton

IF VARTYPE(tcWorkingRoot) # "C" OR EMPTY(tcWorkingRoot)
    ERROR "An isolated working source root is required."
ENDIF
lcRoot = ADDBS(FULLPATH(tcWorkingRoot))
IF VARTYPE(tcFormOverride) == "C" AND !EMPTY(tcFormOverride)
    lcForm = FULLPATH(tcFormOverride)
ELSE
    lcForm = lcRoot + "MOSt\FORMS\patients.scx"
ENDIF
IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm, "sct"))
    ERROR "The isolated source copy is missing patients.scx/sct."
ENDIF

USE (lcForm) EXCLUSIVE ALIAS printerpatients
lnChanged = 0
lnRoutes = 0
llFoundButton = .F.
SCAN
    IF LOWER(ALLTRIM(objname)) == "cmdprint" AND ;
            LOWER(ALLTRIM(baseclass)) == "commandbutton"
        llFoundButton = .T.
    ENDIF
    lcMethods = printerpatients.methods
    IF "patient_label(idd)" $ lcMethods OR "address_label(idd)" $ lcMethods OR ;
            "patient_sheet(idd)" $ lcMethods OR ;
            "radiology_label(idd, THISFORM.text2.VALUE)" $ lcMethods
        lcMethods = STRTRAN(lcMethods, "patient_label(idd)", ;
            'MostPrintPatientOutput("A",idd,"")', 1, -1, 1)
        lnChanged = lnChanged + _TALLY
        lcMethods = STRTRAN(lcMethods, "address_label(idd)", ;
            'MostPrintPatientOutput("B",idd,"")', 1, -1, 1)
        lnChanged = lnChanged + _TALLY
        lcMethods = STRTRAN(lcMethods, "patient_sheet(idd)", ;
            'MostPrintPatientOutput("D",idd,"")', 1, -1, 1)
        lnChanged = lnChanged + _TALLY
        lcMethods = STRTRAN(lcMethods, "radiology_label(idd, THISFORM.text2.VALUE)", ;
            'MostPrintPatientOutput("E",idd,THISFORM.text2.VALUE)', 1, -1, 1)
        lnChanged = lnChanged + _TALLY
        REPLACE methods WITH lcMethods IN printerpatients
    ENDIF
    lnRoutes = lnRoutes + OCCURS("MostPrintPatientOutput", lcMethods)
ENDSCAN

IF !llFoundButton
    USE IN printerpatients
    ERROR "The Patients Print button was not found."
ENDIF
IF lnRoutes < 12
    USE IN printerpatients
    ERROR "Not all Patients print entry points use the printer trace router."
ENDIF
USE IN printerpatients
RETURN
