# V16.35 XP deterministic letter reload and position preservation

Executable: **1.7.636**

The patient loader now performs the full ID `Valid()`/`LostFocus()` lifecycle twice, reproducing the manual second ID entry that displays the current letter list. Before switching, the launcher captures LetterBuilder's Left, Top and WindowState and restores them afterward. Automatic placement is therefore limited to initial creation; all manual moves persist.

Build and metadata verified as 1.7.636. Package contains 15 workstation files and no clinical database files.