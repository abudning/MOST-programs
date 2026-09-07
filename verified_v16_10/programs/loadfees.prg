**** program loads fees from ohip feecode data
**** The file with updates must have the ".001" extension
**** and must be put in MOSt\DATA directory  or Drive A:  only 1 file allowed
*!* Program:
*!* Author:
*!* Date: 01/23/04 11:40:53 AM
*!* Copyright:  MBT
*!* Description:
*!* Revision Information:
*!* Date 			Coder		Description
*!*-------------------------------------------------------------------------------------
*!* 2004.23.01		Erick		New code to update unit numbers for Tech/Assistant and
*!*								Anaesthetist on tthe fly (program: fees_calc_units()
*!* 2004-10-16  	ET			Corrections to code and comments
*!*

&&set escape on
SET TALK OFF
LOCAL m_append_new,i,j,m_file_name, bFloppyDrive, m.MOStTempFolder, m.YesToAll

m.MOStTempFolder = ADDBS(SYS(2023))

bFloppyDrive = .F.
m.YesToAll = .F.

SET DATE TO ANSI
SET CENTURY ON

m.CurrSetSafety = SET("SAFETY")

SET SAFETY OFF

** CREATE TEMP table for service changed report
CREATE TABLE m.MOStTempFolder+"tempfee.dbf" FREE ;
	(OldServ c(6), ;
	NewServ c(6), ;
	oldfeeDsc c(45), ;
	NewFeeDsc c(45))
USE &&CLose Temp

*SET SAFETY &m.CurrSetSafety
SET SAFETY ON


* V16: accept the current Ministry ZIP, TXT, or extracted .001 file.
LOCAL lcSourceFile, lcImportFile, lcDownloads, lcWorkFolder, lcOfficialUrl
LOCAL loShell, loZip, loDestination, lnChoice, lnWait, lnNewest, ltNewest
lcOfficialUrl = "https://www.ontario.ca/page/ohip-schedule-benefits-and-fees"
lcDownloads = ADDBS(GETENV("USERPROFILE")) + "Downloads\"
lcSourceFile = ""
ltNewest = {^1900-01-01}
nFiles = ADIR(aFiles, lcDownloads + "moh-ohip-fee-schedule-master*")
FOR i = 1 TO nFiles
    IF UPPER(JUSTEXT(aFiles(i,1))) $ "ZIP,TXT,001" AND aFiles(i,3) >= ltNewest
        ltNewest = aFiles(i,3)
        lcSourceFile = lcDownloads + aFiles(i,1)
    ENDIF
ENDFOR

IF !EMPTY(lcSourceFile)
    lnChoice = MESSAGEBOX("Use the newest downloaded OHIP Physician Fee Schedule Master?" + CHR(13) + ;
        JUSTFNAME(lcSourceFile) + CHR(13)+CHR(13) + ;
        "Yes = use it, No = choose another file, Cancel = open the official download page.", ;
        3+32, "MOSt - MOH Fee Update")
ELSE
    lnChoice = 7
ENDIF

DO CASE
CASE lnChoice = 2
    DECLARE INTEGER ShellExecute IN shell32 INTEGER, STRING, STRING, STRING, STRING, INTEGER
    =ShellExecute(0, "open", lcOfficialUrl, "", "", 1)
    MESSAGEBOX("Download the OHIP Physician Fee Schedule Master in ZIP or Text format, then run MOH Fees Update again.", 64, "MOSt")
    RETURN
CASE lnChoice = 7
    lcSourceFile = GETFILE("zip;txt;001", "Select the OHIP Physician Fee Schedule Master", "Open", 0, "MOSt - MOH Fee Update")
ENDCASE

IF EMPTY(lcSourceFile) OR !FILE(lcSourceFile)
    RETURN
ENDIF

lcImportFile = lcSourceFile
IF UPPER(JUSTEXT(lcSourceFile)) == "ZIP"
    lcWorkFolder = ADDBS(SYS(2023)) + "MOST_OHIP_FEE\"
    IF !DIRECTORY(lcWorkFolder)
        MD (lcWorkFolder)
    ENDIF
    DELETE FILE (lcWorkFolder + "*.001")
    DELETE FILE (lcWorkFolder + "*.txt")
    loShell = CREATEOBJECT("Shell.Application")
    loZip = loShell.NameSpace(lcSourceFile)
    loDestination = loShell.NameSpace(lcWorkFolder)
    IF VARTYPE(loZip) # "O" OR VARTYPE(loDestination) # "O"
        MESSAGEBOX("The ZIP file could not be opened.", 16, "MOSt - MOH Fee Update")
        RETURN
    ENDIF
    loDestination.CopyHere(loZip.Items, 20)
    lcImportFile = ""
    FOR lnWait = 1 TO 100
        DOEVENTS
        =INKEY(.1)
        nFiles = ADIR(aFiles, lcWorkFolder + "*.001")
        IF nFiles > 0
            lcImportFile = lcWorkFolder + aFiles(1,1)
            EXIT
        ENDIF
    ENDFOR
ENDIF

IF EMPTY(lcImportFile) OR !FILE(lcImportFile)
    MESSAGEBOX("No .001 fee master was found in the selected download.", 16, "MOSt - MOH Fee Update")
    RETURN
ENDIF

CLOSE TABLES ALL


&& check if want to append new fee codes
cMessageTitle = 'MOSt - Append New Service (Fee) Codes ?'
cMessageText = 'Do you wish to append new fee codes to your Fee Table? '
nDialogType = 4 + 32
*  4 = Yes and No buttons
*  32 = Question mark icon
*  256 = Second button is default

nAnswer = MESSAGEBOX(cMessageText, nDialogType, cMessageTitle)

DO CASE
CASE nAnswer = 6
	m_append_new= .T.

CASE nAnswer = 7
	m_append_new = .F.
ENDCASE

* V16.3: use a fresh private cursor for every import.  The former shared
* fee_import_cursor.dbf could be stale, locked, or damaged and was never application data.
CREATE CURSOR fee_import_cursor (DATA C(79))
APPEND FROM (lcImportFile) TYPE SDF

** 2) check for format of .001 file
&& should be alpha followed by 3 numerics
** message if invalid service code  ? continue or abort
GO TOP
IF TYPE(LEFT(DATA,1))#'U' OR TYPE(SUBSTR(DATA,2,3))#'N'
** wrong file format
	MESSAGEBOX("MOH Fee File is in an incorrect format, Program will abort.",16,"MBT Validatiion")
	RETURN
