; a bunch of CMIX (and generic) utility functions for gcl
; BGG


(defun vi(file) (system (concatenate 'string "vi " file)))

(defun outfile(file) (open file :direction :output))

(defun infile(file) (open file :direction :input))

(defun cmix-print(command params &optional file)
	(cond ((not (null file)) (princ command file)
			(princ (commaize params) file) (terpri file) )
		(t (princ command) (princ (commaize params)) (terpri) )
		)
)

(defun commaize(lst) (prog()
	(cond ((null (cdr lst)) (return lst))
		(t (return (append
			(cons (car lst) '(\,)) (commaize (cdr lst))) ) )
		)
	)
)

(defun put(sym ind val)
	(setf (get sym ind) val)
)

(defun put-plist(sym lst)
	(setf (symbol-plist sym) lst)
)

(defun explode(sym) (prog(str)
	(setq str (make-string-input-stream (string sym)))
	(return (collectem str))
	)
)

(defun collectem(st) (prog(ch)
	(cond ((null (setq ch (read-char st nil))) (return nil))
		(t (return (cons (objectify ch) (collectem st))) )
		)
	)
)

(defun objectify(c)
	(read (make-string-input-stream (string c)))
)

(defun make-list-line(str) (prog(st)
	(setq st (make-string-input-stream str))
	(return (list-stream st))
	)
)

(defun list-stream(s) (prog(el)
	(cond ((null (setq el (read s nil))) (return nil))
		(t (return (cons el (list-stream s))) )
		)
	)
)

(defun getel(l)
	(nth (random (length l)) l))

(defun frandom(num) (prog(mnum)
	(setq mnum (* 1000 num))
	(return (/ (random mnum) 1000.0))
	)
)

(defun const-frandom(val1 val2) (prog()
	(return (+ (frandom (- val2 val1)) val1))
	)
)

(defun mus-add(n val) (prog(tval)
	(setq tval (+ n val))
	(cond ((> tval n) (return tval))
		((>= (- tval (truncate n)) 0) (return tval))
		(t (setq tval (- n (truncate n)))
			(setq tval (+ val tval))
			(return (mus-add (+ .12 (- (truncate n) 1.00)) tval)))
		)
	)
)
