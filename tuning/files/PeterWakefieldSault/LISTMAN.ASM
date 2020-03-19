; LISTMAN.ASM  0.14  14/MAY/96
; ASCII List Management
; BASIC Interface
; Copyright (C) Peter Sault 1988-1996
; All rights reserved worldwide
;ммммммммммммммммммммммммммммммм
; Cache memory will default to SMALL if CACHE_SIZE is not defined
HUGE		EQU	65536
LARGE		EQU	49152
MEDIUM		EQU	32768
SMALL		EQU	16384
TINY		EQU	8192
MICRO		EQU	1536
;
CACHE_SIZE	EQU	TINY	;for ODEION
;;;CACHE_SIZE	EQU	MICRO	;for BOXTEST
;ммммммммммммммммммммммммммммммм
; 10 CALL LISTBOX(RT%,RB%,CL%,CR%,BT%,FG1%,FG2%,BG%,RC%)
; [1]	I  top row		(base 1)
; [2]	I  bottom row		(base 1, max 24)
; [3]	I  leftmost column	(base 1)
; [4]	I  rightmost column	(base 1, max 40 or 80 according to mode)
; [5]	I  box type		(0 thru 2)
; [6]	I  box foreground	(0 thru 7)
; [7]	I  list foreground	(0 thru 7)
; [8]	I  background		(0 thru 7, not eq either foreground)
; [9]	O  return code = message id number - 1
;ддддддддддддддддддддддддддддддд
; 10 CALL LISTCLR(RET%)	'wipe box from display
; [1]	O  return code = message id number - 1
;ддддддддддддддддддддддддддддддд
; 10 CALL LISTINI	'once-only initialization
; no param
;ддддддддддддддддддддддддддддддд
; 10 CALL LISTMAN(LD$(0),LL%,SI%,OP%,KB%,RET%)
; [1]	I  list data (string array, start element num included in param)
; [2]	I  list length (number of items in list, base 0)
; [3]	C  selected item number (base 0)
; [4]	I  operation code
;		0 = display only (no wait)
;		1 = display and wait, no item selection
;		2 = display and wait, single item selection
;		3 = display and wait, multiple item selection
; [5]	O  keyboard character code (extd ASCII)
;		13 = [Enter]
;		27 = [Esc]
; [6]	O  return code = message id number - 1
;ммммммммммммммммммммммммммммммм
; Inter-Library stuff
;- - - - - - - - - - - - - - - -
; VIDMODE (VIDEO.LIB)
	EXTRN	$$VDATA:FAR	;load DS for access to vars
	EXTRN	$$VPARM:FAR	;(re)init vars
;
	EXTRN	%VIDMOD:BYTE	;video mode number
	EXTRN	%VIDTYP:BYTE	;mode type (0=text, 1=graphics)
	EXTRN	%VIDSEG:WORD	;video buffer seg addr
	EXTRN	%VIDTXC:WORD	;screen width (text columns)
	EXTRN	%VIDTXR:BYTE	;screen height (text rows)
;- - - - - - - - - - - - - - - -
; KEYPRESS (KEYBOARD.LIB)
	EXTRN	$$PRESS:FAR	;wait for and return keystroke	;[0.14]
;имммммммммммммммммммммммммммммм╩
;╨	   DATA SEGMENT		╨
;хмммммммммммммммммммммммммммммм╪
$LISTDS	SEGMENT	PARA PUBLIC 'LISTMAN_DATA'
	ASSUME	CS:$LISTDS,DS:$LISTDS
	PUBLIC	DATA_COPYRIGHT
DATA_COPYRIGHT	DB '╝LISTMAN Copyright (C) Peter Sault 1996╞'
;Copyright text length must be an even number of bytes
;See also CODE_COPYRIGHT
;здддддддддддддддддддддддддддддд©
;Ё PASS SEGMENT ADDR TO CALLER	Ё
;юдддддддддддддддддддддддддддддды
LISTDS	PROC	FAR		;instruction code lengths (bytes):-
	PUSH	CS		;1
	POP	DS		;1
	RET	0		;1
	NOP			;1 (for even code-length byte-count)
LISTDS	ENDP
;ддддддддддддддддддддддддддддддд
;active-routine id-number (see SRC_01 thru SRC_05 for names)
SRC_ID	DW	1
;- - - - - - - - - - - - - - - -
;routine-name address-table
SRC_TAB	DW	OFFSET SRC_01
	DW	OFFSET SRC_02
	DW	OFFSET SRC_03
	DW	OFFSET SRC_04
	DW	OFFSET SRC_05
SRC_LEN	EQU	$-SRC_TAB
SRC_END	EQU	SRC_LEN/2+1
SRC_OFF	EQU	OFFSET SRC_TAB
;- - - - - - - - - - - - - - - -
;routine names
;each must be 8 bytes long (left-adjusted, with trailing blanks)
SRC_NAME_LEN	EQU	8
;
SRC_01	DB	'UNKNOWN '
SRC_02	DB	'LISTBOX '
SRC_03	DB	'LISTCLR '
SRC_04	DB	'LISTINI '
SRC_05	DB	'LISTMAN '
;ддддддддддддддддддддддддддддддд
; message-box metadata for 80-column display
MSG_TOP		DW	11	;init for 25-row display
MSG_BOTTOM	DW	14	;init for 25-row display
MSG_LEFT	DW	21	;init for 80-column display
MSG_RIGHT	DW	60	;init for 80-column display
;
MSG_TYPE	EQU	1	;box type
MSG_ATTR	EQU	474EH	;box = yellow on red, text = white on red
MSG_ATTR_BOX	EQU	4EH	;box = yellow on red
MSG_ATTR_TXT	EQU	47H	;text = white on red
MSG_DFLT	EQU	1	;default msg num
MSG_HEIGHT	EQU	4
MSG_WIDTH	EQU	40
MSG_SAV		EQU	2*MSG_HEIGHT*MSG_WIDTH
MSG_MAX		EQU	MSG_WIDTH-4
;- - - - - - - - - - - - - - - -
;message id-number
MSG_NUM		DW	MSG_DFLT
;- - - - - - - - - - - - - - - -
;message-text descriptors
MSG_ADDR_TAB	DW	MSG_01L,OFFSET MSG_01
		DW	MSG_02L,OFFSET MSG_02
		DW	MSG_03L,OFFSET MSG_03
		DW	MSG_04L,OFFSET MSG_04
		DW	MSG_05L,OFFSET MSG_05
		DW	MSG_06L,OFFSET MSG_06
		DW	MSG_07L,OFFSET MSG_07
		DW	MSG_08L,OFFSET MSG_08
		DW	MSG_09L,OFFSET MSG_09
		DW	MSG_10L,OFFSET MSG_10
MSG_ADDR_LEN	EQU	$-MSG_ADDR_TAB
MSG_ADDR_END	EQU	MSG_ADDR_LEN/4+1
MSG_ADDR_OFF	EQU	OFFSET MSG_ADDR_TAB
;- - - - - - - - - - - - - - - -
;message texts
;each msg must be an even number of chars long
;max msg length = 44 chars (see MSG_MAX)
;		0----+----1----+----2----+----3----+----4----+----5
MSG_01	DB	'<invalid message id>'
MSG_01L	EQU	$-MSG_01
MSG_02	DB	'Metadata uninitialized'
MSG_02L	EQU	$-MSG_02
MSG_03	DB	'No active list-box'
MSG_03L	EQU	$-MSG_03
MSG_04	DB	'Invalid parameter '
MSG_04L	EQU	$-MSG_04
MSG_05	DB	'Out of cache memory '
MSG_05L	EQU	$-MSG_05
MSG_06	DB	'Invalid op code '
MSG_06L	EQU	$-MSG_06
MSG_07	DB	'Invalid multi-selector map'
MSG_07L	EQU	$-MSG_07
MSG_08	DB	'Invalid list'
MSG_08L	EQU	$-MSG_08
MSG_09	DB	'Initialization failed '
MSG_09L	EQU	$-MSG_09
MSG_10	DB	'Address calculation error '
MSG_10L	EQU	$-MSG_10
;		0----+----1----+----2----+----3----+----4----+----5
;ддддддддддддддддддддддддддддддд
ESC_TEXT	DB	'[Esc]'
ESC_LEN		EQU	$-ESC_TEXT
ESC_OFFSET	EQU	OFFSET ESC_TEXT
ESC_FILL	EQU	2*(MSG_WIDTH-SRC_NAME_LEN-ESC_LEN-4)
;
;restore word alignment
WORK	EQU	$-DATA_COPYRIGHT
IF	WORK MOD 2
	DB	0FFH
