(setf meter-struct '(
                         (37 10 8)
                            )) 
 
 
 
 
(setf tempo-struct '(
                        (0 0 0  116 1/4)
                          )) 
 
 
 
 
(setf score '(
         (p-struct (ed 17))


;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;
;
;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;

;msr. 0
;		  16th's  etc.
         (PAN 54)
         (1  0 0 0        note  0 0 0.43  9 4   101)
         (PAN 54)
         (2  0 0 0.5      note  0 1 0.4  9 4   105)
         (PAN 54)
         (1  0 1 0.5      note  0 1 0.9  9 4   103)

         (PAN 54)
         (2  0 2 0        note  0 3 .42   9 4   107)
         (PAN 54)
         (1  0 3 .5       note  0 3 .9   9 4   105)

         (PAN 54)
         (2  0 4 0        note  0 4 .42   9 4   106)
         (PAN 54)
         (1  0 4 .5       note  0 4 .91   9 4   105)

         (PAN 54)
         (2  0 6 0        note  0 6 .38   9 4   105)
         (PAN 54)
         (1  0 6 .5       note  0 6 .9   9 4   103)
         (PAN 54)
         (2  0 7 0        note  0 7 .42   9 4   102)
         (PAN 54)
         (1  0 7 .5       note  0 7 .91   9 4   104)

         (PAN 54)
         (2  0 8 0        note  0 9 .8   9 4   100)
;
;                      lower "octave"
         (PAN 54)
         (3  0 0 0        note  0 0 0.4   9 5   101)
         (PAN 54)
         (4  0 0 0.5      note  0 1 0.42  9 5   105)
         (PAN 54)
         (3  0 1 0.5      note  0 1 0.91  9 5   103)

         (PAN 54)
         (4  0 2 0        note  0 3 .4    9 5   107)
         (PAN 54)
         (3  0 3 .5       note  0 3 .9    9 5   105)

         (PAN 54)
         (4  0 4 0        note  0 4 .43   9 5   106)
         (PAN 54)
         (3  0 4 .5       note  0 4 .85   9 5   109)

         (PAN 54)
         (4  0 6 0        note  0 6 .43   9 5   105)
         (PAN 54)
         (3  0 6 .5       note  0 6 .91   9 5   103)
         (PAN 54)
         (4  0 7 0        note  0 7 .394  9 5   102)
         (PAN 54)
         (3  0 7 .5       note  0 7 .91   9 5   104)

         (PAN 54)
         (4  0 8 0        note  0 9 .8   9 5   100)



;
;			  a  a  db   viols
         (PAN 10) (HAIRPIN 10 27 20)  (VIBRATO 20 8)
         (6  0 0 0         note 0 6 .9     8 13   108)
         (PAN 10) (HAIRPIN 10 21 20)  (VIBRATO 20 8)
         (7  0 6 0         note 0 8 .933   7 13   108)
         (PAN 10) (HAIRPIN 10 29 20)  (VIBRATO 20 8)
         (8  0 8 .333      note 1 0 .3     8 1   110)


; 				 bells
         (PAN 54) 
         (12  0 0 0        note 1 0 .1     7 5   100)

;
;  msr 1
         (PAN 98)
         (1  1 0 0.01      note  1 0 .66   9 0   106)
         (PAN 10)
         (2  1 0 0         note  1 0 .68   8 5   109)
         (PAN 54)
         (3  1 0 0.07      note  1 0 .665  7 5   110)



         (PAN 98)
         (12  1 3 .29      note  2 0 0     9 5   95)
         (PAN 54)
         (13  1 3 .33      note  2 0 0     8 15  93)
         (PAN 10)
         (14  1 3 .36      note  2 0 0     8 5   91)


         (PAN 10)
         (4   1 6 .666     note 1 7 .3     7 5   107)




;   msr 2
         (PAN 10)(HAIRPIN 15 10 15)
         (5  2 3 .333      note  2 9 0   9 5     108)
         (PAN 10)(HAIRPIN 15 9 14)  (VIBRATO 20 8)
         (1  2 3 .33       note  2 9 0   9 2     105)
         (PAN 54)(HAIRPIN 12 9 16)
         (2  2 3 .32       note  2 9 0   8 15    107)
         (PAN 98)(HAIRPIN 13 8 15)  (VIBRATO 20 8)
         (3  2 3 .39       note  2 9 0   8 9     112)


         (PAN 98) (FP)
         (12  2 6 .666     note  2 9 0   9 9     110)


         (PAN 10) 
         (13  2 9 .444     note  4 3 .33   9 6   109)
         (PAN 54) 
         (14  2 9 .444     note  4 3 .33   8 16  108)
         (PAN 98) (TREMOLO 50 12)
         (15  2 9 .444     note  4 3 .33   8 6   107)



;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;



;  msr 4
         (PAN 10)(VIBRATO 15 10)
         (1  4 5 0        note 4 6 .7   9 6   75)
         (PAN 10)(VIBRATO 15 10)(TREMOLO 23 9)
         (2  4 5 0        note 4 6 .7   9 3   70)
         (PAN 54)(TREMOLO 23 9)
         (3  4 5 0        note 4 6 .7   8 16  78)
         (PAN 98)(VIBRATO 15 10)(TREMOLO 23 9)
         (4  4 5 0        note 4 6 .7   8 10  73)

;
;                       5.0   5.8333335   
;                       6.666667   7.5000005   8.333334   9.166667
;

         (PAN 10) (HAIRPIN 7 3 7) (VIBRATO 20 8)
         (6   4 6 .69     note  5 2 .7   9 7   95)
         (PAN 54) (HAIRPIN 7 3 8)  (VIBRATO 20 8)
         (7   4 6 .63     note  5 2 .7   9 0   93)
         (PAN 98)(HAIRPIN 8 2 9)
         (8   4 6 .666    note  5 2 .7   8 7   97)
         (PAN 54)(HAIRPIN 9 2 7)  
         (9   4 6 .666    note  5 2 .7   8 0   91)
         (PAN 10)(HAIRPIN 7 2 6) (VIBRATO 15 8)
         (11  4 6 .58     note  5 2 .7   7 7   94)




; msr 5
         (PAN 10)  (TREMOLO 15 8)
         (2  5 2 .5      note   5 3 .9    9 7   70)
         (PAN 54)  (VIBRATO 20 8) (TREMOLO 15 8)
         (3  5 2 .5      note   5 3 .9   9 0   72)
         (PAN 98) (VIBRATO 20 8)
         (4  5 2 .5      note   5 3 .8   8 7   72)
         (PAN 54) (VIBRATO 20 8) (TREMOLO 15 8)
         (5  5 2 .5      note   5 3 .8   8 0   77)
         (PAN 10)   (TREMOLO 15 8)
         (1  5 2 .5      note   5 3 .8   7 7   73)

;                   2.5  
;                   3.75   5.0  
;                   6.25   7.5  
;                   8.75
;
;

         (PAN 98)
         (16  5 3 .7        note  5 6 .4   9 7   74)
         (PAN 54)     (TREMOLO 15 8)
         (12  5 3 .78       note  5 6 .36  9 0   73)
         (PAN 10) (VIBRATO 20 8) 
         (13  5 3 .72       note  5 6 .43  8 7   72)
         (PAN 54) (VIBRATO 20 8)
         (14  5 3 .75       note  5 6 .34  8 0   77)
         (PAN 98)    (TREMOLO 15 8)
         (15  5 3 .74       note  5 6 .4   7 7   78)



         (PAN 10)
         (1  5 6 .25       note   5 8 .75  9 7   80)
         (PAN 54)  (VIBRATO 20 8)  (TREMOLO 15 8)
         (2  5 6 .22       note   5 8 .8   9 0   77)
         (PAN 98)   (TREMOLO 15 8)
         (3  5 6 .28       note   5 8 .78  8 7   82)
         (PAN 54)  (VIBRATO 20 8)
         (4  5 6 .2        note   5 8 .75  8 0   78)
         (PAN 10)   (TREMOLO 15 8)
         (5  5 6 .21       note   5 8 .7   7 7   80)



         (PAN 54) (HAIRPIN 8 3 9)  (VIBRATO 20 8)
         (6  5 8 .74       note   6 3 .723  9 0  97)
         (PAN 98) (HAIRPIN 9 3 11)
         (7  5 8 .73       note   6 3 .76  8 7   96)
         (PAN 54) (HAIRPIN 7 2 7)  (VIBRATO 20 8)
         (8  5 8 .77       note   6 3 .74  8 0   95)
         (PAN 10) (HAIRPIN 6 2 7)
         (9  5 8 .75       note   6 3 .79  7 7   98)
         (PAN 54) (HAIRPIN 7 2 7)  (VIBRATO 20 8)
         (11 5 8 .74       note   6 3 .7  7 0    94)



;
; msr 6
;
         (PAN 54)
         (12  6 3 .735    note  6 5 .1   9 0   84)
         (PAN 10)
         (13  6 3 .75     note  6 5 .1   8 7   85)
         (PAN 54)
         (14  6 3 .79     note  6 5 .1   8 0   87)
         (PAN 98)
         (15  6 3 .75     note  6 5 .1   7 7   88)
         (PAN 54)
         (16  6 3 .7      note  6 5 .1   7 0   87)

;
;                       3.75   5.0   6.25    8.75
;


         (PAN 54)  (VIBRATO 20 8)
         (1  6 5 0        note  6 6 .34   9 0   90)
         (PAN 98)    (TREMOLO 15 8)
         (2  6 5 0        note  6 6 .27   8 7   91)
         (PAN 54)  (VIBRATO 20 8) (TREMOLO 15 8)
         (3  6 5 0        note  6 6 .28   8 0   90)
         (PAN 10)  (VIBRATO 20 8)
         (4  6 5 0        note  6 6 .31   7 7   92)
         (PAN 54)   (TREMOLO 15 8)
         (5  6 5 0        note  6 6 .3    7 0   90)



         (PAN 54)
         (12  6 6 .26     note  6 8 .79   9 0   87)
         (PAN 98)
         (13  6 6 .29     note  6 8 .69   8 7   90)
         (PAN 54)
         (14  6 6 .25     note  6 8 .78   8 0   89)
         (PAN 10)
         (15  6 6 .25     note  6 8 .63   7 7   89)
         (PAN 54)
         (16  6 6 .22     note  6 8 .7    7 0   86)




         (PAN 54) (HAIRPIN 6 3 9)  (VIBRATO 20 8)
         (6  6 8 .73      note  7 5 0      9 0   95)
         (PAN 10)(HAIRPIN 4 3 7)
         (7  6 8 .77      note  7 0 .933   8 7   93)
         (PAN 54)(HAIRPIN 8 3 8)  (VIBRATO 20 8)
         (8  6 8 .75      note  7 5 0      8 0   94)
         (PAN 98)(HAIRPIN 7 3 10)  (VIBRATO 20 8)
         (9  6 8 .79      note  7 0 .913   7 7   93)
         (PAN 54)(HAIRPIN 6 3 11)
         (11 6 8 .7       note  7 5 0      7 0   94)


; msr 7

;                        0.8333333   1.6666666   2.5   3.3333333   
;                        4.1666665   
;                        5.0   5.8333335   6.666667   
;                        7.5000005   8.333334   9.166667

         (PAN 98)  
         (12  7 0 .833        note 7 5 0   8 7   98)
         (PAN 10)
         (13  7 0 .861        note 7 5 0   7 7   99)


         (PAN 98)
         (1  7 4 .1666        note 7 5 .1  8 11  77)


         (PAN 98)   (VIBRATO 20 8)
         (2  7 5 0        note   7 7 0     9 11  65)
         (PAN 10)   (TREMOLO 15 8)
         (3  7 5 0        note   8 4 .1    8 7   66)
         (PAN 54)   (VIBRATO 20 8)
         (4  7 5 0        note   8 4 .1    8 0   64)
         (PAN 10)   (VIBRATO 15 8)  (TREMOLO 15 8)
         (5  7 5 0        note   7 7 .6    7 7   65)


;              careful with channel 2 here:
;              careful with channel 2 here:
;              careful with channel 2 here:
;              careful with channel 2 here:
         (PAN 10)   (VIBRATO 20 8)
         (1  7 7 .461      note  8 4 .2    8 4   63)
         (PAN 10) (VIBRATO 15 8)    (TREMOLO 15 8)
         (2  7 7 .5        note  8 4 .1    7 11  62)





;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;


;  msr 8
         (PAN 10)  (TREMOLO 15 8)
         (12   8 4 .1     note   8 6 0     8 8     79)
         (PAN 54)
         (13   8 3 .95    note   8 6 0     8 1     75)
         (PAN 54)  (VIBRATO 15 10)
         (14   8 4 .06    note   8 6 .1     8 1     78)
         (PAN 98)  (VIBRATO 15 9)
         (15   8 4 .02    note   8 5 .95     7 8     75)


         (PAN 10) (VIBRATO 15 10)
         (1   8 8 .1      note   9 0 .1     8 8     73)
         (PAN 54) (VIBRATO 15 10)
         (2   8 8 0       note   9 0 0     8 1     71)
         (PAN 54)  (TREMOLO 15 8)
         (3   8 7 .95     note   9 0 0     8 1     75)
         (PAN 98)(VIBRATO 15 10)(TREMOLO 15 8)
         (4   8 8 0       note   8 9 .95     7 8     74)



; msr 9
         (PAN 54)
         (1   9 4 0     note     9  7 0      8 6     50)
         (PAN 54) (VIBRATO 40 9)
         (6   9 6 0     note     9  8 .1     8 6     54)
         (PAN 54)
         (2   9 8 0     note     10 0 .1     8 6     55)


; msr 10
         (PAN 54)  (HAIRPIN 10 7 7)  (VIBRATO 25 10)
         (7    10 0 0   note     10 5 0      8 6     57)

         (PAN 54)
         (3   10 4 0    note     10 6 .14    8 6     52)
         (PAN 54)
         (8   10 6 0    note     10 9 0      8 6     50)
         (PAN 54)
         (4   10 8 0    note     11 0 .3     8 6     55)



; msr 11
         (PAN 54) (FP)
         (12   11 0 0    note    11 6 0    8 0     120)
         (PAN 54) (FP)
         (13   11 5 0    note    12 1 0    8 0     119)

;                  0.0   
;                  0.5555556   1.1111112  
;                  1.6666667   2.2222223   2.777778 
;                  3.3333335   3.888889   4.4444447   
;                  5.0   5.5555553 
;                  6.1111107 
;                  6.666666  
;                  7.2222214   7.7777767   
;                  8.333332   8.888887   9.444443


         (PAN 98)
         (14   11 0 0       note  11 0 .8     7 12     109)
         (PAN 98)
         (15   11 0 .555    note  11 1 .93    8 12     100)
         (PAN 98)
         (16   11 1 .666    note  11 4 0      7 12     105)
         (PAN 98)
         (14   11 3 .333    note  11 6 0      8 12     103)
         (PAN 98)
         (15   11 5 0       note  11 6 .8     7 12     107)
         (PAN 98)
         (16   11 6 .111    note  11 6 .9     8 12     110)
         (PAN 98)
         (14   11 6 .666    note  11 8 0      7 12     102)
         (PAN 98)
         (15   11 7 .222    note  11 9 0      8 12     106)
         (PAN 98)
         (16   11 8 .333    note  12 1 0      7 12     105)





;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;


; msr 12
         (PAN 54)  (HAIRPIN 10 7 6)
         (6    12 1 .666      note   12 7 0     8 3     94)
         (PAN 54)  (FP)
         (1    12 5 0      note      13 1 .3    8 3     77)



;  msr 13
         (PAN 54)
         (12    13 0 0         note   13 1 .711     8 3     57)
         (PAN 54)
         (13    13 1 .111      note   13 3 .222     8 3     55)
         (PAN 54)
         (14    13 2 .222      note   13 4 .333     8 3     53)
         (PAN 54)  (TREMOLO 30 9)  (VIBRATO 30 9)
         (15    13 3 .333      note   13 7 .666     8 3     51)

         (PAN 54)
         (16    13 6 .666      note   13 8 .288     8 3     55)
         (PAN 54)
         (12    13 7 .777      note   14 1 .27      8 3     52)


; msr 14
         (PAN 10)  (VIBRATO 17 6) (FP)
         (1    14 8 0      note   15 0 .5      8 14     123)
         (PAN 54)  (FP)(VIBRATO 17 6)
         (1    14 8 0      note   15 0 .37     8 14     121)
         (PAN 10)  (VIBRATO 17 6) (FP)
         (2    14 8 0      note   15 0 .4      8 8      124)



; msr 15
         (PAN 10)(VIBRATO 17 6) (TREMOLO 18 8)
         (3    15 4 0      note  15 5 .85     8 11     105)

         (PAN 10) 
         (4    15 6 0      note  15 6 .41       8 11     110)
         (PAN 10)
         (5    15 6 .5     note  15 6 .93      8 11     100)

         (PAN 10)
         (1    15 7 .5     note  15 7 .92      8 11     100)
         (PAN 10)
         (2    15 8 0      note  15 8 .48      8 11     110)



;
;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;



;  msr 16
         (PAN 98)
         (12    16 0 0      note   16 4 0      9 1      121)
         (PAN 98) 
         (13    16 0 0      note   16 4 0      8 1      120)


         (PAN 98)
         (1    16 6 .5      note   16 6 .9      9 1      109)
         (PAN 98)
         (2    16 6 .5      note   16 6 .9      8 1      110)
         (PAN 98)
         (3    16 7 0       note   16 7 .4      9 1      108)
         (PAN 98)
         (4    16 7 0       note   16 7 .4      8 1      109)
         (PAN 98)
         (5    16 7 .5      note   16 7 .9      9 1      109)
         (PAN 98)
         (1    16 7 .5      note   16 7 .9      8 1      108)


         (PAN 10)  (TREMOLO 16 8)(VIBRATO 15 10)
         (2    16 8 0      note    17 0 0       9 0      109)
         (PAN 54)  (VIBRATO 15 10)
         (3    16 8 0      note    17 0 .1      8 10     107)





;                  5.0   5.8333335   6.666667   7.5000005   
;                   end      8.333334   9.166667
; msr 17
         (PAN 10) (HAIRPIN 7 9 6)
         (6    17 5 0      note   17 9 .433      7 0      92)
         (PAN 54) (HAIRPIN 7 11 6) (VIBRATO 15 8)
         (7    17 5 0      note   17 9 .533      7 10     90)
         (PAN 10)(HAIRPIN  6 7 6)
         (8    17 5 0      note   17 9 .433      8 0      89)
         (PAN 54) (HAIRPIN 7 10 6) (VIBRATO 15 8)
         (9    17 5 0      note   17 9 .333      8 10     91)
         (PAN 10)(HAIRPIN  5 6 6) (VIBRATO 15 8)
         (11   17 5 0      note   17 9 .433      9 0      93)



; msr 18
         (PAN 10) (VIBRATO 15 8) (HAIRPIN 7 12 6)
         (6    18 0 0      note   18 5 .54     7 0      103)
         (PAN 54)                (HAIRPIN 7 10 6)
         (7    18 0 0      note   18 5 .7      7 10     100)
         (PAN 10) (VIBRATO 15 8) (HAIRPIN 5 9 6)
         (8    18 0 0      note   18 5 .8      8 0      101)
         (PAN 54)                (HAIRPIN 7 10 6)
         (9    18 0 0      note   18 5 .7      8 10     105)
         (PAN 10)  (VIBRATO 15 8)(HAIRPIN 6 8 5)
         (11   18 0 0      note   18 5 .6      9 0      106)


         (PAN 98)  (VIBRATO 15 8) (FP)
         (1    18 5 .714286    note   19 0 .1   8 15     117)



; msr 19
         (PAN 98) 
         (12    19 0 0      note   19 4 0      8 15     116)
         (PAN 10) 
         (13    19 0 0      note   19 4 0      8 12     115)
         (PAN 10) 
         (14    19 0 0      note   19 4 0      8 11     113)


         (PAN 98) 
         (15    19 4 .285714      note   20 0 0      8 15     125)
         (PAN 10) 
         (16    19 4 .285714      note   20 0 0      8 12     124)
         (PAN 10) 
         (12    19 4 .285714      note   20 0 0      8 11     125)
         (PAN 54) 
         (13    19 4 .285714      note   20 0 0      8 10     126)


;
;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;


;  msr 20
         (PAN 98)  (HAIRPIN 3 7 3)
         (6     20  2 .5       note   21  0 0      8 4     96)
         (PAN 10)  (HAIRPIN 1 4 1)
         (7     20  2 .5       note   20  6 .45    8 11    94)
         (PAN 98)  (HAIRPIN 1 3 1)
         (8     20  2 .5       note   20  6 .45    7 16    92)

         (PAN 10)  (HAIRPIN 1 6 1)
         (9     20  6 .25      note   20  8 .75    8 10    95)
         (PAN 98)  (HAIRPIN 1 4 1)
         (11     20  6 .25     note   20  8 .75    7 15    94)

         (PAN 10) (HAIRPIN 1 4 1)
         (7     20  8 .75      note   21  1 .2     8 9     90)
         (PAN 98) (HAIRPIN 1 5 1)
         (8     20  8 .75      note   21  1 .2     7 14    93)


; 0.0  
; 0.41666666 
; 0.8333333  
; 1.6666666  
; 2.5   3.3333333   
; 4.1666665  
; 5.0   
; 5.8333335  6.666667   
; 7.5000005  8.333334   9.166667


; msr 21
         (PAN 98)
         (12    21  0 0         note   21  0 .41666    8 14    52)
         (PAN 10)
         (13    21  0 .41666    note   21  1 .666    9 9     52)
         (PAN 98)
         (14    21  0 .8333     note   21  1 .666    9 14    53)

         (PAN 98)
         (15    21  1 .666      note   21  2 .5     9 14    54)
         (PAN 10)
         (16    21  1 .666      note   21  2 .5     9 9     52)

         (PAN 98)
         (12    21  2 .5        note   21  4 .166    9 14    51)
         (PAN 10)
         (13    21  2 .5        note   21  4 .166    9 9     53)


         (PAN 98)
         (14    21  4 .166      note   21  5  0     9 14    54)
         (PAN 10)
         (15    21  4 .166      note   21  5  0     9 9     55)

         (PAN 98)
         (16    21  5  0        note   21  5 .8333    9 14    52)
         (PAN 10)
         (12    21  5  0        note   21  5 .8333    9 9     53)

         (PAN 98)
         (13    21  5 .8333     note   21  7 .3    9 14    54)
         (PAN 10)
         (14    21  5 .8333     note   21  7 .5    9 9     52)


         (PAN 54)  (TREMOLO 30 5)   
         (15    21  6 .666      note   21 9 .9       9 13    90)
         (PAN 98)  (TREMOLO 30 5) 
         (16    21  6 .666      note   22 0 0       8 13    91)

;                   watch channel 13 carefully. . . .
         (PAN 98)
         (12    21  7 .5        note   22 0 .2    9 14    61)
         (PAN 10)
         (13    21  7 .5        note   22 0 .2    9 9     62)





;  msr 22
;                   and  WATCH 14 and 15
         (PAN 98)
         (14     22  0 0       note   22  4 .3    9 14    57)
         (PAN 10)
         (15     22  0 .1      note   22  4 .2    9 9     55)


         (PAN 98)
         (16     22  4 0      note    22  6 .2   9 14    54)
         (PAN 10)
         (12     22  4 .03    note    22  6 .1   9 9     53)


         (PAN 54) (HAIRPIN 3 10 8)   (VIBRATO 15 8)
         (6      22  5 .5      note   23 1 .1    9 9     50)
         (PAN 10) (HAIRPIN 3 10 7)  (VIBRATO 15 8)
         (7      22  5 .5      note   23 1 .2    8 9     52)
         (PAN 54) (HAIRPIN 2 9 8)
         (8      22  5 .5      note   23 1 .1    7 9     51)


         (PAN 98)
         (13     22  6 0      note    22  8 .2   9 14    53)
         (PAN 10)
         (14     22  6 0      note    22  8 .1   9 9     52)


         (PAN 98)
         (15     22  8 0      note    23 0 .2   9 14    50)
         (PAN 10)
         (16     22  8 0      note    23 0 .1   9 9     51)


; msr 23
         (PAN 54) (HAIRPIN 2 9 7)   (VIBRATO 15 8)
         (1     23  0 0      note   23  7 .1    9 9     56)
         (PAN 10) (HAIRPIN 2 9 8)   (VIBRATO 15 8)
         (2     23  0 0      note   23  9 .2    8 9     57)
         (PAN 54) (HAIRPIN 1 7 6)
         (3     23  0 0      note   23  7 .3    7 9     56)


         (PAN 54) (HAIRPIN 3 10 8)   (VIBRATO 15 8)
         (6     23  5 0      note   24 2 .1    9 9     59)
         (PAN 10) (HAIRPIN 2 10 7)   (VIBRATO 15 8)
         (7     23  5 0      note   24 2 .2    8 9     60)
         (PAN 54) (HAIRPIN 3 9 9)  (VIBRATO 15 8)
         (8     23  5 0      note   24 2 .1    7 9     59)


         (PAN 98)
         (12    23  5 .5     note   23 9 .5    7 13    64)


         (PAN 54)
         (13    23  9 .5     note   24 3 0    8 13    63)



;
;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;
;
;  msr 24
;
         (PAN 10)  (HAIRPIN 3 7 3)
         (4     24  0 0      note   24 6 .2     9 9     67)
         (PAN 54)  (HAIRPIN 3 8 4)
         (5     24  0 0      note   24 6 .2     8 9     64)
         (PAN 10)  (HAIRPIN 3 8 3)
         (1     24  0 0      note   24 6 .2     7 9     65)


         (PAN 98)
         (14    24  3 0      note   24 8 .2    9 13    90)


         (PAN 54)  (HAIRPIN 4 4 4)
         (6     24  5 0      note   25 2 .1    9 9     72)
         (PAN 10)  (HAIRPIN 4 7 4)
         (7     24  5 0      note   25 2 .2    8 9     73)
         (PAN 54)  (HAIRPIN 4 5 3)
         (8     24  5 0      note   25 2 .15    7 9     74)


; msr 25
         (PAN 10)
         (12    25  0 .04    note   25 1 .8    9 9     83)
         (PAN 54)
         (13    25  0 0      note   25 1 .8    8 9     82)
         (PAN 10)
         (14    24  9 .95    note   25 1 .8    7 9     84)


         (PAN 54)
         (15    25  1 .6     note   25 5 .2    9 9     89)
         (PAN 10)
         (16    25  1 .666   note   25 5 .1    8 9     88)
         (PAN 54)
         (12    25  1 .716   note   25 5 .15    7 9     89)


         (PAN 10)
         (13    25  5 0        note   26 0 .1    9 9     94)
         (PAN 54)
         (14    25  5 .04      note   26 0 .2    8 9     93)
         (PAN 10)
         (15    25  4 .97      note   26 0 .1    7 9     96)



; msr 26
         (PAN 54) (TREMOLO 12 5)
         (16    26  0 0        note   26 2 .3    9 9     103)
         (PAN 10) (TREMOLO 17 4)
         (12    26  0 .03      note   26 2 .1    8 9     102)
         (PAN 54)
         (13    25  9 .97      note   26 2 .4    7 9     104)


         (PAN 10)
         (14    26  2 .122      note  26 3 .5     9 9     105)
         (PAN 54)  (TREMOLO 15 7)
         (15    26  2 .222      note  26 3 .4     8 9     103)
         (PAN 10)  (TREMOLO 15 6)
         (16    26  2 .232      note  26 3 .52    7 9     104)

         (PAN 54) (TREMOLO 12 5)
         (12    26  3 .303      note  26 6 .8     9 9     105)
         (PAN 10)
         (13    26  3 .353      note  26 6 .81    8 9     107)
         (PAN 54) (TREMOLO 15 5)
         (14    26  3 .333      note  26 6 .74    7 9     106)


         (PAN 10)
         (15    26  6 .666      note  27 1 .4     9 9     105)
         (PAN 54) (TREMOLO 17 6)
         (16    26  6 .706      note  27 1 .37    8 9     107)
         (PAN 10) (TREMOLO 14 5)
         (12    26  6 .646      note  27 1 .35    7 9     106)


; msr 27
         (PAN 54) (TREMOLO 15 5)
         (13    27  1 .101      note  27 3 .5     9 9     107)
         (PAN 10) (TREMOLO 17 4)
         (14    27  1 .111      note  27 3 .6     8 9     105)
         (PAN 54)
         (15    27  1 .091      note  27 3 .4     7 9     106)


         (PAN 10)
         (16    27  3 .333      note  27 6 .7     9 9     108)
         (PAN 54) (TREMOLO 15 5)
         (12    27  3 .323      note  27 6 .9     8 9     109)
         (PAN 10) (TREMOLO 12 7)
         (13    27  3 .343      note  27 6 .8     7 9     110)


         (PAN 54) (TREMOLO 14 5)
         (14    27  6 .666      note  28 0 .1     9 9     116)
         (PAN 10) (TREMOLO 15 6)
         (15    27  6 .666      note  28 0 .3     8 9     114)
         (PAN 54)
         (16    27  6 .666      note  28 0 .1     7 9     113)







;
;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.;    mufff up times for vibes/bells
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;
;
;  msr 28
         (PAN 54)(TREMOLO 15 6)
         (12     28 0 .02       note  28 2 .2    9 9     120)
         (PAN 98)
         (13     28 0 .06       note  28 2 .2    9 2     122)
         (PAN 10)(TREMOLO 15 6)
         (14     28 0 .01       note  28 2 .2    8 9     121)
         (PAN 54)(TREMOLO 15 6)
         (15     27 9 .95       note  28 2 .2    7 9     123)
         (PAN 98)
         (16     28 0 0       note  28 2 .2    7 2     119)


         (PAN 54)(TREMOLO 15 6)
         (13     28 2 0       note  28 4 .2    9 9     119)
         (PAN 98)(TREMOLO 15 6)
         (14     28 1 .95       note  28 4 .2    9 2     120)
         (PAN 10)
         (15     28 1 .97       note  28 4 .2    8 9     121)
         (PAN 54)(TREMOLO 15 6)
         (16     28 2 .03       note  28 4 .2    7 9     119)
         (PAN 98)
         (12     28 2 .08       note  28 4 .2    7 2     123)


         (PAN 54)
         (14     28 4 0       note  28 8 .2    9 9     122)
         (PAN 98)(TREMOLO 15 6)
         (15     28 3 .96     note  28 8 .2    9 2     121)
         (PAN 10)
         (16     28 3 .93     note  28 8 .2    8 9     120)
         (PAN 54)(TREMOLO 15 6)
         (12     28 4 .05     note  28 8 .2    7 9     123)
         (PAN 98)(TREMOLO 15 6)
         (13     28 4 .07     note  28 8 .2    7 2     119)


         (PAN 54)
         (15     28 8 .06      note  29 0 .1    9 0     118)
         (PAN 98)(TREMOLO 15 6)
         (16     28 8 .1       note  29 0 .1    9 2     122)
         (PAN 10)(TREMOLO 15 6)
         (12     28 8 0.04     note  29 0 .1    8 9     123)
         (PAN 54)(TREMOLO 15 6)
         (13     28 8 0        note  29 0 .1    7 9     119)
         (PAN 98)
         (14     28 7 .95      note  29 0 .1    7 2     120)



; msr 29
         (PAN 54)(TREMOLO 15 6)
         (12     29 0 0       note  29 2 .95714    9 9     112)
         (PAN 98)
         (13     29 0 .06     note  29 2 .95714    9 2     110)


         (PAN 54)(TREMOLO 15 6)
         (14     29 1 .428572   note  29 2 .95714    8 12    118)


         (PAN 54) (VIBRATO 20 7)
         (1     29 0 0       note  29 2 .95714    9 9     112)
         (PAN 98)(VIBRATO 18 8)
         (2     29 0 .06     note  29 2 .95714    9 2     110)


         (PAN 54)(TREMOLO 15 6) (VIBRATO 20 9)
         (3     29 1 .428572   note  29 2 .95714    8 12    118)



;
;
;
;   bells/vibes
         (PAN 98)(TREMOLO 15 6)  (VIBRATO 15 6)
         (15     29 2 .85714    note   29 8 .471   9 2     110)
         (PAN 10)  (VIBRATO 15 5)
         (16     29 2 .87714    note   29 8 .471   7 9     111)


;  recorders
         (PAN 10)  (TREMOLO 15 7) (VIBRATO 20 9)
         (1     29 2 .85714     note  29 8 .641    9 9     118)
         (PAN 10)  (VIBRATO 22 6)
         (2     29 2 .86714     note  29 8 .671    8 9     119)
         (PAN 98)   (VIBRATO 21 9)
         (3     29 2 .84714     note  29 8 .651    7 2     119)



;
;   viols
         (PAN 98)(TREMOLO 15 6)  (VIBRATO 20 7)
         (6     29 2 .85714    note   29 8 .671   9 2     117)
         (PAN 10)  (TREMOLO 15 7) (VIBRATO 19 8)
         (7     29 2 .85714     note  29 8 .641    9 9     118)
         (PAN 98)   (VIBRATO 19 8)
         (8     29 2 .84714     note  29 8 .651    7 2     119)






;  recorders
         (PAN 10)   (VIBRATO 23 8)
         (4     29 8 .5714      note  31 0 .1    9 16    123)
         (PAN 10)   (VIBRATO 24 10)
         (5     29 8 .5714      note  31 0 .2    6 16    121)


         (PAN 10)   (VIBRATO 25 12)
         (1     29 9 .285715    note   31 0 .05   8 15    126)


;  bells
         (PAN 10)   (VIBRATO 23 8)
         (12     29 8 .5714      note  31 0 .1    9 16    100)
         (PAN 10)   (VIBRATO 24 10)
         (13     29 8 .5714      note  31 0 .2    6 16    100)


         (PAN 10)   (VIBRATO 25 12)
         (14     29 9 .285715    note   31 0 .05   8 15    100)










; msr 30
         (PAN 54)   (VIBRATO 30 11)
         (2     30 0 .08       note  31 0 .08    9 8     127)
         (PAN 54)   (VIBRATO 30 14)
         (3     30 0 0         note  31 0 .11    7 8     127)


         (PAN 54)   (VIBRATO 30 11)
         (15     30 0 .08       note  31 0 .08    9 8     100)
         (PAN 54)   (VIBRATO 30 14)
         (16     30 0 0         note  31 0 .11    7 8     100)


; msr 31
         (PAN 54)  
         (4     31 3 .5        note  31 4 .1    9 8     105)


         (PAN 54) (DIMINUENDO-TO 60)  (VIBRATO 20 9)
         (5     31 6 .5        note  32 0 .1    9 8     127)
         (PAN 54) (DIMINUENDO-TO 60)  (VIBRATO 20 9)
         (1     31 6 .56       note  32 0 .2    8 8     127)




;
;   127 fff    120  ff    105  f   90  mf     75 mp   60 p  50 pp  40 ppp
;
;
;     pitch,  loudness, midi-channel,  stereo-pos,  articulation
;       start,  end.;    mufff up times for vibes/bells
;
;   1-5: recorders,  6-9, 11: viols,     12-16:  bells and/or vibes
;
;   1-5: lute,       6-9, 11: xylorimba  12-16: crumbhorns
;
;
; msr 32
         (PAN 98)  (CRESC-FROM 50) (VIBRATO 15 7)
         (6     32 5 0       note  33 6 0    9 2     127)
         (PAN 10)  (CRESC-FROM 50) (VIBRATO 15 7)
         (7     32 5 .04     note  33 6 .1    8 15    127)
         (PAN 54)  (CRESC-FROM 50) (VIBRATO 15 7)
         (8     32 5 .02     note  33 6 .2    8 8     127)
         (PAN 98) (CRESC-FROM 50)  (VIBRATO 15 7)
         (9     32 5 0       note  33 6 0    8 2     127)


;  msr 33
         (PAN 10)
         (1     33 7 0       note  33 7 .3    7 15     74)
         (PAN 15)
         (2     33 7 .5      note  33 7 .9    7 15     76)



         (PAN 98) (VIBRATO 15 7)  (TREMOLO 15 9)
         (3     33 9 .5      note  34 3 0    8 2     96)


; msr 34
         (PAN 54)  (VIBRATO 15 7) (TREMOLO 15 9)
         (4     34 1 0       note  34 6 0   9 11    110)


         (PAN 98)  (VIBRATO 15 7)
         (5     34 6 0       note  34 7 0    8 2     92)


; msr 35
         (PAN 10)   (TREMOLO 17 8)
         (12    35 6 0       note  36 0 .1    8 15    106)
         (PAN 54)  (VIBRATO 15 7)
         (13    35 6 .05     note  36 0 .05    8 7     105)


         (PAN 54)
         (14    35 7 .33     note  36 0 .07    8 2     69)
))
