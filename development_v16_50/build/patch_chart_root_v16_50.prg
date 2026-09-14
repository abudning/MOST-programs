CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
LOCAL lcForm,lcMethods,lcProps
lcForm="E:\MOST for chat\oms_vfp9_build\MOSt\FORMS\patients.scx"
USE (lcForm) EXCLUSIVE ALIAS c50
LOCATE FOR UPPER(ALLTRIM(c50.objname))=="CMDREFERRALPDF"
IF !FOUND()
 ERROR "Referral PDF button not found"
ENDIF
lcMethods=STRTRAN(c50.methods,'ADDBS("S:\Charts")','ADDBS("S:\")',1,-1,1)
lcProps=STRTRAN(c50.properties,'S:\Charts','S:\',1,-1,1)
REPLACE c50.methods WITH lcMethods, c50.properties WITH lcProps IN c50
USE IN c50
STRTOFILE("SUCCESS","C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\patch_chart_root_v16_50.log",0)
QUIT
