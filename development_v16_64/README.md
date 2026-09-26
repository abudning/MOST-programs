# MOSt V16.64.1 Third Party Billing — work in progress

This snapshot is rebased on the tested V16.63.16 source and extends it with manual third-party invoices, claim storage, invoice preview, payment history, and the Patients button entry point. V16.63.16 remains unchanged as the last known-good V16.63 release. The billing details use the existing Guarantor memo field; no shared database schema change is intended.

## Source in this snapshot

- `PROGRAMS/thirdparty_freehand.prg`: action menu and five-line manual invoice form.
- `PROGRAMS/thirdparty_store.prg`: invoice persistence, validation, memo lookup, and printable HTML preview.
- `PROGRAMS/create_invoice.prg` and `PROGRAMS/oms.prg`: integration and version guard.
- `FORMS/`: Patients, invoice, and paid-history form changes.
- `FORMS/modify_claims.scx/.sct`: tested V16.63.16 premium-code bubble fix carried forward for E409/E410 editing.
- `FORMS/patients.scx/.sct`: V16.63.16 referral-PDF fixes merged without removing the third-party billing entry point.

## Verification status

A synthetic Visual FoxPro test passed for form totals, saved service lines and cents, invoice numbering, validation, rollback, partial and paid previews, and paid-history linkage. Individual changed programs and forms compiled. The V16.64.1 executable must still be treated as a test build until the premium-code, consultation, and third-party billing workflows are verified on an XP workstation.

The completed V16.63 WORKING WELL release remains under `development_v16_63/`.

