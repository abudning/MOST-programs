FUNCTION MostOpenHelp
LOCAL lcHelpFile,lnResult

lcHelpFile=gc_localapp+"MOSt.chm"
IF !FILE(lcHelpFile)
    MESSAGEBOX("MOSt.chm was not found in:"+CHR(13)+gc_localapp,16,"MOSt Help")
    RETURN .F.
ENDIF

DECLARE INTEGER ShellExecute IN shell32.dll ;
    INTEGER hwnd, STRING lpOperation, STRING lpFile, ;
    STRING lpParameters, STRING lpDirectory, INTEGER nShowCmd
lnResult=ShellExecute(0,"open",lcHelpFile,"",gc_localapp,1)
IF lnResult<=32
    MESSAGEBOX("Windows could not open the MOSt help file."+CHR(13)+;
        "File: "+lcHelpFile+CHR(13)+;
        "Windows result: "+TRANSFORM(lnResult),16,"MOSt Help")
    RETURN .F.
ENDIF

RETURN .T.
ENDFUNC
