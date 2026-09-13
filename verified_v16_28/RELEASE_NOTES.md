MOSt V16.28 WINDOWS XP WORKSTATION PRESCRIPTION REPAIR
Executable version: 1.7.629

This build replaces and withdraws V16.27 executable 1.7.628.

V16.28 replaces the four glasses sphere/cylinder numeric controls with signed
text controls. Positive and negative signs now remain visible during manual entry,
after Word import, when reopening history, and on print. The physician name and
CPSO number are also printed in a prominent block near the top and repeated below
the signature. Printed pages include MOSt Rx V16.28 for verification.

V16.27 prints the selected physician's CPSO number in bold on a separate line
below the physician name on both medication and glasses prescriptions. Each
preview now uses a fresh filename to prevent Windows XP from showing an older
cached prescription printout.

V16.26 adds the appropriate CPSO number to the selected physician printed below
the signature on medication and glasses prescriptions: Andrew Budning MD, FRCSC
CPSO 60349 or Hassan Hazari MD, FRCS(C) CPSO 121051.

V16.25 makes Enter on a selected Prescription History row perform the same
action as View. It rewrites medication print construction into XP-safe short
statements, retaining the full office header and selected doctor's full name
below the signature. Glasses sphere and cylinder now print with an explicit
plus or minus sign, including values imported from Word.
V16.24 explicitly selects the correct prescription work area before locating
RX_ID when a history item is viewed. It replaces the SQL-backed prescriber
control with two XP-safe full-name choices: Andrew Budning MD FRCS(C) and
Hassan Hazari MD FRCS(C). AB and HH remain the internal stored codes.

V16.23 repairs history population by explicitly returning to each source table
after adding a row to the history cursor. It adds the Budning Eye Institute
address, telephone and fax header to medication and glasses prints. It removes
the Prescribing MD body line, adds a two-doctor prescriber dropdown and prints
the selected doctor below the signature line. PD is no longer printed on glasses
prescriptions. Faxes is removed from the Rx menu.

V16.22 retains the XP-safe glasses print and separate prescription-history
work areas from V16.21, and closes any stale history cursor before rebuilding
the list so Prescription History can be reopened safely.

V16.21 splits the glasses print page into XP-safe statements and ensures every
prescription table opens in a separate work area, preventing Prescription
History from being closed and triggering the erroneous Look In dialog.

V16.20 changes medication route to Topical, reads patient name and DOB from
the active Patients record, fixes all glasses numeric conversions that caused
error 11, and replaces the preview API statement that caused error 36.

V16.19 also repairs prescription history, shows the patient name and date of
birth prominently and on printed output, defaults medication route to Oral,
uses the same active-MD list as Patients, fixes repeat-count issuing, checks
preview launch failures, and gives a clear instruction when Word is not open.

V16.18 retains the known-working patient form structure. The existing EMR
button is renamed Rx and now offers New Rx and Prescription History. No new
command-button record is added to the legacy patient form. The Rx button no
longer depends on the obsolete optional EMR setting, so New Rx remains
available before any prescriptions exist. It also prevents the legacy
database upgrade from running for this code-only release and displays V16.17.

This is an upgrade-only package for an existing workstation.
DO NOT RUN IT ON WINDOWS SERVER 2008.
It contains no MOSt DBF, DBC, DCT, DCX, CDX, or FPT data files.
The existing server application and shared data are intentionally unchanged.

Extract the complete ZIP, close MOSt, and run the CMD installer using a local
Administrator account. Do not use a self-extracting installer on Windows XP.

This release repairs New Rx for medication and glasses prescriptions. Both are
kept as structured shared DBF records and can be viewed without Word. New
medications use RXMED.DBF instead of the dormant legacy prescription component,
whose same errors appear in the original 2006 logs. Old medication tables are
not changed. On XP, the
glasses form can import a highlighted complete OD/OS refraction from an open
Word chart; the values must be confirmed before they are copied or issued.

The first use creates RXOPTICAL.DBF/FPT/CDX and RXMED.DBF/FPT/CDX in the
configured shared database folder. Test only with a complete copied database first. Back up the full
server MOSt folder before any live pilot. This package never includes or
overwrites clinical database files.
