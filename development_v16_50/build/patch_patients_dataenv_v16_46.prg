CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
LOCAL lcForm,lcMethods
lcForm="E:\MOST for chat\oms_vfp9_build\MOSt\FORMS\patients.scx"
USE (lcForm) EXCLUSIVE ALIAS p46
LOCATE FOR LOWER(ALLTRIM(p46.baseclass))=="dataenvironment"
IF !FOUND()
 ERROR "Patients DataEnvironment not found"
ENDIF
lcMethods=p46.methods
TEXT TO lcBefore NOSHOW
PROCEDURE BeforeOpenTables
* V16.46: route shared Patients tables through configured server database path.
THIS.Cursor1.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor2.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor3.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor4.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor5.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor6.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor7.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor8.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor9.Database=oms_local_fullpath
THIS.Cursor10.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor11.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor12.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor13.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor14.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor15.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor16.Database=ADDBS(path_to_data)+"schedata.dbc"
ENDPROC
ENDTEXT
LOCAL lnStart,lnRelEnd,lnEnd
lnStart=ATC("PROCEDURE BeforeOpenTables",lcMethods)
IF lnStart=0
 lcMethods=lcMethods+CHR(13)+CHR(10)+lcBefore
ELSE
 lnRelEnd=ATC("ENDPROC",SUBSTR(lcMethods,lnStart))
 lnEnd=lnStart+lnRelEnd+LEN("ENDPROC")-2
 lcMethods=LEFT(lcMethods,lnStart-1)+lcBefore+SUBSTR(lcMethods,lnEnd+1)
ENDIF
REPLACE p46.methods WITH lcMethods IN p46
USE IN p46
STRTOFILE("SUCCESS", "C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\patch_patients_dataenv_v16_46.log",0)
QUIT
