CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
SET EXCLUSIVE ON
LOCAL lcRoot, lcMost, lcPrograms, lcForms, lcOutput, lcBackup, lcLog
LOCAL lcOms, lcText, lcOld, lcNew, lcProps, lcMethods, lcAnchor, lcInsert
lcRoot="E:\MOST for chat\oms_vfp9_build\"
lcMost=lcRoot+"MOSt\"
lcPrograms=lcMost+"PROGRAMS\"
lcForms=lcMost+"FORMS\"
lcOutput=lcRoot+"output\"
lcBackup=lcRoot+"backup_v16_29_xp_letter_lock_20260913\"
lcLog=lcOutput+"build_v16_29_xp_letter_lock.log"
ON ERROR DO BuildError WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
IF !DIRECTORY(lcBackup)
    MD (lcBackup)
    MD (lcBackup+"PROGRAMS")
    MD (lcBackup+"FORMS")
ENDIF
COPY FILE (lcPrograms+"oms.prg") TO (lcBackup+"PROGRAMS\oms.prg")
COPY FILE (lcForms+"version.scx") TO (lcBackup+"FORMS\version.scx")
COPY FILE (lcForms+"version.sct") TO (lcBackup+"FORMS\version.sct")
COPY FILE (lcForms+"letterform.scx") TO (lcBackup+"FORMS\letterform.scx")
COPY FILE (lcForms+"letterform.sct") TO (lcBackup+"FORMS\letterform.sct")

* Extend the accepted executable versions without changing database structures.
lcOms=lcPrograms+"oms.prg"
lcText=FILETOSTR(lcOms)
lcOld='normalized_version("1.7.625"), normalized_version("1.7.626"), normalized_version("1.7.627"), normalized_version("1.7.628"), normalized_version("1.7.629")) ;'
lcNew='normalized_version("1.7.625"), normalized_version("1.7.626"), normalized_version("1.7.627"), normalized_version("1.7.628"), normalized_version("1.7.629"), normalized_version("1.7.630")) ;'
IF lcOld $ lcText
    STRTOFILE(STRTRAN(lcText,lcOld,lcNew,1,1,1),lcOms,0)
ELSE
    IF !('normalized_version("1.7.630")' $ lcText)
        ERROR "Version guard could not be patched"
    ENDIF
ENDIF

* Display V16.29 in About MOSt.
USE (lcForms+"version.scx") EXCLUSIVE ALIAS v29version
SCAN
    lcProps=v29version.properties
    lcMethods=v29version.methods
    IF "V16.28" $ lcProps
        REPLACE properties WITH STRTRAN(lcProps,"V16.28","V16.29",1,-1,1) IN v29version
    ENDIF
    IF "V16.28" $ lcMethods
        REPLACE methods WITH STRTRAN(lcMethods,"V16.28","V16.29",1,-1,1) IN v29version
    ENDIF
ENDSCAN
USE IN v29version

* Patch only the active patient-letter edit button.
USE (lcForms+"letterform.scx") EXCLUSIVE ALIAS v29letter
LOCATE FOR UPPER(ALLTRIM(v29letter.objname))=="WORD" AND "PAGE1" $ UPPER(v29letter.parent)
IF !FOUND()
    ERROR "LetterBuilder Word button was not found"
ENDIF
lcMethods=v29letter.methods
IF !("V16.29 XP MULTI-WORKSTATION LETTER LOCK" $ lcMethods)
    lcAnchor=CHR(9)+"WORD=getcominstance('word.application')"
    IF OCCURS(lcAnchor,lcMethods)#1
        ERROR "Active LetterBuilder Word-open anchor was not unique"
    ENDIF
    TEXT TO lcInsert NOSHOW
	* V16.29 XP MULTI-WORKSTATION LETTER LOCK
	LOCAL lcOwnerFile, lcLetterName, laOwner[1], lnLockChoice, loLockedDoc, loLockError
	lcLetterName=JUSTFNAME(strFileExistsLoc)
	lcOwnerFile=IIF(LEN(lcLetterName)>2,ADDBS(JUSTPATH(strFileExistsLoc))+"~$"+SUBSTR(lcLetterName,3),"")
	IF !EMPTY(lcOwnerFile) AND ADIR(laOwner,lcOwnerFile,"H")>0
		lnLockChoice=MESSAGEBOX("This letter is currently open on another workstation."+CHR(13)+CHR(13)+;
			"Choose Yes to view it read-only, or No to cancel.",4+48+256,"MOSt - Letter Already Open")
		IF lnLockChoice=6
			WORD=getcominstance('word.application')
			IF ISNULL(WORD)
				MESSAGEBOX("Microsoft Word could not be opened.",16,"MOSt - Read-Only Letter")
				RETURN
			ENDIF
			TRY
				loLockedDoc=WORD.documents.OPEN(strFileExistsLoc,.F.,.T.,.F.)
				WORD.VISIBLE=.T.
				MESSAGEBOX("The letter was opened READ-ONLY. Changes cannot be saved over the original.",64,"MOSt - Read-Only Letter")
			CATCH TO loLockError
				MESSAGEBOX("The letter could not be opened read-only."+CHR(13)+loLockError.Message,16,"MOSt - Read-Only Letter")
			ENDTRY
		ENDIF
		RETURN
	ENDIF
    ENDTEXT
    REPLACE methods WITH STRTRAN(lcMethods,lcAnchor,lcInsert+CHR(13)+CHR(10)+lcAnchor,1,1,1) IN v29letter
ENDIF

* Printing never needs write access; force the active Print button to open read-only.
LOCATE FOR UPPER(ALLTRIM(v29letter.objname))=="PRINT" AND "PAGE1" $ UPPER(v29letter.parent)
IF !FOUND()
    ERROR "LetterBuilder Print button was not found"
ENDIF
lcMethods=v29letter.methods
IF !("V16.29 READ-ONLY PRINT OPEN" $ lcMethods)
    lcAnchor=CHR(9)+CHR(9)+"WORD.documents.OPEN(strFileExistsLoc)"
    IF OCCURS(lcAnchor,lcMethods)#1
        ERROR "LetterBuilder print-open anchor was not unique"
    ENDIF
    lcInsert=CHR(9)+CHR(9)+"* V16.29 READ-ONLY PRINT OPEN"+CHR(13)+CHR(10)+;
        CHR(9)+CHR(9)+"WORD.documents.OPEN(strFileExistsLoc,.F.,.T.,.F.)"
    REPLACE methods WITH STRTRAN(lcMethods,lcAnchor,lcInsert,1,1,1) IN v29letter
ENDIF
USE IN v29letter

CD (lcMost)
_GENMENU=lcRoot+"genmenu.prg"
SET DEFAULT TO (lcMost)
BUILD EXE (lcOutput+"MOST_V16_29_XP_LETTER_LOCK.exe") FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS V16.29 1.7.630 "+TTOC(DATETIME(),1)+CHR(13)+CHR(10),lcLog,0)
ON ERROR
QUIT

PROCEDURE BuildError
LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
LOCAL lcError
lcError="ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10)
STRTOFILE(lcError,tcLog,0)
MESSAGEBOX(lcError,16,"MOSt V16.29 build")
CANCEL
ENDPROC
