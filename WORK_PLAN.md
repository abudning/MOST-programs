# MOSt Work Plan

## 1. Consultation letter workflow — finalize mail merge

- Start from the stable consultation workflow baseline at GitHub commit `5073cab`.
- Preserve LetterBuilder's existing Word merge action.
- Make sure the operator can open the chart, choose a template after New, click Create Consult, and receive the merged consultation letter with the latest Vision to Plan information inserted.
- Test the generated document and confirm the chart is not replaced or left as a blank document.

## 2. Third party billing

- Resume the third party billing work after the consultation workflow is finalized.
- Review the current V16.64 state and continue the remaining billing changes.
- Build and verify an installer after the billing work is complete.

## Current saved state

- GitHub branch: `codex/v16.28-verified`
- Consultation work baseline to use: `5073cab`
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

- Status: Resolver routine saved; PDF button integration remains to be applied from the 5073cab baseline.
- Resolve both S:\ mapped to the share root and S:\charts\ mapped directly to the charts folder.

