*!*	DO FORM supervisor_Login TO pwok
*!*	IF !(pwok > 0) then
*!*		RETURN
*!*	ENDIF
LOCAL nFiles, i,j, file_nm, file_name1, file_name2, temp_dir, gnFileHandle, gnPosition,;
	cString, m_temp, m_batch_total, m_micro_type, m_error, m_reason_for_file_reject,;
	m_rec_length_submit, m_record_image, m_submited_filename, m_uploading_date,;
	m_uploading_time

LOCAL bRunRa_Report

bRunRa_Report = .F.

SET DATE TO ANSI
SET CENTURY ON

CLOSE TABLES ALL
USE ADDBS(JUSTPATH(oms_local_fullpath))+"options" IN 0
SELE options
LOCATE FOR ALLT(options->CODE)=='EDT'
IF ALLT(options.CODE)=='EDT'    && should use found() really
	IF options.valuenum > 0
		m_not_preview = .F.
	ELSE
		m_not_preview = .T.
	ENDIF
ENDIF

**** ERICK - This check is no longer need it
*!*	nFiles = ADIR(aEDTFilesOut, gc_datadrive+"EDT\OUT\*.*")  && Create array
*!*	IF nFiles > 0
*!*	**********
*!*		file_nm=  uniqfile()
*!*		temp_dir=SYS(2023)
*!*		file_name= temp_dir + "\"+ file_nm + ".dbf"
*!*		CREATE TABLE &file_name FREE (DATA C(80))
*!*		SELE &file_nm
*!*		USE
*!*		USE &file_name IN 0 ALIAS outstand_claimfiles EXCL
*!*	**********
*!*		SELE outstand_claimfiles
*!*		FOR i=1 TO nFiles
*!*			IF SUBSTR(UPPER(aEDTFilesOut(i,1)),1,1)=="H"
*!*				APPE BLAN
*!*				REPL DATA WITH ALLT(aEDTFilesOut(i,1))
*!*			ENDIF
*!*		ENDFOR
*!*		IF RECC() > 0
*!*			IF m_not_preview
*!*				REPO FORM edt_outstand TO PRINTER NOCONSOLE
*!*			ELSE
*!*				REPO FORM edt_outstand PREV
*!*			ENDIF
*!*			answer = MESSAGEBOX("      Have these files already been sent to MOH " + CHR(13)+;
*!*				"and do you wish to DELETE them from the EDT OUT folder ?", 4+32+256, ;
*!*				"MOSt Asking...")
*!*			IF answer = 6
*!*				answer = MESSAGEBOX("Confirm DELETION of file(s) ?", 4+16+256, ;
*!*					"MOSt Warning !")
*!*				IF answer = 6
*!*					SET SAFETY OFF
*!*					DELE FILE gc_datadrive+"EDT\OUT\H*.*"
*!*					SET SAFETY ON
*!*				ENDIF
*!*			ENDIF
*!*		ENDIF
*!*		USE
*!*		file_name=temp_dir + "\"+ file_nm + ".*" && to have all the extensions for this file name. Not only '.dbf', but also '.fpt'
*!*		DELE FILE &file_name
*!*	ENDIF
*!*	RELEASE aEDTFilesOut

nFiles = ADIR(aEDTFiles, gc_datadrive+"EDT\IN\*.*")  && Create array
IF nFiles = 0
	MESSAGEBOX("No downloaded EDT files were found!",64,"MOSt - Note")
