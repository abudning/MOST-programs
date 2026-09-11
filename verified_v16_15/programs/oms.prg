PARAMETER demomode

IF VARTYPE(demomode) <> "L" THEN  && if run most with a parameter for the first time can specify length of security  DEMOA DEMOB ..
	DO setupnew WITH demomode			&& if no parameter present then  demomode is Logical
ENDIF

CLOSE ALL
CLEAR ALL
CLEAR

* Make the startup error handler safe before database paths are loaded.
* This fallback is replaced with PARAMETER2.DATA_FILES after startup succeeds.
PUBLIC gc_localapp, gc_localdata, gc_datadrive
gc_localapp = ADDBS(JUSTPATH(FULLPATH(SYS(16,0))))
gc_localdata = ADDBS(GETENV("LOCALAPPDATA")) + "MOSt\"
IF EMPTY(GETENV("LOCALAPPDATA"))
	gc_localdata = ADDBS(SYS(2023)) + "MOSt\"
ENDIF
gc_datadrive = gc_localapp

** Show Splash welcome window
*!* Erick	LOCAL loForm
*!* Erick	loForm = NewObject("_splash","_dialogs")
*!* Erick	IF VARTYPE(loForm) # "O"
*!* Erick		RETURN
*!* Erick	ENDIF
*!* Erick	loForm.Picture = HOME()+"fox.bmp"
*!* Erick	loForm.Show(1)


&& setup splash for correct screen resolution  2002-07-16 ET
m_screen_width= SYSMETRIC(1)
DO CASE
	CASE m_screen_width = 1024
		fill_file= "MOStsplash_1024.jpg"

	CASE m_screen_width = 1152
		fill_file= "MOStsplash_1152.jpg"

	CASE m_screen_width >= 1280
		fill_file= "MOStsplash_1280.jpg"
	OTHERWISE
		fill_file= "MOStsplash_800.jpg"  && default fill file 800 x 600

ENDCASE
MODIFY WINDOW SCREEN FILL FILE &fill_file
&&MODIFY WINDOW SCREEN fill file "MOSt.jpg"
MODIFY WINDOW SCREEN ICON FILE "icon.ico"

DECLARE INTEGER GetActiveWindow IN win32api  && applies to Win 95 & 98
m_hwnd=GetActiveWindow()
m_str=SPACE(50)
m_int=50
DECLARE INTEGER GetClassName IN win32api INTEGER, STRING@, INTEGER@
m_number=GetClassName(m_hwnd, @m_str, @m_int)
IF m_number=0 && i.e. GetClassName failed, i.e. Windows 9x
	DECLARE INTEGER GetWindowText IN win32api INTEGER, STRING@, INTEGER@
	DECLARE INTEGER GetWindow IN win32api INTEGER, INTEGER
	m_hwnd1=GetWindow(m_hwnd, 2) && GW_HWNDNEXT = 2, as defined in Winuser.h
	DO WHILE m_hwnd1>0
		m_str=SPACE(50)
		m_int=50
		GetWindowText(m_hwnd1,@m_str,@m_int) && changes to name "MOST" below must be exactly matched in MOSt. dot and in the code below
		IF SUBSTR(ALLT(m_str),1,45)=="MOSt - Medical Office Suite"
&&   messagebox('There is already an instance of'+chr(13)+;
&&              '  MOSt application active !',16,'Warning !!!')
			DECLARE INTEGER SetForegroundWindow IN win32api INTEGER
			SetForegroundWindow(m_hwnd1)
			*DECLARE INTEGER SHOWWINDOW IN win32api INTEGER, INTEGER
			DECLARE INTEGER SHOWWINDOW IN user32 INTEGER, INTEGER
			SW_MAXIMIZE=3 && so is defined in Winuser.h
			SHOWWINDOW(m_hwnd1,SW_MAXIMIZE)
			CLEA DLLS
			QUIT
		ELSE
			m_hwnd1=GetWindow(m_hwnd1, 2)
		ENDIF
	ENDDO
