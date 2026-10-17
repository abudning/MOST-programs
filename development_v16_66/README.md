# MOSt V16.66.8 Scheduler stability repair

## Scheduler stability repair — compiled test checkpoint, 2026-10-16

The complete clinic error log exposed scheduler patient-search grid/alias
failures, invalid XP DTPicker assignments, a missing `getSchedule_item` form
property, and widespread multi-workstation file/record contention predating
V16.66.7. Copied `schedule.scx/.sct` and `schedule_addNew.scx/.sct` now contain
a first focused repair: exact patient-ID/health-card matches, temporary-alias
guards, restoration of the 17-column search grid, invalid appointment-date
rejection, and the missing form property. Startup now retries a briefly locked
shared record for up to five seconds.

The patched SCX methods passed structural validation and a clean isolated build
completed as **V16.66.8 / file version 1.7.694**. The isolated build restored the
Patients form from its pre-printer backup, so the failed printer experiment is
not part of this executable.

**This remains a workstation test build, not a clinic deployment. Test it first
with copied data and one workstation while all other workstations are closed.
Only after that succeeds should a controlled two-workstation test be attempted.
Printer diagnostics remain paused.**

## Patient-screen printer routing source correction

**Status: failed workstation test on 2026-10-14. Do not deploy this build over
the working V16.66.7 executable. The cause still requires diagnosis.**

On 2026-10-16 a dedicated printer-trace diagnostic compiled from the validated
V16.66.8 scheduler baseline. It retains embedded version 1.7.694 deliberately,
so running the diagnostic does not invoke the legacy database-upgrade path. A
structural check initially covered only the visible Print button, but the first
workstation test produced no trace message. Further inspection found two more
legacy entry points in the form and search-box keyboard handlers. The corrected
diagnostic routes all 12 active label calls through `MostPrintPatientOutput`,
with zero active direct calls remaining. It displays one message at application
startup and another on entering the print route, then writes each stage to
`%TEMP%\MOSt_Label_Print.log`. Corrected workstation trace results are pending.

The corrected EXE displayed its startup marker on the workstation, proving the
right executable launched, but pressing Print displayed no route marker and no
print-stage entries were written. The returned log contained only the startup
line. Inspection then identified the direct cause: when `LABELOPT` is disabled,
the Patients form supplies `"0"` without a `#copies` suffix. `label_option`
parsed this as zero copies and returned `A0`; the caller silently ran
`FOR i=1 TO 0`. The repaired `label_option.scx/.sct` defaults a missing or
invalid quantity to one and clamps the Print quantity to 1–9. A same-version
1.7.694 test executable compiled successfully on 2026-10-16; workstation
confirmation remains pending.

On 2026-10-17 the zero-copy test again produced only the startup trace. This
confirms that the running installation loads the external
`FORMS\label_option.scx/.sct` pair rather than the form compiled into a replaced
EXE. A matched repaired form pair was therefore packaged for a controlled test
on the user's fully separate test workstation/server. No database files are
included or changed.

The failed test showed that the legacy `patient_label`, `address_label`, and
`patient_sheet` programs overrode the router's printer choice and used an
XP-only `C:\Program Files\MOSt\labels` path. The follow-up source correction
removes those duplicate printer changes and resolves each LBX from the running
MOSt application directory. Radiology-label behavior is deliberately unchanged
because it is not used at this clinic.

Further inspection found the decisive printer override inside all three external
LBX files: their saved report environment targets the retired `\\ETJ\IBM`
printer on `LPT2:`. The used routines now make a temporary LBX/LBT copy, clear
only that saved printer environment, print it through the selected current
printer, and remove the temporary files. Installed label layouts are not edited.

- The Patients Print button now routes patient, address and radiology labels to
  the workstation-local `PARAMETER2.LABEL_PRINTER` selection.
- Full patient sheets route to `PARAMETER2.MAIN_PRINTER`.
- MOSt verifies that the configured Windows printer is installed. If it is
  missing or blank, the user can select a printer for the current job and is
  directed to Setup > Local Parameters to make the change permanent.
- The printer that was active before the job is restored afterwards.
- `PROGRAMS/printer_router.prg` centralizes printer selection so future label
  printer changes do not require another Patients-form edit.
- The existing V16.66.7 executable and installer remain unchanged; rebuild and
  XP printer acceptance are required before packaging this as a new release.

