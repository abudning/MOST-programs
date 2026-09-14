# MOSt V16.44 Windows XP test status

Executable version: `1.7.645`

## Database-location change

- Preferred shared database folder: `K:\most-root\program files\most\databases\`.
- MOSt first confirms that `oms.dbc` exists in that folder.
- When confirmed, MOSt uses the folder and saves it in the workstation-local `PARAMETER2.DATA_FILES` field.
- If the K-drive location is unavailable, the existing legacy validation/fallback remains in effect instead of blindly selecting an inaccessible folder.
- The installer does not move, copy, or alter shared clinical database files.

## Retained repairs

All V16.43 prescription, LetterWriter, reporting, and Reconcile fixes are retained.

## Office test requested

Confirm that drive K: is mapped before opening MOSt, then verify normal access to Patients, Claims, Appointments, prescriptions, letters, and reports.
