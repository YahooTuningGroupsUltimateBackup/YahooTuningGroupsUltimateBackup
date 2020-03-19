(setf meter-struct '(
                         (2 10 8)  (72 2 8)
                            )) 
 
 
 
 
(setf tempo-struct '(
                        (0 0 0  116 1/4)
			(2 0 0  83 1/4)

                          )) 
 
 
 
 
(setf score '(
         (p-struct (ed 29))


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
         (PAN 32)  (DIMINUENDO-TO 30)  (VIBRATO 20 15)
         (12   0 0 .05    note  0 3 0    8 27    105)
         (PAN 32)  (DIMINUENDO-TO 30) (VIBRATO 15 10)
         (13   0 0 .03    note  0 3 0    8 22    100)
         (PAN 76) (DIMINUENDO-TO 30)(VIBRATO 20 10)
         (14   0 0 0      note  0 3 0    8 15    102)
         (PAN 120) (DIMINUENDO-TO 30)(VIBRATO 15 15)
         (15   0 0 .04    note  0 3 0    8 5     103)


         (PAN 32)
         (1   0 3 .5     note   0 4 .6   8 25    60)
         (PAN 76)
         (2   0 4 .5     note   0 6 .2   8 13    63)
         (PAN 120)
         (3   0 6 0      note   0 7 .2   8 3     67)
         (PAN 32)
         (4   0 7 0      note   0 9 .7   7 20    64)
         (PAN 32)
         (5   0 9 .5     note   1 0 .6   8 28    65)


; msr 1
         (PAN 76)
         (6   1 0 .5     note   1 0 .833   8 16    60)
         (PAN 120)
         (7   1 0 .833   note   1 1 .133   8 6     58)
         (PAN 32)
         (8   1 1 .133   note   1 1 .5     8 28    57)

         (PAN 32)
         (1   1 3 0      note   1 4 .3     6 23    65)

         (PAN 120)
         (2   1 4 .5     note   1 5 .24   7 1     75)
         (PAN 76)
         (3   1 5 0      note   1 6 .1    7 11    73)
         (PAN 32)
         (4   1 6 0      note   1 7 .2    7 23    120)
         (PAN 32) (VIBRATO 20 13)
         (12  1 6 0      note   1 7 0     7 23    120)
         (PAN 32)
         (5   1 7 0      note   1 8 .2    7 18    76)
         (PAN 76) (VIBRATO 16 13)
         (13  1 8 0      note   2 0 .04   7 17    64)



; msr 4
         (PAN 120)  (VIBRATO 16 12)
         (14  4 0 .666     note   5 2 0     8 0     106)
         (PAN 32)  (DIMINUENDO-TO 70) (VIBRATO 20 13)
         (15  4 0 .666     note   5 1 .92   8 0     106)


; msr 5
         (PAN 32)
         (16  5 0 0        note   5 1 .566   6 21    118)
         (PAN 76)
         (6   5 1 .666     note   6 0 .06   7 14    95)


;  msr 6
         (PAN 76)
         (1   6 0 0         note  6 0 .3857    7 14    106)
         (PAN 120)
         (2   6 0 .2857     note  6 0 .9571    8 4     96)
         (PAN 32)
         (6   6 0 .8571     note  6 1 .2429    8 26    95)
         (PAN 120)
         (3   6 1 .1429     note  7 0 .12      8 2     94)
         (PAN 32)
         (7   6 1 .1429     note  7 0 .14      8 19    98)
         (PAN 76)
         (4   6 1 .1429     note  7 0 .2       6 12    97)
         (PAN 32)
         (8   6 1 .4286     note  7 0 .2       8 24    95)





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


; msr 7
         (PAN 120) (VIBRATO 20 15)
         (12   7 0 0       note  8 0 0    8 28    75)
         (PAN 120) (VIBRATO 20 15)
         (13   6 1 .95     note  8 0 0    7 28    73)


; msr 9
         (PAN 76) (VIBRATO 20 15)
         (14   9 0 0       note  10 0 0    8 5     104)
         (PAN 120) (VIBRATO 20 15)
         (15   9 0 .03     note  10 0 0    7 23    101)


; msr 10
         (PAN 32) 
         (1   10 0 .666    note  11 0 .1    8 15    112)
         (PAN 76)
         (2   10 0 .61     note  11 0 .2    8 3     114)
         (PAN 32)
         (3   10 0 .7      note  11 0 .15   7 15    115)


; msr 11
         (PAN 120)
         (4   11 0 0       note  11 0 .7   7 23    95)
         (PAN 76)
         (5   11 0 .03     note  11 0 .8   7 6     98)

         (PAN 120)
         (1   11 0 .666    note  11 1 .5   7 26    97)

         (PAN 32)  (VIBRATO 20 13)  (TREMOLO 25 10)
         (2   11 1 .303    note  13 0 .2    8 13    120)
         (PAN 76) (VIBRATO 20 14) (TREMOLO 25 12)
         (3   11 1 .363    note  13 0 .1    8 1     118)
         (PAN 32) (VIBRATO 20 12) (TREMOLO 25 11)
         (4   11 1 .353    note  13 0 .14    7 13     115)
         (PAN 32) (VIBRATO 20 10)  (TREMOLO 25 10)
         (5   10 1 .313    note  13 0 .18    6 13    117)


; msr 13
         (PAN 32) 
         (6   13 0 .8     note   13 1 .4   8 16    95)
         (PAN 32)
         (7   13 0 .78    note   13 1 .4   8 13    98)

         (PAN 120)
         (8   13 1 .2     note   14 0 .2   8 21    97)
         (PAN 32)
         (9   13 1 .25    note   14 0 .1   8 11    96)
         (PAN 120)
         (11  13 1 .16    note   14 0 .17   7 21    98)


; msr 14
         (PAN 120) (VIBRATO 20 10)  (TREMOLO 25 9)
         (1   14 1 0.04   note   16 0 .1       9 0     95)
         (PAN 32) (VIBRATO 20 13)  (TREMOLO 25 10)
         (2   14 1 0      note   15 2 .95      8 17    96)
         (PAN 76) (VIBRATO 20 11)  (TREMOLO 25 11)
         (3   14 1 0.05   note   16 0  .23     8 0     97)
         (PAN 32) (VIBRATO 20 12)  (TREMOLO 25 12)
         (4   14 1 0.03   note   16 0  .18     7 17    96)
         (PAN 120) (VIBRATO 20 9)  (TREMOLO 25 10)
         (5   14 0 .95    note   16 0 .21      7 0     95)
;                 (channel 3 doubled here. . . use only the one articulation)
         (3   14 1 0      note   16 0 .19      6 0     97)



; msr 16
         (PAN 32)
         (2   16 0 0        note  16 0 .6    8 14    95)

         (PAN 120)
         (3   16 0 .353     note  19 0 0    9 0     105)
         (PAN 76)
         (4   16 0 .333     note  19 0 0    9 0     105)
         (PAN 32)
         (5   16 0 .313     note  19 0 0    8 12    108)
;                     crumbhorns doubling:
         (PAN 120)  (HAIRPIN 5 5 6)  (VIBRATO 15 15)
         (13  16 1 .333     note  19 0 0     9 0     95)
         (PAN 32)   (HAIRPIN 5 6 5)  (VIBRATO 19 15)
         (14  16 1 .733     note  19 0 0    8 12    98)



; msr 17
         (PAN 120)
         (6   17 0 0        note  17 0 .333    7 24    120)
         (PAN 120)
         (7   17 0 .333     note  17 1 0       7 19    116)
         (PAN 120)
         (8   17 1 0        note  18 0 .3      8 1     118)




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




; msr 19
         (PAN 76)  (DIMINUENDO-TO 40) (VIBRATO 20 12)
         (15   19 0 .04   note  21 0 .1     9 0     75)
         (PAN 120) (DIMINUENDO-TO 40) (VIBRATO 20 12)
         (16   18 1 .95   note  21 0 0      9 0     77)
         (PAN 32)  (DIMINUENDO-TO 40)(VIBRATO 20 8)
         (12   19 0 0     note  21 0 .2     8 12    84)


         (PAN 120)  (REP-TREM 7)  (DIMINUENDO-TO 70)
         (1   19 0 0     note   20 0 .13    8 1     104)

; msr 20
         (PAN 120)  (REP-TREM 8)
         (2   20 0 0     note   21 0 .11    8 22    100)


; msr 21
         (PAN 32)
         (3   21 0 .8     note  22 0 .1     10 5     105)
;                   crumbhorns:
         (PAN 76)  (VIBRATO 18 10)
         (12  21 0 .8     note  22 0 .12    9 2     75)
         (PAN 76)  (VIBRATO 15 12)
         (13  21 0 .84    note  22 0 .14    9 4     75)


; msr 22
         (PAN 120)
         (4   22 0 0      note  23 0 .1     7 27    98)
         (PAN 76)
         (5   22 0 .4     note  22 1 .2     9 2     94)
         (PAN 120) (VIBRATO 20 13)
         (14  22 0 .8     note  23 0 .1     7 20    96)



; msr 23
         (PAN 120) (REP-TREM 7) (DIMINUENDO-TO 50)
         (6   23 0 0     note   25 0 .22    7 25    105)



; msr 25
         (PAN 120)
         (1   25 1 0     note  26 0 .1      9 16     95)
         (PAN 32)
         (2   25 1 0     note  26 0 .14     9 5      92)


; msr 26
         (PAN 32)
         (3   26 0 0       note  27 0 0     10 3     65)
         (PAN 76)
         (4   26 1 .333    note  27 0 0     9 28     72)


; msr 27
;   upper melody
         (PAN 32)
         (5   27 0 0      note  27 0 .59    10 3     88)
         (PAN 76) (REP-TREM 6)  (CRESC-FROM 95)
         (1   27 0 .5     note  30 0 0      9 23     126)
         (PAN 76) (REP-TREM 8)
         (2   27 1 .5     note  30 0 .1     10 23    122)

; lower chord
         (PAN 32)
         (3   27 0 .5     note  27 1 .7     9 6     108)
         (PAN 120)
         (4   27 0 .5     note  27 1 .65    9 14    112)






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


; msr 30
         (PAN 76)
         (1   30 0 0      note   30 0 0.8     7 26     94)
         (PAN 120)
         (2   30 0 0.04   note   30 0 0.84    7 14     95)


         (PAN 76)
         (3   30 0 0.5     note  30 1 .63    8 26     90)
         (PAN 120)
         (4   30 0 0.47    note  30 1 .53    8 14     93)


         (PAN 76)
         (5   30 1 .23     note   31 0 .1    8 26     95)
         (PAN 120)
         (1   30 1 .25     note   31 0 .3    8 14     92)


; msr 31
         (PAN 32)
         (2   31 0 0       note   31 0 .7     8 1      95)
         (PAN 76)
         (3   30 1 .96     note   31 0 .6     7 21     92)

         (PAN 32)
         (4   31 0 .5      note   31 1 .45    8 1      94)
         (PAN 76)
         (5   31 0 .53     note   31 1 .5     7 21     93)

         (PAN 32)
         (1   31 1 .25     note   32 0 0.25   8 1      95)
         (PAN 76)
         (2   31 1 .25     note   32 0 0.3    7 21     96)


; msr 32
         (PAN 76)
         (3   32 0 .03     note   32 1 .4   9 0     95)
         (PAN 120)
         (4   32 0 0       note   32 0 .67   8 17    92)
         (PAN 32)
         (5   31 1 .97     note   34 0 .1   8 0     91)

         (PAN 120)
         (1   32 0 .46     note   32 1 .2   8 12    95)

         (PAN 32)
         (6   32 1 .23     note   33 0 .1   9 4     100)
         (PAN 76)
         (7   32 1 .25     note   33 0 .2   8 24    98)


; msr 33
         (PAN 32)
         (8   33 0 0      note  33 0 .2    9 2     105)
         (PAN 76)
         (9   33 0 0      note  33 0 .2    8 19    103)

         (PAN 32)
         (11  33 0 .25    note  33 1 .5    9 2     102)
         (PAN 76)
         (6  33 0 .25    note  33 1 .59   8 19    101)


; msr 34
         (PAN 120)
         (1   34 0 0     note  35 0 .2    6 18    127)


; msr 35
         (PAN 120) (REP-TREM 7)
         (11  35 0 0    note   36 0 .2   6 18    104)

         (PAN 120)
         (2   35 0 .8     note  35 1 .4    8 15    116)

         (PAN 120)
         (3   35 1 .2     note  37 0 .1    8 13    118)
         (PAN 76)
         (4   35 1 .2     note  37 0 .1    8 1     117)


; msr 37
         (PAN 76)
         (5   37 1 0     note  38 0 .1    9 22    102)
         (PAN 76)
         (6   37 1 0     note  38 0 .1    9 22    102)


; msr 38
         (PAN 76)
         (1   38 0 0      note  38 1 .2    9 27    110)
         (PAN 76)
         (7   38 0 .03    note  38 1 .1    9 27    110)

         (PAN 76) (TREMOLO 25 10) (VIBRATO 20 10)
         (12  38 0 0      note  38 1 .1    7 27    111)


         (PAN 76)
         (2   38 1 0      note  39 0 0     9 20    106)
         (PAN 76)
         (8   38 0 .95    note  39 0 .1    9 20    106)


; msr 39
         (PAN 76)
         (3   39 0 0      note  39 0 .23    8 25    110)
         (PAN 120)
         (4   39 0 0.03   note  39 0 .33    8 13    112)
         (PAN 120)
         (5   38 1 .96    note  39 0 .3     8 6     111)


         (PAN 76)
         (1   39 0 .333     note  39 1 .09   8 25     111)
         (PAN 120)
         (2   39 0 .313     note  39 1 0     8 13     113)
;                 careful channel 3 . . .
         (PAN 120)
         (3   39 0 .373     note  39 1 .1    8 6      112)


         (PAN 76) (TREMOLO 20 11)(VIBRATO 20 13)
         (12  39 1 .04     note   40 0 .1   8 25     109)
         (PAN 120) (VIBRATO 20 13)(TREMOLO 20 11)
         (13  39 1 0     note     40 0 0    8 13     110)
         (PAN 120) (VIBRATO 20 13)
         (14  39 0 .96     note   40 0 0    8 6      107)



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


; msr 40
         (PAN 32) (REP-TREM 7)
         (6    40 0 0     note   41 1 .2    8 28     77)
         (PAN 32) (REP-TREM 6)
         (7    40 0 0     note   41 1 .1    7 28     78)


; msr 41
         (PAN 32) (VIBRATO 20 12)(DIMINUENDO-TO 90)
         (12   41 1 0       note  43 0 .1    7 23     101)
         (PAN 76)(VIBRATO 20 12) (DIMINUENDO-TO 90)
         (13   41 1 .04     note  43 0 .16    6 16     116)



; msr 43
         (PAN 32) (VIBRATO 17 13) (DIMINUENDO-TO 76)
         (14   43 0 0       note   44 0 .2      7 28     101)



; msr 44
         (PAN 32)
         (15   44 0 .2     note   44 0 .8   7 23     100)


         (PAN 76) (VIBRATO 16 10) (DIMINUENDO-TO 71)
         (16   44 0 .76     note  44 1 .6    8 14     98)
         (PAN 32)(VIBRATO 20 12)
         (12   44 0 .8    note    44 1 .6  7 26     99)
         (PAN 120)(VIBRATO 15 13) (DIMINUENDO-TO 70)
         (13   44 0 .83    note   45 0 .05   7 4      98)


         (PAN 32)
         (14   44 1 .6     note   45 0 .05   7 21     97)



; msr 45
         (PAN 76)  (VIBRATO 18 11) (DIMINUENDO-TO 72)
         (15   45 0 0      note   46 0 0   8 17     103)
         (PAN 120) (VIBRATO 17 10) (DIMINUENDO-TO 75)
         (16   45 0 0.04   note   46 0 0   7 7      104)

         (PAN 32)  (VIBRATO 15 13) (DIMINUENDO-TO 73)
         (12   45 0 .25     note   46 0 .07   8 0      101)



; msr 46
         (PAN 32)  
         (1    46 0 .83    note   47 0 .1    8 24     92)
         (PAN 76)
         (2    46 0 .81    note   47 0 .05   8 12     95)
         (PAN 32)
         (3    46 0 .77    note   47 0 .1    7 19     93)
         (PAN 120)
         (4    46 0 .8     note   47 0 .04   7 2      94)


; msr 47
         (PAN 76) (VIBRATO 20 4)
         (5    47 0 .8     note   48 1 .8    8 18     105)
         (PAN 32)
         (1    47 1 .2     note   48 1 .83   9 1      107)
         (PAN 120) (VIBRATO 19 6)
         (2    47 1 .6     note   48 1 .9    8 1      104)


; msr 48
         (PAN 76)
         (3    48 0 0     note    48 1 .77   7 18     104)
         (PAN 120)  (VIBRATO 17 9)
         (4    48 0 0     note    48 1 .8    7 1      102)


; msr 49
         (PAN 32)
         (5    49 0 0       note  49 0 .6    9 1      105)
         (PAN 76)
         (1    48 1 .96     note  49 0 .61    8 18     107)
         (PAN 120)
         (2    49 0 .02     note  49 0 .58    8 1      106)

;            watch durations.
         (PAN 32)
         (3    49 0 .696     note  49 1 .27    8 27     103)
         (PAN 76)
         (4    49 0 .7       note  49 1 .26    8 15     105)
         (PAN 120)
         (5    49 0 .666     note  49 1 .27    8 5      104)
         (PAN 32)
         (1    49 0 .666     note  49 1 .24    7 22     102)


;                watch durations
         (PAN 32)
         (2    49 1 .333     note  51 0 .1    8 25     106)
         (PAN 120)
         (3    49 1 .353     note  51 0 .05    8 25     106)
         (PAN 76)
         (4    49 1 .323     note  51 0 .12    8 13     104)
         (PAN 32)
         (5    49 1 .313     note  51 0 .12    7 20     101)
         (PAN 120)
         (1    49 1 .333     note  50 0 .1    7  3     103)




; msr 50
         (PAN 120)  (VIBRATO 20 8) (DIMINUENDO-TO 80)
         (12   50 0 0        note  51 0 0     7 1      117)





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




;  msr 51
         (PAN 32) (VIBRATO 15 8)  
         (12   51 1 .4285     note   52 0 .666     8 16     102)
         (PAN 120) (VIBRATO 20 12)
         (13   51 1 .4265     note   52 0 .64     6 28     100)


; msr 52
         (PAN 120)  
         (1   52 0 .666     note     52 1 .6    7 23     105)
         (PAN 76)  (REP-TREM 7)  (DIMINUENDO-TO 50)
         (6   52 1 0        note     55 0 .1    8 6      90)
         (PAN 120)  (REP-TREM 8) (DIMINUENDO-TO 50)
         (7   52 1 .333     note     55 0 .1    7 23     87)


; msr 53
         (PAN 76) 
         (2   53 1 0     note  54 0 0       7 4     124)
         (PAN 76)
         (4   53 1 0.02     note  54 0 0       7 4     125)


; msr 54
         (PAN 76)
         (3   54 1 0     note    55 0 0     7 4     125)
         (PAN 76)
         (5   54 1 0     note    55 0 0     7 4     126)


; msr 57
         (PAN 32)
         (4   57 0 0      note  57 0 .58        9 16     60)
         (PAN 32)
         (5   57 0 .5     note  57 0 .95        9 14     65)
         (PAN 76)
         (1   57 0 .8333     note  57 1 .3       9 4      62)
         (PAN 120)
         (2   57 1 .1666     note  57 1 .7       9 2      63)
         (PAN 120)
         (3   57 1 .4999     note  58 0 .1       8 26     61)


; msr 58
         (PAN 120)
         (4   58 0 0      note    59 0 .1      8 21     64)

         (PAN 76)
         (7   58 1 .2     note    58 1 .6      9 7      62)
         (PAN 76)
         (8   58 1 .6     note    59 0 .02     9 2      63)


; msr 59
         (PAN 76)
         (1   59 0 0      note    60 0 0      9 2      65)

         (PAN 120)
         (9   59 0 .8     note    59 1 .27      10 3     61)
         (PAN 120)
         (11  59 1 .2     note    59 1 .65      10 3     62)
         (PAN 120)
         (6   59 1 .6     note    60 0 .1      10 3     64)


; msr 60
         (PAN 120)
         (7   60 0 .8     note    60 1 .2      10 3     66)

         (PAN 32)
         (2   60 1 .6     note    61 0 .1      8 17     62)


; msr 61
         (PAN 120)  (VIBRATO 17 12)
         (12  61 0 0     note    62 0 0      7 24     113)
         (PAN 120)  (VIBRATO 15 9)  (TREMOLO 25 8)
         (13  60 1 .96     note    62 0 0      8 24     115)





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

; msr 62
         (PAN 32)  (REP-TREM 7)
         (7   62 0 .666     note   63 1 .333      8 12    65)
         (PAN 120) (REP-TREM 6)
         (8   62 0 .666     note   63 1 .333      8 0     66)


; msr 63
         (PAN 32) 
         (1   63 1 .333     note   63 1 .555      8 18    95)
         (PAN 76)
         (2   63 1 .313     note   63 1 .555      8 1     94)


         (PAN 76)
         (3   63 1 .555     note   64 0 .5      8 22    66)
         (PAN 120)
         (4   63 1 .525     note   64 0 .5      8 5     67)



; msr 65
         (PAN 120) (REP-TREM 8)
         (1   65 0 .8       note   69 0 .1      8 27    107)


; msr 66
         (PAN 76) (REP-TREM 7)
         (2   66 0 0     note      69 0 .14   10 3    115)
         (PAN 32) (REP-TREM 6)
         (3   66 0 0     note      69 0 .13   9 15    120)


; msr 69
         (PAN 32)  (VIBRATO 15 11) (DIMINUENDO-TO 80)
         (14   69 0 .4     note   69 1 .7      8 13     118)
         (PAN 32)  (VIBRATO 20 12)  
         (15   69 1 .6     note   70 0 0.1     8 13     117)


         (PAN 32)  (VIBRATO 13 9) (DIMINUENDO-TO 80)
         (16   69 0 .4     note   69 1 .7      8 13     118)
         (PAN 32)  (VIBRATO 20 12)  (DIMINUENDO-TO 80)
         (12   69 1 .6     note   70 0 0.1     8 13     117)


))


