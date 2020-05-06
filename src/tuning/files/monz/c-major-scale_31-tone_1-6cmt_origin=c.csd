
<CsoundSynthesizer>

<CsOptions>
	-W -s -o c-major-scale_31-tone_1-6cmt_origin=c.wav
</CsOptions>

<CsInstruments>
;------------------------------------------------------------------------------------
; COMPUTER-GENERATED CSOUND ORCHESTRAL FILE
;
; CREATED BY TONESCAPE: WWW.TONALSOFT.COM
;------------------------------------------------------------------------------------
sr        =         44100                         ;SAMPLE RATE 
kr        =         4410                          ;CONTROL RATE 
ksmps     =         10                            ;AUDIO-CONTROL RATIO 
nchnls    =         2                             ;NUMBER OF OUTPUT CHANNELS 
0dbfs     =         1                             ;CONFIGURE SCALING FACTORS 


;------------------------------------------------------------------------------------
; INITIALIZE ZAK CHANNELS
;------------------------------------------------------------------------------------
          zakinit   2, 2                          ;INITIALIZE ZAK CHANNELS 


;------------------------------------------------------------------------------------
; GUITAR CLASSICAL
;
; A STANDARD NYLON-STRING CLASSICAL GUITAR.
;------------------------------------------------------------------------------------
          instr     50        

inum      =         p1                            ;INSTRUMENT NUMBER 
itime     =         p2                            ;START TIME, SECONDS 
idur      =         -p3                           ;NOTE DURATION 
izak      =         p4                            ;ZAK CHANNEL 
irel      =         p5                            ;RELEASE TIME IN SECONDS 
icent     =         p6                            ;PITCH IN ABSOLUTE CENTS 
icentz    =         p7                            ;PITCH TRANSITION TICKS 
ivol      =         p8                            ;VOLUME 
ivolz     =         p9                            ;VOLUME TRANSITION TICKS 
ifngr     =         p10                           ;TECHNIQUE: FINGERBOARD 
imute     =         p11                           ;TECHNIQUE: MUTE 
imutez    =         p12                           ;TECHNIQUE TICKS: MUTE 

          cigoto    (idur == 0.0), bye            ;IF TURNING NOTE OFF, JUST QUIT
          kgoto     kperf                         ;IF K-TIME, GOTO K-PERFORMANCE
          tigoto    tiinit                        ;IF TI-TIME, GOTO TI-INITIALIZE
; +++++++++++++++++++++++++++
; AUTO-GEN I-INIT
; +++++++++++++++++++++++++++
idvol     =         0                             ;VOLUME SETTINGS
iivol     =         ivol
kvol      init      ivol
kvoli     init      0
idcent    =         0                             ;FREQUENCY SETTINGS IN CENTS
iicent    =         icent
kcent     init      icent
kcenti    init      0
ihz       =         2^(icent/1200)*440
khz       init      ihz
          goto      kperf
; +++++++++++++++++++++++++++
; AUTO-GEN TI-INITIALIZATION
; +++++++++++++++++++++++++++
tiinit:
          cggoto    (iivol == ivol), tiinit0
idvol     =         (ivol - iivol) / ivolz
iivol     =         ivol
kvoli     init      ivolz
tiinit0:
          cggoto    (iicent == icent), tiinit1
idcent    =         (icent - iicent) / icentz
iicent    =         icent
kcenti    init      icentz
ihz       =         2^(icent/1200)*440
tiinit1:
          goto      techs
; +++++++++++++++++++++++++++
; AUTO-GEN K-PERFORMANCE
; +++++++++++++++++++++++++++
kperf:
krlenv    linseg    1.0, idur - irel, 1.0, irel, 0.0
          cggoto    (kvoli == 0), kperf0
kvoli     =         kvoli - 1
kvol      =         kvol + idvol
kperf0:
          cggoto    (kcenti == 0), kperf1
kcenti    =         kcenti - 1
kcent     =         kcent + idcent
khz       =         2^(kcent/1200)*440
kperf1:
techs:

; ********** TECHNIQUE START **********
          kgoto     techsk00                     ;IF K-TIME, GOTO K-PERFORMANCE
          tigoto    ttinit00                     ;IF TI-TIME, GOTO TI-INITIALIZE
; +++++++++++++++++++++++++++
; TECHNIQUE I-INITIALIZATION
; +++++++++++++++++++++++++++
idmute    =         0
iimute    =         imute
kmute     init      imute
kmutei    init      0
          goto      techsk00
; +++++++++++++++++++++++++++
; TECHNIQUE TI-INITIALIZATION
; +++++++++++++++++++++++++++
ttinit00:
          cggoto    (iimute == imute), techs01
idmute    =         (imute - iimute) / imute
iimute    =         imute
kmutei    init      imutez
          goto      techs01
; +++++++++++++++++++++++++++
; TECHNIQUE K-DELTA
; +++++++++++++++++++++++++++
techsk00:
          cggoto    (kmutei == 0), techs01
