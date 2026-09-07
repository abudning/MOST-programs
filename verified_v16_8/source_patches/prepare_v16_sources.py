from pathlib import Path
import re
import shutil

ROOT = Path(r"E:\MOST for chat\oms_vfp9_build")
MOST = ROOT / "MOSt"
BACKUP = ROOT / "backup_v15_before_ohip_20260907"


def backup(path: Path):
    target = BACKUP / path.relative_to(MOST)
    target.parent.mkdir(parents=True, exist_ok=True)
    if not target.exists():
        shutil.copy2(path, target)


def replace_once(text: str, pattern: str, replacement: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.S | re.I)
    if count != 1:
        raise RuntimeError(f"Could not uniquely patch {label}: {count} matches")
    return updated


oms = MOST / "PROGRAMS" / "oms.prg"
backup(oms)
text = oms.read_text(encoding="cp1252")
text = text.replace("OPEN DATABASE oms_local", "OPEN DATABASE (oms_local_fullpath)", 1)
role_block = '''* V16.2: persist an explicit installation role for server-only operations.
PUBLIC g_installation_role
LOCAL lcRoleFile, lnRoleAnswer
lcRoleFile = gc_localdata + "installation_role.txt"
IF FILE(lcRoleFile)
    g_installation_role = UPPER(ALLTRIM(FILETOSTR(lcRoleFile)))
ELSE
    lnRoleAnswer = MESSAGEBOX("Is this the MOSt SERVER installation?" + CHR(13)+CHR(13) + ;
        "Choose Yes only on the server. Choose No on every workstation.", ;
        4+32+256, "MOSt Installation Role")
    g_installation_role = IIF(lnRoleAnswer=6, "SERVER", "WORKSTATION")
    STRTOFILE(g_installation_role, lcRoleFile, 0)
ENDIF
IF !INLIST(g_installation_role, "SERVER", "WORKSTATION")
    g_installation_role = "WORKSTATION"
ENDIF
'''
if "V16.2: persist an explicit installation role" not in text:
    text = text.replace(
        'gc_datadrive = ADDBS(JUSTPATH(LEFT(path_to_data,LEN(path_to_data)-1)))',
        'gc_datadrive = ADDBS(JUSTPATH(LEFT(path_to_data,LEN(path_to_data)-1)))\n' + role_block,
        1,
    )
text = text.replace('bServerMachine = .F.\nstrUNCFullPath', 'bServerMachine = (g_installation_role == "SERVER")\nstrUNCFullPath', 1)
text = text.replace(
    'IF UPPER(JUSTDRIVE(gc_datadrive))=="C:"\n\t\tbServerMachine\t= .T.\n\tENDIF',
    '* V16.2: the persistent installation role determines server status.',
    1,
)
folders = '''bServerMachine = (g_installation_role == "SERVER")
IF bServerMachine
    IF !DIRECTORY(ADDBS(gc_datadrive)+"EDT")
        MD (ADDBS(gc_datadrive)+"EDT")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"EDT\\IN")
        MD (ADDBS(gc_datadrive)+"EDT\\IN")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"EDT\\OUT")
        MD (ADDBS(gc_datadrive)+"EDT\\OUT")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"backup")
        MD (ADDBS(gc_datadrive)+"backup")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"backup\\EDT")
        MD (ADDBS(gc_datadrive)+"backup\\EDT")
    ENDIF
ENDIF'''
if "IF bServerMachine\n    IF !DIRECTORY(ADDBS(gc_datadrive)+\"EDT\")" not in text:
    text = text.replace('bServerMachine = (g_installation_role == "SERVER")', folders, 1)
security = '''IF securityok=="ERROR" THEN
    * V16: local maintenance build has no licence expiry.
    g_nummd="999"
    g_custno="LOCAL"
ELSE
    g_nummd = SUBSTR(securityok,1,2)
    g_custno = SUBSTR(securityok,9,4)
ENDIF
g_expirydate=DATE(9999,12,31)

'''
if "V16: local maintenance build has no licence expiry" not in text:
    text = replace_once(
        text,
        r'IF securityok=="ERROR" THEN.*?\r?\nENDIF\r?\n\r?\n(?=\*\* Erick 2003\.11\.14)',
        security,
        "licence expiry block",
    )
