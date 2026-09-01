* Copyright (C) Magna Carta Software, Inc. 1991-2000. All Rights Reserved.;
CommTools for FoxPro v2.x, CommTools for Visual FoxPro v3.x+;
CFHDR.H -- CommTools manifest constants.;
Visual FoxPro users should '#INCLUDE' this file in their applications.;
FoxPro for Windows v2.x users should copy this file (or the required parts of;
it) into their source file(s).



    * GENERAL MANIFEST CONSTANTS
#define     FALSE                    0
#define     TRUE                     1
#define     HIGH                     1
#define     LOW                      0
#define     CT_EOF                  -1
#define     NULL                     0
#define     ERROR_DIALOGS           115
#define 	COM_TRUE 				1
#define 	COM_FALSE 				-1

    * FREQUENTLY USED ERROR MESSAGES
#define     BADFILEWRITE           -100
#define     BADPARM                -101
#define     BADPARM0               -102
#define     BADPARM1               -103
#define     BADPARM2               -104
#define     BADPARM3               -105
#define     BADPARM4               -106
#define     BADPARM5               -107
#define     BADPARM6               -108
#define     BADPARM7               -109
#define     BADPARM8               -110
#define     PORT_OPEN              -111
#define     CONNECTION_LOST        -112
#define     NO_FILE                -113
#define     NO_IRQ                 -114
#define     NO_LAN                 -115
#define     NO_MODEM               -116
#define     NO_PORT                -117
#define     NO_RAM                 -118
#define     NO_TERM                -119
#define     NOT_SUPPORTED          -120
#define     PORT_CLOSED            -121
#define     PORT_LOCKED            -122
#define     USER_CANCELLED         -123


    * COMMUNICATIONS MANIFEST CONSTANTS AND MACROS
#define     COM1                   1
#define     COM2                   2
#define     COM3                   3
#define     COM4                   4
#define     COM5                   5
#define     COM6                   6
#define     COM7                   7
#define     COM8                   8
#define     COM9                   9


    * THE TYPES OF DATA TRANSLATION AVAILABLE
#define     LOCAL_ECHO             1
#define     REMOTE_ECHO            2
#define     PRINTER_ECHO           4
#define     FILE_ECHO              8

#define     ABORT_KEY              100
#define     ASCII_ONLY             101
#define     DIR_DOWNLOAD           122
#define     DIR_UPLOAD             123

#define     EOL                    102
#define     FLOWCTL                103
#define     FLOWHIGH               104
#define     HIGH_WATER_MARK        105
#define     IBM_ABORT_KEY          200
#define     IB_DELAY               106
#define     IL_DELAY               107
#define     IL_DELAY_CHAR          108
#define     LEADINGBYTE_DELAY      109
#define     LOW_WATER_MARK         110
#define     MONITOR_DCD            111
#define     PROTECT_FILENAME       112
#define     TEXTCASE               113
#define     TRAILINGBYTE_DELAY     114
#define     TX_DELAY               115
#define     TX_DELAYCHAR           116
#define     XFER_USE_TEMPNAME      117
#define     XLAT                   118
#define     XLATCHAR               119
#define     XOFFCHAR               120
#define     XONCHAR                121

#define     XON_ALL                0


    * TYPES OF FLOW CONTROL
#define     XONXOFF                16
#define     RTS_CTS                32
#define     DTR_DSR                64
#define     DICTATE                128


    * NEW LINE TRANSLATION MODES
#define     CR2LF                  1
#define     CR2CRLF                2
#define     CRLF2LF                3
#define     CRLF2CR                4
#define     LF2CR                  5
#define     LF2CRLF                6
#define     EOL2SP                 7
#define     STRIPEOL               8


    * CASE MODES
#define     UPPERCASE              1
#define     LOWERCASE              2


    * DATA FORMATS VALUES
