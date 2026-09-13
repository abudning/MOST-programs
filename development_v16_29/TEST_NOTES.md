MOSt V16.29 WINDOWS XP LETTERBUILDER LOCK TEST
Executable version: 1.7.630

This build carries forward the working V16.28 prescription repairs unchanged.

V16.29 repairs the active Windows XP LetterBuilder paths used when two
workstations request the same saved Word letter:

- Before editable open, MOSt checks Word's hidden owner file (~$...).
- If the letter is already open, MOSt does not call the legacy editable path.
- The user is asked to choose Yes to View Read-Only or No to Cancel.
- View Read-Only uses Word Documents.Open with ReadOnly set to true.
- Letter printing also opens its document read-only.
- MOSt never deletes a Word owner/lock file automatically.

TEST STATUS

The code compiles successfully and the executable metadata is verified as
1.7.630. This is not yet a two-workstation-verified release. Test it on copied
data with two Windows XP workstations before production use.

Required test:

1. Install V16.29 on both XP test workstations and use copied data.
2. Open a saved letter for editing on workstation A.
3. Request the same letter on workstation B.
4. Confirm B promptly offers Yes for read-only or No to cancel and does not freeze.
5. Choose Yes and confirm the original cannot be overwritten.
6. Repeat with No and confirm MOSt returns immediately.
7. Close Word on A and confirm the letter subsequently opens normally for editing.
8. Test Print while the letter is open elsewhere.
9. If a lock remains after Word is closed, do not delete it automatically; record
   the exact filename and confirm Word is closed on every workstation first.

This is an upgrade-only package for an existing Windows XP workstation.
DO NOT RUN IT ON WINDOWS 10/11 OR WINDOWS SERVER 2008.
It contains no MOSt DBF, DBC, DCT, DCX, CDX or FPT data files.
It does not copy or alter the server program or clinical databases.

Extract the complete ZIP, close MOSt and Word, and run the CMD installer using
a local Administrator account. Back up the full server MOSt folder before any
live pilot.
