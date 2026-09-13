# Windows 10/11 compatibility plan after V16.28

Status: design approved for development; not yet a production release.

## Separation from Windows XP

- Keep V16.28/`1.7.629` as the working Windows XP baseline.
- Build and package Windows 10/11 separately.
- Do not change the Server 2008 executable or shared production databases.
- Preserve VFP7-compatible DBF/DBC/CDX/FPT structures while both workstation generations coexist.

## Local LETTERWR setting

The existing code reads `LETTERWR` from the workstation-local `OPTIONS` table. This is the setting displayed through **Setup → Options → Local Options**. `PARAMETER2` is a separate configuration table.

For Windows 10/11 only:

- Set the local `OPTIONS` record with `CODE='LETTERWR'` to `VALUELOG=.F.`.
- Disable legacy LetterBuilder editing and its old Word macros.
- Do not alter the XP workstation's local option.
- Do not alter a server/shared copy of either `OPTIONS` or `PARAMETER2`.
- Have the installer verify and report the local setting after configuration.

## Read-only letter and chart viewer

Add a Windows 10/11 command that opens an existing Word letter using Word automation with the `Documents.Open` `ReadOnly` argument set to true. The viewer must:

- open the original document read-only and never call Save on it;
- suppress legacy MOSt Word macros and LetterBuilder merge/edit behavior;
- clearly display **READ ONLY — changes cannot be saved to the chart**;
- permit printing if desired;
- handle a missing or unsupported file with a concise message;
- log only technical details, never letter content or patient data.

Read-only opening protects the original file from ordinary edits, although Word may still allow a user to save a separate copy elsewhere.

## Multi-workstation lock handling

Before any supported editable letter workflow opens a document:

1. Resolve the exact shared document path.
2. Check for Word's owner file (`~$...`) and perform a non-destructive availability check.
3. If another workstation owns the document, do not call the legacy editable-open path.
4. Show: **This letter is currently open on another workstation. Choose View Read-Only or Cancel.**
5. If View Read-Only is selected, open with `ReadOnly=.T.`.
6. If Cancel is selected, return immediately to MOSt.
7. Use a guarded error handler and timeout so Word automation cannot leave MOSt waiting indefinitely.
8. Treat stale owner files separately: do not delete one automatically; provide an administrator diagnostic after confirming Word is closed everywhere.

The owner-file check reduces the common lock case. The editable path should also keep an application-level lock token for the entire edit session to reduce race conditions between two nearly simultaneous opens.

## About MOSt diagnostics

Extend **Help → About MOSt** with a read-only **System Details** section containing:

- MOSt release and executable version;
- Windows version and workstation role;
- executable and local application paths;
- configured shared database path;
- database version;
- availability of `RXMED` and `RXOPTICAL`;
- effective `LETTERWR` value;
- detected Word version and read-only viewer availability;
- error-log location;
- a Copy Details button containing no patient data.

## Test sequence

1. Build from the consolidated V16.28 source baseline.
2. Install only on a Windows 10/11 test workstation connected to a complete copied database.
3. Confirm `LETTERWR=.F.` locally and unchanged on XP.
4. Open several legacy `.doc` letters read-only in a supported Word version.
5. Confirm Save cannot overwrite the original; printing remains available.
6. Open one letter for editing on an XP test workstation, then request it from the Windows 10/11 viewer and verify immediate read-only/cancel behavior.
7. Repeat the contention test in reverse and with two nearly simultaneous requests.
8. Simulate a stale Word owner file and verify it is reported but never automatically deleted.
9. Retest patients, appointments, scheduler, claims, EDT, PDF access and prescriptions.
10. Document rollback and acceptance criteria before a live pilot.
