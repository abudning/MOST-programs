# MOSt V14 test build

Built: 2026-09-01 America/Toronto

## Scheduler fixes

- Includes the legacy GravityBox scheduler runtime required by the embedded `schedule1` OLE control.
- Removes the recursive `QueryUnload -> btnExit.Click -> Release -> QueryUnload` shutdown path.
- Makes the temporary `undo_hstry` cleanup safe when the alias was never opened or was already closed.
- Deletes only the scheduler's exact DBF/FPT/CDX history files and only when they are in the current user's Temp directory.

## Required files beside the executable

- `MOST_V14_TEST.exe`
- `GbSchedule.ocx` 6.02.0430 (x86)
- `GbSubclass.ocx` 2.01.0022 (x86)
- `GbXMLParse.dll` 1.01.0014 (x86)
- `CVF50.FLL`
- `MCW32.dll`
- `CFHDR.H`

## Installation requirement

The three GravityBox files are legacy unsigned 32-bit components. On 64-bit Windows, run `Register_MOST_V14_Components.cmd` as Administrator before starting MOST. The script deliberately uses `C:\Windows\SysWOW64\regsvr32.exe`, which is the 32-bit registrar.

Do not replace or unregister the working components on the Windows XP production computer.

## Test status

- Forced VFP9 SP2 recompile completed.
- The executable contains the V14 scheduler cleanup code.
- Static package and checksum verification completed.
- Interactive scheduler testing on Windows 11 and regression testing on Windows XP are still required.
- Test only with complete copied database sets. Preserve Visual FoxPro 7-compatible DBF/DBC/CDX/FPT structures.