ENDIF

* V16.2: recoverable backup of the fee table before changing any code.
LOCAL lcFeeBackupBase
lcFeeBackupBase = ADDBS(gc_datadrive) + "backup\fees_before_" + ;
    DTOS(DATE()) + STRTRAN(TIME(),":","")
COPY FILE (path_to_data + "fees.dbf") TO (lcFeeBackupBase + ".dbf")
IF FILE(path_to_data + "fees.cdx")
    COPY FILE (path_to_data + "fees.cdx") TO (lcFeeBackupBase + ".cdx")
ENDIF
IF FILE(path_to_data + "fees.fpt")
    COPY FILE (path_to_data + "fees.fpt") TO (lcFeeBackupBase + ".fpt")
ENDIF

SELECT 9
USE (path_to_data + "fees.dbf") SHARED ALIAS fees
LOCAL lnFeeCountBefore, lnFeeCountAfter
lnFeeCountBefore = RECCOUNT("fees")
SET ORDER TO TAG service

* GO ahead an update submitted AND claims
USE (path_to_data + "submited.dbf") IN 0 ALIAS submited
USE (path_to_data + "claims.dbf") IN 0 ALIAS claims
USE (m.MOStTempFolder+"tempfee.dbf") IN 0 ALIAS tempfee

GO TOP IN fee_import_cursor
LOCAL lnFeeTotal, lnFeeProcessed
lnFeeTotal = RECCOUNT("fee_import_cursor")
lnFeeProcessed = 0
DO WHILE .NOT. EOF("fee_import_cursor")
	lnFeeProcessed = lnFeeProcessed + 1
	IF MOD(lnFeeProcessed,100)=0
		WAIT WINDOW "Updating OHIP fees: " + TRANSFORM(lnFeeProcessed) + " of " + TRANSFORM(lnFeeTotal) NOWAIT
		DOEVENTS
	ENDIF
	SELECT 9
	servicecode = SUBSTR(fee_import_cursor.DATA,1,4)  && should be alpha followed by 3 numerics

	SEEK servicecode  && find matching fee
	IF FOUND() THEN
