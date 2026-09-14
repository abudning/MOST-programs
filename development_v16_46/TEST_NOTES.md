# MOSt V16.46 Windows XP test status

Executable version: `1.7.647`

The Patients form no longer relies on legacy relative `..\databases\` references. Its shared cursors explicitly use the configured database folder for `oms.dbc`, `letters.dbc`, and `schedata.dbc`. The workstation-specific OPTIONS cursor continues to use local `oms_local.dbc`.

The correct mapped database location remains `K:\Program Files\MOSt\databases\`. No shared database files are included or modified.
