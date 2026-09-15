LPARAMETERS tcPatientsScx
LOCAL lcProps,lcMethods,lcNewMethod
IF VARTYPE(tcPatientsScx)#"C" OR !FILE(tcPatientsScx)
 ERROR "Patients SCX was not supplied"
ENDIF
USE (tcPatientsScx) EXCLUSIVE ALIAS v54patients
SET DELETED ON

* Remove the appended V16.52/V16.53 control record completely.
DELETE FOR UPPER(ALLTRIM(v54patients.objname))=="LETTERSCLAIMS" AND UPPER(ALLTRIM(v54patients.parent))=="PATIENTS"
PACK

* Increase the form by exactly one legacy 24-pixel button row.
LOCATE FOR UPPER(ALLTRIM(v54patients.objname))=="PATIENTS" AND EMPTY(ALLTRIM(v54patients.parent))
IF !FOUND()
 ERROR "Patients form record was not found"
ENDIF
lcProps=v54patients.properties
lcProps=ScxSetProp(lcProps,"Height","440")
lcProps=ScxSetProp(lcProps,"MaxHeight","440")
lcProps=ScxSetProp(lcProps,"MinHeight","440")
REPLACE properties WITH lcProps IN v54patients

* Direct Patients controls.
DO SetPatientButton WITH "cmdHist",364,9,44,24
DO SetPatientButton WITH "third_party",364,53,44,24
DO SetPatientButton WITH "btncapture",364,97,44,24
DO SetPatientButton WITH "cmdprint",364,141,44,24
DO SetPatientButton WITH "cmdReferralPdf",364,185,44,36
DO SetPatientButton WITH "claims",400,185,44,36
DO SetPatientButton WITH "letters",364,273,44,72
DO SetPatientButton WITH "cmdEmr",364,317,44,72
DO SetPatientButton WITH "Command1",364,229,44,72

* Reuse the existing hidden Txtbtns1.cmdPrint control for Letters + Claims.
* No new SCX control record is created.
LOCATE FOR UPPER(ALLTRIM(v54patients.objname))=="TXTBTNS1" AND UPPER(ALLTRIM(v54patients.parent))=="PATIENTS"
IF !FOUND()
 ERROR "Patients navigation button container was not found"
ENDIF
lcProps=v54patients.properties
lcProps=ScxSetProp(lcProps,"Top","388")
lcProps=ScxSetProp(lcProps,"Left","2")
lcProps=ScxSetProp(lcProps,"Width","183")
lcProps=ScxSetProp(lcProps,"Height","48")
lcProps=ScxSetProp(lcProps,"cmdTop.Top","0")
lcProps=ScxSetProp(lcProps,"cmdTop.Left","7")
lcProps=ScxSetProp(lcProps,"cmdTop.Width","44")
lcProps=ScxSetProp(lcProps,"cmdTop.Height","24")
lcProps=ScxSetProp(lcProps,"cmdPrev.Top","24")
lcProps=ScxSetProp(lcProps,"cmdPrev.Left","7")
lcProps=ScxSetProp(lcProps,"cmdPrev.Width","44")
lcProps=ScxSetProp(lcProps,"cmdPrev.Height","24")
lcProps=ScxSetProp(lcProps,"cmdEnd.Top","0")
lcProps=ScxSetProp(lcProps,"cmdEnd.Left","51")
lcProps=ScxSetProp(lcProps,"cmdEnd.Width","44")
lcProps=ScxSetProp(lcProps,"cmdEnd.Height","24")
lcProps=ScxSetProp(lcProps,"cmdNext.Top","24")
lcProps=ScxSetProp(lcProps,"cmdNext.Left","51")
lcProps=ScxSetProp(lcProps,"cmdNext.Width","44")
lcProps=ScxSetProp(lcProps,"cmdNext.Height","24")
lcProps=ScxSetProp(lcProps,"cmdFind.Top","0")
lcProps=ScxSetProp(lcProps,"cmdFind.Left","95")
lcProps=ScxSetProp(lcProps,"cmdFind.Width","44")
lcProps=ScxSetProp(lcProps,"cmdFind.Height","24")
lcProps=ScxSetProp(lcProps,"cmdExit.Top","24")
lcProps=ScxSetProp(lcProps,"cmdExit.Left","95")
lcProps=ScxSetProp(lcProps,"cmdExit.Width","44")
lcProps=ScxSetProp(lcProps,"cmdExit.Height","24")
lcProps=ScxSetProp(lcProps,"cmdExit.Style","0")
lcProps=ScxSetProp(lcProps,"cmdExit.BackColor","160,160,160")
lcProps=ScxSetProp(lcProps,"cmdExit.ForeColor","255,0,0")
lcProps=ScxSetProp(lcProps,"cmdExit.SpecialEffect","0")
lcProps=ScxSetProp(lcProps,"cmdExit.Caption",'"E\<xit"')
lcProps=ScxSetProp(lcProps,"cmdTop.Caption",'"Fi\<rst Pt"')
lcProps=ScxSetProp(lcProps,"cmdEdit.Top","0")
lcProps=ScxSetProp(lcProps,"cmdEdit.Left","139")
lcProps=ScxSetProp(lcProps,"cmdEdit.Width","44")
lcProps=ScxSetProp(lcProps,"cmdEdit.Height","24")
lcProps=ScxSetProp(lcProps,"cmdAdd.Top","24")
lcProps=ScxSetProp(lcProps,"cmdAdd.Left","139")
lcProps=ScxSetProp(lcProps,"cmdAdd.Width","44")
lcProps=ScxSetProp(lcProps,"cmdAdd.Height","24")
lcProps=ScxSetProp(lcProps,"cmdPrint.Visible",".F.")
TEXT TO lcNewMethod NOSHOW
PROCEDURE cmdPrint.Click
* V16.58 THIS LEGACY CONTAINER BUTTON REMAINS HIDDEN
RETURN
ENDPROC
ENDTEXT
lcMethods=ScxReplaceMethod(v54patients.methods,"cmdPrint.Click",lcNewMethod)
REPLACE properties WITH lcProps, methods WITH lcMethods, objcode WITH "", timestamp WITH 0 IN v54patients

