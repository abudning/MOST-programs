# MOSt Work Plan

## 1. Third-party billing — next priority

Current development baseline: V16.64.1 on branch `codex/v16.28-verified`. V16.63.16 remains the last known-good V16.63 release and must not be modified.

### Confirmed workflow requirements

- The Patients form `3rd Party` button opens the new billing menu.
- A manual invoice supports up to five service lines.
- Separate payer or company details are not required.
- Users allocate payments manually.
- Overpayments and refunds are allowed.
- Users can edit a saved invoice, void it, or delete/cancel it when entered in error.
- Prefer the existing FoxPro invoice report over the HTML preview when it can represent the saved manual service lines and payment state correctly.
- Preserve existing Claims and Guarantor table structures; do not require a shared database schema change.

### Planned V16.64 sequence

- V16.64.2: produce a runnable XP billing test build, connect the `3rd Party` button to the new menu, and integrate the existing FoxPro invoice report.
- V16.64.3: implement and test edit, void, error-deletion/cancellation, manual payment allocation, overpayments, and refunds.
- V16.64.4: run two-workstation invoice-number tests plus billing, premium-code, PDF, Claims, and rollback regressions; then package a release candidate with installer, notes, and checksum.

## 2. Consultation letter workflow — parked until billing is complete

- The Create Consult entry point, selected-template handling, and extraction of the latest Vision-to-Plan, Vision, or Refraction content are otherwise acceptable.
- The unresolved defect is the Word mail-merge action: the newly merged document is not identified and activated reliably, so chart text is not inserted correctly.
- Use GitHub commit `5073cab` as the safe consultation baseline when work resumes.
- Do not use commit `26fa460` as the starting point because it produced a blank document with partial text.
- When resumed, preserve LetterBuilder's existing merge action, wait for the newly merged document, identify it deterministically, activate it, and insert the chart text without replacing the patient chart.

## Current saved state

- GitHub branch: `codex/v16.28-verified`
- Consultation work is parked while third-party billing is completed; baseline to use later: `5073cab`
- Later commit `26fa460` should not be used as the starting point because it produced a blank document with partial text.

## Future plans

- Complete and validate the consultation mail merge workflow.
- Continue and finish the third party billing work in V16.64.
- Build, checksum, and archive installers for each validated release.


## 3. MOSt future roadmap from FUTURE_PLANS.md

### Stabilization and prescriptions — Planned

- Run the XP prescription regression checklist and confirm backup/restore coverage for RXMED and RXOPTICAL.
- Add read-only System Details to Help → About MOSt.
- Record exact error number, program, line, and last action for new failures.

### LetterBuilder and XP lock work — In progress / verify

- Complete the documented two-workstation XP LetterBuilder test.
- Keep the V16.29–V16.35 lock, launcher, patient routing, ID validation, and layout changes documented and regression-tested.
- Consider separate letter authorship attribution while preserving legacy AB filing.

### Release and build discipline — Planned

- Make builds repeatable from source controlled scripts.
- Keep release notes, hashes, install instructions, and rollback steps with every installer.
- Reject packages containing patient data, charts, credentials, claims files, or logs.

### Windows 10/11 compatibility — Planned

- Centralize workstation and shared paths while preserving XP behavior.
- Add a modern read-only Word viewer and lock handling.
- Retest patients, claims, appointments, scheduling, indexes, memo files, EDT, and PDF access.

### Data integrity — Planned; copies only

- Inventory and validate DBC/DBF/CDX/FPT sets.
- Investigate known error and scheduling files.
- Use reversible repairs and compare record counts, indexes, and memo references.

### Clinical workflow improvements — Future

- Make office and prescriber details configurable.
- Add prescription filters, validation, correction/cancellation, and audit support.

### Deployment and modernization — Future

- Pilot Windows 10/11 with rollback documentation.
- Document Word, ActiveX, VFP runtime, and network-share dependencies.
- Plan a staged migration away from unsupported XP/VFP components.

## Chart and PDF path normalization

- Status: the V16.63.16 PDF search fixes are carried into V16.64.1.
- Confirm workstation/server chart mappings during V16.64 regression testing.
- Resolve both S:\ mapped to the share root and S:\charts\ mapped directly to the charts folder.



## PDF chart search mapping — carried forward; workstation verification remains

- The current installer still does not reliably find PDFs across the workstation and server mappings.
- Confirm the working server root is the D share and test workstation S: mapping, direct server D share, and paths that incorrectly include a charts subfolder.
- Fix and test the resolver before the next release.

## Version and premium-claim regressions — fixed in source; workstation verification remains

- Separate the executable/file version from the database schema `VERSION` shown in About MOSt. The stale database value (currently reported as 1.7.609) must not cause the program to run the legacy automatic upgrade when the executable is a later validated build.
- Assign each release a distinct incremented build ID and show the same ID consistently in the executable, About MOSt, installer name, and release notes.
- Preserve the database schema version as its own value; do not overwrite it merely to make the file version match.
- The V16.63.16 premium-code bubble fix is carried into V16.64.1. Re-test E409/E410 editing in every V16.64 release candidate.
