# MOSt V16.14 workstation installers

Release label: **V16.14**  
Executable version: **1.7.611**

These are upgrade-only packages for existing MOSt workstations. They must not be run on Windows Server 2008. They contain no MOSt DBF, DBC, DCT, DCX, CDX, or FPT data files and do not update the shared server database.

## Packages

- `MOSt_Workstation_Upgrade_V16.14_Windows_XP.exe` — 32-bit self-extracting XP workstation upgrade.
- `MOSt_Workstation_Upgrade_V16.14_Windows_XP.zip` — platform-neutral XP fallback containing the same payload and install command.
- `MOSt_Workstation_Upgrade_V16.14_Windows_10_11.exe` — 32-bit self-extracting Windows 10/11 workstation upgrade.
- `MOSt_Workstation_Upgrade_V16.14_Windows_10_11.zip` — ZIP alternative containing the same payload and install command.

The installers are not digitally signed. Verify each file against `SHA256SUMS_V16.14.txt` before use. Windows may display an Unknown Publisher warning.

## Safety behavior

- Requires an existing local MOSt workstation installation.
- Refuses server-class Windows.
- Stops if `MOST.exe` is running.
- Saves the existing executable as `MOST_before_V16_14.exe` before replacement.
- Copies the Visual FoxPro runtime and scheduler controls locally.
- Registers the scheduler controls with the 32-bit registrar.
- Marks the current user installation as `WORKSTATION`.
- Copies no clinical, billing, patient, or database files.

## Required pilot

First use a complete copied dataset. Test one XP workstation and one Windows 10 or 11 workstation, including bidirectional reads and writes, before any production pilot. Leave Windows Server 2008 unchanged. The actual XP self-extractor and scheduler registration must be confirmed on the physical XP workstation because that operating system cannot be reproduced on the build computer.