ELSE
	CLOSE TABLES ALL
	USE MD
	USE patients IN 0 ORDER healthnum
	USE ohiperr IN 0 ORDER errorcode
	**********
	file_nm=  uniqfile()
	temp_dir=SYS(2023)
	file_name1= temp_dir + "\"+ file_nm + ".dbf"
	CREATE TABLE &file_name1 FREE (rec_type C(3),ID N(6),surname C(30),firstname C(20),dob D,healthnum C(10),VERSION C(2),province C(2),;
		serv_date D, num_serv N(2),service C(5),diagnosis C(4),referr_md C(6), facility C(4),;
		admit_date D,TYPE C(3),location C(4),accounting N(8),fee_submit N(9,2),;
		md_sur C(25), md_firs C(15),md_mnemo C(2),physician C(2),MESSAGE C(60),specialty C(2),proc_date D, ;
		sex C(1),expln_code C(2),err1 C(3),err2 C(3),err3 C(3),err4 C(3),err5 C(3),;
		p_err1 C(3),p_err2 C(3),p_err3 C(3),p_err4 C(3),p_err5 C(3) )
	SELE &file_nm
	USE
	USE &file_name1 IN 0 ALIAS edt_err EXCL
	**********
	file_nm=  uniqfile()
	temp_dir=SYS(2023)
	file_name2= temp_dir + "\"+ file_nm + ".dbf"
	CREATE TABLE &file_name2 FREE (DATA C(80))
	SELE &file_nm
	USE
	USE &file_name2 IN 0 ALIAS edt_batch EXCL
	**********
	file_nm=  uniqfile()
	temp_dir=SYS(2023)
	file_name3= temp_dir + "\"+ file_nm + ".dbf"
	CREATE TABLE &file_name3 FREE (errorcode C(3),MESSAGE C(60))
	SELE &file_nm
	USE
	USE &file_name3 IN 0 ALIAS edt_expl EXCL
	INDEX ON errorcode TAG errorcode
	SET RELA TO errorcode INTO ohiperr
	**********

	FOR i=1 TO nFiles

		DO CASE
			CASE SUBSTR(UPPER(aEDTFiles(i,1)),1,1)=="X" AND ;
					LEN(aEDTFiles(i,1)) = 12
				IF SUBSTR(UPPER(aEDTFiles(i,1)),2,1) $ "ABCDEFGHIJKL" AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),3,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),4,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),5,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),6,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),7,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),8,1)) AND ;
						SUBSTR(aEDTFiles(i,1),9,1) == "." AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),10,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),11,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),12,1))  && EDT File Reject Message
					gnFileHandle = Give_FileHandle(@i) && local variables passed by reference to UDF
					IF gnFileHandle > -1
						SELE edt_batch
						SET SAFETY OFF
						ZAP
						SET SAFETY ON
						APPE BLAN
						m_file_name = aEDTFiles(i,1)
						m_process_date = CTOD('')
						= FREAD(gnFileHandle, 3)
						cString = FREAD(gnFileHandle, 20)
						m_reason_for_file_reject = ALLT(cString)
						cString = FREAD(gnFileHandle, 5)
						m_rec_length_submit = PADL(ALLT(STR(VAL(cString))),5,SPACE(1))
						= FREAD(gnFileHandle, 11)
						cString = FREAD(gnFileHandle, 37)
						m_record_image = ALLT(cString)
						= FREAD(gnFileHandle, 42)
						= FREAD(gnFileHandle, 2) && LF + CR
						= FREAD(gnFileHandle, 8)
						cString = FREAD(gnFileHandle, 12)
						m_submited_filename = ALLT(cString)
						= FREAD(gnFileHandle, 5)
						cString = FREAD(gnFileHandle, 8)
						m_uploading_date = CTOD('')
						IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
							m_uploading_date = DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
						ENDIF
						m_uploading_time = ''
						= FREAD(gnFileHandle, 5)
						cString = FREAD(gnFileHandle, 6)
						IF BETW(VAL(SUBSTR(cString,1,2)),0,23) AND BETW(VAL(SUBSTR(cString,3,2)),0,59) ;
								AND BETW(VAL(SUBSTR(cString,5,2)),0,59)
							m_uploading_time = SUBSTR(cString,1,2)+":"+SUBSTR(cString,3,2)+":"+SUBSTR(cString,5,2)
						ENDIF
						= FREAD(gnFileHandle, 6)
						cString = FREAD(gnFileHandle, 8)
						IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
							m_process_date = DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
						ENDIF
						= FCLOSE(gnFileHandle)
						SET SAFETY OFF
						COPY FILE gc_datadrive+"EDT\IN\"+aEDTFiles(i,1) TO gc_datadrive+"BACKUP\EDT\"+aEDTFiles(i,1)
						DELE FILE gc_datadrive+"EDT\IN\"+aEDTFiles(i,1)
						SET SAFETY ON
						IF m_not_preview
							REPO FORM edt_rep1 TO PRINTER NOCONSOLE
						ELSE
							REPO FORM edt_rep1 PREV
						ENDIF
					ENDIF
				ENDIF
			CASE SUBSTR(UPPER(aEDTFiles(i,1)),1,1)=="B" AND ;
					LEN(aEDTFiles(i,1)) = 11
				IF SUBSTR(UPPER(aEDTFiles(i,1)),2,1) $ "ABCDEFGHIJKL" AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),3,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),4,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),5,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),6,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),7,1)) AND ;
						SUBSTR(aEDTFiles(i,1),8,1) == "." AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),9,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),10,1)) AND ;
						ISDIGIT(SUBSTR(aEDTFiles(i,1),11,1))  && EDT Claims Batch Edit Report


					gnFileHandle = Give_FileHandle(@i) && local variables passed by reference to UDF
					IF gnFileHandle > -1
						DO WHILE !FEOF(gnFileHandle)
							cString = FREAD(gnFileHandle, 17)
							cString = FREAD(gnFileHandle, 8)
							m_md_created_on = CTOD('')
							IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
								m_md_created_on = DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
							ENDIF
							cString = FREAD(gnFileHandle, 27)
							m_grp = FREAD(gnFileHandle, 4) && Group #
							m_ohipno = FREAD(gnFileHandle, 6) && Ohipnumber
							SELE MD
							SET ORDER TO ihfnohip
							SEEK m_grp + m_ohipno
							IF FOUND()
								m_md_surname = ALLT(MD.surname)
								m_md_firstname = ALLT(MD.firstname)
								m_md_mnemonic = MD.mnemonic
							ELSE
								MESSAGEBOX("         The IHFN + OHIPNUMBER "+m_grp+" + "+m_ohipno+CHR(13)+;
									" sent by MOH in "+'"'+aEDTFiles(i,1)+'"'+" file NOT FOUND in MD table !",;
									64,"MOSt Warning !")
								m_md_surname="UNKNOWN"
								m_md_firstname="UNKNOWN"
								m_md_mnemonic = ''
							ENDIF
							m_file_name = aEDTFiles(i,1)
							m_process_date = CTOD('')
							SELE edt_batch
							SET SAFETY OFF
							ZAP
							SET SAFETY ON
							cString = FREAD(gnFileHandle, 11)
							cString = FREAD(gnFileHandle, 8)
							IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
								m_process_date = DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
							ENDIF
							cString = FREAD(gnFileHandle, 39)
							cString = FREAD(gnFileHandle, 1)
							= FSEEK(gnFileHandle, -121,1) && *** Move the file pointer to beginning of record ***
							APPE BLAN
							IF cString == "R"
								REPL edt_batch.DATA WITH "This batch was REJECTED"
								DO WHILE .T.
									cString = FREAD(gnFileHandle, 81)
									cString = FREAD(gnFileHandle, 40)
									APPE BLAN
									IF SUBSTR(cString,40,1) == "R"
										m_error = ALLT(SUBSTR(cString,1,39))
										m_temp = "Error in:   claim "
										= FSEEK(gnFileHandle, -59,1)
										cString = FREAD(gnFileHandle, 5)
										m_temp = m_temp + PADR(ALLT(STR(VAL(cString))),5,SPACE(1)) + ",     record "
										cString = FREAD(gnFileHandle, 6)
										m_temp = m_temp + PADR(ALLT(STR(VAL(cString))),6,SPACE(1))
										m_temp = m_temp + SPACE(5)+m_error
										REPL edt_batch.DATA WITH m_temp
										APPE BLAN
										= FREAD(gnFileHandle, 59)
										= FREAD(gnFileHandle, 2) && LF + CR
									ELSE
										REPL edt_batch.DATA WITH SPACE(5)+REPLICATE("-",7)
										APPE BLAN
										m_temp = SPACE(5) + "Total:    "
										= FSEEK(gnFileHandle, -59,1)
										cString = FREAD(gnFileHandle, 5)
										m_temp = m_temp + PADL(ALLT(STR(VAL(cString))),5,SPACE(1)) + " claims"
										cString = FREAD(gnFileHandle, 6)
										m_temp = m_temp + ", "+PADL(ALLT(STR(VAL(cString))),6,SPACE(1)) + " records"
										REPL edt_batch.DATA WITH m_temp
										= FREAD(gnFileHandle, 59)
										= FREAD(gnFileHandle, 2) && LF + CR
										EXIT
									ENDIF
								ENDDO
							ELSE
								REPL edt_batch.DATA WITH "This batch was ACCEPTED"
								DO WHILE .T.
									cString = FREAD(gnFileHandle, 45)
									cString = FREAD(gnFileHandle, 7) && MICRO TYPE
									APPE BLAN
									IF LEN(ALLT(cString))>0 && MICRO TYPE is "HCP/WCB" or "RMB"
										m_temp = SPACE(5) + PADR(cString,7,SPACE(1))+" : "
										m_micro_type=.T.
									ELSE && this is the line with batch totals
										REPL edt_batch.DATA WITH SPACE(5)+REPLICATE("-",7)
										APPE BLAN
										m_temp = SPACE(5) + "Total   : "
										m_micro_type=.F.
									ENDIF
									cString = FREAD(gnFileHandle, 10)
									cString = FREAD(gnFileHandle, 5)
									m_temp = m_temp + PADL(ALLT(STR(VAL(cString))),5,SPACE(1)) + " claim(s)"
									cString = FREAD(gnFileHandle, 6)
									m_batch_total = FREAD(gnFileHandle, 48)
									IF "BATCH" $ m_batch_total && this is the line with batch totals
										m_temp = m_temp + ", "+PADL(ALLT(STR(VAL(cString))),6,SPACE(1)) + " records"
									ENDIF
									REPL edt_batch.DATA WITH m_temp
									IF ("BATCH" $ m_batch_total) AND !m_micro_type && there are 3 records in this file
