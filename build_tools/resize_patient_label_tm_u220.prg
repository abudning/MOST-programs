LPARAMETERS tcLabel
LOCAL lcAlias
lcAlias="epsonlabel"
USE (FULLPATH(tcLabel)) EXCLUSIVE IN 0 ALIAS (lcAlias)
SELECT (lcAlias)

* 76 mm roll, approximately 63.4 mm usable print width.
* Keep a small internal safety margin: 24,500 report units = 62.23 mm.
REPLACE height WITH 33000 FOR objtype=9 AND objcode=4

LOCATE FOR objtype=8 AND "upper(ALLT(Surname))" $ expr
IF !FOUND()
    ERROR "Patient name field not found."
ENDIF
REPLACE hpos WITH 0,width WITH 24500,vpos WITH 1800,height WITH 1900,fontsize WITH 9

LOCATE FOR objtype=8 AND "proper(ALLT(Address))" $ expr
IF !FOUND()
    ERROR "Address field not found."
ENDIF
REPLACE hpos WITH 0,width WITH 24500,vpos WITH 4700,height WITH 1700,fontsize WITH 8

LOCATE FOR objtype=8 AND "proper(ALLT(City))" $ expr
IF !FOUND()
    ERROR "City field not found."
ENDIF
REPLACE hpos WITH 0,width WITH 24500,vpos WITH 6900,height WITH 1700,fontsize WITH 8

LOCATE FOR objtype=8 AND "Age:" $ expr
IF !FOUND()
    ERROR "Demographics field not found."
ENDIF
REPLACE hpos WITH 0,width WITH 24500,vpos WITH 9100,height WITH 1700,fontsize WITH 8

LOCATE FOR objtype=8 AND '"H: "' $ expr
IF !FOUND()
    ERROR "Telephone field not found."
ENDIF
REPLACE hpos WITH 0,width WITH 24500,vpos WITH 11300,height WITH 1700,fontsize WITH 7

LOCATE FOR objtype=8 AND '"HC: "' $ expr
IF !FOUND()
    ERROR "Health-card field not found."
ENDIF
REPLACE hpos WITH 0,width WITH 24500,vpos WITH 13700,height WITH 1700,fontsize WITH 7

LOCATE FOR objtype=8 AND expr='"Printed: "'
IF !FOUND()
    ERROR "Printed label not found."
ENDIF
REPLACE hpos WITH 0,width WITH 6000,vpos WITH 17800,height WITH 1400,fontsize WITH 7

LOCATE FOR objtype=8 AND expr="DATE()"
IF !FOUND()
    ERROR "Printed date field not found."
ENDIF
REPLACE hpos WITH 5600,width WITH 8500,vpos WITH 17800,height WITH 1400,fontsize WITH 7

LOCATE FOR objtype=8 AND expr='"Last Edit: "'
IF !FOUND()
    ERROR "Last Edit label not found."
ENDIF
REPLACE hpos WITH 0,width WITH 7000,vpos WITH 19900,height WITH 1400,fontsize WITH 7

LOCATE FOR objtype=8 AND expr="LAST_EDIT"
IF !FOUND()
    ERROR "Last Edit value field not found."
ENDIF
REPLACE hpos WITH 6600,width WITH 9500,vpos WITH 19900,height WITH 1400,fontsize WITH 7

* Remove the obsolete IBM/LPT2 printer environment. The runtime router creates
* its own temporary label and applies the selected Epson driver for each job.
LOCATE FOR objtype=1 AND objcode=53
IF FOUND()
    REPLACE expr WITH "",tag WITH "",tag2 WITH ""
ENDIF

USE IN (lcAlias)
RETURN