* 3) if third party is true and RMB OHIP and WCB are are all false then this code was created
* by the user previously  -> message This third party service code is now being used by MOH
* 	DO you  wish to over rwrite ?? or leave unchanged ->if over write true then find an empty
* service code eg change Z100 to Z101 (test if available ) if free then change all entries in submted
* and claims (and fee table) and in memo fields  note the change and date from Z100 to new code
*then  actually add the new code
** Also maintain list of all the changes and printout at the end.
** Also message  Yes to over write Yes to all No or No to all.

		IF fees.third_party AND (!fees.RMB AND !fees.ohip AND !fees.WCB)
* if third party is true and RMB OHIP and WCB are are all false then this code was created
* by the user previously

			IF m.YesToAll = .F.
				intAnswer = MESSAGEBOX("This third party service code is now being used by MOH."+CHR(13)+;
					"Do you wish to overwrite it?",4+32+256,"MBT Validation")

				IF intAnswer = 6
					intAnswer2 = MESSAGEBOX("Would you like to overwrite all service code conflicts.",4+32+256,"MBT Validation")
					IF intAnswer2 = 6 && YES
						intAnswer = 6
						m.YesToAll = .T.
					ENDIF
				ENDIF

			ENDIF

			IF intAnswer = 6 && YES
* IF OVER WRITE true then FIND an EMPTY
* service code eg change Z100 to Z101 (test if available ) if free then change all entries in submted
* and claims (and fee table) and in memo fields  note the change and date from Z100 to new code
* then  actually add the new code

*1) find the next available number, set order to Service
* and start from the same alpha service, and continue to the next alpha if not available.
* numeric value max is 999. eg. A999
* 2) once service code is determined, update other tables (claims,submitted) service fields
* and submitted.comments memo field with old service code and new service code
				m.CurrentService = fees.service
				m.CurrDecimal = SET("DECIMALS")
				SET DECIMALS TO 0
				m.AsciiValue = ASC(LEFT(fees.service,1))
				m.NewSeqNumber = ABS(VAL(SUBSTR(fees.service,2,3))+1)
				m.NextServiceNum = CHR(m.AsciiValue)+PADL(m.NewSeqNumber,3,"0")

				DO WHILE SEEK(m.NextServiceNum)
					IF m.NewSeqNumber > 999	&& check for Max number per alpha letter
						IF m.AsciiValue == 90 && Z letter
							m.AsciiValue = 65 && go back to A
							m.NewSeqNumber = 1
						ELSE
* other letters
							m.AsciiValue = m.AsciiValue+1
							m.NewSeqNumber = 1
						ENDIF
					ELSE
* increment number
						m.NewSeqNumber = m.NewSeqNumber + 1
					ENDIF
					m.NextServiceNum = CHR(m.AsciiValue)+PADL(m.NewSeqNumber,3,"0")
				ENDDO

				SET DECIMALS TO (m.CurrDecimal)

				m_proffee = VAL(SUBSTR(fee_import_cursor.DATA,54,11))/10000
				IF m_proffee <= 0 THEN               &&  if it's blank use the last fee for profes fee
					m.Proffe2 = VAL(SUBSTR(fee_import_cursor.DATA,65,11))/10000
				ELSE
					m.Proffe2 = m_proffee
				ENDIF

				m.Effective2 = fixfeedate(SUBSTR(fee_import_cursor->DATA,7,6))
				m.termination2 = fixfeedate(SUBSTR(fee_import_cursor->DATA,15,6))
				m.gpFeerate2 = VAL(SUBSTR(fee_import_cursor->DATA,21,11))/10000
				m.TechFee2 = VAL(SUBSTR(fee_import_cursor->DATA,32,11))/10000
				m.SpFeeRate2 = VAL(SUBSTR(fee_import_cursor->DATA,43,11))/10000