&& for this batch, i.e. both HCP/WCB
&& and RMB records were in this batch
										= FREAD(gnFileHandle, 11)
										= FREAD(gnFileHandle, 2) && LF + CR
										EXIT
									ELSE
										APPE BLAN
										= FSEEK(gnFileHandle, -92,1)
										cString = FREAD(gnFileHandle, 11) && MICRO START : identifies the first
&& record in the batch
										REPL edt_batch.DATA WITH SPACE(10) + "The first record in the batch is: " + cString
										APPE BLAN
										m_temp = SPACE(10)+"The last record in the batch is:  " + SUBSTR(cString,1,6)
										cString = FREAD(gnFileHandle, 5) && MICRO END : identifies the last
&& record in the batch
										m_temp = m_temp + cString
										REPL edt_batch.DATA WITH m_temp
										cString = FREAD(gnFileHandle, 87)
										cString = FREAD(gnFileHandle, 2) && LF + CR
										IF "BATCH" $ m_batch_total
											EXIT
										ENDIF
									ENDIF
								ENDDO
							ENDIF
							IF m_not_preview
								REPO FORM edt_rep2 TO PRINTER NOCONSOLE
							ELSE
								REPO FORM edt_rep2 PREV
							ENDIF
						ENDDO
						= FCLOSE(gnFileHandle)
						SET SAFETY OFF
						COPY FILE gc_datadrive+"EDT\IN\"+aEDTFiles(i,1) TO gc_datadrive+"BACKUP\EDT\"+aEDTFiles(i,1)
						DELE FILE gc_datadrive+"EDT\IN\"+aEDTFiles(i,1)
						SET SAFETY ON
					ENDIF
				ENDIF
			CASE SUBSTR(UPPER(aEDTFiles(i,1)),1,1)=="E" AND ;
					(LEN(aEDTFiles(i,1)) = 12 OR LEN(aEDTFiles(i,1)) = 10) && EDT Claims Error Report

				* Erick - above code was modified for a conditional statement in the order of execution
				* OR and AND operators will execute at the same time if there is no brackets to separate both conditions

				gnFileHandle = Give_FileHandle(@i)
				IF gnFileHandle > -1
					SELE MD
					IF LEN(aEDTFiles(i,1)) = 12 && health care provider's solo provider number
						LOCA FOR ohipnumber == SUBSTR(aEDTFiles(i,1),3,6)
					ELSE && health care registered group number
						LOCA FOR group_num == SUBSTR(aEDTFiles(i,1),3,4)
					ENDIF
					IF !FOUND()
						= FCLOSE(gnFileHandle)
						RENAME gc_datadrive+"EDT\IN\"+aEDTFiles(i,1) TO gc_datadrive+"EDT\IN\"+;
							SUBSTR(aEDTFiles(i,1),1,AT('.',aEDTFiles(i,1))-1)+"!!!"+;
							SUBSTR(aEDTFiles(i,1),AT('.',aEDTFiles(i,1)))
						LOOP
					ENDIF
					SELE MD
					SET ORDER TO TAG ihfnohip
					SELE edt_expl
					SET SAFETY OFF
					ZAP
					SELE edt_err
					ZAP
					SET SAFETY ON
					fill_table(@gnFileHandle,@i) && local variables passed by reference to UDF
					m_file_name = aEDTFiles(i,1)

					IF m_not_preview
						REPO FORM edt_rep3 TO PRINTER NOCONSOLE
					ELSE
						REPO FORM edt_rep3 PREV
					ENDIF
					= FCLOSE(gnFileHandle)
					SET SAFETY OFF
					COPY FILE gc_datadrive+"EDT\IN\"+aEDTFiles(i,1) TO gc_datadrive+"BACKUP\EDT\"+aEDTFiles(i,1)
					DELE FILE gc_datadrive+"EDT\IN\"+aEDTFiles(i,1)
					SET SAFETY ON
				ENDIF
			CASE SUBSTR(UPPER(aEDTFiles(i,1)),1,1)=="P" AND ;
					(LEN(aEDTFiles(i,1)) = 12 OR LEN(aEDTFiles(i,1)) = 10) && "Do_Ra.prg" will be launched


				SELE MD
				IF LEN(aEDTFiles(i,1)) = 12 && health care provider's solo provider number
					LOCA FOR ohipnumber == SUBSTR(aEDTFiles(i,1),3,6)
				ELSE && health care registered group number
					LOCA FOR group_num == SUBSTR(aEDTFiles(i,1),3,4)
				ENDIF
				IF !FOUND()
					** this should never occur, ONLY if you are running discs belonging to other doctors
					RENAME gc_datadrive+"EDT\IN\"+aEDTFiles(i,1) TO gc_datadrive+"EDT\IN\"+;
						SUBSTR(aEDTFiles(i,1),1,AT('.',aEDTFiles(i,1))-1)+"!!!"+;
						SUBSTR(aEDTFiles(i,1),AT('.',aEDTFiles(i,1)))
					LOOP
				ENDIF


				bRunRa_Report = .T. && run RA error report after loop is finish

				DO do_ra WITH aEDTFiles(i,1)

				DELE FILE gc_datadrive+"EDT\IN\"+aEDTFiles(i,1)
				** "Do_Ra.Prg" was executed and it closed all the tables,
				** so, we have to reopen them.
				USE MD
				USE patients IN 0 ORDER healthnum
				USE ohiperr IN 0 ORDER errorcode
				USE &file_name1 IN 0 ALIAS edt_err EXCL
				USE &file_name2 IN 0 ALIAS edt_batch EXCL
				USE &file_name3 IN 0 ALIAS edt_expl EXCL

				*******************************************************
				*	Modification Performed by David Nantais
				* 	Date : Thursday February 13,2003
				*
				*	This keeps the 'state of the datasession' the same

				SELECT edt_expl
				SET ORDER TO errorcode
				SET RELATION TO errorcode INTO ohiperr

				*
				*
				*	End Of Modification
				********************************************************

		ENDCASE
	ENDFOR
	SELE edt_err
	USE
	file_name1=SUBSTR(ALLT(file_name1),1,LEN(ALLT(file_name1))-3)+'*' && to have all the extensions for this file name. Not only '.dbf', but also '.fpt'
	DELE FILE &file_name1
	SELE edt_batch
	USE
	file_name2=SUBSTR(ALLT(file_name2),1,LEN(ALLT(file_name2))-3)+'*' && to have all the extensions for this file name. Not only '.dbf', but also '.fpt'
	DELE FILE &file_name2
	SELE edt_expl
	SET RELA TO
	USE
	file_name3=SUBSTR(ALLT(file_name3),1,LEN(ALLT(file_name3))-3)+'*' && to have all the extensions for this file name. Not only '.dbf', but also '.fpt'
	DELE FILE &file_name3
	CLOSE TABLES ALL

	* 2003.08.19 - EDT RA_Error and already reconsile Reports
	IF bRunRa_Report
		DO do_ra_report  && 2003.08.19
		DO appe_overpaid
	ENDIF


