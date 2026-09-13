# V16.38 XP direct letter list and glasses import spacing repair

Executable: **1.7.639**

- After patient validation, LetterBuilder directly calls `onemd_letterlist()` for AB and refreshes the list and form. It no longer depends on a focus transition to build the list.
- Glasses OD/OS parsing removes spaces and tabs before matching. Inputs such as `OD: +2.5 + 2.5 x 90`, `OD: +2.5+2.5x90`, and `OD: +2.50+2.50x90` are accepted.
- Initial no-gap placement and manual-position preservation remain unchanged.

Package contains 15 workstation files and no clinical database files.
