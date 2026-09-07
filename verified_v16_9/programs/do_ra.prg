PARAMETER pEDT && if !empty(pEDT) then EDT i.e. take the "p" file from ".../EDT/IN/", else take it from floppy.
&& If not empty, this parameter contains the name of a "p" file passed by the code executed
&& by selecting "Main_Menu\Billing\EDT" menu item. That piece of code launches "Do_ra.prg" for
&& each file found in ".../EDT/IN/"
** program to read in  md's RA's and analyze earnings for each staff md
LOCAL filetoload, file_nm, file_name, temp_dir, m_variance

LOCAL strTempMemo AS STRING
strTempMemo=""
m_same_idacc = .F. && if and only if the remitted and submitted have the same ID and ACCOUNTING, then this flag is TRUE. the
m_near = .F. && this is a flag used in conjunction to "trueseek".
&& if trueseek .and. m_near then the remitted claim has the service code changed and "NEAR" goes in
&&    submitted.comments field, accompanied by some information regarding the differences between submitted and remitted.
&& if trueseek .and. !m_near then the remitted and submitted are identical.
&& if !trueseek .and. m_same_idacc then "NTFND" goes in submitted.status field, regardless of MULTIOFFICE.
&& if !trueseek .and. !m_same_idacc then "NTFND" goes in submitted.status only for md.multioffice = .f.
m_add_it_to_raerror = .F. && this is a flag which indicates (when it's TRUE) an already reconciled claim. See further explanations in the code.


SET DATE ANSI
SET CENTURY ON
SET CONSOLE OFF
*!*	set printer to "lpr -dmain -s "
SET PRINTER TO DEFAULT
*Set exclusive off
SET TALK OFF
SET ECHO OFF
SET STATUS OFF
SET PRINTER OFF
trueseek=.F.
***  Get the starting accounting number (if they have old data start from this point onwards for reconciliation
CLOSE TABLES ALL

*!* Erick	2003.05.30 - set exclusive on to activate lock
SET EXCLUSIVE ON
**********************************

USE ra_error
file_nm=  uniqfile()
temp_dir=SYS(2023)
** Erick 0 - check if file exist otherwise ignore creation
*file_name= temp_dir + "\"+ file_nm + ".dbf"
file_name= temp_dir + "\reconsil.dbf"
IF !FILE(file_name)
	** create reconsile already file
	COPY STRU TO &file_name
ENDIF

SELE ra_error
USE

USE temp IN 1 EXCL


USE ra_error IN 2 EXCL
USE submited IN 3 EXCL
USE MD IN 4 EXCL
USE adjustments IN 5 EXCL

USE ADDBS(JUSTPATH(oms_local_fullpath))+"options" IN 6 ORDER CODE EXCL
SELE options
SEEK "VARIANCE"
IF !FOUND()
	MESSAGEBOX('Please run UPGRADE first, then try to reconcile any "P" file !',;
		64,"MOSt Warning!")
	CLOSE TABLES ALL
	DELE FILE &file_name..*

	*!* Erick	2003.05.30 - set exclusive off
	SET EXCLUSIVE OFF
	**********************************

	RETURN .F.
ENDIF
m_variance = 0
IF options.valuelog
	m_variance = options.valuenum
ENDIF

USE patients IN 71 EXCL
USE PARAMETER IN 10 EXCL
USE JUSTDRIVE(oms_local_fullpath)+"\program files\most\databases\parameter2" IN 11 EXCL
USE &file_name IN 12 ALIAS reconciled_already EXCL

SELECT PARAMETER
GOTO 3
IF PARAMETER.DATA > 0 THEN
	starting_account_num= PARAMETER.DATA
ELSE
	starting_account_num = 1
ENDIF

SELECT temp
DELETE ALL						&& clear file
PACK

IF EMPTY(pEDT) && no EDT
	backup_dir = ADDBS(gc_datadrive)+"backup\"   && place to put backup. Use only "backup" folder from the server 2002.02.06
	SELE parameter2
	GO TOP  && unnecesary since only 1 record
	IF ALLTRIM(parameter2.floppy_drv)==''
		MESSAGEBOX('No floppy drive has been installed... Program Aborting!!!',16,'MOSt - Warning')
		CLOSE TABLES ALL
		DELE FILE &file_name..*

		*!* Erick	2003.05.30 - set exclusive off
		SET EXCLUSIVE OFF
		**********************************

		RETURN .F.
	ELSE
		floppy_drive= parameter2.floppy_drv + ":"
	ENDIF
	WAIT "Please insert RA disk (yellow label) in drive "+ floppy_drive + "   ... then press any key to continue" ;
		WINDOW AT 10,30
	floppy_drive=floppy_drive + "\"
	WAIT "Reading your disk ... Working...."  WINDOW AT 10,30 NOWAIT
	IF FILE(floppy_drive+'Reconciled_Already.txt')  && Does file exist?
		MESSAGEBOX('This disk has already been reconciled !!  Program Aborting !!',16,'MOSt - Warning')
		CLOSE TABLES ALL
		DELE FILE &file_name..*

		*!* Erick	2003.05.30 - set exclusive off
		SET EXCLUSIVE OFF
		**********************************

		RETURN .F.
	ENDIF
	num_of_files =  ADIR(filelist,floppy_drive+"*")   && the better way to get directory listing
	DO CASE
		CASE num_of_files = 0
			MESSAGEBOX('No files found on disk ... PROGRAM ABORTING !!!',16,'MOSt - Warning')
			CLOSE TABLES ALL
			DELE FILE &file_name..*

			*!* Erick	2003.05.30 - set exclusive off
			SET EXCLUSIVE OFF
			**********************************

			RETURN .F.
		CASE num_of_files > 1
			MESSAGEBOX('Too many files found (disk must have only 1 file)...... PROGRAM ABORTING !!!',16,'MOSt - Error')
			CLOSE TABLES ALL
			DELE FILE &file_name..*

			*!* Erick	2003.05.30 - set exclusive off
			SET EXCLUSIVE OFF
			**********************************

			RETURN .F.
	ENDCASE
	filetype=SUBSTR(filelist(1,1),1,1)   && get file type indicator should be  P
	WAIT "Processing MRO disk ..."  WINDOW AT 10,30 NOWAIT NOCLEAR
	filetoload=floppy_drive+filelist(1,1)          && filename and drive letter
	** verify valid RA file name
	IF .NOT. ( UPPER(SUBSTR(JUSTFNAME(filetoload),1,1)) == 'P' .AND. ;
			UPPER(SUBSTR(JUSTFNAME(filetoload),2,1)) $ 'ABCDEFGHIJKL' )
		*  NB  next 4 or 6 digits are the group number or the provider number could check for this if desired ???
		*  .and. ;
		* substr(filetoload,3,6) == leading0(str(val(substr(filetoload,3,6)),6)) ;
		* .and. substr(filetoload,9,4)='.001')
		MESSAGEBOX('The file found is not a valid  OHIP - MRO file ( ' + filetoload + ' ) .... Programme Aborting !!!',16,'MOSt - Error')
		CLOSE TABLES ALL
		DELE FILE &file_name..*

		*!* Erick	2003.05.30 - set exclusive off
		SET EXCLUSIVE OFF
		**********************************

		RETURN .F.
	ENDIF
	SET SAFETY OFF
	COPY FILE &filetoload TO backup_dir + filelist(1,1)   && backup RA file to harddrive
	SET SAFETY ON
	SELE temp
	APPEND FROM &filetoload TYPE SDF   &&upload data from file (from the yellow labeled disk to "temp" table)
ELSE
	backup_dir = ADDBS(gc_datadrive)+"backup\EDT\"
	filetoload = ADDBS(gc_datadrive)+"EDT\IN\" + pEDT
	*Copy file &filetoload to backup_dir + pEDT && This statement doesn't work
	SET SAFETY OFF
	COPY FILE ADDBS(gc_datadrive)+"EDT\IN\" + pEDT TO ;
		ADDBS(gc_datadrive)+"backup\EDT\" + pEDT
	APPEND FROM ADDBS(gc_datadrive)+"EDT\IN\" + pEDT TYPE SDF
	SET SAFETY ON
ENDIF

** NB:
&& m_variance=1  && this variable can be used to accept a variance in the amount paid  currently not in use
tot_paid = 0   && total of fees paid on this RA disk

*Messagebox('Warning everyone else should be OFF the billing system.',16,'MOSt - Warning') && Now, this message is useless, because "Do_ra.prg" requires exclusive access anyway. It does so because it doesn't use transactions so needs exclusive access.

* Erick - 2004.05.04 - Trap Error (Printer is not ready) and delay for 5 seconds
* It will try to run this trapping error up to 5 times otherwise error will be thrown back to main error handler
LOCAL bKeepLoop AS Logical
LOCAL intCounter AS INTEGER
LOCAL tCurrent_Time as Datetime 
bKeepLoop  = .T.
intCounter = 0
DO WHILE bKeepLoop
	TRY
		SET PRINTER ON
		bKeepLoop = .F.
	CATCH TO oErr
		IF oErr.Errorno = 125
			intCounter  = intCounter + 1
			* Printer is not ready (Error 125)
			* delay for 5 seconds
			tCurrent_Time=DATETIME()
			DO WHILE .T.
				IF DATETIME()- tCurrent_Time > 4
					EXIT
				ENDIF
			ENDDO
			bKeepLoop = .T.
			IF intCounter = 5
				bKeepLoop  = .F.
			ENDIF
		ENDIF
	ENDTRY
ENDDO
*****************************************************************************************

? '***************************************************************************'
? '                          RA PROCESSING STATEMENT                          '
? '***************************************************************************'
? '  '
? 'Processing date: ',DATE(), '  RA file name: ' + filetoload
? '  '
? '  '
SET CONSOLE OFF

*  records beginning with HR1 HR2 HR3 are identifiers for the provider
*  ie name address and Ohipnumber

****
SELECT 3    &&Submited
SET ORDER TO TAG accounting

*****************************************************************************************
**************************  STARTING LOOP  HERE  ****************************************

tgroup='0000'  && set to default
SELECT 1
GOTO 1  && record 1 is filename,2 -4 are provider's name and address

DO WHILE .NOT. EOF(1)

	** @ 3,30 say 'Processing record #: ' + str(recno())
	record_typ= SUBSTR(temp->DATA,3,1)
	DO CASE
		CASE record_typ="1"  && if you want print out data for 1,2,3
			***
			IF (SUBSTR(temp.DATA,4,3) <> 'V03')  THEN    && IF not V03 file abort
				CLOSE TABLES ALL
				MESSAGEBOX('Data is not V03 compatible .... Program Aborting !!!',16,'MOSt - Warning')
				CLOSE TABLES ALL
				DELE FILE &file_name..*

				*!* Erick	2003.05.30 - set exclusive off
				SET EXCLUSIVE OFF
				**********************************

				RETURN .F.
			ENDIF  && V03
			***
			?'Payment date: ' + SUBSTR(temp->DATA,22,8) + '    Total payable: ', ;
				TRANSFORM(VAL(SUBSTR(temp->DATA,69,1) + ;
				SUBSTR(temp->DATA,60,9))/100,'$,$$$,$$$.99')  && 64 is the sign
			? '  '
			?'Payee: ' + SUBSTR(temp->DATA,30,30) + '  Provider #: ' + ;
				SUBSTR(temp->DATA,12,6) + '  Group #: ' + SUBSTR(temp.DATA,8,4)
			tgroup = SUBSTR(temp.DATA,8,4)

		CASE record_typ="2"
			?'Address: ' + RTRIM(SUBSTR(temp->DATA,34,25)) + ', '

		CASE record_typ="3"
			?? SUBSTR(temp->DATA,4,25)
			? '          ' +SUBSTR(temp->DATA,29,25)
			? '   '
		CASE record_typ="4"
&& this is a claim header record
			tprovider=SUBSTR(temp.DATA,16,6)  && provider number

			*!*	** locate MD mnemonic   it's necessary to do this repeatedly in case this is a group RA
			SELECT 4
			LOCATE FOR MD->ohipnumber == tprovider AND MD.group_num== tgroup
			INITIALS=''
			IF .NOT. FOUND()
				MESSAGEBOX('UNABLE TO LOCATE THIS MD : ' + tprovider  + '-' + tgroup+' - Please add to MD file and rerun .... Program Aborting !!!',16,'MOSt - Warning')
				CLOSE TABLES ALL
				DELE FILE &file_name..*

				*!* Erick	2003.05.30 - set exclusive off
				SET EXCLUSIVE OFF
				**********************************

				RETURN .F.  && stop program
			ELSE
				INITIALS=MD->mnemonic
			ENDIF

			SELECT 1

			taccounting= VAL(ALLTRIM(SUBSTR(temp->DATA,24,8)))  && get accounting number
			lasttaccounting=taccounting
			lastrecord_type=record_typ
			tohip= SUBSTR(temp->DATA,53,12) && healthnum N.B. as 12 char
			tversion = SUBSTR(temp->DATA,65,2)
			tprovince = SUBSTR(temp->DATA,51,2)
			tprogram=SUBSTR(temp->DATA,67,3)
			DO CASE
				CASE tprogram="HCP"
					prog_type="O"
				CASE tprogram="WCB"
					prog_type="W"
				CASE tprogram="RMB"
					prog_type="R"
				OTHERWISE
					prog_type=" "
			ENDCASE
		CASE record_typ="5"
			lastrecord_type=record_typ
&& claim item record
			tservice=SUBSTR(temp->DATA,26,5)
			tservdate=SUBSTR(temp->DATA,16,8)
			terror_cod= TRIM(SUBSTR(temp->DATA,45,2))
			ttransact= VAL(SUBSTR(temp->DATA,15,1))
			tfee_paid= (VAL(SUBSTR(temp->DATA,38,6)) * ;
				VAL(SUBSTR(temp->DATA,44,1) + '1'))/100  && for negative numbers
			tot_paid = tot_paid + tfee_paid

			IF lastrecord_type="5"  AND lasttaccounting=0    && deals with multiple items when accounting number is zero
				taccounting=0
			ENDIF
			***** NB****
			IF ((taccounting < starting_account_num) .AND. taccounting > 0) .OR. (taccounting = 0 AND prog_type == "R")
&& to deal with a goof by ET in first version of OHIPDSK (missing accounting numbers) 2000-04-22
&& in this situation only will skip any RMB's with taccounting of 0  don't want to deal with long HC#'s
&&  in actual fact there shouldn't be any RMB's since they were blocked in the previous versions
				SELECT 1
				SKIP               &&  ie. skip this record if it's old data pre-OMS
				LOOP
			ENDIF

			IF taccounting = 0
				DO find_if_zero   && use special search to find if accounting # is 0 due to goof
			ELSE
				SELECT 3
&& The following 2 lines removed 2001.05.28 GEORGE and add a new one: the third ("do find_it")
				*Seek taccounting
				*trueseek=found()  && must do this because skip makes found() false
				DO find_it
			ENDIF

			IF trueseek && i.e. the claim was found in Submited table.
				m_add_it_to_raerror = .F.
				DO CASE
					CASE ttransact = 1 && original payment
						*IF LEN(ALLT(submited.claim_num))>0 OR !EMPTY(submited.rec_date)
						IF (LEN(ALLT(submited.claim_num))>0 OR !EMPTY(submited.rec_date))

							m_add_it_to_raerror = .T. && 2002.02.11 George. Today, on an ET's yellow labeled disk,
&& MOH sent correctly the payments for a bunch of claims,
&& but then, mistakenly, on the same disk they sent the same bunch
&& of claims as 35's. This program did put firstly the correct fee_paid
&& in Submited table, then replaced them with fee_paid=0 and error_code='35'
&& In order to prevent this, when a claim from the remitted disk is
&& found in Submited table, firstly, the program checks if this claim
&& is already reconciled. If it is, then the "m_add_it_to_raerror"
&& is set (TRUE) and the claim from submited table is not altered anymore,
&& and the correspondent claim from the remitted disk is written in Ra_Error table.

							** 2003.08.19 ** Record all errors in submited table comments memo field
							** record error in the memo field
							strTempMemo = submited.Comments + SUBSTR(temp->DATA,4,11)+SPACE(3)+"Error: "+SPACE(3)+;
								ALLTRIM(terror_cod)+SPACE(3)+"Rec_Date: "+DTOC(DATE())+CHR(13)+CHR(10)

							REPLACE submited.Comments WITH strTempMemo

							** check if there is a new fee value to store
							IF tfee_paid # 0.0000
								REPLACE submited->fee_paid WITH tfee_paid
								REPLACE submited->error_code WITH terror_cod
								REPLACE submited->claim_num WITH SUBSTR(temp->DATA,4,11)
							ENDIF
							** send all errors to RA_Error table
						ELSE
							REPLACE submited->fee_paid WITH tfee_paid
							REPLACE submited->error_code WITH terror_cod
							REPLACE submited->claim_num WITH SUBSTR(temp->DATA,4,11)
						ENDIF
					CASE ttransact = 2	&& adjustment
						SELE adjustments
						LOCA FOR adjustments.ID=submited.ID AND adjustments.accounting=submited.accounting ;
							AND adjustments.service=submited.service AND adjustments.transactn=1
							
							
						IF !FOUND()
							APPE BLAN
							SELE submited
							SCAT MEMV
							m.status='A'
							m.eligable=''
							m.healthnum=tohip
							m.province=tprovince
							m.version=tversion
							m.transactn=1
							SELE adjustments
							GATH MEMV
							
						ENDIF 							
						
						 	* Erick 2004.07.13 - rechange transaction date with transaction 2 for different service date code
							* also add a comment explaining what happend 
							dCheckService = DATE(VAL(SUBSTR(tservdate,1,4)),VAL(SUBSTR(tservdate,5,2)),VAL(SUBSTR(tservdate,7,2)))
							dCurrServDate = submited.Serv_date
							IF dCheckService # submited.Serv_date AND VAL(terror_cod) = 57
								Replace submited.Serv_date WITH dCheckService
								** Record a message in the commenst column.
								strExplain = IIF(EMPTY(submited.comments),'Service Date has changed due to manual MOH. From '+DTOC(dCurrServDate)+' To '+DTOC(dCheckService),;
									ALLTRIM(submited.comments)+CHR(10)+'Service Date has changed due to manual MOH. From '+DTOC(dCurrServDate)+' To '+DTOC(dCheckService))
								replace submited.comments WITH strExplain 
							ENDIF 
						REPLACE submited->fee_paid WITH submited->fee_paid + tfee_paid   && make adjustment
						REPLACE submited->error_code WITH terror_cod
						REPLACE submited.STATUS WITH 'ADJMT'
				ENDCASE
				IF m_add_it_to_raerror
					SELE reconciled_already
					APPE BLAN
					REPL reconciled_already.rec_date WITH DATE()  && stamp with today's date
					REPL reconciled_already.STATUS WITH 'E'
					REPL reconciled_already.ID WITH submited.ID
					REPL reconciled_already.accounting WITH taccounting
					REPL reconciled_already.healthnum WITH ALLTRIM(tohip)
					REPL reconciled_already.VERSION WITH tversion
					REPL reconciled_already.fee_paid WITH (VAL(SUBSTR(temp->DATA,38,6)) * ;
						VAL(SUBSTR(temp->DATA,44,1) + '1'))/100  && handles negative number (takes sign and multiples fee by -1
					REPL reconciled_already.transactn WITH ttransact && although, here, ttransact will always be 1
					REPL reconciled_already.TYPE WITH prog_type
					REPL reconciled_already.province WITH tprovince
					REPL reconciled_already.serv_date WITH DATE(VAL(SUBSTR(tservdate,1,4)),VAL(SUBSTR(tservdate,5,2)),VAL(SUBSTR(tservdate,7,2)))
					REPL reconciled_already.service WITH tservice
					REPL reconciled_already.num_serv WITH VAL(SUBSTR(temp->DATA,24,2))
					REPL reconciled_already.fee_submit WITH VAL(SUBSTR(temp->DATA,32,6))/100
					REPL reconciled_already.claim_num WITH SUBSTR(temp->DATA,4,11)
					REPL reconciled_already.billing_md WITH INITIALS
					REPL reconciled_already.error_code WITH terror_cod
				ELSE
					REPLACE submited.rec_date WITH DATE()
					IF submited.service <> tservice
						REPLACE submited.rec_service WITH tservice
					ENDIF
					IF ABS(submited.fee_submited - submited.fee_paid)*10000/submited.fee_submited <= m_variance ;
							AND ttransact = 1 AND submited.service == tservice AND taccounting > 0
						** For Options.code = "VARIANCE", Options.valuenum must be an integer
						** in the range [1 - 10000]. This value means a percentage multiplied
						** by 100. For example 1.92% will be stored in Options.valuenum as 192
						**  although some round off error exists  eg 1%  needs to be 103 ??
						REPL submited.STATUS WITH "ACCPT"

						** Erick 2003.09.09 Record all the errors if there is any,
						** even if it was accepted
						IF !EMPTY(terror_cod)
							SELECT 2
							APPEND BLANK
							REPLACE ra_error.rec_date WITH DATE()  && stamp with today's date
							IF ttransact =2
								REPLACE ra_error.STATUS WITH 'A'
							ELSE
								REPLACE ra_error->STATUS WITH 'E'
							ENDIF
							REPLACE ra_error.ID WITH submited.ID
							REPLACE ra_error->accounting WITH taccounting
							REPLACE ra_error->healthnum WITH ALLTRIM(tohip)
							REPLACE ra_error->VERSION WITH tversion
							REPLACE	ra_error->fee_paid WITH (VAL(SUBSTR(temp->DATA,38,6)) * ;
								VAL(SUBSTR(temp->DATA,44,1) + '1'))/100  && handles negative number (takes sign and multiples fee by -1
							REPLACE ra_error->transactn WITH ttransact
							REPLACE ra_error->TYPE WITH prog_type
							REPLACE ra_error->province WITH tprovince
							REPLACE ra_error->serv_date WITH DATE(VAL(SUBSTR(tservdate,1,4)),VAL(SUBSTR(tservdate,5,2)),VAL(SUBSTR(tservdate,7,2)))
							REPLACE ra_error->service WITH tservice
							REPLACE ra_error->num_serv WITH VAL(SUBSTR(temp->DATA,24,2))
							**    replace ra_error->eligable with substr(temp->data,31,1)           no longer used
							REPLACE ra_error->fee_submited WITH VAL(SUBSTR(temp->DATA,32,6))/100
							REPLACE ra_error->claim_num WITH SUBSTR(temp->DATA,4,11)
							REPLACE ra_error->billing_md WITH INITIALS
							REPLACE ra_error->error_code WITH terror_cod
						ENDIF
					ELSE
						SELECT 2
						APPEND BLANK
						REPLACE ra_error.rec_date WITH DATE()  && stamp with today's date
						IF ttransact =2
							REPLACE ra_error.STATUS WITH 'A'
						ELSE
							REPLACE ra_error->STATUS WITH 'E'
						ENDIF
						REPLACE ra_error.ID WITH submited.ID
						REPLACE ra_error->accounting WITH taccounting
						REPLACE ra_error->healthnum WITH ALLTRIM(tohip)
						REPLACE ra_error->VERSION WITH tversion
						REPLACE	ra_error->fee_paid WITH (VAL(SUBSTR(temp->DATA,38,6)) * ;
							VAL(SUBSTR(temp->DATA,44,1) + '1'))/100  && handles negative number (takes sign and multiples fee by -1
						REPLACE ra_error->transactn WITH ttransact
						REPLACE ra_error->TYPE WITH prog_type
						REPLACE ra_error->province WITH tprovince
						REPLACE ra_error->serv_date WITH DATE(VAL(SUBSTR(tservdate,1,4)),VAL(SUBSTR(tservdate,5,2)),VAL(SUBSTR(tservdate,7,2)))
						REPLACE ra_error->service WITH tservice
						REPLACE ra_error->num_serv WITH VAL(SUBSTR(temp->DATA,24,2))
						**    replace ra_error->eligable with substr(temp->data,31,1)           no longer used
						REPLACE ra_error->fee_submited WITH VAL(SUBSTR(temp->DATA,32,6))/100
						REPLACE ra_error->claim_num WITH SUBSTR(temp->DATA,4,11)
						REPLACE ra_error->billing_md WITH INITIALS
						REPLACE ra_error->error_code WITH terror_cod
					ENDIF
				ENDIF
			ELSE  && !trueseek (ie not found)
				IF m_same_idacc .OR. (!m_same_idacc AND !MD.multioffice)


					SELECT 2
					APPEND BLANK
					REPLACE ra_error.rec_date WITH DATE()  && stamp with today's date
					IF m_same_idacc
						REPL ra_error.ID WITH submited.ID
						REPL ra_error.STATUS WITH 'F'
					ELSE
						*Use patients in 71
						SELECT 71
						SET ORDER TO healthnum
						SEEK ALLTRIM(tohip)
						IF FOUND()
							REPLACE ra_error.ID WITH  patients.ID
							REPLACE ra_error->STATUS WITH 'F'
						ELSE
							REPLACE ra_error->STATUS WITH 'N'
							REPLACE ra_error.ID WITH 0             && this should never happen
						ENDIF
						*Use   && close patients
						SELECT 2
					ENDIF
					REPLACE ra_error->accounting WITH taccounting
					REPLACE ra_error->healthnum WITH ALLTRIM(tohip)
					REPLACE ra_error->VERSION WITH tversion
					REPLACE	ra_error->fee_paid WITH (VAL(SUBSTR(temp->DATA,38,6)) * ;
						VAL(SUBSTR(temp->DATA,44,1) + '1'))/100  && handles negative;
&& number (takes sign and multiples fee by -1
					REPLACE ra_error->transactn WITH ttransact
					REPLACE ra_error->TYPE WITH prog_type
					REPLACE ra_error->province WITH tprovince
					REPLACE ra_error->serv_date WITH CTOD(SUBSTR(tservdate,1,4) + ;
						'.' + SUBSTR(tservdate,5,2) + '.' + SUBSTR(tservdate,7,2))
					REPLACE ra_error->service WITH tservice
					REPLACE ra_error->num_serv WITH VAL(SUBSTR(temp->DATA,24,2))
					REPLACE ra_error->fee_submited WITH VAL(SUBSTR(temp->DATA,32,6))/100
					REPLACE ra_error->claim_num WITH SUBSTR(temp->DATA,4,11)
					REPLACE ra_error->billing_md WITH INITIALS
					REPLACE ra_error->error_code WITH terror_cod
					*IF ra_error.transactn<>2 .AND. ra_error.STATUS=='F'&& .and.(ra_error.fee_paid<>ra_error.fee_submited)
					** Erick 2003.08.26
					IF ra_error.STATUS=='F'&& .and.(ra_error.fee_paid<>ra_error.fee_submited)
						SELE submited
						APPE BLANK
						REPL  submited.accounting WITH ra_error.accounting, submited.comments ;
							WITH IIF(EMPTY(submited.comments),'',ALLT(submited.comments)+CHR(13)+REPL('-',60)+CHR(13))+"Not found in submited HC: "+ ra_error.healthnum,;
							submited.TYPE WITH ra_error.TYPE, submited.serv_date WITH ra_error.serv_date, submited.service WITH ra_error.service, ;
							submited.fee_submited WITH ra_error.fee_submited, submited.fee_paid WITH ra_error.fee_paid,;
							submited.error_code WITH ra_error.error_code, submited.claim_num WITH ra_error.claim_num, ;
							submited.billing_md  WITH ra_error.billing_md, submited.STATUS WITH 'NTFND', ;
							submited.rec_date WITH ra_error.rec_date, submited.num_serv WITH ra_error.num_serv
						REPL submited.ID WITH ra_error.ID
						SELE ra_error
					ENDIF
				ENDIF
			ENDIF && trueseek

		CASE record_typ = "6"
			? 'Balance Forward Record (HR6): '
			? '   1) Amount Brought Forward - Claims adjustment: ', ;
				TRANSFORM(VAL(SUBSTR(temp->DATA,13,1) + ;
				SUBSTR(temp->DATA,4,9))/100,'$,$$$,$$$.99')  && 13 is the sign
			? '   2) Amount Brought Forward - Advances: ', ;
				TRANSFORM(VAL(SUBSTR(temp->DATA,23,1) + ;
				SUBSTR(temp->DATA,14,9))/100,'$,$$$,$$$.99')  && 23 is the sign
			? '   3) Amount Brought Forward - Reductions: ', ;
				TRANSFORM(VAL(SUBSTR(temp->DATA,33,1) + ;
				SUBSTR(temp->DATA,24,9))/100,'$,$$$,$$$.99')  && 33 is the sign
			? '   4) Amount Brought Forward - Other Deductions: ', ;
				TRANSFORM(VAL(SUBSTR(temp->DATA,43,1) + ;
				SUBSTR(temp->DATA,34,9))/100,'$,$$$,$$$.99')  && 43 is the sign
			? '(See Technical specifications manual section 60 for explanation of above)'
			? '  '
		CASE record_typ = "7"
			? 'Accounting Transaction Record (HR7): '
			trancode = SUBSTR(temp->DATA,4,2) && transaction code
			DO CASE
				CASE trancode = '10'
					? '     Advance: '
				CASE trancode = '20'
					? '     Reduction: '
				CASE trancode = '40'
					? '     Advance repayment: '
				CASE trancode = '50'
					? '     Accounting adjustment: '
				CASE trancode = '70'
					? '     Attachments: '
			ENDCASE

			??   TRANSFORM(VAL(SUBSTR(temp->DATA,23,1) + ;
				SUBSTR(temp->DATA,15,8))/100,'$,$$$,$$$.99'), ;
				'  Transaction Date: ' + SUBSTR(temp->DATA,7,8)
			chequetp = SUBSTR(temp->DATA,6,1)
			DO CASE
				CASE chequetp = "M"
					? '     Cheque type: Manual cheque issued'
				CASE chequetp = "C"
					? '     Cheque type: Computer cheque issued'
				CASE chequetp = "I"
					? '     Cheque type: Interim payment - Cheque/Direct Bank Deposit issued'
			ENDCASE

			? '     Message: ' + SUBSTR(temp->DATA,24,50)
			? '  '

		CASE record_typ = "8"
			? SUBSTR(temp->DATA,4,70)   && print line except for HR

	ENDCASE
	SELECT 1
	SKIP
ENDDO
*!*	set console on
? " "
? " "
? "=============================================================================== "
? "  "
? ' Total value of Claims paid on this RA: ', TRANSFORM(tot_paid,'$,$$$,$$$.99')

&&eject
SET PRINTER OFF
SET PRINTER TO DEFAULT
SET TALK OFF


&& do clawback  && program to delete all records which show a 6% clawback


IF EMPTY(pEDT) && no EDT
	*** create a lockout file to prevent reconciling same data twice
	fyl_handle= -1
	DO WHILE fyl_handle= -1    && make sure can create the file
		fyl_handle= FCREATE(floppy_drive+'Reconciled_Already.txt')  && will overwrite without warning
		IF fyl_handle = -1
			MESSAGEBOX('Unable to write to disk !!  Please ensure RA disk is not write protected AND in the drive !!',16,'MOSt - Warning')
		ENDIF
	ENDDO
	=FPUTS(fyl_handle,TTOC(DATETIME()))
	=FCLOSE(fyl_handle)
ENDIF


**************************************************************************8

*!* Erick	WAIT CLEAR
*!* Erick	WAIT "Printing report(s) ...." WINDOW TIMEOUT 3  && Don't know why but without these timeouts get an error if more than 1 report is printed

*!* Erick	&& reports
*!* Erick	nanswer=6
*!* Erick	DO WHILE nanswer=6  && allow for printer jams etc to permit reprinting documents

*!* Erick		SELECT 2 && ra_error  Erick 2003.06.16 select working area
*!* Erick		m_report_header="Report of Transaction Adjustments (RA - Report 1)"
*!* Erick		COUNT TO m.NumOfRec FOR ra_error.transactn=2
*!* Erick		IF m.NumOfRec > 0
*!* Erick			REPORT FORM ra_error FOR transactn=2 TO PRINTER NOCONSOLE
*!* Erick			WAIT "Printing report(s) ...." WINDOW TIMEOUT 3  && Don't know why but without these timeouts get an error if more than 1 report is printed
*!* Erick		ENDIF

*!* Erick		m_report_header="Report of Error Codes - for Items fully paid (RA - Report 2)"
*!* Erick		* ERICK - check if there is any data to printout
*!* Erick		COUNT TO m.NumOfRec FOR LEN(ALLTRIM(ra_error.error_code))>0  AND ra_error.fee_paid=ra_error.fee_submited
*!* Erick		IF m.NumOfRec > 0
*!* Erick			REPORT FORM ra_error FOR LEN(ALLTRIM(ra_error.error_code))>0  AND ra_error.fee_paid=ra_error.fee_submited TO PRINTER NOCONSOLE
*!* Erick			WAIT "Printing report(s) ...." WINDOW TIMEOUT 3  && Don't know why but without these timeouts get an error if more than 1 report is printed
*!* Erick		ENDIF

*!* Erick		m_report_header="Report of Items not correctly paid (over/under payment) (RA - Report 3)"
*!* Erick		* ERICK - check if there is any data to printout
*!* Erick		COUNT TO m.NumOfRec FOR (ra_error.fee_paid <> ra_error.fee_submited) AND ra_error.STATUS<>'A'
*!* Erick		IF m.NumOfRec > 0
*!* Erick			REPORT FORM ra_error FOR  (ra_error.fee_paid <> ra_error.fee_submited) AND ra_error.STATUS<>'A' TO PRINTER NOCONSOLE
*!* Erick	&&and (ra_error.billing_md == initials) to printer noconsole  && if more than one MD is still on file
*!* Erick	&& only prints the current doctor
*!* Erick			WAIT "Printing report(s) ...." WINDOW TIMEOUT 3  && Don't know why but without these timeouts get an error if more than 1 report is printed
*!* Erick		ENDIF

*!* Erick		m_report_header="Report of Items not found in Submitted file (RA - Report 4)"
*!* Erick		COUNT TO m.NumOfRec FOR ra_error.STATUS=="F" OR ra_error.STATUS=='N'
*!* Erick		IF m.NumOfRec > 0
*!* Erick			REPORT FORM ra_error FOR ra_error.STATUS=="F" OR ra_error.STATUS=='N' TO PRINTER NOCONSOLE
*!* Erick			WAIT "Printing report(s) ...." WINDOW TIMEOUT 3   && Don't know why but without these timeouts get an error if more than 1 report is printed
*!* Erick		ENDIF

*!* Erick		SELE reconciled_already
*!* Erick		IF RECC()>0
*!* Erick			m_report_header="Listing of duplicate reconciliations that have been DELETED(MOH error 35)"
*!* Erick			REPORT FORM reconciled_already TO PRINTER NOCONSOLE && PREV  ET 2003-08-18 &&to printer noconsole
*!* Erick			WAIT "Printing report(s) ...." WINDOW TIMEOUT 3   && Don't know why but without these timeouts get an error if more than 1 report is printed
*!* Erick		ENDIF
*!* Erick		nanswer = 7 &&& No only printed once
*!* Erick	ENDDO

*!* Erick	&& erase or move what you don't need
*!* Erick	&& move all adjustments to adjustment file and delete from ra_error
*!* Erick	SELE adjustments
*!* Erick	APPEND FROM ra_error FOR transactn=2
*!* Erick	SELE ra_error
*!* Erick	DELETE FOR transactn=2  ALL
*!* Erick	DELETE FOR LEN(ALLTRIM(ra_error.error_code))>0  AND ra_error.fee_paid=ra_error.fee_submited ALL
*!* Erick	&& stuff with warnings but paid
*!* Erick	REPLACE FOR ra_error.accounting=0 ra_error.accounting WITH 1 && because of goof up  NB can remove later 20000423
*!* Erick	DELETE FOR  ra_error.STATUS=='F'
*!* Erick	DELE FOR ra_error.ID=0 OR ra_error.STATUS=='N' OR LEN(ALLT(ra_error.billing_md))=0
*!* Erick	SET SAFETY OFF
*!* Erick	PACK              && clear all the deleted items
*!* Erick	SET SAFETY ON

*!* Erick	SET CONSOLE ON
*!* Erick	SELE reconciled_already
*!* Erick	USE
*!* Erick	DELE FILE &file_name..*
*!* Erick	*********************************************************************************************


CLOSE TABLES ALL
*!* Erick	2003.05.30 - set exclusive off
SET EXCLUSIVE OFF
*********************************

RETURN .T.


PROCEDURE find_if_zero
	***  to find if accounting number is 0   because of goof up   (later can remove this and all references to this without any impact
	LOCAL bCheckForAlphaNumeric
	bCheckForAlphaNumeric = .F.
	*!* Erick	2003.06.02 - Accounting number could be 0 for alphanumeric accounting #,
	*!* Erick	Make sure to treat it as accounting 0

	*Use patients in 71
	SELECT 71
	SET ORDER TO healthnum
	SEEK ALLTRIM(tohip)
	IF FOUND()
		m_seek_id = patients.ID
	ELSE
		trueseek=.F.
		m_same_idacc = .F.
		SELECT 3
		RETURN
	ENDIF

	SELECT 3
	SET ORDER TO TAG ID
	tdservdate=DATE(VAL(SUBSTR(tservdate,1,4)),VAL(SUBSTR(tservdate,5,2)),VAL(SUBSTR(tservdate,7,2)))
	SCAN FOR submited.ID = m_seek_id .AND. submited.billing_md == INITIALS
		IF submited.serv_date= tdservdate .AND. submited.service = tservice
			taccounting = submited.accounting
			trueseek = .T.
			m_near = .T.
			bCheckForAlphaNumeric = .T.
			*Select patients
			*Use                && close patients
			*Select 3
&&& I commented out the following 2 lines of code, because, from now on,
&&& we adopt the non unique accounting numbers approach. Also, the minus for
&&& this procedure("find_if_zero") is that it doesn't consider the case of 2 or
&&& more services with the same code, in the same day, for the same patient. It's
&&& unlikely, but still possible.     GEORGE  2001.05.28
			*Set order to tag accounting
			*Seek taccounting       &&&  just my paranoia to make sure it's on the correct record
			EXIT
		ELSE
			trueseek=.F.
			m_same_idacc = .F.
			bCheckForAlphaNumeric = .F.
		ENDIF
	ENDSCAN

	*!* Erick	2003.06.02 - Accounting number could be 0 for alphanumeric accounting #,
	*!* Erick	Make sure to treat it as accounting 0
	IF bCheckForAlphaNumeric = .F.
		trueseek=.F.
		m_same_idacc = .F.
	ENDIF

	RETURN

	*******************************

PROCEDURE find_it
&& procedure to find the corresponding submitted claim in "Submited.dbf". Added 2001.05.28 GEORGE

	*Use patients in 71
	SELECT 71
	SET ORDER TO healthnum
	SEEK ALLTRIM(tohip)
	IF FOUND()
		m_seek_id = patients.ID
	ELSE
		trueseek=.F.
		m_same_idacc = .F.
		SELECT 3
		RETURN
	ENDIF

	SELECT 3 && submited
	SET ORDER TO TAG id_acc_srv
	SEEK STR(m_seek_id,6)+STR(taccounting,8)+tservice
	*!*	if eof()
	*!*	   trueseek=.f.
	*!*	else
	*!*	   trueseek=.t.
	*!*	endif
&& This takes into account the non unique accounting numbers and makes an assumption:
&&    - if a perfect matching between a record from the yellow labeled disk
&&      and "Submited.dbf" can not be found (i.e. the same patient id, the
&&      same accounting number and the same service), then the procedure
&&      is searching in that group of submitted claims which have the same
&&      patient id and the same accounting number, for a claim with the same serv_date
&&      and the same fee_submited like serv_date and fee_submited from the current record from yellow
&&      labeled disk. I did this because, sometimes, the Government changes
&&      the service code for the remitted claim, but, as far as I saw, doesn't
&&      change the originally fee_submited, and, of course, doesn't change the service date.
&&      Also, the assumption of different accounting numbers for different service dates
&&      is made.     2001.05.28 GEORGE
	IF !FOUND()
		m_setexact=SET('exact')
		SET EXACT OFF
		SEEK STR(m_seek_id,6)+STR(taccounting,8)
		SET EXACT &m_setexact
		trueseek=.F.
		m_same_idacc = .F.
		IF FOUND()
			tdservdate=DATE(VAL(SUBSTR(tservdate,1,4)),VAL(SUBSTR(tservdate,5,2)),VAL(SUBSTR(tservdate,7,2)))
			DO WHILE submited.ID=m_seek_id AND submited.accounting=taccounting
				IF (submited.fee_submited = VAL(SUBSTR(temp->DATA,32,6))/100) .AND. ;
						(submited.serv_date = tdservdate) .AND. submited.billing_md == INITIALS
					trueseek=.T.
					m_near = .T.
					EXIT
				ELSE
					SKIP 1
					IF EOF()
						EXIT
					ENDIF
				ENDIF
			ENDDO
		ENDIF
	ELSE
		trueseek=.T.
		m_near = .F.
	ENDIF
	RETURN
