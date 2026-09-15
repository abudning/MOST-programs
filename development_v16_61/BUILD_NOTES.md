WITHDRAWN: reported immediate Claims-opening crash on XP. See V16.62.

# V16.61 source checkpoint

This is the repaired source delta from V16.60, GitHub baseline commit
0d9e2f8 on codex/v16.28-verified in abudning/MOST-programs.
It is not a complete standalone Visual FoxPro project or fresh installation.

Source changes are in forms/enter_claims.scx+sct, forms/version.scx+sct,
programs/oms.prg and programs/openpatientclaim.prg.

The successful build used an isolated copy of the complete legacy VFP9 tree,
with these repairs overlaid, existing class references resolved to the copied
Classes folder, and empty database/table schemas used for compiler linking.
Database inputs remained excluded from the executable and are not included
in this checkpoint. Do not substitute production records for build inputs.

The native menu project entries were retained. The unused deleted/dispcrnt.prg
project entry was omitted because it references the unavailable DEMOG_V format;
no source/menu call to dispcrnt was found. No replacement format was invented.
The earlier menu-to-program conversion was discarded after the linker reported
a duplicate object name. The final build uses native BUILD EXE ... RECOMPILE.

build/build_v16_61.prg records the successful build procedure and local paths.
Adjust lcRoot for a new isolated build tree. It requires the complete legacy
source and project, including external libraries/assets and empty schemas.
The script does not include source-copy or empty-schema creation steps.

build/claims_regression.prg is a Visual FoxPro fixture using the repaired
methods and synthetic cursors. Its save checks write synthetic fee values;
they do not execute the full Claims form's Save event. Actual XP workflow
validation is outstanding. See README_V16.61.txt for the workstation checklist.

The compiled installer has not been run here. No live clinical data or server
installation was changed. GitHub has not been updated by this continuation.

