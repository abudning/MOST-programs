# V16.31 Windows XP LetterBuilder AB test

Executable version: **1.7.632**

V16.31 replaces the V16.30 XP test build.

- Removed invalid form-level `SetFocus()` calls.
- Patient-screen Letters loads the active patient and always selects mnemonic `AB`, matching the legacy storage identity used by existing letters.
- No physician picker and no `ALL DOCTORS` selection are used.
- LetterBuilder is placed below Patients if it fits, otherwise to the right, while remaining visible.
- The single-instance behavior remains shared by the patient button and Patients menu.
- No letter is opened or created automatically.
- V16.28 prescription and V16.29 Word lock repairs remain included.

Build verification: FileVersion and ProductVersion are `1.7.632`; the installer has 15 workstation files and no MOSt database files.
## Authorship note

Legacy letters remain stored under `AB`. If authorship must be determined, compare the letter date with Billing History to identify the physician who billed on that date. This is currently a rare manual audit and is not part of the LetterBuilder launch workflow.
