*!*****************************************************************
*!
*!     Procedure: GETPRINT
*!
*!*****************************************************************
PROCEDURE GETPRINT
	* Query WIN.INI to get data on the installed and default printers.

	PARAMETER DEVICE, NUMBER, dfltprnt
	* Usage:
	*    DIMENSION device[1]
	*    numprinters = 0
	*    defaultprnt = ""
	*    DO GETPRINT WITH device, numprinters, defaultprnt
	*
	* The "device" array will be populated with the names and
	* parameters for all installed print devices.
	*
	* The "device" array has this structure:
	* Col 1: Printer name
	* Col 2: Parameter for [device] section
	* Col 3: Parameter for [PrinterPort] section (includes time-out
	* parameters)
	*
	* The contents of "device" might look something like this after
	* GETPRINT is called:
	*   Col 1                      Col 2           Col 3
	*   -------------------------  --------------  ----------------
	*   Apple LaserWriter II NTX   pscript,LPT2:   pscript,LPT2:,15,90
	*   Generic / Text Only=TTY    fred.prn        fred.prn,15,45
	*   HP LaserJets(Level 5)      HPPCL5MS,LPT1:  HPPCL5MS,LPT1:,15,45
	*
	* "numprinters" in this case would be 3
	* "defaultprnt" might be this:
	*    HP LaserJets(Level 5),HPPCL5MS,LPT1:

	#DEFINE buflen 2048
	PRIVATE m.in_talk, m.dcount, m.retbuf, m.bytes, m.thisdevice

	IF PARAMETERS() < 3
		WAIT WINDOW "This procedure requires 3 parameters"
		RETURN
	ENDIF

	** load foxtools library
	IF FILE("C:\program files\MOSt\foxtools.fll")
		SET LIBRARY TO "C:\program files\MOSt\foxtools.fll" ADDITIVE
	ELSE
		WAIT WINDOW "GETPRINT requires the FoxTools library."
		RETURN
	ENDIF
	**Erick**		IF FILE(SYS(2004)+"FOXTOOLS.FLL")
	**Erick**			SET LIBRARY TO (SYS(2004)+"foxtools.fll") ADDITIVE
	**Erick**		ELSE
	**Erick**			WAIT WINDOW "GETPRINT requires the FoxTools library."
	**Erick**			RETURN
	**Erick**		ENDIF

	IF SET("TALK") = "ON"
		SET TALK OFF
		m.in_talk = "ON"
	ELSE
		m.in_talk = "OFF"
	ENDIF

	* Fill in the first column of the array with installed device
	* names.
	m.retbuf = REPLICATE(CHR(0),buflen)
	m.bytes = getprostrg("devices",0,CHR(0),@m.retbuf,buflen)
	* The second argument of 0 to GetProfileString() returns the contents
	* of the entire section, with each entry separated by a null terminator
	* (CHR(0)).
	m.dcount = 0
	m.retbuf = LEFT(m.retbuf,m.bytes)
	DO WHILE CHR(0) $ m.retbuf
		m.thisdevice = LEFT(m.retbuf,AT(CHR(0),m.retbuf)-1)
		IF LEFT(m.thisdevice,1) <> CHR(0)
			m.dcount = m.dcount + 1
			DIMENSION DEVICE[m.dcount,3]
			DEVICE[m.dcount,1] = m.thisdevice
		ENDIF
		m.retbuf = SUBSTR(m.retbuf,AT(CHR(0),m.retbuf)+1)
	ENDDO

	* Fill in the second and third columns of the device array with the
	* parameters of each installed device from the [devices] section
	* (column 2) and the [PrinterPorts] section (column 3).
	FOR m.j = 1 TO m.dcount
		retbuf = REPLICATE(CHR(0),256)
		m.bytes = ;
			getprostrg("devices",DEVICE[m.j,1],CHR(0),@m.retbuf,256)
		m.retbuf = LEFT(m.retbuf,m.bytes)
		DEVICE[m.j,2] = m.retbuf

		retbuf = REPLICATE(CHR(0),256)
		m.bytes = ;
			getprostrg("PrinterPorts",DEVICE[m.j,1],CHR(0),@m.retbuf,256)
		m.retbuf = LEFT(m.retbuf,m.bytes)
		DEVICE[m.j,3] = m.retbuf
	ENDFOR

	* Store the number of installed devices.
	m.number = m.dcount

	* Now get the default printer.
	retbuf = REPLICATE(CHR(0),256)
	m.bytes = getprostrg("windows","device",CHR(0),@m.retbuf,256)
	m.retbuf = LEFT(m.retbuf,m.bytes)
	m.dfltprnt = m.retbuf

	SET TALK &in_talk

	*!*****************************************************************
	*!
	*!     Procedure: LISTPRINT
	*!
	*!*****************************************************************
PROCEDURE listprint
	PARAMETER DEVICE
	#DEFINE buflen 2048
	PRIVATE m.in_talk,m.i
	
		** load foxtools library
	IF FILE("C:\program files\MOSt\foxtools.fll")
		SET LIBRARY TO "C:\program files\MOSt\foxtools.fll" ADDITIVE
	ELSE
		WAIT WINDOW "GETPRINT requires the FoxTools library."
		RETURN
	ENDIF

