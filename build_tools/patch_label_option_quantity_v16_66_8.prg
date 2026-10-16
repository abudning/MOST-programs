LPARAMETERS tcWorkingRoot, tcFormOverride
LOCAL lcRoot,lcForm,lcMethods,lnChanged,llInitFixed,llClickFixed
lcRoot=ADDBS(FULLPATH(tcWorkingRoot))
IF VARTYPE(tcFormOverride)=="C" AND !EMPTY(tcFormOverride)
    lcForm=FULLPATH(tcFormOverride)
ELSE
    lcForm=lcRoot+"MOSt\FORMS\label_option.scx"
ENDIF
IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm,"sct"))
    ERROR "The label_option form is missing."
ENDIF

USE (lcForm) EXCLUSIVE ALIAS patchlabeloption
lnChanged=0
llInitFixed=.F.
llClickFixed=.F.
SCAN
    lcMethods=patchlabeloption.methods
    IF 'THISFORM.qUANTITY.VALUE = nNumCopies' $ lcMethods
        lcMethods=STRTRAN(lcMethods,'THISFORM.qUANTITY.VALUE = nNumCopies', ;
            'THISFORM.qUANTITY.VALUE = IIF(BETWEEN(nNumCopies,1,9),nNumCopies,1)',1,1,0)
        lnChanged=lnChanged+_TALLY
    ENDIF
    IF 'THISFORM.NUMBER = THISFORM.quantity.VALUE' $ lcMethods
        lcMethods=STRTRAN(lcMethods,'THISFORM.NUMBER = THISFORM.quantity.VALUE', ;
            'THISFORM.NUMBER = MAX(1,MIN(9,INT(THISFORM.quantity.VALUE)))',1,1,0)
        lnChanged=lnChanged+_TALLY
    ENDIF
    IF 'THISFORM.qUANTITY.VALUE = IIF(BETWEEN(nNumCopies,1,9),nNumCopies,1)' $ lcMethods
        llInitFixed=.T.
    ENDIF
    IF 'THISFORM.NUMBER = MAX(1,MIN(9,INT(THISFORM.quantity.VALUE)))' $ lcMethods
        llClickFixed=.T.
    ENDIF
    IF lnChanged>0
        REPLACE methods WITH lcMethods IN patchlabeloption
    ENDIF
ENDSCAN
USE IN patchlabeloption
IF !llInitFixed OR !llClickFixed
    ERROR "The label quantity safeguards were not both present after patching."
ENDIF
RETURN