** start transaction here

** Update fees table with new service code
				INSERT INTO fees (service,effective,termination,gpfeerate,;
					techfee,spfeerate,proffee);
					VALUES(m.NextServiceNum,m.Effective2,;
					m.termination2,m.gpFeerate2,m.TechFee2,m.SpFeeRate2,m.Proffe2)


				SELECT SUBMITED
				SET ORDER TO 4   && STR(ID,6)+STR(ACCOUNTING,8)+SERVICE
				m.strtoStore = " Service changed from "+m.CurrentService+" To "+m.NextServiceNum
				LOCAL lnSubmittedScanned, lnSubmittedTotal
				lnSubmittedScanned = 0
				lnSubmittedTotal = RECCOUNT("SUBMITED")
				SCAN
					lnSubmittedScanned = lnSubmittedScanned + 1
					IF MOD(lnSubmittedScanned,500)=0
						WAIT WINDOW "Moving third-party code " + m.CurrentService + ;
							" in submitted claims: " + TRANSFORM(lnSubmittedScanned) + ;
							" of " + TRANSFORM(lnSubmittedTotal) NOWAIT
						DOEVENTS
					ENDIF
					IF LEFT(SUBMITED.service,4) == m.CurrentService
						m.StoreLastServAlpha = RIGHT(SUBMITED.service,1)
						REPLACE SUBMITED.comments WITH SUBMITED.comments+m.strtoStore
						REPLACE SUBMITED.service WITH m.NextServiceNum+m.StoreLastServAlpha
					ENDIF
				ENDSCAN
				SELECT CLAIMS
				SET ORDER TO 3   && DTOC(SERV_DATE)+SERVICE
				LOCAL lnClaimsScanned, lnClaimsTotal
				lnClaimsScanned = 0
				lnClaimsTotal = RECCOUNT("CLAIMS")
				SCAN
					lnClaimsScanned = lnClaimsScanned + 1
					IF MOD(lnClaimsScanned,500)=0
						WAIT WINDOW "Moving third-party code " + m.CurrentService + ;
							" in current claims: " + TRANSFORM(lnClaimsScanned) + ;
							" of " + TRANSFORM(lnClaimsTotal) NOWAIT
						DOEVENTS
					ENDIF
					IF LEFT(CLAIMS.service,4) == m.CurrentService
						m.StoreLastServAlpha = RIGHT(CLAIMS.service,1)
						REPLACE CLAIMS.service WITH m.NextServiceNum+m.StoreLastServAlpha
					ENDIF
				ENDSCAN

*** to do: Write to temp table for report notification
				INSERT INTO tempfee (OldServ,NewServ) VALUES;
					(m.CurrentService,m.NextServiceNum)


