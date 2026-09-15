CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
SET TALK OFF
SET RESOURCE OFF
LOCAL lcLog, loClaims, loNext, lnPremium, lnSpecial, lcSavedMd
lcLog="C:\Users\abudn\Documents\Codex\2026-09-15\ple\work\v16_61_build\output\claims_regression.log"
ON ERROR DO TestFailed WITH ERROR(),MESSAGE(),LINENO(),lcLog
CREATE CURSOR MD (mnemonic C(4), surname C(30), firstname C(30), payment N(5,2), specialty C(2))
INSERT INTO MD VALUES ('AB','Test','Alpha',100,'25')
INSERT INTO MD VALUES ('CD','Test','Beta',100,'25')
INSERT INTO MD VALUES ('OLD','Test','Inactive',0,'25')
CREATE CURSOR premium (premcode C(5), premrate C(254))
INSERT INTO premium VALUES ('TESTA','{|RATE|RATE * 0.3000}')
loClaims=CREATEOBJECT('ClaimsRegression')
loClaims.BuildBillingMdList()
DO AssertTrue WITH loClaims.billing_md.ListCount=2,'Inactive physician excluded',lcLog
DO AssertTrue WITH EMPTY(loClaims.billing_md.Value),'Initial physician remains blank',lcLog
loClaims.billing_md.Value=loClaims.billing_md.List(1,1)
loClaims.RememberBillingMd()
DO AssertTrue WITH _SCREEN.cMostClaimsBillingMd='AB','First choice cached',lcLog
SELECT MD
GO BOTTOM
loClaims.RememberBillingMd()
DO AssertTrue WITH ALLTRIM(MD.mnemonic)=='AB','MD pointer follows chosen value rather than another cursor',lcLog
loClaims.billing_md.Value=''
loClaims.RestoreBillingMd()
DO AssertTrue WITH ALLTRIM(loClaims.billing_md.Value)=='AB','Reset retains AB',lcLog
loNext=CREATEOBJECT('ClaimsRegression')
loNext.BuildBillingMdList()
DO AssertTrue WITH ALLTRIM(loNext.billing_md.Value)=='AB','Reopened Claims retains AB',lcLog
loNext.billing_md.Value=loNext.billing_md.List(2,1)
loNext.RememberBillingMd()
loClaims.billing_md.Value=''
loClaims.RestoreBillingMd()
DO AssertTrue WITH ALLTRIM(loClaims.billing_md.Value)=='CD','Explicit change replaces remembered physician',lcLog
loClaims.billing_md.Value=''
loClaims.RememberBillingMd()
loNext.BuildBillingMdList()
DO AssertTrue WITH EMPTY(loNext.billing_md.Value),'Explicit blank is not replaced by a default physician',lcLog
_SCREEN.cMostClaimsBillingMd='OLD'
loNext.BuildBillingMdList()
DO AssertTrue WITH EMPTY(loNext.billing_md.Value),'Inactive cached physician is not restored',lcLog
_SCREEN.cMostClaimsBillingMd=''
loNext.radiology=1
loNext.BuildBillingMdList()
DO AssertTrue WITH loNext.billing_md.Value='**','Radiology unknown default retained',lcLog

