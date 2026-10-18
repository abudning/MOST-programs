SET SAFETY OFF
SET TALK OFF
SET RESOURCE OFF
LOCAL lcRepo,lcOut,lcLog,lcSource
lcRepo=ADDBS(JUSTPATH(JUSTPATH(SYS(16))))
lcOut=lcRepo+"..\outputs\v16_67_1_compile\"
lcLog=lcOut+"compile.log"
IF !DIRECTORY(lcOut)
    MD (lcOut)
ENDIF
ON ERROR DO CompileFailed WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(),lcLog
STRTOFILE("START"+CHR(13)+CHR(10),lcLog,0)
lcSource=lcRepo+"development_v16_67\PROGRAMS\"
COPY FILE (lcSource+"consult_letter.prg") TO (lcOut+"consult_letter.prg")
COPY FILE (lcSource+"openletterwriter.prg") TO (lcOut+"openletterwriter.prg")
COMPILE (lcOut+"consult_letter.prg")
COMPILE (lcOut+"openletterwriter.prg")
IF !FILE(lcOut+"consult_letter.fxp") OR !FILE(lcOut+"openletterwriter.fxp")
    ERROR "Expected compiled program files were not created."
ENDIF
STRTOFILE("SUCCESS V16.67.1 consultation source"+CHR(13)+CHR(10),lcLog,1)
ON ERROR
QUIT

PROCEDURE CompileFailed
LPARAMETERS tnError,tcMessage,tcCode,tcProgram,tnLine,tcLog
STRTOFILE("ERROR "+TRANSFORM(tnError)+" "+tcMessage+" | "+tcProgram+" | line "+TRANSFORM(tnLine)+CHR(13)+CHR(10)+tcCode+CHR(13)+CHR(10),tcLog,0)
ON ERROR
QUIT
ENDPROC