**Erick**		IF FILE(SYS(2004)+"FOXTOOLS.FLL")
**Erick**			SET LIBRARY TO (SYS(2004)+"foxtools.fll") ADDITIVE
**Erick**		ELSE
**Erick**			WAIT WINDOW "LISTPRINT requires the FoxTools library."
**Erick**			RETURN
**Erick**		ENDIF
	IF SET("TALK") = "ON"
		SET TALK OFF
		m.in_talk = "ON"
	ELSE
		m.in_talk = "OFF"
	ENDIF

	DIMENSION DEVICE(1)
	NUMBER = 0
	dflt = ""

	DO GETPRINT WITH DEVICE, NUMBER, dflt
	CLEAR
	? ALLTRIM(STR(m.number,3))+" installed printer devices in win.ini:"
	FOR m.i = 1 TO NUMBER
		? "  "+DEVICE[m.i,1]+"="+DEVICE[m.i,3]
	ENDFOR
	?
	? "Default printer is "+dflt
	SET TALK &in_talk

	*!*****************************************************************
	*!
	*!     Procedure: PUTPRINT
	*!
	*!*****************************************************************
PROCEDURE putprint
	PARAMETER DEVICE, NUMBER, dflt, portnum
	* Take the printer device information in the device array and
	* update WIN.INI with it.
	*
	* "Number" is the total number of printers listed in "device."
	* "dflt" is the string to write to the [windows] device= statement
	* to set the default printer, or if dflt is a number, the array row
	* to construct this statement from. Thus, to make the default
	* printer the third one listed in "device," either pass a 3 as dflt
	* or pass the actual string (something like HP LaserJets(Level
	* 5),HPPCL5MS,LPT1:). If the string is passed, it must exactly
	* match an entry in the [devices] section of the WIN.INI file.
	*
	* GETPRINT can be used to construct the device array.
	*
	
	** load foxtools library
	IF FILE("C:\program files\MOSt\foxtools.fll")
		SET LIBRARY TO "C:\program files\MOSt\foxtools.fll" ADDITIVE
	ELSE
		WAIT WINDOW "GETPRINT requires the FoxTools library."
		RETURN
	ENDIF
	
**Erick**		IF FILE(SYS(2004)+"FOXTOOLS.FLL")
**Erick**			SET LIBRARY TO (SYS(2004)+"foxtools.fll") ADDITIVE
**Erick**		ELSE
**Erick**			WAIT WINDOW "PUTPRINT requires the FoxTools library."
**Erick**			RETURN
**Erick**		ENDIF

	IF TYPE("dflt") = "N"
		IF PARAMETERS() < 4
			portnum = 1
		ENDIF
		m.strg = DEVICE[m.dflt,1]+","+getport(DEVICE[m.dflt,2],portnum)
	ELSE
		m.strg = m.dflt
	ENDIF

	* Set the default printer
	=putprostrg("windows","device",m.strg)

	* Delete all existing device and PrinterPort entries.
	=putprostrg("devices",0,CHR(0))
	=putprostrg("PrinterPorts",0,CHR(0))

	FOR m.i = 1 TO NUMBER
		=putprostrg("devices",DEVICE[m.i,1],DEVICE[m.i,2])
		=putprostrg("PrinterPorts",DEVICE[m.i,1],DEVICE[m.i,3])
	ENDFOR

	*!*****************************************************************
	*!
	*!     Function: PUTPROSTRG
	*!
	*!*****************************************************************
FUNCTION putprostrg
	PARAMETER SECTION, entry, STRING
	LOCAL lcRegFn,lcCallFn
	lcRegFn="REGFN"
	lcCallFn="CALLFN"
	fn = &lcRegFn.("WRITEPROFILESTRING","CCC","I")
	RETURN &lcCallFn.(fn,SECTION,entry,STRING)
	* NOTE: When the code in this section is implemented in a program
	* running on Windows 95 or Windows NT, the user will get the error
	* "Entry point writeprofilestring not found." In this case, add the
	* optional fourth argument to the call to function call RegFN()
	* in the function named putprostrg as per the following example:
	*
	* fn=regfn("WRITEPROFILESTRING","CCC","I","krnl386.exe")
	*
	* The string "krnl386.exe" specifies that the writeprofilestring API
	* is located in that library.
	*!*****************************************************************
	*!
	*!     Function: GETPROSTRG
	*!
	*!*****************************************************************
FUNCTION getprostrg
	PARAMETER SECTION, entry, dflt, BUFFER, blen
	LOCAL lcRegFn,lcCallFn
	lcRegFn="REGFN"
	lcCallFn="CALLFN"
	fn = &lcRegFn.("GETPROFILESTRING","CCC@CI","I")
	RETURN &lcCallFn.(fn,SECTION,entry,dflt,@BUFFER,blen)
	* NOTE: When the code in this section is implemented in a program
	* running on Windows 95 or Windows NT, the user will get the error
	* "Entry point getprofilestring not found." In this case, add the
	* optional fourth argument to the call to function call RegFN()
	* in the function named Getprostrg as per the following example:
	*
	* fn=RegFN("GETPROFILESTRING","CCC@CI","I","krnl386.exe")
	*
	* The string "krnl386.exe" specifies that the getprofilestring API
	* is located in that library.

	*!*****************************************************************
	*!
	*!     Function: GETPORT
	*!
	*!*****************************************************************
FUNCTION getport
	PARAMETER m.pstrg, m.pnum
	* Get the first "port" from a printer string.

	* First get the printer driver name (e.g., pscript) and the comma.
	m.retstrg = SUBSTR(m.pstrg,1,AT(',',m.pstrg))

	* Now get the port designation (e.g., LPT1: or FILE:)

	* Check if the port passed is greater than the ports available.
	IF OCCURS(',',m.pstrg) >= m.pnum
		m.portstrg = SUBSTR(m.pstrg,AT(',',m.pstrg,m.pnum)+1)
	ELSE
		m.portstrg = SUBSTR(m.pstrg,AT(',',m.pstrg,1)+1)
	ENDIF

	IF AT(',',m.portstrg) > 0
		m.portstrg = LEFT(m.portstrg,AT(',',m.portstrg)-1)
	ENDIF

	RETURN m.retstrg + m.portstrg
