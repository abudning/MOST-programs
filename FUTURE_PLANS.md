# MOSt future plans after V16.28

This is a review list, not authorization to change production systems. Test each phase on complete copied data and release it separately with rollback instructions.

## 1. Stabilize prescriptions

- Run a repeatable XP regression checklist: medication draft/issue/print, glasses manual entry/import/issue/print, history View and Enter, and both physicians.
- Confirm backup and restore coverage for the new `RXMED` and `RXOPTICAL` free tables.
- Add a diagnostic screen showing executable version, shared data path and workstation role.
- Record the exact error number, program, line and last action for any new failure.

## 2. Consolidate releases and builds

- Treat V16.28/`1.7.629` as the current prescription baseline and archive superseded test installers.
- Make future builds repeatable from source-controlled scripts instead of cumulative manual patches.
- Keep release notes, hashes, installation instructions and rollback steps with every build.
- Automatically reject packages containing patient databases, charts, credentials, claims files or logs.

## 3. Finish Windows 10/11 compatibility

- Centralize local application and shared database paths.
- Implement the workstation-local `PARAMETER2.DBF` plan without overwriting the server copy.
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

## Suggested review order

1. Approve the V16.28 regression checklist and backup coverage.
2. Choose Windows 10/11 compatibility or prescription workflow improvements as the next priority.
3. Approve data-integrity work only on a separate verified copy.
4. Define pilot, rollback and acceptance criteria before broader deployment.
