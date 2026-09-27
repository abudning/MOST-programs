LPARAMETERS tcForms
LOCAL lcCode
SET SAFETY OFF
USE (ADDBS(tcForms)+"invoice.scx") EXCLUSIVE ALIAS tphform
LOCATE FOR LOWER(ALLTRIM(objname))="command4" AND LOWER(ALLTRIM(parent))="form1" AND !DELETED()
IF !FOUND()
    ERROR "Outstanding invoice History button was not found."
ENDIF
TEXT TO lcCode NOSHOW
PROCEDURE Click
LOCAL lnPatient
SELECT invoice
IF EOF()
    RETURN
ENDIF
lnPatient=invoice.id
SET PROCEDURE TO thirdparty_history ADDITIVE
=TpShowPaidHistory(lnPatient)
ENDPROC
ENDTEXT
REPLACE methods WITH lcCode
USE IN tphform
