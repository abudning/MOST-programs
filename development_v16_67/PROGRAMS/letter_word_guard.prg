LPARAMETERS toWord, tcDocument

* Return values: 0 blocked, 1 opened for editing, 2 activated locally.
LOCAL lcDocument, lcCompare, lcOpenName, loDocument, lnDocument
LOCAL lnHandle, lnOpenError, lcOldError, llReadOnly

IF VARTYPE(toWord)#"O" OR VARTYPE(tcDocument)#"C" OR EMPTY(ALLTRIM(tcDocument))
    RETURN 0
ENDIF

lcDocument=FULLPATH(ALLTRIM(tcDocument))
lcCompare=UPPER(lcDocument)

* If this Word session already has the document, bring that copy forward.
FOR lnDocument=1 TO toWord.Documents.Count
    lcOpenName=""
    lcOldError=ON("ERROR")
    ON ERROR lcOpenName=""
    lcOpenName=FULLPATH(ALLTRIM(toWord.Documents(lnDocument).FullName))
    ON ERROR &lcOldError
    IF UPPER(lcOpenName)==lcCompare
        toWord.Documents(lnDocument).Activate()
        toWord.Visible=.T.
        toWord.Activate()
        RETURN 2
    ENDIF
ENDFOR

* Word on another workstation prevents this exclusive read/write probe.
DECLARE INTEGER CreateFile IN kernel32.dll AS MostCreateFile ;
    STRING lpFileName, INTEGER dwDesiredAccess, INTEGER dwShareMode, ;
    INTEGER lpSecurityAttributes, INTEGER dwCreationDisposition, ;
    INTEGER dwFlagsAndAttributes, INTEGER hTemplateFile
DECLARE INTEGER CloseHandle IN kernel32.dll AS MostCloseHandle INTEGER hObject

lnHandle=MostCreateFile(lcDocument,-1073741824,0,0,3,128,0)
IF lnHandle=-1
    MESSAGEBOX("This document is open on another workstation and cannot be opened at present."+CHR(13)+CHR(13)+;
        "Please close it on the other workstation and try again.",48,"MOSt LetterBuilder")
    RETURN 0
ENDIF
=MostCloseHandle(lnHandle)

* Reset the prior merge only after the document passes the lock test.
lcOldError=ON("ERROR")
lnOpenError=0
ON ERROR lnOpenError=ERROR()
toWord.Run("MOSt.Macro4")
loDocument=toWord.Documents.Open(lcDocument,.F.,.F.)
ON ERROR &lcOldError

IF lnOpenError#0 OR VARTYPE(loDocument)#"O"
    MESSAGEBOX("This document could not be opened for editing."+CHR(13)+CHR(13)+;
        "It may be open on another workstation. Please close it there and try again.",48,"MOSt LetterBuilder")
    RETURN 0
ENDIF

llReadOnly=.F.
lcOldError=ON("ERROR")
ON ERROR llReadOnly=.T.
llReadOnly=loDocument.ReadOnly
ON ERROR &lcOldError
IF llReadOnly
    loDocument.Close(.F.)
    MESSAGEBOX("This document is open on another workstation and cannot be opened at present."+CHR(13)+CHR(13)+;
        "Please close it on the other workstation and try again.",48,"MOSt LetterBuilder")
    RETURN 0
ENDIF

loDocument.Activate()
toWord.Visible=.T.
RETURN 1
