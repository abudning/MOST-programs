# MOSt V16.16 test build

- Claims now opens its `fees` cursor from the configured shared MOSt database,
  preventing claim entry from using an older workstation fee table.
- The workstation package supplies `CONFIG.FPW` with `RESOURCE=OFF` and starts
  MOSt with that configuration, avoiding the Visual FoxPro resource-file lock
  error on Windows 11 without requiring elevation.
- Running without elevation preserves the user's normal mapped drives, including
  the `K:` database mapping.
- V16.15 is explicitly treated as a code-only update from executable 1.7.611,
  preventing the legacy `upgrade.fxp` database-upgrade routine from starting.

## V16.16 correction

- Setup > Modify Labels now uses the detected local MOSt application directory
  instead of the XP-only `C:\Program Files\MOSt\LABELS` path. This supports both
  `Program Files` and `Program Files (x86)` installations.

Includes all cumulative V16.15 fixes. This remains a test release and does not
alter or copy clinical database files.
