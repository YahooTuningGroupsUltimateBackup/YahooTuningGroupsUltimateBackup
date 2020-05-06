<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
; Audio out   Audio in
-odac           -iadc    ;;;RT audio I/O
; For Non-realtime ouput leave only the line below:
; -o pluck.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

  sr        =           44100
  kr        =           4410
  ksmps     =           10
  nchnls    =           2

  isin      ftgen       1, 0, 8193, 10, 1

instr 1
        ;; Description of Arguments:
  idur      =           p3                      ; Duration
  iamp      =           p4 * 30000              ; normalised amp (0.0-1.0)
  ifqc      =           440.0 * semitone(p5-69) ; Keynumber (MIDI float)

  kamp      linseg      iamp, p3*0.99, iamp, p3*0.01, 0
  a1        pluck       kamp, ifqc, ifqc, 0, 1
            outs        a1, a1
endin 

</CsInstruments>
<CsScore>

; tempo
t 0 60.0

; simple score example: first a harmonic 7th chord, then the same chord as arpeggio

; ins start dur 	amp (0-1) 	pitch (MIDI float)
i1    0.0   2.0 	0.50394  	60.0
i1    0.0   2.0 	0.50394  	63.863
i1    0.0   2.0 	0.50394  	67.019  
i1    0.0   2.0 	0.50394  	69.688
		
i1    3.0   2.0 	0.50394  	60.0
i1    +   2.0 	0.50394  	63.863
i1    +   2.0 	0.50394  	67.019  
i1    +   2.0 	0.50394  	69.688

</CsScore>
</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 324 204 289 431
CurrentView: io
IOViewEdit: On
Options: -b128 -A -s -m167 -R
</MacOptions>
<MacGUI>
ioView background {32125, 41634, 41120}
ioSlider {8, 7} {20, 98} 0.000000 1.000000 0.367347 amp
ioSlider {34, 6} {239, 22} 100.000000 1000.000000 100.000000 freq
ioGraph {8, 112} {265, 116} table 0.000000 1.000000 
ioListing {8, 234} {266, 158}
ioText {34, 37} {41, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder Amp:
ioText {74, 37} {70, 24} display 0.000000 0.00100 "amp" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder 0.4184
ioText {35, 67} {41, 24} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder Freq:
ioText {75, 67} {69, 24} display 0.000000 0.00100 "freq" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} background noborder 427.6151
ioText {152, 34} {119, 69} label 0.000000 0.00100 "" left "Lucida Grande" 8 {0, 0, 0} {65280, 65280, 65280} nobackground border 
ioText {169, 72} {78, 24} display 0.000000 0.00100 "freqsweep" center "DejaVu Sans" 8 {0, 0, 0} {14080, 31232, 29696} background border 999.6769
ioButton {160, 37} {100, 30} event 1.000000 "Button 1" "Sweep" "/" i1 0 10
</MacGUI>