ENDIF

FUNCTION fill_table
PARAMETER hFile, x
m_md_surname=''
m_md_firstname=''
m_md_mnemonic=''
m_md_spec=''
m_healthno=''
m_process_date=CTOD('')
m_p_surname=''
m_p_firstname=''
m_p_id=0
m_p_version=''
m_p_dob=CTOD('')
m_accntg=0
m_typ=''
m_ref_md=''
m_facil=''
m_admit=''
m_loc=''
m_p_err1=''
m_p_err2=''
m_p_err3=''
m_p_err4=''
m_p_err5=''
m_v_err1=''
m_v_err2=''
m_v_err3=''
m_v_err4=''
m_v_err5=''
m_p_sex=''
m_prov=''

DO WHILE !FEOF(hFile)
	cString = FREAD(hFile, 3)
	DO CASE
		CASE cString == "HX1" && Group/Provider Header Record
			cString = FREAD(hFile, 20) && skip 20 chrs
			cString = FREAD(hFile, 10) && group_num + ohipnumber
			SELE MD
			SEEK cString
			IF !FOUND()
				MESSAGEBOX("The IHFN = "+SUBSTR(cString,1,4)+" and OHIPNUMBER = "+SUBSTR(cString,5,6)+" sent by MOH in "+'"'+aEDTFiles(x,1)+'"'+" file NOT FOUND in MD table !",;
					64,"MOSt Warning !")
				SELE edt_err
				m_md_surname="UNKNOWN"
				m_md_firstname="UNKNOWN"
				m_md_mnemonic=""
			ELSE
				m_md_surname=MD.surname
				m_md_firstname=MD.firstname
				m_md_mnemonic=MD.mnemonic
			ENDIF
			cString = FREAD(hFile, 2) && specialty
			m_md_spec=cString
			cString = FREAD(hFile, 3)
			cString = FREAD(hFile, 8) && claim process date
			IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
				m_process_date = DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
			ENDIF
			cString = FREAD(hFile, 33)
			cString = FREAD(hFile, 2) && LF+CR record delimiter
			SELE edt_err
		CASE cString == "HXH" && Claim Header1 Record
			cString = FREAD(hFile, 10) && Healthcard
			IF VAL(cString)>0
				SELE patients
				SEEK cString
				IF !FOUND()
					SELE edt_err
					m_p_surname="NOT FOUND"
					m_p_firstname="NOT FOUND"
					m_p_id=0
					MESSAGEBOX("The HEALTHCARD "+cString+" sent by MOH in "+'"'+aEDTFiles(x,1)+'"'+" file NOT FOUND in PATIENTS table !",;
						64,"MOSt Warning !")
				ELSE
					m_p_surname=patients.surname
					m_p_firstname=patients.firstname
					m_p_id = patients.ID
				ENDIF
				m_healthno=cString
			ENDIF
			cString = FREAD(hFile, 2) && version
			m_p_version = cString
			cString = FREAD(hFile, 8) && DOB
			IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
				m_p_dob = DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
			ELSE
				m_p_dob = CTOD('')
			ENDIF
			cString = FREAD(hFile, 8) && Accounting
			m_accntg = INT(VAL(cString))
			cString = FREAD(hFile, 3) && Type: HCP,RMB,WCB
			m_typ = cString
			cString = FREAD(hFile, 1) && Payee: P or S
			cString = FREAD(hFile, 6) && Referr_md
			m_ref_md = cString
			cString = FREAD(hFile, 4) && Facility
			m_facil = cString
			cString = FREAD(hFile, 8) && Admit_date
			IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
				m_admit = DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
			ELSE
				m_admit = CTOD('')
			ENDIF
			cString = FREAD(hFile, 4)
			cString = FREAD(hFile, 4) && Location
			m_loc = cString
			cString = FREAD(hFile, 3)
			SELE edt_err
			FOR j=1 TO 5
				cString = FREAD(hFile, 3) && ERRj
				IF LEN(ALLT(cString))>0
					statement="m_p_err"+ALLT(STR(j))+" = "+"cString"
					&statement
				ELSE
					statement="m_p_err"+ALLT(STR(j))+" = "+"''"
					&statement
				ENDIF
			ENDFOR
			cString = FREAD(hFile, 2) && LF+CR record delimiter
			m_p_sex=''
			m_prov=''
		CASE cString == "HXR" && Claim Header2 Record
			* Erick 2003.10.17 - search the health number to get patient info for.
			* RMB claims.  RMB header claims come with a HXH and HXR header records.
			* system stores 10 digits number but newfounland gets 12 digits, so in the patient table
			* we store the rest of the numbers in the version field.  therefore we need to 
			* strip the 12 digit number.
			LOCAL strLen AS STRING
			LOCAL Healh_m_ver as STRING
			LOCAL m_ver AS STRING

			Healh_m_ver = FREAD(hFile, 12) && Healthcard + MOSt version number
			strLen = LEN(ALLTRIM(Healh_m_ver)) && lenght of healh number

			** strip code to check for version number
			IF strLen = 12
				m_ver = RIGHT(ALLTRIM(Healh_m_ver),2)
			ENDIF

			cString = LEFT(Healh_m_ver,10) && health card

			IF VAL(cString)>0
				SELE patients
				SEEK cString
				IF !FOUND()
					SELE edt_err
					m_p_surname="NOT FOUND"
					m_p_firstname="NOT FOUND"
					m_p_id=0
					MESSAGEBOX("The HEALTHCARD "+cString+" sent by MOH in "+'"'+aEDTFiles(x,1)+'"'+" file NOT FOUND in PATIENTS table !",;
						64,"MOSt Warning !")
				ELSE
					* check if it is a 12 healhcard number
					IF strLen = 12
						** check for version number
						IF m_ver = patients.VERSION
							m_p_surname=patients.surname
							m_p_firstname=patients.firstname
							m_p_id = patients.ID
						ELSE
							SELE edt_err
							m_p_surname="NOT FOUND"
							m_p_firstname="NOT FOUND"
							m_p_id=0
							MESSAGEBOX("The HEALTHCARD "+cString+" sent by MOH in "+'"'+aEDTFiles(x,1)+'"'+" file NOT FOUND in PATIENTS table !",;
								64,"MOSt Warning !")
						ENDIF
					ELSE
						m_p_surname=patients.surname
						m_p_firstname=patients.firstname
						m_p_id = patients.ID
					ENDIF

				ENDIF
				m_healthno=cString
			ENDIF

			* Erick - I thinh RMB healh number are 12 digits

			*cString = FREAD(hFile, 12) && Registration #
			*cString = FREAD(hFile, 2) && Registration #
			cString = FREAD(hFile, 9) && Patient's surname
			*m_p_surname = cString
			cString = FREAD(hFile, 5) && Patient's firstname
			*m_p_firstname = cString

			cString = FREAD(hFile, 1) && Sex
			m_p_sex = IIF(cString=='1','M','F')
			cString = FREAD(hFile, 2) && Province
			m_prov = cString
			cString = FREAD(hFile, 32)
			SELE edt_err
			FOR j=1 TO 5
				cString = FREAD(hFile, 3) && ERRj
				IF LEN(ALLT(cString))>0
					statement="m_p_err"+ALLT(STR(j))+" = "+"cString"
					&statement
				ELSE
					statement="m_p_err"+ALLT(STR(j))+" = "+"''"
					&statement
				ENDIF
			ENDFOR
			cString = FREAD(hFile, 2) && LF+CR record delimiter
		CASE cString == "HXT" && Item Record
			APPE BLAN
			REPL edt_err.rec_type WITH cString
			REPL edt_err.md_sur WITH m_md_surname
			REPL edt_err.md_firs WITH m_md_firstname
			REPL edt_err.md_mnemo WITH m_md_mnemonic
			REPL edt_err.specialty WITH m_md_spec
			REPL edt_err.proc_date WITH m_process_date
			REPL edt_err.surname WITH m_p_surname
			REPL edt_err.firstname WITH m_p_firstname
			REPL edt_err.ID WITH m_p_id
			REPL edt_err.healthnum WITH m_healthno
			REPL edt_err.VERSION WITH m_p_version
			REPL edt_err.dob WITH m_p_dob
			REPL edt_err.accounting WITH m_accntg
			REPL edt_err.TYPE WITH m_typ
			REPL edt_err.referr_md WITH m_ref_md
			REPL edt_err.facility WITH m_facil
			REPL edt_err.admit_date WITH m_admit
			REPL edt_err.location WITH m_loc
			REPL edt_err.sex WITH m_p_sex
			REPL edt_err.province WITH m_prov
			cString = FREAD(hFile, 5) && Service
			REPL edt_err.service WITH cString
			cString = FREAD(hFile, 2)
			cString = FREAD(hFile, 6) && Fee_Submited
			REPL edt_err.fee_submit WITH VAL(cString)/100
			cString = FREAD(hFile, 2) && Num_Serv
			REPL edt_err.num_serv WITH INT(VAL(cString))
			cString = FREAD(hFile, 8) && Serv_Date
			IF TYPE("date(val(substr(cString,1,4)),val(substr(cString,5,2)),val(substr(cString,7,2)))")="D"
				REPL edt_err.serv_date WITH DATE(VAL(SUBSTR(cString,1,4)),VAL(SUBSTR(cString,5,2)),VAL(SUBSTR(cString,7,2)))
			ENDIF
			cString = FREAD(hFile, 4) && Diagnosis
			REPL edt_err.diagnosis WITH cString
			cString = FREAD(hFile, 32)
			cString = FREAD(hFile, 2) && Explan Code
			REPL edt_err.expln_code WITH cString
			SELE edt_err
			FOR j=1 TO 5
				cString = FREAD(hFile, 3) && ERRj
				IF LEN(ALLT(cString))>0
					statement="repl edt_err.err"+ALLT(STR(j))+" with "+"cString"
					&statement
					SELE edt_expl
					SEEK cString
					IF !FOUND()
						APPE BLAN
						REPL edt_expl.errorcode WITH cString
						IF !EOF("ohiperr")
							REPL edt_expl.MESSAGE WITH ohiperr.MESSAGE
						ELSE
							REPL edt_expl.MESSAGE WITH "This code was not found in OHIPERR table"
						ENDIF
					ENDIF
					SELE edt_err
				ENDIF
				statement="repl edt_err.p_err"+ALLT(STR(j))+" with "+"m_p_err"+ALLT(STR(j))
				&statement
				SELE edt_expl
				m_errcode = "edt_err.p_err"+ALLT(STR(j))
				SEEK &m_errcode
				IF !FOUND()
					APPE BLAN
					REPL edt_expl.errorcode WITH &m_errcode
					IF !EOF("ohiperr")
						REPL edt_expl.MESSAGE WITH ohiperr.MESSAGE
					ELSE
						REPL edt_expl.MESSAGE WITH "This code was not found in OHIPERR table"
					ENDIF
				ENDIF
				SELE edt_err
			ENDFOR
			cString = FREAD(hFile, 2) && LF+CR record delimiter
		CASE cString == "HX8" && Explanation Code Message Record
			APPE BLAN
			REPL edt_err.rec_type WITH cString
			cString = FREAD(hFile, 2) && Explan Code
			REPL edt_err.expln_code WITH cString
			cString = FREAD(hFile, 55) && Explan Description
			REPL edt_err.MESSAGE WITH cString
			cString = FREAD(hFile, 19)
			cString = FREAD(hFile, 2) && LF+CR record delimiter
			REPL edt_err.md_sur WITH m_md_surname
			REPL edt_err.md_firs WITH m_md_firstname
			REPL edt_err.md_mnemo WITH m_md_mnemonic
			REPL edt_err.specialty WITH m_md_spec
			REPL edt_err.healthnum WITH m_healthno
		OTHERWISE && don't need HX9 because it can be obtained from Edt_Err table
			SELE edt_err
			FOR Y=1 TO 5 && will add 5 blank lines on the report
				APPE BLAN
				REPL edt_err.md_sur WITH m_md_surname
				REPL edt_err.md_firs WITH m_md_firstname
				REPL edt_err.md_mnemo WITH m_md_mnemonic
				REPL edt_err.specialty WITH m_md_spec
				REPL edt_err.healthnum WITH m_healthno
				REPL edt_err.rec_type WITH "HX8" && see explanation below
				REPL edt_err.MESSAGE WITH "."
			ENDFOR
			APPE BLAN
			REPL edt_err.md_sur WITH m_md_surname
			REPL edt_err.md_firs WITH m_md_firstname
			REPL edt_err.md_mnemo WITH m_md_mnemonic
			REPL edt_err.specialty WITH m_md_spec
			REPL edt_err.healthnum WITH m_healthno
			REPL edt_err.rec_type WITH "HX8" && see explanation below
			REPL edt_err.MESSAGE WITH REPLICATE("=",60)
			SELE edt_expl
			SCAN FOR LEN(ALLT(errorcode))>0
				SELE edt_err
				APPE BLAN
				REPL edt_err.md_sur WITH m_md_surname
				REPL edt_err.md_firs WITH m_md_firstname
				REPL edt_err.md_mnemo WITH m_md_mnemonic
				REPL edt_err.specialty WITH m_md_spec
				REPL edt_err.healthnum WITH m_healthno
				REPL edt_err.rec_type WITH "HX8" && the error messages are displayed only for HX8's
