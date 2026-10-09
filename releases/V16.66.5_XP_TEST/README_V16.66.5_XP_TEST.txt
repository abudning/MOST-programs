MOSt V16.66.5 / 1.7.691 - XP test workstation upgrade

INSTALL
Extract ALL files into one folder on the XP test workstation. Close MOSt and
run Install-MOSt-V16.66.5-XP.cmd as a local Administrator. The installer makes
and verifies a rollback backup. No database or patient files are included.

V16.66.5 EYE MOVEMENT LAYERS, CLEAR, AND UNDO
- Deviations remain a black measurement layer.
- Eight ocular-movement positions are available as a separate red layer.
- Independent Deviations and Movements toggles allow either layer or both.
- Turning a layer off hides it from entry and Copy/Insert output without
  erasing its values. At least one layer always remains active.
- Clear Active clears the active layer. When both are active, it asks before
  clearing both.
- Undo restores the last two entry edits or clear operations. Layer toggles do
  not consume Undo steps.

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
1. Open LetterBuilder and confirm Diagram is immediately left of Letters.
2. Confirm Deviations and Movements are both initially ON.
3. Enter black deviation values and red movement values.
4. Toggle each layer independently and confirm hidden values are retained but
   omitted from Copy Diagram and Insert into Word output.
5. Turn both layers ON and confirm both black and red values are output.
6. Clear one active layer and confirm Undo restores it.
7. Make two separate entry changes and confirm Undo steps back twice.
8. With both layers active, confirm Clear Active asks before clearing both.
9. Confirm Insert into Word still pastes at the current Word cursor.
10. Recheck the inherited OHIP VHC / technical-fee SLI correction.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_66_5_<numbers> folder inside the installation directory.

BUILD STATUS
The complete executable compiled successfully from an isolated source copy as
file version 1.7.691. Automated SLI regression cases passed for HCP,
WSIB/WCB, other B-suffix technical fees, G858 fallback, RMB, and ordinary HCP.
Windows XP and Word 2000 workstation acceptance remain required.
V16.65 consultation work is not included.
