LOCAL lcBase, lcLog, lcMethods
lcBase = ADDBS(JUSTPATH(SYS(16)))
lcLog = lcBase + "patch_pdf_filename_search_result.txt"
SET SAFETY OFF
SET TALK OFF
SET EXCLUSIVE ON
ON ERROR DO PatchFailed WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog

TEXT TO lcMethods NOSHOW
PROCEDURE Click
LOCAL lcRoot, lcSearchDir, lcId, lcLast, lcFirst, lcPdf, lcPrompt, lcAnswer, lcDisplay
LOCAL lcStem, lcTokens, lcToken, llMatch
LOCAL lnDirCount, lnDir, lnFound, lnF, lnMatches, lnRow, lnChoice, lnResult, lnFailures, ltModified
LOCAL lnTokenCount, lnToken
LOCAL ARRAY laDirs[1], laFound[1], laCount[1]

lcRoot = ADDBS("S:\Charts")
IF !DIRECTORY(lcRoot)
	MESSAGEBOX("The chart folder is not available:" + CHR(13) + lcRoot + CHR(13) + ;
		"Confirm that drive S: is connected, then try again.", 48, "MOST - Referral PDF")
	RETURN
ENDIF
IF !USED("patients") OR EOF("patients") OR BOF("patients")
	MESSAGEBOX("Select a patient before opening a referral PDF.", 48, "MOST - Referral PDF")
	RETURN
ENDIF

lcId = ALLTRIM(TRANSFORM(patients.id))
lcLast = ALLTRIM(patients.surname)
lcFirst = ALLTRIM(patients.firstname)
lcId = STRTRAN(STRTRAN(STRTRAN(lcId, "*", ""), "?", ""), "~", "")
lcLast = STRTRAN(STRTRAN(STRTRAN(lcLast, "*", ""), "?", ""), "~", "")
lcFirst = STRTRAN(STRTRAN(STRTRAN(lcFirst, "*", ""), "?", ""), "~", "")
IF EMPTY(lcId) AND (EMPTY(lcLast) OR EMPTY(lcFirst))
	MESSAGEBOX("The selected patient does not have enough identifying information for a PDF search.", ;
		48, "MOST - Referral PDF")
	RETURN
ENDIF

IF USED("csrReferralCandidates")
	USE IN csrReferralCandidates
ENDIF
CREATE CURSOR csrReferralCandidates (fullpath M, pdfname C(254), modified T)

lnDirCount = ADIR(laDirs, lcRoot + "*.*", "D")
FOR lnDir = 0 TO lnDirCount
	IF lnDir = 0
		lcSearchDir = lcRoot
	ELSE
		IF !("D" $ laDirs[lnDir, 5]) OR INLIST(laDirs[lnDir, 1], ".", "..")
			LOOP
		ENDIF
		lcSearchDir = ADDBS(lcRoot + laDirs[lnDir, 1])
	ENDIF
	lnFound = ADIR(laFound, lcSearchDir + "*.pdf")
	FOR lnF = 1 TO lnFound
		lcStem = LEFT(laFound[lnF, 1], MAX(0, LEN(laFound[lnF, 1]) - 4))
		lcTokens = "~"
		lnTokenCount = GETWORDCOUNT(lcStem, "~")
		FOR lnToken = 1 TO lnTokenCount
			lcToken = UPPER(ALLTRIM(GETWORDNUM(lcStem, lnToken, "~")))
			IF EMPTY(lcToken) OR INLIST(lcToken, "L", "C", "T")
				LOOP
			ENDIF
			lcTokens = lcTokens + lcToken + "~"
	ENDFOR
		llMatch = !EMPTY(lcId) AND (("~" + UPPER(lcId) + "~") $ lcTokens)
		IF !llMatch AND !EMPTY(lcLast) AND !EMPTY(lcFirst)
			llMatch = (("~" + UPPER(lcLast) + "~" + UPPER(lcFirst) + "~") $ lcTokens) OR ;
				(("~" + UPPER(lcFirst) + "~" + UPPER(lcLast) + "~") $ lcTokens)
		ENDIF
		IF llMatch
			lcPdf = lcSearchDir + laFound[lnF, 1]
			ltModified = DATETIME(YEAR(laFound[lnF, 3]), MONTH(laFound[lnF, 3]), ;
				DAY(laFound[lnF, 3]), VAL(LEFT(laFound[lnF, 4], 2)), ;
				VAL(SUBSTR(laFound[lnF, 4], 4, 2)), VAL(SUBSTR(laFound[lnF, 4], 7, 2)))
			INSERT INTO csrReferralCandidates VALUES (lcPdf, laFound[lnF, 1], ltModified)
		ENDIF
	ENDFOR
