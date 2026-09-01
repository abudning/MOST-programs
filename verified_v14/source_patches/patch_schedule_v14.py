import re
import struct
import sys
from pathlib import Path


def read_layout(dbf):
    record_count = struct.unpack("<I", dbf[4:8])[0]
    header_len, record_len = struct.unpack("<HH", dbf[8:12])
    fields = []
    pos = 32
    offset = 1
    while dbf[pos] != 0x0D:
        descriptor = dbf[pos:pos + 32]
        name = descriptor[:11].split(b"\0", 1)[0].decode("ascii").upper()
        kind = chr(descriptor[11])
        length = descriptor[16]
        fields.append((name, kind, length, offset))
        offset += length
        pos += 32
    return record_count, header_len, record_len, fields


def read_memo(fpt, block_size, raw_pointer):
    block = struct.unpack("<I", raw_pointer[:4])[0]
    if not block:
        return ""
    start = block * block_size
    length = int.from_bytes(fpt[start + 4:start + 8], "big")
    return bytes(fpt[start + 8:start + 8 + length]).decode("cp1252")


def append_memo(fpt, block_size, text):
    payload = text.encode("cp1252")
    block = (len(fpt) + block_size - 1) // block_size
    start = block * block_size
    if len(fpt) < start:
        fpt.extend(b"\0" * (start - len(fpt)))
    blob = (1).to_bytes(4, "big") + len(payload).to_bytes(4, "big") + payload
    fpt.extend(blob)
    next_block = (len(fpt) + block_size - 1) // block_size
    fpt.extend(b"\0" * (next_block * block_size - len(fpt)))
    fpt[0:4] = next_block.to_bytes(4, "big")
    return block


form_path = Path(sys.argv[1])
memo_path = form_path.with_suffix(".SCT")
dbf = bytearray(form_path.read_bytes())
fpt = bytearray(memo_path.read_bytes())
block_size = int.from_bytes(fpt[6:8], "big") or 512
record_count, header_len, record_len, fields = read_layout(dbf)
field_map = {name: (kind, length, offset) for name, kind, length, offset in fields}

cleanup = """* V14: close and remove the per-form undo history exactly once.\r\nLOCAL lcHistoryFile, lcHistoryDir, lcTempDir, lcDeleteFile\r\nlcHistoryFile = ALLTRIM(THISFORM.history_file)\r\nTHISFORM.history_file = \"\"\r\n\r\nIF USED(\"undo_hstry\")\r\n    USE IN undo_hstry\r\nENDIF\r\n\r\nIF NOT EMPTY(lcHistoryFile)\r\n    lcHistoryDir = LOWER(ADDBS(JUSTPATH(FULLPATH(lcHistoryFile))))\r\n    lcTempDir = LOWER(ADDBS(FULLPATH(SYS(2023))))\r\n    IF lcHistoryDir == lcTempDir\r\n        lcDeleteFile = FORCEEXT(lcHistoryFile, \"dbf\")\r\n        IF FILE(lcDeleteFile)\r\n            ERASE (lcDeleteFile)\r\n        ENDIF\r\n        lcDeleteFile = FORCEEXT(lcHistoryFile, \"fpt\")\r\n        IF FILE(lcDeleteFile)\r\n            ERASE (lcDeleteFile)\r\n        ENDIF\r\n        lcDeleteFile = FORCEEXT(lcHistoryFile, \"cdx\")\r\n        IF FILE(lcDeleteFile)\r\n            ERASE (lcDeleteFile)\r\n        ENDIF\r\n    ENDIF\r\nENDIF"""

new_release = """PROCEDURE Release\r\n\r\n* V14: let the base Release invoke QueryUnload once.\r\nNODEFAULT\r\nDODEFAULT()\r\n\r\nENDPROC"""

new_exit = """PROCEDURE Click\r\n* V14: QueryUnload owns cleanup; do not close the alias here.\r\nTHISFORM.RELEASE\r\nENDPROC\r\n"""

changes = []
for record_number in range(1, record_count + 1):
    record_start = header_len + (record_number - 1) * record_len
    obj_kind, obj_length, obj_offset = field_map["OBJNAME"]
    methods_kind, methods_length, methods_offset = field_map["METHODS"]
    obj_raw = dbf[record_start + obj_offset:record_start + obj_offset + obj_length]
    methods_raw = dbf[record_start + methods_offset:record_start + methods_offset + methods_length]
    objname = read_memo(fpt, block_size, obj_raw).strip().lower()
    methods = read_memo(fpt, block_size, methods_raw)
    updated = methods

    if objname == "scheduleform":
        updated, tail_count = re.subn(
            r"\* Erick 2004\.07\.26\s*ThisForm\.btnexit\.Click",
            cleanup,
            updated,
            count=1,
            flags=re.IGNORECASE,
        )
        updated, release_count = re.subn(
            r"PROCEDURE Release\s+NODEFAULT\s+this\.QueryUnload\s+DODEFAULT\(\)\s+ENDPROC",
            new_release,
            updated,
            count=1,
            flags=re.IGNORECASE,
        )
        if (tail_count, release_count) != (1, 1):
            raise RuntimeError(
                f"scheduleform replacements were tail={tail_count}, release={release_count}"
            )
        changes.append((record_number, objname, "cleanup and release"))
    elif objname == "btnexit":
        updated = new_exit
        changes.append((record_number, objname, "click"))

    if updated != methods:
        new_block = append_memo(fpt, block_size, updated)
        dbf[record_start + methods_offset:record_start + methods_offset + 4] = struct.pack(
            "<I", new_block
        )

if len(changes) != 2:
    raise RuntimeError(f"expected two changed records, got {changes}")

form_path.write_bytes(dbf)
memo_path.write_bytes(fpt)
for change in changes:
    print(f"record={change[0]} object={change[1]} change={change[2]}")
