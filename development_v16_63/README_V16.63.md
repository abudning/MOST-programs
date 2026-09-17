# MOSt V16.63 test candidate

This is a Windows XP test build (project version 1.7.664), based on the local
V16.62 source. `MOST_V16_63_TEST.exe` compiled successfully in Visual FoxPro 9.
The `forms/` and `programs/` folders contain the changed source files; the
complete project and unchanged dependencies remain in `development_v16_62`.

Changes staged for workstation testing:

- Guard the Patients-form reference when LetterBuilder opens from the top menu.
- Ask for confirmation before deleting a LetterBuilder file. The existing
  deleted-file recovery path remains present.
- Import glasses Add values with a leading plus sign; show signed Rx fields in
  bold; omit the prism print line when all prism values are zero.
- Warn before Rx import when the active Patients or LetterBuilder patient ID
  differs from the Rx patient ID.
- When opening Claims for another patient, close empty Claims forms and warn
  about a form with service lines still present.
- Restore the new health-card prompt and Add Patient action from Patients.
- Widen referring-MD phone/fax controls; Word fax generation is unchanged.

This build has **not** been functionally verified on the XP workstation. Do not
replace the working V16.62 copy without keeping it available for rollback.
The Word chart itself is not yet checked for patient identity during Rx import.

The user reports premium code billing now works on the system. Still open: slow referral PDF retrieval,
and the visual-fields office billing field (fee code/photo needed).

The installable ZIP, XP upgrade script, and installation instructions are also in
this directory. The installer backs up and replaces the local executable only.
