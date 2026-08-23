LOCAL lcLog
lcLog = "E:\MOST for chat\oms_vfp9_build\output\direct_build.log"
SET SAFETY OFF
_GENMENU = "E:\MOST for chat\oms_vfp9_build\genmenu.prg"
ON ERROR DO DirectBuildError WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog
SET DEFAULT TO "E:\MOST for chat\oms_vfp9_build\MOSt"
BUILD EXE "E:\MOST for chat\oms_vfp9_build\output\MOSt_vfp9_test.exe" FROM "most.pjx"
STRTOFILE("Direct build completed" + CHR(13) + CHR(10), lcLog, 0)
ON ERROR
QUIT

PROCEDURE DirectBuildError
    LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
    STRTOFILE("Error " + TRANSFORM(tnError) + ": " + TRANSFORM(tcMessage) + CHR(13) + CHR(10) + ;
        "Code: " + TRANSFORM(tcCode) + CHR(13) + CHR(10) + ;
        "Program: " + TRANSFORM(tcProgram) + ", line " + TRANSFORM(tnLine) + CHR(13) + CHR(10), tcLog, 0)
    ON ERROR
    QUIT
ENDPROC
