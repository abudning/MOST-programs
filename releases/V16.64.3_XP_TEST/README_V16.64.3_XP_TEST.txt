MOSt V16.64.3 / 1.7.683 - Windows XP test workstation upgrade

READY TO INSTALL: the package contains the compiled MOST.exe, external Claims
form, Visual FoxPro 9 English runtime, C runtime, and reporting support apps.
This upgrades an existing MOSt workstation. It is not a blank-machine install.
Database files, patient data, drive mappings, and settings are not included.

INSTALL
1. Extract ALL files from the ZIP into one folder on the XP test workstation.
2. Close MOSt and sign in as a local Administrator.
3. Double-click Install-MOSt-V16.64.3-XP.cmd. Review the displayed destination.
   The default is C:\Program Files\MOSt. For a different installed folder run:
   Install-MOSt-V16.64.3-XP.cmd "D:\MOSt"
4. Start MOSt and confirm executable version 1.7.683.
5. Use a test database copy for billing checks; existing configured data paths
   are retained, so installing on a test machine alone does not change the data.

CHANGES
- Third Party manual invoice MD dropdown reads active physicians (payment<>0).
- Native HTML invoice review has Print invoice and Exit buttons.
- Invoice layout follows the supplied physician invoice sample.
- Fixed MD selection validation placement and Print control/method collision.
- Retains the earlier V16.64 premium-code bubble fix and billing work.
- V16.63.16 remains the known-good release.

TEST
1. Check premium-code bubbles and existing Claims functions.
2. Select a test patient, open Third Party, then New manual invoice.
3. Confirm both active MDs AB and HH are available and inactive MDs are absent.
4. Save an invoice with up to five descriptions/fees; verify cents and total.
5. Review the physician, patient, descriptions, amounts and payment balance.
6. Click Print invoice, confirm the XP printer dialog, and print a test page.
7. Click Exit and confirm you return to MOSt. Ctrl+P is an alternate print action.
8. Verify paid-history reprint and partial/credit balances on test records.

ROLLBACK
The installer verifies backups before replacing any files. It reports the
Upgrade_Backup_V16_64_3_<numbers> folder inside the MOSt installation.
Close MOSt and copy the backed-up MOST.exe, Claims form pair, and any backed-up
support files to the installation folder to restore the previous version.
The installer attempts this automatically if copying or verification fails.

VERIFICATION AND REMAINING WORK
VFP9 compilation and synthetic billing/invoice-control tests passed here.
Actual XP printer-driver behavior requires the workstation checks above.
Saved-invoice edit/void and the remaining payment/refund workflows are still
planned third-party billing work; this package is the V16.64.3 checkpoint.
The consultation merge issue remains pending.