ELSE && i.e. Windows NT, 2000

	#DEFINE SW_HIDE        0
	#DEFINE SW_SHOWNORMAL  1
	#DEFINE SW_MAXIMIZE    3
	#DEFINE SW_MINIMIZE    6
	#DEFINE SW_RESTORE     9

	DECLARE INTEGER SetForegroundWindow IN Win32API LONG HWND
	*DECLARE INTEGER SHOWWINDOW IN WIN32API LONG HWND,INTEGER nCmdShow
	DECLARE INTEGER SHOWWINDOW IN user32 INTEGER,INTEGER

	*Public Declare Function ShowWindow Lib "user32" Alias "ShowWindow" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long

	DECLARE INTEGER FindWindow IN win32api STRING@, STRING@
	m_title="MOSt - Medical Office Suite"  && see warning above
	m_hwnd1=FindWindow(@m_str,@m_title)
	IF m_hwnd1 # 0
		*messagebox('There is already an instance of'+chr(13)+;
		*           '  MOSt application active !',16,'Warning !!!')

		*!* Erick	2003.06.02 Fixed - Wrong declaration of API libray
		*!* Erick			DECLARE INTEGER SetForegroundWindow IN win32api INTEGER
		*!* Erick			SetForegroundWindow(m_hwnd1)
		*!* Erick			DECLARE INTEGER SHOWWINDOW IN win32api INTEGER, INTEGER

		SetForegroundWindow(m_hwnd1)
		*SHOWWINDOW(m_hwnd1, SW_MAXIMIZE)

		*!* Erick			SW_MAXIMIZE=3 && so is defined in Winuser.h
		*!* Erick			SHOWWINDOW2(m_hwnd1,SW_MAXIMIZE)
		CLEA DLLS
		QUIT
	ENDIF
ENDIF
CLEA DLLS
**DECLARE INTEGER GetClassLong IN win32api INTEGER, INTEGER
**m_var=GetClassLong(m_hwnd, -32) && GCW_ATOM = -32 as defined in Winuser.h
**DECLARE INTEGER GetAtomName IN win32api INTEGER, STRING@, INTEGER@
**GetAtomName(m_var, @m_str, @m_int)
***DECLARE INTEGER GetWindowLong IN win32api INTEGER, INTEGER
***m_var=GetWindowLong(m_hwnd, -6) && GWL_HINSTANCE = -6 as defined in Winuser.h
**MESSAGEBOX(m_str)
**cancel
**DECLARE INTEGER GetLastError IN win32api
**messagebox(str(GetLastError())) && There are not child processes to wait for

WITH _SCREEN
	.LOCKSCREEN=.T.
	.CLOSABLE=.T.
	.WINDOWSTATE=2
	.WINDOWTYPE = 1
	.CAPTION= "MOSt - Medical Office Suite"
	.VISIBLE = .T.
	.ICON="icon.ico"
	.LOCKSCREEN=.F.
ENDWITH

&& set sysmenu to   && turn off system menu
ON ERROR DO ERR_FIX WITH ERROR(), MESSAGE(), SYS(16), LINENO()
ON SHUTDOWN DO quit_most

SET HELP ON  && Erick - 2003.10.01
SET DEFAULT TO (gc_localapp)
IF FILE(gc_localapp + "MOSt.chm")
	SET HELP TO (gc_localapp + "MOSt.chm")
ELSE
	SET HELP OFF
ENDIF
SET SAFETY ON
SET MULTILOCKS ON
SET SCOREBOARD OFF
SET STATUS OFF && old character bar
SET STATUS BAR OFF && graphical bar    ET 000812
SET STEP OFF
SET ECHO OFF
SET TALK OFF
SET MESSAGE TO 24
SET ESCAPE OFF
SET DATE ANSI
SET CENTURY ON
SET EXCLUSIVE OFF
SET CONFIRM ON
SET BELL OFF
SET CLOCK  OFF

*** Windows 11 does not permit applications to create data folders beneath
*** Program Files.  Keep per-workstation writable state under LocalAppData.
IF !DIRECTORY(gc_localdata)
	TRY
		MKDIR (gc_localdata)
	CATCH
		gc_localdata = ADDBS(SYS(2023))
	ENDTRY
ENDIF

** Erick assign hotkeys for current windows
ON KEY LABEL CTRL+F9 _SCREEN.ACTIVEFORM.WINDOWSTATE = 1		&& minimize
ON KEY LABEL CTRL+F10 _SCREEN.ACTIVEFORM.WINDOWSTATE = 0	&& restore

** Erick - This path was modified to locate source code in development mode
LOCAL lcGetDefaultFolder, frm_f, prg_f,rpt_f,cls_f,mnu_f,bmp_f
LOCAL lbl_f,upgrade_f, graph_f, icon_f

lcGetDefaultFolder = SYS(5)+SYS(2003)

