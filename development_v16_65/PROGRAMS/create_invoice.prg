* creates the data file for the invoice program report
PARAMETER  patientid
SET PROCEDURE TO thirdparty_store ADDITIVE
LOCAL lnTpCount
SELECT claims
COUNT FOR id=m.patientid AND type=="T" TO lnTpCount
IF lnTpCount=0
 MESSAGEBOX("There are no outstanding third party bills for this patient.",64,"Third Party Billing")
 RETURN
ENDIF
PUBLIC m_flag_variable && 1 for "Accept Payment" and 2 for "Exit"
m_flag_variable=0
LOCAL m_guarantor_id
m_guarantor_id=""

DO WHILE m_flag_variable<>2
	m_pay=SPACE(10)
	file_nm=  uniqfile() && get  unique alias
	temp_dir=SYS(2023)   && temporary directory (independant of OS ie c:\temp for NT, c:\windows\temp for 95/98)
	file_name= temp_dir + "\"+ file_nm  && temp file name to hold data from &dummy
	SELECT serv_date,service,num_serv,billing_md,fee_submited,;
		fee_paid,STATUS,ID,guarantor,RECNO() AS rec_no FROM claims WHERE claims.ID=patientid;
		.AND. claims.TYPE=='T' INTO DBF (file_name)  ORDER BY 4,1
	ALTER TABLE &file_name..DBF ADD feedesc C(45)
	ALTER TABLE &file_name..DBF ADD balance N(8,2)
	ALTER TABLE &file_name..DBF ADD service1 C(5)
	ALTER TABLE &file_name..DBF ADD surname C(30)
	ALTER TABLE &file_name..DBF ADD firstname C(20)
	ALTER TABLE &file_name..DBF ADD address C(35)
&& djg 3 new
	ALTER TABLE &file_name..DBF ADD city C(20)
	ALTER TABLE &file_name..DBF ADD prov C(20)
	ALTER TABLE &file_name..DBF ADD md_prov C(20)
	ALTER TABLE &file_name..DBF ADD postal C(6)
	ALTER TABLE &file_name..DBF ADD phone_home C(12)
	ALTER TABLE &file_name..DBF ADD md_firs C(15)
	ALTER TABLE &file_name..DBF ADD md_surn C(25)
	ALTER TABLE &file_name..DBF ADD md_phone_w C(12)
	ALTER TABLE &file_name..DBF ADD md_phone_h C(12)
	ALTER TABLE &file_name..DBF ADD md_address C(35)
	ALTER TABLE &file_name..DBF ADD md_city C(12)
	ALTER TABLE &file_name..DBF ADD md_postal C(7)
	ALTER TABLE &file_name..DBF ADD mnemonic C(2)
	ALTER TABLE &file_name..DBF ADD selections L
	* Guarantor
	ALTER TABLE &file_name..DBF ADD glname C(20)
	ALTER TABLE &file_name..DBF ADD gfname C(12)
	ALTER TABLE &file_name..DBF ADD ginstitutn C(40)
	ALTER TABLE &file_name..DBF ADD gaddress C(35)
	ALTER TABLE &file_name..DBF ADD gcity C(20)
	ALTER TABLE &file_name..DBF ADD gpostal C(6)
	ALTER TABLE &file_name..DBF ADD gphone C(10)
	** 2004.02.17 - Erick new fields to hold country and prov_state
	ALTER TABLE &file_name..DBF ADD gprov C(35)
	ALTER TABLE &file_name..DBF ADD gcountry C(35)

	*  Alter table &file_name..dbf add status C(5)
	USE &file_name..DBF ALIAS invoice EXCLUSIVE
	SELE invoice
	REPLACE ALL mnemonic WITH billing_md
	REPLACE ALL service1 WITH service
	REPLACE ALL service WITH SUBSTR(service,1,4)
	REPLACE ALL surname WITH patients.surname
	REPLACE ALL firstname WITH patients.firstname
	REPLACE ALL address WITH patients.address
