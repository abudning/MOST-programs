# V16.64.3 XP test checkpoint

The full FoxPro 9 build produces `MOST_V16_64_3_1_7_683_TEST.exe` with file/product version 1.7.683. Synthetic billing and viewer tests pass.

The apparent hang was a hidden Locate File prompt for STP_FAXJOBS. The isolated copy lacked OMS.DBC/DCT/DCX after an earlier copy failed while a VFP process held them open. Restoring these files and recalling the excluded project database entry resolves the dependency without changing the trigger or adding a stub. The build script now checks for the metadata before compiling. `launch_v16_64_3.ps1` uses an explicit FPW COMMAND and requires fresh successful output, avoiding ambiguous command-line launches and stale outputs.

Additional source corrections move MD selection validation from form initialization to Save, avoid a Print button/method name collision, keep the physician footer populated after SCAN, and calculate claim unit price from quantity. The executable compatibility guard extends to 1.7.683.

The XP package upgrades an existing MOSt installation and includes the EXE, Claims form pair, English VFP9/C runtime, and report support applications. The installer backs up and binary-verifies existing files before replacing them, verifies replacements, and attempts rollback on copy failure. Patient data and configuration are not included.

Actual XP printing and normal workstation regressions remain acceptance checks. Saved-invoice edit/void, manual payment allocation, refunds, and the consultation merge fix remain subsequent work.