kmute     =         kmutei - 1
kmute     =         kmute + idmute
techs01:
; ********** TECHNIQUE END **********

; ***** START INSTRUMENT TIMBRE ****

; ...............................................
; I-TIME (PREMIERE) INITIALIZATION
; ...............................................
          kgoto     perform
          tigoto    tied
itable    =         0                             ;PLUCK OPCODE PARAMETERS
imethod   =         1

          cggoto    (ifngr != 5), it00
iatthigh  =         0.033
iattlow   =         0.055
          goto      it01
it00:
iatthigh  =         0.018
iattlow   =         0.043

it01:
icnthigh  =         221
icntlow   =         -4832
islope    =         (iatthigh - iattlow) / (icnthigh - icntlow)
iatttime  =         (icent - icntlow) * islope + iattlow
          goto      perform

; ...............................................
; TI-TIME (TIED-NOTE) INITIALIZATION
; ...............................................
tied:
          cggoto    (irel == 0), tied0
tied0:
          goto bye

; ...............................................
; PERFORM INSTRUMENT
; ...............................................
perform:

; ...............................................
; FINGERED PLUCKED
; ...............................................
          cggoto    (ifngr != 5), fingered
kamp      linseg    0.0, iatttime, ivol, idur-0.1, ivol, 0.05, 0.0
          kgoto     common

; ...............................................
; TAPPED
; ...............................................
fingered:
kamp      linseg    0.0, iatttime, ivol, idur-0.065, ivol, 0.05, 0.0

; ...............................................
; COMMON TO FINGER-PLUCKED AND TAPPED.
; ...............................................
common:
asig	  pluck     kamp, khz, ihz, itable, imethod
af1       reson     asig, 110, 80
af2       reson     asig, 220, 100
af3       reson     asig, 250, 100
af4       reson     asig, 440, 80
af5       reson     asig, 750, 200
af6       reson     asig, 1400, 700
af7       reson     asig, 3400, 900
af8       reson     asig, 5400, 800
af1a      =         af1*0.5
af2a      =         af2*0.4
af3a      =         af3*1.0
af4a      =         af4*0.4
af5a      =         af5*0.6
af6a      =         af6*1.6
af7a      =         af7*1.0
af8a      =         af8*0.7
amix      =         af1a+af2a+af3a+af4a+af5a+af6a+af7a+af8a
aout      balance   amix, asig

; ***** END INSTRUMENT TIMBRE ****
zakout:
          zawm      aout * krlenv, izak 
bye:
          endin     


;------------------------------------------------------------------------------------
; GENERAL-PURPOSE PART-INSTANCE MIXER AND AUDIO-EFFECTS
; PROCESSOR.  INCOMING SIGNALS ARE ALL MONO AND WILL BE
; EXPANDED AND MIXED TO MULTIPLE CHANNELS WITH THIS DEVICE.
;------------------------------------------------------------------------------------
          instr     25000     

inum      =         p1                            ;INSTRUMENT NUMBER 
itime     =         p2                            ;START TIME, SECONDS 
idur      =         -p3                           ;NOTE DURATION 
izak      =         p4                            ;ZAK CHANNEL 
ispacx    =         p5                            ;SPATIALIZATION: LEFT-RIGHT 
ispacz    =         p6                            ;SPATIALIZATION: FORE-BACK 
ispacy    =         p7                            ;SPATIALIZATION: UP-DOWN 
ispatz    =         p8                            ;SPATIAL TRANSITION TICKS 
ichor     =         p9                            ;CHORUS = 1, OFF = 0 
; ***** START INSTRUMENT TIMBRE ****

; ...............................................
; I-TIME (PREMIERE) INITIALIZATION
; ...............................................
          kgoto     zakin
          tigoto    tied
idx       =         0                             ;TRANSITION SETTINGS
kiters    init      0                             ;SPATIALIZATION CONTROL
iispacx   =         ispacx
kspacx    init      iispacx
iichor    =         ichor                         ;CHORUS CONTROL
kchor     init      ichor
irate     =         0.5                           ;CHORUS SETTINGS
idepth    =         0.002
imix      =         1
ideloff   =         0.025
iphase    =         0
          igoto     zakin

; ...............................................
; TI-TIME (TIED-NOTE) INITIALIZATION
; ...............................................
tied:
          cggoto    (iispacx == ispacx), tied0    ;PREPARE K-RATE SPATIAL TRANSITION
idx       =         (iispacx - ispacx)/ispatz
iispacx   =         ispacx
kiters    init      ispatz
tied0:
          cggoto    (iichor == ichor), tied1      ;SET K-RATE CHROUS VALUE
iichor    =         ichor
kchor     init      ichor
tied1:
          tigoto    bye

; ...............................................
; READ INPUT SIGNAL FROM ZAK CHANNEL
; ...............................................
zakin:
ain       zar       izak
axt0      =         ain
axt1      =         ain
         

; ...............................................
; STEREO CHORUS
; ...............................................
chorus:
          igoto     chorus0
          ckgoto    (kchor == 0), mix
