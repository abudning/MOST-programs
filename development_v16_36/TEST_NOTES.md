# V16.36 XP delayed letter reload and position preservation

Executable: **1.7.637**

The patient loader first selects the patient normally, then uses a short one-shot timer to repeat the successful ID-and-Enter sequence after the first UI event cycle has completed. This is intended to populate the existing-letter list without requiring the operator to re-enter the ID manually.

Before every patient switch, the launcher captures LetterBuilder's Left, Top and WindowState. After the delayed Enter is processed, those exact values are restored. Automatic placement is limited to the first creation of LetterBuilder. On that first opening it is aligned directly below Claims with no gap; later manual moves persist.

Build and metadata were verified as 1.7.637. The package contains 15 workstation files and no clinical database files.

Test on copied data:

1. Open a patient with known letters and click Letters. Wait approximately one second and confirm the list appears automatically.
2. Move LetterBuilder manually, change the patient in Patients, and click Letters. Confirm the new list appears and LetterBuilder remains at the exact manually selected position.
3. Click Letters again for the same patient and confirm the existing LetterBuilder is brought forward silently.
4. Confirm the existing cross-workstation open-letter warning/read-only behavior is unchanged.
