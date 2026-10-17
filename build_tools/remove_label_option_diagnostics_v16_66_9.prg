LPARAMETERS tcWorkingRoot, tcFormOverride
LOCAL lcRoot,lcForm,lcMethods,lcLogLine,lcMessageLine,llClean
lcRoot=ADDBS(FULLPATH(tcWorkingRoot))
IF VARTYPE(tcFormOverride)=="C" AND !EMPTY(tcFormOverride)
    lcForm=FULLPATH(tcFormOverride)
ELSE
    lcForm=lcRoot+"MOSt\FORMS\label_option.scx"
ENDIF
IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm,"sct"))
    ERROR "The label_option form is missing."
ENDIF
lcLogLine='STRTOFILE("LABEL OPTION CLICK selection="+THISFORM.opt_selection+"; copies="+TRANSFORM(THISFORM.NUMBER)+CHR(13)+CHR(10),ADDBS(SYS(2023))+"MOSt_Label_Print.log",1)'
lcMessageLine='MESSAGEBOX("Label window returned: "+THISFORM.opt_selection+TRANSFORM(THISFORM.NUMBER),64,"MOSt ZERO-COPY BUILD 2")'
llClean=.F.
USE (lcForm) EXCLUSIVE ALIAS cleanlabeloption
SCAN FOR LOWER(ALLTRIM(objname))=="printer" AND LOWER(ALLTRIM(baseclass))=="commandbutton"
    lcMethods=cleanlabeloption.methods
    lcMethods=STRTRAN(lcMethods,lcLogLine,"",1,-1,0)
    lcMethods=STRTRAN(lcMethods,lcMessageLine,"",1,-1,0)
    REPLACE methods WITH lcMethods IN cleanlabeloption
    llClean=!("LABEL OPTION CLICK selection=" $ lcMethods) AND ;
        !("Label window returned:" $ lcMethods) AND ;
        "lnPrintPatient=THISFORM.parent_object.id1.VALUE" $ lcMethods
ENDSCAN
USE IN cleanlabeloption
IF !llClean
    ERROR "Label diagnostics were not removed while preserving direct printing."
ENDIF
RETURN
