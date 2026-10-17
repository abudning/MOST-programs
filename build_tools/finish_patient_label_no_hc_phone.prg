LPARAMETERS tcLabel,tcExpression
LOCAL lcAlias,lcRefExpression
lcAlias="finishlabel"
lcRefExpression=ALLTRIM(FILETOSTR(FULLPATH(tcExpression)))
USE (FULLPATH(tcLabel)) EXCLUSIVE IN 0 ALIAS (lcAlias)
SELECT (lcAlias)
REPLACE expr WITH '""',width WITH 0,height WITH 0 FOR objtype=8 AND "Phone_home" $ expr
LOCATE FOR objtype=8 AND "Healthnum" $ expr
IF !FOUND()
    USE IN (lcAlias)
    ERROR "Health-card field not found."
ENDIF
REPLACE expr WITH lcRefExpression,hpos WITH 0,width WITH 24500,;
    vpos WITH 11500,height WITH 1700,fontsize WITH 8
REPLACE vpos WITH 14900 FOR objtype=8 AND expr='"Printed: "'
REPLACE vpos WITH 14900 FOR objtype=8 AND expr="DATE()"
REPLACE vpos WITH 17100 FOR objtype=8 AND expr='"Last Edit: "'
REPLACE vpos WITH 17100 FOR objtype=8 AND expr="LAST_EDIT"
USE IN (lcAlias)
RETURN
