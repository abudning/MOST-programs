# MOSt verified v13 checkpoint

Saved: 2026-08-31 America/Toronto

## Verified behavior

- Patient PDF access searches `S:\Charts` and its first-level folders.
- Tilde-delimited filenames match exact patient IDs or patient names in either order.
- Standalone `L`, `C`, and `T` filename tokens are ignored.
- All matching PDFs open automatically through the Windows PDF association.
- The PDF feature was confirmed working on Windows XP.
- EDT was confirmed working after its native support files were placed beside the executable.

## Required files kept together

- `MOST_V13_TEST.exe`
- `CVF50.FLL`
- `MCW32.dll`
- `CFHDR.H`

The production installer and upgrade package must install the three support files beside `most.exe`.

## EDT compatibility changes

- Writable EDT temporary files use `SYS(2023)\MOST_EDT` rather than `C:\Program Files\MOSt\TEMP\TEMPP`.
- EDT resolves `CVF50.FLL` relative to the running executable, avoiding the old hardcoded `C:\Program Files\MOSt` path.

## Safety

This snapshot contains application binaries, form definitions, and patch/build scripts only. It intentionally excludes patient databases, charts, credentials, logs, claims, and downloaded EDT files.
