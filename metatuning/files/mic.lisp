;  constants:
(setf NOTE-OFF 8
      NOTE-ON  9
      NOTE-AFTERTOUCH 10
      CONTROLLER 11
      PROG-CHANGE 12
      CHAN-AFTERTOUCH 13
      PITCH-BEND 14
      TICKS-PER-BEAT 960
      LIST-OF-ALL-ARTICULATIONS 
          '(VIBRATO TREMOLO CRESC-FROM DIMINUENDO-TO
          HAIRPIN REP-TREM  PAN PAN-MOVE FP DEFAULT-VOLUME
          DEFAULT-PAN))



; parameter-numbers:
(setf MIDI-CHANNEL-PAR 0
      MSR-PAR 1    BEAT-PAR 2  DIV-PAR 3
      TICK-TIME-PAR     1           ; eventually replaces DIV-PAR argument
      COMMAND-TYPE-PAR  4
      END-MSR-PAR    5
      END-BEAT-PAR   6
      END-DIV-PAR    7
      OCTAVE-PAR     8
      PC-PAR         9
      VELOCITY-PAR   10
      JI-MODIFIER-PAR 11
      PROG-CHANGE-PAR 5
      CONTROLLER-NUMBER-PAR 5
      CONTROLLER-VALUE-PAR 6
      EXT-PITCH-BEND-VALUE-IN-CENTS-PAR 5)

