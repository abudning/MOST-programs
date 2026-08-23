LOCAL lcScriptDir, lcSourceDir, lcOutputDir, lcExe, lcLog, llBuilt

lcScriptDir = ADDBS(JUSTPATH(SYS(16)))
lcSourceDir = ADDBS(lcScriptDir + "MOSt")
lcOutputDir = ADDBS(lcScriptDir + "output")
lcExe = lcOutputDir + "MOSt_vfp9_test.exe"
lcLog = lcOutputDir + "build.log"

SET SAFETY OFF
SET TALK OFF
SET ECHO OFF
SET NOTIFY OFF
SET EXCLUSIVE OFF

IF !DIRECTORY(lcOutputDir)
    MD (lcOutputDir)
ENDIF

STRTOFILE("Build started: " + TTOC(DATETIME(), 1) + CHR(13) + CHR(10), lcLog, 0)
ON ERROR DO BuildFailed WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog

SET DEFAULT TO (lcSourceDir)
MODIFY PROJECT "most.pjx" NOWAIT
llBuilt = _VFP.ActiveProject.Build(lcExe, 3, .T., .T.)
_VFP.ActiveProject.Close()

STRTOFILE("Build returned: " + TRANSFORM(llBuilt) + CHR(13) + CHR(10), lcLog, 1)
STRTOFILE("Build completed: " + TTOC(DATETIME(), 1) + CHR(13) + CHR(10), lcLog, 1)
ON ERROR
QUIT

PROCEDURE BuildFailed
    LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
    LOCAL lcFailure
    lcFailure = "BUILD FAILED" + CHR(13) + CHR(10) + ;
        "Error: " + TRANSFORM(tnError) + CHR(13) + CHR(10) + ;
        "Message: " + TRANSFORM(tcMessage) + CHR(13) + CHR(10) + ;
        "Code: " + TRANSFORM(tcCode) + CHR(13) + CHR(10) + ;
        "Program: " + TRANSFORM(tcProgram) + CHR(13) + CHR(10) + ;
        "Line: " + TRANSFORM(tnLine) + CHR(13) + CHR(10)
    STRTOFILE(lcFailure, tcLog, 1)
    ON ERROR
    QUIT
ENDPROC
