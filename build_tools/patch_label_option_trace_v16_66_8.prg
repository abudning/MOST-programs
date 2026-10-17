LPARAMETERS tcWorkingRoot, tcFormOverride
LOCAL lcRoot,lcForm,lcMethods,lcTrace,lnChanged,llFound
lcRoot=ADDBS(FULLPATH(tcWorkingRoot))
IF VARTYPE(tcFormOverride)=="C" AND !EMPTY(tcFormOverride)
    lcForm=FULLPATH(tcFormOverride)
ELSE
    lcForm=lcRoot+"MOSt\FORMS\label_option.scx"
ENDIF
IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm,"sct"))
    ERROR "The label_option form is missing."
ENDIF
lcTrace='STRTOFILE("LABEL OPTION CLICK selection="+THISFORM.opt_selection+"; copies="+TRANSFORM(THISFORM.NUMBER)+CHR(13)+CHR(10),ADDBS(SYS(2023))+"MOSt_Label_Print.log",1)'+CHR(13)+CHR(10)+ ;
    'MESSAGEBOX("Label window returned: "+THISFORM.opt_selection+TRANSFORM(THISFORM.NUMBER),64,"MOSt ZERO-COPY BUILD 2")'
USE (lcForm) EXCLUSIVE ALIAS patchlabeltrace
lnChanged=0
llFound=.F.
SCAN FOR LOWER(ALLTRIM(objname))=="printer" AND LOWER(ALLTRIM(baseclass))=="commandbutton"
    lcMethods=patchlabeltrace.methods
    IF !("LABEL OPTION CLICK selection=" $ lcMethods)
        lcMethods=STRTRAN(lcMethods,"THISFORM.RELEASE",lcTrace+CHR(13)+CHR(10)+"THISFORM.RELEASE",1,1,1)
        lnChanged=lnChanged+_TALLY
        REPLACE methods WITH lcMethods IN patchlabeltrace
    ENDIF
    llFound="LABEL OPTION CLICK selection=" $ lcMethods
ENDSCAN
USE IN patchlabeltrace
IF !llFound
    ERROR "The label Print button trace was not installed."
ENDIF
RETURN
