CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
LOCAL lcRoot,lcForm,lcMethods,lcBefore,lnStart,lnRelEnd,lnEnd
lcRoot="E:\MOST for chat\oms_vfp9_build\MOSt\FORMS\"
* Claims: all shared cursors use OMS; OPTIONS remains local.
lcForm=lcRoot+"enter_claims.scx"
USE (lcForm) EXCLUSIVE ALIAS f47
LOCATE FOR LOWER(ALLTRIM(f47.baseclass))=="dataenvironment"
lcMethods=f47.methods
TEXT TO lcBefore NOSHOW
PROCEDURE BeforeOpenTables
* V16.47: route Claims shared tables through configured server database path.
THIS.Cursor1.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor2.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor3.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor4.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor5.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor6.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor7.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor8.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor9.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor10.Database=oms_local_fullpath
THIS.Cursor11.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor12.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor13.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor14.Database=ADDBS(path_to_data)+"oms.dbc"
ENDPROC
ENDTEXT
lnStart=ATC("PROCEDURE BeforeOpenTables",lcMethods)
lnRelEnd=ATC("ENDPROC",SUBSTR(lcMethods,lnStart))
lnEnd=lnStart+lnRelEnd+LEN("ENDPROC")-2
REPLACE f47.methods WITH LEFT(lcMethods,lnStart-1)+lcBefore+SUBSTR(lcMethods,lnEnd+1) IN f47
USE IN f47
* LetterBuilder: letter cursors use LETTERS, clinical cursors use OMS, OPTIONS local.
lcForm=lcRoot+"letterform.scx"
USE (lcForm) EXCLUSIVE ALIAS f47
LOCATE FOR LOWER(ALLTRIM(f47.baseclass))=="dataenvironment"
lcMethods=f47.methods
TEXT TO lcBefore NOSHOW
PROCEDURE BeforeOpenTables
* V16.47: route LetterBuilder databases explicitly.
THIS.Cursor1.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor2.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor3.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor4.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor5.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor6.Database=ADDBS(path_to_data)+"letters.dbc"
THIS.Cursor7.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor8.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor9.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor10.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor11.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor12.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor13.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor14.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor15.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor16.Database=ADDBS(path_to_data)+"oms.dbc"
THIS.Cursor17.Database=oms_local_fullpath
ENDPROC
ENDTEXT
lnStart=ATC("PROCEDURE BeforeOpenTables",lcMethods)
IF lnStart=0
 lcMethods=lcMethods+CHR(13)+CHR(10)+lcBefore
ELSE
 lnRelEnd=ATC("ENDPROC",SUBSTR(lcMethods,lnStart))
 lnEnd=lnStart+lnRelEnd+LEN("ENDPROC")-2
 lcMethods=LEFT(lcMethods,lnStart-1)+lcBefore+SUBSTR(lcMethods,lnEnd+1)
ENDIF
REPLACE f47.methods WITH lcMethods IN f47
USE IN f47
STRTOFILE("SUCCESS","C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\patch_claims_letters_dataenv_v16_47.log",0)
QUIT