&& djg 2 new
	REPLACE ALL city WITH patients.city
	REPLACE ALL prov WITH patients.province
	REPLACE ALL md_prov WITH 'ON'
	REPLACE ALL postal WITH patients.postal
	REPLACE ALL phone_home WITH patients.phone_home
	ALTER TABLE &file_name..DBF ALTER service C(4)
	ALTER TABLE &file_name..DBF ALTER STATUS C(6)
	ALTER TABLE &file_name..DBF ALTER fee_submit N(8,2)
	ALTER TABLE &file_name..DBF ALTER fee_paid N(8,2)
	SELE fees
	SET ORDER TO service
	SELE invoice
	SET RELATION TO service INTO fees
	GO TOP
	DO WHILE !EOF()
		REPLACE invoice.feedesc WITH TpDescription(invoice.guarantor,fees.feedesc)
		SKIP 1
	ENDDO
	SELE invoice
	SET RELA TO

	SELE guarantor
	SET ORDER TO TAG ID
	SELE invoice
	SET RELATION TO guarantor INTO guarantor
	GO TOP
	DO WHILE !EOF()
		REPLACE invoice.glname WITH guarantor.lname
		REPLACE invoice.gfname WITH guarantor.fname
		REPLACE invoice.ginstitutn WITH guarantor.institutn
		REPLACE invoice.gaddress WITH guarantor.address
		REPLACE invoice.gcity WITH guarantor.city
		REPLACE invoice.gpostal WITH guarantor.postal
		REPLACE invoice.gphone WITH guarantor.phone_main

		REPLACE invoice.gprov WITH guarantor.prov_state
		REPLACE invoice.gcountry WITH guarantor.country

		SKIP 1
	ENDDO
	SELE invoice
	SET RELA TO

	SELE MD
	SET ORDER TO mnemonic
	SELE invoice
	SET RELATION TO mnemonic INTO MD
	GO TOP
	DO WHILE !EOF()
		REPLACE invoice.md_firs WITH MD.firstname
		REPLACE invoice.md_surn WITH MD.surname
		REPLACE invoice.md_phone_w WITH MD.phone_work
		REPLACE invoice.md_phone_h WITH MD.phone_home
		REPLACE invoice.md_address WITH MD.address
		REPLACE invoice.md_city WITH MD.city
		REPLACE invoice.md_postal WITH MD.postal
		SKIP 1
	ENDDO
	SELE invoice
	SET RELA TO
	*Index on billing_md tag md
	*Set order to tag md

	DO FORM invoice &&to m_guarantor_id
	IF m_flag_variable=1
		DO FORM enter_payment TO m_pay
		m_payment=VAL(SUBSTR(m_pay,3,8))
		m_status=ALLTRIM(SUBSTR(m_pay,11,5))
		* accept payments  for 1 doc or all docs **
		IF m_payment<>0
			SELE claims
			SET ORDER TO
			SET FILTER TO
			*If substr(m_pay,1,2)=='**'
			*   Set filter to
			*   Set filter to claims.id=patientid;
			*      .and. claims.type=='T'
			*Else
			*   Set filter to
			*   Set filter to claims.id=patientid;
			*      .and. claims.type=='T' .and. claims.billing_md==;
			*      substr(m_pay,1,2)
			*Endif
			SELE invoice
			LOCA FOR invoice.selections=.T.
			IF !FOUND()
				MESSAGEBOX("Error in Create_Invoice.prg !",64,"MOSt Warning !")
				USE
				SELE claims
				DELE FILE &file_name..*
				RETURN
			ENDIF
			m_guarantor_id = invoice.guarantor
			SET FILTER TO guarantor = m_guarantor_id
			INDEX ON IIF(selections,"0","1")+billing_md+DTOS(serv_date) TAG pay_gt0 && payment > 0
			INDEX ON IIF(selections,"1","0")+billing_md+DTOS(serv_date) TAG pay_lt0 && payment < 0
			*        Suspend
			DO CASE
				CASE m_payment>0
					SET ORDER TO TAG pay_gt0
					GO TOP
					DO WHILE !EOF()
						SELE claims
						GOTO invoice.rec_no
						SELE invoice
						IF (claims.fee_paid)==(claims.fee_submited)
							SKIP 1
						ELSE
							IF (claims.fee_submited)-(claims.fee_paid)<=m_payment
								m_payment=m_payment-(claims.fee_submited)+(claims.fee_paid)
								REPLACE claims.fee_paid WITH (claims.fee_submited)
								REPLACE claims.STATUS WITH M_status
								REPL claims.guarantor WITH m_guarantor_id
								SKIP 1
							ELSE
								REPLACE claims.fee_paid WITH (claims.fee_paid)+m_payment
								REPLACE claims.STATUS WITH M_status
								REPL claims.guarantor WITH m_guarantor_id
								m_payment=0
								EXIT
							ENDIF
						ENDIF
					ENDDO

					* accept negative payments where overpaid but still active.
				CASE m_payment<0
					SET ORDER TO TAG pay_lt0
					GO BOTTOM
					DO WHILE !BOF()
						*djg added to handle negative amounts
						SELE claims
						GOTO invoice.rec_no
						SELE invoice
						IF claims.fee_submited < 0
							* all paid.
							IF claims.fee_submited - claims.fee_paid = 0
								SKIP -1
							ELSE
								IF claims.fee_submited-claims.fee_paid >  m_payment
									m_payment=m_payment-(claims.fee_submited)+(claims.fee_paid)
									REPLACE claims.fee_paid WITH (claims.fee_submited)
									REPLACE claims.STATUS WITH M_status
									REPL claims.guarantor WITH m_guarantor_id
									SKIP -1
								ELSE
									REPLACE claims.fee_paid WITH (claims.fee_paid)+m_payment
									REPLACE claims.STATUS WITH M_status
									REPL claims.guarantor WITH m_guarantor_id
									m_payment=0
									EXIT
								ENDIF
							ENDIF
						ELSE
							* end of add
							IF (claims.fee_paid)==0
								SKIP -1
							ELSE
								IF (claims.fee_paid)+m_payment<0
									m_payment=m_payment+(claims.fee_paid)
									REPLACE claims.fee_paid WITH 0
									REPLACE claims.STATUS WITH M_status
									REPL claims.guarantor WITH m_guarantor_id
									SKIP -1
								ELSE
									REPLACE claims.fee_paid WITH (claims.fee_paid)+m_payment
									REPLACE claims.STATUS WITH M_status
									REPL claims.guarantor WITH m_guarantor_id
									m_payment=0
									EXIT
								ENDIF
							ENDIF
						ENDIF
					ENDDO
			ENDCASE
			SELE claims
			REPL FOR ISNULL(claims.guarantor) guarantor WITH 0
			BEGIN TRANSACTION
			m_tsuccess=TABLEUPDATE(.T.,.F.,"claims")
			IF m_tsuccess
				END TRANSACTION
			ELSE
				ROLLBACK
				TABLEREVERT(.T.)
				=MESSAGEBOX('These claims were modified by another user'+CHR(13)+;
					'Payment not accepted. Try again !',16,'MOSt Warning')
				LOOP
			ENDIF
		ENDIF && if m_payment<>0
	ELSE && if m_flag_variable=1
		**djg***I think first time through we assign accounting numbers*******
		SELE claims
		SET FILTER TO
		SET FILTER TO claims.ID=patientid;
			.AND. claims.TYPE=='T' .AND. claims.fee_submited=claims.fee_paid
		COUN TO m_nr
		IF m_nr>0
			********
			SELECT PARAMETER
			GOTO 2  && get next accounting number  (must be at least 1  and must be next free number
			next_accnt_num = PARAMETER.DATA
			SELECT claims
			GO TOP
			DO WHILE !EOF()
				SCATTER MEMVAR
				SELE submited
				APPEND BLANK
				GATHER MEMVAR
				REPLACE accounting WITH next_accnt_num
				next_accnt_num = next_accnt_num + 1
				SELECT PARAMETER
				REPLACE PARAMETER.DATA WITH next_accnt_num   && update accounting number
				SELECT claims
				SKIP 1
			ENDDO
			********
			SELE claims
			GO TOP
			DO WHILE !EOF()
				REPLACE claims.ID WITH 0
				REPLACE claims.service WITH SPACE(5)
				SKIP 1
			ENDDO
			SELE submited
			BEGIN TRANSACTION
			m_tsuccess1=TABLEUPDATE(.T.,.F.)
			SELE claims
			SET FILTER TO
			REPL FOR ISNULL(claims.guarantor) guarantor WITH 0
			BEGIN TRANSACTION
			m_tsuccess2=TABLEUPDATE(.T.,.F.)
			SELE PARAMETER
			BEGIN TRANSACTION
			m_tsuccess3=TABLEUPDATE(.T.,.F.)
			IF m_tsuccess1 .AND. m_tsuccess2 .AND. m_tsuccess3
				SELE submited
				END TRANSACTION
				SELE claims
				END TRANSACTION
				SELE PARAMETER
				END TRANSACTION
			ELSE
				SELE submited
				ROLLBACK
				SELE claims
				ROLLBACK
				SELE PARAMETER
				ROLLBACK
				SELE submited
				TABLEREVERT(.T.)
				SELE claims
				TABLEREVERT(.T.)
				SELE PARAMETER
				TABLEREVERT(.T.)
				=MESSAGEBOX('   Transaction error !! '+CHR(13)+;
					'Payment was accepted, '+CHR(13)+;
					'but, the third party claims '+CHR(13)+;
					' could not be submited '+CHR(13)+CHR(13)+'(Notify MBT Software)!',16,'MOSt Warning')
			ENDIF
		ELSE
			SELE claims
			SET FILTER TO
			REPL FOR ISNULL(claims.guarantor) guarantor WITH 0
			BEGIN TRANSACTION
			m_tsuccess=TABLEUPDATE(.T.,.F.,"claims")
			IF m_tsuccess
				END TRANSACTION
			ELSE
				ROLLBACK
				TABLEREVERT(.T.)
				=MESSAGEBOX('These claims were modified by another user'+CHR(13)+;
					'Payment not accepted. Try again !',16,'MOSt Warning')
				SELE invoice
				USE
				DELE FILE &file_name..*
			ENDIF
		ENDIF
		***********************
&&      Thisform.visible=.t.
		EXIT
	ENDIF
	SELE claims
	SET FILTER TO
	SET ORDER TO
	SELE invoice
	SET FILTER TO
	SCAN ALL
		SELE claims
		GOTO invoice.rec_no
		REPL claims.guarantor WITH invoice.guarantor
	ENDSCAN
	BEGIN TRANSACTION
	m_tsuccess=TABLEUPDATE(.T.,.F.,"claims")
	IF m_tsuccess
		END TRANSACTION
	ELSE
		ROLLBACK
		TABLEREVERT(.T.)
		=MESSAGEBOX('These claims were modified by another user'+CHR(13)+;
			'Payment not accepted. Try again !',16,'MOSt Warning')
	ENDIF
	SELE invoice
	USE
	SELE claims
	DELE FILE &file_name..*
ENDDO && do while m_flag_variable<>2
RELEASE m_flag_variable
