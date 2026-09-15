MOSt V16.60 / 1.7.661 COMPLETE VFP9 WINDOWS XP WORKSTATION PACKAGE
Based on your V16.47 full XP workstation upgrade package.

EXISTING XP MACHINE - ORIGINAL VFP7 OR EARLIER VFP9 MOST
Extract ALL files to a local folder. Close MOSt. Sign in as a local
Administrator. Run Install-MOSt-V16.60-XP-Workstation.cmd.
The installer replaces the local application, installs the private VFP9 SP2
runtime and supporting components, registers Scheduler components, adds
missing labels and Word templates, and creates shortcuts. Original VFP7
runtime files are left in place. Existing local databases, OPTIONS,
PARAMETER2, CONFIG.FPW, labels and existing Word Startup templates are kept.
Requires the existing installation at %ProgramFiles%\MOSt with a working
local databases\oms_local.dbc and parameter2.dbf.

NEW XP MACHINE
Run Install-MOSt-V16.60-NEW-XP-Workstation.cmd instead.
The target MOSt folder must not already exist. This supplies a workstation-
local configuration database, empty DAILY and MACROS tables, application
resources, runtime files, components and shortcuts. These local DBF/DBC files
contain no patient or claims records. New local defaults have blank printer
names, K:\Program Files\MOSt\databases\ as the shared data location and
LETTERWR enabled for XP. Configure workstation printers in MOSt before use.
No server clinical databases are supplied or installed.

BEFORE FIRST START
- Use Windows XP 32-bit with a local Administrator account for installation.
- Map K: to the existing MOST server root share so the database folder is
  K:\Program Files\MOSt\databases\.
- Map S: directly to the Charts share; V16.60 expects charts at S:\.
- Install/configure a default printer.
- Install the established XP-compatible Microsoft Word version for the legacy
  LetterBuilder workflow (normally Word 2000/2003 in this environment).
- Install a PDF reader and associate PDF files when chart PDF viewing is used.
- Use existing server credentials and MOSt accounts. No credentials included.
- Do not select SERVER when prompted for the workstation role.
- If installing under a different account, log in as the intended MOSt user,
  run Configure-MOSt-User.cmd, and grant that user Modify access to MOSt's
  local databases and working folders through XP folder Security settings.
  Setup grants these local permissions to the installing user only.

BACKUP / ROLLBACK
Setup displays a unique Setup_Backup_V16_60_* folder inside the local MOSt
folder. It backs up application/runtime files that it replaces, and verifies
copies byte-for-byte. It does not automatically roll back a partial install.
To restore an existing workstation: close MOSt, copy the files in that backup
back to the local MOSt folder, and re-register the restored GbXMLParse.dll,
GbSubclass.ocx and GbSchedule.ocx using regsvr32 if needed. Original local
configuration and VFP7 runtime files remain in place. Newly added resources
are not automatically removed. Preserve the backup until testing passes.
If new setup stops partway, correct the cause and preserve any local files
before retrying; the NEW launcher will refuse an already existing MOSt folder.

VALIDATION AND STATUS
This is the latest V16.60 test checkpoint, not a new executable build.
Includes prescription/history and optical import/sign repairs, LetterBuilder,
Patients layout, L +C, Scheduler shared-path startup and Claims MD persistence.
Follow TEST_NOTES.md and run prescription regression tests on copied data.
Package contents, executable version and archive integrity checked locally.
Installer and application have not been validated on an XP workstation here.
The installer does not modify shared data. MOSt itself can write shared data
in normal use and create RXMED/RXOPTICAL tables on first prescription use.
Back up the complete server MOSt folder before any later live pilot.
Do not run this workstation installer on Windows Server 2008.
