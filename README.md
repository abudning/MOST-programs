# MOSt Visual FoxPro 9 upgrade progress

Saved: 2026-08-23 17:10 America/Toronto

## Current result

- The Visual FoxPro 7 source builds under Visual FoxPro 9 SP2 x86.
- The compatibility test executable is version `1.7.611` and has started successfully on the Windows XP test machine.
- The build retains the legacy database-version safeguard.
- No production databases were changed by this work.
- The VFP9 test executable now starts on the Windows 11 machine (`ANDYAMD`) and reaches the main menu/forms.
- Windows 11 local installation path is `C:\Program Files (x86)\MOSt\`.
- The XP-hosted production data is mapped on Windows 11 as `K:`.

## Test executable

- File: `MOSt_vfp9_test.exe`
- Current build timestamp: `2026-08-23 16:59:46`
- Current SHA-256: `06A10C73D7141FC6FB388953A631672C3DA018B6CCE40E266E272115852B894C`
- Intended use: controlled testing with complete copied database sets only.

## Windows 11 compatibility fixes completed

- Initialized `gc_datadrive` before the legacy startup error handler can run.
- Made `ERR_FIX.PRG` safe when startup globals do not yet exist.
- Diagnostic errors are written to `%TEMP%\MOSt_Error_msg.log`.
- Replaced local `C:\Program Files\MOSt` assumptions with the executable's actual folder.
- Made the optional `MOSt.chm` help file non-fatal when absent.
- Moved writable per-workstation state to `%LOCALAPPDATA%\MOSt`.
- Stopped workstation startup from trying to provision directories on the XP share.
- Corrected local and server executable-version lookups.
- Added fallback from the stale local `C:\Program Files\MOSt\databases` setting to the mapped XP data at `K:\Program Files\MOSt\databases` (including an x86 variant).
- Corrected `OPTIONS.DBF` paths used by the main menu, EDT, billing, and server-option routines.

## Current blocker on Windows 11

- MOSt loads, but saving a claim fails with VFP error 111:
  `Cannot update the cursor CLAIMS, since it is read-only.`
- Logged at `2026-08-23 17:02:29`, procedure `CLAIMS.SAVE.CLICK`, line 171 in `ENTER_CLAIMS.SCT`.
- Windows 11 can create/read/write ordinary files on `K:`, but cannot clear the read-only state reported for the XP-hosted database/container files.
- A subsequent report says access is denied in the database container.
- This indicates an XP-side file attribute, NTFS/share permission, or active-file lock affecting `OMS.DBC`/`OMS.DCT`/`OMS.DCX` and/or `CLAIMS.DBF`/`CLAIMS.CDX`. Do not work around this by copying or deleting individual database components.

## Resume point

1. On the XP machine, close MOSt, Remind My Patient, and any process/service using the MOSt databases; verify no `MOST.EXE`/FoxPro process remains.
2. Make a complete backup of `C:\Program Files\MOSt\databases` before changing attributes or permissions.
3. From an XP administrator command prompt, inspect/clear read-only attributes on the matching DBC/DCT/DCX and DBF/CDX/FPT sets.
4. Verify both XP share permissions (Change + Read) and XP NTFS permissions (Modify) for the identity used by Windows 11.
5. If an `attrib` command fails, capture the exact command, filename, and message.
6. Retest claim saving only after permissions are corrected, with MOSt closed on the XP machine during the controlled test.

## Mandatory compatibility requirement

The upgraded program must preserve Visual FoxPro 7-compatible DBF/DBC/CDX/FPT structures so the original XP application can read and update the same database during transition. Do not introduce VFP9-only field types or database features.

## Known data issues (repair later, on copies only)

- `appointmentserror.DBF`: header record count conflicts with its payload.
- `temperr.DBF`: header declares records that are not present.
- `LETTERTEXT.DBF`: required `LETTERTEXT.FPT` is missing; restore the matching DBF/FPT pair from a working set or backup.
- `ra_error20011002.DBF`: structural index flag is present but its CDX is missing.
- `SCHEDATAold.DBC`: DCX is missing.
- The legacy `PARAMETER2.DATA_FILES` value and hard-coded `Program Files\MOSt` paths require modernization.

## Safety rules

- Never repair, pack, reindex, or upgrade the only production copy.
- Never commit patient databases, logs, credentials, claims/EDT files, or card data to GitHub.
- Test old-to-new and new-to-old writes sequentially on copied data.
- Do not run `MOStUpDbc.exe` until its changes are documented and verified.

## Next work

1. Complete the functional test checklist on copied data.
2. Centralize local application and shared database paths.
3. Repair and validate damaged database files on a separate copy.
4. Test Word 2000/2003 automation and letter printing.
5. Package the VFP9 runtime and required x86 components in a workstation installer.
6. Pilot on one Windows 10/11 workstation with a documented rollback.

## Mandatory next-release packaging item

- Include an updated **workstation-local** `PARAMETER2.DBF` in the next release.
- Set `PARAMETER2.DATA_FILES` to the configured shared database location (normally `K:\Program Files\MOST\DATABASES\`).
- Do not overwrite or package the server's production `PARAMETER2.DBF` as the workstation-local configuration file.
- Run `Configure-MOST-Parameter2.ps1` during workstation setup when the server path differs from the packaged default.
- Before release, verify that MOST opens and can update patients, claims, appointments, scheduler data, DBF indexes/memos, and DBC container files through the configured path.
- Preserve compatibility with the original XP/VFP7 database structures during transition.

## Verified v13 checkpoint — 2026-08-31

- Added a patient-screen PDF button using `S:\Charts`.
- PDF matching treats `~` as the filename separator, matches an exact patient ID anywhere, accepts last/first or first/last order, and ignores standalone `L`, `C`, and `T` category tokens.
- One PDF opens immediately; multiple matching PDFs all open immediately in Adobe.
- Confirmed the v11 PDF behavior on Windows XP.
- Updated EDT temporary-file handling to use the writable Windows user Temp folder instead of protected `C:\Program Files` paths.
- Updated EDT to locate `CVF50.FLL` beside the running executable rather than using a hardcoded 32-bit installation path.
- Confirmed EDT works when `CVF50.FLL`, `MCW32.dll`, and `CFHDR.H` are beside the v13 executable.
- The final clean installer and upgrade package must install those three support files beside `most.exe`.
- No patient charts, medical databases, credentials, or EDT operational files are included in the v13 snapshot.
