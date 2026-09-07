# MOSt V16.13 test build

Fixes the Fee Codes display data source. The form previously opened ..\databases\oms.dbc beside the executable while the updater correctly changed K:\Program Files\MOSt\databases. Its data environment now sets the fees and claims cursors to the configured path_to_data server database before opening tables.

Includes cumulative V16.12 fee reconciliation fixes.
