CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
LOCAL lcRoot,lnFiles,lnI,lnChanged,lnRecords,lcProps,lcNew
LOCAL ARRAY laFiles[1]
lcRoot="E:\MOST for chat\oms_vfp9_build\MOSt\FORMS\"
lnChanged=0
lnRecords=0
lnFiles=ADIR(laFiles,lcRoot+"*.scx")
FOR lnI=1 TO lnFiles
 USE (lcRoot+laFiles[lnI,1]) EXCLUSIVE ALIAS p48
 SCAN FOR LOWER(ALLTRIM(p48.baseclass))=="cursor"
  lcProps=p48.properties
  lcNew=STRTRAN(lcProps,"..\databases\oms.dbc","K:\Program Files\MOSt\databases\oms.dbc",1,-1,1)
  lcNew=STRTRAN(lcNew,"..\databases\letters.dbc","K:\Program Files\MOSt\databases\letters.dbc",1,-1,1)
  lcNew=STRTRAN(lcNew,"..\databases\schedata.dbc","K:\Program Files\MOSt\databases\schedata.dbc",1,-1,1)
  IF lcNew#lcProps
   REPLACE p48.properties WITH lcNew IN p48
   lnRecords=lnRecords+1
  ENDIF
 ENDSCAN
 IF lnRecords>lnChanged
  lnChanged=lnChanged+1
 ENDIF
 USE IN p48
ENDFOR
STRTOFILE("FILES="+TRANSFORM(lnChanged)+" RECORDS="+TRANSFORM(lnRecords),"C:\Users\abudn\Documents\Codex\2026-09-12\wh\work\patch_all_form_shared_paths_v16_48.log",0)
QUIT
