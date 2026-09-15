MOSt V16.62 Windows XP Claims repair - TEST BUILD
Executable version: 1.7.663

V16.61 IS WITHDRAWN AFTER THE REPORTED CLAIMS-OPENING CRASH
The Menu Manager internal consistency error has not been reproduced here.
V16.62 removes V16.61's new manual billing-MD list reconstruction and restores
V16.60's SQL dropdown source/properties. It retains the numeric fee repair and
session MD memory. This is a targeted test candidate, not a confirmed crash fix.
First test: start MOSt and open Claims. If it crashes, close MOSt and roll back
to the known-working executable from the backup created before V16.61.

CHANGES
- Premium and special-visit amounts stay numeric through the yellow-star return
  to Claims, totals and saving. Currency captions are used only for display.
- Decimal cents are preserved in additional-fee totals and saved amounts.
- Claims remembers an explicitly chosen billing MD during the current MOSt
  session and restores it after patient changes, resets and reopening Claims.
- Existing fee macros, code/time associations and database paths are retained.
- All V16.60 prescription, Patients layout, LetterWriter and Scheduler work is
  carried forward. No fee-table or clinical-database migration is included.

INSTALL ON AN EXISTING XP TEST WORKSTATION
1. Extract ALL files from the ZIP on the Windows XP workstation.
2. Close MOSt and sign in as a local Administrator.
3. Run Install-MOSt-V16.62-XP.cmd. It backs up the existing MOST.exe and
   verifies the copied files byte-for-byte.
4. Start MOSt using the existing shortcut. Confirm version 1.7.663.
Requires the existing working VFP9 installation and configured database/chart
mappings. Use a complete copied test database for the following checks.

XP CHECKLIST - STILL REQUIRED
1. Complete a base claim with a nonzero fee; right-click that line, open Premium,
   select the time/code, and return with the yellow star.
2. Test the reported E185 path with a configured 30% macro. A test base fee of
   100.00 should retain 30.00, subject to the installed table's macro and mapping.
3. Save and reopen the claim. Verify base fee, additional fee, cents and total.
4. Test a fixed special-visit code and the applicable time/hospital selections.
5. Test multiple additional codes, removing a code and recalculating the base fee.
6. Select billing MD AB. Save/reset, change patients via Claims and L +C, close
   and reopen Claims. Confirm AB stays selected and is stored on each test claim.
7. Select another active MD and repeat. Confirm the latest choice is retained.
8. Clear the MD explicitly and confirm no unintended MD is assigned.
9. Restart MOSt: session memory should start fresh; no new persistent default
   was introduced. Check inactive-MD exclusion and the existing unknown-MD option.
10. Recheck prescription printing/history, Patients L +C, letters and Scheduler.

ROLLBACK
Close MOSt. Copy MOST.exe from the Upgrade_Backup_V16_62_* folder shown by
installation over the workstation's existing MOST.exe. Keep the backup.

VALIDATION
Local Visual FoxPro fixture tests cover percentage and fixed amounts, cents,
unit-based premiums, active-MD filtering, explicit changes/blank choices and
session restore. Source checks confirm the original Claims record structure and
removal of currency-caption parsing. These do not replace actual XP testing.
The installer script is adapted from V16.60 and has not been executed on XP here.

This executable-only upgrade contains no database files, patient charts or
credentials. It updates the local workstation executable only. Do not install
on the server. V16.62 remains a test build until workstation checks pass.