* end transaction here
			ELSE && answer NO



				REPLACE fees->service WITH SUBSTR(fee_import_cursor->DATA,1,4)
				REPLACE fees->effective WITH fixfeedate(SUBSTR(fee_import_cursor->DATA,7,6))  &&NB if dates are invalid eg 999999 then returns null date
				REPLACE fees->termination WITH fixfeedate(SUBSTR(fee_import_cursor->DATA,15,6))
				REPLACE fees->gpfeerate WITH VAL(SUBSTR(fee_import_cursor->DATA,21,11))/10000
				REPLACE fees->techfee WITH VAL(SUBSTR(fee_import_cursor->DATA,32,11))/10000
				REPLACE fees->spfeerate WITH VAL(SUBSTR(fee_import_cursor->DATA,43,11))/10000
				m_proffee = VAL(SUBSTR(fee_import_cursor->DATA,54,11))/10000
				IF m_proffee <= 0 THEN               &&  if it's blank use the last fee for profes fee
					REPLACE fees->proffee WITH VAL(SUBSTR(fee_import_cursor->DATA,65,11))/10000
				ELSE
					REPLACE fees->proffee WITH m_proffee
				ENDIF
			ENDIF
		ELSE
			REPLACE fees->service WITH SUBSTR(fee_import_cursor->DATA,1,4)
			REPLACE fees->effective WITH fixfeedate(SUBSTR(fee_import_cursor->DATA,7,6))  &&NB if dates are invalid eg 999999 then returns null date
			REPLACE fees->termination WITH fixfeedate(SUBSTR(fee_import_cursor->DATA,15,6))
			REPLACE fees->gpfeerate WITH VAL(SUBSTR(fee_import_cursor->DATA,21,11))/10000
			REPLACE fees->techfee WITH VAL(SUBSTR(fee_import_cursor->DATA,32,11))/10000
			REPLACE fees->spfeerate WITH VAL(SUBSTR(fee_import_cursor->DATA,43,11))/10000
			m_proffee = VAL(SUBSTR(fee_import_cursor->DATA,54,11))/10000
			IF m_proffee <= 0 THEN               &&  if it's blank use the last fee for profes fee
				REPLACE fees->proffee WITH VAL(SUBSTR(fee_import_cursor->DATA,65,11))/10000
			ELSE
				REPLACE fees->proffee WITH m_proffee
			ENDIF
		ENDIF
	ELSE
		IF m_append_new  && if append new codes is desired
			* V16.2: append silently; the main loop reports progress periodically.
			APPEND BLANK
			REPLACE fees->service WITH servicecode
			REPLACE fees->effective WITH fixfeedate(SUBSTR(fee_import_cursor->DATA,7,6))  &&NB if dates are invalid eg 999999 then returns null date
			REPLACE fees->termination WITH fixfeedate(SUBSTR(fee_import_cursor->DATA,15,6))
			REPLACE fees->gpfeerate WITH VAL(SUBSTR(fee_import_cursor->DATA,21,11))/10000
			REPLACE fees->techfee WITH VAL(SUBSTR(fee_import_cursor->DATA,32,11))/10000
			REPLACE fees->spfeerate WITH VAL(SUBSTR(fee_import_cursor->DATA,43,11))/10000
			m_proffee = VAL(SUBSTR(fee_import_cursor->DATA,54,11))/10000
			IF m_proffee <= 0 THEN               &&  if it's blank use the last fee for profes fee
				REPLACE fees->proffee WITH VAL(SUBSTR(fee_import_cursor->DATA,65,11))/10000
			ELSE
				REPLACE fees->proffee WITH m_proffee
			ENDIF
**  NB we don't know the values for refphyreq or hospreq etc. from the OHIP disk therefore
** leave to individuals to set
		ENDIF && append new fee codes
	ENDIF
	* V16: every record in the Ministry master is an OHIP code.
	SELECT fees
	IF SEEK(servicecode)
		REPLACE fees.ohip WITH .T.
	ENDIF
	SKIP IN fee_import_cursor
ENDDO

