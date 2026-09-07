# MOSt V16.3 test build

Built September 7, 2026 from the Visual FoxPro 9 source tree.

## Fee updater repair

- Uses a new private in-memory import cursor instead of the shared temp.dbf.
- Prevents stale, locked, or corrupted temp.dbf from stopping the import at line 138.
- Appends new codes without thousands of status windows and reports progress every 100 records.
- Backs up fees.dbf and its related files before making changes.
- Accepts the Ministry ZIP, text, or extracted .001 file.

## Cumulative changes

- Recreated EDT submissions and all EDT input/output use the configured server folders.
- Installations are marked Server or Workstation.
- No application expiry; About displays No expiry.
- Scheduler repair from V14 is included.

Close every running copy of MOSt before testing. Back up live data and verify this test build against copied data before production use.
