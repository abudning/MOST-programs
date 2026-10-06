MOSt V16.66.3 / 1.7.689 - XP test workstation upgrade

INSTALL
Extract ALL files into one folder on the XP test workstation. Close MOSt and
run Install-MOSt-V16.66.3-XP.cmd as a local Administrator. The installer makes
and verifies a rollback backup. No database or patient files are included.

V16.66.3 BUTTON CORRECTION
- Diagram is positioned immediately to the left of the existing Letters button.
- Its position is calculated from the live Letters button position, preventing
  overlap caused by workstation display or font scaling.
- Letters remains active and retains its legacy function.
- The unused Consult button remains removed.
- The copied/inserted diagram is 60% of the previous dimensions, with
  proportionally larger measurement text for easier reading in Word.

INHERITED DIAGRAM LAYOUT
- Exactly three centre measurements: top, middle, and bottom.
- No separate entry positions above the individual eyes.
- Outer side measurements remain beside each eye.
- Lower head-tilt measurements are farther outward with diagonal indicators.
- Use | for a second line, for example 25XT|RH3.

ACCEPTANCE CHECKS
1. Open LetterBuilder and confirm the bottom controls do not overlap.
2. Confirm Diagram is immediately left of Letters.
3. Confirm Letters still returns to the main letters page.
4. Open Diagram and recheck Copy Diagram and Insert into Word.
5. Recheck the three centre and two head-tilt positions.
6. Confirm the inserted diagram is substantially smaller while its numbers
   remain easy to read and print.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_66_3_<numbers> folder inside the installation directory.

BUILD STATUS
The complete executable compiled successfully from an isolated V16.64.5 source
copy as file version 1.7.689. V16.65 consultation work is not included.
