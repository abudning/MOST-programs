# V16.33 Windows XP three-window workflow

Executable version: **1.7.634**

## LetterBuilder

- Defaults to `AB` from either entry point.
- The patient-screen sequence invokes ID mode, copies the active patient number into LetterBuilder, focuses the ID/search control, and sends Enter.
- Selecting another patient on Patients and pressing Letters uses the same ID-plus-Enter sequence in the existing LetterBuilder.
- If the same patient is already displayed, the existing LetterBuilder is raised silently.

## Layout

- Claims opened from Patients is positioned to the right of Patients.
- New Patients menu command: **Patient / Claims / Letters**.
- It opens/reuses Patients at top-left, Claims to its right, and LetterBuilder below Claims and right of Patients.
- All positions are clamped to the visible MOSt desktop, and matching windows are reused.

The V16.29 cross-workstation Word owner-file protection remains separate and unchanged.

Build verification: successful; FileVersion/ProductVersion `1.7.634`; generated menu contains the new command; installer has 15 workstation files and no clinical databases.