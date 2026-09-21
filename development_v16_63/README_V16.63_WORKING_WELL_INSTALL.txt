MOSt V16.63 WORKING WELL Windows XP workstation upgrade
Executable version: 1.7.664

This installer upgrades an EXISTING Windows XP workstation. It replaces only
C:\Program Files\MOSt\MOST.exe. It does not install on a new computer, change
medical databases, or alter patient charts. Keep V16.62 available for rollback.

INSTALL
1. Extract ALL files from the ZIP to a folder on the XP workstation.
2. Close MOSt and sign in as a local Administrator.
3. Run Install-MOSt-V16.63-XP.cmd. The script checks XP, confirms MOSt is
   closed, backs up the existing executable, copies V16.63, and verifies it.
4. Start MOSt using the existing shortcut. Check version 1.7.664.

TEST FIRST
- Open LetterBuilder from the Patients menu; confirm no FoxPro error.
- Delete a test letter; confirm No cancels and Yes moves it to deleted files.
  Recover that test letter through the existing recovery path.
- Import a glasses Rx with an Add value. Check plus signs and print output.
  Test zero prism and nonzero prism. Test mismatched Patients/LetterBuilder IDs.
- Open L+C with an empty old claim and with an unfinished claim.
- Enter a new health card on Patients; confirm the Add Patient prompt and form.
- Check referring-MD phone/fax boxes and a sample Word fax output.
- Open Claims and L+C repeatedly for different patients. An empty Claims form
  should now be reused in place, preserving OHIP or Third Party type.
- Open LetterBuilder. The physician selector is hidden and the letter uses AB.

The user reports premium code billing now works on the system; this update does
not change premium logic. Referral PDF speed and visual-fields office billing
are not fixed in this build. V16.63 has been reported working well on the workstation, but these workflows
have not been functionally verified on the XP workstation.

ROLLBACK
Close MOSt. Copy MOST.exe from the Upgrade_Backup_V16_63_* folder created
by the installer over C:\Program Files\MOSt\MOST.exe. The installer also
restores the previous executable automatically if the copy/verification fails.

The package contains only the executable, installer, and this README. It has no
medical databases, charts, or credentials. Do not run this on the server.


CHART PDF DRIVE MAPPING
-----------------------
The working chart share is the server D share.

On workstations, S: may be mapped to the server D share. The PDF search should resolve both S:\ and the server D share to the same chart root.
Do not use a separate server charts share as the chart root. If a configured path ends in \charts, normalize it back to the working D share root when needed.