&& so, we just take advantage of this to insert
&& in the report, in the same manner, the explanations
&& for error codes.
				REPL edt_err.MESSAGE WITH edt_expl.errorcode + " = " + edt_expl.MESSAGE
				SELE edt_expl
			ENDSCAN
			SET SAFETY OFF
			ZAP
			SET SAFETY ON
			SELE edt_err
			APPE BLAN
			REPL edt_err.md_sur WITH m_md_surname
			REPL edt_err.md_firs WITH m_md_firstname
			REPL edt_err.md_mnemo WITH m_md_mnemonic
			REPL edt_err.specialty WITH m_md_spec
			REPL edt_err.healthnum WITH m_healthno
			REPL edt_err.rec_type WITH "HX8" && see explanation below
			REPL edt_err.MESSAGE WITH REPLICATE("=",60)
			cString = FREAD(hFile, 76)
			cString = FREAD(hFile, 2) && LF+CR record delimiter
	ENDCASE
ENDDO
ENDFUNC

FUNCTION Give_FileHandle
PARAMETER x
hFile = FOPEN(gc_datadrive+"EDT\IN\"+aEDTFiles(x,1))
IF hFile < 0  && Check for error opening file
	MESSAGEBOX("Cannot open "+'"'+aEDTFiles(x,1)+'"'+" file",64,"EDT Claims Error Report")
ELSE
	*** Move the file pointer to BOF ***
	nPos = FSEEK(hFile, 0)
	*** If file pointer is at BOF and EOF, the file is empty ***
	*** Otherwise the file must have something in it ***
	IF FEOF(hFile)
		MESSAGEBOX("The "+'"'+aEDTFiles(x,1)+'"'+" file is empty",64,"EDT Claims Error Report")
		= FCLOSE(hFile)
		hFile = -1
	ENDIF
ENDIF
RETURN hFile
ENDFUNC
