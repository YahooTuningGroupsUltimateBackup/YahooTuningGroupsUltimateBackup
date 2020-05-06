; SPEAKER.ASM  0.01  14/MAY/96
; PC Speaker Functions
; Copyright (C) Peter Sault 1996
; All rights reserved worldwide
;อออออออออออออออออออออออออออออออ
; 100 CALL SPEAKON(FREQ%)	;initiate note
; 100 CALL SPEAKOFF		;terminate note
;อออออออออออออออออออออออออออออออ
$TIMER	SEGMENT PARA PUBLIC 'TIMER_CODE'
	ASSUME	CS:$TIMER
	PUBLIC	SPEAKON
	PUBLIC	SPEAKOFF
;ษออออออออออออออออออออออออออออออป
;บ	TURN PC SPEAKER ON	บ
;ศออออออออออออออออออออออออออออออผ
PIT_COUNT	DW	?
;
CLK_FRQ_HI	EQU	0012H	;MSW of CLK rate
CLK_FRQ_LO	EQU	34DCH	;LSW of CLK rate
;
PPI_SWITCH	EQU	61H	;8255 port B address
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
SPEAKON	PROC	FAR
	PUSH	BP
	MOV	BP,SP
	MOV	SI,[BP+6]
	MOV	CX,[SI]		;CX = frequency (Hz)
	CMP	CX,20		;at/above minimum?
	JB	SPON90		;{N} skip it
;
; Set counter for requested frequency
	MOV	DX,CLK_FRQ_HI
	MOV	AX,CLK_FRQ_LO
	DIV	CX		;AX = count
	MOV	PIT_COUNT,AX
	CALL	COUNT		;set counter
;
	IN	AL,PPI_SWITCH	;read 8255 PPI
	OR	AL,3		;connect...
	OUT	PPI_SWITCH,AL	;...the speaker
;
SPON90:	POP	BP
	RET	2
SPEAKON	ENDP
;ษออออออออออออออออออออออออออออออป
;บ     TURN PC SPEAKER OFF	บ
;ศออออออออออออออออออออออออออออออผ
SPEAKOFF PROC	FAR
	IN	AL,PPI_SWITCH	;read 8255 PPI
	AND	AL,NOT 3	;disconnect...
	OUT	PPI_SWITCH,AL	;...the speaker
	RET	0
SPEAKOFF ENDP
;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ   SET PC SPEAKER FREQUENCY	ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; The CLK inputs to the 8253 PITs on a PC are driven at a fixed rate
; of 1.193180 Mhz, irrespective of the processing rate of the CPU.
; The PC speaker line is tied to the OUT pin of PIT counter 2.
; The data port address for counter 2 is 42H.
; The control word (written to port 43H for all counters) is
; formatted as follows:-
;	Bits	Field	Significance
;	 0	BCD	0 = binary count
;			1 = BCD count
;	1-3	M	000 = mode 0	Interrupt on terminal count
;			001 = mode 1	Hardware triggerable one-shot
;			010 = mode 2	Rate generator
;			011 = mode 3	Square wave mode
;			100 = mode 4	Software triggered strobe
;			101 = mode 5	Hardware triggered strobe
;			110 = mode 2	{not recommended}
;			111 = mode 3	{not recommended}
;	4-5	RW	00 = counter latch command
;			01 = read/write LSB only
;			10 = read/write MSB only
;			11 = read/write LSB then MSB
;	6-7	SC	00 = select counter 0
;			01 = select counter 1	!!! DO NOT TOUCH !!!
;			10 = select counter 2
;			11 = 8253: illegal
;			   = 8254: read-back command
;- - - - - - - - - - - - - - - -
PIT_CTRL	EQU	043H	;port for 8253 control_reg
PIT_DATA	EQU	042H	;port for 8253 counter_2 data_reg
PIT_CMND	EQU	0B6H	;8253 cmd = counter2,LSB&MSB,mode3
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
COUNT	PROC	NEAR
	PUSH	AX
	MOV	AL,PIT_CMND
	OUT	PIT_CTRL,AL
	MOV	AX,PIT_COUNT
	OUT	PIT_DATA,AL
	MOV	AL,AH
	OUT	PIT_DATA,AL
	POP	AX
	RET
COUNT	ENDP
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
$TIMER	ENDS
	END
