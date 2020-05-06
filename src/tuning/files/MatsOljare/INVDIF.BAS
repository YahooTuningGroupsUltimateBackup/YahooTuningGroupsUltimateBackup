

SCREEN 12
CLS

t = 120
tv = 480 - t
ti = 1 / t

LINE (160, 0)-(160, 480), 8
LINE (320, 0)-(320, 480), 8
LINE (480, 0)-(480, 480), 8
LINE (0, 120)-(640, 120), 8
LINE (0, 240)-(640, 240), 8
LINE (0, 360)-(640, 360), 8

FOR x = 1 TO 640

y = x * .75

LINE (x, tv)-(x, tv), 15

LINE (x, 480 - y)-(x, 480 - y), 2

s = 480 - (y + t)
d = 480 - (ABS(y - t))
si = 480 - (ABS(1 / ((1 / y) + ti)))
di = 480 - (ABS(1 / ((1 / y) - ti)))


LINE (x, s)-(x, s), 1
LINE (x, d)-(x, d), 4


IF si >= 0 THEN LINE (x, si)-(x, si), 11
IF di >= 0 THEN LINE (x, di)-(x, di), 13


NEXT x

p:
IF INKEY$ = "" GOTO p
END

