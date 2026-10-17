LPARAMETERS tcReport,tcOutput
LOCAL lcAlias,lcText,lnFields,lnField
LOCAL ARRAY laFields[1]
lcAlias="reportinspect"
lcText=""
USE (FULLPATH(tcReport)) SHARED IN 0 ALIAS (lcAlias)
SELECT (lcAlias)
lnFields=AFIELDS(laFields)
lcText="FIELDS"+CHR(13)+CHR(10)
FOR lnField=1 TO lnFields
    lcText=lcText+TRANSFORM(lnField)+"|"+laFields[lnField,1]+"|"+;
        laFields[lnField,2]+"|"+TRANSFORM(laFields[lnField,3])+"|"+;
        TRANSFORM(laFields[lnField,4])+CHR(13)+CHR(10)
ENDFOR
lcText=lcText+CHR(13)+CHR(10)+"RECORDS"+CHR(13)+CHR(10)
SCAN
    lcText=lcText+"REC="+TRANSFORM(RECNO())+;
        " OBJTYPE="+TRANSFORM(objtype)+" OBJCODE="+TRANSFORM(objcode)+;
        " HPOS="+TRANSFORM(hpos)+" VPOS="+TRANSFORM(vpos)+;
        " WIDTH="+TRANSFORM(width)+" HEIGHT="+TRANSFORM(height)+;
        " FONT="+fontface+" SIZE="+TRANSFORM(fontsize)+;
        " STYLE="+TRANSFORM(fontstyle)+" STRETCH="+TRANSFORM(stretch)+CHR(13)+CHR(10)+;
        "EXPR="+STRTRAN(expr,CHR(13),"<CR>")+CHR(13)+CHR(10)+;
        "TAG="+STRTRAN(tag,CHR(13),"<CR>")+CHR(13)+CHR(10)+;
        "TAG2="+STRTRAN(tag2,CHR(13),"<CR>")+CHR(13)+CHR(10)
ENDSCAN
USE IN (lcAlias)
STRTOFILE(lcText,FULLPATH(tcOutput),0)
RETURN