frm_f     = lcGetDefaultFolder + '\forms'
prg_f 	  = lcGetDefaultFolder + '\programs'
rpt_f  	  = lcGetDefaultFolder + '\reports'
cls_f     = lcGetDefaultFolder + '\classes'
mnu_f 	  = lcGetDefaultFolder + '\menu'
bmp_f 	  = lcGetDefaultFolder + '\bmp'
lbl_f     = lcGetDefaultFolder + '\labels'
*upgrade_f = lcGetDefaultFolder + '\upgrade'
graph_f   = lcGetDefaultFolder + '\graphics'
icon_f    = lcGetDefaultFolder + '\icons'
dbc_f     = lcGetDefaultFolder + '\databases'

IF APPLICATION.STARTMODE = 0
	* A development version of Visual FoxPro was started in an interactive session.
	SET PATH TO &frm_f;&prg_f;&rpt_f;&cls_f;&mnu_f;&bmp_f;&lbl_f;&graph_f;&icon_f;&dbc_f
ELSE
	* .exe version
	SET PATH TO reports,FORMS,DATABASES,MENU,labels,programs
ENDIF

*set path to databases,labels
PUBLIC label_printer,main_printer,path_to_data,daily_report_flag,checkin_report_flag,refmdstatistic_report_flag,;
	MVAR,mcounter,g_modify_submited_flag,g_test,g_expirydate,g_nummd, g_selectdate,g_selectid,;
	g_todaydate, g_custno, gc_datadrive, g_scheduler , g_admin, G_security,G_lettrloc,;
	g_floatingmenu, g_mask, g_skip_sequence, g_skip_item2_from_seq,listing_by_sequence_flag, g_history_path, ;
	g_claimmenu, g_claimmask, g_error_code, g_change_security_code, g_edt , oms_local_fullpath, g_invalid_path, ;
	g_Scheduler_Room_Selection, gc_MBT_Admin, g_WinDefaultPrinter

PUBLIC g_MostApplication,g_menuitem_enterclaims,g_menuitem_modify, g_menuitem_reconcile
PUBLIC g_MSWordIsInstalled

g_MSWordIsInstalled = .T.

STORE .T. TO g_menuitem_enterclaims,g_menuitem_modify, g_menuitem_reconcile

STORE '' TO g_MostApplication

RELEASE g_Scheduler_Room_Array
PUBLIC ARRAY g_Scheduler_Room_Array(1,2)
STORE '' TO g_Scheduler_Room_Array


* Erick - Setup class libraries
SET CLASSLIB TO newtbars ADDITIVE
SET CLASSLIB TO tools ADDITIVE
SET CLASSLIB TO solution ADDITIVE

