MOSt V16.64.4 / 1.7.684 - XP test workstation upgrade

INSTALL
Extract ALL files into one folder on the XP workstation. Close MOSt and run
Install-MOSt-V16.64.4-XP.cmd as a local Administrator. The default existing
installation is C:\Program Files\MOSt. A different folder can be supplied as
the first argument. The installer verifies backups and replacement files.
No database files or patient data are included. Existing data paths are kept.

FIXES
- Paid billing history opens from the configured data path for the selected
  patient and shows all doctors together. The doctor dropdown is removed.
- Empty history is handled without legacy date controls or invalid dates.
- History is read-only and uses a separate data session, preserving the
  outstanding invoice screen and its selections.
- Select a history row and click Review / Print selected to open that invoice.
- Both the Third Party menu and the outstanding-invoice History button use
  the repaired history route.
- The HTML viewer allows browser dialogs, focuses the document before Print,
  and tries the document print method if the native command fails.

XP ACCEPTANCE CHECKS
1. Open a patient with paid third-party records and choose Paid billing history.
2. Confirm records for both AB and HH appear without selecting a doctor.
3. Check a patient without history: the empty message should appear and Print
   should be disabled. No error or invalid-date prompt should occur.
4. Select a paid invoice, click Review / Print selected, then Print invoice.
   Check the actual XP print dialog and output. Ctrl+P remains an alternate.
5. Exit history and confirm the outstanding invoice screen is preserved.
6. Recheck manual invoice saving, Claims, premium-code bubbles and PDF access.
Use test data for write operations.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_64_4_<numbers> folder inside the installation directory.
V16.63.16 remains the known-good release. V16.64.3 is the previous test package.

The full build and synthetic patient-history, empty-state, doctor lookup,
cursor-isolation, invoice, storage and rollback checks passed here. Actual
XP printer-driver behavior remains a workstation acceptance check.
Edit/void, expanded payment/refund workflows and consultation merge remain
subsequent work.