SELECT premium
GO TOP
lnPremium=loClaims.fee_for_premium(100)
DO AssertTrue WITH lnPremium=30,'Thirty percent premium of 100 is 30',lcLog
loClaims.StoreAdditionalFee(1,1,m.lnPremium,.F.)
DO AssertTrue WITH loClaims.apremium1[1,2]=30,'Premium array retains numeric amount',lcLog
DO AssertTrue WITH loClaims.premium_fee1=30,'Premium state retains numeric amount',lcLog
DO AssertTrue WITH loClaims.lbl_fee_prem.Caption='$ 30.00','Displayed premium amount is 30.00',lcLog
DO AssertTrue WITH VAL(loClaims.lbl_fee_prem.Caption)=0,'Reproduces old currency-caption parsing failure',lcLog
loClaims.StoreAdditionalFee(1,1,loClaims.fee_for_premium(123.45),.F.)
DO AssertTrue WITH loClaims.apremium1[1,2]=37.04,'Percentage premium keeps cents',lcLog
REPLACE premium.premrate WITH '{||17.85}'
lnSpecial=loClaims.fee_for_premium(123.45)
loClaims.StoreAdditionalFee(1,1,m.lnSpecial,.T.)
DO AssertTrue WITH loClaims.aspec_visit1[1,2]=17.85,'Fixed special visit amount keeps cents',lcLog
DO AssertTrue WITH loClaims.sv_fee1=17.85,'Special visit state remains numeric',lcLog
REPLACE premium.premrate WITH '{|numserv|numserv * 10.20 * 0.7500}'
loClaims.StoreAdditionalFee(1,1,loClaims.fee_for_premium(3),.F.)
DO AssertTrue WITH loClaims.apremium1[1,2]=22.95,'B/C unit-based premium retained',lcLog
* Simulate the existing save code writing array values and selected physician.
CREATE CURSOR savedclaim (service C(5), fee_submited N(10,2), billing_md C(4))
INSERT INTO savedclaim VALUES ('BASEA',123.45,'AB')
INSERT INTO savedclaim VALUES ('PREMA',loClaims.apremium1[1,2],'AB')
INSERT INTO savedclaim VALUES ('VISITA',loClaims.aspec_visit1[1,2],'AB')
GO TOP
DO AssertTrue WITH savedclaim.fee_submited=123.45,'Base claim amount is unchanged',lcLog
SKIP
DO AssertTrue WITH savedclaim.fee_submited=22.95,'Saved premium is not zero',lcLog
SKIP
DO AssertTrue WITH savedclaim.fee_submited=17.85,'Saved special visit is not zero',lcLog
STRTOFILE('PASS: Claims fee storage and billing-MD regression checks'+CHR(13)+CHR(10),lcLog,0)
ON ERROR
QUIT

PROCEDURE AssertTrue
LPARAMETERS tlCondition,tcDescription,tcLog
IF !m.tlCondition
 STRTOFILE('FAIL: '+m.tcDescription+CHR(13)+CHR(10),m.tcLog,0)
 ON ERROR
 QUIT
ENDIF
ENDPROC
PROCEDURE TestFailed
LPARAMETERS tnError,tcMessage,tnLine,tcLog
STRTOFILE('ERROR '+TRANSFORM(tnError)+' '+m.tcMessage+' line '+TRANSFORM(m.tnLine)+CHR(13)+CHR(10),m.tcLog,0)
ON ERROR
QUIT
ENDPROC

DEFINE CLASS ClaimsRegression AS Form
radiology=0
premium_fee1=0
sv_fee1=0
DIMENSION apremium1[1,4]
DIMENSION aspec_visit1[1,2]
ADD OBJECT billing_md AS ComboBox WITH RowSourceType=1, ColumnCount=3, BoundColumn=1, BoundTo=.T., Style=2, Value=''
ADD OBJECT lbl_fee_prem AS Label WITH Caption=''
ADD OBJECT lbl_fee_spec AS Label WITH Caption=''

PROCEDURE StoreAdditionalFee
LPARAMETERS tnClaim, tnRow, tnAmount, tlSpecialVisit
LOCAL lcClaim, lnAmount
lcClaim=ALLTRIM(STR(m.tnClaim))
lnAmount=ROUND(m.tnAmount,2)
IF m.tlSpecialVisit
    THIS.sv_fee&lcClaim=m.lnAmount
    THIS.aspec_visit&lcClaim[m.tnRow,2]=m.lnAmount
    THIS.lbl_fee_spec.Caption='$ '+ALLTRIM(STR(m.lnAmount,12,2))
ELSE
    THIS.premium_fee&lcClaim=m.lnAmount
    THIS.apremium&lcClaim[m.tnRow,2]=m.lnAmount
    THIS.lbl_fee_prem.Caption='$ '+ALLTRIM(STR(m.lnAmount,12,2))
ENDIF
RETURN m.lnAmount
ENDPROC

