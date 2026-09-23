# MOSt V16.63.4 Premium Claims Fix

Build `1.7.668`, based on V16.63.3.

This release includes the matching `modify_claims.scx/.sct` files. The premium claim bubble routine now references the existing shared `submited.dbf` table instead of looking for `submitted.dbf` in the local MOSt folder.

The claims table is not renamed, copied, or modified. The installer backs up any existing form files before replacing them.

Installer: `MOSt_V16.63.4_PREMIUM_CLAIMS_XP.zip`
