CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
LOCAL lcRoot,lnFiles,lnI,lcMethods,lcBlock,lnStart,lnLineEnd,lnPatched
LOCAL ARRAY laFiles[1]
lcRoot="E:\MOST for chat\oms_vfp9_build\MOSt\FORMS\"
lnPatched=0
lnFiles=ADIR(laFiles,lcRoot+"*.scx")
lcBlock="SET TALK OFF"+CHR(13)+CHR(10)+"SET ECHO OFF"+CHR(13)+CHR(10)+"SET CONSOLE OFF"+CHR(13)+CHR(10)+"SET STATUS OFF"+CHR(13)+CHR(10)+"SET STATUS BAR OFF"+CHR(13)+CHR(10)
FOR lnI=1 TO lnFiles
 USE (lcRoot+laFiles[lnI,1]) EXCLUSIVE ALIAS p49
 LOCATE FOR LOWER(ALLTRIM(p49.baseclass))=="dataenvironment"
 IF FOUND()
  lcMethods=p49.methods
  IF !("V16.49 SUPPRESS FORM DATA OUTPUT" $ lcMethods)
   lnStart=ATC("PROCEDURE BeforeOpenTables",lcMethods)
   IF lnStart>0
    lnLineEnd=AT(CHR(10),SUBSTR(lcMethods,lnStart))
    lcMethods=LEFT(lcMethods,lnStart+lnLineEnd-1)+"* V16.49 SUPPRESS FORM DATA OUTPUT"+CHR(13)+CHR(10)+lcBlock+SUBSTR(lcMethods,lnStart+lnLineEnd)
   ELSE
    lcMethods=lcMethods+CHR(13)+CHR(10)+"PROCEDURE BeforeOpenTables"+CHR(13)+CHR(10)+"* V16.49 SUPPRESS FORM DATA OUTPUT"+CHR(13)+CHR(10)+lcBlock+"ENDPROC"+CHR(13)+CHR(10)
   ENDIF
   REPLACE p49.methods WITH lcMethods IN p49
   lnPatched=lnPatched+1
  ENDIF
 ENDIF
 USE IN p49
ENDFOR
STRTOFILE("DATAENV_FORMS="+TRANSFORM(lnPatched),"C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\patch_all_form_output_suppression_v16_49.log",0)
QUIT