oms.write_text(text, encoding="cp1252", newline="")

fees = MOST / "PROGRAMS" / "loadfees.prg"
backup(fees)
text = fees.read_text(encoding="cp1252")
text = text.replace('m.MOStTempFolder = "C:\\Program Files\\MOst\\TEMP\\"', 'm.MOStTempFolder = ADDBS(SYS(2023))')
text = text.replace('ltNewest = CTOT("")', 'ltNewest = {^1900-01-01}')
text = text.replace('nDialogType = 4 + 32 + 256', 'nDialogType = 4 + 32')
text = text.replace(
    'WAIT "Service code " + servicecode + " not found. Appending to fee table ..." WINDOW AT 14,45 NOWAIT\n\t\t\tAPPEND BLANK',
    '* V16.2: append silently; the main loop reports progress periodically.\n\t\t\tAPPEND BLANK',
)
if "V16.3: use a fresh private cursor" not in text:
    text = text.replace(
        '''SELECT 8
USE temp EXCLUSIVE
SET SAFETY OFF && to allow zap
ZAP  && deletes all records in temp
SET SAFETY ON

APPEND FROM (lcImportFile) TYPE SDF''',
        '''SELECT 8
* V16.3: use a fresh private cursor for every import.  The former shared
* temp.dbf could be stale, locked, or damaged and was never application data.
CREATE CURSOR temp (DATA C(79))
APPEND FROM (lcImportFile) TYPE SDF''',
        1,
    )
text = text.replace(
    'SELECT 8\nGOTO TOP\nDO WHILE .NOT. EOF(8)',
    'SELECT 8\nGOTO TOP\nLOCAL lnFeeTotal, lnFeeProcessed\nlnFeeTotal = RECCOUNT(8)\nlnFeeProcessed = 0\nDO WHILE .NOT. EOF(8)\n\tlnFeeProcessed = lnFeeProcessed + 1\n\tIF MOD(lnFeeProcessed,100)=0\n\t\tWAIT WINDOW "Updating OHIP fees: " + TRANSFORM(lnFeeProcessed) + " of " + TRANSFORM(lnFeeTotal) NOWAIT\n\t\tDOEVENTS\n\tENDIF',
    1,
)
if "V16.2: recoverable backup of the fee table" not in text:
    text = text.replace(
        'SELECT 9\nUSE fees EXCLUSIVE',
        '''* V16.2: recoverable backup of the fee table before changing any code.
LOCAL lcFeeBackupBase
lcFeeBackupBase = ADDBS(gc_datadrive) + "backup\\fees_before_" + ;
    DTOS(DATE()) + STRTRAN(TIME(),":","")
COPY FILE (path_to_data + "fees.dbf") TO (lcFeeBackupBase + ".dbf")
IF FILE(path_to_data + "fees.cdx")
    COPY FILE (path_to_data + "fees.cdx") TO (lcFeeBackupBase + ".cdx")
ENDIF
IF FILE(path_to_data + "fees.fpt")
    COPY FILE (path_to_data + "fees.fpt") TO (lcFeeBackupBase + ".fpt")
ENDIF

SELECT 9
USE fees EXCLUSIVE''',
        1,
    )

