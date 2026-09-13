# V16.32 Windows XP patient-driven LetterBuilder switching

Executable version: **1.7.633**

When the single LetterBuilder instance is already displaying a different patient, the Patients-screen Letters button now enters the newly active patient ID through LetterBuilder's existing `search.Valid()` routine. This reuses the same established save/completion and patient-update sequence as entering the next patient number directly inside LetterBuilder.

`AB` remains selected throughout because the legacy letters are stored under AB. The V16.29 cross-workstation Word lock/read-only behavior is separate and unchanged.

Verification: the project compiled successfully, FileVersion and ProductVersion are `1.7.633`, and the installer contains 15 workstation files with no clinical database files.