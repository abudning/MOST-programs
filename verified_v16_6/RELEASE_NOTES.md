# MOSt V16.6 test build

The MOH fee updater now opens fees.dbf by its configured server path in shared mode. It no longer requires exclusive access or performs an unnecessary REINDEX. Index tags remain maintained automatically during record updates and appends. The isolated fee_import_cursor repair remains included.

Close older MOSt builds before testing and back up live data first.
