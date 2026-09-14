CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
LOCAL loFile,lcNeed,llFound,lnI
DIMENSION laNeed[4]
laNeed[1]="E:\MOST for chat\oms_vfp9_build\MOSt\PROGRAMS\openletterwriter.prg"
laNeed[2]="E:\MOST for chat\oms_vfp9_build\MOSt\PROGRAMS\openpatientclaim.prg"
laNeed[3]="E:\MOST for chat\oms_vfp9_build\MOSt\PROGRAMS\openpatientclaimsletters.prg"
laNeed[4]="E:\MOST for chat\oms_vfp9_build\MOSt\PROGRAMS\letterpatientreloadtimer.prg"
MODIFY PROJECT "E:\MOST for chat\oms_vfp9_build\MOSt\most.pjx" NOWAIT
FOR lnI=1 TO 4
 lcNeed=laNeed[lnI]
 llFound=.F.
 FOR EACH loFile IN _VFP.ActiveProject.Files
  IF UPPER(JUSTFNAME(loFile.Name))==UPPER(JUSTFNAME(lcNeed))
   llFound=.T.
   EXIT
  ENDIF
 ENDFOR
 IF !llFound
  _VFP.ActiveProject.Files.Add(lcNeed)
 ENDIF
ENDFOR
_VFP.ActiveProject.VersionNumber="1.7.646"
_VFP.ActiveProject.Close()
QUIT


