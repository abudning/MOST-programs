LOCAL lcLog
lcLog = "E:\MOST for chat\oms_vfp9_build\output\direct_build_v14.log"
SET SAFETY OFF
_GENMENU = "E:\MOST for chat\oms_vfp9_build\genmenu.prg"
ON ERROR DO DirectBuildError WITH ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO(), lcLog
SET DEFAULT TO "E:\MOST for chat\oms_vfp9_build\MOSt"
BUILD EXE "E:\MOST for chat\oms_vfp9_build\output\MOST_V14_TEST.exe" FROM "most.pjx" RECOMPILE
STRTOFILE("SUCCESS: forced recompile V14 build completed" + CHR(13) + CHR(10), lcLog, 0)
ON ERROR
QUIT

PROCEDURE DirectBuildError
    LPARAMETERS tnError, tcMessage, tcCode, tcProgram, tnLine, tcLog
    STRTOFILE("FAILED: Error " + TRANSFORM(tnError) + ": " + TRANSFORM(tcMessage) + CHR(13) + CHR(10) + ;
        "Code: " + TRANSFORM(tcCode) + CHR(13) + CHR(10) + ;
        "Program: " + TRANSFORM(tcProgram) + ", line " + TRANSFORM(tnLine) + CHR(13) + CHR(10), tcLog, 0)
    ON ERROR
    QUIT
ENDPROC
