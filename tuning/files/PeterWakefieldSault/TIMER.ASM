; 100 CALL TIMINIT
; 100 CALL TIMEXIT
; 100 CALL TIMWAIT(PERIOD%)	'period in millisecs
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
$TIMER	SEGMENT PARA PUBLIC 'TIMER_CODE'
	ASSUME	CS:$TIMER
	PUBLIC	TIMINIT		;initialization
	PUBLIC	TIMEXIT		;termination
	PUBLIC	TIMWAIT		;call delay
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
DONE_BITS	DB	0
;
;subrs INTSET and INTRES
INTFAR		LABEL	DWORD
INTOFF		DW	0	;system timer-...
INTSEG		DW	0	;...interrupt-vector store
;
TEMPO_ACCUM	DW	0				
TEMPO_COUNT	DW	0FFFFH	;8253 loaded counter_0 value
				;65535 (FFFFh) is the normal counter_0
				;value for system-timer functions.
;
TIME_FLAG	DB	0	;status (0=idle, -1=active)
TIME_COUNT	DW	0	;msecs (1-65535)
;ษออออออออออออออออออออออออออออออป
;บ I N I T I A L I Z A T I O N	บ
;บ	I N T E R F A C E	บ
;ศออออออออออออออออออออออออออออออผ
TIMINIT	PROC	FAR
	CALL	INTSET
	RET	0
TIMINIT	ENDP
;ษออออออออออออออออออออออออออออออป
;บ    T E R M I N A T I O N	บ
;บ	I N T E R F A C E	บ
;ศออออออออออออออออออออออออออออออผ
TIMEXIT	PROC	FAR
	CALL	INTRES
	RET	0
TIMEXIT	ENDP
;ษออออออออออออออออออออออออออออออป
;บ     C O U N T - D O W N	บ
;บ	I N T E R F A C E	บ
;ศออออออออออออออออออออออออออออออผ
TIMWAIT	PROC	FAR
	PUSH	BP
	MOV	BP,SP
	TEST	DONE_BITS,40H	;timer installed?
	JZ	WAIT90		;{N} exit
	MOV	SI,[BP+6]
	MOV	AX,[SI]
	MOV	TIME_COUNT,AX
WAIT10:	CMP	TIME_COUNT,0
	JNE	WAIT10
WAIT90:	POP	BP
	RET	2
TIMWAIT	ENDP
;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ   REPLACE TIMER INT VECTOR	ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
INTSET	PROC	NEAR
	TEST	DONE_BITS,40H	;already installed?
	JNZ	INTS9		;{Y} exit
;- - - - - - - - - - - - - - - -
	PUSH	AX
	PUSH	BX
	PUSH	DX
	PUSH	DS
	PUSH	ES
;
; Disable IRQ0
	IN	AL,21H
	OR	AL,1
	OUT	21H,AL
;
; Get/save system timer interrupt vector
	MOV	AX,3508H	;func 35h, INT_08h
	INT	21H		;get INT_08h vector (to ES:BX)
;
	MOV	INTSEG,ES	;save segment...
	MOV	INTOFF,BX	;...and offset
;
; Set local ISR vector
	MOV	AX,CS
	MOV	DS,AX		;DS = CS
	LEA	DX,TIME		;DX = internal handler offset
	MOV	AX,2508H	;func 25h, INT_08h
	INT	21H		;set INT_08h vector from DS:DX
;
; Set IRQ0 rate to 1kHz
	MOV	TEMPO_COUNT,04A9H				;[0.02]
	CALL	TEMPO		;set IRQ rate			;[0.02]
;
; Enable IRQ0
	IN	AL,21H
	AND	AL,NOT 1
	OUT	21H,AL
;
	OR	DONE_BITS,40H	;set vector_install flag
	POP	ES
	POP	DS
	POP	DX
	POP	BX
	POP	AX
;- - - - - - - - - - - - - - - -
INTS9:	RET
INTSET	ENDP
;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ   RESTORE TIMER INT VECTOR	ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
INTRES	PROC	NEAR
	TEST	DONE_BITS,40H	;int_vector installed?
	JZ	INTR9		;{N} exit
;- - - - - - - - - - - - - - - -
	PUSH	AX
	PUSH	DX
	PUSH	DS
;
	AND	DONE_BITS,0BFH	;reset install flag
