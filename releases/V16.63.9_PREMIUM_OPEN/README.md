# MOSt V16.63.9 Premium Claims Explicit Open

Build `1.7.673`.

The `modify_claims.check_bubble` routine now explicitly opens the submitted-claims table from `path_to_data`, which is loaded from `parameter2.data_files`. It checks `submitted.dbf` first and the legacy `submited.dbf` spelling second, then opens the existing server table with alias `submited` as required by the original premium calculation.

This addresses the failure that occurred while tabbing from premium service code E877A to the number field. The server DBF is only opened shared and is not renamed or copied.

Installer: `MOSt_V16.63.9_PREMIUM_OPEN_XP.zip`
