# MOSt V16.43 Windows XP test status

Executable version: `1.7.644`

## Repair in this build

- Reconcile's separate billing-MD selector now shows only physicians whose **Billing MD payment % is not 0**.
- `ALL DOCTORS` remains available when more than one active billing physician exists.
- All V16.42 prescription, LetterWriter, window-positioning, and report-filter repairs are retained.

## Verification

- Visual FoxPro form-method inspection confirmed `md.payment<>0` in the Reconcile selector.
- The executable compiled successfully and reports file/product version `1.7.644`.
- The installer archive contains 15 workstation files and no DBF/DBC/FPT/CDX patient-data files.

## Office test requested

Open Reconcile and confirm the billing-MD list contains only active physicians plus `ALL DOCTORS` when applicable.
