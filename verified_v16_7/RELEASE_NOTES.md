# MOSt V16.7 test build

Fixes the actual error recorded in MOSt_Error_msg.log at GOTO TOP. The updater no longer assumes numeric work area 8. It creates fee_import_cursor and selects, counts, scans, and advances that cursor exclusively by alias. This avoids collisions with any tables already occupying work area 8.

Includes the explicit server table paths and shared fee-table access from V16.6.
