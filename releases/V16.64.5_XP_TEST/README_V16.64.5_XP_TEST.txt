MOSt V16.64.5 / 1.7.686 - XP test workstation upgrade

INSTALL
Extract ALL files into one folder on the XP workstation. Close MOSt and run
Install-MOSt-V16.64.5-XP.cmd as a local Administrator. The default existing
installation is C:\Program Files\MOSt. A different folder can be supplied as
the first argument. The installer verifies backups and replacement files.
No database files or patient data are included. Existing data paths are kept.

NEW WAITING-LIST LOOKUP
- Open Scheduler from the Patients tab. The separate Waiting List opens as
  before.
- Left-click a patient item in the Waiting List. Scheduler should immediately
  open its existing Find Appointment page and display that patient's matching
  appointments.
- Registered patients are matched by patient ID, preventing duplicate names
  from selecting the wrong patient.
- Unregistered/free-text patients use their exact stored surname, firstname,
  and phone value.
- Clicking a category or heading does not run a search. Existing drag-and-drop
  behavior remains unchanged.
- The click is read-only: it does not create, change, move, or delete an
  appointment.

XP ACCEPTANCE CHECKS
1. Confirm the normal Scheduler and Waiting List open successfully.
2. Click a waiting-list patient with one appointment; confirm it appears in
   the normal Find Appointment results.
3. Repeat with a patient having multiple appointments.
4. Repeat with a patient having no qualifying recent/future appointment and
   confirm the normal no-records message appears.
5. Test two patients with the same name and confirm the selected patient's ID
   controls the results.
6. Test an unregistered/free-text waiting-list patient.
7. Click Waiting List/Rebooked/category headings and confirm no patient search
   occurs.
8. Confirm the waiting-list selection remains available when returning and
   that booking still requires the operator's normal action.
9. Recheck printing, Claims, premium codes, manual invoices, and PDF access.

ROLLBACK
Close MOSt and restore the files from the reported
Upgrade_Backup_V16_64_5_<numbers> folder inside the installation directory.
V16.64.4 is the previous workstation-tested build and V16.63.16 remains the
known-good frozen release.

BUILD STATUS
The complete executable compiled successfully from a fresh isolated V16.64
source tree, avoiding the stale-project hidden compiler prompt. V16.65.1
consult-letter changes are not included. The occasional missed-PDF audit stays
deferred until the complete chart set is available.
