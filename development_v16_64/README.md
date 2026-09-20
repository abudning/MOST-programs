# MOSt V16.64 Third Party Billing — work in progress

This snapshot extends the V16.63 working source with manual third-party invoices, claim storage, invoice preview, payment history, and the Patients button entry point. The billing details use the existing Guarantor memo field; no shared database schema change is intended.

## Source in this snapshot

- `PROGRAMS/thirdparty_freehand.prg`: action menu and five-line manual invoice form.
- `PROGRAMS/thirdparty_store.prg`: invoice persistence, validation, memo lookup, and printable HTML preview.
- `PROGRAMS/create_invoice.prg` and `PROGRAMS/oms.prg`: integration and version guard.
- `FORMS/`: Patients, invoice, and paid-history form changes.

## Verification status

A synthetic Visual FoxPro test passed for form totals, saved service lines and cents, invoice numbering, validation, rollback, partial and paid previews, and paid-history linkage. Individual changed programs and forms compiled. A full V16.64 executable build has not completed, and the interface has not been tested on a workstation. Do not deploy this snapshot as a production upgrade.

The completed V16.63 WORKING WELL release remains under `development_v16_63/`.
