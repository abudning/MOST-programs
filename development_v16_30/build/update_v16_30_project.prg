CLEAR ALL
CLOSE DATABASES ALL
SET SAFETY OFF
LOCAL loFile, llFound
llFound=.F.
MODIFY PROJECT "E:\MOST for chat\oms_vfp9_build\MOSt\most.pjx" NOWAIT
FOR EACH loFile IN _VFP.ActiveProject.Files
    IF UPPER(JUSTFNAME(loFile.Name))=="OPENLETTERWRITER.PRG"
        llFound=.T.
        EXIT
    ENDIF
ENDFOR
IF !llFound
    _VFP.ActiveProject.Files.Add("E:\MOST for chat\oms_vfp9_build\MOSt\PROGRAMS\openletterwriter.prg")
ENDIF
_VFP.ActiveProject.VersionNumber="1.7.631"
_VFP.ActiveProject.Close()
QUIT