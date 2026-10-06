MOSt V16.66.2 / 1.7.688 - XP test workstation upgrade

INSTALL
Extract ALL files into one folder on the XP test workstation. Close MOSt and
run Install-MOSt-V16.66.2-XP.cmd as a local Administrator. The default existing
installation is C:\Program Files\MOSt. No database files or patient data are
included. The installer makes and verifies a rollback backup before replacing
files.

V16.66.2 CORRECTIONS
- The unused experimental Consult button is removed so it cannot overlap other
  LetterBuilder controls.
- The legacy Letters button remains because it returns to the main letters page
  and refreshes the available letter list after Templates or Canned Text work.
- The bottom controls now fit as Letters, Diagram, and Exit.
- The diagram contains only three centre measurement positions: top, middle,
  and bottom. The unwanted fourth centre position is removed.
- The two positions immediately above the individual left and right eyes are
  removed; this compact form is not a full nine-position motility chart.
- The two lower head-tilt values are farther outward, with a short diagonal
  indicator between each eye and its value.

DIAGRAM USE
- Enter measurements in the boxes surrounding the two eye outlines.
- Leave unused positions blank; they do not appear in the copied bitmap.
- Use a vertical bar for a second line: 25XT|RH3.
- Copy Diagram places the bitmap on the Windows Clipboard for manual Paste.
- Insert into Word pastes it at the current cursor in an open Word document.

XP / WORD 2000 ACCEPTANCE CHECKS
1. Confirm LetterBuilder displays Letters, Diagram, and Exit without overlap and
   no Consult button.
2. Confirm Letters still returns to the main letters page after opening Letter
   Templates or Canned Text.
3. Enter the supplied sample values and confirm there are exactly three centre
   values and no separate entry positions above the individual eyes.
4. Confirm the lower head-tilt values and their diagonal indicators are correctly
   positioned.
5. Test Copy Diagram followed by manual Paste into Word 2000.
6. Test Insert into Word at the current cursor.
7. Resize and print one test page.
8. Recheck V16.64.5 waiting-list lookup, Claims, invoices, and PDF access.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_66_2_<numbers> folder inside the installation directory.

BUILD STATUS
The full executable compiled successfully from an isolated V16.64.5 source
copy as file version 1.7.688. V16.65 consultation work is not included.
