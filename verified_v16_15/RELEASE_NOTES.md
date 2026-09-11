# MOSt V16.15 test build

- Claims now opens its `fees` cursor from the configured shared MOSt database,
  preventing claim entry from using an older workstation fee table.
- The workstation package supplies `CONFIG.FPW` with `RESOURCE=OFF` and starts
  MOSt with that configuration, avoiding the Visual FoxPro resource-file lock
  error on Windows 11 without requiring elevation.
- Running without elevation preserves the user's normal mapped drives, including
  the `K:` database mapping.
- V16.15 is explicitly treated as a code-only update from executable 1.7.611,
  preventing the legacy `upgrade.fxp` database-upgrade routine from starting.

Includes all cumulative V16.14 fixes. This remains a test release and does not
alter or copy clinical database files.
