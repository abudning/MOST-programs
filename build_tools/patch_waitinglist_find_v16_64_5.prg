LPARAMETERS tcClasses
LOCAL lcMethods, lcOld, lcNew
SET SAFETY OFF
USE (ADDBS(tcClasses)+"tools.vcx") EXCLUSIVE ALIAS wlclass
LOCATE FOR LOWER(ALLTRIM(objname))="oletreeview" AND ;
    LOWER(ALLTRIM(parent))="waitinglist2" AND !DELETED()
IF !FOUND()
    ERROR "Waiting List tree control was not found."
ENDIF

lcMethods = methods
TEXT TO lcOld NOSHOW
		THIS.NodeClick(loNode)
		THISFORM.ID = loNode.TAG
ENDTEXT
TEXT TO lcNew NOSHOW
		THIS.NodeClick(loNode)
		THISFORM.ID = loNode.TAG
		* Patient leaves hold appointment IDs. Category/root clicks remain unchanged.
		IF loNode.Children = 0 AND !INLIST(loNode.TEXT,"Rebooked","Waiting List")
			DO waitinglist_find WITH loNode.TAG
		ENDIF
ENDTEXT
IF OCCURS(lcOld, lcMethods) # 1
    ERROR "Expected Waiting List left-click block was not unique."
ENDIF
REPLACE methods WITH STRTRAN(lcMethods, lcOld, lcNew)
USE IN wlclass
