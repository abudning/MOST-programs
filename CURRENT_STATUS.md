# Current development status

Latest Windows XP test candidate: **V16.63 / 1.7.664**.

V16.63 source changes, executable, checksum, and test notes are in
`development_v16_63/`. It compiles successfully but has not been functionally
verified on the XP workstation. The V16.62 package remains the last build the
user reported working on the system.

V16.62 source, executable-only upgrade, installer, checksum and test instructions
are in development_v16_62/. It restores the V16.60 billing-MD SQL dropdown setup
while retaining numeric premium/special-visit amounts and session MD memory.
The compiler and updated synthetic VFP tests pass. Full XP testing is incomplete.

## Latest workstation reports

- V16.61 is withdrawn: clicking Claims immediately caused Menu Manager internal
  consistency error / Microsoft Visual FoxPro encountered an error and closed.
- V16.62 was supplied as the targeted startup-crash test candidate. The user
  subsequently confirmed the premium workflow worked for A235. There is no
  explicit confirmation yet that every Claims-opening path is stable.
- E185 still reports that it does not accept a premium.
- Missing OHIP/Premium/required checkbox settings affect only newly imported
  codes; older codes retain their settings. This is not a confirmed mass reset.

## Investigation and next work

1. Claims rejects a base code when fillin_premium finds no matching premcodes
   association. The saved VFP7 reference has A235A associations, but no E185
   entry or E185 association. These reference tables are old and are not the
   actual current XP tables.
2. The Ministry fee import appends new rows with amounts/dates and sets OHIP,
   but does not populate MOSt-specific required flags or premium associations.
   Existing flags are not reset by the inspected importer.
3. Ontario's strabismus billing brief identifies E877 as a 30% repeat-procedure
   addition to E185/E184/E183/E182. Confirm the installed E877 fee classification,
   premium macro, time settings and base-code mappings before implementing a
   targeted repair on a complete copied test database.
4. Audit the current new-code configuration. Do not guess required flags for
   every new Ministry code or apply a blanket flag reset.
5. Test E185 + E877 using the existing right-click Premium / yellow-star return,
   save/reopen, decimal totals and the selected billing MD. Recheck A235 and
   prescription/Scheduler/letter workflows for regressions.

Official reference:
https://www.ontario.ca/document/education-and-prevention-committee-billing-briefs/strabismus-procedures

No E185/E877 configuration repair has been implemented yet. No live fee tables,
clinical databases or server installation were changed by this continuation.
The V16.61/V16.62 installers copy only the local MOST.exe and create a backup.
Their archives include no database records, charts or credentials.

Fee form checkbox definitions/methods match the prior source. Class-library
references were resolved to the copied Classes folder during compilation;
therefore the form file itself is not claimed to be byte-identical.

## Resume locations

Local complete isolated build tree:
C:\Users\abudn\Documents\Codex\2026-09-15\ple\work\v16_62_build

Local repository:
C:\Users\abudn\Documents\Codex\2026-09-15\ple\work\MOST-programs

The GitHub checkpoint is a source delta, not the full legacy project/linking
schemas. See development_v16_62/BUILD_NOTES.md and README_V16.62.txt.
