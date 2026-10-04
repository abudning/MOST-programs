MOSt V16.66.1 / 1.7.687 - XP test workstation upgrade

INSTALL
Extract ALL files into one folder on the XP test workstation. Close MOSt and
run Install-MOSt-V16.66.1-XP.cmd as a local Administrator. The default existing
installation is C:\Program Files\MOSt. No database files or patient data are
included. The installer makes and verifies a rollback backup before replacing
files.

NEW LETTERBUILDER EYE DIAGRAM
- Open LetterBuilder normally. A new Diagram button appears beside its existing
  controls.
- Enter measurements in the boxes surrounding the two eye outlines. The box
  locations correspond to the locations in the finished diagram.
- Leave unused positions blank. They will not appear in the finished image.
- Use a vertical bar for a second line: 25XT|RH3.
- Copy Diagram places the completed bitmap on the Windows Clipboard. Put the
  cursor in Word and choose Paste.
- Insert into Word copies the diagram and pastes it at the current cursor in an
  already-open Word document.
- Clear empties every measurement box without closing the form.

XP / WORD 2000 ACCEPTANCE CHECKS
1. Open LetterBuilder and confirm the Diagram button is visible without covering
   another control.
2. Open the diagram form and enter the sample values supplied for this feature.
3. Use 25XT|RH3 in one box and confirm that it produces two lines.
4. Click Copy Diagram and manually paste into a Word 2000 test document.
5. Confirm both eye outlines, every entered value, and the white background are
   clean and correctly positioned.
6. Place the Word cursor elsewhere and test Insert into Word.
7. Resize the pasted image and print one test page.
8. Confirm blank fields do not produce stray text or box borders.
9. Reopen LetterBuilder for a different patient and confirm its existing letter,
   patient-selection, printing, and close controls still work.
10. Recheck the V16.64.5 waiting-list lookup, Claims, manual invoices, and PDF
    access.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_66_1_<numbers> folder inside the installation directory.

BUILD STATUS
The complete executable compiled successfully from an isolated copy of the
V16.64.5 source as file version 1.7.687. V16.65 consultation-letter work is not
included. The eye diagram still requires visual and Word 2000 acceptance on the
clinic XP workstation before it should be treated as a production release.
