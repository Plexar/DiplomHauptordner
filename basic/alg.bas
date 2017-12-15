100 REM
110 REM Datei: alg.bas
120 REM
130 REM Implementierung der Algorithmen fuer 3*3-Matrizen
140 REM
150 REM Wegen der Beschraenkte Moeglichkeiten von BASIC muss dieses Programm
160 REM unvollendet bleiben und in Modula-2 implementiert werden.
170 DEFDBL "A-Z"
180 N#=3: REM Anzahl der Zeilen und Spalten einer Matrix
190 DIM A#(N#-1,N#-1)
200 PRINT : PRINT "*** Test aller Algorithmen ***": PRINT
210 REPEAT
220 : INPUT "Eingabe (0: Ende; 1: Hilfe)? ";Eingabe#
230 : ON Eingabe#+1 GOTO 710,350,270,470,500,530,560,590,630
240 REM Befehl unbekannt
250 : PRINT "Befehl unbekannt"
260 : GOTO 710
270 REM Matrix eingeben
280 : FOR I#=0 TO N#-1
290 :: PRINT "Zeile";I#;"?   "
300 :: FOR J#=0 TO N#-1
310 ::: INPUT A#(I#,J#)
320 :: NEXT J#
330 : NEXT I#
340 : GOTO 710
350 REM Hilfe
360 : PRINT "*** Hilfe ***"
370 : PRINT "0:  Ende"
380 : PRINT "1:  Hilfe"
390 : PRINT "2:  Matrix eingeben"
400 : PRINT "3:  Alg. v. Csanky"
410 : PRINT "4:  Alg. v. Borodin, von zur Gathen und Hopcroft"
420 : PRINT "5:  Alg. v. Berkowitz"
430 : PRINT "6:  Alg. v. Pan"
440 : PRINT "7:  Basic-Funktion"
450 : PRINT "8:  Matrix anzeigen"
460 : GOTO 710
470 REM Alg. v. Csanky
480 : PRINT "*** Alg. v. Csanky ***"
490 :Csanky: GOTO 710
500 REM Alg. v. Borodin, von zur Gathen und Hopcroft
510 : PRINT "*** Alg. v. Borodin, von zur Gathen und Hopcroft ***"
520 :Bgh: GOTO 710
530 REM Alg. v. Berkowitz
540 : PRINT "*** Alg. v. Berkowitz *** "
550 :Berk: GOTO 710
560 REM Alg. v. Pan
570 : PRINT "*** Alg. v. Pan ***"
580 :Pan: GOTO 710
590 REM Basic-Funktion
600 : PRINT "*** Basic-Funktion ***"
610 : PRINT DET(A#(N#-1,N#-1))
620 : GOTO 710
630 REM Matrix anzeigen
640 : PRINT "*** Matrix anzeigen ***"
650 : FOR I#=0 TO N#-1
660 :: FOR J#=0 TO N#-1
670 ::: PRINT A#(I#,J#);
680 :: NEXT J#
690 :: PRINT
700 : NEXT I#
710 UNTIL Eingabe#=0
720 END
730 REM ***********
740 DEF PROC Csanky
750 REM ***********
760 LOCAL Erg#
770 RETURN
780 REM ********
790 DEF PROC Bgh
800 REM ********
810 RETURN
820 REM *********
830 DEF PROC Berk
840 REM *********
850 RETURN
860 REM ********
870 DEF PROC Pan
880 REM ********
890 RETURN
900 REM ********
910 DEF FN Trace#(B#(N#,N#))
920 REM ********
930 LOCAL Erg#
940 :Erg#=0
950 : FOR I#=0 TO N#-1
960 ::Erg#=Erg#+A#(I#,I#)
970 : NEXT I#
980 RETURN Erg#
