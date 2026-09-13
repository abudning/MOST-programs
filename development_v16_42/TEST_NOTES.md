# MOSt V16.42 Windows XP test status

Executable version: `1.7.643`

## Confirmed working in office testing

- LetterWriter patient loading and letter-list/detail population.
- LetterWriter first-open positioning and retention of operator-adjusted position.
- Glasses prescription import with optional spaces and sphere-only refractions.
- Active billing-MD filtering in Daily Summary, Check-In Report, Outstanding Submitted Claims, Referring MD Statistics, Submitted Service Codes, and Fix RA Errors.

## Remaining issue

- Reconcile still lists inactive billing physicians. Its separate billing-MD selector must be restricted to physicians whose **Billing MD payment % is not 0**.

## Next build

- V16.43 will apply that active-physician rule to the Reconcile selector and retain `ALL DOCTORS` when more than one active billing physician exists.

## Package integrity

The package hash is recorded in `SHA256.txt`. The upgrade archive contains workstation program/runtime files only and no patient DBF data.
