FUNCTION ResolveChartRoot
LPARAMETERS tcConfiguredRoot
LOCAL lcRoot
IF VARTYPE(tcConfiguredRoot)=="C" AND !EMPTY(ALLTRIM(tcConfiguredRoot))
    lcRoot=ADDBS(ALLTRIM(tcConfiguredRoot))
ELSE
    lcRoot="S:\"
ENDIF
IF LOWER(RIGHT(lcRoot,7))=="\charts\"
    RETURN lcRoot
ENDIF
IF DIRECTORY(lcRoot+"charts")
    RETURN ADDBS(lcRoot+"charts")
ENDIF
RETURN lcRoot
ENDFUNC
