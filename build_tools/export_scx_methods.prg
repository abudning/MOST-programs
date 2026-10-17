LPARAMETERS tcScx,tcOutput
LOCAL lcAlias,lcText
lcAlias="scxmethods"
lcText=""
USE (FULLPATH(tcScx)) SHARED IN 0 ALIAS (lcAlias)
SELECT (lcAlias)
SCAN FOR !DELETED() AND !EMPTY(methods)
    lcText=lcText+REPLICATE("=",72)+CHR(13)+CHR(10)+ ;
        "OBJECT: "+ALLTRIM(objname)+" | CLASS: "+ALLTRIM(class)+CHR(13)+CHR(10)+ ;
        REPLICATE("=",72)+CHR(13)+CHR(10)+methods+CHR(13)+CHR(10)
ENDSCAN
USE IN (lcAlias)
STRTOFILE(lcText,FULLPATH(tcOutput),0)
RETURN