selection = r'''* V16: accept the current Ministry ZIP, TXT, or extracted .001 file.
LOCAL lcSourceFile, lcImportFile, lcDownloads, lcWorkFolder, lcOfficialUrl
LOCAL loShell, loZip, loDestination, lnChoice, lnWait, lnNewest, ltNewest
lcOfficialUrl = "https://www.ontario.ca/page/ohip-schedule-benefits-and-fees"
lcDownloads = ADDBS(GETENV("USERPROFILE")) + "Downloads\"
lcSourceFile = ""
ltNewest = CTOT("")
nFiles = ADIR(aFiles, lcDownloads + "moh-ohip-fee-schedule-master*")
FOR i = 1 TO nFiles
    IF UPPER(JUSTEXT(aFiles(i,1))) $ "ZIP,TXT,001" AND aFiles(i,3) >= ltNewest
        ltNewest = aFiles(i,3)
        lcSourceFile = lcDownloads + aFiles(i,1)
    ENDIF
ENDFOR

IF !EMPTY(lcSourceFile)
    lnChoice = MESSAGEBOX("Use the newest downloaded OHIP Physician Fee Schedule Master?" + CHR(13) + ;
        JUSTFNAME(lcSourceFile) + CHR(13)+CHR(13) + ;
        "Yes = use it, No = choose another file, Cancel = open the official download page.", ;
        3+32, "MOSt - MOH Fee Update")
ELSE
    lnChoice = 7
ENDIF

DO CASE
CASE lnChoice = 2
    DECLARE INTEGER ShellExecute IN shell32 INTEGER, STRING, STRING, STRING, STRING, INTEGER
    =ShellExecute(0, "open", lcOfficialUrl, "", "", 1)
    MESSAGEBOX("Download the OHIP Physician Fee Schedule Master in ZIP or Text format, then run MOH Fees Update again.", 64, "MOSt")
    RETURN
CASE lnChoice = 7
    lcSourceFile = GETFILE("zip;txt;001", "Select the OHIP Physician Fee Schedule Master", "Open", 0, "MOSt - MOH Fee Update")
ENDCASE

IF EMPTY(lcSourceFile) OR !FILE(lcSourceFile)
    RETURN
ENDIF

lcImportFile = lcSourceFile
IF UPPER(JUSTEXT(lcSourceFile)) == "ZIP"
    lcWorkFolder = ADDBS(SYS(2023)) + "MOST_OHIP_FEE\"
    IF !DIRECTORY(lcWorkFolder)
        MD (lcWorkFolder)
    ENDIF
    DELETE FILE (lcWorkFolder + "*.001")
    DELETE FILE (lcWorkFolder + "*.txt")
    loShell = CREATEOBJECT("Shell.Application")
    loZip = loShell.NameSpace(lcSourceFile)
    loDestination = loShell.NameSpace(lcWorkFolder)
    IF VARTYPE(loZip) # "O" OR VARTYPE(loDestination) # "O"
        MESSAGEBOX("The ZIP file could not be opened.", 16, "MOSt - MOH Fee Update")
        RETURN
    ENDIF
    loDestination.CopyHere(loZip.Items, 20)
    lcImportFile = ""
    FOR lnWait = 1 TO 100
        DOEVENTS
        =INKEY(.1)
        nFiles = ADIR(aFiles, lcWorkFolder + "*.001")
        IF nFiles > 0
            lcImportFile = lcWorkFolder + aFiles(1,1)
            EXIT
        ENDIF
    ENDFOR
ENDIF

IF EMPTY(lcImportFile) OR !FILE(lcImportFile)
    MESSAGEBOX("No .001 fee master was found in the selected download.", 16, "MOSt - MOH Fee Update")
    RETURN
ENDIF

CLOSE TABLES ALL
'''
if "V16: accept the current Ministry ZIP" not in text:
    text = replace_once(
        text,
        r'\* 1\) Message to read from floppy drive, otherwise proceed to read from DATA folder.*?CLOSE TABLES ALL\r?\n\r?\n(?=\r?\n?&& check if want to append new fee codes)',
        selection + "\r\n",
        "fee source selection",
    )
    text = replace_once(
        text,
        r'\* Erick 2003\.06\.10\r?\n\* check location of MOH file\r?\nIF bFloppyDrive.*?ENDIF\r?\n\r?\n(?=\*\* 2\) check for format)',
        'APPEND FROM (lcImportFile) TYPE SDF\r\n\r\n',
        "fee import source",
    )
archive = r'''* Keep the downloaded source and archive a dated copy under the configured MOSt folder.
LOCAL lcBackupFolder, lcBackupFile
lcBackupFolder = ADDBS(gc_datadrive) + "backup\"
IF !DIRECTORY(lcBackupFolder)
    MD (lcBackupFolder)
ENDIF
lcBackupFile = lcBackupFolder + FORCEEXT(JUSTFNAME(lcSourceFile), "") + today + "." + JUSTEXT(lcSourceFile)
COPY FILE (lcSourceFile) TO (lcBackupFile)

'''
if "Keep the downloaded source and archive" not in text:
    text = replace_once(
        text,
        r'\* Erick 2003\.06\.10\r?\n\* check location of MOH file\r?\nIF bFloppyDrive.*?ENDIF\r?\n\r?\n(?=\s*\*\*\* CHECK TEMP FILE)',
        archive,
        "fee archive",
    )
