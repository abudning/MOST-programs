# MOSt V16.4 test build

Corrects the V16.3 fee-import cursor name collision with the TEMP table registered in OMS.DBC. The updater now uses the unique private alias fee_import_cursor and never opens or modifies temp.dbf.

This package includes all cumulative V16.3 changes. Close all MOSt instances, back up live data, and test against copied data before production use.