#define     PARITY_NONE            0
#define     PARITY_ODD             1
#define     PARITY_EVEN            2
#define     PARITY_MARK            3
#define     PARITY_SPACE           4
#define     STOPBITS0              0
#define     STOPBITS1              1
#define     STOPBITS15             3
#define     STOPBITS2              2
#define     DATABITS5              5
#define     DATABITS6              6
#define     DATABITS7              7
#define     DATABITS8              8


    * INTERRUPT TYPES
#define     RECEIVE                1001
#define     TRANSMIT               1002
#define     LINE_STATUS            1004
#define     MODEM_STATUS           1008

#define     NOTESTIRQ                 1
#define     CF_NOPOPUP                2


    * UART FUNCTION SELECTION PARAMETERS
#define     DATABITS                96
#define     PARITY                  28
#define     STOPBITS                 3

#define     CT_BREAK               100
#define     DCTS                   101
#define     DDCD                   102
#define     DDSR                   103
#define     DRI                    104
#define     LOOPBACK               105
#define     OUT1                   106
#define     OUT2                   107
#define     SPEED                  108


    * RS-232 VARIABLES (CORRESPOND TO PIN NUMBERS)
#define     CTS                      5
#define     DCD                      8
#define     DSR                      6
#define     DTR                     20
#define     RI                      22
#define     RTS                      4

    * PROTOCOLS
#define     ASCII                  100
#define     CISB                   101
#define     CISQB                  102
#define     CISBPLUS               103
#define     KERMIT                 104
#define     XMODEM                 105
#define     XMODEM_CRC             106
#define     XMODEM_1K              107
#define     YMODEM                 108
#define     YMODEM_G               109
#define     ZMODEM                 110


    * TERMINAL TYPES
#define     ANSI_SYS               2
#define     ANSI_X364              3
#define     DEC_VT100              4
#define     DEC_VT220              5
#define     DEC_VT52               7
#define     ETTY                   8
#define     MC_BINARY              9
#define     TTY                    10
#define     TV_910                 11
#define     TV_912                 12
#define     TV_925                 13
#define     WYSE_50                14


    * TERMINAL SETTINGS

#define     TERM_BACKSPACE         12
#define     TERM_COLORS            0
#define     TERM_COLUMNS           1
#define     TERM_CURSOR            2
#define     TERM_DEBUG             3
#define     TERM_FONT              4
#define     TERM_KEYCLICK          5
#define     TERM_MAR_BOTTOM        6
#define     TERM_MAR_LEFT          7
#define     TERM_MAR_RIGHT         8
#define     TERM_MAR_TOP           9
#define     TERM_PORT              10
#define     TERM_ROWS              11


    * ASCII control character values
#define     NUL                        00
#define     SOH                        01
#define     CTRL_A                     01
#define     STX                        02
#define     CTRL_B                     02
#define     ETX                        03
#define     CTRL_C                     03
#define     EOT                        04
#define     CTRL_D                     04
#define     ENQ                        05
#define     CTRL_E                     05
#define     ACK                        06
#define     CTRL_F                     06
#define     BEL                        07
#define     CTRL_G                     07
#define     BS                         08
#define     CTRL_H                     08
#define     HT                         09
#define     CTRL_I                     09
#define     LF                         10
#define     CTRL_J                     10
#define     VT                         11
#define     CTRL_K                     11
#define     FF                         12
#define     CTRL_L                     12
#define     CR                         13
#define     CTRL_M                     13
#define     SO                         14
#define     CTRL_N                     14
#define     SI                         15
#define     CTRL_O                     15
#define     DLE                        16
#define     CTRL_P                     16
#define     DC1                        17
#define     CTRL_Q                     17
#define     XON                        17
#define     DC2                        18
#define     CTRL_R                     18
#define     DC3                        19
#define     CTRL_S                     19
#define     XOFF                       19
#define     DC4                        20
#define     CTRL_T                     20
#define     NAK                        21
#define     CTRL_U                     21
#define     SYN                        22
#define     CTRL_V                     22
#define     ETB                        23
#define     CTRL_W                     23
#define     CAN                        24
#define     CTRL_X                     24
#define     EM                         25
#define     CTRL_Y                     25
#define     SUB                        26
#define     CTRL_Z                     26
#define     ESC                        27
#define     CTRL_LBRAK                 27
#define     FS                         28
#define     CTRL_BAKSL                 28
#define     GS                         29
#define     CTRL_RBRAK                 29
#define     RS                         30
#define     CTRL_CTRL                  30
#define     US                         31
#define     CTRL__                     31
#define     SP                         32
#define     CT_BLANK                   32
#define     PERIOD                     46
#define     DEL                        127
#define     NIL                        0


    * CIS B PROTOCOL SUITE CONSTANTS
