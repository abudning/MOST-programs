MOSt V16.65.1 / 1.7.685 - XP consultation test upgrade

INSTALL
Extract ALL files into one folder on the XP workstation. Close MOSt and run
Install-MOSt-V16.65.1-XP.cmd as a local Administrator. The default existing
installation is C:\Program Files\MOSt. A different folder can be supplied as
the first argument. Existing files are backed up and verified before replacement.
No database files or patient data are included.

PURPOSE
- Continue from the workstation-tested V16.64.4 billing baseline.
- Open LetterBuilder for the selected patient with a shorter delayed reload.
- Create a consultation letter with the selected LetterBuilder template.
- Wait for Word to add the merged document, select that new document directly,
  and insert the latest Vision-to-Plan, Vision, or Refraction text there.
- Never insert consultation text into the open patient chart when Word fails to
  create a new merged document.

CONSULTATION ACCEPTANCE CHECK
1. Open a test patient's chart in Word. Make sure it contains a recent Vision,
   Vision-to-Plan, or Refraction line.
2. In MOSt, open Patients and Claims for that same test patient.
3. Open LetterBuilder. Confirm it opens and populates the selected patient more
   quickly, without moving to an incorrect screen position.
4. Select the normal consultation template and click Create Consult.
5. Confirm Word creates and activates a NEW merged letter.
6. Confirm the new letter contains the latest chart vision/refraction text after
   "On examination" and that the original patient chart is unchanged.
7. Save or print the test letter using the normal workflow.
8. Repeat once with an existing unrelated Word document open. The consultation
   text must still go only into the newly merged letter.
9. Recheck Claims, premium-code editing, a manual third-party invoice, billing
   history/printing, and normal PDF access.

If Word does not create a new merge document within ten seconds, MOSt should show
a warning and leave the patient chart unchanged. Record the exact message and the
open Word document titles.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_65_1_<numbers> folder inside the installation directory.
V16.64.4 remains the previously workstation-tested release.

The full 1.7.685 EXE and standalone consultation source compiled successfully
from a fresh isolated project. Real XP Word mail-merge behavior requires this
workstation acceptance test.
