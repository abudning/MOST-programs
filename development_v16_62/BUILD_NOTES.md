# V16.62 Claims startup crash test candidate

Executable 1.7.663. V16.61 is withdrawn after an XP report of Menu Manager
internal consistency error and Microsoft Visual FoxPro closing immediately
when Claims is clicked, before its window appears.

The crash has not been reproduced locally. The targeted change restores the
original V16.60 billing-MD SQL RowSource and dropdown properties, removing the
new manual list rebuilding during Claims Init. Only the selected Value is
cleared/restored for non-radiology startup. Numeric premium/special-visit fee
storage and session physician memory remain. No fee tables or schema changed.

Build succeeded and updated synthetic VFP tests pass using the original SQL
source setup. Source verification confirms identical V16.60 dropdown properties
and that tested fee/MD helper bodies match production source. Full Claims
startup/save events and the XP crash itself remain unverified.

Build inputs and legacy DEMOG_V omission are as recorded in V16.61 BUILD_NOTES.
The menu generator is byte-identical to the V16.60 generator. Native menu project
entries are retained. This checkpoint contains source changes, not the complete
legacy project or linking schemas. No database records or credentials included.

First XP check: install on the test workstation, confirm 1.7.663 and open Claims.
If it fails, restore the known-working executable backed up before V16.61.
Follow README_V16.62.txt for additional fee and MD checks. GitHub is unchanged.