if "V16: every record in the Ministry master is an OHIP code" not in text:
    text = text.replace(
        '\tENDIF && append new fee codes\n\tENDIF\n\tSELECT 8',
        '\tENDIF && append new fee codes\n\tENDIF\n\t* V16: every record in the Ministry master is an OHIP code.\n\tSELECT fees\n\tIF SEEK(servicecode)\n\t\tREPLACE fees.ohip WITH .T.\n\tENDIF\n\tSELECT 8',
        1,
    )
# V16.8b: navigate the cursor explicitly; never rely on the selected work area.
text = text.replace("SELECT fee_import_cursor\nGOTO TOP\nLOCAL lnFeeTotal", "GO TOP IN fee_import_cursor\nLOCAL lnFeeTotal", 1)
text = text.replace("\tSELECT fee_import_cursor\n\tSKIP\nENDDO", "\tSKIP IN fee_import_cursor\nENDDO", 1)
text = text.replace('USE (path_to_data + "fees.dbf") SHARED ALIAS fees\nSET ORDER TO TAG service', 'USE (path_to_data + "fees.dbf") SHARED ALIAS fees\nLOCAL lnFeeCountBefore, lnFeeCountAfter\nlnFeeCountBefore = RECCOUNT("fees")\nSET ORDER TO TAG service', 1)
text = text.replace("SELECT fees\nFLUSH\nCLOSE TABLES ALL", 'SELECT fees\nlnFeeCountAfter = RECCOUNT("fees")\nFLUSH\nCLOSE TABLES ALL', 1)
text = text.replace('MESSAGEBOX("Fee codes updating completed !",64,"MOSt")', 'MESSAGEBOX("Fee codes updating completed." + CHR(13)+CHR(13) + ;\n    "Ministry records processed: " + TRANSFORM(lnFeeTotal) + CHR(13) + ;\n    "New fee codes added: " + TRANSFORM(lnFeeCountAfter-lnFeeCountBefore) + CHR(13) + ;\n    "Database: " + path_to_data,64,"MOSt")', 1)
# V16.8: keep historical-claim migration responsive after a third-party conflict.
old_submitted = """\t\t\t\tSELECT SUBMITED
\t\t\t\tSET ORDER TO 4   && STR(ID,6)+STR(ACCOUNTING,8)+SERVICE
\t\t\t\tm.strtoStore = \" Service changed from \"+m.CurrentService+\" To \"+m.NextServiceNum
\t\t\t\tSCAN FOR LEFT(SUBMITED.service,4) == m.CurrentService
\t\t\t\t\tm.StoreLastServAlpha = RIGHT(SUBMITED.service,1)
* update comment column
\t\t\t\t\tREPLACE SUBMITED.comments WITH SUBMITED.comments+m.strtoStore
* update new service number
\t\t\t\t\tREPLACE SUBMITED.service WITH m.NextServiceNum+m.StoreLastServAlpha
\t\t\t\tENDSCAN"""
new_submitted = """\t\t\t\tSELECT SUBMITED
\t\t\t\tSET ORDER TO 4   && STR(ID,6)+STR(ACCOUNTING,8)+SERVICE
\t\t\t\tm.strtoStore = \" Service changed from \"+m.CurrentService+\" To \"+m.NextServiceNum
\t\t\t\tLOCAL lnSubmittedScanned, lnSubmittedTotal
\t\t\t\tlnSubmittedScanned = 0
\t\t\t\tlnSubmittedTotal = RECCOUNT(\"SUBMITED\")
\t\t\t\tSCAN
\t\t\t\t\tlnSubmittedScanned = lnSubmittedScanned + 1
\t\t\t\t\tIF MOD(lnSubmittedScanned,500)=0
\t\t\t\t\t\tWAIT WINDOW \"Moving third-party code \" + m.CurrentService + ;
\t\t\t\t\t\t\t\" in submitted claims: \" + TRANSFORM(lnSubmittedScanned) + ;
\t\t\t\t\t\t\t\" of \" + TRANSFORM(lnSubmittedTotal) NOWAIT
\t\t\t\t\t\tDOEVENTS
\t\t\t\t\tENDIF
\t\t\t\t\tIF LEFT(SUBMITED.service,4) == m.CurrentService
\t\t\t\t\t\tm.StoreLastServAlpha = RIGHT(SUBMITED.service,1)
\t\t\t\t\t\tREPLACE SUBMITED.comments WITH SUBMITED.comments+m.strtoStore
\t\t\t\t\t\tREPLACE SUBMITED.service WITH m.NextServiceNum+m.StoreLastServAlpha
\t\t\t\t\tENDIF
\t\t\t\tENDSCAN"""
old_claims = """\t\t\t\tSELECT CLAIMS
\t\t\t\tSET ORDER TO 3   && DTOC(SERV_DATE)+SERVICE
\t\t\t\tSCAN FOR LEFT(CLAIMS.service,4) == m.CurrentService
\t\t\t\t\tm.StoreLastServAlpha = RIGHT(CLAIMS.service,1)
\t\t\t\t\tREPLACE CLAIMS.service WITH m.NextServiceNum+m.StoreLastServAlpha
\t\t\t\tENDSCAN"""
new_claims = """\t\t\t\tSELECT CLAIMS
\t\t\t\tSET ORDER TO 3   && DTOC(SERV_DATE)+SERVICE
\t\t\t\tLOCAL lnClaimsScanned, lnClaimsTotal
\t\t\t\tlnClaimsScanned = 0
\t\t\t\tlnClaimsTotal = RECCOUNT(\"CLAIMS\")
\t\t\t\tSCAN
\t\t\t\t\tlnClaimsScanned = lnClaimsScanned + 1
\t\t\t\t\tIF MOD(lnClaimsScanned,500)=0
\t\t\t\t\t\tWAIT WINDOW \"Moving third-party code \" + m.CurrentService + ;
\t\t\t\t\t\t\t\" in current claims: \" + TRANSFORM(lnClaimsScanned) + ;
\t\t\t\t\t\t\t\" of \" + TRANSFORM(lnClaimsTotal) NOWAIT
\t\t\t\t\t\tDOEVENTS
\t\t\t\t\tENDIF
\t\t\t\t\tIF LEFT(CLAIMS.service,4) == m.CurrentService
\t\t\t\t\t\tm.StoreLastServAlpha = RIGHT(CLAIMS.service,1)
\t\t\t\t\t\tREPLACE CLAIMS.service WITH m.NextServiceNum+m.StoreLastServAlpha
\t\t\t\t\tENDIF
\t\t\t\tENDSCAN"""
if old_submitted in text:
    text = text.replace(old_submitted, new_submitted, 1)