* scheduler claims and admin are setup from the employee database.
g_scheduler="v" && default scheduler to view only
g_security=.T.  && default security on
g_claims="v"    && default claims to view only
g_admin=.F.      && default admin user to false
g_selectdate=DATE()
g_todaydate=DATE()
g_selectid=0
daily_report_flag=0
checkin_report_flag=0
refmdstatistic_report_flag=0
g_modify_submited_flag=0
listing_by_sequence_flag=0
g_floatingmenu=''
g_claimmenu=''
g_history_path=''
g_mask=255 && it is a mask in relation to the 8 items of "appt_menu" (shortcut menu)
&& For a shortcut menu, the statement "set skip of 1 of appt_menu .t."
&& doesn't work. In Menu Designer, a menu item can be skipped based on
&& a condition. This public variable helps in implementing this condition.
g_claimmask=15
g_error_code = 0 && global numeric variable which stores the error code which caused a QUIT to be issued.
g_change_security_code = .F. && an uninitialized variable has a logical FALSE anyway, but...
g_edt = .F. && flag to store the EDT status: .f. for EDT off and .t. for EDT on
*!*	oms_local_fullpath = "C:\Program Files\MOSt\databases\oms_local.dbc" && this public variable solves
*!*	        && the problem of using the local "oms_local.dbc" and not the server's "oms_local.dbc".
*!*	        && It is VERY IMPORTANT for this variable's value to be included between double quotes ("),
*!*	        && not simple quotes ('). This variable is used in "BeforeOpenTables" event of the forms.

oms_local_fullpath = gc_localapp + "databases\oms_local.dbc"
g_invalid_path = .F. && this is necessary for a limited period of time. It is used
&& in the following scenario only: a client machine with database
&& version < 1.0.893 and running MOSt.Exe with a version of 1.7.xxx,
&& has an invalid path for the data (databases on the server machine).
&& At the start up (running Oms.Prg), MOSt offers the user the choice
&& of selecting the correct path, by automatically launching
&& Parameter2 form. But, in 1.7.xxx, Parameter2 form has a new textbox
&& bound to Parameter2.Most_Vsn field, which does not exist in a
&& database version < 1.0.893. To solve this problem, a new public variable
&& "g_invalid_path" was created for the form Parameter2 to know and
&& to unbound that textbox bound to this inexisting field.
&& we have to make sure when remove this variable from here, to also
&& go in Parameter2 form in Text7.Init and remove the code from there too.
&& In this form we also will have to modofy at design time the field
&& to which Text7 is bound: to modify from Parameter2.version back
&& to Parameter2.most_vsn

mcounter=0 && this variable keeps track of number of forms launched into execution
STORE SPACE(4) TO MVAR
OPEN DATABASE (oms_local_fullpath)
g_test="1.0.22"
USE gc_localapp + "databases\parameter2"

GOTO 1
main_printer = parameter2.main_printer      && at present not used
label_printer = parameter2.label_printer	&& at present not used
path_to_data = ADDBS(ALLTRIM(parameter2.data_files))
* A copied legacy workstation database commonly still points to the server's
* local C: path. On client workstations the same XP data is mapped as K:.
* Use the mapped database folder when the stored location is unavailable.
IF !FILE(path_to_data + "oms.dbc")
	IF FILE("K:\Program Files\MOSt\databases\oms.dbc")
		path_to_data = "K:\Program Files\MOSt\databases\"
	ELSE
		IF FILE("K:\Program Files (x86)\MOSt\databases\oms.dbc")
			path_to_data = "K:\Program Files (x86)\MOSt\databases\"
		ENDIF
	ENDIF
ENDIF
*!*	LN_data=at("\DATABASE",upper(path_to_data))    && this is just silly and prone to trouble if change directory names ET 00-08-14
*!*	gc_datadrive = substr(path_to_data,1,ln_data)
* Derive the shared application folder from the configured database folder.
* This supports mapped drives, UNC paths, and Program Files (x86).
gc_datadrive = ADDBS(JUSTPATH(LEFT(path_to_data,LEN(path_to_data)-1)))
* V16.2: persist an explicit installation role for server-only operations.
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

gc_MBT_Admin = "SofTware"


**********************
LOCAL bServerMachine, strUNCFullPath
bServerMachine = (g_installation_role == "SERVER")
IF bServerMachine
    IF !DIRECTORY(ADDBS(gc_datadrive)+"EDT")
        MD (ADDBS(gc_datadrive)+"EDT")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"EDT\IN")
        MD (ADDBS(gc_datadrive)+"EDT\IN")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"EDT\OUT")
        MD (ADDBS(gc_datadrive)+"EDT\OUT")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"backup")
        MD (ADDBS(gc_datadrive)+"backup")
    ENDIF
    IF !DIRECTORY(ADDBS(gc_datadrive)+"backup\EDT")
        MD (ADDBS(gc_datadrive)+"backup\EDT")
    ENDIF
ENDIF
strUNCFullPath  = ''
********************
** 2003.11.24 - store client's UNC full path
IF UPPER(JUSTDRIVE(gc_datadrive)) # "C:"  && check for client machine
	IF !FILE(gc_localdata + "most.net") && check if file exists
		strUNCFullPath = ShowMapped("K:")  && get complete network path
		IF !EMPTY(strUNCFullPath)
			STRTOFILE(strUNCFullPath,gc_localdata + "most.net",0)
		ENDIF
	ENDIF
ENDIF
************************************************************************


*** -> 2002.05.02
IF !FILE(path_to_data + "oms.dbc")

	*** 2003.11.24 try to remap network drive store in most.net
	LOCAL bCheckFileConmnection AS Boolean
	bMap_Success = .T.

	IF FILE(gc_localdata + "most.net")
		LOCAL strcFullUNC AS STRING
		LOCAL lcOldOnError

		* Save the original error handler
		lcOldOnError = ON("ERROR")

		* Issue ON ERROR with the name of a procedure
		ON ERROR DO network_error

		strcFullUNC = FILETOSTR(gc_localdata + "most.net")
		IF mapDrive("K:",strcFullUNC) = -1
			bMap_Success = .F.
		ENDIF

		* Reset the original error handler
		ON ERROR &lcOldOnError

	ENDIF

	IF !bMap_Success && not map
		CLOSE DATA ALL
		answer = MESSAGEBOX("Invalid Data Path. Do you want to correct it now?",4+32,"MOSt Warning...")
		IF answer = 6
			g_invalid_path = .T.
			DO FORM admin_login TO pwok
			IF !pwok
				CLOSE DATA ALL
				QUIT
			ELSE
				return_from_parameter2 = .F.
				DO FORM parameter2 TO return_from_parameter2
				DO WHILE .T. && In VFP everything is executed synchronously, so the code doesn't wait
