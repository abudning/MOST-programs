# MOSt V16.17 workstation installation and testing

## Before installation

1. Begin with a complete copied MOSt database and copied application environment.
2. Close MOSt on the test workstation.
3. Extract the complete ZIP to a new folder. Do not run the installer from inside the ZIP.
4. Keep the prior workstation installer and executable for rollback.

## Windows XP

Run `Install-MOSt-V16.17-XP-Workstation.cmd` while signed in as a local Administrator. Start MOSt normally after installation.

For Word import, open the correct patient's chart in Word 2000 or Word 2003. The most reliable initial test is to highlight the complete Refraction heading plus the OD and OS lines before clicking **Import from Word**.

## Windows 10 or 11

Right-click `Install-MOSt-V16.17-Workstation.cmd` and choose **Run as administrator**. After installation, start MOSt normally, not as administrator, so normal mapped drives remain available.

Word is not required to create a manual prescription, view prescription history, view a saved glasses prescription or preview/print it.

## Test sequence

1. Open a test patient and confirm the new **New Rx** button is visible.
2. Choose **Medication** and confirm the existing medication-prescription screen opens with the correct patient and Billing MD default.
3. Choose **Glasses**, enter a complete sample and save it as Draft.
4. Open EMR, choose **Prescription History**, and confirm both medication and glasses records appear.
5. Open the draft, confirm it remains editable, and issue it only after verifying all values.
6. Reopen the issued record and confirm it is read-only.
7. Preview/print the issued glasses prescription without Word.
8. On XP, import a highlighted sample refraction and confirm the proposed OD/OS values before accepting them.
9. On Windows 10/11, confirm the same issued record is readable without Word.
10. Test two workstations reading the same copied database and confirm normal locking.

Stop testing if the wrong patient is shown, values are parsed incorrectly, an issued prescription can be edited, a database-upgrade prompt appears, or any existing clinical table is changed unexpectedly.
