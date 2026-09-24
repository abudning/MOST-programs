# MOSt V16.63.8 Premium Claims Cursor Fix

Build `1.7.672`.

Root cause: `modify_claims` uses a private data session, but its DataEnvironment did not open the `submited` table required by `check_bubble`. FoxPro then searched the local MOSt folder for a DBF and failed before showing the premium-code bubble.

This release starts from the untouched earlier form and adds `submited` as a DataEnvironment cursor through the existing server `OMS.DBC`. It does not rename or modify the server table.

Installer: `MOSt_V16.63.8_PREMIUM_CURSOR_XP.zip`
