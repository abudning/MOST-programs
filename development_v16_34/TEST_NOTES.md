# V16.34 XP letter-list loading and window persistence

Executable: **1.7.635**

- LetterBuilder is fixed to AB.
- Patient loading performs ID mode, ID-box focus and Enter; if the first pass leaves the letter list empty, it repeats the complete ID-and-Enter pass.
- Same-patient clicks silently raise LetterBuilder.
- Existing Patients, Claims and LetterBuilder windows are not repositioned. Automatic placement applies only when a window is newly created, preserving all later manual moves.
- At 1024x768, slight initial Claims/LetterBuilder overlap is unavoidable because their combined heights exceed the desktop; the initial layout keeps LetterBuilder visible.

Build and metadata verified as 1.7.635. Package has 15 workstation files and no clinical database files.