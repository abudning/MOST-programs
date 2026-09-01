# V14 third-party runtime files

The V14 scheduler requires these legacy unsigned x86 GravityBox components:

| File | Version | SHA-256 |
|---|---:|---|
| `GbSchedule.ocx` | 6.02.0430 | `55F8E073B63534C635DDDA13C90E90FC90C9AE81BF5615ACD8EFD020FFED604A` |
| `GbSubclass.ocx` | 2.01.0022 | `88FA28B0EEE19E51CE01F2D8A4FE8F053DEDC0E995A77E9CEED33E14778A1E68` |
| `GbXMLParse.dll` | 1.01.0014 | `E9280B0A4C19D9E3077B78E7C310A8B9C0A462E1735791AE56815902DB1D55D0` |

They are intentionally not committed to this public repository because they are third-party proprietary binaries and redistribution rights have not been established.

The verified local copies are stored outside GitHub under:

```text
E:\MOST for chat\oms_vfp9_build\output\GB info
```

The complete local V14 test package is:

```text
E:\MOST for chat\oms_vfp9_build\output\MOST_V14_TEST_PACKAGE.zip
```

On 64-bit Windows, registration must use the 32-bit registrar at `C:\Windows\SysWOW64\regsvr32.exe`.