ENDFOR

SELECT COUNT(*) AS matchcount FROM csrReferralCandidates INTO ARRAY laCount
lnMatches = laCount[1]
IF lnMatches = 0
	USE IN csrReferralCandidates
	MESSAGEBOX("No referral PDF was found for:" + CHR(13) + ;
		IIF(EMPTY(lcId), "", "ID " + lcId + CHR(13)) + lcLast + "~" + lcFirst, ;
		64, "MOST - Referral PDF")
	RETURN
ENDIF

DECLARE INTEGER ShellExecute IN shell32.dll ;
	INTEGER hwnd, STRING cOperation, STRING cFile, STRING cParameters, ;
	STRING cDirectory, INTEGER nShowCmd
IF lnMatches = 1
	SELECT csrReferralCandidates
	GO TOP
	lcPdf = ALLTRIM(fullpath)
	USE IN csrReferralCandidates
	lnResult = ShellExecute(0, "open", lcPdf, "", lcRoot, 1)
	IF lnResult <= 32
		MESSAGEBOX("Adobe Reader could not open the selected PDF.", 16, "MOST - Referral PDF")
	ENDIF
	RETURN
ENDIF

lnFailures = 0
SELECT csrReferralCandidates
GO TOP
SCAN
	lnResult = ShellExecute(0, "open", ALLTRIM(fullpath), "", lcRoot, 1)
	IF lnResult <= 32
		lnFailures = lnFailures + 1
	ENDIF
ENDSCAN
USE IN csrReferralCandidates
IF lnFailures > 0
	MESSAGEBOX(TRANSFORM(lnFailures) + " PDF file(s) could not be opened.", 16, "MOST - Referral PDF")
ENDIF
ENDPROC
ENDTEXT
lcMethods = lcMethods + CHR(13) + CHR(10)

USE (lcBase + "patients.scx") EXCLUSIVE ALIAS patchform
LOCATE FOR UPPER(ALLTRIM(objname)) == "CMDREFERRALPDF"
IF !FOUND()
	STRTOFILE("FAILED: PDF button was not found." + CHR(13) + CHR(10), lcLog, 0)
	USE IN patchform
	RETURN
ENDIF
REPLACE methods WITH lcMethods
USE IN patchform
STRTOFILE("SUCCESS: Tilde filename and modified-date PDF search applied." + CHR(13) + CHR(10), lcLog, 0)
RETURN

PROCEDURE PatchFailed
	LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
	LOCAL lcFailure
	lcFailure = "FAILED" + CHR(13) + CHR(10) + "Error: " + TRANSFORM(tnError) + ;
		CHR(13) + CHR(10) + "Message: " + TRANSFORM(tcMessage) + CHR(13) + CHR(10) + ;
		"Code: " + TRANSFORM(tcCode) + CHR(13) + CHR(10) + ;
		"Program: " + TRANSFORM(tcProgram) + CHR(13) + CHR(10) + ;
		"Line: " + TRANSFORM(tnLine) + CHR(13) + CHR(10)
	STRTOFILE(lcFailure, tcLog, 0)
	IF USED("patchform")
		USE IN patchform
	ENDIF
	RETURN
ENDPROC
