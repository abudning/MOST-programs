# V16.37 XP LetterBuilder list-focus repair

Executable: **1.7.638**

After the delayed patient validation, MOSt explicitly focuses the Letter Name control. Its legacy GotFocus routine builds the selected patient's existing-letter list. This addresses the state where only patient ID and name appeared.

Initial no-gap placement below Claims and operator-position preservation remain unchanged.

Package contains 15 workstation files and no clinical database files.