;
;
;************************************************************************************************************************************************
;
;FIRST,  DEFINE A METER STRUCTURE FOR THE PIECE:
;
;  times of notes will be written as:
;      measure, beat, div. (from 0.0 - 1.0 in percentage of the beat)
;
;  define a meter structure:
;   (defun meter-struct
;            '((#-of-measures   4  4)
;              (#-of-measures   3  8)))
;          etc.
;
;
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[  INTERNAL  INTERNAL  INTERNAL  INTERNAL
;   meter-struct is eventually changed internally to the form:  tick #-of-beats size/type-of-beat
;     (example):   ((0 4 4) (3840 4 4) (7680 4 4) 
;                   (11520 4 4) (15360 3 8) (16800 3 8))
;     
;   Each measure is a separate sub-list
;]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;
;
;
;**************************************************************************************************************************
;
;
;SECOND,  DEFINE ALL TEMPO CHANGES:
;  
;   list of     measure, beat, div,    MM, what-is-the-beat
;
;
;   (defun   tempo-struct
;           '((msr beat div 60 1/4)
;             (msr beat div 80 1/8)))
;

;
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[  INTERNAL  INTERNAL  INTERNAL  INTERNAL
;   changed to:
;           ((tick-time MM what-is-the-beat)
;            (tick-time MM what-is-the-beat))
;
;]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;
;
;
;
;
;**********************************************************************************************************
;
;THEN, DEFINE A LIST OF THE PIECE'S EVENTS WHICH INCLUDE:
;
;
;  NOTES:   beats are measured from 0  (NOT 1), so 4/4 bar goes  0 1 2 3 0 1 2 3, etc.
;           divs are less than 1, and indicate portion of the beat
;                so 16ths of a quarter beat are:  .0  .25 .50 .75
;                 triplets are:                   .0    .333  .666
;
;
;
;
;  write a note
;     ( midi-channel  msr beat div     note      end-msr end-beat end-div   octave   pc  dynamic-or-velocity 
;                                       [optional:  ji-modifier(usually 1.0)]
;                                       [eventually, added internally:  midi-note  pitch-bend-in-cents]  )
;                         [[[[[div is
;                            eventually
;                          replaced
;                         internally by
;                           tick-time]]]]]]]]]
;
;
;
;  
; [note-off commands:
;     these will be added internally:
;     (midi-channel   msr beat div    note-off   midi-note)
;  ]
;   
;
;
;
;
;  write other midi event:
;     (midi-channel   msr beat div     midi   event-type   par1  par2)
;                        [[[[[[div is
;                            eventually
;                            replaced
;                          internally by
;                            tick-time]]]]]]]]]]]   
;                      
;
;  program-change:   
;     (midi-channel   msr beat div     prog   program-number)
;                        [[[[[[div is
;                            eventually
;                            replaced
;                          internally by
;                            tick-time]]]]]]]
;
;
;  controller:
;     (midi-channel   msr beat div     ctrl   controller#  value)
;                        [[[[[div is
;                            eventually
;                            replaced
;                          internally by
;                            tick-time]]]]]]]
;
;
;
;  separate pitch-bend event:
;      (midi-channel  msr beat div    bend   value-in-cents)    
;
;
;
;
;
;
;
;
;    THE NOTES MAY BE WRITTEN IN THE SCORE FILE IN ANY ORDER.
;
;
;
;    DURING THE SCORE-FILE, AT ANY POINT, YOU MAY RE-DEFINE THE
;    PITCH SYSTEM WITHIN WHICH YOU ARE WORKING.  ALL SUCCEEDING NOTES 
;     (IN WRITTEN ORDER (NOT ULTIMATE TEMPORAL ORDER))  WILL BE READ
;      IN THAT PITCH SYSTEM.
;
;
;**************************************************************************************************************
;
;    ARTICULATIONS:
;           These are removed in a pre-processing wave of note-processing, and
;                 replaced with appropriate controller, note, program-change, or etc. commands.
;
;   they should appear like this in the score, before the note that they affect:
;         (HAIRPIN 4 7)
;         (1  0 0 0  note  1 0 0    8 0   100)
;;
;  there can be more than one,  but there's no garuntee how the note will be affected:
;         (HAIRPIN 4 7)  (VIBRATO 50 4.5)
;
;
;          VIBRATO width rate                      -random tiny vibrato via pitch bend
;          TREMOLO width rate                      -random tiny tremolo via volume   (optional:  width, rate)
;
;          CRESC-FROM       beginning-low-volume   -gradual change via volume 
;          DIMINUENDO-TO    ending-low-volume      - same 
;              (for these last two, the high volume is given as velocity in the note itself)
;
;          HAIRPIN 3 proportions                   -from niente, to 127, to 0 in the volume parameter,  (set porportions)
;          REP-TREM rate                           -for insts like guitar and xylophone,  repeat the next note a bunch of times
;          REP-VIB  width rate
;                         (rate is average, in number of att's per second.  width is in cents
;          PAN    value                            -fixed location
;          PAN-MOVE  value1 value2                 -location moves from value1 to value2
;
;          DEFAULT                                 -this command is secretly pre-processed into the score, and
;                                                    sets volume and pan to default values.
;          FP                                      -self-expanatory
;
;************************************************************************************************************
;
;
;
;
;
;
;
;  define a pitch system:
;          THIS IS A PRE-PROCESSING COMMAND.  P-STRUCTS ARE REMOVED IN THE FIRST WAVE OF       
;              PROCESSING THE NOTES
;          (Midi-note and cents-bend are added at the end of each note's parameter list).
;
;  
;    Whatever type of system you are using, the pitches will be accessed by "pitch-class-number,"
;           that is, the number of the note in the scale, from 0-(n-1)
;
;   Your scale/pitchsystem may be defined by:
;                           by equal-divisions.
;                           by ratios-of-pitches.        (ratios-of)
;                                  NOTE: LIST MUST INCLUDE 1/1  (the "tonic")
;                           by ratios-between-pitches.   (ratios-between)
;                           by absolute frequencies.     (freqs)
;                                  (in this case, octave 8 will give you the freqs you specify,
;                                     other octaves will transpose your list up and down.)
;                           by cents-between-pitches.    (cents-between)
;                           by cents-of-pitches          (cents-of)
;                                  NOTE:  LIST MUST INCLUDE 0   (the "tonic")
;
;
;        what-is-8-0:         an exact frequency which will be the bottom note of octave 8.
;                                usually this will be/near the standard "middle C".
;                       DEFAULT IS MIDDLE C.
;
;
;        octave:  optional, default is  2.0 / 1.0
;
;    
;     ( p-struct  (ed 17) (what-is-8-0 261) (octave 2.0) )
;
;
;  for this one, it's recommended that you list the pc's below:
;     ( p-struct  (ratios-between 1/1 16/15 9/8 10/9))
;                                0   1    2   3   4
;
;
;     ( p-struct  (ratios-of 1/1 16/15 9/8 6/5 5/4))
;                                 
;     ( p-struct  (freqs  400 420 440 510.342) )
;                 In this case, what-is-8-0 would be meaningless:  just use octave 8 always,
;                    (using higher or lower will transpose accordingly)
;     ( p-struct  (cents-of 0 100 200 300 528) (what-is-8-0 261))
;
;
;
;
;     ( p-struct  (cents-between 100 200 156 228) (what-is-8-0 261))
;                               0   1   2   3   4
;
;
;
;
;
;
;
;
;
;
;
;
;
;
(load "init.lsp")
(load "score")
;     should include 3 lists:
;               score
;               meter-struct
;               tempo-struct
;
;
;
    (setf track-bytes-list ())
    (setf final-rhythm-list ())
;
;
;
;
;
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;  MAIN PROCEDURE :
(defun main ()
    (setf track-bytes-list ())
    (setf final-rhythm-list ())
    (setf this-track-score ())
    (pre-process-pitch-structs)
;        pre-process:  change all pitch values in notes to MIDI-NOTE PITCH-BEND-IN-CENTS
;                      following the p-struct commands,  in list "score"
;                     MIDI-NOTE and PITCH-BEND are tacked on the END of the NOTE
;
    (get-rid-of-all-p-struct-commands)
;        remove all p-struct commands from list "Score"
;
    (add-note-off-commands)   
;        add note-off commands to go with each note command
;                   in list "score"
;
;
;         expand the meter structure;  add tick-values
;          in front of each entry
    (expand-meters-and-add-ticks)
;
;
;         this will add DEFAULT-VOLUME and DEFAULT-PAN articulations, setting volume and panning to 0.
;              (if there are no other VOLUME or PAN related commands before a note)
;          better to take care of this at the beginning of a new note, rather than at the end of
;           an old note.  
    (add-default-commands)
;
;
;        the following will be easier after expanding the meter structure
;              and figuring out bend values for the notes:
    (process-articulations)
    (get-rid-of-all-articulation-commands)
;
;        make a list,  replacing time with ticks
;                    for "note" commands, you only worry about onset time, since
;                    for "note-off" commands take care of note-off time.
    (replace-all-times-in-score-with-ticks)
;
;
;
;        then sort all events by:
;                     channel
;                       time --- now in ticks
    (sort-score-by-channel-and-time)
;
;
;
    (setf num-of-tracks (+ 1 (nth MIDI-CHANNEL-PAR (first (last score)))))
;         number of midi-channels + 1 intro track.
;
;
;       all tempo and meter changes will go into the first "intro" track:
;       format of the actual tempo and meter changes should be as given 
;        [all the way down] below for
;        function "add-tempo-change" and "add-meter-change"
;
;       the following adds the tempo changes to the meter-change list.
;        it also changes the tempo-change times to ticks.
;        the result should be sorted.
;
    (combine-tempo-changes-and-meter-changes)
;
;
;
;
     (with-open-file (blablastream "blabla.mid" :direction :output 
                                 :element-type 'unsigned-byte)
;
       (write-smf-header blablastream 1 num-of-tracks TICKS-PER-BEAT)
;
;
       (setf track-bytes-list ())
       (process-final-rhythm-list-into-track-bytes-list)
;
;
       (write-track blablastream track-bytes-list)
;  this writes the 1st, introductory track with tempo changes
;        also,  include the intro text.
;
;
;           now for the rest of the tracks:
       (dotimes (track (- num-of-tracks 1))
;
;                    num-of-tracks - 1 =
;                 number of tracks, besides intro
;
                (setf track-bytes-list ())
;          remember,  tracks go from ONE to SIXTEEN
                (setf this-track-score (get-track score (+ 1 track)))
                (process-this-track-score-into-track-bytes-list)
;                     should make track-bytes-list out of this-track-score
;                REMINDERS:
                (write-track blablastream track-bytes-list))))
;              write the list out.
;         
;
;
;
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;PROCEDURES TO PROCESS ARTICULATIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defclass articulation ()
      ((articulation-command  :accessor articulation-command  :initarg :articulation-command)
       (the-note              :accessor the-note    :initarg :the-note)))
 


(defclass VIBRATO        (articulation) ())
(defclass TREMOLO        (articulation) ())
(defclass PAN            (articulation) ())
(defclass PAN-MOVE       (articulation) ())
(defclass CRESC-FROM     (articulation) ())
(defclass DIMINUENDO-TO  (articulation) ())
(defclass HAIRPIN        (articulation) ())
(defclass REP-TREM       (articulation) ())
(defclass FP             (articulation) ())
(defclass DEFAULT-VOLUME (articulation) ())   ;  sets a note's volume & pan values to default (127, 64) values at the beginning
(defclass DEFAULT-PAN    (articulation) ())   ;  sets a note's volume & pan values to default (127, 64) values at the beginning




(defun process-articulations ()
;
;   this procedure is engaged after processing the p-structs.
;     at that point, every note's list is ended with midi-note, cents-bend
;
;
;
; go through each item in the score
;   is it an articulation?
;      look for the note after it
;      send that and the parameters to the articulation procedure
;
;
  (let ((this-note '())
        (this-articulation '())
        (note-reffered-to-pointer '())
        (note-reffered-to '()))
;
;
  (dotimes (note-counter (length score))
;  get the next "note", meaning item in the score, regardles of whether it's 
;      actually a note, an articulation, or whatever:
      (setf this-note (nth note-counter score))
;  test if this-note is an articulation command:
      (when (member (first this-note) LIST-OF-ALL-ARTICULATIONS)
            (setf this-articulation this-note)
;               look forward for the note it affects:
            (setf note-reffered-to-pointer note-counter)
            (loop
                (setf this-note (nth note-reffered-to-pointer score))
;   now, this-note is wanting to be an actual note:
                (when (eq (nth COMMAND-TYPE-PAR this-note) 'note)
                      (setf note-reffered-to this-note)
                      (return))
                (setf note-reffered-to-pointer (+ 1 note-reffered-to-pointer)))
      (articulate (make-instance 
                     (first this-articulation) 
                     :articulation-command this-articulation
                     :the-note note-reffered-to)))))) 







;
;   (TREMOLO midi-volume-difference average-number-of-changes-per-second)
;
(defmethod articulate ((articulation TREMOLO))
      (let ((the-note (the-note articulation))
            (articulation-command (articulation-command articulation))
            (time-list '())
            (vol-diff (second (articulation-command articulation)))
            (vol 127)
            (the-vol-diff 0))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
     (setf time-list (make-time-list-for the-note (third articulation-command)))
     (dolist (elle time-list)
       (setf score (append score (list 
         (list 
            (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
            (first elle) (second elle) (third elle)
            'ctrl
            '7   ; controller number 7,  volume
            (progn
                 (setf vol 
                    (- 127
                       (progn (setf the-vol-diff (random vol-diff)) 
                              (when (< the-vol-diff (* .5 vol-diff))
                                    (setf the-vol-diff (random vol-diff)))
                              the-vol-diff)))
                 (when (> vol 127)
                       (setf vol 127))
                 (when (< vol 0)
                       (setf vol 0))
                 vol))))))))





;
;   (PAN position(0-64-127))
;
(defmethod articulate ((articulation PAN))
      (let ((the-note (the-note articulation))
            (articulation-command (articulation-command articulation)))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)

     (setf score (append score (list 
         (list 
            (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
            (nth MSR-PAR the-note) (nth BEAT-PAR the-note) (nth DIV-PAR the-note) 
            'ctrl
            '10   ; controller number 10,  pan
            (second articulation-command)))))))





;
;   (DEFAULT-PAN)
;
(defmethod articulate ((articulation DEFAULT-PAN))
      (let ((the-note (the-note articulation)))
;
        (setf score (append score (list 
          (list 
            (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
            (nth MSR-PAR the-note) (nth BEAT-PAR the-note) (nth DIV-PAR the-note) 
            'ctrl
            '10   ; controller number 10,  pan
            '64))))))



;
;   (DEFAULT-VOLUME)
;
(defmethod articulate ((articulation DEFAULT-VOLUME))
      (let ((the-note (the-note articulation)))
;
        (setf score (append score (list 
          (list 
            (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
            (nth MSR-PAR the-note) (nth BEAT-PAR the-note) (nth DIV-PAR the-note) 
            'ctrl
            '7   ; controller number 7,  volume
            '127))))))










;
;   (PAN-MOVE position1 position2(0-64-127) )
;
;  (number of changes per second is constant 15 for this one)
;
(defmethod articulate ((articulation PAN-MOVE))
  (let ((the-note (the-note articulation))
         (articulation-command (articulation-command articulation))
         (time-list '())
         (num-of-changes 0)
         (first-pan 0) (last-pan 0)
         (pan-value 0) 
         (count-changes 0))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
     (setf first-pan (second articulation-command))
     (setf last-pan (third articulation-command))
     (setf time-list (make-time-list-for the-note 15))
     (setf num-of-changes (length time-list))
; make it so the time-list has "holes" at the begining and end,
;      so that the initial and final values "Stick around" longer
     (when (> num-of-changes '7)
           (setf time-list (append 
                (list (first time-list))
                (subseq time-list 3 (- (length time-list) 3))
                (last time-list)))
           (setf num-of-changes (length time-list)))
;  now add the notes to the score
     (dolist (elle time-list)
         (setf pan-value (truncate
           (+  first-pan
               (* (- last-pan first-pan) 
                  (/ count-changes num-of-changes)))))
         (setf score (append score (list 
             (list 
                (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
                (first elle) (second elle) (third elle) 
                'ctrl
                '10   ; controller number 10,  pan
                pan-value))))
         (setf count-changes (+ 1 count-changes)))))






;
;   (CRESC-FROM       beginning-low-volume)
;      -gradual change via volume 
;              (the high volume is given as velocity in the note itself)
;
;  (number of changes per second is constant 20 for this one)
;
(defmethod articulate ((articulation CRESC-FROM))
  (let ((the-note (the-note articulation))
         (articulation-command (articulation-command articulation))
         (time-list '())
         (num-of-changes 0)
         (first-volume 0)
         (volume-value 0)
;  count-changes is one so that the ending is at 127 level, not slightly smaller
         (count-changes 1))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
     (setf first-volume (truncate
        (/  (* 127.0 (second articulation-command))
            (nth VELOCITY-PAR the-note))))
     (setf time-list (make-time-list-for the-note 20))
     (setf num-of-changes (length time-list))
;   make it so the time-list has "holes" at the begining and end,
;        so that the initial and final values "Stick around" longer
     (when (> num-of-changes '7)
           (setf time-list (append 
                (list (first time-list))
                (subseq time-list 3 (- (length time-list) 3))
                (last time-list)))
           (setf num-of-changes (length time-list)))
;  now add the notes to the score
     (dolist (elle time-list)
         (setf volume-value (truncate
           (+  first-volume
               (* (- 127 first-volume)
                  (/ count-changes num-of-changes)))))
         (setf score (append score (list 
             (list 
                (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
                (first elle) (second elle) (third elle) 
                'ctrl
                '7   ; controller number 7, volume
                volume-value))))
         (setf count-changes (+ 1 count-changes)))
    (format t "~%~%~% ~a ~%~%~%" score)))







;
;   (DIMUENDO-TO       ending-low-volume)
;      -gradual change via volume 
;              (the high volume is given as velocity in the note itself)
;
;  (number of changes per second is constant 20 for this one)
;
(defmethod articulate ((articulation DIMINUENDO-TO))
  (let ((the-note (the-note articulation))
         (articulation-command (articulation-command articulation))
         (time-list '())
         (num-of-changes 0)
         (last-volume 0)
         (volume-value 0)
         (count-changes 0))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
     (setf last-volume (truncate
        (/  (* 127.0 (second articulation-command))
            (nth VELOCITY-PAR the-note))))
     (setf time-list (make-time-list-for the-note 20))
     (setf num-of-changes (length time-list))
;   make it so the time-list has "holes" at the begining and end,
;        so that the initial and final values "Stick around" longer
     (when (> num-of-changes '7)
           (setf time-list (append 
                (list (first time-list))
                (subseq time-list 3 (- (length time-list) 3))
                (last time-list)))
           (setf num-of-changes (length time-list)))
;  now add the notes to the score
     (dolist (elle time-list)
         (setf volume-value (truncate
           (+  last-volume
               (* (- 127 last-volume)
                  (/ (- num-of-changes count-changes) 
                     num-of-changes)))))
         (setf score (append score (list 
             (list 
                (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
                (first elle) (second elle) (third elle) 
                'ctrl
                '7   ; controller number 7, volume
                volume-value))))
         (setf count-changes (+ 1 count-changes)))))













;
;   (FP )
;  pretty dagged simple
;
;
;  (number of changes per second is constant 15 for this one)
;
(defmethod articulate ((articulation FP))
  (let  ((the-note (the-note articulation))
         (articulation-command (articulation-command articulation))
         (time-list '())
         (num-of-changes 0)
         (last-volume 0)
         (volume-value (+ 40 (random 40)))
         (change-time ()))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
;     (setf last-volume (truncate
;        (/  (* 127.0 (second articulation-command))
;            (nth VELOCITY-PAR the-note))))
     (setf time-list (make-time-list-for the-note 15))
     (setf num-of-changes (length time-list))
;   make it so the time-list has "holes" at the begining and end,
;        so that the initial and final values "Stick around" longer
     (when (> num-of-changes '3)
;  on third time-change go to soft volume
           (setf change-time (third time-list))
           (setf score (append score (list 
              (list 
                  (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
                  (first change-time) (second change-time) (third change-time) 
                  'ctrl
                  '7   ; controller number 7, volume
                  volume-value)))))))















;
;   (HAIRPIN  proportion1 proportion2 proportion3 )
;      -gradual change via volume 
;             low volume is 3% of high volume
;              (the high volume--in the middle of the hairpin--is given as velocity in the note itself)
;
;  (number of changes per second is constant 10 for this one)
;
(defmethod articulate ((articulation HAIRPIN))
  (let ((the-note (the-note articulation))
         (articulation-command (articulation-command articulation))
         (time-list '())
         (time-list-element '())
         (num-of-changes 0)
         (proportion1 0) (proportion2 0) (proportion3 0)
         (proportion-sum 0)
         (low-volume (round (* 0.03 127.0)))
         (volume-value 0)
         (num-for-cresc 0) (num-for-steady 0) (num-for-dim 0)
         (current-sum 0)
         (count-changes 0))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
     (setf time-list (make-time-list-for the-note 20))
     (setf num-of-changes (length time-list))
     (setf proportion1 (second articulation-command))
     (setf proportion2 (third  articulation-command))
     (setf proportion3 (fourth articulation-command))
     (setf proportion-sum (+ proportion1 proportion2 proportion3))
;      if the note is very short, just do a simple cresc-decresc 
;
     (setf num-for-cresc (round (* 1.0 num-of-changes (/ proportion1 proportion-sum))))
     (setf num-for-steady (round (* 1.0 num-of-changes (/ proportion2 proportion-sum))))
     (setf num-for-dim  (round (* 1.0 num-of-changes (/ proportion3 proportion-sum))))
     (Setf current-sum (+ num-for-cresc num-for-steady num-for-dim))
     (when (< current-sum num-of-changes)
           (loop 
              (setf num-for-cresc (+ 1 num-for-cresc))
              (Setf current-sum (+ num-for-cresc num-for-steady num-for-dim))
              (when (eq current-sum num-of-changes) (return))       
              (setf num-for-steady (+ 1 num-for-steady))
              (Setf current-sum (+ num-for-cresc num-for-steady num-for-dim))
              (when (eq current-sum num-of-changes) (return))       
              (setf num-for-dim (+ 1 num-for-dim))
              (Setf current-sum (+ num-for-cresc num-for-steady num-for-dim))
              (when (eq current-sum num-of-changes) (return))       
                     ))
     (when (> current-sum num-of-changes)
           (loop   
              (setf num-for-dim (- num-for-dim 1))
              (Setf current-sum (+ num-for-cresc num-for-steady num-for-dim))
              (when (eq current-sum num-of-changes) (return))       
              (setf num-for-steady (- num-for-steady 1))
              (Setf current-sum (+ num-for-cresc num-for-steady num-for-dim))
              (when (eq current-sum num-of-changes) (return))       
              (setf num-for-cresc (- num-for-cresc 1))
              (Setf current-sum (+ num-for-cresc num-for-steady num-for-dim))
              (when (eq current-sum num-of-changes) (return))       
                     ))
;
;  now add the CRESC notes to the score
;
     (dotimes (counter num-for-cresc)
         (setf time-list-element (nth count-changes time-list))
         (setf volume-value (truncate
           (+  low-volume
               (* (- 127.0 low-volume)
                  (/ counter
                     num-for-cresc)))))
         (setf score (append score (list 
             (list 
                (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
                (first time-list-element) (second time-list-element) (third time-list-element) 
                'ctrl
                '7   ; controller number 7,  volume
                volume-value))))
         (setf count-changes (+ 1 count-changes)))
;
;  now add the STEADY notes to the score
;
     (dotimes (counter num-for-steady)
         (setf time-list-element (nth count-changes time-list))
         (setf score (append score (list 
             (list 
                (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
                (first time-list-element) (second time-list-element) (third time-list-element) 
                'ctrl
                '7   ; controller number 7,  volume
                '127))))
         (setf count-changes (+ 1 count-changes)))
;
;  now add the DIM notes to the score
;
     (dotimes (counter num-for-dim)
         (setf time-list-element (nth count-changes time-list))
         (setf score (append score (list 
             (list 
                (nth MIDI-CHANNEL-PAR the-note) 
;     (midi-channel   msr beat div     ctrl   controller#  value)
                (first time-list-element) (second time-list-element) (third time-list-element) 
                'ctrl
                '7   ; controller number 7,  volume
                (+  low-volume (truncate
                  (* (- 127.0 low-volume)
                     (/ (- num-for-dim counter)
                        num-for-dim))))))))
         (setf count-changes (+ 1 count-changes)))))














;
;   (VIBRATO cents average-number-of-changes-per-second)
;
(defmethod articulate ((articulation VIBRATO))
      (let ((the-note (the-note articulation))
            (articulation-command (articulation-command articulation))
            (time-list '()))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
     (setf time-list (make-time-list-for the-note (third articulation-command)))
     (dolist (elle time-list)
       (setf score (append score (list 
         (list 
            (nth MIDI-CHANNEL-PAR the-note) 
; channel msr beat div bend value            
            (first elle) (second elle) (third elle)
            'bend 
            (truncate
                 (+ (const-frandom (* -1 (second articulation-command))
                              (second articulation-command))
                    (first (last the-note)))))))))))










;
;   (REP-TREM average-number-of-reps-per-second)
;
(defmethod articulate ((articulation REP-TREM))
      (let ((the-note (the-note articulation))
            (articulation-command (articulation-command articulation))
            (time-list '())
            (elle ()) (next-elle ()))
;
     (format t "~%~%~%~%~%~%    ~a  ~a ~%~%~%" the-note articulation-command)
     (setf time-list (make-time-list-for the-note (second articulation-command)))
;
;   delete original note from score:
;     (setf score
;        (remove the-note score
;           :test #'equal))
;
     (dotimes  (counter (length (butlast time-list)))
       (setf elle (nth counter time-list))
       (setf next-elle (nth (+ counter 1) time-list))
       (setf score (append score (list 
;      note on:
         (list 
            (nth MIDI-CHANNEL-PAR the-note) 
;     ( midi-channel  msr beat div     note      end-msr end-beat end-div   octave   pc  dynamic-or-velocity )
            (first elle) (second elle) (third elle)
            'note
            (first next-elle) (second next-elle) (third next-elle)
	    (nth OCTAVE-PAR the-note)
            (nth PC-PAR the-note)
            (nth VELOCITY-PAR the-note)
            (nth (- (length the-note) 2) the-note)   ; midinote
            (nth (- (length the-note) 1) the-note))))) ;; bend
;      note off:
      (setf score (append score (list
         (list
            (nth MIDI-CHANNEL-PAR the-note)
;     (midi-channel   msr beat div    note-off   midi-note)
            (first next-elle) (second next-elle) (third next-elle)
            'note-off
            (nth (- (length the-note) 2) the-note)))))) 
     (format t "~%~%~%~%~%~%~% ~a ~%~%~%~%" score)))









(defun make-time-list-for (the-note average-num-per-second)
;
;    make a list of msr-beat-div times averaging 10 per second.
;
   (let ((time-list '())
         (cur-measure '0)
         (bts-in-this-msr '0)
         (beats-div 0.0)
         (cur-mm-tempo-per-quarter 60.0)
         (cur-tempo-per-cur-beat 60.0)
         (time-used-in-this-measure 0.0)
         (time-used-per-cur-beat 0.0)
         (average-beat-div-increment 0.0)
         (cur-time '()) 
         (cur-time-decimal 0.0))
;
                 (setf cur-measure (nth MSR-PAR the-note))
;    this gives the total number of beats in the whole measure (not what's left):
                 (setf bts-in-this-msr (second (nth cur-measure meter-struct)))
;  find out number of beats.div left in this measu
;   the following also tests whether the note ends in the middle of this measure, or some time later. . . 
                 (setf beats-div 
                            (if (eq cur-measure (nth END-MSR-PAR the-note))
;                                 yes it ends in the middle:
                                (-  (+  (nth END-BEAT-PAR the-note) (nth END-DIV-PAR the-note))
                                    (+  (nth BEAT-PAR the-note) (nth DIV-PAR the-note)))
;                                 no it ends later:
                                (- bts-in-this-msr (+ (nth BEAT-PAR the-note) (nth DIV-PAR the-note)))))
;    beats-div should be a floating-point number in the form:   beats.div
                                            (format t "~%~%~%~%  ~A ~A ~A ~%~%~%~%~%" cur-measure bts-in-this-msr beats-div)
;  find out number of seconds left in this measure
;                     find out current tempo, in seconds per beat (Whatever the beat may be).
;    this should find the last tempo change before the note
                  (dolist (elle tempo-struct)
                          (when (< (First elle) (nth MSR-PAR the-note))
                                (setf cur-mm-tempo-per-quarter 
                                   (*  (nth 3 elle) 
                                       (/  (nth 4 elle) .25)))))
                  (setf cur-tempo-per-cur-beat (/  (*  cur-mm-tempo-per-quarter  
                                                       (nth 2 (nth cur-measure meter-struct)))
                                                   4.0))
                  (setf time-used-per-cur-beat (/  60.0 cur-tempo-per-cur-beat)) 
                  (setf time-used-in-this-measure (* time-used-per-cur-beat beats-div))
;    this is measured in beat.div:
                  (setf average-beat-div-increment (/ (/ 1.0 average-num-per-second) 
                                                      time-used-per-cur-beat))
;  make the time-list  this measure
;;  (format t "~%~%~%  ~a ~a ~a ~a ~a ~a  ~%~%~%" beats-div cur-mm-tempo-per-quarter cur-tempo-per-cur-beat time-used-per-cur-beat time-used-in-this-measure average-beat-div-increment)
                  (setf cur-time (list (nth MSR-PAR the-note) (nth BEAT-PAR the-note) (nth DIV-PAR the-note)))
                  (loop
                         (setf time-list (append time-list (list cur-time)))
                         (setf cur-time-decimal (+ (nth 1 cur-time) (nth 2 cur-time)))
                         (setf cur-time-decimal (+ cur-time-decimal 
                                                    (* (const-frandom .7692 1.3) average-beat-div-increment)))
                         (when (> cur-time-decimal (+ (nth BEAT-PAR the-note) (nth DIV-PAR the-note) beats-div))
                               (return))
                         (setf cur-time (list (nth MSR-PAR the-note) 
                                              (truncate cur-time-decimal)
                                              (- cur-time-decimal (truncate cur-time-decimal)))))
;;;;;;;;;;; 
;;;;;;;;;;;  loop:
;;;;;;;;;;;   is there another whole measure?  if so do it.
;;;;;;;;;;;
                  (setf cur-measure (+ 1 (nth MSR-PAR the-note)))
                  (loop 
                        (when (>= cur-measure (nth END-MSR-PAR the-note)) (return)) 
                        (dolist (elle tempo-struct)
                                (when (< (First elle) cur-measure)
                                      (setf cur-mm-tempo-per-quarter 
                                         (*  (nth 3 elle) 
                                             (/  (nth 4 elle) .25)))))
                        (setf cur-tempo-per-cur-beat (/  (*  cur-mm-tempo-per-quarter  
                                                           (nth 2 (nth cur-measure meter-struct)))
                                                       4.0))
                        (setf time-used-per-cur-beat (/  60.0 cur-tempo-per-cur-beat))
;      this is measured in beat.div:
                        (setf average-beat-div-increment (/ (/ 1.0 average-num-per-second) 
                                                            time-used-per-cur-beat))
;        write to the time-list
                        (setf cur-time (list cur-measure 0 (const-frandom 0.0 0.2)))
                        (loop
                               (setf time-list (append time-list (list cur-time)))
                               (setf cur-time-decimal (+ (nth 1 cur-time) (nth 2 cur-time)))
                               (setf cur-time-decimal (+ cur-time-decimal 
                                                    (* (const-frandom .7692 1.3) average-beat-div-increment)))
                               (when (> cur-time-decimal bts-in-this-msr)  (return))
                               (setf cur-time (list cur-measure
                                                  (truncate cur-time-decimal)
                                                  (- cur-time-decimal (truncate cur-time-decimal)))))
                        (setf cur-measure (+ 1 cur-measure)))
;;;;;;;;;;;
;;;;;;;;;;;  is there a final partial measure? if so do it.
;;;;;;;;;;;
;;;                    set cur-measure to last measure, regardless of what's happened
                  (setf cur-measure (nth END-MSR-PAR the-note))
                  (when  (and (null (eq (nth MSR-PAR the-note) (nth END-MSR-PAR the-note)))
                              (or (> (nth END-BEAT-PAR the-note) 0) (> (nth END-DIV-PAR the-note) 0.0)))
;  find the average beat.div increment in this measure:
                        (dolist (elle tempo-struct)
                                (when (< (First elle) cur-measure)
                                      (setf cur-mm-tempo-per-quarter 
                                         (*  (nth 3 elle) 
                                             (/  (nth 4 elle) .25)))))
                        (setf cur-tempo-per-cur-beat (/  (*  cur-mm-tempo-per-quarter  
                                                           (nth 2 (nth cur-measure meter-struct)))
                                                       4.0))
                        (setf time-used-per-cur-beat (/  60.0 cur-tempo-per-cur-beat))
;                                  this is measured in beat.div:
                        (setf average-beat-div-increment (/ (/ 1.0 average-num-per-second) 
                                                            time-used-per-cur-beat))
                        (setf cur-time (list cur-measure 0 0))
                        (loop
                               (setf time-list (append time-list (list cur-time)))
                               (setf cur-time-decimal (+ (nth 1 cur-time) (nth 2 cur-time)))
                               (setf cur-time-decimal (+ cur-time-decimal 
                                                    (* (const-frandom .7692 1.3) average-beat-div-increment)))
                               (when (> cur-time-decimal 
                                        (+ (nth END-BEAT-PAR the-note) (nth END-DIV-PAR the-note)))  (return))
                               (setf cur-time (list cur-measure
                                                  (truncate cur-time-decimal)
                                                  (- cur-time-decimal (truncate cur-time-decimal))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(format t "~%~%~%~%  ~a ~%~%~%" time-list)
time-list
))

;         
;
;





;  procedure to add DEFAULT-VOLUME or DEFAULT-PAN
;    if no VOLUME or PAN related articulations precede a note,
;    respectively.
;
;
(defun add-default-commands ()
   (let ((new-list ())     
         (hi  ())
         (pan-flag nil)
         (vol-flag nil)
         (passed-something-on-flag nil))
   (dolist (elle score)
      (setf passed-something-on-flag nil)
      (when (member (first elle) '(PAN PAN-MOVE)) 
            (setf pan-flag t)
            (setf new-list (append new-list 
                           (list elle)))
            (setf passed-something-on-flag t)
            )
      (when (member (first elle) '(HAIRPIN DIMINUENDO-TO 
				   CRESC-FROM TREMOLO FP)) 
            (setf vol-flag t)
            (setf new-list (append new-list 
                           (list elle)))
            (setf passed-something-on-flag t)
            )
      (when (eq (nth 4 elle) 'note) 
            (if pan-flag
                ()
                (setf new-list (append new-list '((DEFAULT-PAN)))))
            (if vol-flag
                ()
                (setf new-list (append new-list '((DEFAULT-VOLUME)))))
            (setf vol-flag nil) (setf pan-flag nil)
            (setf new-list (append new-list (list elle)))
            (setf passed-something-on-flag t))
      (when (null passed-something-on-flag)
                 (format t "~%~% passing something else on:  ~a  ~%~%" elle)
                 (setf new-list (append new-list (list elle)))))
   (setf score new-list)))

             

;  if element is a PAN articulation, set pan flag
;         pass the PAN on to the score copy
;  if elements is a VOLUME articulation, set VOLUME flag
;         pass on the VOLUME command
;  if element is a note,  check flags:
;               if a flag is not set, write that default
;               if the flag is set,  do not write default
;       clear flags
;       pass the note on.  (note has to come after the articulations)
;  if element is something else, pass it on.
;  next element.









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;PROCEDURES TO PRE-PROCESS PITCH-STRUCTS AND NOTES ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defun pre-process-pitch-structs ()
  (let ((this-pitch-array ())
        (octave 2.0) 
        (octave-8 '(261.62558 277.18265 293.66483 311.12704 329.62766 
                    349.22833 369.99457 391.9956 415.3049 440.0 466.16403 493.88364))
        (what-is-8-0 261.0)
        (ratio-list ())
        (ed 0)
        (cents-of ())
        (cents-between ())
        (this-note-octave 8)
        (this-note-pc 0)
        (this-note-ji-mod 1.0)
        (this-note-frequency 440.0)
        (this-note-midi 60)
        (this-note-cents-bend 0)
       )
;
;  in case of no p-structs, defaults to 12-edo.
;
    (setf this-pitch-array (make-default-pitch-array))
;
;  go through the score
;   is it a note, a change of struct,  or something else?    
;
    (dotimes (note-counter (length score))
      (let ((this-note (nth note-counter score)))
         (when 
;
;     if it's a p-struct,  then build a list of all pitches in octaves
;                 1 through 15
;
             (eq (first this-note) 'p-struct) 
;           set defaults for octave,  what-is-8-0, this-pitch-array  etc.
             (setf this-pitch-array ())
             (setf octave 2.0)  (setf what-is-8-0 261.6255653005986)         
;           then go through list, see if they're changed.
             (dolist  (elle this-note)
                (when (listp elle)
                      (case (first elle)
                         (octave      (setf octave      (second elle)))
                         (what-is-8-0 (setf what-is-8-0 (second elle))))))
;
;
;              now make the list of pitches, into this-pitch-array.
;         shall be structured  ((pc0 pc1 pc2. . . .) (pc0 pc1 pc2 . . . )  
;            etc. for 15 octaves
;
;
             (dolist (elle this-note)
                (when (listp elle)
                   (case (first elle)
                         (ratios-of 
                            (setf ratio-list (rest elle))
                            (setf octave-8 (get-freqs-ratios-of ratio-list what-is-8-0))
                            (setf this-pitch-array (get-octaves octave-8 octave)))
                         (ratios-between 
                            (setf ratio-list (rest elle))
                            (setf octave-8 (get-freqs-ratios-between ratio-list what-is-8-0))
                            (setf this-pitch-array (get-octaves octave-8 octave)))
                         (ed
                            (setf ed (second elle))
                            (setf octave-8 (get-freqs-ed ed what-is-8-0 octave))
                            (setf this-pitch-array (get-octaves octave-8 octave)))
                         (freqs
                            (setf octave-8 (rest elle))
                            (setf this-pitch-array (get-octaves octave-8 octave)))
                         (cents-of
                            (setf cents-of (rest elle))
                            (setf octave-8 (get-freqs-cents-of cents-of what-is-8-0))
                            (setf this-pitch-array (get-octaves octave-8 octave)))
                         (cents-between
                            (setf cents-between (rest elle))
                            (setf octave-8 (get-freqs-cents-between cents-between what-is-8-0))
                            (setf this-pitch-array (get-octaves octave-8 octave))))))
             (format t "~%~%~a~%~%~%" this-pitch-array))
;
;
;
; 
;     if it's a note,  then do conversion:
;
;
         (when 
             (eq (fifth this-note) 'note)
             (setf this-note-octave (nth OCTAVE-PAR this-note))
             (setf this-note-pc  (nth PC-PAR this-note))
             (if (null (nth JI-MODIFIER-PAR this-note))
                 (setf this-note-ji-mod 1.0)
                 (setf this-note-ji-mod (* 1.0 (nth JI-MODIFIER-PAR this-note))))
             (setf this-note-frequency 
                 (* this-note-ji-mod
                    (nth (mod this-note-pc (length octave-8))
                      (nth (- this-note-octave 1) this-pitch-array))))
             (setf this-note-midi  (first (get-midi this-note-frequency)))
             (setf this-note-cents-bend  (second (get-midi this-note-frequency)))
;;  we actually have to destructively write to the score-list
;;       tack on the MIDI-note plus cents-modifier at the end
             (setf (nth note-counter score) (append this-note
                   (list this-note-midi this-note-cents-bend))))))))








;************************************************************************************
;************************************************************************************
;       SUB-FUNCTIONS FOR P-STRUCTS 
;************************************************************************************
;************************************************************************************
(defun  make-default-pitch-array ()
   (let ( (octave-8 ())
          (this-pitch-array ())
        )
;
;        makes a default pitch-array with 12-tone-et
;
     (setf octave-8 (get-freqs-ed 12 261.6255653005986 2.0))
     (setf this-pitch-array (get-octaves octave-8 2.0))
     this-pitch-array))




(defun  get-freqs-ed  (equal-division what-is-8-0 octave)
;
;     spits out one octave's worth of frequencies
;     with "what-is-8-0" as the first pitch
;
  (let ((final-list ())
       (base-ratio (expt octave (/ 1.0 equal-division)))
       )
     (dotimes (pc equal-division)
          (setf final-list (append final-list 
               (list   (* what-is-8-0 (expt base-ratio pc))))))
     final-list))




(defun  get-freqs-ratios-of (ratio-list what-is-8-0)
;
;     spits out one octave's worth of frequencies
;     with "what-is-8-0" as the first pitch
;
  (let ((final-list ())
       ) 
    (dolist (ratio ratio-list)
        (setf final-list (append final-list
            (list (* 1.0 what-is-8-0 ratio)))))
    final-list))





(defun  get-freqs-ratios-between (ratio-list what-is-8-0)
;
;     spits out one octave's worth of frequencies
;     with "what-is-8-0" as the first pitch
;
  (let ((final-list (list what-is-8-0))
        (current-pitch what-is-8-0)
       ) 
    (dolist (ratio ratio-list)
        (setf final-list (append final-list
            (list 
               (setf current-pitch (* 1.0 current-pitch ratio))))))
    final-list))




(defun  get-freqs-cents-of (cents-of-list what-is-8-0)
;    
;     spits out one octave's worth of frequencies
;     with "what-is-8-0" as the first pitch
;
  (let ((final-list ())
       ) 
    (dolist (cents-of-current-pitch cents-of-list)
        (setf final-list (append final-list
            (list (* what-is-8-0 
                (expt 1.0005777895065548 cents-of-current-pitch))))))
    final-list))





(defun  get-freqs-cents-between (cents-between-list what-is-8-0)
;
;     spits out one octave's worth of frequencies
;     with "what-is-8-0" as the first pitch
;
  (let ((final-list (list what-is-8-0))
        (current-pitch what-is-8-0)
       ) 
    (dolist (cents-of-current-interval cents-between-list)
        (setf final-list (append final-list
            (list
               (setf current-pitch 
                (* current-pitch 
                 (expt 1.0005777895065548 cents-of-current-interval)))))))
    final-list))




(defun  get-octaves (octave-8 what-is-octave)
;
;    given a list of frequencies in octave-8  
;       (ostensibly the middle-C octave) this returns
;       a list of lists of octaves of frequencies from
;    octave 1,  up to 15.
   (let ((pitch-array  ())
         (this-octave ())
        )
       (dotimes (octave-counter 15)
          (setf pitch-array (append pitch-array
            (list
               (dolist (pc octave-8 this-octave)
                  (setf this-octave (append this-octave (list 
                     (* pc (expt what-is-octave (- octave-counter 7))))))))))
          (setf this-octave ()))
       pitch-array))




(defun  get-midi  (frequency)
;  make a list of midi-note,  cents-bend
   (let ((midi-list ())
         (midi-60 261.6255653005986)   
        )
     (setf midi-list 
       (multiple-value-bind 
             (midi bend) 
             (round  
               (+ 60.0
                  (log (/ frequency midi-60) 
                      1.0594630943592953)))
             (list midi bend)))
     (when (< (abs (nth 1 midi-list)) 0.0001) 
           (setf (nth 1 midi-list) 0.0))
     (setf (nth 1 midi-list)
          (* (nth 1 midi-list) 100))
     midi-list))






(defun get-rid-of-all-p-struct-commands ()
     (setf score 
         (remove-if #'p-struct-p score)))


(defun p-struct-p (input)
    (eq (first input) 'p-struct))


(defun get-rid-of-all-articulation-commands ()
    (setf score
         (remove-if #'articulation-p score)))

(defun articulation-p (input)
    (member (first input) LIST-OF-ALL-ARTICULATIONS))

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;            RHYTHM FUNCTIONS
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&





(defun add-note-off-commands ()
 (let ((note-off-list ()))
;
;    adds a "note-off" command for each "note" command
;      we're going to sort everything later, so we don't need to
;      put the note-offs in any particular place.  we'll just 
;      append them at the end.
;
  (dotimes (note-counter (length score))
     (let  ((this-note (nth note-counter score))
            (note-off ()))
       (if 
         (eq (nth COMMAND-TYPE-PAR this-note) 'note)
             (progn
                (setf note-off (list
;           midi-channel:
                     (nth MIDI-CHANNEL-PAR this-note)
;           end measure:
                     (nth END-MSR-PAR this-note)
;           end beat:
                     (nth END-BEAT-PAR this-note)
;           end division:
                     (nth END-DIV-PAR this-note)
                     'note-off
;           midi-note:
                     (first (last this-note 2))))
                (setf note-off-list (append note-off-list
                     (list note-off)))))))
  (setf score (append score note-off-list))))








;
;   creates a separate meter-change entry for each measure.
;   meter-struct is changed to the form:  tick #-of-beats size/type-of-beat
;     (example):   ((0 4 4) (3840 4 4) (7680 4 4) 
;                   (11520 4 4) (15360 3 8) (16800 3 8))
;
(defun expand-meters-and-add-ticks ()
  (let ((output-list ())
        (current-tick 0)
        (current-bar ())
       )
;
;   create a separate entry for every measure.
;
    (dolist (elle meter-struct)
        (setf output-list (append output-list
            (make-list (first elle) :initial-element (rest elle)))))
;     add an extra bar at the end, in case any notes last 
;            to the first beat of that bar.
    (setf output-list (append output-list
          (last output-list)))
    (setf meter-struct output-list)
;
;   now add tick value for beginning of given measure
;
    (dotimes (measure-pointer (length meter-struct))
;   first add tick value for beginning of this bar
       (setf current-bar (nth measure-pointer meter-struct))
       (setf  (nth measure-pointer meter-struct) 
          (append (list current-tick) 
              current-bar))
;
;   now, update current-tick  
;              = current-tick + 
;                 (#-of-beats * ( 1 / (2nd-number-in-meter / 4) ) * ticks-per-beat
;
       (setf current-tick 
          (+ current-tick
             (* (first current-bar) 
                (/  4 (second current-bar))
                TICKS-PER-BEAT))))))
;
;
;





(defun replace-all-times-in-score-with-ticks ()
      (let ((this-note ())  (this-msr 0)
            (this-beat 0)   (this-div 0)
            (this-meter ()) (basic-beat-in-quarters 0.0)
            (this-tick-value '0))
      (dotimes (note-counter (length score))
          (setf this-note (nth note-counter score))
          (setf this-msr  (nth MSR-PAR  this-note))
          (setf this-beat (nth BEAT-PAR this-note))
          (setf this-div  (nth DIV-PAR  this-note))
          (setf this-meter (nth this-msr meter-struct))
          (setf basic-beat-in-quarters (/ 4.0 (third this-meter)))
          (setf this-tick-value
;  tick value of beginning of measure:
            (truncate
              (+ (first (nth this-msr meter-struct)) 
;  of beginning of beat:
                 (* basic-beat-in-quarters this-beat TICKS-PER-BEAT)
                 (* basic-beat-in-quarters this-div  TICKS-PER-BEAT)))) 
          (setf (nth TICK-TIME-PAR this-note) this-tick-value)
          (setf (nth note-counter score) this-note)))) 





(defun sort-score-by-channel-and-time ()
   (sort 
       (sort score #'compare-tick-times)
       #'compare-chans))



(defun compare-tick-times (input1 input2)
    (< (nth TICK-TIME-PAR input1)  (nth TICK-TIME-PAR input2)))


(defun compare-chans (input1 input2)
    (< (nth MIDI-CHANNEL-PAR input1) (nth MIDI-CHANNEL-PAR input2)))






;
;       all tempo and meter changes will go into the first "intro" track:
;       format of the actual tempo and meter changes should be as given 
;        [all the way down] below for
;        function "add-tempo-change" and "add-meter-change"
;
;       the following adds the tempo changes to the meter-change list.
;        it also changes the tempo-change times to ticks.
;        the result should be sorted.
;
;
;
;
(defun combine-tempo-changes-and-meter-changes ()
; 
       (add-ticks-to-tempo-struct)
;  now add labels to the ends of elements from both lists,
;    so we'll be able to tell "meter" commands from "tempo"
;   commands:
       (add-tempo-labels)
       (add-meter-labels)   
       (setf final-rhythm-list 
           (append meter-struct tempo-struct))
       (setf final-rhythm-list
           (sort final-rhythm-list #'compare-rhythm-tick-times)))



(defun compare-rhythm-tick-times (input1 input2)
    (< (first input1)  (first input2)))



(defun add-ticks-to-tempo-struct ()
   (let ((this-tempo-change ())  (this-msr 0)
            (this-beat 0)   (this-div 0)
            (this-meter ()) (this-tempo ()) (basic-beat-in-quarters 0.0)
            (this-tick-value '0))
;
;  put ticks with the tempo-changes.
        (dotimes (tempo-change-counter (length tempo-struct))
          (setf this-tempo-change (nth tempo-change-counter tempo-struct))
          (setf this-msr  (nth 0 this-tempo-change))
          (setf this-beat (nth 1 this-tempo-change))
          (setf this-div  (nth 2 this-tempo-change))
          (setf this-tempo (last this-tempo-change 2))
          (setf this-meter (nth this-msr meter-struct))
          (setf basic-beat-in-quarters (/ 4.0 (third this-meter)))
          (setf this-tick-value
;  tick value of beginning of measure:
            (truncate
              (+ (first (nth this-msr meter-struct)) 
;  of beginning of beat:
                 (* basic-beat-in-quarters this-beat TICKS-PER-BEAT)
                 (* basic-beat-in-quarters this-div  TICKS-PER-BEAT)))) 
          (setf (nth tempo-change-counter tempo-struct)
                (append (list this-tick-value) this-tempo)))))




(defun add-tempo-labels ()
    (dotimes (tempo-counter (length tempo-struct))
        (setf (nth tempo-counter tempo-struct)
              (append (nth tempo-counter tempo-struct)
                      (list 'tempo)))))




(defun add-meter-labels ()
    (dotimes (meter-counter (length meter-struct))
        (setf (nth meter-counter meter-struct)
              (append (nth meter-counter meter-struct)
                      (list 'meter)))))






















;#########################################################################################
;###########################################################################################
;##########################################################################################
;##########################################################################################
;#############FILL TRACK-BYTES-LIST FUNCTIONS FILL TRACK-BYTES-LIST FUNCTIONS  ############
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################



(defun process-final-rhythm-list-into-track-bytes-list ()
;;
;
;     go through the final-rhythm-list
;         get each event's delta-time, 
;         its type
;         and its data.
;
   (let ((previous-tick-time 0)
         (delta-time 0)
         (data-list ())
        )
        (dolist (change final-rhythm-list)
            (setf delta-time (- (first change) previous-tick-time))
            (setf data-list (subseq  change 1 3))
            (when (eq (first (last change)) 'tempo)
                  (add-tempo-change delta-time data-list))
            (when (eq (first (last change)) 'meter)
                  (add-meter-change delta-time data-list))
            (setf previous-tick-time (first change)))))





(defun get-track (score track)
   (let ((this-track ()))
       (dolist (note score)
           (setf midi-channel (nth MIDI-CHANNEL-PAR note))
           (if (= midi-channel track)
               (setf this-track
                  (append this-track (list note)))))
       this-track))





(defun process-this-track-score-into-track-bytes-list ()
  (let ((channel (nth MIDI-CHANNEL-PAR (first this-track-score)))
        (previous-tick-time 0)
        (this-tick-time 0))
     (dolist (this-note this-track-score)
;
        (setf this-tick-time (nth TICK-TIME-PAR this-note))
;               is it a 
        (case (nth COMMAND-TYPE-PAR this-note)
;               note on?
           ('note 
               (setf delta-time 
                     (- this-tick-time
                        previous-tick-time))
               (add-pitch-bend-event 
                           delta-time 
                           channel
                           (nth (- (length this-note) 1) this-note)) ; cents adjustment
               (add-midi-channel-event
                           0    ; 0 delta-time relative to pitch-bend command
                           NOTE-ON
                           channel
                           (nth (- (length this-note) 2) this-note) ; midi note
                           (- (nth VELOCITY-PAR this-note) 1)))
;                 note off?
           ('note-off
               (setf delta-time
                     (- this-tick-time
                        previous-tick-time))
               (add-midi-channel-event
                            delta-time
                            NOTE-OFF
                            channel
                            (nth (- (length this-note) 1) this-note) ; midi-note
                            0))
;                program change?
           ('prog
               (setf delta-time
                     (- this-tick-time
                        previous-tick-time))
               (add-prog-change-event
                            delta-time
                            channel
                            (nth PROG-CHANGE-PAR this-note)))
;               controller change?
           ('ctrl
	       (setf delta-time
                     (- this-tick-time
                        previous-tick-time))
               (add-controller-event
                            delta-time
                            channel 
                            (nth CONTROLLER-NUMBER-PAR this-note) 
                            (nth CONTROLLER-VALUE-PAR this-note)
                              ))
;               separate pitch bend event?
           ('bend
	       (setf delta-time
                     (- this-tick-time
                     previous-tick-time))
               (add-pitch-bend-event
                            delta-time
                            channel
                            (nth EXT-PITCH-BEND-VALUE-IN-CENTS-PAR this-note)
                              )))
           (setf previous-tick-time this-tick-time))))
;
;
;
;
;
;
; TEMPO-LIST:
;     tempo-list is in the form:  (60 1/4)  or (80 1/8) or  (50 1/16)
;     (i.e. 60 quarter-notes per minutes, or 80 eighth-notes per minute
;                   or 50 sixteenth-notes per minute)
;
(defun add-tempo-change (delta-time tempo-list)
  (setf track-bytes-list
     (append track-bytes-list
;  delta-time
           (convert-to-var-length-bytes delta-time)               
;   meta-event.  type 81.  length 3.
	   (list 255 81 3)
           (make-3-bytes
;       number of microsecs per quarter note
               (/ 60000000             
;       number of quarter-notes per minute = 1/4 * 1/basic-unit
                   (/ (* (first tempo-list) 4) (/ 1.0 (second tempo-list))))))))







;
; METER-LIST
;     meter-list is in the form:  (4 8) or (5 4) or etc.
;     must be a power-of-two in the denominator
;

(defun add-meter-change (delta-time meter-list)
   (setf track-bytes-list
      (append track-bytes-list
; delta-time
          (convert-to-var-length-bytes delta-time)
          (list

; meter
               255 88 4 (first meter-list) 
                   (log (second meter-list) 2) 
               24 8))))
;





;
;
;
(defun add-midi-channel-event  (delta-time event-type channel par1 par2)
     (setf track-bytes-list
        (append track-bytes-list 
            (convert-to-var-length-bytes delta-time)
            (list
                (+ (* event-type 16) (- channel 1))
                par1  
                par2))))




(defun add-pitch-bend-event (delta-time channel cents)
  (let ((PBV 0))
     (when (or (< cents -199.9999) (> cents 199.9999))
           (progn  (format t "WHOA, TOO BIG PITCH-BEND VALUE!!!!!") (bye)))
     (setf PBV (truncate  (*  (+ cents 200.0) 40.96)))
;   16384 / 400 = 20.48  (setting pitch-bend value)
     (setf track-bytes-list
        (append track-bytes-list
            (convert-to-var-length-bytes delta-time)
            (list
                 (+ 224 (- channel 1)))
;   14 * 16 = 224  (= this is a pitch-bend event)
            (make-two-pitch-bend-bytes PBV)))))



;
;    these only use THREE bytes
;
(defun add-prog-change-event  (delta-time channel prog-number)
     (setf track-bytes-list
        (append track-bytes-list 
            (convert-to-var-length-bytes delta-time)
            (list
                (+ 192 (- channel 1))
;   12(program-change) * 16 = 192
                (- prog-number 1)))))




;  controller:
;     (midi-channel   msr beat div     ctrl   controller#  value)
;                        [[[[[div is
;                            eventually
;                            replaced
;                          internally by
;                            tick-time]]]]]]]
;
;

(defun add-controller-event (delta-time channel controller-number value)
    (setf track-bytes-list
        (append track-bytes-list 
            (convert-to-var-length-bytes delta-time)
            (list
                (+ 176 (- channel 1))
;   11(program-change) * 16 = 176
                controller-number  value))))




;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################
;##########################################################################################




;
;   THINGS TO REMEMBER:
;               be sure to clear track-bytes-list before writing a new track
;           2 types of functions:
;                   1)  writes directly to the file
;                   2)  writes to track-bytes-list
;


;
;   write to a FILE
;
(defun write-smf-header (file format-type number-of-tracks TICKS-PER-BEAT)
;
;       write "Mthd":
    (dolist (elle '(77 84 104 100))
       (write-byte elle file))
;   length of succeeding header stuff:
    (send-bytes '(0 0 0 6) file)
;       write format-type (2 bytes):
    (write-byte 00 file)
    (write-byte format-type file)
;       number-of-tracks (will always be less than 17):
    (write-byte 00 file)
    (write-byte number-of-tracks file)
;       960 ticks per beat:
    (dolist (elle (convert-to-bytes TICKS-PER-BEAT))
         (write-byte elle file)))







;
;  writes a track to a FILE      
;
;        puts end-of-track-marker at the end.
;
(defun write-track (file track-bytes-list)
;
;    the "Mtrk" header
    (dolist (elle '(77 84 114 107))
       (write-byte elle file))
;      length of the list of bytes in this 
;         track + 0 delta-time  + end of track message
    (dolist (elle (convert-to-dword-bytes (+ 4 (length track-bytes-list))))
       (write-byte elle file))
;      send the track data itself:
    (send-bytes track-bytes-list file)
;      send a 0 delta-time
    (send-bytes '(0) file)
;      end of track marker:
    (dolist (elle '(255 47 0))
       (write-byte elle file)))





(defun send-bytes (byte-list file)
    (dolist (elle byte-list)
          (write-byte elle file)))











(defun print-score ()
     (dolist (elle score)
         (format t "~%~a" elle)))

 





;;
;;
;
;   CONVERSION ROUTINES
;
;




(defun convert-to-dword-bytes (decimal-number)
     (let ((outlist ()))
        (setf outlist (convert-to-bytes decimal-number))
        (dotimes (counter (- 4 (length outlist)))
            (setf outlist (cons 0 outlist)))
        outlist))





(defun make-3-bytes (decimal-number)
     (let ((outlist ()))
        (setf outlist (convert-to-bytes decimal-number))
        (dotimes (counter (- 3 (length outlist)))
            (setf outlist (cons 0 outlist)))
        outlist))




(defun make-two-pitch-bend-bytes (decimal-number)
   (let ((outlist ()))
        (setf outlist (convert-to-7-bit-wibbles decimal-number))
        (dotimes (counter (- 2 (length outlist)))
            (setf outlist (cons 0 outlist)))
        (reverse outlist)))




(defun convert-to-var-length-bytes (decimal-number)
    (let ((final-list ())
          (wibbles (convert-to-7-bit-wibbles decimal-number)))
    (dolist (elle wibbles)
          (setf final-list (append final-list (list
             (+ elle 128)))))
    (setf (nth (- (length final-list) 1) final-list)
          (- (nth (- (length final-list) 1) final-list)
             128))
    final-list))




;
;  outputs a list of decimally-notated 7-bit (i.e. < 128) wibbles
;
;
(defun convert-to-7-bit-wibbles (decimal-number)
  (let ((deci-list ())
        (pow-of-128 0)
        )
;;  first,
;; find the biggest power of 256 smaller than the number
       (loop
          (if (> (expt 128 (+ pow-of-128 1)) decimal-number)
              (return ()))
          (setf pow-of-128 (+ pow-of-128 1)))
;
;  remember pow-of-256 is just an exponent
;
; now work downwards.
; make a list of decimal numbers to be
; converted to a single hexidecimal digit.
;
       (loop
          (setf deci-list (append deci-list (list
             (truncate
                (/ decimal-number 
                   (expt 128 pow-of-128))))))
          (setf decimal-number
             (- decimal-number 
                (*
                  (truncate
                     (/ decimal-number 
                       (expt 128 pow-of-128)))
                  (expt 128 pow-of-128))))
          (setf pow-of-128 (- pow-of-128 1))
          (when (< pow-of-128 0) (return)))
;
       deci-list))


    
 



;
;
;   outputs a list of decimally-notated bytes
;
;
(defun convert-to-bytes (decimal-number)
  (let ((deci-list ())
        (hexi-list ())
        (pow-of-256 0)
        )
;;  first,
;; find the biggest power of 256 smaller than the number
       (loop
          (if (> (expt 256 (+ pow-of-256 1)) decimal-number)
              (return ()))
          (setf pow-of-256 (+ pow-of-256 1)))
;
;  remember pow-of-256 is just an exponent
;
; now work downwards.
; make a list of decimal numbers to be
; converted to a single hexidecimal digit.
;
       (loop
          (setf deci-list (append deci-list (list
             (truncate
                (/ decimal-number 
                   (expt 256 pow-of-256))))))
          (setf decimal-number
             (- decimal-number 
                (*
                  (truncate
                     (/ decimal-number 
                       (expt 256 pow-of-256)))
                  (expt 256 pow-of-256))))
          (setf pow-of-256 (- pow-of-256 1))
          (when (< pow-of-256 0) (return)))
;
       deci-list))










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;
;      beginning of the first or INTRO track
;      beginning of the first or INTRO track
;      beginning of the first or INTRO track
;      beginning of the first or INTRO track
;  writes to track-bytes-list
;
(defun old-add-beginning-of-intro-track (tempo-list meter-list)
;  tempo
    (add-tempo-change 0 tempo-list)
    (add-meter-change 0 meter-list)
    (setf track-bytes-list 
      (append track-bytes-list
          (list
;  delta-time:
             0
;  TITLE INFO: 
;    meta-event:
             255
;  type:
             1)
;  length is variable-length:
          (convert-to-var-length-bytes 44)
;  this is ASCII for "Made with Chris Bailey's MicroMidi program."  :
         '(77  97 100 101  32 119 105 116 104  32  67 104 114 105 115  32
             66  97 105 108 101 121  39 115  32  77 105  99 114 111  77 105
             100 105  32 112 114 111 103 114  97 109  46  10))))











(defun oldmain ()
  (with-open-file (blablastream "blabla.mid" :direction :output 
                                 :element-type 'unsigned-byte)
    (setf track-bytes-list ())

    (write-smf-header blablastream 1 2 TICKS-PER-BEAT)

;  this writes the 1st, introductory track
    (add-beginning-of-intro-track '(60 1/4) '(4 4) )
    (write-track blablastream track-bytes-list)

;  this writes the second (and succeeding) trakcs with notes.
    (setf track-bytes-list ())
    (setf track-bytes-list
           '(135 64 145 60 60 135 64 129 60 0))

    (add-midi-channel-event 960 NOTE-ON 1 61 100)
    (add-midi-channel-event 960 NOTE-OFF 1 61 0)

    (add-pitch-bend-event 960 1 50)  
    (add-midi-channel-event 0 NOTE-ON 1 61 100)
    (add-midi-channel-event 960 NOTE-OFF 1 61 0)
    

    (write-track blablastream track-bytes-list)
  )
)



(main)
(bye)

