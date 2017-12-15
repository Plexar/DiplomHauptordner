10 REM
20 REM Datei: berk1.bas
30 REM Datum: 20.04.92
40 REM
50 REM Test von f(m) (epsilon fuer m<=n-3)
60 REM     sowie
70 REM eines Teils der Ableitung der zugehoerigen Formel
80 REM
90 REM Testergebnis: Abschaetzung der Gausklammern durch zusaetzlichen
100 REM              Summand '+1' ist zu ungenau
110 REM
120 DEFSNG "A-Z"
130 PRINT @(24,0)
140 PRINT "*************"
150 PRINT "Ableitung t_3"
160 PRINT "*************"
170 PRINT
180 INPUT "n=";N!
190 IF N!<4 THEN PRINT "???(n<4)": GOTO 170
200 INPUT "gamma=";Gamma!
210 INPUT "epsilon=";Epsilon!
220 FOR M!=1 TO N!-3
230 :: REM *** berechne f(m) mit 'Gaussklammer-Log' ***
240 ::Gc!=FN Glog!(N!-2)^2+(2+1/Epsilon!)*FN Glog!(N!-2)+1/Epsilon!
250 ::Gnennerf!=Gc!-FN Glog!(M!)^2-2*FN Glog!(M!)
260 ::Gf!=(FN Glog!(M!)+1)/Gnennerf!
270 :: GOTO 310: REM *** berechne f(m) ***
280 ::Cf!= LOG(2,N!-2)^2+(2+1/Epsilon!)* LOG(2,N!-2)+1/Epsilon!-3
290 ::Nennerf!=Cf!- LOG(2,M!)^2-4* LOG(2,M!)
300 ::F!=( LOG(2,M!)+2)/Nennerf!
310 :: REM *** berechne f(m) ohne Gaussklammern und ohne ***
320 :: REM ***     Abschaetzung der Gaussklammern        ***
330 ::Oc!= LOG(2,N!-2)^2+(2+1/Epsilon!)* LOG(2,N!-2)+1/Epsilon!
340 ::Onennerf!=Oc!- LOG(2,M!)^2-2* LOG(2,M!)
350 ::Of!=( LOG(2,M!)+1)/Onennerf!
360 :: GOTO 450: REM *** berechne t3(m) ***
370 ::C!=( LN(N!-2))^2/ LN(2)+(2+1/Epsilon!)* LN(N!-2)+(1/Epsilon!-3)* LN(2)
380 ::T3zaehlera1!=2* LN(M!)/M!+2* LN(2)/M!
390 ::T3zaehlera2!=C!-( LN(M!))^2/ LN(2)-4* LN(M!)
400 ::T3zaehlera3!=( LN(M!))^2+2* LN(2)* LN(M!)
410 ::T3zaehlera4!=2* LN(M!)/( LN(2)*M!)-4/M!
420 ::T3zaehler!=T3zaehlera1!*T3zaehlera2!-T3zaehlera3!*T3zaehlera4!
430 ::T3nenner!=T3zaehlera2!^2
440 ::T3all!=2/M!+Gamma!/M!+T3zaehler!/T3nenner!: REM 't3all' enthaelt Ergebnis
450 :: REM *** gib die Ergebnisse aus ***
460 :: PRINT @(24,0);"m=";M!;
470 :: PRINT @(24,7);"of(m)=";Of!;
480 :: PRINT @(24,31);"gf(m)=";Gf!;
490 ::Mycol!=26
500 :: IF Of!<Gf! THEN
510 :::: PRINT @(24,Mycol!);"<";
520 :: ELSE
530 :::: IF Of!=Gf! THEN PRINT @(24,Mycol!);"==="; ELSE PRINT @(24,Mycol!);"  >";
540 :: ENDIF
550 :: IF FRAC( LOG(2,M!))=0 THEN PRINT
560 :: PRINT
570 NEXT M!
580 END
590 DEF FN Glog!(X!)
600 :: LOCAL Hilf1!= LOG(2,X!)
610 :: LOCAL Erg!
620 :: IF FRAC(Hilf1!)<>0 THEN Erg!= INT(Hilf1!+1) ELSE Erg!=Hilf1!
630 RETURN Erg!