V16.66.1 branches directly from the synchronized V16.64.5 source at commit `9d9ab7bc37e904fa6c64ad36b352f8fdff4813d9`. It does not include the separate V16.65 consultation-letter experiment.

## V16.66.7 movement alignment fine correction

- The four red nasal/temporal values move upward by eight bitmap pixels so
  their text centres sit on the eyes' horizontal centreline.
- Red top/bottom values and every black deviation coordinate are unchanged.

## V16.66.6 movement alignment correction

- The eight red movement values now form symmetrical crosses around the two
  actual eye centres: top and bottom share a centreline, and nasal/temporal
  values share a horizontal line.
- Existing black deviation coordinates are unchanged.

## V16.66.5 movement layers and undo

- Deviations remain a black measurement layer; eight ocular-movement positions form a separate red layer.
- Independent graphical toggles select Deviations, Movements, or both. At least one layer remains active.
- Hidden layers retain their values and are omitted from Copy Diagram and Insert into Word output.
- Clear Active clears the selected layer. When both layers are active it asks before clearing both.
- Undo restores the last two entry edits or clear operations. Changing layer visibility does not consume undo history.
- The fine alignment correction compiled successfully as file version 1.7.693
  and was packaged as the V16.66.7 XP test installer. Windows XP, clipboard, and Word 2000
  workstation acceptance remain required.

## V16.66.3 button placement correction

- Diagram is anchored immediately to the left of the legacy Letters button (`Command3`) instead of being positioned relative to Exit.
- The relative placement prevents Diagram from covering Letters when LetterBuilder is displayed with the clinic workstation's font/display scaling.
- The copied/inserted bitmap is reduced from 640 x 260 to 384 x 156 pixels (60% in each dimension), while its measurement type is proportionally larger for readability.

## V16.66.2 layout correction

- The experimental Consult button is removed from LetterBuilder for now.
- The existing Letters button is retained because it returns to the main letters page and refreshes the available letter list after Templates or Canned Text administration.
- The controls now fit in the order `Letters`, `Diagram`, `Exit` without overlap.
- The unwanted fourth centre field beneath the middle measurement is removed; the diagram has only top, middle, and bottom centre positions.
- The two separate fields above the individual eye outlines are removed; this compact deviation diagram is not a full nine-position motility chart.
- The two lower head-tilt measurements are moved farther outward.
- Short diagonal head-tilt indicator lines appear between the lower eye positions and those measurements.

## V16.66.1 eye diagram

- LetterBuilder now has a `Diagram` button beside its existing controls.
- The button opens a spatial entry form modelled on the supplied two-eye diagram.
- Blank fields are omitted from the result; a vertical bar (`|`) creates a second output line, for example `25XT|RH3`.
- `Copy Diagram` creates a clean 640 x 260 monochrome bitmap on the Windows Clipboard for manual Paste into Word 2000.
- `Insert into Word` copies the same bitmap and pastes it at the current cursor in an open Word document.
- The bitmap is produced with Windows GDI and has no dependency on Paint, .NET, a browser, or a modern Office version.

Source changes are in `PROGRAMS/diagram_tool.prg` and `PROGRAMS/openletterwriter.prg`. Compilation and Windows XP/Word 2000 workstation acceptance are still required. V16.64.5 and all earlier snapshots remain unchanged.

## V16.66.3 OHIP VHC / SLI correction

- `PROGRAMS/ohipdsk.prg` now establishes the current accounting group and selects the claims table before inspecting encounter service lines.
- HCP and WCB/WSIB encounters containing a technical `B` service write `OFF` into the HEH Service Location Indicator.
- G858 is recognized explicitly as a fallback if it reaches OHIP output before or without the normal professional/technical split.
- RMB and ordinary nontechnical claims retain their existing location handling.
- `build_tools/test_sli_v16_66_3.prg` passed grouped G858B, WCB/WSIB, another B fee, G858 fallback, RMB, and ordinary HCP regression cases.

The separate FP7-server billing-file patcher is pending an actual generated OHIP output file so its fixed-width positions can be verified safely.

## Inherited V16.64.5 baseline