ENDIF
;ддддддддддддддддддддддддддддддд
OP_CODE		DW	0	;operation code
RET_CODE	DW	0	;return code
SEL_MAP		DW	0	;multi-selector map address
INIT_FLAG	DB	0	;initialization flag (1=init'd)
;ддддддддддддддддддддддддддддддд
;video stuff
VIDEO_MODE	DB	3	;default = CGA 80x25
VIDEO_SEG	DW	0B800H	;default = CGA 80x25
TEXT_WIDTH	DW	160	;screen width (bytes)
TEXT_COLS	DW	80	;screen width (text columns)
TEXT_ROWS	DW	25	;screen height (text rows)
;ддддддддддддддддддддддддддддддд
;keyboard stuff
LOCKS_STAT	DW	0	;lock keys status
;;;LOCKS_ADDR	EQU	417H				[DEL 0.14]
;ддддддддддддддддддддддддддддддд
;LISTMAN stuff
LIST_TOP	DW	0	;list top row		(base 1)
LIST_BOTTOM	DW	0	;list bottom row	(base 1)
LIST_LEFT	DW	0	;list left column	(base 1)
LIST_RIGHT	DW	0	;list right column	(base 1)
LIST_HEIGHT	DW	0	;list height	(rows, base 0)
LIST_WIDTH	DW	0	;list width	(columns, base 0)
LIST_TYPE	DW	0	;current box type	(0-2)
;- - - - - - - - - - - - - - - -
LIST_BASE	DW	0	;string descriptor array addr (BASIC DS)
LIST_LENGTH	DW	0	;list_len = max_item_num (items, base 0)
TOP_ITEM	DW	0	;list top item num		(base 0)
BOT_ITEM	DW	0	;list bottom item num		(base 0)
SEL_ITEM	DW	0	;base 0
WORK_ITEM	DW	0	;
SEL_ROW		DW	0	;base 1
WORK_ROW	DW	0	;
MAX_ROW		DW	0	;max list row		(base 1)
SCROL_VEC	DW	0	;scroll_vector	(0=up, 1=down)
FRAME_ATTR	DB	7	;box/indic attr
LIST_ATTR	DB	7	;text attr
;
POSIN_CHR	DW	0
POSIN_ROW	DW	0
;ддддддддддддддддддддддддддддддд
;LISTBOX stuff
BOX_CHAR	DB	'шзи'
		DB	'ъдм'
		DB	'ш©╩'
		DB	'шЁ╨'
		DB	'шюх'
		DB	'эдм'
		DB	'шы╪'
		DB	0,0,0	;<3-byte filler>
BOX_CHAR_START	EQU	OFFSET BOX_CHAR
;- - - - - - - - - - - - - - - -
BOX_LEVEL	DW	-1	;-1 = none active
CACHE_BOX	DW	-1	;offset of active box
CACHE_NEXT	DW	0	;offset of next available cache slot
;- - - - - - - - - - - - - - - -
;all offsets relative to start of cache
CACHE_START	LABEL	WORD	;start of cache
CACHE_POINT	EQU	OFFSET CACHE_START
;
BOX_BACK	DW	-1	;offset of previous box data
;
BOX_TOP		DW	0	;top row		(base 1)
BOX_BOTTOM	DW	0	;bottom row		(base 1)
BOX_LEFT	DW	0	;left column		(base 1)
BOX_RIGHT	DW	0	;right column		(base 1)
BOX_HEIGHT	DW	0	;number of rows		(base 1)
BOX_WIDTH	DW	0	;number of columns	(base 1)
BOX_TYPE	DW	0	;box type (0-2)
BOX_OFF		DW	0	;vid buf offset of box top/left
BOX_ATTR	DB	0	;multiplexed box colours
TEXT_ATTR	DB	0	;multiplexed list colours
;
POSIN_CHR_SAVE	DW	0
POSIN_ROW_SAVE	DW	0
BOX_DATA	EQU	$-CACHE_START	;box metadata length
MSG_ROOM	EQU	MSG_SAV+BOX_DATA
;
CACHE_WORK	EQU	$-DATA_COPYRIGHT
;must include box_data and add 2 for cache_limit
CACHE_ROOM	EQU	CACHE_WORK+MSG_ROOM+2
	IFDEF	CACHE_SIZE
	DB	CACHE_SIZE-CACHE_ROOM DUP(0)
	ELSE
	DB	SMALL-CACHE_ROOM DUP(0)
	ENDIF

CACHE_END	EQU	$-CACHE_START	;total data space but...
		DB	MSG_ROOM DUP(0)	;...always room for msg
CACHE_LIMIT	DW	CACHE_END	;max cache offset
;ддддддддддддддддддддддддддддддд
$LISTDS	ENDS
;имммммммммммммммммммммммммммммм╩
;╨	   CODE SEGMENT		╨
;хмммммммммммммммммммммммммммммм╪
$LISTCS	SEGMENT	WORD PUBLIC 'LISTMAN_CODE'
	ASSUME	CS:$LISTCS,DS:$LISTDS
	PUBLIC	LISTBOX
	PUBLIC	LISTCLR
	PUBLIC	LISTINI
	PUBLIC	LISTMAN
	PUBLIC	CODE_COPYRIGHT
CODE_COPYRIGHT	DB '╝LISTMAN Copyright (C) Peter Sault 1996╞'
;здддддддддддддддддддддддддддддд©
;Ё   ONCE-ONLY INITIALIZATION	Ё
;юдддддддддддддддддддддддддддддды
LISTINI	PROC	FAR
	PUSH	DS
	CALL	LISTDS		;DS = $LISTDS
	MOV	SRC_ID,4	;LISTINI id-num
;
	CALL	$$VPARM		;(re-)init VIDMODE variables
	CALL	$$VDATA		;DS = $VIDAT (VIDMODE data seg)
	CMP	%VIDTYP,0	;text mode?
	JE	INIT10		;{Y} continue
;
	CALL	LISTDS		;DS = $LISTDS
	MOV	CX,9		;"Init...
	CALL	MESS		;...failed"
	JMP	SHORT INIT90
;
INIT10:	MOV	AX,%VIDSEG	;AX = vid buf seg addr
	MOV	BX,%VIDTXC	;BX = text columns
	MOV	CL,%VIDTXR	;CL = text rows
	MOV	CH,%VIDMOD	;CH = video mode num
	CALL	LISTDS		;DS = $LISTDS
	MOV	VIDEO_SEG,AX
	MOV	TEXT_COLS,BX
	SHL	BX,1		;bytes = 2 x characters
	MOV	TEXT_WIDTH,BX
	SHR	BX,1		;chars
	SUB	BX,MSG_WIDTH
	SHR	BX,1
	INC	BX		;AX = left column (base 1)
	MOV	MSG_LEFT,BX
	MOV	VIDEO_MODE,CH
	XOR	CH,CH		;CX = text rows
	MOV	TEXT_ROWS,CX
	SUB	CX,MSG_HEIGHT
	SHR	CX,1
	INC	CX		;CX = top row (base 1)
	MOV	MSG_TOP,CX
	MOV	INIT_FLAG,1	;set init switch
;
INIT90:	MOV	SRC_ID,1
	POP	DS
	RET	0
LISTINI	ENDP
;здддддддддддддддддддддддддддддд©
;Ё	LISTMAN INTERFACE	Ё
;юдддддддддддддддддддддддддддддды
LISTMAN	PROC	FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	DS
	PUSH	ES
	MOV	AX,DS
	MOV	ES,AX		;ES = BASIC data seg
	CALL	LISTDS		;DS = $LISTDS
	MOV	SRC_ID,5	;LISTMAN id-num
;
	MOV	RET_CODE,2
	CMP	INIT_FLAG,1	;init'd?
	JNE	LIST90		;{N} exit with error
;- - - - - - - - - - - - - - - -
	CALL	VALI		;verify params
	CMP	RET_CODE,0
	JG	LIST80
;- - - - - - - - - - - - - - - -
	CALL	SMAPI		;set up selector map copy
	CALL	INIT		;init dependencies
	CALL	LISTO		;display list page
	CALL	INDIC		;display list...
	CALL	POSIN		;...position indics
	CALL	LISTM		;AX = ASCIIX k/b char
	CMP	AL,27		;[Esc]?
	JNE	LIST20		;{N}
;
	CALL	INIT		;{Y} reset list to...
	CALL	LISTO		;    ...initial condition...
	CALL	INDIC		;    ...and redisplay list...
	CALL	POSIN		;    ...position indics
	MOV	AX,SEL_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,SEL_ROW
	MOV	WORK_ROW,AX
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
	MOV	AX,27		;restore [Esc]
;
LIST20:	MOV	DI,[BP+8]
	MOV	ES:[DI],AX	;pass k/b char
;
	MOV	DI,[BP+12]
	MOV	AX,SEL_ITEM
	MOV	ES:[DI],AX
;- - - - - - - - - - - - - - - -
LIST80:	MOV	CX,RET_CODE
	JCXZ	LIST90
	CALL	MESS
	MOV	RET_CODE,CX
;
LIST90:	MOV	AX,RET_CODE
	MOV	DI,[BP+6]
	MOV	ES:[DI],AX
	MOV	SRC_ID,1
	POP	ES
	POP	DS
	POP	BP
	RET	12
LISTMAN	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   VERIFY INPUT PARAMETERS	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
VALI	PROC	NEAR
	MOV	RET_CODE,3	;assume no active box
	CMP	BOX_LEVEL,0	;active box?
	JNL	VALI00		;{Y} continue		ЁVALI90 tooЁ
	JMP	VALI90		;{N} exit with error	Ёfar for JLЁ
;- - - - - - - - - - - - - - - -
;check op_code
VALI00:	MOV	RET_CODE,6	;assume op code error
	MOV	SI,[BP+10]
	MOV	AX,ES:[SI]	;AX = op code
	CMP	AX,3
	JA	VALI90
	MOV	OP_CODE,AX
;- - - - - - - - - - - - - - - -
; AX = op code
;if list_len < 0 then exit with error
	MOV	RET_CODE,4	;assume list length error
	MOV	SI,[BP+14]
	MOV	CX,ES:[SI]	;CX = list length (items, base 0)
	CMP	CX,0
	JL	VALI90
;- - - - - - - - - - - - - - - -
; AX = op code
; CX = list length (base 0)
;verify list string descriptors
	MOV	SI,[BP+16]	;ES:[SI] = 1st descriptor
	CMP	AX,3		;multi-select?
	JNE	VALI20		;{N} skip flags test
;-  -  -  -  -  -  -  -  -  -  -
; AX = op code
; CX = list length (base 0)
; SI = pointer to selector-map (caller's DS)
;if multi-select then first string must be selector-map
	MOV	RET_CODE,7	;assume selector-map error
	MOV	AX,ES:[SI]	;AX = selector-map length (base 1)
	CMP	AX,CX		;selector-map proper length?
	JNE	VALI90		;{N} exit with error
	MOV	DI,ES:[SI+2]	;{Y} ES:[DI] = selector-map
	CMP	SI,ES:[DI-2]	;valid string data prefix?
	JNE	VALI90		;{N} exit with error
	MOV	SEL_MAP,DI	;{Y} save addr of selector-map
	MOV	AX,CX		;save CX
VALI10:	CMP  BYTE PTR ES:[DI],1	;valid data?
	JA	VALI90		;{N} exit with error
	INC	DI		;{Y} incr pointer and...
	LOOP	VALI10		;    ...loop for next
	ADD	SI,4		;selector ok, so point to 1st item
	MOV	CX,AX		;restore CX
	DEC	CX		;CX = list length (items, base 0)
;-  -  -  -  -  -  -  -  -  -  -
; CX = adjusted list length (base 0)
; SI = pointer to first list item (caller's DS)
VALI20:	MOV	LIST_BASE,SI
	MOV	LIST_LENGTH,CX	;item count includes selector-map
	INC	CX		;CX = list length (items, base 1)
;- - - - - - - - - - - - - - - -
; CX = adjusted list length (base 1)
	MOV	RET_CODE,8	;assume list error
VALI30:	MOV	AX,ES:[SI]	;AX = string length
	CMP	AX,0		;null string?
	JE	VALI40		;{Y} skip prefix test
	MOV	DI,ES:[SI+2]	;ES:[DI] = string data start
	CMP	SI,ES:[DI-2]	;does data prefix point to descriptor?
	JNE	VALI90		;{N} exit with error
VALI40:	ADD	SI,4		;{Y} point to next descriptor
	LOOP	VALI30
;- - - - - - - - - - - - - - - -
;clear return code
	MOV	RET_CODE,0
;- - - - - - - - - - - - - - - -
VALI90:	RET
VALI	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   INITIALIZE SELECTOR MAP	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
SMAPI	PROC	NEAR
	CMP	OP_CODE,3	;multi-select?
	JNE	SMAPI9		;{N} exit
;
	MOV	CX,LIST_LENGTH
	INC	CX		;CX = list length (items, base 1)
	MOV	DI,SEL_MAP	;ES:[DI] = multi-selector map
SMAPI1:	MOV	AL,ES:[DI]	;copy...
	SHL	AL,1		;...bit 0...
	OR	ES:[DI],AL	;...to bit 1
	INC	DI
	LOOP	SMAPI1
;
SMAPI9:	RET
SMAPI	ENDP
;здддддддддддддддддддддддддддддд©
;Ё	RESET SELECTOR MAP	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
SMAPR	PROC	NEAR
	CMP	OP_CODE,3	;multi-select?
	JNE	SMAPR9		;{N} exit
;
	MOV	CX,LIST_LENGTH
	INC	CX		;CX = list length (items, base 1)
	MOV	DI,SEL_MAP	;ES:[DI] = multi-selector map
SMAPR1:	SHR	BYTE PTR ES:[DI],1
	INC	DI
	LOOP	SMAPR1
;
SMAPR9:	RET
SMAPR	ENDP
;здддддддддддддддддддддддддддддд©
;Ё	WRITE SELECTOR MAP	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
SMAPW	PROC	NEAR
	CMP	OP_CODE,3	;multi-select?
	JNE	SMAPW9		;{N} exit
;
	MOV	CX,LIST_LENGTH
	INC	CX		;CX = list length (items, base 1)
	MOV	DI,SEL_MAP	;ES:[DI] = multi-selector map
SMAPW1:	AND	BYTE PTR ES:[DI],1
	INC	DI
	LOOP	SMAPW1
;
SMAPW9:	RET
SMAPW	ENDP
;здддддддддддддддддддддддддддддд©
;Ё     TOGGLE SELECTOR FLAG	Ё
;юдддддддддддддддддддддддддддддды
;;;SMAPT	PROC	NEAR
;;;	MOV	DI,SEL_MAP	;ES:[DI] = multi-selector map
;;;	ADD	DI,SEL_ITEM
;;;	XOR	BYTE PTR ES:[DI],1
;;;	RET
;;;SMAPT	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   SWITCH SELECTOR FLAG ON	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
SMAP1	PROC	NEAR
	CMP	OP_CODE,3	;multi-select?
	JNE	SMAP19		;{N} exit
;
	MOV	DI,SEL_MAP	;ES:[DI] = multi-selector map
	ADD	DI,WORK_ITEM
	OR	BYTE PTR ES:[DI],1
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
;
SMAP19:	RET
SMAP1	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   SWITCH SELECTOR FLAG OFF	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
SMAP0	PROC	NEAR
	CMP	OP_CODE,3	;multi-select?
	JNE	SMAP09		;{N} exit
;
	MOV	DI,SEL_MAP	;ES:[DI] = multi-selector map
	ADD	DI,WORK_ITEM
	AND	BYTE PTR ES:[DI],2	;preserve copy bit
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
;
SMAP09:	RET
SMAP0	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   INITIALIZE DEPENDENCIES	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
INIT	PROC	NEAR
	MOV	TOP_ITEM,0	;top_item_num = 0 (default)
;- - - - - - - - - - - - - - - -
;if sel_item_num < 0 then set to zero and continue
;if sel_item_num > list_len then set to list_len and continue
	MOV	SI,[BP+12]
	MOV	AX,ES:[SI]	;AX = sel_item_num	(base 0)
	CMP	AX,0		;sel_item_num => 0?
	JGE	INIT01		;{Y}
	XOR	AX,AX		;{N} sel_item_num = 0
INIT01:	CMP	AX,LIST_LENGTH	;sel_item_num <= list_len?
	JLE	INIT02		;{Y}
	MOV	AX,LIST_LENGTH	;{N} sel_item_num = list_len
INIT02:	MOV	SEL_ITEM,AX
;- - - - - - - - - - - - - - - -
	MOV	AX,LIST_LENGTH	;AX = list_len		(base 0)
	CMP	AX,LIST_HEIGHT	;list_len > box_len?
	JG	INIT03		;{Y}
	ADD	AX,LIST_TOP	;{N} AX = list_len + top_row_num
	MOV	MAX_ROW,AX
	JMP	SHORT INIT06
;- - - - - - - - - - - - - - - -
INIT03:	XOR	BX,BX		;BX = 0 = dflt box_top_item_num
	MOV	AX,LIST_BOTTOM
	MOV	MAX_ROW,AX	;XRMX = LIRB
	MOV	AX,LIST_HEIGHT
	SHR	AX,1
	CMP	AX,SEL_ITEM
	JGE	INIT04
;
	MOV	BX,SEL_ITEM
	SUB	BX,AX
;
INIT04:	MOV	AX,LIST_TOP
	ADD	AX,LIST_LENGTH
	SUB	AX,MAX_ROW
	CMP	AX,BX
	JG	INIT05
;
	MOV	BX,LIST_LENGTH
	SUB	BX,LIST_HEIGHT
;
INIT05:	MOV	TOP_ITEM,BX
;- - - - - - - - - - - - - - - -
INIT06:	MOV	AX,TOP_ITEM	;AX = top_item_num	(base 0)
	MOV	BX,LIST_TOP	;BX = top_row		(base 1)
	ADD	BX,SEL_ITEM	;	+ sel_item	(base 0)
	SUB	BX,AX		;	- top_item	(base 0)
	MOV	SEL_ROW,BX	;	= sel_row_num	(base 1)
	ADD	AX,LIST_HEIGHT	;top_item + page_len	(base 0)
	MOV	BOT_ITEM,AX	;	= bot_item	(base 0)
	RET
INIT	ENDP
;имммммммммммммммммммммммммммммм╩
;╨    KEYBOARD INPUT HANDLER	╨
;хмммммммммммммммммммммммммммммм╪
;If the length of the preceding code and data is an odd number of
;bytes then an extra byte is assembled here to make it even.
ODD_BIN	EQU	$-CODE_COPYRIGHT
	IF	ODD_BIN MOD 2
	DB	0FFH
	ENDIF
;-------------------------------
;Note:-
;Each code table must comprise an even number
;of bytes in order to maintain word alignment.
;-------------------------------
;standard ASCII keycodes
STD_ASC	DB	13,27,43,45,0,0
STD_SIZ	EQU	$-STD_ASC
STD_OFF	EQU	OFFSET STD_ASC
STD_VEC	DW	OFFSET STD_13	;[Enter]
	DW	OFFSET STD_27	;[Esc]
	DW	OFFSET STD_43	;[+]
	DW	OFFSET STD_45	;[-]
	DW	OFFSET KEYAC8	;catch-all
	DW	OFFSET KEYAC8	;catch-all
;;;STD_LEN	EQU	$-STD_VEC
;- - - - - - - - - - - - - - - -
;extended ASCII keycodes
EXT_ASC	DB	71,72,73,75,77,79,80,81,0,0	;keypad + catchall (null)
EXT_SIZ	EQU	$-EXT_ASC
EXT_OFF	EQU	OFFSET EXT_ASC
EXT_VEC	DW	OFFSET KEYAC8	;[Home]
	DW	OFFSET EXT_72	;[CsrU]
	DW	OFFSET EXT_73	;[PgUp]
	DW	OFFSET KEYAC8	;[CsrL]
	DW	OFFSET KEYAC8	;[CsrR]
	DW	OFFSET KEYAC8	;[End]
	DW	OFFSET EXT_80	;[CsrD]
	DW	OFFSET EXT_81	;[PgDn]
	DW	OFFSET KEYAC8	;catch-all
	DW	OFFSET KEYAC8	;catch-all
;;;EXT_LEN	EQU	$-EXT_VEC
;здддддддддддддддддддддддддддддд©
;Ё	LIST MOTION CONTROL	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
; AX	output	ASCIIX k/b char, or zero if NOWAIT op
;ддддддддддддддддддддддддддддддд
LISTM	PROC	NEAR
	MOV	AX,OP_CODE
	CMP	AX,0		;display & exit? (nowait)
	JE	LISTM9		;{Y}
;- - - - - - - - - - - - - - - -
	PUSH	BX						;[0.14]
;
	MOV	AX,SEL_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,SEL_ROW
	MOV	WORK_ROW,AX
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
;
;;;TM1:	CALL	KEYIN		;get keyboard input	[DEL 0.14]
;;;	CMP	AX,0		;null?			[DEL 0.14]
;;;	JE	LISTM1		;{Y} loop		[DEL 0.14]
LISTM1:	CALL	$$PRESS		;AL = ASCII, AL = key scan-code	;[0.14]
	MOV	LOCKS_STAT,BX	;BX = shifts/locks status	;[0.14]
	CMP	AL,0		;extd ASCII?			;[0.14]
	JE	LISTM2		;{Y}				;[0.14]
	XOR	AH,AH		;{N} clear k/b scan-code	;[0.14]
;;;	CALL	KEYAC		;{N} exec k/b action
LISTM2:	CALL	KEYAC		;exec k/b action		;[0.14]
	CMP	AX,0		;has k/b code survived?
	JE	LISTM1		;{N} loop
;
;CALL ITEMO suspended until list-edit (opcode=3) enabled
;;;	CALL	ITEMO
;
	POP	BX						;[0.14]
;- - - - - - - - - - - - - - - -
LISTM9:	RET
LISTM	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   WAIT FOR KEY DEPRESSION	Ё			[DEL 0.14]
;юдддддддддддддддддддддддддддддды
; Service now provided by $$PRESS (KEYBOARD.LIB)		;[0.14]
; DS	input	$LISTDS
; ES	input	BASIC data seg
; AX	output	ASCII keyboard input code
;ддддддддддддддддддддддддддддддд
;;;KEYIN	PROC	NEAR
;;;KEYIN1:	CALL	LOCKS
;;;	MOV	AH,1		;input...
;;;	INT	16H		;...ready?
;;;	JZ	KEYIN1		;loop if N
;;;	XOR	AH,AH		;AH = 0
;;;	INT	16H		;get input data (keystroke)
;;;	CMP	AL,0		;extd ASCII?
;;;	JE	KEYIN9		;{Y}
;;;	XOR	AH,AH		;{N} clear k/b scan-code
;;;KEYIN9:	RET
;;;KEYIN	ENDP
;здддддддддддддддддддддддддддддд©
;Ё	  ACTION CONTROL	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
; AX	input	ASCII k/b input code
;	output	zero if k/b code recognized, otherwise unchanged
;ддддддддддддддддддддддддддддддд
KEYAC	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DI
;
	CMP	AL,0		;standard ASCII?
	JA	KEYAC1		;{Y}
;- - - - - - - - - - - - - - - -
;extended ASCII keycodes
	PUSH	ES
	MOV	BX,CS		;set up ES for scan
	MOV	ES,BX		;ES = CS
	MOV	AL,AH		;{N} get extended ASCII code
	MOV	DI,EXT_OFF
	MOV	CX,EXT_SIZ	;CX = length of data table (bytes)
	REPNE	SCASB		;scan table for match
	SUB	DI,EXT_OFF	;DI = match posn (1 thru data_table_len)
	DEC	DI		;convert to vector...
	SHL	DI,1		;...table index
	MOV	BX,CS:EXT_VEC.[DI]	;BX = direct vector to handler
	POP	ES
	JMP	BX
;- - - - - - - - - - - - - - - -
;standard ASCII keycodes
KEYAC1:	PUSH	ES
	MOV	BX,CS		;set up ES for scan
	MOV	ES,BX		;ES = CS
	MOV	DI,STD_OFF
	MOV	CX,STD_SIZ	;CX = length of data table (bytes)
	REPNE	SCASB		;scan table for match
	SUB	DI,STD_OFF	;DI = match posn (1 thru data_table_len)
	DEC	DI		;convert to vector...
	SHL	DI,1		;...table index
	MOV	BX,CS:STD_VEC.[DI]	;BX = direct vector to handler
	POP	ES
	JMP	BX
;-------------------------------
;standard ASCII handlers
;- - - - - - - - - - - - - - - -
;[Enter]
STD_13:	CALL	SMAPW		;{Y} write selector-map
	JMP	SHORT KEYAC9	;exit
;- - - - - - - - - - - - - - - -
;[Esc]
STD_27:	CALL	SMAPR		;{Y} reset selector map
	JMP	SHORT KEYAC9	;exit
;- - - - - - - - - - - - - - - -
;[+]
STD_43:	CALL	SMAP1		;{Y} set selector flag
	JMP	SHORT KEYAC8	;exit
;- - - - - - - - - - - - - - - -
;[-]
STD_45:	CALL	SMAP0		;{Y} reset selector flag
	JMP	SHORT KEYAC8	;exit
;-------------------------------
;extended ASCII handlers
EXT_72:	CALL	ITEMU		;[CsrU]
	JMP	SHORT KEYAC8	;exit
;- - - - - - - - - - - - - - - -
EXT_73:	CALL	LISTD		;[PgUp]	= [ScrDn]
	JMP	SHORT KEYAC8	;exit
;- - - - - - - - - - - - - - - -
EXT_80:	CALL	ITEMD		;[CsrD]
	JMP	SHORT KEYAC8	;exit
;- - - - - - - - - - - - - - - -
EXT_81:	CALL	LISTU		;[PgDn]	= [ScrUp]
;-------------------------------
KEYAC8:	XOR	AX,AX
;-------------------------------
KEYAC9:	POP	DI						
	POP	CX						
	POP	BX						
	RET							
KEYAC	ENDP
;здддддддддддддддддддддддддддддд©
;Ё     DISPLAY LIST SEGMENT	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
LISTO	PROC	NEAR
	PUSH	AX						
	MOV	AX,TOP_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,LIST_TOP
	MOV	WORK_ROW,AX
LISTO1:	CALL	ITEMO
	MOV	AX,MAX_ROW
	CMP	AX,WORK_ROW
	JLE	LISTO9
	INC	WORK_ITEM
	INC	WORK_ROW
	JMP	SHORT LISTO1
LISTO9:	POP	AX						
	RET							
LISTO	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   SELECT NEXT ITEM UPWARDS	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
ITEMU	PROC	NEAR
;;;	PUSH	AX					[DEL 0.14]
;;;	PUSH	BX					[DEL 0.14]
	CMP	OP_CODE,2	;selection active?
	JL	ITEMU9		;{N} bypass item_up
;- - - - - - - - - - - - - - - -
	PUSH	AX						;[0.14]
	PUSH	BX						;[0.14]
;
;copy current params
	MOV	AX,SEL_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,SEL_ROW
	MOV	WORK_ROW,AX
	CALL	ITEMO		;normalize previous selection
;
	MOV	AX,LIST_TOP
	CMP	AX,WORK_ROW	;prev selection at box_top?
	JGE	ITEMU1		;{Y} wrap to max_row_num
;
;not yet at box_top...
	DEC	WORK_ITEM	;{N} ascend x 1 row
	DEC	WORK_ROW
	MOV	BX,WORK_ITEM
	MOV	AX,WORK_ROW
	JMP	SHORT ITEMU2
;
;wrap to max_row_num
ITEMU1:	MOV	BX,TOP_ITEM
	SUB	BX,AX		;BX = top_item - top_row
	MOV	AX,MAX_ROW
	ADD	BX,AX
	MOV	WORK_ITEM,BX	;new sel_item_num
	MOV	WORK_ROW,AX	;new sel_row_num = max_row_num
;
ITEMU2:	MOV	SEL_ITEM,BX
	MOV	SEL_ROW,AX
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
;
;;;MU9:	POP	BX
	POP	BX						;[0.14]
	POP	AX						
;- - - - - - - - - - - - - - - -
;;;	RET
ITEMU9:	RET							;[0.14]
ITEMU	ENDP
;здддддддддддддддддддддддддддддд©
;Ё  SELECT NEXT ITEM DOWNWARDS	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
ITEMD	PROC	NEAR
;;;	PUSH	AX					[DEL 0.14]
;;;	PUSH	BX					[DEL 0.14]
	CMP	OP_CODE,2	;selection active?
	JL	ITEMD9		;{N} bypass item_down
;- - - - - - - - - - - - - - - -
	PUSH	AX						;[0.14]
	PUSH	BX						;[0.14]
;
	MOV	AX,SEL_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,SEL_ROW
	MOV	WORK_ROW,AX
	CALL	ITEMO		;normalize previous selection
;
	MOV	AX,MAX_ROW
	CMP	AX,WORK_ROW	;prev sel_row_num = max_row_num?
	JLE	ITEMD1		;{Y} wrap to box_top
;
;not yet at max_row_num...
	INC	WORK_ITEM	;{N} descend x 1 row
	INC	WORK_ROW
	MOV	BX,WORK_ITEM
	MOV	AX,WORK_ROW
	JMP	SHORT ITEMD2
;
;wrap to box_top
ITEMD1:	MOV	BX,TOP_ITEM
	MOV	AX,LIST_TOP
	MOV	WORK_ITEM,BX	;sel_item_num = box_top_item_num
	MOV	WORK_ROW,AX	;sel_row_num = box_top_row_num
;
ITEMD2:	MOV	SEL_ITEM,BX
	MOV	SEL_ROW,AX
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
;
;;;MD9:	POP	BX
	POP	BX						;[0.14]
	POP	AX						
;- - - - - - - - - - - - - - - -
;;;	RET
ITEMD9:	RET							;[0.14]
ITEMD	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   DISPLAY UNCURSORED ITEM	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
ITEMO	PROC	NEAR
	PUSH	AX						
	PUSH	BX						
	PUSH	CX						
	PUSH	DX						
	PUSH	DI						
	PUSH	SI						
;
	CALL	ITEMW		;CX = adjusted string length
				;SI = string data offset (BASIC DS)
				;DI = video offset
	JC	ITEMO9		;exit if error			
;
	MOV	AH,LIST_ATTR	;AH = attribute byte
	MOV	AL,32		;AL = prefix character (blank)
	CMP	OP_CODE,3	;multi-select?
	JNE	ITEMO1		;{N} skip selector test
	MOV	BX,SEL_MAP	;{Y} get selector flag addr
	ADD	BX,WORK_ITEM	;ES:[BX] = selector flag (byte)
	TEST BYTE PTR ES:[BX],1	;multi-selected item?
	JZ	ITEMO1		;{N} leave at lo-int
	OR	AH,8		;{Y} make hi-int
;- - - - - - - - - - - - - - - -
;xfer string from BASIC data seg to vid buf
ITEMO1:	PUSH	ES
	PUSH	DS
	MOV	DX,ES
	MOV	ES,VIDEO_SEG	;ES = vid buf seg
	MOV	DS,DX		;DS = BASIC data seg
	CLD
	STOSW
	MOV	DX,CX		;save treated length	(base 1)
	JCXZ	ITEMO3
ITEMO2:	LODSB			;fetch text char to AL
	STOSW
	LOOP	ITEMO2
ITEMO3:	POP	DS
	MOV	CX,LIST_WIDTH
	SUB	CX,DX
	JCXZ	ITEMO5
	MOV	AL,32
	REPZ	STOSW		;blank-fill to right		
ITEMO5:	POP	ES
;- - - - - - - - - - - - - - - -
ITEMO9:	POP	SI						
	POP	DI						
	POP	DX						
	POP	CX						
	POP	BX						
	POP	AX						
	RET
ITEMO	ENDP
;здддддддддддддддддддддддддддддд©
;Ё  DISPLAY CURSORED UNI-ITEM	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
ITEMI	PROC	NEAR
	CMP	OP_CODE,2	;uni-select?			;[0.14]
	JNE	ITEMI9		;{N} exit			;[0.14]
;- - - - - - - - - - - - - - - -
	PUSH	AX						
	PUSH	CX						
	PUSH	DX						
	PUSH	DI						
	PUSH	SI						
;
;;;	CMP	OP_CODE,2	;uni-select?		[DEL 0.14]
;;;	JNE	ITEMI9		;{N} exit		[DEL 0.14]
	CALL	ITEMW		;CX = adjusted string length
				;SI = string data offset (BASIC DS)
				;DI = video offset
;;;	JC	ITEMI9		;exit if error
	JC	ITEMI8		;exit if error			;[0.14]
;- - - - - - - - - - - - - - - -
	MOV	AH,LIST_ATTR	;AH = attribute byte
	ROL	AH,1		;    ...and...
	ROL	AH,1		;    ...invert...
	ROL	AH,1		;    ...colours
	ROL	AH,1
	MOV	AL,221		;AL = prefix character ("щ")
;- - - - - - - - - - - - - - - -
;xfer string from BASIC data seg to vid buf
; AX = 256*attr+char
; CX = item length (chars, base 1)
; DI = vid buf offset
; SI = item addr
	PUSH	ES
	PUSH	DS
	MOV	DX,ES
	MOV	ES,VIDEO_SEG	;ES = vid buf seg
	MOV	DS,DX		;DS = BASIC data seg
	CLD
	STOSW
	MOV	DX,CX		;save treated length	(base 1)
	JCXZ	ITEMI3
;
ITEMI2:	LODSB
	STOSW
	LOOP	ITEMI2
;
ITEMI3:	POP	DS
;- - - - - - - - - - - - - - - -
	MOV	CX,LIST_WIDTH
	SUB	CX,DX
	JCXZ	ITEMI5
;
	MOV	AL,222		;suffix character (= "ч")
	STOSW
	DEC	CX
	JCXZ	ITEMI5
	MOV	AL,219		;filler = reversed blanks ("ш")
	REPZ	STOSW						
;
ITEMI5:	POP	ES
;- - - - - - - - - - - - - - - -
;;;MI9:	POP	SI
ITEMI8:	POP	SI						;[0.14]
	POP	DI						
	POP	DX						
	POP	CX						
	POP	AX						
;- - - - - - - - - - - - - - - -
;;;	RET
ITEMI9:	RET							;[0.14]
ITEMI	ENDP
;здддддддддддддддддддддддддддддд©
;Ё DISPLAY CURSORED MULTI-ITEM	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
ITEMJ	PROC	NEAR
	CMP	OP_CODE,3	;multi-select?			;[0.14]
	JNE	ITEMJ9		;{N} exit			;[0.14]
;- - - - - - - - - - - - - - - -
	PUSH	AX						
	PUSH	BX						
	PUSH	CX						
	PUSH	DX						
	PUSH	DI						
	PUSH	SI						
;
;;;	CMP	OP_CODE,3	;multi-select?		[DEL 0.14]
;;;	JNE	ITEMJ9		;{N} exit		[DEL 0.14]
	CALL	ITEMW		;CX = adjusted string length
				;SI = string data offset (BASIC DS)
				;DI = video offset
;;;	JC	ITEMJ9		;exit if error
	JC	ITEMJ8		;exit if error			;[0.14]
;- - - - - - - - - - - - - - - -
; AX = 256*attr+char
; CX = item length (chars, base 1)
; DI = vid buf offset
; SI = item addr
	MOV	BX,SEL_MAP	;{Y} get selector flag addr
	ADD	BX,WORK_ITEM	;ES:[BX] = selector flag (byte)
	TEST BYTE PTR ES:[BX],1	;multi-selected item?
	MOV	BL,0FFH		;assume yes
	JNZ	ITEMJ1		;{Y} item hi-int
	MOV	BL,077H		;{N} item lo-int
;
ITEMJ1:	MOV	AH,LIST_ATTR	;AH = attribute byte
	OR	AH,8		;make hi-int for prefix
	MOV	AL,16		;AL = prefix character ("")
;-  -  -  -  -  -  -  -  -  -  -
;xfer string from BASIC data seg to vid buf
	PUSH	ES
	PUSH	DS
	MOV	DX,ES
	MOV	ES,VIDEO_SEG	;ES = vid buf seg
	MOV	DS,DX		;DS = BASIC data seg
	CLD
	STOSW
	AND	AH,BL		;adjust intensity attr
	MOV	DX,CX		;save treated length	(base 1)
	JCXZ	ITEMJ3
ITEMJ2:	LODSB
	STOSW
	LOOP	ITEMJ2
ITEMJ3:	POP	DS
;-  -  -  -  -  -  -  -  -  -  -
	MOV	CX,LIST_WIDTH
	SUB	CX,DX
	JCXZ	ITEMJ4
;
	OR	AH,8		;make hi-int
	MOV	AL,17		;AL = suffix character ("")
	STOSW
	DEC	CX
	JCXZ	ITEMJ4
	MOV	AL,32		;AL = default filler (blank)
	REPZ	STOSW		;fill to right			
ITEMJ4:	POP	ES
;- - - - - - - - - - - - - - - -
;;;MJ9:	POP	SI
ITEMJ8:	POP	SI						;[0.14]
	POP	DI						
	POP	DX						
	POP	CX						
	POP	BX						
	POP	AX						
;- - - - - - - - - - - - - - - -
;;;	RET
ITEMJ9:	RET							;[0.14]
ITEMJ	ENDP
;здддддддддддддддддддддддддддддд©
;Ё ITEM DISPLAY INITIALIZATION	Ё
;юдддддддддддддддддддддддддддддды
; Called by all item display subrs
; DS	input	$LISTDS
; ES	input	BASIC data seg
; CX	output	adjusted string length
; SI	output	string data offset (BASIC data seg)
; DI	output	video offset
;-------------------------------
ITEMW	PROC	NEAR
	PUSH	AX						
;fetch string descriptor
	MOV	SI,WORK_ITEM	;SI = line_item num	(base 0)
	SHL	SI,1
	SHL	SI,1		;SI = 4 x line_number
	ADD	SI,LIST_BASE	;ES:[SI] = string descriptor addr
	MOV	CX,ES:[SI]	;CX = string length	(base 1)
	MOV	SI,ES:[SI+2]	;SI = string offset
	CMP	CX,LIST_WIDTH	;string overlength?
	JLE	ITEMW1		;{N} take supplied length
	MOV	CX,LIST_WIDTH	;{Y} truncate to list_width
ITEMW1:	MOV	AX,WORK_ROW
	CALL	VADDR		;DI = video offset, CF:1 = error
	POP	AX						
	RET
ITEMW	ENDP
;здддддддддддддддддддддддддддддд©
;Ё     COMPUTE VIDEO OFFSET	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; AX	input	text row (base 1)
; DI	output	video offset
; CF	output	error flag (0=ok, 1=error)
;ддддддддддддддддддддддддддддддд
VADDR	PROC	NEAR
	PUSH	AX						
	CALL	ADDRA		;AX = text_row vid_offset	
	JC	VADDR9		;exit if text_row invalid	
	MOV	DI,LIST_LEFT					
	SHL	DI,1						
	ADD	DI,AX		;DI = target video offset	
	CLC			;clear error flag		
VADDR9:	POP	AX						
	RET
VADDR	ENDP
;здддддддддддддддддддддддддддддд©
;Ё OBTAIN TEXT_ROW VIDEO_OFFSET	Ё				
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; AX	input	text row (base 1)
;	output	video offset
; CF	output	error flag (0=ok, 1=error)
;ддддддддддддддддддддддддддддддд
ADDRA	PROC	NEAR
	PUSH	DX
;- - - - - - - - - - - - - - - -
; assume 80-column mode
	DEC	AX		;AX = text row (base 0)
	CMP	AX,TEXT_ROWS	;AX valid?
	JB	ADDRA1		;{Y} continue
	INC	AX		;{N} restore input data...
	STC			;    ...set error flag...
	JMP	SHORT ADDRA9	;    ...and exit
ADDRA1:	XCHG	AH,AL		;AH = text row (base 1), AL = 0
	SHR	AX,1		;AX = 128 x screen_row
	MOV	DX,AX
	SHR	AX,1
	SHR	AX,1		;AX = 32 x screen_row
	ADD	AX,DX		;AX = 160 x screen_row
;- - - - - - - - - - - - - - - -
; check for 40-column mode
	CMP	TEXT_COLS,40	;40-column mode?
	JNE	ADDRA8		;{N} skip
	SHR	AX,1		;{Y} AX = 80 x screen_row
ADDRA8:	CLC			;clear error flag
;- - - - - - - - - - - - - - - -
ADDRA9:	POP	DX
	RET
ADDRA	ENDP
;здддддддддддддддддддддддддддддд©
;Ё	SCROLL PAGE UPWARDS	Ё
;юдддддддддддддддддддддддддддддды
LISTU	PROC	NEAR
	MOV	AX,LIST_LENGTH
	CMP	AX,BOT_ITEM
	JG	LISTU1		;			ЁLISTU9 too Ё
	JMP	LISTU9		;			Ёfar for JLEЁ
;- - - - - - - - - - - - - - - -
LISTU1:	TEST	LOCKS_STAT,16	;scroll_lock set?
 	JZ	LISTU3		;{N} skip to scroll_up
;- - - - - - - - - - - - - - - -;{Y} display end_page
;display list end segment
;AX = list_len
	SUB	AX,LIST_HEIGHT	;list_len => page_len?
	JGE	LISTU2		;{Y} accept new top_item
	XOR	AX,AX		;{N} top_item = 0
LISTU2:	MOV	TOP_ITEM,AX	;pass box_top_item_num...
	CALL	LISTO		;display list segment
;
	MOV	AX,TOP_ITEM
	ADD	AX,LIST_HEIGHT
	MOV	BOT_ITEM,AX
	MOV	AX,MAX_ROW
	MOV	SEL_ROW,AX
	MOV	WORK_ROW,AX
	ADD	AX,TOP_ITEM
	SUB	AX,LIST_TOP
	MOV	SEL_ITEM,AX
	MOV	WORK_ITEM,AX
;
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
	JMP	SHORT LISTU6	;go update position indics
;- - - - - - - - - - - - - - - -
;scroll up
LISTU3:	MOV	SCROL_VEC,0	;vector = 0 (up)
	CALL	SCROL		;scroll
	MOV	AX,SEL_ITEM
	CMP	AX,TOP_ITEM
	JE	LISTU4		;{Y}
;
	DEC	SEL_ROW
	JMP	SHORT LISTU5
;
LISTU4:	INC	SEL_ITEM	;increment sel_item_num
;
LISTU5:	INC	TOP_ITEM
	INC	BOT_ITEM
	MOV	AX,BOT_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,LIST_BOTTOM
	MOV	WORK_ROW,AX
	CALL	ITEMO		;display new box_bot_item
;- - - - - - - - - - - - - - - -
; AX  = sel_item_num
	MOV	AX,SEL_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,SEL_ROW
	MOV	WORK_ROW,AX
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
;- - - - - - - - - - - - - - - -
LISTU6:	CALL	INDIC		;display list...
	CALL	POSIN		;...position indics
;- - - - - - - - - - - - - - - -
LISTU9:	RET
LISTU	ENDP
;здддддддддддддддддддддддддддддд©
;Ё    SCROLL PAGE DOWNWARDS	Ё
;юдддддддддддддддддддддддддддддды
LISTD	PROC	NEAR
	CMP	TOP_ITEM,0
	JG	LISTD1		;			ЁLISTD9 too Ё
	JMP	LISTD9		;			Ёfar for JLEЁ
;- - - - - - - - - - - - - - - -
LISTD1:	TEST	LOCKS_STAT,16	;scroll_lock set?
 	JZ	LISTD2		;{N} skip to scroll_down
;- - - - - - - - - - - - - - - -
;display list top segment
	MOV	TOP_ITEM,0
	CALL	LISTO		;display list segment
;
	MOV	AX,LIST_HEIGHT
	MOV	BOT_ITEM,AX
	MOV	AX,LIST_TOP
	MOV	SEL_ROW,AX
	MOV	WORK_ROW,AX
	MOV	SEL_ITEM,0
	MOV	WORK_ITEM,0
;
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
	JMP	SHORT LISTD5	;go update position indics
;- - - - - - - - - - - - - - - -
;scroll down
LISTD2:	MOV	SCROL_VEC,1	;vector = 1 (down)
	CALL	SCROL		;exec scroll
	MOV	AX,SEL_ITEM
	CMP	AX,BOT_ITEM
	JE	LISTD3
;
	INC	SEL_ROW
	JMP	SHORT LISTD4
;
LISTD3:	DEC	SEL_ITEM	;decrement sel_item_num
;
LISTD4:	DEC	BOT_ITEM
	DEC	TOP_ITEM
	MOV	AX,TOP_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,LIST_TOP
	MOV	WORK_ROW,AX
	CALL	ITEMO		;display new box_top_item
;- - - - - - - - - - - - - - - -
; AX  = current sel_item_num
	MOV	AX,SEL_ITEM
	MOV	WORK_ITEM,AX
	MOV	AX,SEL_ROW
	MOV	WORK_ROW,AX
	CALL	ITEMI		;<===TEMP FIX
	CALL	ITEMJ		;<===TEMP FIX
;- - - - - - - - - - - - - - - -
LISTD5:	CALL	INDIC		;display list...
	CALL	POSIN		;...position indics
;- - - - - - - - - - - - - - - -
LISTD9:	RET
LISTD	ENDP
;здддддддддддддддддддддддддддддд©
;Ё     SCROLL PAGE UP/DOWN	Ё
;юдддддддддддддддддддддддддддддды
SCROL	PROC	NEAR
	MOV	CX,LIST_BOTTOM
	MOV	DH,CL
	DEC	DH		;DH = box_bot_row_num	(base 0)
;
	MOV	AX,LIST_TOP
	SUB	CX,AX
	MOV	DL,AL
	DEC	DL		;DL = box_top_row_num	(base 0)
;
	MOV	AX,LIST_RIGHT
	MOV	AH,AL
	DEC	AH		;AH = box_right		(base 0)
	MOV	BX,LIST_LEFT
;do not decrement AL because list_left (base 0) = box_left (base 1)
	MOV	AL,BL		;AL = box_left		(base 1)
	XOR	BX,BX		;BX = 0
	CMP	SCROL_VEC,1	;0 <= vector <= 1?
	JA	SCROL9		;{N} exit
;- - - - - - - - - - - - - - - -
;AL = list_left		(base 0) = box_left (base 1)
;AH = box_right		(base 0)
;BX = 0
;CX = box_height	(base 0)
;DL = box_top		(base 0)
;DH = box_bot		(base 0)
	JL	SCROL1		;{Y} skip to scroll_up if zero
	MOV	BH,DH		;BH = box_bottom [ScrDn]	(base 0)
	JMP	SHORT SCROL2
SCROL1:	MOV	BH,DL		;BH = box_top    [ScrUp]	(base 0)
SCROL2:	SHR	BX,1
	MOV	DI,BX		;DI = 128 x box_top/bottom
	SHR	BX,1
	SHR	BX,1		;BX =  32 x box_top/bottom
	ADD	DI,BX		;DI = 160 x box_top/bottom
;- - - - - - - - - - - - - - - -
; check for 40-column mode
	CMP	TEXT_COLS,40	;40-column mode?		
	JNE	SCROL3		;{N} skip			
	SHR	DI,1		;{Y} DI = 80 x screen_row	
;- - - - - - - - - - - - - - - -;   = screen_row offset	(base 0)
SCROL3:	MOV	BX,AX		;BL = list_left, BH = box_right	
	SUB	BH,BL
	INC	BH
	MOV	DL,BH
	XOR	DH,DH		;DX = list_width		(base 1)
;- - - - - - - - - - - - - - - -
	CBW			;AX = list_left
	SHL	AX,1		;AX = 2 x list_left
	ADD	DI,AX		;DI = target video offset
;- - - - - - - - - - - - - - - -
	CMP	SCROL_VEC,1	;0 <= vector <= 1?
	MOV	SI,DI
	MOV	BX,TEXT_COLS	;BX = screen width (base 1)	
	JL	SCROL6		;{N} skip to scroll_up if zero
;- - - - - - - - - - - - - - - -
;initialize video_source_offset and offset_decrement for scroll_down
	SUB	SI,TEXT_WIDTH	;SI = initial source vid offset	
	ADD	BX,DX		;	+ list_width
	SHL	BX,1		;	x 2
	NEG	BX		;	x -1 = offset_decrement
	JMP	SHORT SCROL7
;- - - - - - - - - - - - - - - -
;initialize video_source_offset and offset_increment for scroll_up
SCROL6:	ADD	SI,TEXT_WIDTH	;SI = initial source vid offset	
	SUB	BX,DX		;	- list_width
	SHL	BX,1		;	x 2 = offset_increment
;- - - - - - - - - - - - - - - -
;DX = list_width (base 1)
SCROL7:	PUSH	DS
	PUSH	ES
	MOV	AX,VIDEO_SEG
	MOV	DS,AX
	MOV	ES,AX
	CLD
SCROL8:	MOV	AX,CX		;save row count
	MOV	CX,DX		;CX = column count	(base 1)
  REPZ	MOVSW
	ADD	DI,BX		;[DI] = next target row start
	ADD	SI,BX		;[SI] = next source row start
	MOV	CX,AX		;restore row count
	LOOP	SCROL8		;do next row
	POP	ES
	POP	DS
;- - - - - - - - - - - - - - - -
SCROL9:	RET
SCROL	ENDP
;здддддддддддддддддддддддддддддд©
;Ё DISPLAY DIRECTION INDICATORS	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
;ддддддддддддддддддддддддддддддд
INDIC	PROC	NEAR
;check for empty list (i.e. list_len = -1)
	CMP	LIST_LENGTH,0					;[0.14]
	JL	INDIC9						;[0.14]
;- - - - - - - - - - - - - - - -
	PUSH	AX						
	PUSH	BX						
	PUSH	DI						
	PUSH	ES
;check for empty list (i.e. list_len = -1)
;;;	CMP	LIST_LENGTH,0				[DEL 0.14]
;;;	JL	INDIC9					[DEL 0.14]
;- - - - - - - - - - - - - - - -
;upper indicator
	MOV	AX,LIST_TOP
	CMP	LIST_TYPE,0
	JA	INDIC1
	DEC	AX		;box type 0
INDIC1:	CALL	VADDR		;DI = video offset, CF:1 = error
	JC	INDIC3		;skip upper indic if error	
	DEC	DI		;point to upper...
	DEC	DI		;...indicator position
;
	MOV	AH,FRAME_ATTR	;AH = color_attr
	MOV	AL,254		;AL = default indic_char (eol)
	CMP	TOP_ITEM,0
	JE	INDIC2
	MOV	AL,30		;AL = indic_char (`more')
;
INDIC2:	MOV	ES,VIDEO_SEG	;ES = vid buf seg
	MOV	ES:[DI],AX	;write upper indicator
;
;check for single-item list (i.e. list_len = 0)
INDIC3:	MOV	AX,LIST_HEIGHT	;AX = list height	(rows, base 0)
	CMP	AX,LIST_LENGTH	;length > page?
;;;	JGE	INDIC9		;{N} skip lower indic
	JGE	INDIC8		;{N} skip lower indic		;[0.14]
;- - - - - - - - - - - - - - - -
;lower indicator
	MOV	AX,MAX_ROW
	CMP	LIST_TYPE,0
	JA	INDIC4
	INC	AX		;box type 0
INDIC4:	CALL	VADDR		;DI = video offset, CF:1 = error
;;;	JC	INDIC9		;skip lower indic if error
	JC	INDIC8		;skip lower indic if error	;[0.14]
	DEC	DI		;point to lower...
	DEC	DI		;...indicator position
;
	MOV	AH,FRAME_ATTR	;AH = color_attr
	MOV	AL,254		;AL = default indic_char (eol)
	MOV	BX,BOT_ITEM
	CMP	BX,LIST_LENGTH
	JGE	INDIC5
	MOV	AL,31		;AL = indic_char (`more')
;
;write lower indicator to video
INDIC5:	MOV	ES:[DI],AX	;write lower indicator
;- - - - - - - - - - - - - - - -
;;;IC9:	POP	ES
INDIC8:	POP	ES						;[0.14]
	POP	DI						
	POP	BX						
	POP	AX						
;- - - - - - - - - - - - - - - -
;;;	RET
INDIC9:	RET							;[0.14]
INDIC	ENDP
;здддддддддддддддддддддддддддддд©
;Ё  DISPLAY POSITION INDICATOR	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
;ддддддддддддддддддддддддддддддд
POSIN	PROC	NEAR
	PUSH	AX						
	PUSH	CX						
	PUSH	DI						
	PUSH	ES
	MOV	ES,VIDEO_SEG	;ES = vid buf seg
;- - - - - - - - - - - - - - - -
;wipe previous position indic
	MOV	AX,POSIN_ROW
	ADD	AX,LIST_TOP	;AX = screen row (base 1)
	CALL	VADDR		;we do not save&restore the...
	JC	POSIN1		;skip restore if error		
	DEC	DI		;...computed address as the...
	DEC	DI		;...box may have since been...
	MOV	AX,POSIN_CHR	;...relocated or resized by user
	MOV	ES:[DI],AX	;restore box side char
;- - - - - - - - - - - - - - - -
;check for start or end of list
POSIN1:	CMP	TOP_ITEM,0					
	JE	POSIN9
;
	MOV	CX,LIST_LENGTH
	SUB	CX,LIST_HEIGHT
	CMP	CX,TOP_ITEM
	JE	POSIN9
;- - - - - - - - - - - - - - - -
; 1030 STAT%=LISC%-LISV%	'theor. number of ptr posns (base 1)
; 1050 IF LISI%=0 THEN ROWN%=-1:GOTO 1080
; 1060 IF LISI%=STAT% THEN ROWN%=LISV%+1:GOTO 1080
; 1070 '''ROWN%=((LISV%+1)*LISI%\STAT%)	'box type 0
; 1072 ROWN%=((LISV%-1)*LISI%\STAT%)+1	'box types 1&2
;write new position indic
	MOV	AX,LIST_HEIGHT
	CMP	LIST_TYPE,0
	JA	POSIN2
	INC	AX		;box type 0
	INC	AX
POSIN2:	DEC	AX		;box types 1&2
	MUL	TOP_ITEM	;DX:AX = product
	JCXZ	POSIN9		;avoid div-by-0
	DIV	CX		;AX = quotient, DX = remainder
	CMP	LIST_TYPE,0
	JE	POSIN3
	INC	AX		;box types 1&2
POSIN3:	MOV	POSIN_ROW,AX	;store for next time round
	ADD	AX,LIST_TOP	;AX = screen row (base 1)
	CALL	VADDR
	JC	POSIN9		;exit if error			
	DEC	DI
	DEC	DI
	MOV	AX,ES:[DI]
	MOV	POSIN_CHR,AX	;save for next time round
	MOV	AH,FRAME_ATTR	;AH = attribute byte
	MOV	AL,254		;AL = pos indic ("Ч")
	MOV	ES:[DI],AX	;write lower indicator
;
POSIN9:	POP	ES
	POP	DI						
	POP	CX						
	POP	AX						
	RET
POSIN	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   REPORT LOCK KEYS STATUS	Ё			[DEL 0.14]
;юдддддддддддддддддддддддддддддды
; Service now provided by $$PRESS (KEYBOARD.LIB)
; DS	input	$LISTDS
;ддддддддддддддддддддддддддддддд
;;;LOCKS	PROC	NEAR
;;;	PUSH	AX
;;;	PUSH	DI
;;;	PUSH	ES
;;;	XOR	AX,AX
;;;	MOV	ES,AX		;ES = 0
;;;	MOV	DI,LOCKS_ADDR	;DI = status word offset
;;;	MOV	AX,ES:[DI]	;AX = status word
;;;	MOV	LOCKS_STAT,AX	;store status internally
;;;	POP	ES
;;;	POP	DI
;;;	POP	AX
;;;	RET
;;;LOCKS	ENDP
;имммммммммммммммммммммммммммммм╩
;╨	     LISTBOX		╨
;хмммммммммммммммммммммммммммммм╪
;здддддддддддддддддддддддддддддд©
;Ё	 BASIC INTERFACE	Ё
;юдддддддддддддддддддддддддддддды
LISTBOX	PROC	FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	DS
	PUSH	ES
	MOV	AX,DS
	MOV	ES,AX		;ES = BASIC data seg
	CALL	LISTDS		;DS = $LISTDS
	MOV	SRC_ID,2	;LISTBOX id-num
;- - - - - - - - - - - - - - - -
	MOV	RET_CODE,2
	CMP	INIT_FLAG,1	;init'd?
	JNE	BOX90		;{N} exit with error
;- - - - - - - - - - - - - - - -
	CALL	VERI		;verify params
	CMP	RET_CODE,0	;error?
	JG	BOX80		;{Y} exit
;- - - - - - - - - - - - - - - -
;save position indicator data
	CMP	BOX_LEVEL,0	;is there a lower-level box?
 	JL	BOX10		;{N} skip save
	MOV	DI,CACHE_BOX	;{Y} save position...
	MOV	AX,POSIN_CHR	;    ...indicator data
	MOV	[DI+POSIN_CHR_SAVE],AX
	MOV	AX,POSIN_ROW
	MOV	[DI+POSIN_ROW_SAVE],AX
;- - - - - - - - - - - - - - - -
BOX10:	CALL	ADDR		;SI = box top/left vid offset
	JNC	BOX20		;continue if no error		
	MOV	RET_CODE,10	;set error code			
	JMP	SHORT BOX80					
BOX20:	CALL	SAVE		;save underlying screen		
	CMP	RET_CODE,0	;error?
	JNE	BOX80		;{Y} exit			
;
	CALL	PARAM		;init list metadata
	CALL	DRAW		;draw box
;
BOX80:	MOV	CX,RET_CODE
	JCXZ	BOX90
	CALL	MESS
	MOV	RET_CODE,CX
;
BOX90:	MOV	AX,RET_CODE
	MOV	DI,[BP+6]
	MOV	ES:[DI],AX
	MOV	SRC_ID,1
	POP	ES
	POP	DS
	POP	BP
	RET	18
LISTBOX	ENDP
;здддддддддддддддддддддддддддддд©
;Ё    VERIFY/LOAD PARAMETERS	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; ES	input	BASIC data seg
;ддддддддддддддддддддддддддддддд
VERI	PROC	NEAR
	MOV	RET_CODE,4	;assume error
	MOV	DI,CACHE_NEXT	;next available cache slot
;- - - - - - - - - - - - - - - -
	MOV	SI,[BP+20]
	MOV	AX,ES:[SI]	;AX = box_bottom
	DEC	AX						
	CMP	AX,TEXT_ROWS	;0 <= box_bottom <= max?	
	JB	VERI10		;{Y} continue		ЁVERI90 too Ё
	JMP	VERI90		;{N} exit with error	Ёfar for JNBЁ
VERI10:	INC	AX						
	MOV  [DI+BOX_BOTTOM],AX	;store box_bottom		
;
	MOV	SI,[BP+22]
	MOV	BX,ES:[SI]	;BX = box_top
	DEC	BX						
	CMP	BX,TEXT_ROWS	;0 <= box_top <= max?		
	JB	VERI20		;{Y} continue		ЁVERI90 too Ё
	JMP	VERI90		;{N} exit with error	Ёfar for JNBЁ
VERI20:	INC	BX						
	MOV	[DI+BOX_TOP],BX	;{Y} store box_top		
;
	SUB	AX,BX
	INC	AX		;AX = box_height (rows, base 1)
	CMP	AX,5		;below min?
	JNL	VERI30		;{N} continue			
	JMP	VERI90		;{Y} exit with error		
VERI30:	MOV  [DI+BOX_HEIGHT],AX					
;- - - - - - - - - - - - - - - -
	MOV	SI,[BP+16]
	MOV	AX,ES:[SI]	;AX = box_right (base 1)
	DEC	AX						
	CMP	AX,TEXT_COLS	;0 <= box_right <= max?		
	JNB	VERI90		;{N} exit with error		
	INC	AX						
	MOV   [DI+BOX_RIGHT],AX	;right_column		(base 1)
;
	MOV	SI,[BP+18]
	MOV	BX,ES:[SI]	;BX = box_left (base 1)
	DEC	BX						
	CMP	BX,TEXT_COLS	;0 <= box_left <= max?		
	JNB	VERI90		;{N} exit with error		
	INC	BX						
	MOV    [DI+BOX_LEFT],BX	;{Y} store box_left
;
	SUB	AX,BX		;AX = box width (columns, base 0)
	INC	AX		;AX = box width (columns, base 1)
	CMP	AX,6		;below min?
	JL	VERI90		;{Y} exit with error
	MOV   [DI+BOX_WIDTH],AX	;{N} store box width
;- - - - - - - - - - - - - - - -
;box type
	MOV	SI,[BP+14]
	MOV	AX,ES:[SI]	;BX = box_type
	CMP	AX,2
	JA	VERI90
	MOV	[DI+BOX_TYPE],AX
;- - - - - - - - - - - - - - - -
;colour attributes
	MOV	SI,[BP+12]
	MOV	AX,ES:[SI]	;AX = box f/g colour
	CMP	AX,7		;0 <= colour <= max?
	JA	VERI90		;{N} exit with error
;
	MOV	SI,[BP+10]
	MOV	DX,ES:[SI]	;DX = list f/g colour
	CMP	DX,7		;0 <= colour <= max?
	JA	VERI90		;{N} exit with error
;
	MOV	SI,[BP+8]
	MOV	BX,ES:[SI]	;BX = b/g colour
	CMP	BX,7		;0 <= colour <= max?
	JA	VERI90		;{N} exit with error
;
	CMP	AX,BX		;box f/g = b/g?
	JE	VERI90		;{Y} exit with error
	CMP	DX,BX		;list f/g = b/g?
	JE	VERI90		;{Y} exit with error
;
	MOV	AH,DL		;AH = list f/g
	MOV	BH,BL
	SHL	BX,1		;multiplex...
	SHL	BX,1		;...the...
	SHL	BX,1		;...colour...
	SHL	BX,1		;...numbers
	OR	AX,BX
	MOV	WORD PTR [DI+BOX_ATTR],AX
;- - - - - - - - - - - - - - - -
	MOV	RET_CODE,0	;clear error
;- - - - - - - - - - - - - - - -
VERI90:	RET
VERI	ENDP
;здддддддддддддддддддддддддддддд©
;Ё   OBTAIN BOX VIDEO OFFSET	Ё
;Ё       Top/Left Corner	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; SI	output	video offset
; CF	output	0=ok, 1=error
;ддддддддддддддддддддддддддддддд
ADDR	PROC	NEAR
	MOV	DI,CACHE_NEXT	;next available cache slot
	MOV	AX,[DI+BOX_TOP]	;AX = top_row (base 1)
	CALL	ADDRA		;AX = vid offset, CF:1 = error	
	JC	ADDR90		;exit if error			
;
	MOV    SI,[DI+BOX_LEFT]	;SI = left column (base 1)	
	DEC	SI		;SI = left column (base 0)	
	SHL	SI,1						
	ADD	SI,AX		;SI = vid buf offset
	MOV	[DI+BOX_OFF],SI	;save for future ref
	CLC			;clear error flag		
;
ADDR90:	RET							
ADDR	ENDP
;здддддддддддддддддддддддддддддд©
;Ё    SAVE UNDERLYING SCREEN	Ё
;юдддддддддддддддддддддддддддддды
; SI	input	box top/left vid offset
; DS	input	$LISTDS
;ддддддддддддддддддддддддддддддд
SAVE	PROC	NEAR
	PUSH	AX						
	PUSH	BX						
	PUSH	CX						
	PUSH	DX						
	PUSH	DI						
	PUSH	SI						
;
	MOV	RET_CODE,5	;assume error
	MOV	DI,CACHE_NEXT	;next available cache slot
;- - - - - - - - - - - - - - - -
	MOV  BX,[DI+BOX_WIDTH]	;BX = box width (columns, base 1)
	MOV  CX,[DI+BOX_HEIGHT]	;CX = box_height (rows, base 1)
	MOV	AX,BX
	MUL	CL
	SHL	AX,1		;AX = bytes to store underlying screen
	ADD	AX,DI
	ADD	AX,BOX_DATA	;AX = end offset of new box data+save
	CMP	AX,CACHE_LIMIT	;enough room to put it all?
	JA	SAVE90		;{N} exit with error
;
	MOV	AX,CACHE_BOX	;save offset of...
	MOV    [DI+BOX_BACK],AX	;...previous box data
;
	MOV	SI,[DI+BOX_OFF]
	ADD	DI,CACHE_POINT
	ADD	DI,BOX_DATA	;save to ES:[DI]
;- - - - - - - - - - - - - - - -
	PUSH	DS
	PUSH	ES
	MOV	AX,DS
	MOV	ES,AX		;ES = DS
;must copy text_cols before changing DS
	MOV	AX,TEXT_COLS	;AX = display width		
	MOV	DS,VIDEO_SEG	;DS = vid buf
	CLD
	SUB	AX,BX
	SHL	AX,1
SAVE10:	MOV	DX,CX		;copy rows-to-do count
	MOV	CX,BX		;CX = box_width (columns, base 1)
	REPZ	MOVSW		;save a row
	ADD	SI,AX
	MOV	CX,DX
	LOOP	SAVE10
	POP	ES
	POP	DS
;- - - - - - - - - - - - - - - -
	MOV	AX,CACHE_NEXT
	MOV	CACHE_BOX,AX	;start of new box data
	SUB	DI,CACHE_POINT					
	MOV	CACHE_NEXT,DI	;next available cache slot
	INC	BOX_LEVEL
	MOV	RET_CODE,0	;clear error
;
SAVE90:	POP	SI						
	POP	DI						
	POP	DX						
	POP	CX						
	POP	BX						
	POP	AX						
	RET							
SAVE	ENDP
;здддддддддддддддддддддддддддддд©
;Ё	     DRAW BOX		Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
;ддддддддддддддддддддддддддддддд
DRAW	PROC	NEAR
	PUSH	AX						
	PUSH	BX						
	PUSH	CX						
	PUSH	DX						
	PUSH	DI						
	PUSH	SI						
	PUSH	ES
;
	CLD
	MOV	SI,CACHE_BOX
;- - - - - - - - - - - - - - - -
	MOV	ES,VIDEO_SEG
	MOV	DI,[SI+BOX_OFF]
	MOV	AH,[SI+BOX_ATTR]
	MOV	BX,[SI+BOX_TYPE]
	ADD	BX,BOX_CHAR_START
	MOV	AL,[BX]
	STOSW			;top-left corner
	ADD	BX,3
	MOV	AL,[BX]
	MOV	CX,[SI+BOX_WIDTH]
	DEC	CX
	DEC	CX
	REPZ	STOSW		;top side
	ADD	BX,3
	MOV	AL,[BX]
	MOV	ES:[DI],AX	;top-right corner		
;
	ADD	BX,3
	MOV	AL,[BX]
	MOV	POSIN_CHR,AX	;save left&right side char...
	MOV	POSIN_ROW,1	;...and set dummy row for POSIN
	MOV	CX,[SI+BOX_HEIGHT]
	DEC	CX
	DEC	CX
DRAW20:	ADD	DI,TEXT_WIDTH					
	MOV	ES:[DI],AX	;right side			
	LOOP	DRAW20
;
	MOV	DI,[SI+BOX_OFF]
	MOV	CX,[SI+BOX_HEIGHT]
	DEC	CX
	DEC	CX
DRAW30:	ADD	DI,TEXT_WIDTH					
	MOV	ES:[DI],AX	;left side			
	LOOP	DRAW30
;
	ADD	BX,3
	MOV	AL,[BX]
	ADD	DI,TEXT_WIDTH					
	STOSW			;bottom-left corner
	ADD	BX,3
	MOV	AL,[BX]
	MOV	CX,[SI+BOX_WIDTH]
	DEC	CX
	DEC	CX
	REPZ	STOSW		;bottom side
	ADD	BX,3
	MOV	AL,[BX]
	STOSW			;bottom-right corner
;- - - - - - - - - - - - - - - -
;blank out list area
	MOV	AL,32
	MOV	AH,LIST_ATTR
	MOV	DX,[SI+BOX_WIDTH]
	DEC	DX
	MOV	DI,[SI+BOX_OFF]
	ADD	DI,DX
	ADD	DI,DX
	DEC	DX
	MOV	BX,TEXT_COLS					
	SUB	BX,DX
	SHL	BX,1
	MOV	CX,[SI+BOX_HEIGHT]
	DEC	CX
	DEC	CX
;
DRAW40:	MOV	SI,CX
	ADD	DI,BX
	MOV	CX,DX
	REPZ	STOSW
	MOV	CX,SI
	LOOP	DRAW40
;- - - - - - - - - - - - - - - -
	POP	ES
	POP	SI						
	POP	DI						
	POP	DX						
	POP	CX						
	POP	BX						
	POP	AX						
	RET
DRAW	ENDP
;здддддддддддддддддддддддддддддд©
;Ё    WIPE BOX FROM DISPLAY	Ё
;юдддддддддддддддддддддддддддддды
LISTCLR	PROC	FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	DS
	PUSH	ES
	MOV	AX,DS
	MOV	ES,AX		;ES = BASIC data seg
	CALL	LISTDS		;DS = $LISTDS
	MOV	SRC_ID,3	;LISTCLR id-num
;- - - - - - - - - - - - - - - -
	MOV	RET_CODE,2
	CMP	INIT_FLAG,1	;init'd?
	JNE	CLR90		;{N} exit with error
;- - - - - - - - - - - - - - - -
	MOV	RET_CODE,3	;assume error
	CMP	BOX_LEVEL,0	;is there a box to clear?
	JL	CLR80		;{N} exit with error
	MOV	RET_CODE,0	;{Y} clear error
	CALL	CLEAR		;wipe box
	CALL	PARAM		;init list metadata
;- - - - - - - - - - - - - - - -
;restore previous position indicator data
	CMP	BOX_LEVEL,0	;is there a box remaining?
	JL	CLR80		;{N} skip restore
	MOV	SI,CACHE_BOX	;{Y} restore position indic
	MOV	AX,[SI+POSIN_CHR_SAVE]
	MOV	POSIN_CHR,AX
	MOV	AX,[SI+POSIN_ROW_SAVE]
	MOV	POSIN_ROW,AX
;- - - - - - - - - - - - - - - -
CLR80:	MOV	CX,RET_CODE
	JCXZ	CLR90
	CALL	MESS
	MOV	RET_CODE,CX
;
CLR90:	MOV	AX,RET_CODE
	MOV	DI,[BP+6]
	MOV	ES:[DI],AX
	MOV	SRC_ID,1
	POP	ES
	POP	DS
	POP	BP
	RET	2
LISTCLR	ENDP
;здддддддддддддддддддддддддддддд©
;Ё  RESTORE UNDERLYING SCREEN	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
;ддддддддддддддддддддддддддддддд
CLEAR	PROC	NEAR
	PUSH	AX						
	PUSH	BX						
	PUSH	CX						
	PUSH	DX						
	PUSH	DI						
	PUSH	SI						
;
	MOV	SI,CACHE_BOX
	MOV  BX,[SI+BOX_WIDTH]	;BX = box width (columns, base 1)
	MOV  CX,[SI+BOX_HEIGHT]	;CX = box height (rows, base 1)
	MOV  DI,[SI+BOX_OFF]
	ADD	SI,CACHE_POINT
	ADD	SI,BOX_DATA
;- - - - - - - - - - - - - - - -
	PUSH	ES
	MOV	ES,VIDEO_SEG
	CLD
	MOV	AX,TEXT_COLS					
	SUB	AX,BX
	SHL	AX,1
CLEAR1:	MOV	DX,CX		;save rows-to-do count
	MOV	CX,BX		;CX = box width (columns, base 1)
	REPZ	MOVSW		;xfer row
	ADD	DI,AX		;DI = start of next row
	MOV	CX,DX		;restore rows-to-do
	LOOP	CLEAR1
	POP	ES
;- - - - - - - - - - - - - - - -
	MOV	SI,CACHE_BOX
	MOV	CACHE_NEXT,SI
	MOV	AX,[SI+BOX_BACK]
	MOV	CACHE_BOX,AX
	DEC	BOX_LEVEL
;
	POP	SI						
	POP	DI						
	POP	DX						
	POP	CX						
	POP	BX						
	POP	AX						
	RET
CLEAR	ENDP
;здддддддддддддддддддддддддддддд©
;Ё     SET UP LIST METADATA	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
;ддддддддддддддддддддддддддддддд
PARAM	PROC	NEAR
	PUSH	AX						
	PUSH	SI						
;
	MOV	SI,CACHE_BOX
;
	MOV	AX,[SI+BOX_TOP]
	INC	AX
	MOV	LIST_TOP,AX
;
	MOV	AX,[SI+BOX_BOTTOM]
	DEC	AX
	MOV	LIST_BOTTOM,AX
;
	MOV	AX,[SI+BOX_LEFT]
	MOV	LIST_LEFT,AX
;
	MOV	AX,[SI+BOX_RIGHT]
	DEC	AX
	MOV	LIST_RIGHT,AX
;
	MOV	AX,[SI+BOX_HEIGHT]
	SUB	AX,3
	MOV	LIST_HEIGHT,AX
;
	MOV	AX,[SI+BOX_WIDTH]
	SUB	AX,3
	MOV	LIST_WIDTH,AX
;
	MOV	AX,[SI+BOX_TYPE]
	MOV	LIST_TYPE,AX
	CMP	AX,0
	MOV	AX,WORD PTR [SI+BOX_ATTR]
	JNE	PARAM1
	ROL	AL,1		;reverse image...
	ROL	AL,1		;...frame attr...
	ROL	AL,1		;...if box...
	ROL	AL,1		;...is type 0
PARAM1:	MOV	WORD PTR FRAME_ATTR,AX
;
	POP	SI						
	POP	AX						
	RET
PARAM	ENDP
;здддддддддддддддддддддддддддддд©
;Ё	DISPLAY A MESSAGE	Ё
;юдддддддддддддддддддддддддддддды
; DS	input	$LISTDS
; CX	input	message number
;ддддддддддддддддддддддддддддддд
MESS	PROC	NEAR
	PUSH	AX						
	PUSH	BX						;[0.14]
	PUSH	CX
	PUSH	DI						
	PUSH	SI						
	PUSH	WORD PTR FRAME_ATTR
;
	MOV	MSG_NUM,CX	;save msg num
	ADD	CACHE_LIMIT,MSG_ROOM	;reveal hidden room	
	MOV	DI,CACHE_NEXT	;next available cache slot
	MOV	AX,MSG_TOP					
	MOV	[DI+BOX_TOP],AX					
	ADD	AX,MSG_HEIGHT					
	DEC	AX		;AX = bottom row (base 1)	
	MOV	[DI+BOX_BOTTOM],AX				
	MOV	[DI+BOX_HEIGHT],MSG_HEIGHT
	MOV	AX,MSG_LEFT					
	MOV	[DI+BOX_LEFT],AX				
	ADD	AX,MSG_WIDTH					
	DEC	AX		;AX = right column (base 1)	
	MOV	[DI+BOX_RIGHT],AX				
	MOV	[DI+BOX_WIDTH],	MSG_WIDTH
	MOV	[DI+BOX_TYPE],	MSG_TYPE
	MOV	WORD PTR [DI+BOX_ATTR],	MSG_ATTR
	MOV	WORD PTR FRAME_ATTR,	MSG_ATTR
;- - - - - - - - - - - - - - - -
;save position indicator data
	CMP	BOX_LEVEL,0	;is there a lower-level box?
 	JL	MESS00		;{N} skip save
	MOV	DI,CACHE_BOX	;{Y} save position...
	MOV	AX,POSIN_CHR	;    ...indicator data
	MOV	[DI+POSIN_CHR_SAVE],AX
	MOV	AX,POSIN_ROW
	MOV	[DI+POSIN_ROW_SAVE],AX
;- - - - - - - - - - - - - - - -
MESS00:	CALL	ADDR		;SI = box top/left vid offset
	JNC	MESS02		;continue if no error		
	MOV	RET_CODE,10	;set error code			
	JMP	MESS90		;exit				
MESS02:	CALL	SAVE		;save underlying screen		
	CMP	RET_CODE,0	;error?
	JE	MESS04		;{N} continue		ЁMESS90 tooЁ
	JMP	MESS90		;{Y} exit		Ёfar for JGЁ
MESS04:	CALL	DRAW		;{N} draw box
;
	MOV	DI,SI		;DI = box top/left vid offset	
	ADD	DI,TEXT_WIDTH					
	ADD	DI,4		;DI = msg src_name vid offset	
;- - - - - - - - - - - - - - - -
;point to msg-source name
	PUSH	ES
	MOV	ES,VIDEO_SEG
;
	MOV	SI,SRC_ID	;SI = src id-num (base 1)
	CMP	SI,SRC_END	;recognized?
	JB	MESS10		;{Y} continue
	MOV	SI,1		;{N} force name_1 (='unknown')
MESS10:	DEC	SI		;convert to...
	SHL	SI,1		;...pointer
	ADD	SI,SRC_OFF	;DS:[SI] = name addr
	MOV	SI,[SI]		;DS:[SI] = name
	MOV	AH,MSG_ATTR_TXT	;AH = vid attr			
	MOV	CX,SRC_NAME_LEN	;CX = name len (chars, base 1)	
;-  -  -  -  -  -  -  -  -  -  -
	PUSH	DI						
MESS20:	LODSB			;AL = name char
	STOSW
	LOOP	MESS20
	ADD	DI,ESC_FILL					
	MOV	SI,ESC_OFFSET					
	MOV	CX,ESC_LEN	;CX = "Esc" len (chars, base 1)	
MESS22:	LODSB			;AL = "Esc" char		
	STOSW							
	LOOP	MESS22						
	POP	DI						
;-  -  -  -  -  -  -  -  -  -  -
	ADD	DI,TEXT_WIDTH	;DI = msg text vid offset	
;point to msg text
	MOV	SI,MSG_NUM	;SI = msg num (base 1)
	CMP	SI,MSG_ADDR_END	;recognized?
	JB	MESS30		;{Y} continue
	MOV	SI,MSG_DFLT	;{N} force default msg (='unknown')
MESS30:	DEC	SI		;convert to...
	SHL	SI,1		;...descriptor...
	SHL	SI,1		;...table pointer
	ADD	SI,MSG_ADDR_OFF	;DS:[SI] = msg addr
	MOV	CX,[SI]		;CX = msg length	(chars, base 1)
	MOV	SI,[SI+2]	;SI = msg offset
	MOV	AX,MSG_MAX	;AX = max msg length
	SUB	AX,CX		;AX = filler length	(blanks, base 1)
	JNS	MESS40
	MOV	CX,MSG_MAX
	XOR	AX,AX
MESS40:	ADD	DI,AX		;msg text now centred
	MOV	AH,MSG_ATTR_BOX	;AH = vid attr			
MESS50:	LODSB			;AL = text char
	STOSW
	LOOP	MESS50
	POP	ES
;- - - - - - - - - - - - - - - -
;;;S60:	CALL	KEYIN		;get keyboard input
MESS60:	CALL	$$PRESS		;AL = ASCII, AH = key scan-code	;[0.14]
				;BX = shifts/locks status	;[0.14]
	CMP	AL,27		;[Esc]?
	JNE	MESS60		;{N} loop
	CALL	CLEAR		;{Y} wipe box
;- - - - - - - - - - - - - - - -
;restore previous position indicator data
	CMP	BOX_LEVEL,0	;is there a box remaining?
	JL	MESS90		;{N} skip restore
	MOV	SI,CACHE_BOX	;{Y} restore position indic
	MOV	AX,[SI+POSIN_CHR_SAVE]
	MOV	POSIN_CHR,AX
	MOV	AX,[SI+POSIN_ROW_SAVE]
	MOV	POSIN_ROW,AX
;- - - - - - - - - - - - - - - -
MESS90:	SUB	CACHE_LIMIT,MSG_ROOM	;hide msg room again	
	POP	WORD PTR FRAME_ATTR
	POP	SI						
	POP	DI						
	POP	CX
	POP	BX						;[0.14]
	POP	AX						
	RET
MESS	ENDP
;ммммммммммммммммммммммммммммммм
$LISTCS	ENDS
	END	LISTMAN
