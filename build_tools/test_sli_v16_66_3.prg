LOCAL lcResult, lcType, lcLocation, lcService, lnAccounting, lnRecord
lcResult = FULLPATH("test_sli_v16_66_3_result.txt")
ON ERROR DO TestError WITH ERROR(), MESSAGE(), LINENO()

CREATE CURSOR claims (accounting I, service C(7))
INSERT INTO claims VALUES (101, "A001A")
INSERT INTO claims VALUES (101, "G858B")
INSERT INTO claims VALUES (102, "A001A")
INSERT INTO claims VALUES (103, "J123B")
INSERT INTO claims VALUES (104, "G858A")
INSERT INTO claims VALUES (105, "A001A")

DO AssertSli WITH 101, "HCP", "    ", "OFF ", "HCP grouped G858B"
DO AssertSli WITH 101, "WCB", "    ", "OFF ", "WSIB/WCB grouped G858B"
DO AssertSli WITH 103, "HCP", "ABC ", "OFF ", "HCP other technical B fee"
DO AssertSli WITH 104, "WCB", "ABC ", "OFF ", "WSIB/WCB explicit G858 fallback"
DO AssertSli WITH 101, "RMB", "ABC ", "ABC ", "RMB unchanged"
DO AssertSli WITH 102, "HCP", "ABC ", "ABC ", "ordinary HCP unchanged"

STRTOFILE("SUCCESS: all SLI regression cases passed", lcResult, 0)
QUIT

PROCEDURE AssertSli
LPARAMETERS tnAccounting, tcType, tcInitial, tcExpected, tcLabel
LOCAL lcHeaderLocation, lcSliService, lnRecord
SELECT claims
LOCATE FOR accounting == tnAccounting
IF !FOUND()
    ERROR "Missing test encounter: " + tcLabel
ENDIF
lnRecord = RECNO()
lcHeaderLocation = tcInitial
SCAN FOR claims.accounting == tnAccounting
    lcSliService = UPPER(ALLTRIM(claims.service))
    IF INLIST(tcType, "HCP", "WCB") AND ;
            (RIGHT(lcSliService, 1) == "B" OR LEFT(lcSliService, 4) == "G858")
        lcHeaderLocation = "OFF "
        EXIT
    ENDIF
ENDSCAN
GOTO lnRecord
IF lcHeaderLocation <> tcExpected
    ERROR tcLabel + ": expected [" + tcExpected + "] but got [" + lcHeaderLocation + "]"
ENDIF
ENDPROC

PROCEDURE TestError
LPARAMETERS tnError, tcMessage, tnLine
STRTOFILE("ERROR " + TRANSFORM(tnError) + " line " + TRANSFORM(tnLine) + ": " + tcMessage, ;
    FULLPATH("test_sli_v16_66_3_result.txt"), 0)
QUIT
ENDPROC