#define     BP_HOST_WR           3000
#define     BP_HOST_WS           3001
#define     BP_HOST_BS           3002
#define     BP_HOST_CM           3003
#define     BP_HOST_DQ           3004
#define     BP_HOST_TL           3005
#define     BP_HOST_Q1           3006
#define     BP_HOST_Q2           3007
#define     BP_HOST_Q3           3008
#define     BP_HOST_Q4           3009
#define     BP_HOST_Q5           3010
#define     BP_HOST_Q6           3011
#define     BP_HOST_Q7           3012
#define     BP_HOST_Q8           3013
#define     BP_HOST_DR           3014
#define     BP_HOST_UR           3015
#define     BP_HOST_FI           3016

#define     BP_NEG_WR            3017
#define     BP_NEG_WS            3018
#define     BP_NEG_BS            3019
#define     BP_NEG_CM            3020
#define     BP_NEG_DQ            3021
#define     BP_NEG_TL            3022
#define     BP_NEG_Q1            3023
#define     BP_NEG_Q2            3024
#define     BP_NEG_Q3            3025
#define     BP_NEG_Q4            3026
#define     BP_NEG_Q5            3027
#define     BP_NEG_Q6            3028
#define     BP_NEG_Q7            3029
#define     BP_NEG_Q8            3030
#define     BP_NEG_DR            3031
#define     BP_NEG_UR            3032
#define     BP_NEG_FI            3033

#define     BP_FI_DATA_TYPE      3034
#define     BP_FI_COMPRESSION    3035
#define     BP_FI_ZONE           3036
#define     BP_FI_CDATE          3037
#define     BP_FI_CTIME          3038
#define     BP_FI_MDATE          3039
#define     BP_FI_MTIME          3040
#define     BP_FI_TRUE_NAME      3041

#define     BP_MSG               3042
#define     BP_RX_ENQ            3043
#define     BP_RX_PKT_TYPE       3044
#define     BP_RX_SEQ            3045
#define     BP_TX_PKT_TYPE       3046
#define     BP_TX_ENQ            3047
#define     BP_TX_SEQ            3048
#define     BP_WAITING_FOR_HOST  3049


#define     CRC_CCITT            501
#define     CHECKSUM             500


    * KERMIT PARAMETERS
#define     K_MARK                 500
#define     K_MAXL                 501
#define     K_TIMEOUT              502
#define     K_NPAD                 503
#define     K_PADC                 504
#define     K_EOL                  505
#define     K_QCTL                 506
#define     K_QBIN                 507
#define     K_CHKT                 508
#define     K_REPT                 509
#define     K_CAPAS                510

#define     K_MMARK                511
#define     K_MMAXL                512
#define     K_MTIMEOUT             513
#define     K_MNPAD                514
#define     K_MPADC                515
#define     K_MEOL                 516
#define     K_MQCTL                517
#define     K_MQBIN                518
#define     K_MCHKT                519
#define     K_MREPT                520
#define     K_MCAPAS               521

    * KERMIT MESSAGES DURING FILE TRANSFER
#define     K_ABORT                4096
#define     K_BREAK                4097
#define     K_DATA                 4098
#define     K_EOF                  4099
#define     K_ERROR                4100
#define     K_FHEAD                4101
#define     K_SINIT                4102


    * FILE TRANSFER STATUS MESSAGES: INFORMATIONAL (DO NOT CAUSE AN ABORT)
