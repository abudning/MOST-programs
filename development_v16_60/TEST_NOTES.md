# MOSt V16.60 Windows XP test status

Executable version: `1.7.661`

## Current checkpoint

V16.60 is the latest Windows XP test build. It includes all work from V16.51 through V16.60 and supersedes V16.51-V16.59 as test packages.

## Changes since V16.50

- V16.51 repaired optical Word import for `PL`/`PLANO`, sphere-only refractions and `ADD +2.50 OU`; changed the optical signature wording to `Digitally signed`; and retained a selected Claims billing MD when opening a patient.
- V16.52-V16.55 developed the requested three-row Patients button layout without adding an SCX control record, retained multi-user Patients access, restored the individual Claims/Letters controls, and corrected initial LetterWriter positioning.
- V16.56-V16.58 repaired the visible Exit control, made the combined control invoke Claims and Letters directly, and adjusted LetterWriter below the complete Claims window frame.
- V16.59 labels the combined button `L +C` and explicitly opens `schedata` from the configured `path_to_data` folder in shared mode before the Scheduler room query.
- V16.60 retains the billing MD already selected in an existing Claims window when the Patients-screen Claims or `L +C` action loads another patient. A previously blank billing MD remains blank.

## Patients button layout

- Row/column layout follows the approved handwritten design.
- Exit uses red text and a standard XP-visible button face.
- `L +C` opens or reuses Claims and LetterWriter for the current patient.
- Claims opens to the right of Patients.
- A newly created LetterWriter opens below Claims with an XP frame allowance; later manual moves are retained.

## Scheduler routing

- The Scheduler menu opens `ADDBS(ALLTRIM(path_to_data))+"schedata"` with `SHARED` before using `SCHEDATA!ROOMTABLE`.
- The Scheduler form data environment continues to point to `K:\Program Files\MOSt\databases\schedata.dbc` for the current XP mapping.

## Test checklist

1. Open Patients concurrently on more than one workstation.
2. Confirm Exit is visible and closes the Patients form.
3. Confirm the combined button reads `L +C` and opens both Claims and LetterWriter.
4. Confirm LetterWriter does not cover Claims on its first opening.
5. Choose billing MD `AB`, change patient on Patients, then press Claims; confirm `AB` remains selected.
6. Repeat the patient change using `L +C`; confirm `AB` remains selected.
7. Start with no billing MD selected and confirm it remains blank.
8. Open Patients → Scheduler and confirm it opens the shared Scheduler data without looking for `C:\Program Files\MOSt\schedata.dbc`.

## Package safety

The test archive contains the executable and instructions only. It includes no DBF, DBC, FPT, CDX, patient charts, claims data, credentials, or operational logs.