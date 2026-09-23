# MOSt V16.63.5 Premium Claims Path Fix

Build `1.7.669`, based on V16.63.4.

The premium Claims bubble form now sets its working directory from `parameter2.data_files` before accessing the shared `submited.dbf` table. The server claims table is not copied, renamed, or modified.

Installer: `MOSt_V16.63.5_PREMIUM_CLAIMS_PATH_XP.zip`
