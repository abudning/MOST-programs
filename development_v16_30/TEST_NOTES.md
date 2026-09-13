# V16.30 Windows XP LetterBuilder test

Executable version: **1.7.631**

This test build carries forward the V16.28 prescription repairs and V16.29 Word owner-file/read-only handling.

## Change

Both XP entry points now use `openletterwriter.prg`:

- The patient-screen **Letters** button opens LetterBuilder for the current patient without opening or creating a letter.
- **Patients > Letter Builder** opens the general LetterBuilder without opening or creating a letter.
- Only one LetterBuilder form is allowed per workstation.
- A repeat launch restores/focuses the existing form and displays that LetterBuilder is already open.
- If the existing form is associated with another patient, MOSt requires it to be closed first and does not silently retarget it.

## Verification

- VFP build completed successfully on 2026-09-13.
- FileVersion and ProductVersion are both `1.7.631`.
- Patient button method calls `DO openletterwriter WITH patients.id`.
- Patients menu generated code calls `DO openletterwriter`.
- V16.29 multi-workstation lock marker remains present.
- Installer ZIP contains 15 workstation files and no DBF/DBC/DCT/DCX/CDX/FPT files.

This remains a test build until the documented XP workflow is tested with copied data.