chorus0:
kamp      linseg    0, .002, 1, 5000 - .004, 1, .002, 0

aosc1     oscil     idepth, irate, 250001, iphase
aosc2     =         aosc1 + ideloff
atemp     delayr    idepth + ideloff
adell     deltapi   aosc2
          delayw    ain
axt0      =         (adell * imix + ain)/2 * kamp

iphase    =         .33
aosc3     oscil     idepth, irate, 250001, iphase
aosc4     =         aosc3 + ideloff
atemp2    delayr    idepth + ideloff
adell2    deltapi   aosc4
          delayw    ain
axt1      =         (adell2 * imix + ain)/2 * kamp

; ...............................................
; OUTPUTS MIXED AND SAMPLES READIED.  CLEAR
; ZAK CHANNELS BEFORE EXITING.
; ...............................................
mix:
          ckgoto    (kiters == 0), mix0
kiters    =         kiters - 1
kspacx    =         kspacx + idx
mix0:
          outs      (1 - kspacx) * axt0, kspacx * axt1
          zacl      izak, izak
bye:
          endin     

</CsInstruments>

<CsScore>
;------------------------------------------------------------------------------------
; COMPUTER-GENERATED CSOUND SCORE FILE
;
; CREATED BY TONESCAPE: WWW.TONALSOFT.COM
;------------------------------------------------------------------------------------


;------------------------------------------------------------------------------------
; F-TABLE GENERATORS REQUIRED BY DEFINED MUSICAL INSTRUMENTS
; INSTRUMENTS AND OTHER ORCHESTRAL-FILE DEVICES.  EACH
; F-TABLE IS UNIQUELY IDENTIFIED BY ITS INSTRUMENT NUMBER
; PLUS ITS UNIQUE INSTRUMENT-RELATIVE NUMBER.
;------------------------------------------------------------------------------------
f  250001 0  8192   10  1 


;------------------------------------------------------------------------------------
; COMPUTER-GENERATED INSTRUMENT COMMANDS IN THE REMAINING
; PARTS OF THIS FILE.  ALL COMMANS IN CHRONOLOGICAL ORDER.
; THERE ARE NO SECTIONS OR OTHER HELPERS FOR HUMAN READERS.
;------------------------------------------------------------------------------------
;  INSTR         START          DUR      ZAK   RELTIME    CENTS       CN TKS    VOLUME    VOL TKS  TECHNIQUES -->
;  *****         *****         ******    ***   *******   ********     ******    *******   *******  **************
i  50.1         0.0000        -0.4210    0     0.0800    -2104.1445   2500      0.5525    2500      1     2     450       
i  50.1         0.4210         0.0000    0     0.0800    -2104.1445   2500      0.5525    2500      1     2     450       
i  50.2         0.5250        -0.3890    0     0.0800    -1907.4033   2500      0.4225    2500      1     2     450       
i  50.2         0.9140         0.0000    0     0.0800    -1907.4033   2500      0.4225    2500      1     2     450       
i  50.3         1.0000        -0.4210    0     0.0800    -1710.6621   2500      0.4550    2500      1     2     450       
i  50.3         1.4210         0.0000    0     0.0800    -1710.6621   2500      0.4550    2500      1     2     450       
i  50.4         1.5250        -0.3890    0     0.0800    -1602.5151   2500      0.4225    2500      1     2     450       
i  50.4         1.9140         0.0000    0     0.0800    -1602.5151   2500      0.4225    2500      1     2     450       
i  50.5         2.0000        -0.4210    0     0.0800    -1405.7739   2500      0.5525    2500      1     2     450       
i  50.5         2.4210         0.0000    0     0.0800    -1405.7739   2500      0.5525    2500      1     2     450       
i  50.6         2.5250        -0.3890    0     0.0800    -1209.0327   2500      0.4225    2500      1     2     450       
i  50.6         2.9140         0.0000    0     0.0800    -1209.0327   2500      0.4225    2500      1     2     450       
i  50.7         3.0000        -0.4210    0     0.0800    -1012.2915   2500      0.4550    2500      1     2     450       
i  50.7         3.4210         0.0000    0     0.0800    -1012.2915   2500      0.4550    2500      1     2     450       
i  50.8         3.5250        -0.3890    0     0.0800    -904.1445    2500      0.4225    2500      1     2     450       
i  50.8         3.9140         0.0000    0     0.0800    -904.1445    2500      0.4225    2500      1     2     450       


;------------------------------------------------------------------------------------
; I-STATEMENTS FOR STARTING THE MIXER INSTRUMENTS.
; EACH PART-INSTANCE HAS ITS OWN MIXER. ALL OTHER MIXER
;------------------------------------------------------------------------------------
;  INSTR       START         DUR       ZAK    SPACEX   SPACEZ   SPACEY   SPAT TKS  CH
;  *****       *****         ***       ***    ******   ******   ******   ********  **
i  25000.1      0.0000        -1         0     0.5000   0.5000   0.5000   1500      0   

</CsScore>

</CsoundSynthesizer>