PROCEDURE BuildBillingMdList
LOCAL lnArea, lnRecord, lnRow, llUnknown
lnArea=SELECT()
lnRecord=RECNO('MD')
THIS.billing_md.RowSource=''
THIS.billing_md.RowSourceType=1
THIS.billing_md.BoundColumn=1
THIS.billing_md.BoundTo=.T.
THIS.billing_md.Clear()
THIS.billing_md.Value=''
llUnknown=.F.
SELECT MD
SCAN FOR MD.payment<>0 OR THIS.radiology=1
    lnRow=THIS.billing_md.ListCount+1
    THIS.billing_md.AddItem(MD.mnemonic,m.lnRow,1)
    THIS.billing_md.List(m.lnRow,2)=ALLTRIM(MD.surname)
    THIS.billing_md.List(m.lnRow,3)=ALLTRIM(MD.firstname)
    IF ALLTRIM(MD.mnemonic)=='**'
        llUnknown=.T.
    ENDIF
ENDSCAN
IF THIS.radiology=1
    IF !m.llUnknown
        lnRow=THIS.billing_md.ListCount+1
        THIS.billing_md.AddItem('**',m.lnRow,1)
        THIS.billing_md.List(m.lnRow,2)='MD'
        THIS.billing_md.List(m.lnRow,3)='Unknown'
    ENDIF
    THIS.billing_md.Value='**'
ENDIF
IF m.lnRecord>0 AND m.lnRecord<=RECCOUNT('MD')
    GO m.lnRecord IN MD
ENDIF
SELECT (m.lnArea)
THIS.RestoreBillingMd()
RETURN .T.
ENDPROC

PROCEDURE RememberBillingMd
LOCAL lcMd, lnArea
lcMd=ALLTRIM(TRANSFORM(THIS.billing_md.Value))
IF !PEMSTATUS(_SCREEN,'cMostClaimsBillingMd',5)
    _SCREEN.AddProperty('cMostClaimsBillingMd','')
ENDIF
IF EMPTY(m.lcMd)
    _SCREEN.cMostClaimsBillingMd=''
    RETURN .T.
ENDIF
lnArea=SELECT()
SELECT MD
LOCATE FOR ALLTRIM(MD.mnemonic)==m.lcMd AND (MD.payment<>0 OR THIS.radiology=1)
IF FOUND() OR (THIS.radiology=1 AND m.lcMd=='**')
    _SCREEN.cMostClaimsBillingMd=m.lcMd
    SELECT (m.lnArea)
    RETURN .T.
ENDIF
SELECT (m.lnArea)
RETURN .F.
ENDPROC

PROCEDURE RestoreBillingMd
LOCAL lcMd, lnRow
IF !PEMSTATUS(_SCREEN,'cMostClaimsBillingMd',5)
    RETURN .F.
ENDIF
lcMd=_SCREEN.cMostClaimsBillingMd
IF EMPTY(m.lcMd)
    RETURN .F.
ENDIF
FOR lnRow=1 TO THIS.billing_md.ListCount
    IF ALLTRIM(TRANSFORM(THIS.billing_md.List(m.lnRow,1)))==m.lcMd
        THIS.billing_md.Value=THIS.billing_md.List(m.lnRow,1)
        THIS.RememberBillingMd()
        THIS.billing_md.Refresh()
        RETURN .T.
    ENDIF
ENDFOR
RETURN .F.
ENDPROC

PROCEDURE fee_for_premium
** Computes the fee for the special service code, according to the macro
** from Premium.Premrate field. In these macros, in some places, IF statement
** is incorrectly used in place of IIF. This has to be corrrected.

PARAMETER fee_submit && i.e. fee_submited for the original claim

b=AT('|',premrate,1)
F=AT('|',premrate,2)


IF b*F=0
	MESSAGEBOX('ERROR in Premium.Premrate field !',16,'MOSt Error !!!')
	RETURN 0
ENDIF
IF F=b+1
	fee=VAL(CHRTRAN(SUBSTR(premrate,F+1),'}',''))
ELSE
	m_var=SUBSTR(premrate,b+1,F-b-1)+"=fee_submit"
	&m_var
	IF SUBSTR(premrate,F+1,1)$'*+'
		m_cmd="fee="+SUBSTR(premrate,b+1,F-b-1)+CHRTRAN(SUBSTR(premrate,F+1),'}','')
	ELSE
		m_cmd="fee="+CHRTRAN(SUBSTR(premrate,F+1),'}','')
	ENDIF
	&m_cmd
ENDIF
RETURN fee

ENDPROC
ENDDEFINE

