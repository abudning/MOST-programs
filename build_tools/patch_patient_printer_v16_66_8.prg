LPARAMETERS tcWorkingRoot, tcFormOverride
LOCAL lcRoot, lcForm, lcMethods, lnChanged

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
LOCATE FOR LOWER(ALLTRIM(objname)) == "cmdprint" AND ;
    LOWER(ALLTRIM(baseclass)) == "commandbutton"
IF !FOUND()
    USE IN printerpatients
    ERROR "The Patients Print button was not found."
ENDIF

lcMethods = printerpatients.methods
IF !("MostPrintPatientOutput" $ lcMethods)
    lnChanged = 0
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
    IF lnChanged < 4
        USE IN printerpatients
        ERROR "The expected patient label calls were not found."
    ENDIF
    REPLACE methods WITH lcMethods IN printerpatients
ENDIF

USE IN printerpatients
RETURN