&& for the Parameter2 form to return. This infinite loop "waits" for the
&& form to return. In order for this to work, I made Parameter2 form modal.
					IF return_from_parameter2
						g_invalid_path = .F.
						EXIT
					ENDIF
				ENDDO
			ENDIF
		ELSE
			CLOSE DATA ALL
			QUIT
		ENDIF
		USE gc_localapp + "databases\parameter2"
		path_to_data = parameter2.data_files
		IF FILE(path_to_data + "oms.dbc")
			main_printer = parameter2.main_printer
			label_printer = parameter2.label_printer
		ELSE
			USE
			QUIT
		ENDIF
	ENDIF
ELSE
	** 2003.08.01 server machine
	* V16.2: the persistent installation role determines server status.

ENDIF
gnFlag = 0
FOR gnCount = 1 TO FCOUNT( )  && Loop for number of fields
	IF UPPER(FIELD(gnCount)) == "MOST_VSN"
		most_ver = ALLT(parameter2.most_vsn)
		local_database_ver = parameter2.VERSION
		gnFlag = 1
		EXIT
	ENDIF
ENDFOR
IF gnFlag = 0
	WAIT "New version of MOSt detected - Upgrading..." WINDOW AT 16,40 TIMEOUT 2
	DO upgrade.prg && after running this, it will quit
ENDIF
*** <- 2002.05.02

CLOSE DATABASES ALL



** Existing shared server folders are provisioned by installation/administration.
** Do not attempt to create them during workstation startup: modern SMB shares
** commonly allow database access without granting directory-creation rights.



*** Erick - 2004.03.17
*** check if webupdate is present in server machine
*** Code check if "update\fileversion.xml" exists on the server,  then checks XML resource file for new version
*** downloaded if it is a new version then proceeds to run the update method.
*** Load the class libraries required
DO wwCodeUpdate
*** Profile INI usage
SET PROCEDURE TO wwAPI Additive

