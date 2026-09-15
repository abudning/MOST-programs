LPARAMETERS tcMenuMnx
LOCAL lcProc,lcNeed,lcAnchor
IF VARTYPE(tcMenuMnx)#"C" OR !FILE(tcMenuMnx)
 ERROR "Main menu MNX was not supplied"
ENDIF
USE (tcMenuMnx) EXCLUSIVE ALIAS v59menu
LOCATE FOR UPPER(ALLTRIM(v59menu.prompt))=="SCHEDULER"
IF !FOUND()
 ERROR "Scheduler menu item was not found"
ENDIF
lcProc=v59menu.procedure
lcNeed='IF !DBUSED("SCHEDATA")'
lcAnchor=CHR(13)+CHR(10)+CHR(9)+"SELECT ROOMTABLE.Roomname,roomtable.roomid ;"
IF !(lcNeed $ lcProc)
 IF !(lcAnchor $ lcProc)
  ERROR "Scheduler room query anchor was not found"
 ENDIF
 TEXT TO lcNeed NOSHOW
	* V16.59 Always open the Scheduler database from the configured shared data folder.
	IF !DBUSED("SCHEDATA")
		OPEN DATABASE (ADDBS(ALLTRIM(path_to_data))+"schedata") SHARED
	ENDIF

 ENDTEXT
 lcProc=STRTRAN(lcProc,lcAnchor,lcNeed+lcAnchor,1,1,1)
 REPLACE procedure WITH lcProc IN v59menu
ENDIF
USE IN v59menu
RETURN .T.