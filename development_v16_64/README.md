# MOSt V16.64.3 Third Party Billing — XP test build 1.7.683

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
