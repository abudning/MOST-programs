# MOSt V16.50 Windows XP test status

Executable version: `1.7.651`

## Included repairs

- Prescriptions, prescription history, medication/glasses printing, physician/CPSO display, signed optical values, and flexible optical import retained.
- LetterBuilder patient loading, AB default, one-instance behaviour, detail-panel population, and operator window-position retention retained.
- Active billing-MD filtering retained, including the Reconcile selector.
- Correct workstation database location: `K:\Program Files\MOSt\databases\` because K: is already mapped to the `most-Root` share.
- All 294 shared form cursor references use the K: `oms.dbc`, `letters.dbc`, or `schedata.dbc`; all 29 `oms_local.dbc` references remain workstation-local.
- All 85 form data environments suppress TALK/ECHO/CONSOLE/status output so K: paths and commands are not painted over the MOSt screen.
- Referral PDF/chart search uses `S:\` because S: is mapped directly to the Charts share.

## Intermediate builds

- V16.44 repeated the K: share name and is superseded.
- V16.45 corrected the K: root.
- V16.46-V16.49 progressively expanded form routing and display cleanup and are superseded by V16.50.

## Current observation under monitoring

An intermittent Microsoft Word message, `Preparing to copy`, appeared after opening an existing letter and estimated approximately eight minutes. Cancelling left the letter visible and usable. This appears to be a legacy Word/mail-merge conversion rather than a database or chart copy. If it repeats, record the patient number, letter date, whether Word was already open, and whether the same letter reproduces it.

## Package safety

The installer archive contains workstation program/runtime files only. It includes no DBF, DBC, FPT, CDX, or clinical chart files and does not move shared data.
