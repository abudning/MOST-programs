&& automated version to create multiple disks for all md's
&& program to create ohipsubmission disk data
*/*  code checked by E.T.  991005,1999.11.29 - file backups,sortsub,findbad disabled
PARAMETER pEDT, bEDTON && if !empty(pEDT) then EDT, else creates floppies.

* 2003.05.27
* Erick - bEDTON  = parameter added to identify automated EDT is ON

LOCAL m_recordno, m_accounting, m_facility, m_add_title
m_recordno=0
m_accounting=0
m_facility=0

*** Erick 2003.06.19 CREATE TEMP FILE for labels
oldSetSafety = SET("Safety")
SET SAFETY OFF
LOCAL strTempMostFolder, strTempLocal
strTempLocal = ADDBS(SYS(2023))
strTempMostFolder = ADDBS(SYS(2023)) + "tmplabels.dbf"
CREATE TABLE (strTempMostFolder) FREE ;
	(DistName c(40),;
	fname c(40),;
	lname c(40),;
	cprovid c(40),;
	pwork c(40),;
	claimr c(40),;
	cdate c(40))

DELETE FILE (strTempLocal)+"e409recs2.dbf" 

SET SAFETY &oldSetSafety
****************************************************

CLOSE TABLES ALL

SET TALK OFF
SET DATE ANSI
SET CENTURY ON
SET CLOCK OFF    && clock sometimes crashes programme if time altered while running

today=ALLT(DTOS(DATE())+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2))
USE (ADDBS(gc_localapp) + "databases\parameter2")
GO TOP  && unnecesary since only 1 record
IF EMPTY(pEDT) && no EDT
	IF ALLTRIM(parameter2.floppy_drv)==''
		WAIT "No floppy drive has been installed... Program Aborting!!!" WINDOW TIMEOUT 5
		CLOSE TABLES ALL
		RETURN
	ENDIF
	floppy_drive= parameter2.floppy_drv + ":\"
	back_file=ADDBS(gc_datadrive)+'backup\claims.'+today && use only "backup" folder from the server 2001.06.04
ELSE
	back_file=ADDBS(gc_datadrive)+'backup\EDT\claims.'+today
ENDIF
label_printer=parameter2.label_printer
CLOSE TABLES ALL


*!* Erick	2003.05.30 - set exclusive on to activate lock
SET EXCLUSIVE ON
**********************************

USE patients IN 1 EXCL
USE claims IN 2 EXCL
USE MD IN 3 EXCL
USE PARAMETER IN 4 EXCL
USE diagnosis IN 5 EXCL
USE temp IN 6 EXCL
USE submited IN 8 EXCL
USE submis IN 10 EXCL
USE district IN 40 EXCL

SELE claims
USE
SET SAFETY OFF
COPY FILE claims.DBF TO "&back_file"
SET SAFETY ON

IF !bEDTON
	* not automatic EDT
	CLEAR
ENDIF

WAIT "Cleaning claims.dbf ...." WINDOW NOWAIT
SELECT 2
USE claims ORDER TAG ID EXCLUSIVE
DELETE FOR ID=0 .OR. ''==TRIM(service) .OR. ''==TRIM(billing_md)
PACK
REPLACE FOR !(STATUS=='RESUB') STATUS WITH ''

&& print billing totals
&&?"Calculating billing totals...."
WAIT "Calculating billing totals...." WINDOW NOWAIT

****   set accounting numbers
SELECT PARAMETER
GOTO 2  && get next accounting number  (must be at least 1  and must be next free number
IF RLOCK()
	next_accnt_num = PARAMETER.DATA
	*!*	  next_accnt_num = 1
	SELECT claims
	SET FILTER TO !(billing_md=='**') && added 2001.04.12 GEORGE

**Erick**		next_accnt_num = assign_accnts(next_accnt_num) && 2001.06.04 GEORGE. This statement replaces
	** new code to address E409 and E410 premium codes.
** ET 2005.06.16	next_accnt_num = assign_accnts2(next_accnt_num) 
next_accnt_num = assign_accnts(next_accnt_num)


&& the following 5 statements. This program
&& assigns non-unique accounting numbers

	*scan all
	*	replace accounting with next_accnt_num, claims.bill_date with date() for ''==trim(status) next 1
	*    && give an accounting number if status flag clear and add submission date
	*     next_accnt_num = next_accnt_num + 1
	*endscan
	SELECT PARAMETER
	REPLACE PARAMETER.DATA WITH  next_accnt_num   && update accounting number
	UNLOCK RECORD 2 IN PARAMETER   && now release the record
ELSE
	MESSAGEBOX("Parameter file in use. Push OK to retry.",16, "ERROR Condition")
&&  @ 23,0 say "Parameter file in use please wait..."  && change this to ??? allow escape  but really shouldn't happen
	RETRY												  && only one person should be running this at a time
ENDIF
****

*!*	set printer to default
WAIT "Printing Claims report ...." WINDOW NOWAIT
*!*	set print on
*set console off
*!*	?" OHIP DISKETTE: CREATION REPORT FOR OMS @ " + ttoc(datetime())
*!*	?"   "
*!*	?"   "
*!*	? " TOTALS ON FILE  PRIOR TO GENERATING OHIP DISK"
*!*	?
** do billings
SELECT claims
SET ORDER TO TAG ID
SET FILTER TO 
m_add_title = "Before generating OHIP submission"

* Erick - Check if there is any records first
IF RECCOUNT() > 0

	cCtable = SELECT()

	*!* Erick	    SELECT BILLING_MD, SUM(Fee_submited) as SUMT, ;
	*!* Erick		count(type), type ;
	*!* Erick		FROM claims INTO CURSOR tmpclaims GROUP BY billing_md,type

	SELECT claims.BILLING_MD, SUM(claims.Fee_submited) AS SUMT, ;
		COUNT(claims.TYPE), claims.TYPE, MD.firstname,MD.surname,MD.ohipnumber,MD.phone_work, ;
		MD.phone_home,MD.group_num ;
		FROM claims, oms!MD INTO CURSOR tmpclaims ;
		WHERE claims.ID # 0 AND claims.billing_MD = MD.mnemonic ;
		GROUP BY billing_md,TYPE,firstname,surname,ohipnumber,phone_work, ;
		phone_home,group_num

	SELECT tmpclaims
	REPORT FORM mdclaims2 TO PRINTER NOCONSOLE
	SELECT (cCtable)
ENDIF
*!*	set print off
*!*	set printer to
*!* Erick	SET CONSOLE ON

SET CONSOLE OFF

SELECT 1
USE patients ORDER TAG ID EXCLUSIVE
SELECT 2   && must reopen this file because billings.prg  closes it  NB not in updated version
&&USE claims ORDER TAG ID EXCLUSIVE
USE claims EXCLUSIVE

&& Erick - 2006.08.05 - Merge E409's and E410's into one service for the same patient, Service date and MD
LOCAL bIs4094010 as Boolean 
** keep original records
SELECT billing_md, claims.ID, serv_date , service, fee_submited, prem_link ;
from claims ;
join md on mnemonic = billing_md ;
join patients on patients.id = claims.id ;
INTO CURSOR e409recs  ;
where (service = 'E409A' OR service = 'E410A') AND !(billing_md=='**');
	AND ((mod10(patients.healthnum)) .AND. (patients.healthnum <> '0000000000') .AND. claims.TYPE $'WO') ;
						.OR. (claims.TYPE=="R" .AND. VAL(patients.healthnum + patients.VERSION) <> 0 ) 
&&order BY 1,2,3 

&& store in permanent table for later use
SELECT * from e409recs  INTO TABLE (strTempLocal)+"e409recs2" 
SELECT e409recs2
USE
SELECT e409recs
IF RECCOUNT('e409recs') > 0
	bIs4094010  = .T.
	** group all e409's and E410's by billing MD, patient, and service date 
	SELECT c.ID , MIN(c.ACCOUNTING) as ACCOUNTING, MIN(c.TYPE) as TYPE, c.SERV_DATE, MIN(c.NUM_SERV) as NUM_SERV,;
	c.SERVICE, MIN(c.DIAGNOSIS) as DIAGNOSIS, c.BILLING_MD, MIN(c.REFERR_MD) as REFERR_MD,MIN(c.FACILITY) as FACILITY,;
	MIN(c.ADMIT_DATE) as ADMIT_DATE, sum(c.FEE_SUBMITED) as FEE_SUBMITED, MIN(c.FEE_PAID) as FEE_PAID, ;
	MIN(c.ERROR_CODE) ERROR_CODE, MIN(c.CLAIM_NUM) as CLAIM_NUM, MIN(c.STATUS) as status, MIN(c.MANREVIEW) as MANREVIEW, ;
	min(c.ENTRY_DATE) as ENTRY_DATE, MIN(c.BILL_DATE) as BILL_DATE, MIN(c.REC_DATE) as REC_DATE, ;
	MIN(c.REC_SERVICE) as REC_SERVICE, MIN(c.RESUB_ACCOUNTING) as RESUB_ACCOUNTING, MIN(c.LEFTRIGHT) as LEFTRIGHT,;
	MIN(c.GUARANTOR) as GUARANTOR, MIN(c.PREM_LINK) as PREM_LINK;
	from  claims as c ;
	join md on mnemonic = billing_md ;
	join patients on patients.id = c.id ;
	INTO CURSOR e409e410_group  ;
	where (service = 'E409A' OR service = 'E410A') AND !(billing_md=='**') ;
		  AND ((mod10(patients.healthnum)) .AND. (patients.healthnum <> '0000000000') .AND. c.TYPE $'WO') ;
						.OR. (c.TYPE=="R" .AND. VAL(patients.healthnum + patients.VERSION) <> 0 ) ;
	GROUP BY billing_md, c.ID, serv_date , service
	
	&& delete e409's and e410's from claims file
	SELECT e409e410_group  
	GO TOP
	DO WHILE !EOF()
		m.billing_md = ALLTRIM(e409e410_group.billing_md)
		m.ID =  e409e410_group.ID
		m.Service = ALLTRIM(e409e410_group.service)
		m.Serv_date = e409e410_group.serv_date 
		m.Sum_fee_submited = e409e410_group.fee_submited 
		
		SELECT 2 && claims file..look for first e409/e410
		GO TOP
		LOCATE FOR ALLTRIM(billing_md )==m.billing_md AND ID == e409e410_group.ID ;
					AND  ALLTRIM(Service) == m.Service AND Serv_date == m.Serv_date
		IF FOUND()
			&& override fee_submitted with SUM value 
			REPLACE claims.FEE_SUBMITED WITH m.Sum_fee_submited 
			&& look for the rest e409/e410's and delete
			CONTINUE
			DO WHILE FOUND()
				DELETE  && delete next e409's/e410's for that group
				CONTINUE
			ENDDO
		ENDIF 
		SELECT e409e410_group  
		SKIP
	EnDDO
ENDIF

SELECT 2
SET FILTER TO !(billing_md=='**') && added 2001.04.12
SET ORDER TO 0
SELECT 5         && ?not used???? anymore
USE diagnosis EXCL
SELECT 6 && temp file (to hold output from claims)
USE temp EXCLUSIVE
SELECT 8
USE submited EXCL
SELECT 9   && duplicate of submis file to add sequence #
file_nm=  uniqfile() && get  unique alias
temp_dir=SYS(2023)   && temporary directory (independant of OS ie c:\temp for NT, c:\windows\temp for 95/98)
file_name= temp_dir + "\"+ file_nm && temp file name to hold data from &dummy

SELE submis
USE
COPY FILE submis.DBF TO &file_name..DBF
USE &file_name ALIAS tempfyl EXCLUSIVE IN 9

SELECT 10   && file that contains names of files to be submited this cycle
USE submis EXCLUSIVE   && ****NB this section needs to be reworked if maintain previous submission data***
DELETE ALL   && same as zap but works 			 can also do with zap and set safety off
PACK

* Erick open TMPLABEL
USE (strTempMostFolder) IN 0

SELECT 3
USE MD EXCL
GO TOP
WAIT "Starting ohip disk creation...." WINDOW NOWAIT
&& START LOOP HERE
DO WHILE .NOT. EOF(3)

	IF !bEDTON
		* not automatic EDT
		CLEAR
	ENDIF

&&   @ 2,5 say 'Provider: ' + md->surname + '  ' + md->ohipnumber+ '   '+ md->group_num
	WAIT 'Processing Provider: ' + MD->surname + '  ' + MD->ohipnumber+ '   '+ MD->group_num WINDOW NOWAIT

	provider=MD->ohipnumber
	specialty=MD.specialty
	group_num=MD.group_num        && also called IHFN  (independent health facility number)
	IF TRIM(group_num)=="" THEN
		group_num="0000"           && if blank then make sure it's 4 zeros
	ENDIF

	MD=MD->mnemonic
	district=MD.district
	phone_work=MD.phone_work
	location=MD.locatn_cod            && for newer doctors must have a location code
	IF TRIM(location)=='' THEN
		location= SPACE(4)
	ENDIF

	SELECT 40                               && get district name for label
	USE district EXCL
	SCAN WHILE district.CODE <> district
	ENDSCAN
	district_name=district.cname
	USE

	SELECT 6 && temp file (to hold output from claims)
	DELETE ALL
	PACK

	claim1cnt=0
	claim2cnt=0
	itemcnt=0
	batchcnt=0
	last_accounting=0

	** create batch header
	APPEND BLANK

	REPLACE DATA WITH 'HEBV03' +district+ ohipdate(DATE()) + '0001'+ ;
		SPACE(6) + group_num + provider + specialty + SPACE(42)

	batchcnt=batchcnt + 1

	SELECT 2   && claims
	GO TOP
	DO WHILE .NOT. EOF(2)
		WAIT "Processing ...." WINDOW NOWAIT NOCLEAR

		IF claims->billing_md == MD   && md mnemonic
			SELECT 1  && patient file
			SEEK claims->ID
			IF FOUND (1) 	&&  Third party will be automatically excluded ** will be marked 'I'
				IF ((mod10(healthnum)) .AND. (healthnum <> '0000000000') .AND. claims.TYPE $'WO') ;
						.OR. (claims.TYPE=="R" .AND. VAL(healthnum + VERSION) <> 0 )
&& exclude invalid or blank healthnum for WCB or HCP(ohip) and blank for RMB
&& should check for missing dob  hosp# admission dates etc
					IF claims.STATUS=="RESUB" AND VAL(SUBSTR(claims.resub_accounting,1,8)) > 0
&& if is a resubmission, link accounting number back to source
&& of resubmission
						SELE submited
						SET ORDER TO TAG accounting
						SEEK VAL(SUBSTR(claims.resub_accounting,1,8))
						IF FOUND()
							DO WHILE submited.accounting=VAL(SUBSTR(claims.resub_accounting,1,8))
								IF submited.service==SUBSTR(claims.resub_accounting,9,5)
									REPL submited.resub_accounting WITH PADL(ALLT(STR(claims.accounting)),8,'0')+;
										claims.service
									EXIT
								ENDIF
								SKIP 1
								IF EOF()
									EXIT
								ENDIF
							ENDDO
						ENDIF
					ENDIF

					DO CASE
						CASE claims.TYPE=='O'
							m_hc_ver= patients.healthnum+patients.VERSION
							m_claim_type='HCP'
						CASE claims.TYPE=='W'
							m_hc_ver= patients.healthnum+patients.VERSION
							m_claim_type='WCB'
						CASE claims.TYPE=='R'
							m_hc_ver=SPACE(12)  && not used for RMB
							m_claim_type='RMB'
					ENDCASE

					birthday=DTOS(patients->dob)
					accountg=STR(claims.accounting,8)
					IF claims->facility =0
						fcltynum = SPACE(4)
						admitdat= SPACE(8)
					ELSE
						fcltynum = STR(claims->facility,4)
						admitdat=ohipdate(claims->admit_date)
					ENDIF && claims
					IF UPPER(claims->manreview) <> 'Y' && manual review indicator make sure is at least a space
						REPLACE claims->manreview WITH SPACE(1)
					ENDIF

					SELECT 6 && temp
					IF claims.accounting<>last_accounting
						*** START sequence of code added on 2001.08.13 to correctly deal with the facility for a batch of claims. GEORGE
						SELECT 2	&& claims
						m_recordno=RECNO()
						m_accounting=claims.accounting
						m_facility=0
						m_referring=SPACE(6)
						SCAN FOR claims.accounting == m_accounting
							IF claims.facility>0
								fcltynum = STR(claims->facility,4)
								admitdat=ohipdate(claims->admit_date)
								*exit
							ENDIF
							IF VAL(claims.referr_md)>0
								m_referring = PADL(ALLT(claims.referr_md),6,"0")
							ENDIF
						ENDSCAN
						GOTO m_recordno
						SELECT 6
						*** END sequence of code added on 2001.08.13 to correctly deal with the facility for a batch of claims. GEORGE
						APPE BLANK
						REPLACE DATA WITH 'HEH'+m_hc_ver+birthday+ accountg + m_claim_type + 'P' ;
							+ m_referring + fcltynum + admitdat + SPACE(4) ;
							+ claims->manreview + location + SPACE(17)
						claim1cnt = claim1cnt + 1  && Header count
						IF m_claim_type=='RMB'   &&then need a claim header 2
							APPEND BLANK
							*** NB  surname and firstname for RMB claim2 must not contain special char
							*** or embedded blanks I don't test for this ****
							REPLACE DATA WITH 'HER'+ PADR(ALLTRIM(patients.healthnum)+ALLTRIM(patients.VERSION),12,' ') + ;
								SUBSTR(LTRIM(patients.surname),1,9) + SUBSTR(LTRIM(patients.firstname),1,5) + ;
								IIF(patients.sex=='M','1','2') + patients.province + SPACE(47)
							claim2cnt = claim2cnt + 1  && R count
						ENDIF
					ENDIF

					APPE BLANK
					**  item record
					REPLACE DATA WITH 'HET'+ claims->service + SPACE(2) + ;
						leading0(STR(claims->fee_submited*100,6)) + leading0(STR(claims->num_serv,2)) + ;
						DTOS(claims->serv_date) + PADR(ALLT(claims->diagnosis),3,SPACE(1)) + SPACE(13) + ;
						SPACE(5+2+6+6+4+13)
					itemcnt=itemcnt+1
					last_accounting=claims.accounting
				ELSE
					REPLACE claims.STATUS WITH 'I'  && indicates incomplete status can't bill
&& will include third party
				ENDIF && ((mod10(
			ELSE  && couldn't locate this id # in the patient file
				REPLACE claims.STATUS WITH 'U' && unfound id #
			ENDIF && found(1)
			SELECT claims
		ENDIF &&claims->billing
		SKIP
	ENDDO

	** batch trailer record
	SELECT 6
	APPEND BLANK
	REPLACE DATA WITH 'HEE'+ leading0(STR(claim1cnt,4)) + ;
		leading0(STR(claim2cnt,4)) + leading0(STR(itemcnt,5)) + SPACE(63)

	****** print label here
&&   @5,5 say 'claim cnt: ' + str(claim1cnt,4) + '  number of records: ;
'+ str(recno(6))


	*****  eliminate anyone without claims here
	IF claim1cnt > 0 && only do if claims generated
		monthlet= CHR(MONTH(DATE()) + 96)  && convert month to letter

&& check sequence number of filename
		SELECT 9 && tempfyl. Containes a duplicate of the initial "submis.dbf"
		IF group_num == '0000'
			prov_id="h" + monthlet + MD->ohipnumber
		ELSE
			prov_id="h" + monthlet + MD->group_num    && if has a group number of IHFN then use in
&& file name
		ENDIF
&& ?prov_id
&& check to see if this filenm was previously submitted
		IF RECCOUNT() > 0  && prevents string error with locate if file empty
			GO TOP
			LOCATE FOR SUBSTR(ALLT(tempfyl->filename),1,AT('.',ALLT(tempfyl->filename))-1)==prov_id && handles IHFN
			IF FOUND()  && then add 1 to max sequence#
				CALC MAX(VAL(SUBSTR(ALLT(tempfyl.filename),AT('.',ALLT(tempfyl.filename))+1,3))) ;
					FOR SUBSTR(ALLT(tempfyl.filename),1,AT('.',ALLT(tempfyl.filename))-1)==;
					prov_id TO sequence
				sequence=sequence+1
				sequence=PADL(ALLT(STR(sequence)),3,'0')
				prov_id=  prov_id + '.' + sequence
			ELSE
				prov_id= prov_id + '.001'
				sequence='001'
			ENDIF && found
		ELSE && reccount
			prov_id= prov_id + '.001'
			sequence='001'
		ENDIF && reccount
		filenm= ADDBS(gc_datadrive)+'data\'+prov_id
&& copy temp.dbf to file with proper name for submission
		SELECT 6
		GO TOP
		REPLACE DATA WITH STUFF(DATA,17,3,sequence)  && fix sequence number in data
		COPY TO "&filenm" TYPE SDF

		** NB - Need to get rid of this and put in a proper report ??  Although this way can use as a label for the diskette?? 2002-07-17
&& This paragraph of stupid "set" code below is to try and  trap  the occaisional printer not ready error
&& that occurs in the next block -  the latter results in an unprinted label!!  So far only seen on a
&& networked  HP  laserjet 4   (delaying the printer transmission time  didn't seem to help)
&&  This way if an error occurs it wakes the printe up  and it works the next (when it's really needed)
&&  I hope  ET 2002-10-16
		*!* Erick			SET PRINTER TO DEFAULT
		*!* Erick			SET CONSOLE OFF   &&  block display to console
		*!* Erick			SET PRINTER ON
		*!* Erick			SET CONSOLE ON
		*!* Erick			SET PRINTER OFF
		*!* Erick			SET PRINTER TO  && starts the printing

		*!* Erick			SET PRINTER TO DEFAULT
		*!* Erick			SET CONSOLE OFF   &&  block display to console
		*!* Erick			SET PRINTER ON    &&&  got  an error  printer not ready   here and then failed to print a label


		*!* Erick			?'  M.O.H. '  + district_name
		*!* Erick			?'   '
		*!* Erick			?'Name: Dr ' + SUBSTR(MD->firstname,1,1) + ' '+ MD->surname
		*!* Erick			?'Prov/Grp.Id: ' + TRANSFORM(prov_id,'!!XXXXXXXXXX') && change to uppercase
		*!* Erick			?'Ph.#: '+ phone_work
		*!* Erick			?'Claim/Rec: ' + STR(claim1cnt,5) + '/' + STR(RECCOUNT(6),6)
		*!* Erick			?'Date: ' + DTOC(DATE()) + ' Seq:1 of 1'

		INSERT INTO tmplabels (DistName,fname,lname,cprovid,pwork,claimr,cdate);
			VALUES(ALLTRIM(district_name),SUBSTR(MD->firstname,1,1),;
			MD->surname,UPPER(prov_id),ALLTRIM(phone_work),;
			STR(claim1cnt,5) + '/' + STR(RECCOUNT(6),6),DTOC(DATE()) + ' Seq:1 of 1')

		*!* Erick			SET CONSOLE ON
		*!* Erick			SET PRINTER OFF
		*!* Erick			SET PRINTER TO  && starts the printing

&& end of label data to main printer

		SELECT submis  && add name of file for later copying
		APPEND BLANK
		REPLACE submis->filename WITH prov_id

		SELECT tempfyl
		APPEND BLANK
		REPLACE tempfyl->filename WITH prov_id
	ENDIF  && if claim1cnt > 0
	SELECT MD
	SKIP
ENDDO      && loop for next md

SELECT tmplabels
IF RECCOUNT() > 0
	** we have labels to printout
	REPORT FORM ohiplabels TO PRINTER
ENDIF
** delete temp file
USE
DELETE FILE (strTempMostFolder)


IF !bEDTON
	* not automatic EDT
	CLEAR
ENDIF

&& backup data that is being submited
WAIT "Backing up sub file..." WINDOW NOWAIT
SELECT claims
IF EMPTY(pEDT)
	back_file=ADDBS(gc_datadrive)+'backup\sub.' + today
ELSE
	back_file=ADDBS(gc_datadrive)+'backup\EDT\sub.' + today
ENDIF

&&set talk on
SET TALK OFF
COPY TO "&back_file" FOR (LEN(ALLT(STATUS))=0) .OR. (ALLT(STATUS)=='RESUB')

&& backuping up resub file
&&?"Backing up resub file...."
WAIT "Backing up resub file..." WINDOW NOWAIT
IF EMPTY(pEDT)
	back_file=ADDBS(gc_datadrive)+'backup\resub.' + today
ELSE
	back_file=ADDBS(gc_datadrive)+'backup\EDT\resub.' + today
ENDIF

SET FILTER TO
COPY TO "&back_file" FOR (LEN(ALLT(STATUS))>0 AND ALLT(STATUS)<>'RESUB') OR billing_md=='**'
SET TALK OFF


&& copy submission files to diskettes
IF !bEDTON
	* not automatic EDT
	CLEAR
ENDIF

*!*	?"Retrieve labels from label printer" + chr(7)
*!*	wait
*!*	clear
SELECT 10
USE submis EXCL && need to reopen file
IF EMPTY(pEDT)
	MESSAGEBOX("Number of BLANK disks required: " + STR(RECCOUNT(10)),64,"MOSt - Message")
	GO TOP
	DO WHILE .NOT. EOF(10)
		IF !bEDTON
			* not automatic EDT
			CLEAR
		ENDIF

		MESSAGEBOX("Insert BLANK disk in drive "+JUSTDRIVE(floppy_drive),64,'MOSt - Message')
		WAIT "Copying data....." WINDOW NOWAIT
		SELECT 10
		filenm = ADDBS(gc_datadrive)+"data\" + submis->filename
		SET SAFETY OFF
		COPY FILE "&filenm" TO "&floppy_drive"
		SET SAFETY ON
		IF !bEDTON
			* not automatic EDT
			CLEAR
		ENDIF

		MESSAGEBOX("Remove disk and apply label: " + TRANSFORM(submis->filename,'!!XXXXXXXXXX'),64,;
			"MOSt - Message")
		SKIP
	ENDDO
	WAIT "All disks created... " WINDOW NOWAIT
ENDIF

SELECT 9  && get rid of copy of submis file
USE
DELETE FILE &file_name..DBF  && . acts like + here

&& backup ohip files   N.B. directories must already exist !!!
WAIT "Backing up OHIP diskette data...." WINDOW NOWAIT  && no move function exists
SET SAFETY OFF   && will overwrite without warning
nFiles = ADIR(aFiles, ADDBS(gc_datadrive)+"data\*.*")  && Create array
IF nFiles > 0
	FOR i=1 TO nFiles
		IF !("MBT" $ UPPER(aFiles(i,1)))
			IF EMPTY(pEDT)
				COPY FILE ADDBS(gc_datadrive)+"data\"+aFiles(i,1) TO ;
					ADDBS(gc_datadrive)+"backup\"+aFiles(i,1)
			ELSE
				COPY FILE ADDBS(gc_datadrive)+"data\"+aFiles(i,1) TO ;
					ADDBS(gc_datadrive)+"backup\EDT\"+aFiles(i,1)
				COPY FILE ADDBS(gc_datadrive)+"data\"+aFiles(i,1) TO ;
					ADDBS(gc_datadrive)+"EDT\OUT\"+aFiles(i,1)
			ENDIF
			DELETE FILE ADDBS(gc_datadrive)+"data\"+aFiles(i,1)
		ENDIF
	ENDFOR
ENDIF
SET SAFETY ON

&& append data to submited file
IF !bEDTON
	* not automatic EDT
	CLEAR
ENDIF

WAIT "Appending data to submited file...." WINDOW NOWAIT

**Erick**	SELECT claims
**Erick**	USE      && close claims file otherwise append below won't work

SELECT submited
SET ORDER TO

*** Erick 2004.02.10 - copy claims to submitted and premium link to submited.comments 
USE (strTempLocal)+"e409recs2" IN 0 ALIAS e409recs

SELECT CLAIMS
SET FILTER TO (LEN(ALLT(STATUS))=0 OR ALLT(STATUS)=='RESUB') ;
	AND !(billing_md=='**') && copy claims to submited
GO TOP
DO WHILE !EOF()
	SCATTER NAME oClaims
	strPremLink = ''
	IF !EMPTY(claims.prem_link)
		IF claims.service = 'E409A' OR claims.service = 'E410A' && Erick - 2006.08.07
			DIMENSION aTemp[1]
			aTemp[1] = ''
			SELECT prem_link INTO ARRAY aTemp FROM e409recs WHERE e409recs.ID = claims.ID AND e409recs.service = claims.service ;
							AND e409recs.billing_md = claims.billing_md AND e409recs.serv_date = claims.serv_date 
					IF !EMPTY(aTemp[1]) && found merge recs
							FOR n = 1 TO ALEN(aTemp)
								strPremLink = strPremLink  + "*~"+ALLTRIM(aTemp[n])+"~*"
							ENDFOR 
					ELSE
						strPremLink = "*~"+ALLTRIM(claims.prem_link)+"~*"					
					ENDIF
		ENDIF
	ENDIF

	SELECT submited
	APPEND BLANK
	GATHER NAME oClaims
	IF !EMPTY(strPremLink)
		REPLACE COMMENTS WITH strPremLink
	ENDIF
	SELECT claims
	SKIP
ENDDO

SELECT claims
USE
SELECT e409recs 
USE
DELETE FILE (strTempLocal)+"e409recs2.dbf" 
**********************************************************************
**Erick**	APPEND FROM claims.DBF FOR (LEN(ALLT(STATUS))=0 OR ALLT(STATUS)=='RESUB') ;
**Erick**		AND !(billing_md=='**') && copy claims to submited

**do listman && list claims requiring manual review note
SELECT MD
USE
SELECT patients
USE
SET CONSOLE OFF

* Erick - Check if there is any Records to print first
*COUNT TO m.NumOfRec FOR claims.ID > 0 AND "" <> ALLTRIM(claims.manreview) AND mod10(patients.healthnum) AND  (claims.TYPE $ 'OW')
* 2003.06.20 - the Report form 'manualreview' is using the dataenviroment and is sending a
* FOR statement to filter the data. We need to filter the data before to avoid printing
* blank pages if there is no records to print.
SELECT claims.ID,patients.healthnum, claims.TYPE;
	FROM oms!claims,oms!patients INTO CURSOR manualrev;
	WHERE claims.ID = patients.ID AND ;
	claims.ID > 0 AND " " <> ALLTRIM(claims.manreview) ;
	AND mod10(patients.healthnum) AND  (claims.TYPE $ 'OW')

SELECT manualrev
IF RECCOUNT()>0
	IF USED('claims')
		SELECT claims
		USE
	ENDIF
	IF USED('patients')
		SELECT patients
		USE
	ENDIF
	REPORT FORM MANUALREVIEW TO PRINTER FOR claims.ID > 0 AND "" <> ALLTRIM(claims.manreview) AND mod10(patients.healthnum) AND  (claims.TYPE $ 'OW')
ENDIF
SELECT manualrev
USE
******************************************

&& Report of claims requiring manual review note
&& do varmonth && compute variable expenses

&& delete submited data from claims.dbf
WAIT "Deleting submited data from claims file...." WINDOW NOWAIT

IF USED('claims')
	SELECT claims
ELSE
	USE claims
ENDIF

USE claims ORDER TAG ID EXCLUSIVE
SET FILTER TO !(billing_md=='**') && added 2001.04.12
DELETE FOR LEN(ALLT(STATUS))=0 OR ALLT(STATUS)=='RESUB'
SET FILTER TO && added 2001.04.12
DELE FOR ID=0
PACK
REINDEX
REPLACE claims.accounting WITH 0 ALL   && get rid of any left over accounting numbers or HISTORY button won't display properly

&& print billing totals not billed this cycle
*set printer to default_printer
*!*	set printer to default

*!*	** set printer to "lpr -dmain -s "
*!*	set print on
*!*	set console off
*!*	? "TOTALS LEFT ON FILE  AFTER GENERATING OHIP DISK"
*!*	?
*!*	&&do billings
*!*	? time()
m_add_title = "After generating OHIP submission"

* Erick - check for data to print - 2003/05/13
IF RECCOUNT() > 0
	* calculate types to display in report

	cCtable = SELECT()
	*!* Erick		SELECT BILLING_MD, SUM(Fee_submited) as SUMT, ;
	*!* Erick		count(type), type ;
	*!* Erick		FROM claims INTO CURSOR tmpclaims GROUP BY billing_md,type

	SELECT claims.BILLING_MD, SUM(claims.Fee_submited) AS SUMT, ;
		COUNT(claims.TYPE), claims.TYPE, MD.firstname,MD.surname,MD.ohipnumber,MD.phone_work, ;
		MD.phone_home,MD.group_num ;
		FROM claims, oms!MD INTO CURSOR tmpclaims ;
		WHERE claims.ID # 0 AND claims.billing_MD = MD.mnemonic ;
		GROUP BY billing_md,TYPE, firstname,surname,ohipnumber,phone_work, ;
		phone_home,group_num

	SELECT tmpclaims
	REPORT FORM mdclaims2 TO PRINTER NOCONSOLE && for !(billing_md=='**')

	SELECT (cCtable)
ENDIF
&& report form mdclaims preview
*!*	eject
*!*	set print off
*!*	set printer to
*!*	** set printer to "lpr -dmain -s "
*!*	*set printer to default_printer
*!*	set printer to default
*!* set console on

&& do findbad && old way
m_listing_header=" - for Claims without valid HC #"&& report of claims for which invalid HC# and are not Third party or Reciprocal ie. are WSIB or OHIP
&&report form "listing of claims" to printer for !mod10(patients.healthnum) and id > 0 and  !(claims.type $ 'TR')

SELECT claims.ID,patients.healthnum, claims.TYPE;
	FROM oms!claims,oms!patients INTO CURSOR listclaims;
	WHERE claims.ID = patients.ID AND ;
	(!mod10(patients.healthnum) .OR. '0000000000'== patients.healthnum) AND;
	claims.ID > 0 AND  !(claims.TYPE $ 'TR')

SELECT listclaims
IF RECCOUNT() > 0
	IF USED('claims')
		SELECT claims
		USE
	ENDIF
	IF USED('patients')
		SELECT patients
		USE
	ENDIF
	REPORT FORM "listing of claims" TO PRINTER FOR (!mod10(patients.healthnum) .OR. '0000000000'== patients.healthnum) AND ID > 0 AND  !(claims.TYPE $ 'TR')
ENDIF
SELECT listclaims
USE

*!*	set talk on
*!*	? "Sorting and Reindexing Submited file ....."

***************************************  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  RECHECK this part
** do sortsub  && N.B. ** takes a few minutes and needs alot of diskspace
SET TALK OFF
CLOSE TABLES ALL

IF !bEDTON
	* not automatic EDT
	WAIT CLEAR
ENDIF

USE claims
SET FILTER TO
COUN TO m_count FOR billing_md=='**'
IF m_count>0
	MESSAGEBOX(ALLT(STR(m_count))+ ' Claims without any assigned MD (**) have been retained in claim file !',16,'Claims without MD')

ENDIF


IF EMPTY(pEDT)
	MESSAGEBOX("Claims submission completed !",64,"MOSt")
ELSE
	IF bEDTON = .F.
		** Normal submission without automated EDT
		*!*			MESSAGEBOX("You  may now run PROCOMM"+CHR(13)+;
		*!*			"to send your submission.",64,"MOSt")
	ENDIF
ENDIF
CLOSE TABLES ALL

*!* Erick	2003.05.30 - set exclusive on to activate lock
SET EXCLUSIVE OFF
**********************************