V16.64.4 repairs paid history using a patient-only, read-only private-session form (`thirdparty_history.prg`), updates both history entry points, and improves the native HTML viewer Print command. Synthetic checks include both doctors, empty history, excluded/deleted records, selected-invoice rendering and caller-cursor isolation. Full EXE 1.7.684 compiled successfully. Actual XP printing was confirmed working September 29, 2026. Saved-invoice edit/void and manual payment/refund work remain pending; consultation work continues separately in V16.65.1. V16.63.16 stays unchanged. Use `launch_v16_64_4.ps1` / `build_v16_64_4.prg` for the current build; the older notes below describe the V16.64.3 baseline.

This snapshot is rebased on the tested V16.63.16 source and extends it with manual third-party invoices, claim storage, invoice preview, payment history, and the Patients button entry point. V16.63.16 remains unchanged as the last known-good V16.63 release. The billing details use the existing Guarantor memo field; no shared database schema change is intended.

## Source in this snapshot

- `PROGRAMS/thirdparty_freehand.prg`: action menu and five-line manual invoice form.
- `PROGRAMS/thirdparty_store.prg`: invoice persistence, validation, memo lookup, and printable HTML preview.
- `PROGRAMS/create_invoice.prg` and `PROGRAMS/oms.prg`: integration and version guard.
- `FORMS/`: Patients, invoice, and paid-history form changes.
- `FORMS/modify_claims.scx/.sct`: tested V16.63.16 premium-code bubble fix carried forward for E409/E410 editing.
- `FORMS/patients.scx/.sct`: V16.63.16 referral-PDF fixes merged without removing the third-party billing entry point.

## Verification status

A full V16.64.3 executable (file/product version 1.7.683) has compiled successfully. Synthetic Visual FoxPro checks pass for active-MD selection, inactive-MD rejection, complete manual forms without a preferred MD, native HTML viewer controls, quantity/unit prices, physician footer, five lines, HTML escaping, payment balances, numbering, rollback, and paid-history linkage. The XP upgrade installer includes the English VFP9 runtime and verified backups. Actual XP printer behavior and premium-code/Claims/PDF regressions require workstation testing. Saved-invoice edit/void, manual payment allocation, and refund workflows remain the next functional checkpoint, V16.64.4.

## V16.64.5 waiting-list appointment lookup

Clicking a patient leaf in the Scheduler's separate Waiting List now opens the
existing Find Appointment page and runs its normal appointment search. Registered
patients use the stable patient ID stored on the waiting-list appointment;
unregistered entries use the exact packed surname, firstname, and phone value.
Category/root clicks and drag-and-drop behavior are unchanged, and the lookup does
not create, edit, or delete appointments. A fresh V16.64.5 executable compiled as
file/product version 1.7.686; workstation acceptance remains pending.

Build blockers fixed: the shutdown target is `quit_most` (not `quit_mos`), and `TpSaveBill` declares its passed invoice array with `EXTERNAL ARRAY taLines`. Retain native menu project entries; replacing them with generated MPR entries introduces duplicate linker objects.

For a repeat build, prepare an isolated full MOSt source copy, overlay this snapshot's FORMS and PROGRAMS, and copy VFP's `genmenu.prg` into the parent working folder. Preserve OMS.DBC, OMS.DCT, and OMS.DCX even though these are excluded from the EXE: the compiler needs their stored-procedure metadata to resolve STP_FAXJOBS. A previous interrupted copy omitted them, leading to a hidden Locate File dialog. `build_tools/launch_v16_64_3.ps1 -WorkingRoot "<working-copy-parent>"` launches VFP with an explicit FPW startup command and verifies a fresh successful build; alternatively run `DO build_tools/build_v16_64_3.prg WITH "<working-copy-parent>"` inside VFP. Output and log are written to `output/`. The build preflight rejects missing database metadata and recalls the restored excluded DBC entry. Never point it at production or the frozen V16.63.16 package.

The completed V16.63 WORKING WELL release remains under `development_v16_63/`.
## Confirmed next-step requirements

- The Patients `3rd Party` button opens the new billing menu.
- Five manual service lines are sufficient; no separate payer/company fields are needed.
- Payments are allocated manually; overpayments and refunds are allowed.
- Saved invoices may be edited, voided, or deleted/cancelled when entered in error.
- Use HTML invoice review and browser printing, as confirmed September 27.
- V16.64.3 is the compiled invoice/MD/printing checkpoint; V16.64.4 is the next functional implementation checkpoint.
