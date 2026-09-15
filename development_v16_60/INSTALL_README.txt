MOSt V16.60 Windows XP workstation upgrade - TEST CHECKPOINT
Executable version: 1.7.661. Application built September 14, 2026.

INSTALL
1. Copy this ZIP to the Windows XP test workstation and extract ALL files.
2. Close MOSt and sign in as a local Administrator.
3. Double-click Install-MOSt-V16.60-XP.cmd.
4. Start MOSt using your existing shortcut and confirm version 1.7.661.
5. Complete TEST_NOTES.md using a complete copied test database.

Requires an existing working MOSt installation at C:\Program Files\MOSt
(or the workstation's equivalent %ProgramFiles% path), its existing VFP9
runtime/components, and the configured K: database and S: Charts mappings.
This is an executable-only upgrade, not a fresh installation or runtime setup.
The installer uses XP's WMIC, tasklist and net session for prerequisite checks.
If those checks cannot run, installation stops.

BACKUP AND ROLLBACK
The script displays a unique Upgrade_Backup_V16_60_* folder under MOSt.
It verifies the backup and installed executable byte-for-byte.
To roll back, close MOSt and copy MOST.exe from that backup folder over
C:\Program Files\MOSt\MOST.exe. Keep the backup until testing is complete.

No database files, charts, credentials or logs are included. The installer
changes only the local MOST.exe and creates its executable backup folder.
No runtime registration, configuration edits, or server installation occurs.

Includes prescription repairs and optical import/sign handling, Patients
layout and L +C, LetterWriter positioning, shared Scheduler startup, and
Claims billing-MD persistence. XP functional checks remain outstanding.
The installer script was inspected but has not been run on Windows XP.
