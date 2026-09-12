# MOSt V16.17 prescription test build

Executable version: `1.7.614`

## Added

- A **New Rx** button on the patient screen with Medication and Glasses choices.
- The Medication choice opens the existing MOSt medication-prescription module.
- A new structured glasses-prescription form for OD/OS sphere, cylinder, axis, add, prism/base, pupillary distance, use, notes, examination date, issue date and prescribing MD.
- **Prescription History** replaces the unused Immunizations choice in the EMR menu. The remaining Allergies, Prescriptions, Vitals and optional Faxes choices are preserved.
- Prescription History combines legacy medication records and new glasses records, newest first. Selecting a medication opens the legacy prescription screen; selecting glasses opens the saved prescription read-only.
- Glasses drafts can be saved and reopened. Issuing requires confirmation and makes the issued record read-only.
- Glasses preview/printing is generated directly by MOSt as HTML and does not require Word.
- Optional Word refraction import. It prefers deliberately selected text and otherwise searches backward for the last explicit Refraction section. It imports only complete OD and OS sphere/cylinder/axis values, preserves plus-cylinder notation, displays the source text and requires confirmation.

## Shared data

On first use of Glasses Rx or Prescription History, MOSt creates the following VFP7-compatible free-table files in the configured shared database folder:

- `RXOPTICAL.DBF`
- `RXOPTICAL.FPT`
- `RXOPTICAL.CDX`

The files are not added to or required by `OMS.DBC`; older MOSt versions ignore them. The installers contain no clinical data or database files.

## Required testing

This is a test release. Install it against a complete copied database first. Verify patient context, medication entry, glasses draft/issue, Word import on XP, manual entry on Windows 10/11, history, view, preview/print, simultaneous workstation access, backup and rollback. Confirm the printed clinical content before any live pilot.

The existing Server 2008 program remains unchanged. Remind My Patient remains unchanged.
