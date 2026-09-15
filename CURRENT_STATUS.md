# Current development status

Latest Windows XP test checkpoint: **V16.60**, executable/file version **1.7.661**.

The checkpoint includes the prescription repairs, optical import/sign handling, single-instance AB LetterBuilder workflow, approved Patients button layout, `L +C` combined action, initial Claims/LetterWriter positioning, active-MD report filtering, mapped K:/S: routing, Scheduler `schedata` shared-path startup, and Claims billing-MD persistence between patients.

The latest test package and source snapshot are in `development_v16_60/`. V16.51-V16.59 are intermediate test builds superseded by V16.60.

Remaining validation:

- Confirm `L +C` appearance and both-window behavior on the actual XP workstation.
- Confirm Claims retains `AB` through several patient changes using both Claims and `L +C`.
- Confirm Patients → Scheduler opens the shared server database without a local C: fallback.
- Continue prescription regression testing and later Windows 10/11 compatibility work.

No production database repair, packing, reindexing, or schema conversion is authorized by this checkpoint.