* Reuse the existing dormant direct Command1 control for Letters + Claims.
LOCATE FOR UPPER(ALLTRIM(v54patients.objname))=="COMMAND1" AND UPPER(ALLTRIM(v54patients.parent))=="PATIENTS"
IF !FOUND()
 ERROR "Dormant Patients command control was not found"
ENDIF
lcProps=v54patients.properties
lcProps=ScxSetProp(lcProps,"Top","364")
lcProps=ScxSetProp(lcProps,"Left","229")
lcProps=ScxSetProp(lcProps,"Width","44")
lcProps=ScxSetProp(lcProps,"Height","72")
lcProps=ScxSetProp(lcProps,"Caption",'"L +C"')
lcProps=ScxSetProp(lcProps,"WordWrap",".T.")
lcProps=ScxSetProp(lcProps,"FontSize","10")
lcProps=ScxSetProp(lcProps,"FontBold",".T.")
lcProps=ScxSetProp(lcProps,"Style","0")
lcProps=ScxSetProp(lcProps,"Visible",".T.")
lcProps=ScxSetProp(lcProps,"TabIndex","42")
TEXT TO lcNewMethod NOSHOW
PROCEDURE Click
* V16.58 OPEN OR REUSE CLAIMS AND LETTERWRITER FOR THE CURRENT PATIENT
IF THISFORM.error_found()
 RETURN
ENDIF
IF !THISFORM.claims.Enabled OR !THISFORM.letters.Enabled
 RETURN
ENDIF
THISFORM.claims.Click()
DOEVENTS FORCE
THISFORM.letters.Click()
ENDPROC
ENDTEXT
lcMethods=ScxReplaceMethod(v54patients.methods,"Click",lcNewMethod)
REPLACE properties WITH lcProps, methods WITH lcMethods, objcode WITH "", timestamp WITH 0 IN v54patients

USE IN v54patients
RETURN .T.

PROCEDURE SetPatientButton
LPARAMETERS tcObject,tnTop,tnLeft,tnWidth,tnHeight
LOCAL lcButtonProps
LOCATE FOR UPPER(ALLTRIM(v54patients.objname))==UPPER(tcObject) AND UPPER(ALLTRIM(v54patients.parent))=="PATIENTS"
IF !FOUND()
 ERROR "Patients control not found: "+tcObject
ENDIF
lcButtonProps=v54patients.properties
lcButtonProps=ScxSetProp(lcButtonProps,"Top",TRANSFORM(tnTop))
lcButtonProps=ScxSetProp(lcButtonProps,"Left",TRANSFORM(tnLeft))
lcButtonProps=ScxSetProp(lcButtonProps,"Width",TRANSFORM(tnWidth))
lcButtonProps=ScxSetProp(lcButtonProps,"Height",TRANSFORM(tnHeight))
REPLACE properties WITH lcButtonProps IN v54patients
ENDPROC

FUNCTION ScxReplaceMethod
LPARAMETERS tcMethods,tcProcedure,tcNewBlock
LOCAL lnStart,lnRelEnd,lnEnd
lnStart=ATC("PROCEDURE "+tcProcedure,tcMethods)
IF lnStart=0
 ERROR "Patients method was not found: "+tcProcedure
ENDIF
lnRelEnd=ATC("ENDPROC",SUBSTR(tcMethods,lnStart))
IF lnRelEnd=0
 ERROR "Patients method end was not found: "+tcProcedure
ENDIF
lnEnd=lnStart+lnRelEnd+LEN("ENDPROC")-2
RETURN LEFT(tcMethods,lnStart-1)+tcNewBlock+SUBSTR(tcMethods,lnEnd+1)
ENDFUNC

FUNCTION ScxSetProp
LPARAMETERS tcProps,tcName,tcValue
LOCAL lcCRLF,lcMarked,lcNeed,lnAt,lnLine,lnEndRel
lcCRLF=CHR(13)+CHR(10)
lcMarked=lcCRLF+tcProps
lcNeed=lcCRLF+tcName+" = "
lnAt=ATC(lcNeed,lcMarked)
IF lnAt=0
 RETURN tcProps+IIF(EMPTY(tcProps),"",lcCRLF)+tcName+" = "+tcValue
ENDIF
lnLine=lnAt+LEN(lcCRLF)
lnEndRel=AT(lcCRLF,SUBSTR(lcMarked,lnLine))
IF lnEndRel=0
 lcMarked=LEFT(lcMarked,lnLine-1)+tcName+" = "+tcValue
ELSE
 lcMarked=LEFT(lcMarked,lnLine-1)+tcName+" = "+tcValue+SUBSTR(lcMarked,lnLine+lnEndRel-1)
ENDIF
RETURN SUBSTR(lcMarked,LEN(lcCRLF)+1)
ENDFUNC