LPARAMETERS tcWorkingRoot, tcFormOverride
LOCAL lcRoot,lcForm,lcMethods,lcAnchor,lcDirect,llFound
lcRoot=ADDBS(FULLPATH(tcWorkingRoot))
IF VARTYPE(tcFormOverride)=="C" AND !EMPTY(tcFormOverride)
    lcForm=FULLPATH(tcFormOverride)
ELSE
    lcForm=lcRoot+"MOSt\FORMS\label_option.scx"
ENDIF
IF !FILE(lcForm) OR !FILE(FORCEEXT(lcForm,"sct"))
    ERROR "The label_option form is missing."
ENDIF
lcAnchor='MESSAGEBOX("Label window returned: "+THISFORM.opt_selection+TRANSFORM(THISFORM.NUMBER),64,"MOSt ZERO-COPY BUILD 2")'
lcDirect=lcAnchor+CHR(13)+CHR(10)+ ;
    'LOCAL lnPrintCopy,lnPrintPatient'+CHR(13)+CHR(10)+ ;
    'lnPrintPatient=THISFORM.parent_object.id1.VALUE'+CHR(13)+CHR(10)+ ;
    'FOR lnPrintCopy=1 TO THISFORM.NUMBER'+CHR(13)+CHR(10)+ ;
    '    IF "A" $ THISFORM.opt_selection'+CHR(13)+CHR(10)+ ;
    '        =MostPrintPatientOutput("A",lnPrintPatient,"")'+CHR(13)+CHR(10)+ ;
    '    ENDIF'+CHR(13)+CHR(10)+ ;
    '    IF "B" $ THISFORM.opt_selection'+CHR(13)+CHR(10)+ ;
    '        =MostPrintPatientOutput("B",lnPrintPatient,"")'+CHR(13)+CHR(10)+ ;
    '    ENDIF'+CHR(13)+CHR(10)+ ;
    '    IF "D" $ THISFORM.opt_selection'+CHR(13)+CHR(10)+ ;
    '        =MostPrintPatientOutput("D",lnPrintPatient,"")'+CHR(13)+CHR(10)+ ;
    '    ENDIF'+CHR(13)+CHR(10)+ ;
    '    IF "E" $ THISFORM.opt_selection'+CHR(13)+CHR(10)+ ;
    '        =MostPrintPatientOutput("E",lnPrintPatient,THISFORM.parent_object.text2.VALUE)'+CHR(13)+CHR(10)+ ;
    '    ENDIF'+CHR(13)+CHR(10)+ ;
    'ENDFOR'+CHR(13)+CHR(10)+ ;
    'THISFORM.stop=1'
USE (lcForm) EXCLUSIVE ALIAS patchlabeldirect
llFound=.F.
SCAN FOR LOWER(ALLTRIM(objname))=="printer" AND LOWER(ALLTRIM(baseclass))=="commandbutton"
    lcMethods=patchlabeldirect.methods
    IF !("lnPrintPatient=THISFORM.parent_object.id1.VALUE" $ lcMethods)
        lcMethods=STRTRAN(lcMethods,lcAnchor,lcDirect,1,1,0)
        REPLACE methods WITH lcMethods IN patchlabeldirect
    ENDIF
    llFound="lnPrintPatient=THISFORM.parent_object.id1.VALUE" $ lcMethods
ENDSCAN
USE IN patchlabeldirect
IF !llFound
    ERROR "The direct label-window print route was not installed."
ENDIF
RETURN