IF FILE(gc_datadrive+"update\fileversion.xml")

	LOCAL cXMLContent,lcVersion , strCur_ver
	LOCAL ARRAY averarray(1)
	
	ntheval = AGETFILEVERSION(averarray,gc_localapp + "MOSt.exe")
	** convert in numeric value 
	strCur_ver =  VAL(STRTRAN(ALLTRIM(averarray(4)),'.',''))
		
	cXMLContent=FILETOSTR(gc_datadrive+"update\fileversion.xml")
	
	lcVersion = VAL(ALLTRIM(Extract(cXMLContent,"<version>","</version>")))
	
	IF lcVersion > strCur_ver 
		LOCAL strLocalPath 
		strLocalPath  = gc_localapp

		** new webupdate was downloaded and is sitting on the server to update rest of client machines
		MESSAGEBOX("New MOSt UPDATE was downloaded on the server.  Your system will now be updated.",64,"MBT Webupdate",7000)
		
		loAPI = CREATEOBJECT("wwAPI")
		
		*** Update the LastCheckDate
		*** And write out the updated version number
		loAPI.WriteProfileString(;
        		    FULLPATH("webupdate.ini"), ;
                    "Main", ;
                    "LastVersionCheck",;
                    TRANSFORM(DATE()))

		loUpdate=CREATEOBJECT("wwCodeUpdate")
		
		*** Run the generic CodeUpdate Exe and quit application
		loUpdate.RunUpdateExe([WSCRIPT CodeUpdate.vbs "MOSt.exe" "] + ;
                               SHORTPATH(gc_datadrive + [update\most_update.exe])  + ; 
                               [ /auto ] + ;
                               SHORTPATH(strLocalPath) + [" ] +;
                               ["MOSt Webupdate"])
	
	ENDIF 
ENDIF 

&& allows for client machines referencing  a server mapped drive
&& watch out for temp files and MOSt_local which reference to local c:\program files\MOSt\"
SET ESCAPE OFF
SET TALK OFF

*** -> 2002.05.01
*** Read the version from the executable in the actual local installation
*** folder.  The legacy GetVersion(C:) call assumes C:\Program Files\MOSt.
LOCAL ARRAY aCurrentExeVersion(1)
LOCAL lcRunningExe
lcRunningExe = SYS(16,0)
IF EMPTY(lcRunningExe) OR !FILE(lcRunningExe)
    lcRunningExe = gc_localapp + "MOSt.exe"
ENDIF
m_current_most_ver = ''
IF AGETFILEVERSION(aCurrentExeVersion, lcRunningExe) > 0
	m_current_most_ver = ALLTRIM(aCurrentExeVersion(4))
ENDIF
IF EMPTY(m_current_most_ver)
	MESSAGEBOX("Invalid MOSt.Exe version !",64,"Program Aborting...") && This should never happen.
	QUIT
ENDIF
IF normalized_version(m_current_most_ver) < normalized_version(most_ver)
	MESSAGEBOX("Potential program conflict running an older version of MOSt." + CHR(13) + CHR(13) + ;
		"Executable detected: " + TRANSFORM(m_current_most_ver) + CHR(13) + ;
		"Version required by local database: " + TRANSFORM(most_ver) + CHR(13) + CHR(13) + ;
		"Diagnostic test build: no database upgrade was performed.",;
		64,"MOSt Aborting - Version Details")
	QUIT
ENDIF

* Keep the workstation application folder as the default directory.  Shared
* tables below are opened by their full configured path; changing the default
* to a reconstructed server application folder is unnecessary and fails for
* some mapped-drive and UNC configurations.
USE path_to_data + "parameter2"
server_database_ver = parameter2.VERSION
CLOSE DATA ALL
* V16.15 is a workstation code-only update.  It does not change the database
* schema, so do not invoke the legacy external upgrade program when the shared
* installation still records the preceding V16.14 executable version.
LOCAL llV1615CodeOnly
llV1615CodeOnly = normalized_version(m_current_most_ver) == normalized_version("1.7.612") ;
	AND normalized_version(most_ver) == normalized_version("1.7.611")
IF !(JUSTDRIVE(path_to_data) == JUSTDRIVE(oms_local_fullpath)) && this is a client machine
	LOCAL ARRAY aServerExeVersion(1)
	server_vsn = ''
	IF AGETFILEVERSION(aServerExeVersion, gc_datadrive + "MOSt.exe") > 0
		server_vsn = ALLTRIM(aServerExeVersion(4))
	ENDIF
	IF !(server_vsn == m_current_most_ver) AND !llV1615CodeOnly
		IF normalized_version(server_vsn) < normalized_version(m_current_most_ver)
			IF (server_database_ver = local_database_ver) ;
					AND (normalized_version(m_current_most_ver) == normalized_version(most_ver))
				** this means that the server was already upgraded from a client machine,
				** but its MOSt.Exe version remained the old one. So both server and client
				** machines were already upgraded. Nothing to be done here.
				** Once again: m_current_most_ver is the version of local MOSt.Exe file (currently running).
				**             most_ver is the local Parameter2.most_vsn value
			ELSE
				** Both client and server will be upgraded from the client machine.
				** Because only the MOSt.Exe versions with major=7 (1.7.xxxx) have this
				** ability to upgrade the server machine from the client machine, the
				** first 1.7.xxxx released version can not take advantage of this ability.
				** After the server will be upgraded from a client machine, next time when
				** MOSt is launched from the server, being an older version, it won't
				** test for the Parameter2.most_vsn and won't be aware of the upgrade done
				** from the client machine.
				WAIT "New version of MOSt detected - Upgrading..." WINDOW AT 16,40 TIMEOUT 2
				DO upgrade.prg && after running this, it will quit
			ENDIF
		ELSE
			MESSAGEBOX("      Server running a newer version of MOSt." + CHR(13)+;
				"Both Server and Client machines MUST run the same version!",64,;
				"Program Aborting...")
			QUIT
		ENDIF
	ENDIF
ENDIF

IF normalized_version(m_current_most_ver) > normalized_version(most_ver) AND !llV1615CodeOnly
	WAIT "New version of MOSt detected - Upgrading..." WINDOW AT 16,40 TIMEOUT 2
	DO upgrade.prg && after running this, it will quit
ENDIF
*** <- 2002.05.01


** Erick - 2003.09.18 check for windows default printer
g_WinDefaultPrinter = ALLTRIM(SET("printer",2))  && returns WINDOWS default printer name
IF EMPTY(g_WinDefaultPrinter)
	MESSAGEBOX("There is no default printer installed on this computer.  A printer is required"+CHR(13)+;
		"in order to run MOSt.  The program will now close."+CHR(13),64,"MBT Warning",10000)
	QUIT
ENDIF

* 2004.02.18 - check if MS WORD is install in local machine
* MSgraph will be loaded with it.
LOCAL cExtn,cAppKey,cAppName,nErrNum,cNewKey
LOCAL oReg,regfile,cVersion
cAppKey = ""
cAppName = ""
regfile = "registry.prg"

SET PROCEDURE TO (m.regfile) ADDITIVE
oReg = CREATEOBJECT("FileReg")
cExtn = "DOC"
* Get Application
nErrNum = oReg.GetAppPath(m.cExtn,@cAppKey,@cAppName)

IF m.nErrNum # 0
	** MSword is not install
	g_MSWordIsInstalled = .F.
ELSE
	** MSword is install
	g_MSWordIsInstalled = .T.
ENDIF
** close procedure library
RELEASE PROCEDURE (m.regfile)

**********************************

OPEN DATABASE ALLTRIM(path_to_data)+"oms"   && open that oms database regardless of where it may be

DO main_menu.mpr   && start main mainu

USE gc_localapp + "databases\options"

g_claims=ALLTRIM("R")
g_scheduler=ALLTRIM("R")
G_admin= .F.


*** new code to set up global flag for Scheduler Room Selection
g_Scheduler_Room_Selection = .F.
LOCATE FOR options.CODE=='SCHED1MD'
IF FOUND()
	g_Scheduler_Room_Selection = options.valuelog
ENDIF

LOCATE FOR options->CODE=='SECURITY'
IF options.CODE=='SECURITY'
	g_security=options.valuelog
	IF options.valuelog=.T.
		DO FORM user_login
	ENDIF
ENDIF

LOCATE FOR options->CODE=='SCHEDULE'
IF options.CODE=='SCHEDULE'
	IF options.valuelog=.F.
		SET SKIP OF BAR 2 OF patients .T.
	ELSE
		SET SKIP OF BAR 2 OF patients .F.
	ENDIF
ENDIF

LOCATE FOR options->CODE=='SCHSETUP'
IF options.CODE=='SCHSETUP'
	IF options.valuelog=.F.
		SET SKIP OF BAR 8 OF SETUP .T.
	ELSE
		SET SKIP OF BAR 8 OF SETUP .F.
	ENDIF
ENDIF

LOCATE FOR options->CODE=='LETTERWR'
IF options.CODE=='LETTERWR'
	IF options.valuelog=.F.
		SET SKIP OF BAR 3 OF patients .T.
	ELSE
		SET SKIP OF BAR 3 OF patients .F.
	ENDIF
ENDIF

LOCATE FOR ALLT(options->CODE)=='EDT'
IF ALLT(options.CODE)=='EDT'
	IF options.valuelog=.F.
		*SET SKIP OF BAR 5 OF billing .t.
	ELSE
		*SET SKIP OF BAR 5 OF billing .f.
		g_edt = .T.
	ENDIF
ENDIF

LOCATE FOR options->CODE=='SEQUENCE'
IF options.CODE=='SEQUENCE'
	IF options.valuelog=.F.
		g_skip_sequence=.T.
	ELSE
		g_skip_sequence=.F.
	ENDIF
ENDIF

LOCATE FOR options->CODE=='MDUNKNOW'
IF options.CODE=='MDUNKNOW'
	IF options.valuelog=.F.
		g_skip_item2_from_seq=.T.
	ELSE
		g_skip_item2_from_seq=.F.
	ENDIF
ENDIF
USE
*
*
USE security				&& this deals with a

IF RECCOUNT() < 1 OR EMPTY(SECURITYCODE)          && strange problem since post executable on setup won't run then self run demo on first run of MOST
	** new demo client so run the wizard
	LOCAL m.intans AS INTEGER
	IF bServerMachine  &&& server machine
		m.intans = MESSAGEBOX("Do you wish to run the MOSt wizard now?",4+32,"MBT Install Wizard")
		IF m.intans = 6 && yes
			LOCAL strLocalMostPath AS STRING

			DO FORM wizard_install
			* AVI - file
			* If file does not exist then disale Introduction menu
			strLocalMostPath = SYS(5)+SYS(2003)+"\most.mpg"
			IF FILE(strLocalMostPath)
				** launch Intro video
				DO video_intro.prg
			ENDIF
		ENDIF
	ELSE
		RUN "most.exe DEMOC"
	ENDIF
	QUIT   &&& quit MOSt
ENDIF
securityok = decrypt(ALLTRIM(security.securitycode),"D")
IF securityok=="ERROR" THEN
    * V16: local maintenance build has no licence expiry.
    g_nummd="999"
    g_custno="LOCAL"
ELSE
    g_nummd = SUBSTR(securityok,1,2)
    g_custno = SUBSTR(securityok,9,4)
ENDIF
g_expirydate=DATE(9999,12,31)

** Erick 2003.11.14 - Security modification for inactivate doctors
SELE DIST mnemonic FROM MD INTO CURSOR temp_curs WHERE MD.PAYMENT<>0.0000
**
mdcount=RECC()
IF mdcount > 3 THEN
	IF  mdcount > VAL(g_nummd)  THEN
		MESSAGEBOX("You have too many Doctors Registered!"+CHR(13)+"You will not be able to Enter new Claims or Create Disks";
			+CHR(13)+"Please contact MBT Software Solutions Inc. at (416)255-7088 for further assistance",16,'MOSt Warning');
&&         +chr(13)+"or visit www.medinsite.com")
	ENDIF
ENDIF

*** Erick 2004.03.05 - Get all MD's address and put in them into an array 
PUBLIC ARRAY g_array_md_address[1]

SELECT DISTINCT mnemonic , address,city,postal,address2,city2,postal2,phone_work FROM OMS!MD ;
	INTO ARRAY (g_array_md_address) WHERE MD.PAYMENT<>0.0000

***************************************************
CLOSE TABLES ALL
*if date() > date(2000,05,30)
*  messagebox('Trial version of MOSt has expired please call Please contact MBT Software Solutions Inc. at (416)255-7088')
*  clear events
*  close all
*  quit
*endif
READ EVENTS

ON ERROR

FUNCTION mapDrive(tcNetDrive, tcNetworkShare)
	LOCAL cNetDrive, cNetworkShare
	oWSHNetwork = CREATEOBJECT("WScript.Network")
	* tcNetDrive syntax is cDriveLetter f.ex.  X
	* tcNetworkShare syntax is cNetPath f.ex  \\mMyServer\Cdisk\Common
	* returns the size of map or -1 if fails to map
	m.cNetDrive = m.tcNetDrive
	m.cNetworkShare = m.tcNetworkShare
	oWSHNetwork.MapNetworkDrive(m.tcNetDrive, m.tcNetworkShare, .T.)
	RELEASE oWSHNetwork
	RETURN (DISKSPACE(m.tcNetDrive))

FUNCTION DisConnectDrive(tlforce, tlupdateprofile)
	LOCAL cNetDrive, cNetworkShare
	oWSHNetwork = CREATEOBJECT("WScript.Network")
	* m.lforce = .T.  && force removal even if resource is in use
	* m.lupdateprofile = .T.  && Update the profile
	IF DISKSPACE(m.cNetDrive) # -1
		oWSHNetwork.RemoveNetworkDrive(m.cNetDrive,m.tlforce,m.tlupdateprofile)
	ENDIF
	RELEASE oWSHNetwork
	RETURN (DISKSPACE(m.cNetDrive) = -1)

FUNCTION ShowMapped
	LPARAMETERS strDrive
	LOCAL cNetDrive, cNetworkShare
	oWSHNetwork = CREATEOBJECT("WScript.Network")
&& returns complete UNC path
&& strDrive - drive to search e.i. "K:"
	LOCAL oColDrives, cStrMsg
	m.oColDrives = oWSHNetwork.EnumNetworkDrives
	m.cStrMsg = ''
	IF m.oColDrives.COUNT > 0
		FOR i = 0 TO m.oColDrives.COUNT - 1 STEP 2
			*!* Windows 2000 adds "Network Places" to list
			IF !EMPTY(m.oColDrives.ITEM[i])  AND m.oColDrives.ITEM[i] == strDrive && drive letter is mapped
				*!* Erick	     m.cStrMsg = cStrMsg + CHR(13)+CHR(10) + ;
				*!* Erick	       m.oColDrives.ITEM[i] + CHR(9) + ;
				*!* Erick	     m.oColDrives.ITEM[i + 1]
				m.cStrMsg = m.oColDrives.ITEM[i + 1]
				EXIT
			ENDIF
		ENDFOR
		ShowMapped = m.cStrMsg
	ENDIF
	RELEASE oWSHNetwork
	RETURN m.cStrMsg

FUNCTION network_error
	** 2003.11.25
	** This error trapping will trap the error to check if the server is down.
	LOCAL aErrInfo[1]
	AERROR(aErrInfo)

	DO CASE
		CASE aErrInfo[1] = 1429
			MESSAGEBOX("Your network connection to the server is down."+CHR(13)+;
				" Please contact your network administrator.",16,"MBT Warning",8000)
			** do not quit allow them to select a network drive.
		OTHERWISE

	ENDCASE
ENDFUNC