if old_claims in text:
    text = text.replace(old_claims, new_claims, 1)
# V16.7b: CREATE CURSOR itself creates/selects the alias; do not select it first.
text = text.replace("SELECT fee_import_cursor\n* V16.3: use a fresh private cursor", "* V16.3: use a fresh private cursor", 1)
# V16.7: never depend on numeric work area 8; other MOSt tables may own it.
text = text.replace("SELECT 8", "SELECT fee_import_cursor")
text = text.replace("RECCOUNT(8)", 'RECCOUNT("fee_import_cursor")')
text = text.replace("EOF(8)", 'EOF("fee_import_cursor")')
# V16.6: fee updates do not require exclusive access or a full REINDEX.
# CDX tags are maintained automatically as records are replaced/appended.
text = text.replace('USE (path_to_data + "fees.dbf") EXCLUSIVE ALIAS fees', 'USE (path_to_data + "fees.dbf") SHARED ALIAS fees')
text = text.replace("SELECT fees\nREINDEX\nCLOSE TABLES ALL", "SELECT fees\nFLUSH\nCLOSE TABLES ALL")
# V16.5: open every billing table by its configured server path.  Bare USE
# commands can invoke VFP's interactive "Open Tables in Database" dialog.
text = text.replace("USE fees EXCLUSIVE", 'USE (path_to_data + "fees.dbf") EXCLUSIVE ALIAS fees')
text = text.replace("USE SUBMITED IN 0", 'USE (path_to_data + "submited.dbf") IN 0 ALIAS submited')
text = text.replace("USE CLAIMS IN 0", 'USE (path_to_data + "claims.dbf") IN 0 ALIAS claims')
text = text.replace('USE m.MOStTempFolder+"tempfee.dbf" IN 0', 'USE (m.MOStTempFolder+"tempfee.dbf") IN 0 ALIAS tempfee')
text = text.replace('USE m.MOStTempFolder+"tempfee.dbf"', 'USE (m.MOStTempFolder+"tempfee.dbf") ALIAS tempfee')
# V16.4: avoid any alias collision with the TEMP table registered in OMS.DBC.
text = text.replace("CREATE CURSOR temp (DATA C(79))", "CREATE CURSOR fee_import_cursor (DATA C(79))")
text = re.sub(r"\btemp(?=\.|->)", "fee_import_cursor", text, flags=re.I)

