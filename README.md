# MOSt Visual FoxPro 9 upgrade progress

Saved: 2026-08-23

## Current result

- The Visual FoxPro 7 source builds under Visual FoxPro 9 SP2 x86.
- The compatibility test executable is version `1.7.611` and has started successfully on the Windows XP test machine.
- The build retains the legacy database-version safeguard.
- No production databases were changed by this work.

## Test executable

- File: `MOSt_vfp9_test.exe`
- SHA-256: `9A9F3C623B402F42798DC299F450ECD9173B208C2BDAEB9654120AC9B6F0B6FA`
- Intended use: controlled testing with complete copied database sets only.

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