#define     CT_ATTEMPT                    4000
#define     CT_BAD_PACKET_NUMBER          4001
#define     CT_CRC_ERROR                  4002
#define     CT_DOWN_RESUME_TRY            4004
#define     CT_EOT                        4
#define     CT_FILE_DATE                  4006
#define     CT_FILE_FINISH                4007
#define     CT_FILE_NAME                  4008
#define     CT_FILE_PROTECTED             4012
#define     CT_FILE_SIZE                  4013
#define     CT_FILE_SOURCE                4005
#define     CT_FILE_START                 4014
#define     CT_FILE_XFER_ENDED            4027
#define     CT_JUNK_RECEIVED              4015
#define     CT_MSG                        3042
#define     CT_QUOTE_OVERHEAD             4017
#define     CT_RENAMED_FILE               4012
#define     CT_RX_ACK                     4019
#define     CT_RX_CAN                     502
#define     CT_RX_ENQ                     3043
#define     CT_RX_NAK                     4020
#define     CT_RX_SEQ                     3045
#define     CT_SKIP_FILE                  4005
#define     CT_SOH                        4005
#define     CT_STX                        4005
#define     CT_SYNC_END                   4021
#define     CT_SYNC_START                 4022
#define     CT_TIMEOUT                    4016
#define     CT_TX_ACK                     4023
#define     CT_TX_BUFFER_NOT_EMPTY        4024
#define     CT_TX_CAN                     503
#define     CT_TX_ENQ                     3047
#define     CT_TX_NAK                     4025
#define     CT_TX_SEQ                     3048
#define     CT_CHECKSUM                   4005
#define     CT_CRC                        4005
#define     CT_XMODEM                     4005
#define     CT_XMODEM1K                   4005
#define     CT_XMODEMCRC                  4005
#define     CT_YMODEM                     4005
#define     CT_YMODEMG                    4005
#define     CT_XFER_POSITION              4009
#define     CT_XFER_RX_POSITION           4010
#define     CT_XFERTX_POSITION           4011
#define     CT_WAITING_FOR_HOST           3049
#define     CT_WINDOW_SIZE                4026
#define     CT_XFER_START                 4028

    * FILE TRANSFER STATUS MESSAGES: ERRORS (MAY CAUSE AN ABORT)
#define     CT_DISK_ERROR                 4003
#define     CT_DISK_FULL                  4003
#define     CT_MAX_ERRORS_REACHED         4005
#define     CT_NO_REMOTE_START            4016
#define     CT_REMOTE_CANCELLED           4018
#define     CT_UNSPECIFIED                4005


    * ZMODEM messages during file transfer
#define     ZRQINIT                  0
#define     ZRINIT                   1
#define     ZSINIT                   2
#define     ZACK                     3
#define     ZFILE                    4
#define     ZSKIP                    5
#define     ZNAK                     6
#define     ZABORT                   7
#define     ZFIN                     8
#define     ZRPOS                    9
#define     ZDATA                    10
#define     ZEOF                     11
#define     ZFERR                    12
#define     ZCRC                     13
#define     ZCHALLENGE               14
#define     ZCOMPL                   15
#define     ZCAN                     16
#define     ZFREECNT                 17
#define     ZCOMMAND                 18
#define     ZSTDERR                  19



#define     CT_XFER_ATTEMPTS            200
#define     CT_XFER_CANCOUNT            201
#define     CT_XFER_ECC                 202
#define     CT_XFER_INTERBYTE_DELAY     203
#define     CT_XFER_KEEP_ABORTED        204
#define     CT_XFER_MAX_BLOCKSIZE       205
#define     CT_XFER_QUOTE               206
#define     CT_XFER_RETRIES             200
#define     CT_XFER_FILENAME            208
#define     CT_XFER_RWINDOW             209
#define     CT_XFER_TXFILENAME          210
#define     CT_XFER_TWINDOW             211
#define     CT_XMODEM_PADCHAR           212
#define     CT_XFER_NOWAIT              213

#define     CT_Z_RXTIMEOUT              4101

