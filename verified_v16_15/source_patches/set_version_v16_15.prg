LOCAL lcProject, lcLog
lcProject = "E:\MOST for chat\oms_vfp9_build\MOSt\most.pjx"
lcLog = "E:\MOST for chat\oms_vfp9_build\output\version_update_v16_15.log"
SET SAFETY OFF
MODIFY PROJECT (lcProject) NOWAIT
_VFP.ActiveProject.VersionNumber = "1.7.612"
_VFP.ActiveProject.Close()
STRTOFILE("Project version set to 1.7.612 (Windows file version 1.7.612.0)" + CHR(13) + CHR(10), lcLog, 0)
QUIT