;
; Disable IRQ0
	IN	AL,21H
	OR	AL,1
	OUT	21H,AL
;
; Set IRQ0 rate to 18.2Hz
	MOV	TEMPO_COUNT,0FFFFH
	CALL	TEMPO
;
; Restore system INT_08h vector
	LDS	DX,INTFAR	;DS:DX = int handler
	MOV	AX,2508H	;func 25h, INT_08h
	INT	21H		;set INT_08h vector from DS:DX
;
; Enable IRQ0
	IN	AL,21H
	AND	AL,NOT 1
	OUT	21H,AL
;
	POP	DS
	POP	DX
	POP	AX
;- - - - - - - - - - - - - - - -
INTR9:	RET
INTRES	ENDP
;ษออออออออออออออออออออออออออออออป
;บ   TIMER INTERRUPT HANDLER	บ
;ศออออออออออออออออออออออออออออออผ
TIME	PROC						
	PUSH	AX
;
	CMP	TIME_COUNT,0	;period count set?
	JE	TIME80		;{N} bypass

;;;	CMP	TIME_FLAG,0	;previously activated?
;;;	JNE	TIME10		;{Y} carry on
;;;	MOV	TEMPO_COUNT,04A9H	;set counter for 1kHz IRQ rate
;;;	CALL	TEMPO		;set IRQ rate
;;;	MOV	TIME_FLAG,-1
;
;;;E10:	DEC	TIME_COUNT	;{Y} decr count
;;;	JNZ	TIME80
;;;	MOV	TEMPO_COUNT,0FFFFH	;set counter for 18.2Hz IRQ rate
;;;	CALL	TEMPO		;set IRQ rate
;;;	MOV	TIME_FLAG,0
	DEC	TIME_COUNT	;{Y} decr count			;[0.02]
;
TIME80:	MOV	AX,TEMPO_COUNT
	ADD	TEMPO_ACCUM,AX
	JNC	TIME90
	POP	AX
	JMP	[INTFAR]
;
TIME90:	MOV	AL,20H		;signal end-of-IRQ...
	OUT	20H,AL		;...(EOI) to PIC (8259)
	POP	AX
	IRET
TIME	ENDP
;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ   SET TIMER-INTERRUPT RATE	ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; The CLK inputs to the 8253 PITs on a PC are driven at a fixed rate
; of 1.193180 Mhz, irrespective of the processing rate of the CPU.
; The system timer interrupt line (IRQ0) is tied to the OUT pin of
; PIT counter 0. For the system INT08h ISR, interrupt requests are
; generated at the lowest possible rate (18.20676Hz) by setting the
; count to the maximum of FFFFh (= 65535). [note:- the 8253 interprets
; a count of 0 as 10000h (= 65536), which would give an interrupt
; request rate of 18.20648Hz, but this value is not used by the PC
; system timer function. The `lowest' count is 1, giving an IRQ rate
; of 1.193180MHz.] Thus, the timer can only be made to run faster.
; To obtain a resolution of approximately 1msec, the count must be set
; to 04A9h (= 1193). This makes the IRQ0 rate 1000.151Hz, giving an
; actual resolution of 0.9999849msec.
; A precision 20Hz IRQ rate (i.e. a resolution of exactly 50msec) can
; be obtained with a count of E90Bh (= 59659; a prime number).
; A count of 2E9Ch (= 11932) gives an IRQ rate of 99.9983Hz.
; A count of 2E9Bh (= 11931) gives an IRQ rate of 100.007Hz.
;- - - - - - - - - - - - - - - -
TEMPO_PORTC	EQU	43H	;port for 8253-5 timer chip control_reg
TEMPO_PORTD	EQU	40H	;port for 8253-5 timer chip data_reg
TEMPO_CMND	EQU	36H	;8253-5 cmd = counter0,LSB,MSB,mode3
;-------------------------------
TEMPO	PROC	NEAR
	PUSH	AX
	MOV	AL,TEMPO_CMND
	OUT	TEMPO_PORTC,AL
	MOV	AX,TEMPO_COUNT
	OUT	TEMPO_PORTD,AL
	MOV	AL,AH
	OUT	TEMPO_PORTD,AL
	POP	AX
	RET
TEMPO	ENDP
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
$TIMER	ENDS
	END
