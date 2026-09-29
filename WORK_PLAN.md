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
- Use HTML invoice review/printing (confirmed September 27). Include browser printing; do not pursue FoxPro report conversion for this workflow.
- Preserve existing Claims and Guarantor table structures; do not require a shared database schema change.

### Planned V16.64 sequence

- V16.64.2: produce a runnable XP billing test build, connect the `3rd Party` button to the new menu, and integrate HTML invoice review/printing.
- V16.64.3: compiled invoice review/printing and active-MD selection checkpoint, with XP test installer.
- V16.64.4: implement and test edit, void, error-deletion/cancellation, manual payment allocation, overpayments, and refunds.
- V16.64.4: run two-workstation invoice-number tests plus billing, premium-code, PDF, Claims, and rollback regressions; then package a release candidate with installer, notes, and checksum.

## 2. Consultation letter workflow — parked until billing is complete

- The Create Consult entry point, selected-template handling, and extraction of the latest Vision-to-Plan, Vision, or Refraction content are otherwise acceptable.
- The unresolved defect is the Word mail-merge action: the newly merged document is not identified and activated reliably, so chart text is not inserted correctly.
- Use GitHub commit `5073cab` as the safe consultation baseline when work resumes.
- Do not use commit `26fa460` as the starting point because it produced a blank document with partial text.
- When resumed, preserve LetterBuilder's existing merge action, wait for the newly merged document, identify it deterministically, activate it, and insert the chart text without replacing the patient chart.

## Current saved state

### V16.64.2 implementation checkpoint — September 27

- V16.64.2 / executable build ID 1.7.682 compiled successfully September 27. It is an XP/workstation TEST build, not a validated production release. No installer has been built.
- HTML printing is retained for outstanding and paid-history invoices. Added a Print button, billing-physician address/phone from invoice data (no hard-coded office address), and explicit credit-balance wording for overpaid previews.
- Synthetic VFP tests pass: five service lines, escaped HTML, print control, credit/partial/paid balances, form totals, saved history linkage, cents, unique numbering, invalid input rejection, and transactional rollback.
- Reproducible source test: run `DO build_tools/test_thirdparty_v16_64_2.prg` from the repository root in a separate VFP session. It creates only synthetic fixtures under the temporary directory and exits that session; result is `tp_store_test.log` there.
- Full project compilation is now successful. Hidden Locate File dialogs were caused by the misspelled shutdown target `quit_mos` and the undeclared array parameter `taLines`; both are fixed in source. A prior workaround replacing native menu project entries with generated MPRs caused duplicate linker objects and was removed. The build launcher now points to the correct script. Temporary printer metadata experiments were reverted; original report layouts/settings are retained. The repeatable build script is `build_tools/build_v16_64_2.prg` (see development README).
- Next functional checkpoint is now V16.64.4: editing, void/error-cancellation, manual allocation, overpayments and refunds. Credit-balance preview testing is not evidence that those payment workflows are implemented.

### V16.64.3 build and XP installer checkpoint — September 27

- Full EXE build completed with file/product version 1.7.683. The hidden Locate File prompt for STP_FAXJOBS was resolved by restoring missing OMS.DBC/DCT/DCX in the isolated source copy and recalling the excluded DBC project entry. Build preflight now checks these metadata files; an explicit FPW launcher verifies fresh build output.
- Active-MD selector, unselected-MD form controls, inactive-MD rejection, native invoice Print/Exit controls, quantity/unit pricing, physician footer, persistence and rollback passed synthetic tests.
- The XP upgrade package is in `releases/V16.64.3_XP_TEST/`. It contains the compiled EXE, Claims form pair, English VFP9 runtime and reporting support. No database files are packaged. Installer copying/backup and injected-failure rollback were tested in scratch folders; archive payload hashes were verified after extraction.
- Next acceptance step: install on the XP test workstation and verify the actual printer dialog/output, premium-code bubbles, Claims and PDF navigation. V16.63.16 remains the last validated release. Consultation merge remains parked.
- V16.63.16 remains untouched and consultation work stays parked.

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
# September 27, 2026 — V16.64.4 regression checkpoint

Paid billing history now uses the configured data path, no doctor selector, safe empty state, and a private read-only session. Both menu and invoice History button use it. Selected-invoice HTML rendering and patient/doctor/cursor-isolation tests pass. Native Print allows dialogs, focuses the browser and has a document-print fallback. EXE 1.7.684 compiled; actual XP printing is still an acceptance check. Finish saved-invoice edit/void and manual payment/overpayment/refund workflows next, in V16.64.5. Consultation merge remains pending. Keep V16.63.16 frozen as known good.

# September 29, 2026 — V16.64.4 printer acceptance and V16.65.1 start

Actual workstation printing from V16.64.4 was confirmed working. Claims, premium-code handling, manual invoices, and normal PDF access were also confirmed working. PDF completeness remains a deferred audit because occasional letters may be missed; retain this item until the complete approximately 6 GB chart set is available for comparison. V16.65.1 now starts from that source baseline for the consultation-letter workflow. The first performance change reduces LetterBuilder's deliberate reload delay. The merge now polls without a fixed three-second sleep, while deterministic selection of the newly created Word document remains the next implementation step.

V16.65.1 / executable 1.7.685 compiled successfully from a fresh isolated copy of `v16_63_build` with the V16.65 source overlaid. The hidden prompt was caused by stale project state in the reused V16.64 build directory, not a syntax error in `consult_letter.prg`; its standalone compile also passed. Keep future V16.65 builds fresh and add project members only when absent.
