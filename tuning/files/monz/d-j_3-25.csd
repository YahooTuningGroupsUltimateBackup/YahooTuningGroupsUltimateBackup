<CsoundSynthesizer>

	;example 3.25 from Dodge/Jerse _Computer Music_
	;Generation of noise bands by means of ring modulation
	;chapter 3.11B - Instrument Design Examples
	;file created 2005-10-05 by monz

;=======================================================================================

<CsOptions>

	-W	-s	-o	d-j_3-25_cw.wav

	;^	^	^	^
	;|	|	|	|___ the name of the output soundfile
	;|	|	|
	;|	|	|__ flag stipulating that output soundfile will be named here
	;|	|          
	;|	|__ "short" integer calculations
	;|
	;|__ the type of output soundfile: this one will be in .wav format
	
</CsOptions>

;========================================================================================

<CsInstruments>


	; --- HEADER ---
	
		sr	=	44100        ; Usual header information
		kr	=	4410
		ksmps	=	10
		nchnls	=	1

	;instr1
	
	; --- BLOCK DIAGRAM ---
		;
		;     amp
		; rise |  decay
		;  |   v   |
		;  v ----- v
		;  / linen \
		;  ---------
		;      |
		;      |  kcps
		;      |   |
		;      v   v
		;     -------
		;    | randi |
		;     -------
		;       |
		;       |  acps
		;       |   | 
		;       v   v
		;   -----------
		;   |         |
		;    \ oscil /
		;      -----
		;        |
		;        v
		;        -
		;       /|\ out
		;
	
	
	; --- MAIN CODE ---


		instr	1
		
			;--- VARIABLE DECLARATIONS ---------------------------------------
			;
			idur	=	p3		;DURATION OF NOTE
			iamp	=	32767*p4	;amp (p4) scaled from 0 to 1
			acps	=	p5		;FREQUENCY OF RANDOM GENERATOR IN Hz
			kcps	=	p6
			irise	=	p7
			idecay	=	p8
			;
			;-----------------------------------------------------------------
			
			
			;OUTPUT	OPCODE	ARGUMENTS

			;--- ENVELOPE GENERATOR---------------------
			;
			;		p4	P7	p3	p8
			;		AMP	START	DUR	END
			aw1	linen	iamp,	irise,	idur,	idecay
			;
			;-------------------------------------------

			;--- AUDIO AMPLITUDE CONTROL SOURCE --------------------------
			;
			;			p6
			;		AMP	FREQ_R
			aw2	randi	aw1,	kcps
			;
			;-------------------------------------------

			;--- AUDIO SOURCE --------------------------
			;
			;			p5
			;		AMP	FREQ	FUNC#
			aw3	oscil	aw2,	acps,	1
			aw4	oscil	aw2,	acps*2,	1
			aw5	oscil	aw2,	acps*3,	1
			aw6	oscil	aw2,	acps*4,	1
			;
			;-------------------------------------------

			;--- OUTPUT --------------------------------
			;
		        	out	aw3+aw4+aw5+aw6
			;
			;-------------------------------------------
				
		endin

          
</CsInstruments>

;========================================================================

<CsScore>

	;score created entirely by monz

	; ---- FUNCTION-TABLE DEFINITIONS -------------
	;sine wave:
	;f#	time	size	gen#	partials:
	;				1
	f1	0	1024	10	1
	
	
	; ---- NOTE EVENTS ----------------------------	
	;p1	p2	p3	p4	p5	p6	p7	p8
	;instr#	start	dur	amp	freq_c	freq_r	en_rise	en_decay
	
	i 1	0	2.5	0.30	400	1	.5	.5
	i 1	3	2.5	0.30	400	5	.5	.5
	i 1	6	2.5	0.30	400	10	.5	.5
	i 1	9	2.5	0.30	400	20	.5	.5
	i 1	12	2.5	0.30	400	30	.5	.5
	i 1	15	2.5	0.30	400	40	.5	.5
	i 1	18	2.5	0.30	400	50	.5	.5
	i 1	21	2.5	0.30	400	60	.5	.5
	i 1	24	2.5	0.30	400	70	.5	.5
	i 1	27	2.5	0.30	400	80	.5	.5
	i 1	30	2.5	0.30	400	90	.5	.5
	i 1	33	2.5	0.30	400	100	.5	.5
	i 1	36	2.5	0.30	400	200	.5	.5
	i 1	39	2.5	0.30	400	300	.5	.5
	i 1	42	2.5	0.30	400	400	.5	.5
	i 1	45	2.5	0.30	400	500	.5	.5
	i 1	48	2.5	0.30	400	600	.5	.5
	i 1	51	2.5	0.30	400	700	.5	.5
	i 1	54	2.5	0.30	400	800	.5	.5
	i 1	57	2.5	0.30	400	900	.5	.5

</CsScore>

;========================================================================

</CsoundSynthesizer>