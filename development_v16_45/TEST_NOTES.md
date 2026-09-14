# MOSt V16.45 Windows XP test status

Executable version: `1.7.646`

## Corrected database location

Drive `K:` is already mapped to the `most-Root` share on Server2008. Therefore the correct database path is:

`K:\Program Files\MOSt\databases\`

MOSt confirms that `oms.dbc` exists there, uses that folder, and saves the exact path into the workstation-local `PARAMETER2.DATA_FILES` field. V16.44 incorrectly repeated the share name as a subfolder and is superseded.

The installer does not copy, move, or alter shared clinical database files. All V16.43 repairs remain included.
