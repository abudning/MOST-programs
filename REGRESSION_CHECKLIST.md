# MOSt release regression checklist

Use this checklist for every build derived from V16.68.6. A completed item is a required regression test, not an optional future feature.

## Completed — must remain working

- [ ] Executable file version remains `1.7.708` while the code-only test series is in use, so startup does not trigger a database upgrade.
- [ ] Help > About MOSt shows the trackable code build (`V16.68.6`) in the Customer/Client number field.
- [ ] Installer changes workstation program files only, creates a byte-verified rollback folder, and does not contain or alter databases or clinical data.
- [ ] Premium billing-code bubbles show the real non-zero fee; dollar-prefixed captions are converted correctly rather than becoming `0.00`.
- [ ] Claims retains Billing MD during the open Claims session and starts blank after Claims is closed and reopened.
- [ ] Patients uses the ID plus `L+C` workflow; redundant separate Claims, Letters, and letter-list controls remain hidden.
- [ ] LetterBuilder reads `DATA_FILES` from Parameters 2 and works against the mapped `K:\PROGRAM FILES\MOST\DATABASES\` path without a Locate File prompt.
- [ ] LetterBuilder includes Consult and Diagram; the button row remains Consult, Diagram, Letters, Exit without overlap.
- [ ] Consult preserves the current V16.67/V16.68 workflow and inserts at the exact `[[CONSULT]]` marker without closing the resulting Word consultation.
- [ ] The eye diagram includes both compact upper oblique entries on the nasal/centre side, not the temporal side; the centre-bottom entry remains fully visible.
- [ ] LetterBuilder document-lock handling does not leave a read-only Word copy open.
- [ ] Scheduler search and new appointments work.
- [ ] Patient labels and the TM-U220 layout remain correct.
- [ ] Existing report preview/print/PDF behavior remains available; Daily Summary, Check In, patient sheet, and patient label are smoke-tested.

## Planned or deferred

- [ ] Complete workstation acceptance of the consultation workflow with the real Word template and chart.
- [ ] Complete live LetterBuilder acceptance against the actual mapped K: drive and Parameters 2 configuration.
- [ ] Perform the broader report audit later; reports are accepted as-is for V16.68.6.
- [ ] Audit PDF completeness against the full clinical document collection when it is available.
- [ ] Resume saved-invoice edit/void and manual payment, overpayment, and refund work after this stable workstation build.

## Release gate

Before distributing a subsequent version, compare its source/payload with the last accepted version, run every applicable completed check above, record any intentional exception, and verify install plus rollback on a scratch workstation folder.
