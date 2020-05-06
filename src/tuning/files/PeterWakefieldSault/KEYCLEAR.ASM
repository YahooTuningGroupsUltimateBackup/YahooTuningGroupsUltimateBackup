; KEYCLEAR.ASM  0.02  14/MAY/96
; Clear Keyboard Buffer
; for Compiled BASIC and Inter-Library CALLs
; Copyright (C) Peter Sault 1996
; All rights reserved worldwide
;อออออออออออออออออออออออออออออออ
; 100 CALL KEYCLEAR	'clear keyboard buffer
; no param
;อออออออออออออออออออออออออออออออ
$KEY	SEGMENT BYTE PUBLIC 'KEY_CODE'
	ASSUME	CS:$KEY
	PUBLIC	KEYCLEAR
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
KEYCLEAR PROC	FAR
	PUSH	AX						;[0.02]
CLEAR1:	MOV	AH,1		;func = Get Keystroke Status
	INT	16H		;ZF=status, AH=scan code, AL=ASCII char
	JZ	CLEAR2		;{N} exit
	XOR	AH,AH		;{Y} func = Get Keystroke
	INT	16H		;AH=scan code, AL=ASCII char
	JMP	SHORT CLEAR1	;repeat
;;;AR2:	RET	0
CLEAR2:	POP	AX						;[0.02]
	RET	0						;[0.02]
KEYCLEAR ENDP
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
$KEY	ENDS
	END	KEYCLEAR
