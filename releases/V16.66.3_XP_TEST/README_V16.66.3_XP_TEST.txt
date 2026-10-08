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

UPDATED DIAGRAM LAYOUT
- Exactly three centre measurements: top, middle, and bottom.
- Two superior-oblique measurement positions are restored above the inner
  portion of the left and right eyes.
- Outer side measurements remain beside each eye.
- The eye curves have open, shortened ends at the sides and central gap so
  two-line measurements such as RET56|RHT3 do not overlap the drawing.
- Lower head-tilt measurements are farther outward with diagonal indicators.
- Use | for a second line, for example 25XT|RH3.

VHC / TECHNICAL-FEE SLI CORRECTION
- The OHIP encounter-header scan now uses the current claim accounting group
  and scans the claims table rather than the temporary output table.
- HCP and WCB/WSIB encounters containing a technical B-suffix service write
  OFF as the four-character Service Location Indicator (SLI).
- G858 is also recognized explicitly if it reaches billing before or without
  the normal professional/technical split.
- RMB and ordinary nontechnical claims retain their existing location handling.

ACCEPTANCE CHECKS
1. Open LetterBuilder and confirm the bottom controls do not overlap.
2. Confirm Diagram is immediately left of Letters.
3. Confirm Letters still returns to the main letters page.
4. Open Diagram and recheck Copy Diagram and Insert into Word.
5. Recheck the three centre, two superior-oblique, and two head-tilt positions.
6. Enter RET56|RHT3 at the horizontal measurement positions and confirm neither
   line overlaps the eye curves.
7. Confirm the inserted diagram is substantially smaller while its numbers
   remain easy to read and print.
8. Create test HCP and WSIB/WCB claims containing a G858 technical component;
   confirm their HEH encounter headers contain OFF and no VHC rejection occurs.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_66_3_<numbers> folder inside the installation directory.

BUILD STATUS
The complete executable compiled successfully from an isolated V16.64.5 source
copy as file version 1.7.689. Automated SLI regression cases passed for HCP,
WSIB/WCB, other B-suffix technical fees, G858 fallback, RMB, and ordinary HCP.
V16.65 consultation work is not included.