#define     CT_XFER_BACKGROUND          1



    * MODEM PARAMETERS CONFIGURED WITH 'modem_set()' and/or 'modem_get()'
#define     MODEMDIAL               1
#define     MODEM_ECHO              2
#define     MODEM_ESCAPE            3
#define     MODEM_QUIET             4
#define     MODEM_DO_RESET          5
#define     MODEM_SPEAKER           6
#define     MODEM_VERBOSITY         7
#define     MODEM_CSI               8
#define     MODEM_DATA_BUFFER_SIZE  9
#define     MODEM_FINAL             10
#define     MODEM_GUARDTIME         11
#define     MODEM_RX_IBDELAY        12
#define     MODEM_RX_LBDELAY        13
#define     MODEM_TX_IBDELAY        14
#define     MODEM_DTE_SPEED_FIXED   15
#define     MODEM_WAIT_DCD          16
#define     MODEM_IS_INIT           17
#define     MODEM_RESPONSE          18



    * LINK CHARACTERISTICS
#define     LINK_CARRIER            200
#define     LINK_COMPRESSION        201
#define     LINK_MNP                202
#define     LINK_V32                203
#define     LINK_V42                204



    * CONSTANTS DENOTING ZMODEM OPTIONS
#define     CT_Z_CAPABILITY          4097
#define     CT_Z_CONVERT             4098
#define     CT_Z_MANAGE              4099

    * BIT MASKS FOR ZRINIT FLAGS BYTE ZF0
#define     CANFDX          1
#define     CANOVIO         2
#define     CANBRK          4
#define     CANFC32         32
#define     ESCCTL          64
#define     ESC8            128

    * PARAMETERS FOR ZFILE FRAME
#define     ZCBIN           1
#define     ZCNL            2
#define     ZCRESUM         3

    * MANAGEMENT INCLUDE OPTIONS
#define     ZMSKNOLOC       128

    * MANAGEMENT OPTIONS (MUTUALLY EXCLUSIVE IN ZF1)
#define     ZMMASK       31
#define     ZMNEWL       1
#define     ZMCRC        2
#define     ZMAPND       3
#define     ZMCLOB       4
#define     ZMNEW        5
#define     ZMDIFF       6
#define     ZMPROT       7


    * INT14 REDIRECTION CONSTANTS
#define     BIOS         128
#define     EBIOS        129
#define     FOSSIL       130
#define     NETDEV       131
#define     NETPORT      132
#define     SHARECOM     133
#define     DIGIBOARD    134


    * CommTools v2.0 Compatibility Definitions
#define     INTERBYTE_DELAY         IB_DELAY


#define    EV_RXCHAR          1
#define    EV_RXFLAG          2
#define    EV_TXEMPTY         4
#define    EV_CTS             8
#define    EV_DSR             16
#define    EV_RLSD            32
#define    EV_BREAK           64
#define    EV_ERR             128
#define    EV_RING            256
#define    EV_PERR            512
#define    EV_CTSS            1024
#define    EV_DSRS            2048
#define    EV_RLSDS           4096
#define    EV_RINGTE          8192


* NASI return codes (NASI_INIT(), etc)
#define NASI_BUSY                       255
#define NASI_SERVER_NOT_RESPONDING      254
#define NASI_UNABLE_TO_OPEN_SESSION     253
#define NASI_TX_BUFFER_FULL             252
#define NASI_TX_IN_XOFF_STATE           251
#define NASI_CIRCUIT_NOT_ACTIVE         250
#define NASI_REQ_NOT_SUPPORTED          249
#define NASI_REQ_REFUSED                248
#define NASI_NO_ALLOCATE_CIRCUIT        247
#define NASI_ILL_BUFFER_SIZE            246
#define NASI_ILL_CIRCUIT_OR_PORT        245
#define NASI_ILL_REENTRANT_CALL         244
#define NASI_PROTOCOL_MISMATCH          243
#define NASI_X25_VC_BUSY                242
#define NASI_NAK                        21
