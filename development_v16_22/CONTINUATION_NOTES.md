# MOSt V16.22 prescription centre development checkpoint

Executable version reserved: `1.7.623`

Status: **development continuation — not clinically verified and not approved for live use**.

## Purpose

This checkpoint preserves the latest Windows XP prescription-centre work so investigation can continue later without losing the V16.18–V16.21 changes. The source is carried forward from the locally built V16.21 baseline. A V16.22 executable and Windows XP upgrade ZIP were compiled successfully, but workstation functional testing remains outstanding.

## Changes carried forward

- V16.18 retained the known-working patient-form structure, renamed the existing EMR button to Rx, and exposed New Rx and Prescription History without adding a new legacy form record.
- V16.19 introduced the structured `RXMED` medication path, repaired prescription history, added patient name and date of birth to the UI and print output, aligned the prescriber list with Patients, repaired repeat issuing, and added clearer Word/preview failure handling.
- V16.20 changed the medication route default to Topical, read patient identity from the active Patients record, repaired glasses numeric conversions associated with error 11, and replaced the preview API statement associated with error 36.
- V16.21 split glasses print generation into Windows XP-safe statements and opened prescription tables in separate work areas to prevent Prescription History from closing and producing the unexpected **Look In** dialog.

## Error history to retain

The following workstation observations drove the recent repair iterations:

1. Visual FoxPro error 11 during glasses numeric conversion.
2. Visual FoxPro error 36 when launching prescription preview.
3. Prescription History closing unexpectedly, followed by an incorrect **Look In** file dialog.

The V16.20/V16.21 code contains intended repairs for these observations, but the interrupted test cycle did not establish that all Windows XP paths are resolved. Treat any recurrence or new error as unresolved until reproduced and recorded with the complete error number, message, action being performed, and screen state.

## Resume checklist

1. Install the compiled V16.22/`1.7.623` package on a Windows XP test workstation using a complete copied database.
2. Install only on a Windows XP test workstation against a complete copied database.
3. Test medication New Rx, glasses manual entry, Word refraction import, draft and issue, Prescription History, reopening records, and preview/print.
4. For every error, record the exact number and message, whether Word was open, the patient and prescription type, and the last button pressed.
5. Confirm `RXOPTICAL` and `RXMED` open in independent aliases/work areas and that closing a form does not close the history cursor.
6. Do not label V16.22 verified or use it clinically until the XP sequence passes.

## Safety boundaries

- Upgrade-only workstation work; do not run on Windows Server 2008.
- Do not include or overwrite clinical DBF, DBC, DCT, DCX, CDX, or FPT data files.
- Back up the complete server MOSt folder before any later live pilot.
- Use a complete copied database for continued testing.