fees.write_text(text, encoding="cp1252", newline="")

ohip = MOST / "PROGRAMS" / "ohipdsk.prg"
backup(ohip)
text = ohip.read_text(encoding="cp1252")
text = text.replace('strTempLocal = "C:\\program files\\MOSt\\TEMP\\"', 'strTempLocal = ADDBS(SYS(2023))')
text = text.replace('strTempMostFolder = "C:\\program files\\MOSt\\TEMP\\tmplabels.dbf"', 'strTempMostFolder = ADDBS(SYS(2023)) + "tmplabels.dbf"')
text = text.replace('USE JUSTDRIVE(oms_local_fullpath)+"\\program files\\most\\databases\\parameter2"', 'USE (ADDBS(gc_localapp) + "databases\\parameter2")')
text = text.replace("back_file=JUSTDRIVE(path_to_data)+'\\program files\\MOSt\\backup\\claims.'+today", "back_file=ADDBS(gc_datadrive)+'backup\\claims.'+today")
text = text.replace("back_file=JUSTDRIVE(path_to_data)+'\\program files\\MOSt\\backup\\EDT\\claims.'+today", "back_file=ADDBS(gc_datadrive)+'backup\\EDT\\claims.'+today")
text = re.sub(r'JUSTDRIVE\(path_to_data\)\+(["\'])\\program files\\MOSt\\', r'ADDBS(gc_datadrive)+\1', text, flags=re.I)
ohip.write_text(text, encoding="cp1252", newline="")

do_ra = MOST / "PROGRAMS" / "do_ra.prg"
backup(do_ra)
text = do_ra.read_text(encoding="cp1252")
text = re.sub(r'JUSTDRIVE\(path_to_data\)\+(["\'])\\program files\\MOSt\\', r'ADDBS(gc_datadrive)+\1', text, flags=re.I)
do_ra.write_text(text, encoding="cp1252", newline="")

help_updates = {
    "Security.htm": "<h2>Licence status</h2><p>This maintenance build of MOSt has no application expiry date. User logins, supervisor authorization, audit controls, and protection of clinical and billing data remain available.</p>",
    "Recreate OHIP disk.htm": "<h2>Current submission recreation</h2><p>Recreate OHIP Submission now uses the configured MOSt backup and output folders. EDT files are restored to the EDT\\OUT folder; non-EDT files are restored to the OHIP\\OUT folder. A floppy disk is no longer required.</p>",
    "Reindex,security,upgrade.htm": "<h2>MOH fee schedule updates</h2><p>MOH Fees Update accepts the official OHIP Physician Fee Schedule Master as a ZIP, text, or .001 file. It can use the newest matching file in Downloads, let you choose a file, or open the official Ontario download page. The source download is retained and a dated backup copy is made.</p>",
    "Local Parameters.htm": "<h2>Installation role</h2><p>Each installation is explicitly marked as Server or Workstation on first startup. Choose Server only on the computer that hosts the shared MOSt data and EDT folders. All EDT IN and EDT OUT files use the configured server MOSt folder.</p>",
}
for name, block in help_updates.items():
    path = MOST / "manual" / name
    backup(path)
    html = path.read_text(encoding="cp1252")
    marker = "<!-- MOSt V16 maintenance update -->"
    if marker not in html:
        html = re.sub(r"</body>", lambda _: marker + block + "</body>", html, count=1, flags=re.I)
    path.write_text(html, encoding="cp1252", newline="")

print("Prepared V16 text and help sources")