* V16.10: final authoritative reconciliation with the Ministry master.
SELECT fee_import_cursor
INDEX ON LEFT(DATA,4) TAG fee_service
LOCAL lnFeesReconciled, lnFeesScanned, lnFeesTableTotal, lcReconService, lnReconProfFee
lnFeesReconciled = 0
lnFeesScanned = 0
SELECT fees
lnFeesTableTotal = RECCOUNT("fees")
SCAN
    lnFeesScanned = lnFeesScanned + 1
    IF MOD(lnFeesScanned,500)=0
        WAIT WINDOW "Verifying server fee table: " + TRANSFORM(lnFeesScanned) + ;
            " of " + TRANSFORM(lnFeesTableTotal) NOWAIT
        DOEVENTS
    ENDIF
    lcReconService = LEFT(ALLTRIM(fees.service),4)
    IF SEEK(lcReconService, "fee_import_cursor", "fee_service")
        REPLACE fees.effective WITH fixfeedate(SUBSTR(fee_import_cursor.DATA,7,6)), ;
            fees.termination WITH fixfeedate(SUBSTR(fee_import_cursor.DATA,15,6)), ;
            fees.gpfeerate WITH VAL(SUBSTR(fee_import_cursor.DATA,21,11))/10000, ;
            fees.techfee WITH VAL(SUBSTR(fee_import_cursor.DATA,32,11))/10000, ;
            fees.spfeerate WITH VAL(SUBSTR(fee_import_cursor.DATA,43,11))/10000, ;
            fees.ohip WITH .T. IN fees
        lnReconProfFee = VAL(SUBSTR(fee_import_cursor.DATA,54,11))/10000
        IF lnReconProfFee <= 0
            lnReconProfFee = VAL(SUBSTR(fee_import_cursor.DATA,65,11))/10000
        ENDIF
        REPLACE fees.proffee WITH lnReconProfFee IN fees
        lnFeesReconciled = lnFeesReconciled + 1
    ENDIF
ENDSCAN

SELECT fees
lnFeeCountAfter = RECCOUNT("fees")
FLUSH
CLOSE TABLES ALL

today=ALLT(DTOS(DATE())+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2))

* Keep the downloaded source and archive a dated copy under the configured MOSt folder.
LOCAL lcBackupFolder, lcBackupFile
lcBackupFolder = ADDBS(gc_datadrive) + "backup\"
IF !DIRECTORY(lcBackupFolder)
    MD (lcBackupFolder)
ENDIF
lcBackupFile = lcBackupFolder + FORCEEXT(JUSTFNAME(lcSourceFile), "") + today + "." + JUSTEXT(lcSourceFile)
COPY FILE (lcSourceFile) TO (lcBackupFile)



*** CHECK TEMP FILE TO PRINT RECORDS
USE (m.MOStTempFolder+"tempfee.dbf") ALIAS tempfee
IF RECCOUNT() > 0
** show report
	REPORT FORM LOADFEES PREVIEW
ENDIF
USE

** Delete temp file
DELETE FILE m.MOStTempFolder+"tempfee.dbf"


* Erick - New code to update unit number for Tech/Assistant and Anaesthetist
DO fees_calc_units

WAIT CLEA
MESSAGEBOX("Fee codes updating completed." + CHR(13)+CHR(13) + ;
    "Ministry records processed: " + TRANSFORM(lnFeeTotal) + CHR(13) + ;
    "New fee codes added: " + TRANSFORM(lnFeeCountAfter-lnFeeCountBefore) + CHR(13) + ;
    "Existing fee rows synchronized: " + TRANSFORM(lnFeesReconciled) + CHR(13) + ;
    "Database: " + path_to_data,64,"MOSt")

RETURN

*** programme to fix stupid OHIP dates like 999999 and 990401
FUNCTION fixfeedate
LPARAMETER ohipdate

IF ohipdate=='999999'
	RETURN CTOD('9999-09-09')
ENDIF

nyr=SUBSTR(ohipdate,1,2)
IF VAL(nyr) >=80 THEN
	nyr='19'+nyr
ELSE
	nyr='20' + nyr
ENDIF

nmonth=SUBSTR(ohipdate,3,2)
IF !BETWEEN(VAL(nmonth),1,12) THEN
	nmonth='01'
ENDIF
nday= SUBSTR(ohipdate,5,2)
IF !BETWEEN(VAL(nday),1,28)  && really not perfect since some months only have 31 or 30 days but unlikely to be selected for start dates
	nday='01'
ENDIF
RETURN CTOD(nyr+'-'+nmonth+'-'+nday)
