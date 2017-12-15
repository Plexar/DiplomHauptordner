(* ###GrepMarke###
\begin{ProgModul}{algtest}
\begin{verbatim}
   ###GrepMarke### *)

MODULE algtest;

(*  Test der Algorithmen fuer 3*3--Matrizen

In diesem Testprogramm wird keine R"ucksicht auf Anforderungen an
die Implementierung genommen. Insbesondere wird die Parallelisierung
nicht beachtet.

*)

FROM InOut IMPORT ReadString, WriteString, WriteLn, ReadLReal, WriteReal,
                  ReadCard, WriteCard;
IMPORT Files, NumberIO, Text;
FROM MathLib0 IMPORT log, power;

CONST n= CARDINAL(3);
             (* Anzahl der Zeilen und Spalten, die die Testmatrix hat *)
      nMax= n+1;
             (* Anzahl der Zeilen und Spalten, die eine Matrix maximal
                haben kann *)
      myfile= "algtest.inf";
             (* Datei, in der die Testmatrix gespeichert wird
                (damit sie nicht staendig neu eingegeben werden muss) *)

      BerkDebug= FALSE;
             (* TRUE: Algorithmus von 'Berkowitz' liefert Testausgaben *)

      (********************************************************)
      (* Konstanten fuer den Alg. von Borodin, von zur Gathen *)
      (* und Hopcroft:                                        *)

      SerMax = n;
             (* maximaler Grad der homogenen Komponenten, die fuer die
                Potenzreihen betrachtet werden *)
      cBGHNoDebug= 3;
             (* Debug-Ebene, fuer die der Alg. keine Testausgaben
                liefert *)
      cBGHDebug= 3;
             (* cBGHDebug < cBGHNoDebug:
                    Alg. liefert Testausgaben *)
      BGHRadius= 1.0;
             (* angenommener Konvergenzradius der Potenzreihen;
                theoretisch ist hier nur der Wert 1.0 richtig *)

      (*************************************)
      (* Konstanten fuer den Alg. von Pan: *)

      PanDebug= TRUE;
             (* TRUE: Alg. liefert Testausgaben *)
      PanLoops= 15;
             (* Anzahl der Iterationen zur Verbesserung der
                Naeherungsinversen *)

TYPE tMat = RECORD (* Matrix aus Fliesskommazahlen *)
                r, c: CARDINAL; (* Rows, Columns *)
                v: ARRAY [1..nMax],[1..nMax] OF LONGREAL; (* Values *)
            END;
     tSer = ARRAY [0..SerMax] OF LONGREAL; (* eine Potenzreihe *)
     tSerMat = RECORD (* Matrix aus Potenzreihen *)
                   r, c: CARDINAL; (* Rows, Columns *)
                   v: ARRAY [1..nMax],[1..nMax] OF tSer
               END;

VAR a: tMat; (* Matrix, deren Determinante zu Berechnen ist *)
    eingabe: CARDINAL; (* Befehl des Benutzers an das Programm *)

    BGHDebug: CARDINAL;
             (* BGHDebug < cBGHNoDebug:
                    Algorithmus von 'Borodin, von zur Gathen und
                    Hopcroft' liefert Testausgaben; je kleiner
                    BGHDebug, umso mehr Testausgaben werden geliefert
             *)

(* zur Fehlersuche: *)
PROCEDURE Wait;
(* Die Prozedur wartet auf das Betraetigen der RETURN-Taste *)
VAR dummy: ARRAY [1..3] OF CHAR;
BEGIN
    ReadString(dummy);
END Wait;

PROCEDURE l(line: ARRAY OF CHAR);
(* Prozedur zur vereinfachten Schreibweise *)
BEGIN
    WriteString(line); WriteLn
END l;

PROCEDURE Hilfe;
(* Es wird eine Liste der Eingabemoeglichkeiten (Befehle an das Programm)
   ausgegeben. *)
BEGIN
    l("*** Hilfe ***");
    l("0: Ende");
    l("1: Hilfe");
    l("2: Matrix eingeben");
    l("3: Matrix ausgeben");
    l("4: Alg. v. Csanky");
    l("5: Alg. v. Borodin, von zur Gathen und Hopcroft");
    l("6: Alg. v. Berkowitz");
    l("7: Alg. v. Pan");
    l("8: Trivialmethode")
END Hilfe;
    
(**************************************************************************)

PROCEDURE WriteFile(a: tMat);
(* Die Matrix 'a' wird in der durch die Konstante 'myfile' angegebenen
   Datei abgelegt. *)
VAR f: Files.File;
    i,j: CARDINAL;
BEGIN
    Files.Create(f, myfile, Files.writeSeqTxt, Files.replaceOld);
    FOR i:= 1 TO n DO
        FOR j:= 1 TO n DO
            NumberIO.WriteReal(f, a.v[i,j],20,10); Text.WriteLn(f)
        END
    END;
    Files.Close(f);
END WriteFile;

PROCEDURE Exist(name: ARRAY OF CHAR): BOOLEAN;
(* Falls die Datei mit dem Namen 'name' existiert, wird TRUE zurueck-
   gegeben, sonst FALSE. *)
VAR f: Files.File;
    IsPresent: BOOLEAN;
BEGIN
    Files.Open(f, name, Files.readSeqTxt);
    IsPresent:= Files.State(f) >= 0;
    IF IsPresent THEN
        Files.Close(f)
    END;
    RETURN IsPresent
END Exist;

PROCEDURE ReadFile(VAR a: tMat);
(* Die Matrix, die in der Datei abgelegt ist, die die Konstante 'myfile'
   angibt, wird eingelesen und in 'a' zurueckgegeben. *)
VAR f: Files.File;
    i,j: CARDINAL;
    dummy: BOOLEAN;
BEGIN
    a.r:= n; a.c:= n;
    IF Exist(myfile) THEN
        Files.Open(f, myfile, Files.readSeqTxt);
        FOR i:= 1 TO n DO
            FOR j:= 1 TO n DO
                NumberIO.ReadLReal(f, a.v[i,j], dummy)
            END
        END;
        Files.Close(f)
    ELSE
        FOR i:= 1 TO n DO
            FOR j:= 1 TO n DO
                a.v[i,j]:= 0.0
            END
        END
    END
END ReadFile;

PROCEDURE ReadMat(VAR a: tMat);
(* Es wird zeilenweise eine Matrix vom Benutzer eingelesen und in 'a'
   zurueckgegeben. *)
VAR i,j: CARDINAL;
BEGIN
    FOR i:= 1 TO n DO
        WriteString("Zeile "); WriteCard(i,0); WriteString(":"); WriteLn;
        FOR j:= 1 TO n DO
            ReadLReal(a.v[i,j])
        END;
        WriteLn
    END;
    WriteFile(a)
END ReadMat;

PROCEDURE WriteMat(a: tMat);
(* Die Matrix 'a' wird auf den Bildschirm ausgegeben. *)
VAR i,j: CARDINAL;
BEGIN
    FOR i:= 1 TO a.r DO
        FOR j:= 1 TO a.c DO
            WriteReal(a.v[i,j],20,10); WriteString("   ")
        END;
        WriteLn
    END
END WriteMat;

PROCEDURE Check(prop: BOOLEAN);
(* Bei 'prop = FALSE' wird das Programm abgebrochen. *)
BEGIN
    IF NOT prop THEN
        HALT
    END
END Check;

(**************************************************************************)

PROCEDURE Trace(a: tMat): LONGREAL;
(* Es wird die Spur der Matrix 'a' berechnet und als Funktionswert zurueck-
   gegeben. *)
VAR erg: LONGREAL;
    i: CARDINAL;
BEGIN
    FOR i:= 1 TO a.r DO
        erg:= erg + a.v[i,i]
    END;
    RETURN erg
END Trace;

PROCEDURE MatClear(VAR a: tMat; r, c: CARDINAL);
(* Die Matrix 'a' wird initialisiert (mit Nullen gefuellt). Als neue Anzahl
   der Zeilen wird 'r' festgesetzt. Als neue Anzahl der Spalten wird 'c'
   festgesetzt. *)
VAR i,j: CARDINAL;
BEGIN
    a.r:= r; a.c:= c;
    FOR i:= 1 TO nMax DO
        FOR j:= 1 TO nMax DO
            a.v[i,j]:= 0.0
        END
    END
END MatClear;

PROCEDURE MatAssign(a: tMat; VAR b: tMat);
(* In Matrix 'b' wird der Inhalt von Matrix 'a' zurueckgegeben. *)
VAR i,j: CARDINAL;
BEGIN
    FOR i:= 1 TO nMax DO
        FOR j:= 1 TO nMax DO
            b.v[i,j]:= a.v[i,j]
        END
    END;
    b.r:= a.r;
    b.c:= a.c;
END MatAssign;

PROCEDURE MatAdd(a,b: tMat; VAR c: tMat);
(* In Matrix 'c' wird die Summe der Matrizen 'a' und 'b' zurueckgegeben. *)
VAR i,j: CARDINAL;
BEGIN
    Check( (a.r = b.r) AND (a.c = b.c) );
    FOR i:= 1 TO a.r DO
        FOR j:= 1 TO a.c DO
            c.v[i,j]:= a.v[i,j] + b.v[i,j]
        END
    END;
    c.r:= a.r; c.c:= a.c
END MatAdd;

PROCEDURE MatSub(a,b: tMat; VAR c: tMat);
(* In 'c' wird die Differenz der Matrizen 'a' und 'b' zurueckgegeben.
   (a - b) *)
VAR i,j: CARDINAL;
BEGIN
    Check( (a.r = b.r) AND (a.c = b.c) );
    FOR i:= 1 TO n DO
        FOR j:= 1 TO n DO
            c.v[i,j]:= a.v[i,j] - b.v[i,j]
        END
    END;
    c.r:= a.r; c.c:= a.c
END MatSub;

PROCEDURE MatUnit(VAR a: tMat; r, c: CARDINAL);
(* In 'a' wird eine Matrix mit 'r' Zeilen und 'c' Spalten zurueckgegeben,
   die in der Hauptdiagonalen Einsen und sonst nur Nullen enthaelt. *)
VAR i,j: CARDINAL;
BEGIN
    a.r:= r; a.c:= c;
    FOR i:= 1 TO nMax DO
        FOR j:= 1 TO nMax DO
            IF i=j THEN
                a.v[i,j]:= 1.0
            ELSE
                a.v[i,j]:= 0.0
            END
        END
    END
END MatUnit;

PROCEDURE MatMult(a,b: tMat; VAR c: tMat);
(* In 'c' wird das Produkt der Matrizen 'a' und 'b' zurueckgegeben. *)
VAR i,j,k: CARDINAL;
BEGIN
    Check( a.c = b.r );
    FOR i:= 1 TO a.r DO
        FOR j:= 1 TO b.c DO
            c.v[i,j]:= 0.0;
            FOR k:= 1 TO a.c DO
                c.v[i,j]:= c.v[i,j] + a.v[i,k] * b.v[k,j]
            END
        END
    END;
    c.r:= a.r; c.c:= b.c
END MatMult;

PROCEDURE MatXMult(a: tMat; x: LONGREAL; VAR c: tMat);
(* In 'c' wird das Produkt der Matrix 'a' mit der Zahl 'x'
   zurueckgegeben. *)
VAR i,j: CARDINAL;
BEGIN
    FOR i:= 1 TO a.r DO
        FOR j:= 1 TO a.c DO
            c.v[i,j]:= a.v[i,j] * x
        END
    END;
    c.r:= a.r; c.c:= a.c
END MatXMult;

(**************************************************************************)

PROCEDURE Csanky(a: tMat): LONGREAL;
(* Als Funktionswert wird die Determiante der Matrix 'a' berechnet nach
   dem Algorithmus von Csanky (Frame) zurueckgegeben. *)
VAR b0: tMat;
    z: CARDINAL;
    aSubUnit, unit: tMat;
BEGIN
    MatUnit(b0,n,n);
    FOR z:= n-1 TO 1 BY -1 DO
        MatAssign(a, aSubUnit);
        MatUnit(unit,n,n);
        MatXMult(unit, 1.0/LFLOAT(z), unit);
        MatXMult(unit, Trace(a), unit);
        MatSub(aSubUnit, unit, aSubUnit);
        
        MatMult(b0, aSubUnit, b0)
    END;
    MatMult(a, b0, b0);
    RETURN Trace(b0) / LFLOAT(n)
END Csanky;

(**************************************************************************)

PROCEDURE SerClear(VAR a: tSer);
(* Die Potenzreihe 'a' wird geloescht. *)
VAR k: CARDINAL;
BEGIN
    FOR k:= 0 TO SerMax DO
        a[k]:= 0.0
    END
END SerClear;

PROCEDURE SerWrite(a: tSer);
(* Die Potenzreihe 'a' wird auf den Bildschirm ausgegeben. *)
VAR k: CARDINAL;
BEGIN
    FOR k:= 0 TO SerMax DO
        WriteCard(k,4); WriteString(": ");
        WriteReal(a[k],20,10);
        IF k MOD 3 = 0 THEN
            WriteLn
        END
    END;
END SerWrite;

PROCEDURE SerMatWrite(VAR a: tSerMat);
(* Die Potenzreihenmatrix 'a' wird interaktiv auf den Bildschirm ausgegeben.
   Der Benutzer kann die Position der Potenzreihe in der Matrix bestimmen,
   die ausgegeben werden soll. Bei einer Eingabe von 0 wird die Prozedur
   verlassen. *)
VAR i,j: CARDINAL;
BEGIN
    WriteString("SerMatWrite (0: Ende)"); WriteLn;
    LOOP
        WriteString("Zeile ? "); ReadCard(i);
        IF i=0 THEN RETURN END;
        WriteString("Spalte? "); ReadCard(j);
        IF j=0 THEN RETURN END;
        IF (i <= a.r) AND (j <= a.c) THEN
            SerWrite(a.v[i,j])
        END
    END
END SerMatWrite;

PROCEDURE SerEval(ser: tSer): LONGREAL;
(* Die einzelnen Komponenten der Potenzreihe 'ser' werden addiert. Das
   Ergebnis wird als Funktionsergebnis zurueckgegeben. *)
VAR k: CARDINAL;
    res: LONGREAL;
BEGIN
    res:= 0.0;
    FOR k:= 0 TO SerMax DO
        res:= res + ser[k]
    END;
    RETURN res
END SerEval;

PROCEDURE SerAssign(a: tSer; VAR b: tSer);
(* In 'b' wird eine Kopie der Potenzreihe 'a' zurueckgegeben. *)
VAR k: CARDINAL;
BEGIN
    FOR k:= 0 TO SerMax DO
        b[k]:= a[k]
    END
END SerAssign;

PROCEDURE SerAdd(a,b: tSer; VAR c: tSer);
(* Die Potenzreihen 'a' und 'b' werden addiert. Das Ergebnis wird in 'c'
   zurueckgegeben. *)
VAR k: CARDINAL;
BEGIN
    FOR k:= 0 TO SerMax DO
        c[k]:= a[k] + b[k]
    END;
    
    (* Fehlersuche: *)
    IF BGHDebug = 0 THEN
        WriteString("SerAdd: 1.Summand ausgewertet: ");
        WriteReal(SerEval(a), 10, 5); WriteLn;
        WriteString("    2. Summand ausgewertet: ");
        WriteReal(SerEval(b), 10, 5); WriteLn;
        WriteString("Ergebnis ausgewertet: ");
        WriteReal(SerEval(c), 10, 5); WriteLn;
        WriteString("    Summe d. ausgewerteten Summanden:");
        WriteReal(SerEval(a) + SerEval(b), 10, 5); Wait;
    END;
END SerAdd;

PROCEDURE SerSub(a,b: tSer; VAR c: tSer);
(* Die Potenzreihen 'a' und 'b' werden voneinander subtrahiert (a - b).
   Das Ergebnis wird in 'c' zurueckgegeben. *)
VAR k: CARDINAL;
BEGIN
    FOR k:= 0 TO SerMax DO
        c[k]:= a[k] - b[k]
    END;
    
    (* Fehlersuche: *)
    IF BGHDebug = 0 THEN
        WriteString("SerSub: Subtrahend ausgewertet: ");
        WriteReal(SerEval(a), 10, 5); WriteLn;
        WriteString("    Minuend ausgewertet: ");
        WriteReal(SerEval(b), 10, 5); WriteLn;
        WriteString("Ergebnis ausgewertet: ");
        WriteReal(SerEval(c), 10, 5); WriteLn;
        WriteString("    Diff. d. ausgewerteten Operanden:");
        WriteReal(SerEval(a) - SerEval(b), 10, 5); Wait;
    END;
END SerSub;

PROCEDURE SerMult(a,b: tSer; VAR c: tSer);
(* Die Potenzreihen 'a' und 'b' werden miteinander multipliziert. Das
   Ergebnis wird in 'c' zurueckgegeben. *)
VAR k,l: CARDINAL;
BEGIN
    FOR k:= 0 TO SerMax DO
        c[k]:= 0.0;
        FOR l:= 0 TO k DO
            c[k]:= c[k] + a[l] * b[k-l]
        END
    END;
    
    (* Fehlersuche: *)
    IF BGHDebug = 0 THEN
        WriteString("SerMult: 1.Faktor ausgewertet: ");
        WriteReal(SerEval(a), 10, 5); WriteLn;
        WriteString("    2.Faktor ausgewertet: ");
        WriteReal(SerEval(b), 10, 5); WriteLn;
        WriteString("Ergebnis ausgewertet: ");
        WriteReal(SerEval(c), 10, 5); WriteLn;
        WriteString("    Mult. d. ausgewerteten Faktoren:");
        WriteReal(SerEval(a) * SerEval(b), 10, 5); Wait;
    END;
END SerMult;

PROCEDURE SerXMult(a: tSer; x: LONGREAL; VAR b: tSer);
(* Die Potenzreihe 'a' wird mit der Zahl 'x' multipliziert. Das Ergebnis
   wird in 'b' zurueckgegeben. *)
VAR k: CARDINAL;
BEGIN
    FOR k:= 0 TO SerMax DO
        b[k]:= a[k] * x
    END;
    
    (* Fehlersuche: *)
    IF BGHDebug = 0 THEN
        WriteString("SerXMult: Potenzreihe ausgewertet: ");
        WriteReal(SerEval(a), 10, 5); WriteLn;
        WriteString("    Ergebnis ausgewertet: ");
        WriteReal(SerEval(b), 10, 5);
        WriteString("    Mult. mit ausgewerteter Reihe:");
        WriteReal(SerEval(a) * x, 10, 5); Wait;
    END;
END SerXMult;

PROCEDURE SerDiv(a,b: tSer; VAR c: tSer);
(* Die Potenzreihe 'a' wird durch die Potenzreihe 'b' mit Hilfe des
   Satzes von Taylor dividiert. Dazu muss der konstante Term von 'b'
   gleich '1' sein. *)
VAR factor, b2, power: tSer;
    k: CARDINAL;
BEGIN
    SerClear(c);

    (* Fehlersuche: *)
    IF BGHDebug <= 1 THEN
        WriteString("Dividend (ausgewertet: ");
        WriteReal(SerEval(a),20,10); WriteString("):"); WriteLn;
        SerWrite(a); Wait;
        
        WriteString("Divisor (ausgewertet: ");
        WriteReal(SerEval(b),20,10); WriteString("):"); WriteLn;
        SerWrite(b); Wait
    END;

    BGHDebug:= cBGHNoDebug;

    SerAssign(b, factor);
    factor[0]:= 0.0;
    SerXMult(factor, -1.0, factor);
    
    SerClear(b2);
    b2[0]:= 1.0;
    
    SerAssign(factor, power);
    SerAdd(b2, power, b2);
    FOR k:= 1 TO SerMax-1 DO
        SerMult(power, factor, power);
        SerAdd(b2, power, b2)
    END;
    SerMult(a,b2,c);

    BGHDebug:= cBGHDebug;
       
    (* Fehlersuche: *)
    IF BGHDebug <= 1 THEN
        WriteString("Ergebnis der Division:"); WriteLn;
        SerWrite(c); Wait;

        WriteString("als Zahl: "); WriteReal(SerEval(c),20,10);
        Wait;

        WriteString("Reihen ausgewertet und dividiert: ");
        WriteReal(SerEval(a) / SerEval(b),20,10); Wait;
    END
END SerDiv;

PROCEDURE Kronecker(a,b: CARDINAL): LONGREAL;
(* Diese Prozedur implementiert das Kronecker-Delta. *)
BEGIN
    IF a=b THEN
        RETURN 1.0
    ELSE
        RETURN 0.0
    END
END Kronecker;

PROCEDURE Ceil(a: LONGREAL): LONGREAL;
BEGIN
    IF LFLOAT(TRUNC(a)) # a THEN
        IF a > 0.0 THEN
            a:= LFLOAT(TRUNC(a + 1.0))
        ELSE
            a:= LFLOAT(TRUNC(a))
        END
    END;
    RETURN a
END Ceil;

PROCEDURE Transform(a: tMat; VAR aSer: tSerMat);
(* In 'aSer' wird die der Matrix 'a' entsprechende Potenzreihenmatrix
   zurueckgegeben. *)
VAR i,j: CARDINAL;
    max: LONGREAL;
    LogMax: LONGREAL;
    LineFactor: LONGREAL;
BEGIN
    max:= 0.0;
    FOR i:= 1 TO a.r DO
        FOR j:= 1 TO a.c DO
            IF ABS(a.v[i,j]) > max THEN
                max:= ABS(a.v[i,j])
            END
        END
    END;
    
    aSer.r:= a.r; aSer.c:= a.c;
    FOR i:= 1 TO aSer.r DO
        FOR j:= 1 TO aSer.c DO
            SerClear(aSer.v[i,j]);
            aSer.v[i,j][0]:= Kronecker(i,j);
            aSer.v[i,j][1]:= (-1.0)
                             * (Kronecker(i,j) - a.v[i,j])
        END
    END;
    
    (* Fehlersuche: *)
    IF BGHDebug < cBGHNoDebug THEN
        WriteString("Transform: Test der Transformation... ");
        FOR i:= 1 TO aSer.r DO
            FOR j:= 1 TO aSer.c DO
                IF (SerEval(aSer.v[i,j]) * LineFactor) - a.v[i,j] > 0.00001
                THEN
                    WriteString("FEHLERHAFT   ( Element[");
                    WriteCard(i,0); WriteString(","); WriteCard(j,0);
                    WriteString("] )"); WriteLn;
                    WriteString("    erwartet:"); WriteReal(a.v[i,j],20,10);
                    WriteLn;
                    WriteString("    bekommen:");
                    WriteReal( SerEval(aSer.v[i,j]) * LineFactor, 10, 5);
                    HALT;
                END
            END
        END;
        WriteString("OK"); WriteLn
    END;
END Transform;

PROCEDURE ZeroesInColumn(col: CARDINAL; VAR aSer: tSerMat);
(* Mit Hilfe des Gauss'schen Eliminationsverfahrens werden in Spalte 'col'
   von 'aSer' unterhalb der Hauptdiagonalen Nullen "produziert". *)
VAR LineFactor: tSer;
    multiple: tSer;
    i,j : CARDINAL;
BEGIN
    FOR i:= col+1 TO aSer.r DO
        SerDiv(aSer.v[i,col], aSer.v[col,col], LineFactor);
        FOR j:= col TO aSer.c DO
            SerMult(aSer.v[col,j], LineFactor, multiple);
            SerSub(aSer.v[i,j], multiple, aSer.v[i,j])
        END
    END;
    
    (* Fehlersuche: *)
    IF BGHDebug <= 2 THEN
        WriteString("ZeroesInColumn: "); SerMatWrite(aSer)
    END
END ZeroesInColumn;

PROCEDURE MultDiag(aSer: tSerMat; VAR res: tSer);
(* In 'res' wird die Potenzreihe zurueckgegeben, die durch Multiplikation
   der Elemente der Hauptdiagonalen der Potenzreihenmatrix 'aSer'
   entsteht. *)
VAR k: CARDINAL;
    res2: LONGREAL;
BEGIN
    SerAssign(aSer.v[1,1], res);
    FOR k:= 2 TO aSer.c DO
        SerMult(res, aSer.v[k,k], res)
    END;
    
    (* Fehlersuche: *)
    IF BGHDebug <= 2 THEN
        WriteString("MultDiag: erst ausgewertet und dann multipliziert:");
        res2:= SerEval(aSer.v[1,1]);
        FOR k:= 2 TO aSer.c DO
            res2:= res2 * SerEval(aSer.v[k,k])
        END;
        WriteReal(res2, 10, 5); WriteLn;
        WriteString("    Ergebisreihe ausgewertet: ");
        WriteReal(SerEval(res), 10, 5); WriteLn;
    END
END MultDiag;

PROCEDURE BGH(a: tMat): LONGREAL;
(* Determiantenberechnung mit Hilfe des Algorithmus von 'Borodin, von zur
   Gathen und Hopcroft *)
VAR aSer: tSerMat;
    SerDet: tSer;
    k: CARDINAL;
BEGIN
    Transform(a, aSer);
    FOR k:= 1 TO aSer.c - 1 DO
        ZeroesInColumn(k, aSer)
    END;
    MultDiag(aSer, SerDet);
    
    (* Fehlersuche: *)
    IF BGHDebug <= 2 THEN
        WriteString("Determinate als Potenzreihe: "); WriteLn;
        SerWrite(SerDet); Wait;
    END;
    
    RETURN SerEval(SerDet)
END BGH;

(**************************************************************************)

PROCEDURE GetR(a: tMat; i: CARDINAL; VAR r: tMat);
(* In 'r' wird der Vektor zurueckgegeben, den man aus den Elementen der
   'i'-ten Zeile oberhalb Hauptdiagonalen der Matrix 'a' erhaelt. *)
VAR k: CARDINAL;
BEGIN
    MatClear(r, 1, n-i);
    FOR k:= 1 TO r.c DO
        r.v[1,k]:= a.v[i,k+i]
    END;
    
    (* Fehlersuche: *)
    IF BerkDebug THEN
        WriteString("R"); WriteCard(i,0); WriteString(":"); WriteLn;
        WriteMat(r); Wait
    END
END GetR;

PROCEDURE GetS(a: tMat; i: CARDINAL; VAR s: tMat);
(* In 's' wird der Vektor zurueckgegeben, den man aus den Elementen
   der 'i'-ten Spalte von 'a' unterhalb der Hauptdiagonalen erhaelt. *)
VAR k: CARDINAL;
BEGIN
    MatClear(s, n-i, 1);
    FOR k:= 1 TO s.r DO
        s.v[k,1]:= a.v[k+i,i]
    END;

    (* Fehlersuche: *)
    IF BerkDebug THEN
        WriteString("S"); WriteCard(i,0); WriteString(":"); WriteLn;
        WriteMat(s); Wait;
    END
END GetS;

PROCEDURE GetM(a: tMat; i: CARDINAL; VAR m: tMat);
(* In 'm' wird die Untermatrix von 'a' zurueckgegeben, die durch
   Streichen der ersten 'i' Zeilen und Spalten entsteht *)
VAR k,l : CARDINAL;
BEGIN
    MatClear(m, n-i, n-i);
    FOR k:= 1 TO m.r DO
        FOR l:= 1 TO m.c DO
            m.v[k,l]:= a.v[k+i,l+i]
        END
    END;

    (* Fehlersuche: *)
    IF BerkDebug THEN
        WriteString("M"); WriteCard(i,0); WriteString(":"); WriteLn;
        WriteMat(m); Wait;
    END
END GetM;

PROCEDURE MakeToeplitz(VAR a: tMat);
(* Ausgehend von den Elementen in der ersten Spalte von 'a' wird diese
   Matrix in eine Toepliz-Matrix ueberfuehrt. *)
VAR i,j: CARDINAL;
BEGIN
    FOR j:= 2 TO a.c DO
        FOR i:= 1 TO a.r DO
            IF i=1 THEN
                a.v[i,j]:= 0.0
            ELSE
                a.v[i,j]:= a.v[i-1,j-1]
            END
        END
    END
END MakeToeplitz;

PROCEDURE GetC(a: tMat; i: CARDINAL; VAR c: tMat);
(* In 'c' wir die Matrix C_i (siehe Beschreibung des Algorithmus von
   Berkowitz) fuer die Matrix 'a' zurueckgegeben. *)
VAR r, m, s, rm, rms: tMat;
    k: CARDINAL;
BEGIN
    c.r:= n-i+2; c.c:= n-i+1;
    c.v[1,1]:= -1.0;
    c.v[2,1]:= a.v[i,i];
    IF n >= i+1 THEN
        GetR(a, i, r);
        GetS(a, i, s);
        GetM(a, i, m);
        MatAssign(r, rm);
        MatMult(rm, s, rms);
        c.v[3,1]:= rms.v[1,1];
        FOR k:= 1 TO n-i-1 DO
            MatMult(rm, m, rm);
            MatMult(rm, s, rms);
            c.v[k+3,1]:= rms.v[1,1]
        END
    END;
    MakeToeplitz(c);

    (* Fehlersuche: *)
    IF BerkDebug THEN
        WriteString("C"); WriteCard(i,0); WriteString(":"); WriteLn;
        WriteMat(c); Wait;
    END
END GetC;

PROCEDURE Berk(a: tMat): LONGREAL;
(* Determinantenberechnung mit Hilfe des Algorithmus von Berkowitz *)
VAR p: tMat;
    res, c: tMat;
    i: CARDINAL;
BEGIN
    GetC(a, 1, res);
    
    FOR i:= 2 TO n DO
        GetC(a, i, c);
        MatMult(res, c, res);
        
        (* Fehlersuche: *)
        IF BerkDebug THEN
            WriteString("Produkt von C1 bis C"); WriteCard(i,0);
            WriteString(":"); WriteLn;
            WriteMat(res); Wait
        END
    END;

    (*  Fehlersuche: *)
    IF BerkDebug THEN
        FOR i:= 1 TO n+1 DO
            WriteReal(res.v[i,1], 0, 0); WriteLn;
        END;
    END;

    RETURN res.v[n+1, 1]
END Berk;

(**************************************************************************)

PROCEDURE IssueKrylovVektor(n: CARDINAL; VAR z: tMat);
(* In 'z' wird der fuer das Verfahren von Krylov zu benutzende Krylov-Vektor
   der Laenge 'n' zurueckgegeben. *)
VAR i: CARDINAL;
BEGIN
    MatClear(z, n, 1);
    FOR i:= 1 TO n DO
        z.v[i,1]:= 1.0
    END
END IssueKrylovVektor;

PROCEDURE MatSetColumn(from, to: CARDINAL; src: tMat;
                       VAR dest: tMat);
(* Spalte 'from' der Matrix 'src' wird nach Spalte 'to' der Matrix 'dest'
   kopiert. *)
VAR i: CARDINAL;
BEGIN
    Check(src.r = dest.r);
    FOR i:= 1 TO src.r DO
        dest.v[i,to]:= src.v[i,from]
    END
END MatSetColumn;

PROCEDURE CreateKrylovMatrix(a: tMat; VAR kry, zn: tMat);
(* Fuer die Matrix 'a' wird in 'kry' die zugehoerige Krylov-Matrix
   zurueckgegeben. In 'zn' wird der zugehoerige 'n'-te ('a' besitze n
   Zeilen und Spalten) iterierte Vektor zurueckgegeben. *)
VAR z: tMat;
    k: CARDINAL;
BEGIN
    IssueKrylovVektor(a.r, z);
    MatClear(kry, a.r, a.c);
    MatSetColumn(1, 1, z, kry);
    FOR k:= 2 TO a.r DO
        MatMult(a, z, z);
        MatSetColumn(1, k, z, kry)
    END;
    MatMult(a, z, zn);
    IF PanDebug THEN
        WriteString("Krylov-Matrix:"); WriteLn;
        WriteMat(kry); WriteLn;
        WriteString("z_n:"); WriteLn;
        WriteMat(zn); WriteLn;
        Wait
    END
END CreateKrylovMatrix;

PROCEDURE MatTranspose(a: tMat; VAR b: tMat);
(* In 'b' wird die Transponierte der Matrix 'a' zurueckgegeben. *)
VAR i,j: CARDINAL;
BEGIN
    MatClear(b, a.r, a.c);
    FOR i:= 1 TO b.r DO
        FOR j:= 1 TO b.c DO
            b.v[i,j]:= a.v[j,i]
        END
    END
END MatTranspose;

PROCEDURE MatRowSum(m: tMat; r: CARDINAL): LONGREAL;
(* Als Funktionswert wird die Summe der Elemente in Zeile 'r' der Matrix
   'm' zurueckgegeben. *)
VAR j: CARDINAL;
    res: LONGREAL;
BEGIN
    res:= 0.0;
    FOR j:= 1 TO m.c DO
        res:= res + ABS(m.v[r,j])
    END;
    RETURN res
END MatRowSum;

PROCEDURE MatColSum(m: tMat; c: CARDINAL): LONGREAL;
(* Als Funktionswert wird die Summe der Elemente in Spalte 'c' der Matrix
   'm' zurueckgegeben. *)
VAR i: CARDINAL;
    res: LONGREAL;
BEGIN
    res:= 0.0;
    FOR i:= 1 TO m.r DO
        res:= res + ABS(m.v[i,c])
    END;
    RETURN res
END MatColSum;

PROCEDURE Max(a, b: LONGREAL): LONGREAL;
(* Es wird das Maximum von 'a' und 'b' zurueckgegeben. *)
BEGIN
    IF a > b THEN
        RETURN a
    ELSE
        RETURN b
    END
END Max;

PROCEDURE Mat1Norm(a: tMat): LONGREAL;
(* Funktionsergebnis ist die 1-Norm (maximale Betrags-Spaltensumme)
   der Matrix 'a'. *)
VAR k: CARDINAL;
    cMax: LONGREAL;
BEGIN
    cMax:= MatColSum(a, 1);
    FOR k:= 2 TO a.c DO
        cMax:= Max(cMax, MatColSum(a, k))
    END;
    RETURN cMax
END Mat1Norm;

PROCEDURE MatInftyNorm(a: tMat): LONGREAL;
(* Funktionsergebnis ist die Unendlich-Norm (maximale Betrags-Zeilensumme)
   der Matrix 'a'. *)
VAR k: CARDINAL;
    rMax: LONGREAL;
BEGIN
    rMax:= MatRowSum(a, 1);
    FOR k:= 2 TO a.r DO
        rMax:= Max(rMax, MatRowSum(a, k))
    END;
    RETURN rMax
END MatInftyNorm;

PROCEDURE ErrorMat(a, b: tMat; VAR error: tMat);
(* Fuer die Matrix 'a' und ihre Naeherungsinverse 'b' wird die Fehlermatrix
   berechnet und in 'error' zurueckgegeben. *)
VAR
    unit, ErrMult: tMat;
BEGIN
    MatUnit(unit, b.r, b.c);
    MatMult(b, a, ErrMult);
    MatSub(unit, ErrMult, error)
END ErrorMat;

PROCEDURE GuessInv(m: tMat; VAR inv: tMat);
(* Fuer die Matrix 'm' wird eine Naeherungsinverse berechnet und in 'inv'
   zurueckgegeben. *)
VAR t: LONGREAL;
    mMult, mTrans, error: tMat;
BEGIN
    MatTranspose(m, mTrans);
    MatMult(mTrans, m, mMult);

    t:= 1.0 / Mat1Norm(mMult);
 
    MatXMult(mMult, t, inv);
    IF PanDebug THEN
        WriteString("Naeherungsinverse: "); WriteLn;
        WriteMat(inv); WriteLn;

        WriteString("Fehlermatrix: "); WriteLn;
        ErrorMat(m, inv, error);
        WriteMat(error);
        WriteString("1-Norm der Fehlermatrix: ");
        WriteReal(Mat1Norm(error), 20, 10);
        Wait
    END
END GuessInv;

PROCEDURE ImproveGuessed(a, b: tMat; VAR bStern: tMat);
(* Die Naeherungsinverse 'b' der Matrix 'a' wird iterativ verbessert.
   Das Ergebnis wird in 'bStern' zurueckgegeben. *)
VAR k: CARDINAL;
    hilf, unit, error: tMat;
BEGIN
    Check(a.r = a.c);
    MatUnit(unit, a.r, a.c);
    MatXMult(unit, 2.0, unit);
    MatAssign(b, bStern);
    FOR k:= 1 TO PanLoops DO
        (* B_i := (2E_n - B_{i-1}A)B_{i-1} *)
        MatMult(bStern, a, hilf);
        MatSub(unit, hilf, hilf);
        MatMult(hilf, bStern, bStern);
        IF PanDebug THEN
            WriteString("ImproveGuessed: 1-Norm der Fehlermatrix: ");
            ErrorMat(a, bStern, error);
            WriteReal(Mat1Norm(error), 20, 10);
            WriteLn
        END
    END;
END ImproveGuessed;

PROCEDURE Pan(a: tMat): LONGREAL;
(* Determinantenberechnung mit Hilfe des Algorithmus von Pan *)
VAR kry, InvKry, ImprovedKry, zn, c: tMat;
BEGIN
    CreateKrylovMatrix(a, kry, zn);
    GuessInv(kry, InvKry);
    ImproveGuessed(a, InvKry, ImprovedKry);
    MatMult(ImprovedKry, zn, c);
    IF PanDebug THEN
        WriteString("Ergebnisvektor:"); WriteLn;
        WriteMat(c); WriteLn;
    END;
    RETURN c.v[n+1,1]
END Pan;

(**************************************************************************)

PROCEDURE Trivial(a: tMat): LONGREAL;
(* Es wird die Determinante von 'a' durch Betrachtung aller
   Index-Permutationen berechnet. *)
BEGIN
    CASE n OF
      2: RETURN a.v[1,1] * a.v[2,2] - a.v[2,1] * a.v[1,2]
    | 3: RETURN   a.v[1,1] * a.v[2,2] * a.v[3,3]
                + a.v[1,2] * a.v[2,3] * a.v[3,1]
                + a.v[1,3] * a.v[2,1] * a.v[3,2]
                - a.v[1,1] * a.v[2,3] * a.v[3,2]
                - a.v[1,2] * a.v[2,1] * a.v[3,3]
                - a.v[1,3] * a.v[2,2] * a.v[3,1]
    ELSE
        WriteString("*** Trivial: zu schwierig");
        RETURN 0.0
    END
END Trivial;

(**************************************************************************)

BEGIN
    BGHDebug:= cBGHDebug;

    WriteString("*** Test der Algorithmen fuer 3*3--Matrizen ***");
    ReadFile(a);
    WriteLn;
    REPEAT
        WriteString("Eingabe (0: Ende, 1: Hilfe)? ");
        ReadCard(eingabe); WriteLn;
        CASE eingabe OF
            0: (* tue nichts *)
          | 1: Hilfe
          | 2: ReadMat(a)
          | 3: WriteMat(a)

          | 4: WriteString("*** Alg. v. Csanky ***"); WriteLn;
               WriteReal(Csanky(a),20,10); WriteLn;

          | 5: WriteString("*** Alg. v. Borodin, von zur Gathen");
               WriteString(" und Hopcroft ***"); WriteLn;
               WriteReal(BGH(a),20,10); WriteLn;

          | 6: WriteString("*** Alg. v. Berkowitz ***"); WriteLn;
               WriteReal(Berk(a),20,10); WriteLn;

          | 7: WriteString("*** Alg. v. Pan ***"); WriteLn;
               WriteReal(Pan(a),20,10); WriteLn;

          | 8: WriteString("*** Trivialmethode ***"); WriteLn;
               WriteReal(Trivial(a),20,10); WriteLn;
        ELSE
            WriteString("Befehl unbekannt")
        END
    UNTIL eingabe = 0
END algtest.
(* ###GrepMarke###
\end{verbatim}
\end{ProgModul}
   ###GrepMarke### *)
