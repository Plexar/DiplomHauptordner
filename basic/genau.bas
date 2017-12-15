100 REM genau.bas
110 REM
120 REM Frage: Wie weit muessen die Potenzreihen im Algorithmus von
130 REM        Borodin, von zur Gathen und Hopcroft entwickelt werden?
140 REM
150 DEFDBL "A-Z"
160 INPUT "Stellen? ";S#
170 IF S#>19 THEN PRINT "zu gross": END
180 FOR I#=1 TO S#
190 :A#=10^(-I#)
200 :B#=1-A#
210 :Z#=1
220 ::B#=B#*B#
230 ::Z#=Z#+1
240 :: IF B#>=A# THEN GOTO 220
250 :F#=6+4*(I#-1)
260 : PRINT "Stellen: ";I#;"   Potenz: ";Z#;
270 : PRINT "   6+4*(";I#;"-1)= ";F#;"   Differenz ";F#-Z#
280 NEXT I#
