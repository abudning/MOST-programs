# MOSt V16.64.2 Third Party Billing — test build 1.7.682

This snapshot is rebased on the tested V16.63.16 source and extends it with manual third-party invoices, claim storage, invoice preview, payment history, and the Patients button entry point. V16.63.16 remains unchanged as the last known-good V16.63 release. The billing details use the existing Guarantor memo field; no shared database schema change is intended.

## Source in this snapshot

- `PROGRAMS/thirdparty_freehand.prg`: action menu and five-line manual invoice form.
- `PROGRAMS/thirdparty_store.prg`: invoice persistence, validation, memo lookup, and printable HTML preview.
- `PROGRAMS/create_invoice.prg` and `PROGRAMS/oms.prg`: integration and version guard.
- `FORMS/`: Patients, invoice, and paid-history form changes.
- `FORMS/modify_claims.scx/.sct`: tested V16.63.16 premium-code bubble fix carried forward for E409/E410 editing.
- `FORMS/patients.scx/.sct`: V16.63.16 referral-PDF fixes merged without removing the third-party billing entry point.

## Verification status

A full V16.64.2 executable (file/product version 1.7.682) has compiled successfully. A synthetic Visual FoxPro test passed for five lines, HTML escaping, print controls, credit/partial/paid balances, form totals, saved service lines and cents, invoice numbering, validation, rollback, and paid-history linkage. This is a TEST build, not a production release: XP/workstation testing, premium-code editing, PDF navigation, Claims and actual browser printing remain to be verified. Editing, void/cancellation, manual payment allocation, overpayments and refunds are not complete; those are the V16.64.3 checkpoint.

Build blockers fixed: the shutdown target is `quit_most` (not `quit_mos`), and `TpSaveBill` declares its passed invoice array with `EXTERNAL ARRAY taLines`. Retain native menu project entries; replacing them with generated MPR entries introduces duplicate linker objects.

For a repeat build, prepare an isolated full MOSt source copy, overlay this snapshot's FORMS and PROGRAMS, and copy VFP's `genmenu.prg` into the parent working folder. In a separate VFP session run `DO build_tools/build_v16_64_3.prg WITH "<working-copy-parent>"` from the repository root. The working folder must contain `MOSt/most.pjx`; output and log are written to `output/`. The script updates only the supplied working-copy project and exits VFP. Never point it at a production installation or the frozen V16.63.16 package.

The completed V16.63 WORKING WELL release remains under `development_v16_63/`.
## Confirmed next-step requirements

- The Patients `3rd Party` button opens the new billing menu.
- Five manual service lines are sufficient; no separate payer/company fields are needed.
- Payments are allocated manually; overpayments and refunds are allowed.
- Saved invoices may be edited, voided, or deleted/cancelled when entered in error.
- Use HTML invoice review and browser printing, as confirmed September 27.
- V16.64.3 is the next functional implementation checkpoint.
