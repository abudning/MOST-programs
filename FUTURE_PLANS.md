# MOSt future plans after V16.28

This is a review list, not authorization to change production systems. Test each phase on complete copied data and release it separately with rollback instructions.

## 1. Stabilize prescriptions

- Run a repeatable XP regression checklist: medication draft/issue/print, glasses manual entry/import/issue/print, history View and Enter, and both physicians.
- Confirm backup and restore coverage for the new `RXMED` and `RXOPTICAL` free tables.
- Extend **Help → About MOSt** with read-only System Details showing executable version, shared data path, workstation role, effective `LETTERWR`, Word version and error-log location.
- Record the exact error number, program, line and last action for any new failure.

## XP LetterBuilder lock work in progress

- V16.29/`1.7.630` is compiled as a Windows XP test build.
- Editable letter open now checks Word's hidden owner file and offers read-only viewing or cancellation instead of entering the blocking path.
- Letter printing opens the document read-only.
- V16.29 must pass the documented two-workstation XP test before it replaces V16.28 as the verified baseline.
- V16.30/`1.7.631` adds a shared single-instance XP LetterBuilder launcher for both the patient screen and Patients menu.
- The patient-screen button now loads the current patient into LetterBuilder but does not open or create a letter; repeat launches restore the existing form and report that it is already open.
- V16.31/`1.7.632` replaces V16.30: fixes the invalid form `SetFocus` call, always files/loads patient letters under legacy mnemonic `AB`, and positions LetterBuilder below or to the right of Patients.
- V16.32/`1.7.633` extends the patient-screen workflow: selecting another patient and pressing Letters routes that ID through LetterBuilder's existing patient-number `Valid()` sequence so the current work follows the established save/completion behavior and the same LetterBuilder switches to the new patient under `AB`.
- V16.33/`1.7.634` adds the explicit ID-focus-and-Enter sequence, defaults standalone LetterBuilder to `AB`, silently raises it for the same patient, positions Claims to the right of Patients, and adds a combined Patient / Claims / Letters window-layout command.
- V16.34/`1.7.635` repeats the full ID-and-Enter pass when the first pass leaves the letter list empty and limits automatic positioning to newly created windows, preserving all later manual moves.
- V16.35/`1.7.636` makes the two patient-ID validation passes synchronous and restores LetterBuilder's exact saved Left, Top and WindowState after every patient switch.
- Letter authorship remains a manual audit when rarely needed: compare the letter date with Billing History to identify the billing physician; do not change the legacy `AB` filing identity.
- Future enhancement: add automatic letter authorship attribution by recording or deriving the physician responsible for the letter, initially using the billing physician for the matching service date. Keep `AB` as the legacy LetterBuilder storage identity so existing letters remain accessible, and show the attribution separately as audit information.
## 2. Consolidate releases and builds

- Treat V16.28/`1.7.629` as the current prescription baseline and archive superseded test installers.
- Make future builds repeatable from source-controlled scripts instead of cumulative manual patches.
- Keep release notes, hashes, installation instructions and rollback steps with every build.
- Automatically reject packages containing patient databases, charts, credentials, claims files or logs.

## 3. Finish Windows 10/11 compatibility

- Centralize local application and shared database paths.
- Keep shared-path configuration in the workstation-local `PARAMETER2.DBF` without overwriting the server copy.
- For Windows 10/11 only, set `LETTERWR=.F.` in the workstation-local `OPTIONS` table exposed through **Setup → Options → Local Options**; leave XP unchanged.
- Add a read-only modern-Word viewer for existing letters, independent of legacy LetterBuilder macros.
- Detect an existing Word owner/application lock before editable open and offer **View Read-Only** or **Cancel** instead of waiting or freezing.
- Resolve the read-only DBC/DBF update problem using copied data and verified XP share/NTFS permissions.
- Retest patients, claims, appointments, scheduling, indexes, memo files, EDT and PDF access.
- Preserve VFP7-compatible database structures while XP and newer workstations coexist.

## 4. Data integrity work on copies only

- Inventory and validate every DBC/DBF/CDX/FPT set before repair.
- Investigate `appointmentserror.DBF`, `temperr.DBF`, `LETTERTEXT.DBF/FPT`, `ra_error20011002.DBF/CDX` and `SCHEDATAold.DBC/DCX`.
- Create reversible repair procedures and compare record counts, indexes and memo references before and after.
- Never pack, reindex or repair the only production copy.

## 5. Clinical workflow improvements

- Make office and prescriber details configurable so address, phone, fax, credentials and CPSO changes do not require recompilation.
- Add prescription status filters, clearer search and optional reprint/audit information.
- Add optical-range and medication-field validation without blocking legitimate clinical exceptions.
- Consider a correction/cancellation workflow that preserves the original issued prescription and audit trail.

## 6. Deployment and modernization

- Pilot one Windows 10/11 workstation with documented rollback before broader deployment.
- Replace legacy HTML/browser printing only after an XP-compatible alternative is proven.
- Document Word automation, ActiveX, VFP runtime and network-share dependencies.
- Plan a staged migration away from unsupported XP/VFP components while preserving readable clinical history and uninterrupted office operation.

See `WINDOWS_10_11_COMPATIBILITY_PLAN.md` for the approved platform separation, read-only viewer and lock-handling design.

## Suggested review order

1. Approve the V16.28 regression checklist and backup coverage.
2. Choose Windows 10/11 compatibility or prescription workflow improvements as the next priority.
3. Approve data-integrity work only on a separate verified copy.
4. Define pilot, rollback and acceptance criteria before broader deployment.
