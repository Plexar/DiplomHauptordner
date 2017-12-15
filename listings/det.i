
\begin{ImpModul}{Det}
\begin{verbatim}

IMPLEMENTATION MODULE Det;

(* Verschiedene Algorithmen zur Determinatenberechnung

         ( Erklaerungen im Definitionsmodul )
*)

FROM SYSTEM IMPORT TSIZE, ADR;
FROM InOut IMPORT WriteLn, WriteString, WriteCard, WriteReal;
IMPORT Sys, SysMath, Func, Type, List, Frag, Hash, Reli, Mat,
       Pram, Rema, Mali;
FROM Sys IMPORT tPOINTER;
FROM SysMath IMPORT ld, lg, real, power, Card2LCard, Card2LReal,
                    LReal2Card, LReal2LCard, LCard2Card, LCard2LReal,
                    LInt2LReal;
FROM Func IMPORT Message, Error;
FROM Rema IMPORT tMat, Rows, Columns, Elem, Set;

CONST (* Schalter zur Fehlersuche (TRUE: entsprechender Programm-
         teil gibt Testmeldungen aus):  *)
      BGHDebug = TRUE;
          (* ... Algorithmus von Borodin, von zur Gathen und
                 Hopcroft (Prozedur 'BGH' ... ) *)
      BerkDebug = TRUE;
          (* ... Algorithmus von Berkowitz *)

      BerkEpsilon = 0.5;
          (* 'Epsilon' fuer den Berkowitz-Algorithmus *)
          
      HashSize = 10000L;
          (* Groessenvorgabe fuer den verwendeten Hash-Speicher *)

VAR MatId: Type.Id; (* Typidentifikator fuer 'Matrix' *)
    ListId: Type.Id; (* Typidentifikator fuer 'List' *)

(************************************************************)
(***** gemeinsame Prozeduren verschiedener Algorithmen: *****)

PROCEDURE CheckSquare(mat: tMat; proc: ARRAY OF CHAR);
(* Falls 'mat' keine quadratische Matrix ist, wird eine
   Fehlermeldung ausgegeben. Dabei erscheint 'proc' als
   Funktionsname in der Meldung. *)
BEGIN
    IF Rows(mat) # Columns(mat) THEN
        Error(proc,
            "Die Matrix ist nicht quadratisch.")
    END;
    IF (Rows(mat) < 1) OR (Columns(mat) < 1) THEN
        Error(proc,
        "Die Matrix besitzt weniger als eine Zeile oder Spalte !??");
    END
END CheckSquare;

PROCEDURE SetToeplitz(a: tMat);
(* Anhand der Elemente der in ihrer ersten Spalte wird 'a' in eine
   untere Dreiecks-Toeplitz-Matrix ueberfuehrt.

   Nach dem Aufruf gilt also:
       a_{i,j} = a_{i-1,j-1}  und  i<j \Rightarrow a_{i,j} = 0
*)
VAR i, (* Zeile *)
    j, (* Spalte *)
    r, (* Zeilen insgesamt *)
    c: (* Spalten insgesamt *)
       LONGCARD;
BEGIN
    r:= Rows(a);
    c:= Columns(a);
    FOR j:= 2 TO c DO
        Set(a, 1, j, 0.0)
    END;
    FOR i:= 2 TO r DO
        FOR j:= 2 TO c DO
            Set(a, i, j, Elem(a, i-1, j-1))
        END
    END
END SetToeplitz;

PROCEDURE MultMatList(VAR res: tMat;
                      matlist: List.tList;
                      toepliz: BOOLEAN);
(* In 'matlist' muss eine Liste von Matrizen (Typ tMat)
   uebergeben werden.
   In 'res' wird das Produkt aller dieser Matrizen zurueckgegeben.
   Der Inhalt von 'matlist' geht verloren.
   Falls in 'toepliz' der Wert TRUE uebergeben wird, geht die
   Prozedur davon aus, das 'matlist' untere Dreiecks-Toepliz-Matrizen
   enthaelt und benutzt einen effizienteren Multiplikations-
   algorithmus.
   Bei 'toepliz = FALSE' wird 'Rema.Mult' zur Multiplikation verwendet.
   'res' wird in 'MultMatList' angelegt. 'matlist' muss ausserhalb
   von 'MultMatList' angelegt und geloescht werden. *)
VAR l: ARRAY [1..2] OF Mali.tMali;
    m1, m2, m: tMat;
    source, target: [1..2];
    i,k: LONGCARD;
    sum: LONGREAL;
    AddList: Reli.tReli;
        (* Liste fuer Addition nach der Binaerbaummethode *)
BEGIN
    Reli.Use(AddList);
    Mali.Use(l[1]);
    l[2]:= matlist;
    source:= 1; target:= 2;
    IF List.Count( l[target] ) = 0 THEN
       Error("Det.MultMatList", "Die Liste ist leer")
    END;

    WHILE List.Count( l[target] ) > 1 DO
        target:= 3 - target; source:= 3 - source;
        Pram.ParallelStart("Det.MultMatList");
        REPEAT
            List.First( l[source] );
            m1:= Mali.OutCur( l[source] );
            m2:= Mali.OutCur( l[source] );
            Rema.Use(m, Rows(m1), Columns(m2) );

            IF toepliz THEN
                (* effizienter Multiplikationsalgorithmus fuer
                   untere Dreiecks-Toepliz-Matrizen: *)
                IF Columns(m1) # Rows(m2) THEN
                    Error("Det.MultMatList",
                        "Die Liste enthaelt inkompatible Matrizen.");
                END;
                Pram.ParallelStart("Det.MultMatList:Toeplitz");
                FOR i:= 1 TO Rows(m1) DO
                    List.Empty(AddList);

                    (* untere Dreieckmatrix; deshalb
                       Rows(m) statt Columns(m) moeglich: *)
                    FOR k:= 1 TO Columns(m1) DO
                        Reli.InsertBehind(AddList,
                            Elem(m1, i, k) * Elem(m2, k, 1)
                        )
                    END;

                    (* Die Durchlaeufe der obigen Schleife werden
                       parallel durchgefuehrt: *)
                    Pram.Prozessoren(Rows(m));
                    Pram.Schritte(1);

                    Set(m, i, 1, Pram.AddList(AddList) );
                    Pram.NaechsterBlock("Det.MultMatList:Toeplitz")
                END;
                Pram.ParallelEnde("Det.MultMatList:Toeplitz");
                SetToeplitz(m)
            ELSE
                Rema.Mult(m1, m2, m)
            END;

            Rema.DontUse(m1);
            Rema.DontUse(m2);
            Mali.InsertBehind( l[target], m );

            IF List.Count( l[source] ) = 1 THEN
                Mali.InsertBehind(
                    l[target], Mali.OutCur( l[source] )
                )
            END;
            Pram.NaechsterBlock("Det.MultMatList");
        UNTIL List.Count( l[source] ) = 0;
        Pram.ParallelEnde("Det.MultMatList");
    END;

    List.First( l[target] );
    res:= Mali.OutCur( l[target] );
    List.DontUse(l[1]);
    List.DontUse(AddList)
END MultMatList;

PROCEDURE MatFragSet(f: Frag.tFrag; index: LONGCARD; item: tMat);
(* ... zur vereinfachten Handhabung *)
BEGIN
    Frag.SetItem(f, index, tPOINTER(item))
END MatFragSet;

PROCEDURE MatFragGet(f: Frag.tFrag; index: LONGCARD): tMat;
(* ... zur vereinfachten Handhabung *)
BEGIN
    RETURN tMat( Frag.GetItem(f, index) )
END MatFragGet;

PROCEDURE Praefixalg(x, res: Frag.tFrag);
(* 'x' und 'res' muessen Felder von Matrizen (Typ 'Rema.tMat') sein.
   In jedem Element 'i' von 'res' wird das Produkt der ersten 'i'
   Elemente von 'x' zurueckgegeben. Die Produkte werden mit Hilfe
   des Ladner-Fischer-Praefixalgorithmus berechnet.
   'x' darf leere Elemente ( = NIL ) enthalten. Die minimal zulaessige
   Laenge von 'x' ist 1.
*)
VAR UpperHalf, ResUpperHalf,
    LowerQuarter, ResLowerQuarter: Frag.tFrag;
    frontier: LONGCARD;
        (* groesster Index der unteren Haelfte von 'x' bzw. 'res' *)
    i: LONGCARD;
BEGIN
    IF Frag.GetHigh(x) = 1 THEN
        (* Es ist nichts zu berechnen (kopiere Eingabe): *)
        MatFragSet( res, 1, Rema.Copy(MatFragGet(x, 1)) )

    ELSIF Frag.GetHigh(x) = 2 THEN
        (* Es ist nur das zweite Element von 'res' zu berechnen
           (eine Matrizenmultiplikation): *)
        MatFragSet( res, 1, Rema.Copy(MatFragGet(x, 1)) );
        IF (MatFragGet(x, 1) # tMat(NIL))
           AND (MatFragGet(x, 2) # tMat(NIL))
        THEN
            MatFragSet( res, 2, Rema.CreateMult(
                                    MatFragGet(x, 1),
                                    MatFragGet(x, 2)
                                )
            )
        END
    ELSE
        IF (Frag.GetHigh(x) MOD 4) # 0 THEN
            Error("Det.Praefixalg",
                "Die Feldgroese ist nicht durch 4 teilbar.")
        END;
        frontier:= Frag.GetHigh(x) DIV 2;
        Pram.ParallelStart("Det.Praefixalg:halves");
            (* multipliziere die Elemente der unteren Haelfte des
               Eingabefeldes 'x' paarweise miteinander: *)

            Frag.Use(LowerQuarter, MatId, 1, frontier DIV 2);
            Frag.Use(ResLowerQuarter, MatId, 1, frontier DIV 2);
            Frag.AddRef(ResLowerQuarter, TRUE);

            Pram.ParallelStart("Det.Praefixalg:lower");
                FOR i:= 1 TO frontier DIV 2 DO
                    IF (MatFragGet(x, 2 * i - 1) # tMat(NIL))
                       AND (MatFragGet(x, 2 * i) # tMat(NIL))
                    THEN
                        MatFragSet(LowerQuarter, i,
                            Rema.CreateMult(
                                MatFragGet(x, 2 * i - 1),
                                MatFragGet(x, 2 * i)
                            )
                        )
                    END;
                Pram.NaechsterBlock("Det.Praefixalg:lower")
                END;
            Pram.ParallelEnde("Det.Praefixalg:lower");

            (* berechne die Elemente mit geradem Index der unteren
               Haelfte des Ergebnisfeldes 'res': *)

            Praefixalg(LowerQuarter, ResLowerQuarter);
            FOR i:= 1 TO frontier DIV 2 DO
                MatFragSet(res, i * 2,
                           MatFragGet(ResLowerQuarter, i))
            END;

            Frag.DontUse(LowerQuarter);
            Frag.DontUse(ResLowerQuarter);
        Pram.NaechsterBlock("Det.Praefixalg:halves");
            (* loese das Problem rekursiv fuer die obere Haelfte des
               Eingabefeldes 'x': *)

            Frag.Use(UpperHalf, MatId, 1, frontier);
            Frag.AddRef(UpperHalf, TRUE);
            Frag.Use(ResUpperHalf, MatId, 1, frontier);
            
            FOR i:= frontier + 1 TO Frag.GetHigh(x) DO
                MatFragSet(UpperHalf, i - frontier, MatFragGet(x, i))
            END;
            Praefixalg(UpperHalf, ResUpperHalf);
        Pram.ParallelEnde("Det.Praefixalg:halves");
        Pram.ParallelStart("Det.Praefixalg:nextstep");
            (* berechne die Elemente mit ungeradem Index der unteren
               Haelfte des Ergebnisfeldes 'res': *)

            MatFragSet( res, 1, Rema.Copy(MatFragGet(x, 1)) );
            Pram.ParallelStart("Det.Praefixalg:oddlower");
                FOR i:= 3 TO (frontier DIV 2) BY 2 DO
                    IF (MatFragGet(res, i - 1) # tMat(NIL))
                    AND (MatFragGet(x, i) # tMat(NIL)) THEN
                        MatFragSet( res, i,
                            Rema.CreateMult(
                                MatFragGet(res, i - 1),
                                MatFragGet(x, i)
                            )
                        );
                    END;
                Pram.NaechsterBlock("Det.Praefixalg:oddlower")
                END;
            Pram.ParallelEnde("Det.Praefixalg:oddlower");
        Pram.NaechsterBlock("Det.Praefixalg:nextstep");
             (* berechne die Elemente der oberen Haelfte des Ergebnis-
                feldes 'res': *)

             Pram.ParallelStart("Det.Praefixalg:resupper");
                 FOR i:= frontier + 1 TO Frag.GetHigh(res) DO
                     IF (MatFragGet(res, frontier) # tMat(NIL)) AND
                        (MatFragGet(ResUpperHalf, i - frontier) # tMat(NIL))
                     THEN
                         MatFragSet(res, i,
                             Rema.CreateMult(
                                 MatFragGet(res, frontier),
                                 MatFragGet(ResUpperHalf, i-frontier)
                             )
                         )
                     END;
                     Pram.NaechsterBlock("Det.Praefixalg:resupper")
                 END;
             Pram.ParallelEnde("Det.Praefixalg:resupper");
             Frag.DontUse(UpperHalf);
             Frag.DontUse(ResUpperHalf);
        Pram.ParallelEnde("Det.Praefixalg:nextstep");
    END
END Praefixalg;

PROCEDURE MultLadnerFischer(l: Mali.tMali; m: tMat; max: LONGCARD);
(* Mit Hilfe des Ladner-Fischer-Praefixalgorithmus werden
   fuer 'm' alle Potenzen von 1 bis 'max' berechnet und in
   'l' zurueckgegeben.
   Dabei werden Zaehlprozeduren des Moduls 'Pram' aufgerufen.
*)
VAR i, size: LONGCARD;
    x, res: Frag.tFrag;
BEGIN
     size:= LReal2LCard(
                power( 2.0,
                    LCard2LReal( Func.Ceil(ld(LCard2LReal(max))) )
                )
            );
     Frag.Use(x, MatId, 1, size);
     Frag.Use(res, MatId, 1, size);
     FOR i:= 1 TO max DO
         MatFragSet(x, i, Rema.Copy(m))
     END;

     Praefixalg(x, res);

     List.Empty(l);
     FOR i:= 1 TO max DO
         Mali.InsertBehind(l, MatFragGet(res, i))
     END;

     Frag.DontUse(x);
     Frag.DontUse(res)
END MultLadnerFischer;

(***************************************************************)
(***** Algorithmus nach der Spaltenentwicklung von Laplace *****)
(*****       ( Spezialfall des Entwicklungssatzes )        *****)

PROCEDURE RemoveRowAndColumn(a: tMat; r, c: LONGCARD): tMat;
(* Funktionsergebnis ist die Matrix, die man aus 'a' durch
   Streichen von Zeile 'r' und Spalte 'c' erhaelt.
*)
VAR res: tMat; (* Funktionsergebnis *)
    i, j, i2, j2: LONGCARD;
BEGIN
    Rema.Use(res, Rows(a) - 1, Columns(a) - 1);
    FOR i:= 1 TO Rows(res) DO
        FOR j:= 1 TO Columns(res) DO
            IF i < r THEN
                i2:= i
            ELSE
                i2:= i+1
            END;
            IF j < c THEN
                j2:= j
            ELSE
                j2:= j+1
            END;
            Set(res, i, j, Elem(a, i2, j2))
        END
    END;
    RETURN res
END RemoveRowAndColumn;

PROCEDURE EineSpalte(a: tMat): LONGREAL;
(* Funktionsergebnis ist die Determianten von 'a'. Sie wird durch
   rekursive Entwicklung nach der ersten Spalte berechnet.
*)
VAR WorkMat: tMat;
        (* Untermatrix von 'a', deren Determinante als naechste
           zu berechnen ist *)
    DetList: Reli.tReli;
        (* Liste der vorzeichenbehafteten Determinanten von Unter-
           Matrizen von 'a' *)
    i: LONGCARD; (* Schleifenzaehler *)
    n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    AddList: Reli.tReli;
    res: LONGREAL;
BEGIN
    CheckSquare(a,"Det.Spalten");
    n:= Rows(a);
    IF n = 1 THEN
        RETURN Elem(a,1,1)
    END;

    Reli.Use(DetList);
    Reli.Use(AddList);

    Pram.ParallelStart("Det.EineSpalte");
    FOR i:= 1 TO n DO
        WorkMat:= RemoveRowAndColumn(a, i, 1);
        Reli.InsertBehind(
            DetList, EineSpalte(WorkMat) * power( -1.0, real(i+1) )
        );
        Rema.DontUse(WorkMat);
        Pram.NaechsterBlock("Det.EineSpalte")
    END;
    Pram.ParallelEnde("Det.EineSpalte");

    List.First(DetList);
    FOR i:= 1 TO n DO
        Reli.InsertBehind(AddList,
            Elem(a, i, 1) * Reli.Cur(DetList)
        );
        List.Next(DetList)
    END;
    (* Die Schleifendurchlaufe werden parallel durchgefuehrt: *)
    Pram.Prozessoren( n );
    Pram.Schritte( 1 );

    res:= Pram.AddList(AddList);
        (* Der zur Addition der Elemente von 'AddList' wird in
           'Pram.AddList' gezaehlt. *)

    List.DontUse(DetList);
    List.DontUse(AddList);
    RETURN res
END EineSpalte;

PROCEDURE Laplace(a: tMat): LONGREAL;
BEGIN
    CheckSquare(a,"Det.Laplace");
    IF Rows(a) = 1 THEN
        RETURN Elem(a,1,1)
    END;

    RETURN EineSpalte(a)
END Laplace;

(************************************)
(*****  Algorithmus von Csanky  *****)
(***** nach dem Satz von Frame: *****)

PROCEDURE Csanky(a: tMat): LONGREAL;
VAR b0: tMat;
    tr: LONGREAL; (* Spur von 'a' *)
    MatList: Mali.tMali;
        (* Liste von zu multiplizierenden Matrizen *)
    work: tMat;
        (* aktuelle Arbeitsmatrix *)
    i,j: LONGCARD; (* Schleifenzaehler *)
    z: LONGREAL; (* Zwischenergebnis im Algorithmus *)
    det: LONGREAL; (* Determinante von 'a' *)
    size: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
BEGIN
    Mali.Use(MatList);
    CheckSquare(a,"Det.Csanky");
    IF Rows(a) = 1 THEN
        RETURN Elem(a,1,1)
    END;
    
    size:= Rows(a);

    tr:= Rema.Trace(a);
    (* Der Aufwand wird in 'Rema.Trace' gezaehlt. *)

    Pram.ParallelStart("Det.Csanky");
    FOR i:= size - 1 TO 1 BY -1 DO
        Rema.Use(work, Rows(a), Columns(a));
        Rema.Assign(a, work);
        (* Zuweisungen werden nicht gezaehlt. *)
        
        z:= tr / real(i);
        Pram.Prozessoren(1);
        Pram.Schritte(1);
        
        FOR j:= size TO 1 BY -1 DO
            Set(work, j, j, Elem(work, j, j) - z)
        END;
        Pram.Prozessoren(size);
        Pram.Schritte(1);

        Mali.InsertBefore(MatList, work);
        (* Verwaltungsaufwand wird nicht gezaehlt. *)
        
        Pram.NaechsterBlock("Det.Csanky");
        (* Die Schleifendurchlaeufe werden parallel durchgefuehrt. *)
    END;
    Pram.ParallelEnde("Det.Csanky");

    MultMatList(b0, MatList, FALSE);
    
    (* 'b0' wird als Zwischenspeicher missbraucht: *)
    Rema.Mult(a,b0,b0);
        (* Der Aufwand wird im Modul 'Rema' gezaehlt. *)

    det:= Rema.Trace(b0) / real( size );
        (* Der Aufwand fuer 'Rema.Trace' wird dort gezaehlt. *)
    Pram.Prozessoren(1);
    Pram.Schritte(1);

    List.DontUse(MatList);
    
    RETURN det
END Csanky;

(*****************************************************************)
(***** Algorithmus von Borodin, von zur Gathen und Hopcroft: *****)

(* Typen fuer den Algorithmus: *)

TYPE tOpType = ( constant, indeterminate, node );
     tOp = POINTER TO tOpRec;
     tOpRec
         = RECORD (* ein Operand eines Knotens *)
               CASE vOpType: tOpType OF
                   constant:
                   (* der Operand ist eine Konstante *)
                       ConstVal: LONGREAL (* Wert der Konstante *)
                 | indeterminate:
                   (* der Operand ist eine Unbestimmte *)
                       IndetVal: LONGREAL
                           (* Wert, der bei der Ausfuehrung des
                              Programms fuer die Unbestimmte
                              eingesetzt werden soll *)
                 | node:
                   (* der Operand ist das Ergebnis eines anderen
                      Knotens *)
                       NodePos: List.tPos
                           (* Position des Knotens in der
                              Knotenliste *)
               END
           END;
     tNode = POINTER TO tNodeRec;
     tNodeRec
           = RECORD (* ein Additions- oder Multiplikationsknoten *)
                 DegValid: BOOLEAN;
                     (* TRUE: 'degree' wurde bereits gesetzt *)
                 degree: LONGCARD;
                     (* Grad des Knotens *)
                 ResValid: BOOLEAN;
                     (* TRUE: 'res' wurde bereits berechnet *)
                 res: LONGREAL;
                     (* Ergebnis des Knotens *)
                 add: BOOLEAN;
                     (* TRUE:  der Knoten ist ein Additionsknoten;
                        FALSE: ... ein Multiplikationsknoten *)
                 op1, op2: tOp
                     (* die beiden Operanden *)
             END;
     tSer = Frag.tFrag;  (* power SERies *)
         (* jede Potenzreihe wird als Feld ihrer homogenen Komponen-
            ten bis zum festgelegten Grad implementiert *)

VAR NodeId: Type.Id; (* Typidentifikator eines Knotens *)
    OpId  : Type.Id; (* ... eines Operanden *)
    SerId: Type.Id; (* ... eine Potenzreihe *)
    
    vMaxDeg: LONGCARD;
        (* maximaler Grad der homogenen Komponenten, die fuer
           Potenzreihen betrachtet werden *)

PROCEDURE MaxDeg(): LONGCARD;
(* Funktionsergebnis: siehe 'vMaxDeg';
   die Deklaration der Prozedur 'MaxDeg' erlaubt, verglichen mit
   anderen Moeglichkeiten der Handhabung des maximalen Grades,
   groessere Flexibilitaet beim Experimentieren mit der
   Implementierung des Algorithmus *)
BEGIN
    RETURN vMaxDeg
END MaxDeg;

PROCEDURE ConvertMat(a: tMat; VAR m2: LONGREAL);
(* Die Elemente von 'a' werden so transformiert, dass sie im Inter-
   vall von -0.01 bis 0.01 liegen. In 'm2' wird der Faktor zurueck-
   gegeben, mit dem die Determinante der transformierten Matrix 'a'
   multipliziert werden muss, um die Determinante der urspruenglichen
   Matrix zu erhalten.
*)
VAR m, m1, max: LONGREAL;
    i, j, size: LONGCARD;
BEGIN
    size:= Rows(a);
    max:= 0.0;
    FOR i:= 1 TO size DO
        FOR j:= 1 TO size DO
            max:= Func.MaxReal(ABS(Elem(a, i, j)), max)
        END
    END;

    m:= power( 10.0, real(Func.Ceil(lg(max)) + 1) );
    m1:= 1.0 / m;
    m2:= power(m, real(size));

    FOR i:= 1 TO size DO
        FOR j:= 1 TO size DO
            Set(a, i, j, Elem(a, i, j) * m1)
        END
    END
END ConvertMat;

(* --------------------------------------- *)
(* Operationsprozeduren fuer Modul 'Type': *)

PROCEDURE NewOpI(o: tPOINTER);
(* Initialisierungsprozedur fuer Modul 'Type' *)
VAR O: tOp;
BEGIN
    O:= o;
    WITH O^ DO
        vOpType:= constant;
        ConstVal:= 0.0
    END
END NewOpI;

PROCEDURE NewNodeI(n: tPOINTER);
(* Initialisierungsprozedur fuer Modul 'Type' (Typ: NodeId) *)
VAR N: tNode;
BEGIN
    N:= n;
    WITH N^ DO
        DegValid:= FALSE;
        degree:= 0;
        ResValid:= FALSE;
        add:= TRUE;
        NewOpI(op1);
        NewOpI(op2)
    END
END NewNodeI;

PROCEDURE DelNodeI(n: tPOINTER);
(* Loeschprozedur fuer Modul 'Type' (Typ: NodeId) *)
VAR N: tNode;
BEGIN
    N:= n;
    Type.DelI(OpId, N^.op1);
    Type.DelI(OpId, N^.op2)
END DelNodeI;

PROCEDURE NewSerI(s: tPOINTER);
VAR S: tSer;
    i: LONGCARD;
    op: tOp;
BEGIN
    S:= tSer(s);
    Frag.Use(S, OpId, 0, MaxDeg());
    FOR i:= 0 TO MaxDeg() DO
        op:= Type.NewI(OpId);
        Frag.SetItem(S, i, op)
    END
END NewSerI;

PROCEDURE DelSerI(s: tPOINTER);
VAR S: tSer;
BEGIN
    S:= tSer(s);
    Frag.DontUse(S)
END DelSerI;

(* ------------------------------------- *)
(* Handhabung von Operanden (Typ 'tOp'): *)

PROCEDURE OpAssign(a: tOp; VAR b: tOp);
(* In 'b' muss entweder NIL oder ein initialisierte Operator ueber-
   geben werden. Dieser wird in 'OpAssign' geloescht. In 'b' wird
   eine neu angelegte Kopie von 'a' zurueckgegeben.
*)
BEGIN
    Type.DelI(OpId, b);
    b:= Type.NewI(OpId);

    b^.vOpType:= a^.vOpType;
    CASE b^.vOpType OF
        constant     : b^.ConstVal:= a^.ConstVal;
      | indeterminate: b^.IndetVal:= a^.IndetVal;
      | node         : b^.NodePos:= a^.NodePos
    END
END OpAssign;

PROCEDURE OpAdd(prog: List.tList; a,b: tOp; VAR res: tOp);
(* An das Ende von 'prog' wird eine Anweisung zur Addition von
   'a' und 'b' angehaengt. Die Position dieser Anweisung innerhalb
   von 'prog' (als Operator gespeichert) wird in 'res' zurueck-
   gegeben. Die Zuweisung der Ergebnisses an 'res' erfolgt wie bei
   'OpAssign'.
   'a', 'b' und 'res' duerfen beim Aufruf identisch sein.
*)
VAR NewNode: tNode; (* neue Anweisung fuer 'prog' *)
BEGIN
   NewNode:= Type.NewI(NodeId);
   OpAssign(a, NewNode^.op1);
   OpAssign(b, NewNode^.op2);
   List.InsertBehind(prog, NewNode);

   Type.DelI(OpId, res);
   res:= Type.NewI(OpId);
   res^.vOpType:= node;
   res^.NodePos:= List.GetPos(prog)
END OpAdd;

PROCEDURE OpMult(prog: List.tList; a,b: tOp; VAR res: tOp);
(* ... analog 'OpAdd', jedoch Multiplikation *)
VAR NewNode: tNode; (* neue Anweisung fuer 'prog' *)
BEGIN
   NewNode:= Type.NewI(NodeId);
   NewNode^.add:= FALSE;
   OpAssign(a, NewNode^.op1);
   OpAssign(b, NewNode^.op2);
   List.InsertBehind(prog, NewNode);

   Type.DelI(OpId, res);
   res:= Type.NewI(OpId);
   res^.vOpType:= node;
   res^.NodePos:= List.GetPos(prog)
END OpMult;

PROCEDURE OpGetDeg(prog: List.tList; op: tOp): LONGCARD;
(* Funktionswert ist der Grad von 'op'. In 'prog' muss das zuge-
   hoerige Programm uebergeben werden. *)
VAR res: LONGCARD;
    cur: List.tPos;
    pred: tNode;
BEGIN
    CASE op^.vOpType OF
        constant:
            res:= 0
      | indeterminate:
            res:= 1
      | node:
            cur:= List.GetPos(prog);
            List.SetPos(prog, op^.NodePos);

            pred:= List.Cur(prog);
            IF NOT pred^.DegValid THEN
                Error("Det.OpGetDeg",
                    "Grad von Vorgaengerknoten unbekannt")
            END;
            res:= pred^.degree;

            List.SetPos(prog, cur)
    END;
    RETURN res
END OpGetDeg;

PROCEDURE NodeGetCur(prog: List.tList): tNode; FORWARD;
PROCEDURE NodeGetRes(node: tNode): LONGREAL; FORWARD;

PROCEDURE OpGetRes(prog: List.tList; op: tOp): LONGREAL;
(* Funktionsergebnis ist der Wert des Operanden 'op' aus dem
   Programm 'prog'. Falls der Operand ein Anweisungsknoten ist,
   muss dessen Ergebnis bereits bekannt sein.
*)
VAR res: LONGREAL;
    cur: List.tPos;
BEGIN
    CASE op^.vOpType OF
        constant:
            res:= op^.ConstVal
      | indeterminate:
            res:= op^.IndetVal
      | node:
            cur:= List.GetPos(prog);
            List.SetPos(prog, op^.NodePos);

            res:= NodeGetRes(NodeGetCur(prog));

            List.SetPos(prog, cur)
    END;
    RETURN res
END OpGetRes;

PROCEDURE OpGetNode(prog: List.tList; o: tOp): tNode;
(* 'o' muss ein Operand vom mit 'vOpType = node' sein. Er muss
   weiterhin Operand eines Knotens von 'prog' sein. Funktionswert
   ist der Knoten, auf den im Datensatz des Operanden verwiesen
   wird.
*)
VAR cur: List.tPos;
    res: tNode;
BEGIN
    IF o^.vOpType # node THEN
        Error("Det.OpGetNode", "Operand ist kein Knoten")
    END;
    cur:= List.GetPos(prog);

    List.SetPos(prog, o^.NodePos);
    res:= NodeGetCur(prog);
    
    List.SetPos(prog, cur);
    RETURN res
END OpGetNode;

(* ---------------------------------------- *)
(* Handhabung von Potenzreihen (Typ 'tSer') *)

PROCEDURE TypeNewSerI(VAR a: tSer);
VAR point: tPOINTER;
BEGIN
    point:= Type.NewI(SerId);
    a:= tSer(point)
END TypeNewSerI;

PROCEDURE TypeDelSerI(VAR a: tSer);
VAR point: tPOINTER;
BEGIN
    point:= tPOINTER(a);
    Type.DelI(SerId, point);
    a:= tSer(point)
END TypeDelSerI;

PROCEDURE SerAssign(a: tSer; VAR b: tSer);
(* ... analog 'OpAssign', jedoch fuer Typ 'tSer' *)
VAR i: LONGCARD;
    NewOp: tOp;
BEGIN
    TypeDelSerI(b);
    TypeNewSerI(b);
    Frag.SetRange(b, 0, MaxDeg());
    NewOp:= NIL;

    FOR i:= 0 TO MaxDeg() DO
        OpAssign(Frag.GetItem(a, i), NewOp);
        Frag.SetItem(b, i, NewOp);
        NewOp:= NIL
    END
END SerAssign;

PROCEDURE SerAdd(prog: List.tList; a,b: tSer; VAR res: tSer);
(* An das Ende von 'prog' wird ein Programmstueck angehaengt, das
   die Summe der Potenzreihen 'a' und 'b' berechnet. Die Summe
   wird in 'res' zurueckgegeben. Die Zuweisung an 'res' erfolgt
   wie bei 'SerAssign'.
   Es werden nur die homogenen Komponenten bis zum Grad 'MaxDeg()'
   berechnet.
   'a', 'b' und 'res' duerfen beim Aufruf identisch sein.
*)
VAR i: LONGCARD;
    NewOp: tOp;
    HilfRes: tSer;
BEGIN
    TypeNewSerI(HilfRes);
    Frag.SetRange(HilfRes, 0, MaxDeg());
    NewOp:= NIL;

    FOR i:= 0 TO MaxDeg() DO
        OpAdd(prog, Frag.GetItem(a,i), Frag.GetItem(b,i), NewOp);
        Frag.SetItem(HilfRes, i, NewOp);
        NewOp:= NIL
    END;

    TypeDelSerI(res);
    res:= HilfRes
END SerAdd;

PROCEDURE SerMult(prog: List.tList; a,b: tSer; VAR res: tSer);
(* ... analog 'SerAdd', jedoch Multiplikation *)
VAR ResComp: LONGCARD;
    SumOp, MultOp: tOp;
    i: LONGCARD;
    HilfRes: tSer;
BEGIN
    TypeNewSerI(HilfRes);
    Frag.SetRange(HilfRes, 0, MaxDeg());

    MultOp:= NIL;

    FOR ResComp:= 0 TO MaxDeg() DO
        SumOp:= Type.NewI(OpId);
        FOR i:= 0 TO ResComp DO
            OpMult(prog,
                Frag.GetItem(a,i), Frag.GetItem(b, ResComp - i), MultOp
            );
            OpAdd(prog, SumOp, MultOp, SumOp)
        END;
        Frag.SetItem(HilfRes, ResComp, SumOp)
    END;

    Type.DelI(OpId, MultOp);
    TypeDelSerI(res);
    res:= HilfRes
END SerMult;

PROCEDURE SerSetConst(a: tSer; component: LONGCARD; val: LONGREAL);
(* Die Komponente von 'a' mit dem Grad 'component' wird zu einer
   Konstanten mit dem Wert 'val' gemacht. *)
VAR op: tOp;
BEGIN
    op:= Frag.GetItem(a, component);
    op^.vOpType:= constant;
    op^.ConstVal:= val
END SerSetConst;

PROCEDURE SerMultVal(prog: List.tList; a: tSer; val: LONGREAL;
                     VAR res: tSer);
(* An 'prog' wird ein Programmstueck angehaengt, das alle Komponen-
   ten von 'a', mit 'val' multipliziert. Der konstante Term von 'a'
   wird nur dann mit 'val' multipliziert, wenn er ungleich Null ist.
   Das Ergebnis wird in 'res' zurueckgegeben. Die Zuweisung an 'res'
   erfolgt wie bei 'SerAssign'.
*)
VAR ConstOp, MultOp, aOp: tOp;
    r: tSer;
    i, start: LONGCARD;
BEGIN
    ConstOp:= Type.NewI(OpId);
    ConstOp^.ConstVal:= val;
    MultOp:= NIL;
    TypeNewSerI(r);

    aOp:= Frag.GetItem(a, 0);
    IF aOp^.vOpType = constant THEN
        IF aOp^.ConstVal # 0.0 THEN
            OpMult(prog, aOp, ConstOp, MultOp);
            Frag.SetItem(r, 0, MultOp)
        END
    END;

    FOR i:= 1 TO MaxDeg() DO
        MultOp:= NIL;
        aOp:= Frag.GetItem(a, i);
        OpMult(prog, aOp, ConstOp, MultOp);
        Frag.SetItem(r, i, MultOp)
    END;
        
    Type.DelI(OpId, ConstOp);
    TypeDelSerI(res);
    res:= r
END SerMultVal;

PROCEDURE Divide(prog: List.tList; a: tSer; VAR res: tSer);
(* An das Ende von 'prog' wird ein Programmstueck angehaengt, dass
   das multiplikative Inverse von 'a' berechnet. Es wird in 'res'
   zurueckgegeben. Die Zuweisung an 'res' erfolgt wie bei
   'SerAssign'.
   In der Prozedur wird davon ausgegangen, dass 'a' die Form '1-g'
   besitzt, wobei 'g' eine Potenzreihe mit Null als konstantem Term
   ist.
   Es werden nur die homogenen Komponenten bis zum Grad 'MaxDeg()'
   beachtet.
*)
VAR power: tSer;
        (* Potenzen von:
           'ser' mit konstantem Term Null und invertiertem
           Vorzeichen *)
    divisor: tSer;
        (* erste Potenz fuer 'Power' *)
    HilfRes: tSer;
    i: LONGCARD;
BEGIN
    divisor:= tSer(NIL);
    SerAssign(a, divisor);
    SerSetConst(divisor, 0, 0.0);
    SerMultVal(prog, divisor, -1.0, divisor);

    power:= tSer(NIL);
    SerAssign(divisor, power);

    TypeNewSerI(HilfRes);
    SerSetConst(HilfRes, 0, 1.0);

    SerAdd(prog, HilfRes, power, HilfRes);

    FOR i:= 2 TO MaxDeg() DO
        SerMult(prog, power, divisor, power);
        SerAdd(prog, HilfRes, power, HilfRes)
    END;

    TypeDelSerI(divisor);
    TypeDelSerI(power);
    TypeDelSerI(res);
    res:= HilfRes
END Divide;

(* ------------------------------------------------------------- *)
(* Handhabung der Programmatrix (Matrix der Zwischenergebnisse): *)

PROCEDURE InitProgMat(ProgMat: Mat.tMat; a: tMat);
(* Die Programmatrix 'ProgMat' wird anhand der Matrix 'a', deren
   Determinante zu berechnen ist, initialisiert.
   Die Programmatrix gibt an, welche Zwischenergebnisse fuer
   Matrizenelemente durch das bisher erzeugte Programm bereits
   berechnet werden. Die Elemente der Programmatrix sind Potenzreihen
   (Typ 'tSer').
*)
VAR WorkSer: tSer;
    Op: tOp; (* naechstes zu initialisierendes Element von
                'WorkSer' *)
    n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    i,j: LONGCARD; (* Schleifenzaehler *)
BEGIN
    n:= Rows(a);
    FOR i:= 1 TO n DO
        FOR j:= 1 TO n DO
            TypeNewSerI(WorkSer);
            Frag.SetRange(WorkSer, 0, n);

            Op:= Type.NewI(OpId);
            Op^.ConstVal:= 1.0;
            Frag.SetItem(WorkSer, 0, Op);
 
            Op:= Type.NewI(OpId);
            Op^.vOpType:= indeterminate;
            Op^.IndetVal:= - Elem(a, i, j);
            Frag.SetItem(WorkSer, 1, Op);

            Mat.Set(ProgMat, i, j, tPOINTER(WorkSer))
        END
    END
END InitProgMat;

(* -------------------------------------------------- *)
(* Algorithmusteil 'Anlegen des Berechnungsprogramms' *)
(* ('BuildProgram' und zugehoerige Prozeduren) :      *)

PROCEDURE SubLine(prog: List.tList; ProgMat: Mat.tMat; ThisLine,
                  SubFromLine: LONGCARD; divisor: tSer);
(* In 'ProgMat' wird ein Vielfaches von Zeile 'ThisLine' so zu Zeile
   'SubFromLine' addiert ('SubFromLine' muss groesser sein als
   'ThisLine'), dass in Spalte 'ThisLine' unterhalb der Hauptdiago-
   nalen Nullen entstehen. In 'divisor' muss das inverse Element
   bzgl. der Multiplikation von 'ProgMat_{thisline, thisline}' ueber-
   geben werden.
*)
VAR j, n: LONGCARD;
    accu: tSer;
BEGIN
    n:= Mat.Rows(ProgMat);
    accu:= tSer(NIL);

    FOR j:= ThisLine TO n DO
        SerMult(prog, tSer(Mat.Elem(ProgMat, ThisLine, j)),
                      tSer(Mat.Elem(ProgMat, SubFromLine, j)), accu);
        SerMult(prog, accu, divisor, accu);
        SerMultVal(prog, accu, -1.0, accu);
        Mat.Set(ProgMat, SubFromLine, j, tPOINTER(accu));
        accu:= tSer(NIL)
    END
END SubLine;

PROCEDURE ZerosInColumn(prog: List.tList; ProgMat: Mat.tMat;
                        column: LONGCARD);
(* An das Ende von 'prog' wird ein Programmstueck angehaengt, dass
   durch Subtraktion eines Vielfachen von Zeile 'column' von allen
   folgenden Zeilen in 'ProgMat' in Spalte 'column' unterhalb der
   Hauptdiagonalen Nullen erzeugt.
*)
VAR divisor: tSer;
        (* inverses Element bzgl. der Multiplikation von
           'ProgMat_{column, column}' *)
    i: LONGCARD;
BEGIN
    divisor:= tSer(NIL);
    Divide(prog, tSer(Mat.Elem(ProgMat, column, column)), divisor);
    FOR i:= column+1 TO Mat.Rows(ProgMat) DO
        SubLine(prog, ProgMat, column, i, divisor)
    END
END ZerosInColumn;

PROCEDURE MultMainDiag(prog: List.tList; ProgMat: Mat.tMat;
                       VAR res: tSer);
(* An 'prog' wird ein Programmstueck angehaengt, das die Elemente
   der Hauptdiagonalen von 'ProgMat' miteinander multipliziert.
   Das Ergebnis wird in 'res' zurueckgegeben. Die Zuweisung an 'res'
   erfolgt wie bei 'SerAssign'.
*)
VAR prod: tSer;
    i, n: LONGCARD;
BEGIN
    prod:= tSer(NIL);
    SerAssign(tSer(Mat.Elem(ProgMat, 1, 1)), prod);

    n:= Mat.Rows(ProgMat);
    FOR i:= 2 TO n DO
        SerMult(prog, prod, tSer(Mat.Elem(ProgMat, i, i)), prod)
    END;
    
    TypeDelSerI(res);
    res:= prod
END MultMainDiag;

PROCEDURE AddComponents(prog: List.tList; s: tSer);
(* An 'prog' wird ein Programmstueck angehaengt, das die Summe
   der Komponenten von 's' berechnet. *)
VAR sum: tOp;
    i: LONGCARD;
BEGIN
    sum:= NIL;
    OpAssign(Frag.GetItem(s, 0), sum);
    FOR i:= 1 TO MaxDeg() DO
        OpAdd(prog, Frag.GetItem(s, i), sum, sum)
    END;
    Type.DelI(OpId, sum)
END AddComponents;

PROCEDURE BuildProgram(prog: List.tList; a: tMat);
(* 'prog' wird mit den Anweisungen zur Berechnung der Determinante
   von 'a' gefuellt. ( 1. Anweisung am Listenanfang; letzte Anweisung
   ( deren Ergebnis die Determinanten ist) am Listenende )
*)
VAR ProgMat: Mat.tMat; (* Matrix der Zwischenergebnisse der
                          Berechnungen in 'prog' *)
    n, i: LONGCARD;
    det: tSer; (* Determinante von 'a' als Potenzreihe *)
BEGIN
    n:= Rows(a);
    Mat.Use(ProgMat, SerId);
    Mat.SetSize(ProgMat, n, n);
    det:= tSer(NIL);

    InitProgMat(ProgMat, a);
    FOR i:= 1 TO n-1 DO
        ZerosInColumn(prog, ProgMat, i)
    END;
    MultMainDiag(prog, ProgMat, det);
    AddComponents(prog, det);
    
    TypeDelSerI(det);
    Mat.DontUse(ProgMat)
END BuildProgram;

(* -------------------------------- *)
(* Handhabung von Anweisungsknoten: *)

              (* CURrent *)
PROCEDURE NodeGetCur(prog: List.tList): tNode;
(* Funktionsergebnis ist der aktuelle Anweisungsknoten von 'prog'. *)
BEGIN
    RETURN tNode(List.Cur(prog))
END NodeGetCur;

PROCEDURE NodeGetRes(node: tNode): LONGREAL;
(* Funktionsergebnis ist das Berechnungsergebnis fuer den Programm-
   knoten 'node'. *)
BEGIN
    IF NOT node^.ResValid THEN
        Error("Det.GetNodeRes",
            "Knotenergebnis wurde noch nicht berechnet")
    END;
    RETURN node^.res
END NodeGetRes;

PROCEDURE NodeExec(prog: List.tList; n: tNode);
(* Fuer den Anweisungsknoten 'n' aus dem Programm 'prog' wird
   das Ergebnis berechnet. Evtl. zu berechnende Ergebnisse der
   Operanden von 'n' muessen bereits bekannt sein.
*)
VAR op1, op2: LONGREAL;
BEGIN
    op1:= OpGetRes(prog, n^.op1);
    op2:= OpGetRes(prog, n^.op2);
    IF n^.add THEN
        n^.res:= op1 + op2
    ELSE
        n^.res:= op1 * op2
    END;
    n^.ResValid:= TRUE
END NodeExec;

PROCEDURE NodeGetDeg(n: tNode): LONGCARD;
(* Funktionsergebnis ist der Grad des angegebenen Knotens. *)
BEGIN
    RETURN n^.degree
END NodeGetDeg;

(* -------------------------------------------------- *)
(* Handhabung der Zwischenergebnisse der Form f(v;w): *)

TYPE tFvwStore = Hash.tHash; (* Speicher fuer Zwischenergebnisse *)
     tFvw = POINTER TO tFvwRec;
     tFvwRec = RECORD (* ein Zwischenergebnis der Form f(v;w)
                         ( siehe Kapitel 'Parallele Berechnung von
                          Termen' ) *)
                   v, w: tNode;
                   val: LONGREAL
               END;
VAR FvwId: Type.Id;

PROCEDURE EquFvwI(a,b: tPOINTER): BOOLEAN;
(* Vergleichsfunktion fuer Modul 'Type' (Typ 'tFvw') *)
VAR A,B: tFvw;
BEGIN
    A:= a; B:= b;
    RETURN (A^.v = B^.v) AND (A^.w = B^.w)
END EquFvwI;

PROCEDURE HashFvwI(a: tPOINTER; size: LONGCARD): LONGCARD;
(* Hash-Funktion fuer Modul 'Type' (Typ 'tFvw') *)
VAR A: tFvw;
BEGIN
    A:= a;
    RETURN ( (LONGCARD(A^.v) MOD size) + (LONGCARD(A^.w) MOD size) )
           MOD size
END HashFvwI;

PROCEDURE FvwUse(VAR store: tFvwStore);
(* Bevor eine Variable vom Typ 'tFvwStore' benutzt wird, ist fuer
   diese Variable 'FvwUse' zur Initialisierung aufzurufen.
*)
BEGIN
    Hash.Use(store, FvwId, HashSize)
END FvwUse;

PROCEDURE FvwDontUse(VAR store: tFvwStore);
(* Wenn eine Variable vom Typ 'tFvwStore' nicht mehr benutzt werden
   soll, muss 'FvwDontUse' fuer diese Variable aufgerufen werden,
   damit der fuer die Variable angelegte Speicherplatz wieder frei-
   gegeben wird.
*)
BEGIN
    Hash.DontUse(store)
END FvwDontUse;

PROCEDURE FvwEnter(store: tFvwStore; v,w: tNode; val: LONGREAL);
(* Fuer die Knoten 'v' und 'w' wird das Zwischenergebnis 'val' in
   'store' eingetragen.
*)
VAR FvwI: tFvw;
BEGIN
    FvwI:= Type.NewI(FvwId);
    FvwI^.v:= v;
    FvwI^.w:= w;
    FvwI^.val:= val;
    Hash.Insert(store, FvwI);
END FvwEnter;

PROCEDURE FvwGet(store: tFvwStore; v,w: tNode): LONGREAL;
(* Funktionsergebnis ist das in 'store' eingetragene Zwischenergebnis
   fuer die Knoten 'v' und 'w'. Falls fuer die beiden Knoten keine
   Eintragung vorhanden ist, wird 0 zurueckgegeben.
*)
VAR FvwI, SearchI: tFvw;
    found: BOOLEAN;
    res: LONGREAL;
BEGIN
    IF v = w THEN RETURN 1.0 END;

    SearchI:= Type.NewI(FvwId);
    SearchI^.v:= v;
    SearchI^.w:= w;
    IF Hash.Stored(store, SearchI, FvwI) THEN
        res:= FvwI^.val
    ELSE
        res:= 0.0
    END;
    Type.DelI(FvwId, SearchI);

    RETURN res
END FvwGet;

PROCEDURE FvwGetOp(prog: List.tList; store: tFvwStore;
                   v: tNode; w: tOp): LONGREAL;
(* ... analog 'FvwGet', jedoch muss 'w' ein Operator sein *)
VAR wNode: tNode;
    res: LONGREAL;
BEGIN
    CASE w^.vOpType OF
        indeterminate, constant:
            res:= 0.0
      | node:
            wNode:= OpGetNode(prog, w);
            res:= FvwGet(store, v, wNode)
    END;
    RETURN res
END FvwGetOp;

(* ------------------------------------------------------ *)
(* Algorithmusteil 'Ausfuehrung des Berechnungsprogramms' *)
(* ('BuildProgram' und zugehoerige Prozeduren) :          *)

TYPE tContext = RECORD (* Berechnungskontext fuer das auszufuehrende
                          Programm *)
                    AllDone: BOOLEAN;
                        (* TRUE: alle Berechnungen sind durchgefuehrt;
                                 der letzte Programmknoten enthaelt
                                 das Gesamtergebnis *)
                    Fvw: tFvwStore;
                END;

PROCEDURE ContextUse(VAR c: tContext);
(* Bevor eine Variable vom Typ 'tContext' benutzt wird, ist fuer
   diese Variable 'ContextUse' zur Initialisierung aufzurufen.
*)
BEGIN
    c.AllDone:= FALSE;
    FvwUse(c.Fvw)
END ContextUse;

PROCEDURE ContextDontUse(VAR c: tContext);
(* Wenn eine Variable vom Typ 'tContext' nicht mehr benutzt werden
   soll, muss 'ContextDontUse' fuer diese Variable aufgerufen werden,
   damit der fuer die Variable angelegte Speicherplatz wieder frei-
   gegeben wird.
*)
BEGIN
    FvwDontUse(c.Fvw);
END ContextDontUse;

PROCEDURE ComputeDegrees(prog: List.tList);
(* Fuer alle Knoten in 'prog' werden deren Grade berechnet und in
   den Datensaetzen der Knoten gespeichert.
*)
VAR node: tNode;
    hilf: tOp;
    deg1, deg2: LONGCARD;
BEGIN
    List.First(prog);
    WHILE List.MoreData(prog) DO
        node:= NodeGetCur(prog);

        deg1:= OpGetDeg(prog, node^.op1);
        deg2:= OpGetDeg(prog, node^.op2);
        IF deg1 < deg2 THEN
            hilf:= node^.op1;
            node^.op1:= node^.op2;
            node^.op2:= hilf
        END;
        IF node^.add THEN
            node^.degree:= Func.MaxLCard(deg1, deg2)
        ELSE
            node^.degree:= deg1 + deg2
        END;
        node^.DegValid:= TRUE;

        List.Next(prog)
    END
END ComputeDegrees;

PROCEDURE OneRun(prog: List.tList);
(* Um eine bessere Fehlersuche zu ermoeglichen wird in 'OneRun'
   alternativ zum implementierten Algorithmus das in 'prog'
   enthaltene Programm in einem einzigen Listendurchlauf
   interpretiert.
*)
VAR n: tNode;
BEGIN
    Message("Det.(BGH.)OneRun", "Programmlaenge ");
    WriteCard(List.Count(prog), 0); WriteLn;
    List.First(prog);
    WHILE List.MoreData(prog) DO
        NodeExec(prog, NodeGetCur(prog));
        List.Next(prog)
    END;
    Message("Det.(BGH.)OneRun", "Programmergebnis ");
    WriteReal(NodeGetRes(NodeGetCur(prog)), 15, 6); WriteLn;
    
    List.First(prog);
    WHILE List.MoreData(prog) DO
        n:= NodeGetCur(prog);
        n^.ResValid:= FALSE;
        n^.res:= 0.0;
        List.Next(prog)
    END;
END OneRun;

PROCEDURE GetVa(prog, Va: List.tList; a: LONGCARD);
(* In 'Va' wird die Liste aller Elemente der Menge 'V_a' fuer das
   Programm 'prog' zurueckgegeben.
   (siehe Kapitel 'Parallele Berechnung von Termen')
*)
VAR cur: List.tPos;
    n: tNode;
BEGIN
    cur:= List.GetPos(prog);
    
    List.Empty(Va);
    List.First(prog);
    WHILE List.MoreData(prog) DO
        n:= NodeGetCur(prog);
        IF NOT n^.add THEN
            IF (NodeGetDeg(n) > a)
            AND (OpGetDeg(prog, n^.op1) <= a) THEN
                List.InsertBehind(Va, List.Cur(prog))
            END;
        END;
        List.Next(prog)
    END;

    List.SetPos(prog, cur);
END GetVa;

PROCEDURE GetVa1(prog, Va1: List.tList; a: LONGCARD);
(* In 'Va1' wird die Liste aller Elemente der Menge  V'_a  fuer das
   Programm 'prog' zurueckgegeben.
   (siehe Kapitel 'Parallele Berechnung von Termen')
*)
VAR cur: List.tPos;
    n: tNode;
BEGIN
    cur:= List.GetPos(prog);

    List.Empty(Va1);
    List.First(prog);
    WHILE List.MoreData(prog) DO
        n:= NodeGetCur(prog);
        IF n^.add THEN
            IF (NodeGetDeg(n) > a)
            AND (OpGetDeg(prog, n^.op2) <= a) THEN
                List.InsertBehind(Va1, List.Cur(prog))
            END;
        END;
        List.Next(prog)
    END;

    List.SetPos(prog, cur);
END GetVa1;

PROCEDURE ComputeFw(prog: List.tList; FvwStore: tFvwStore;
                    Va, Va1: List.tList);
(* Es wird mit Hilfe der Knotenlisten 'Va' und 'Va1' sowie der
   Zwischenergebnisse 'FvwStore' das Ergebnis des aktuellen
   Knotens von 'prog' berechnet und im Datensatz des Knotens
   in 'prog' gespeichert.
*)
VAR cur: List.tPos;
    w: tNode;
        (* aktuelles Element von 'prog' *)
    res: LONGREAL; (* f(w) *)
    fu1, fu2, fuw: LONGREAL;
        (* zur Berechnung von 'res' benutzte Ergebnisse vorangegangener
           Rechnungen *)
    u: tNode;
        (* aktuelles Element von 'Va' bzw. 'Va1' *)
    AddList: Reli.tReli;
BEGIN
    Reli.Use(AddList);
    cur:= List.GetPos(prog);
    w:= NodeGetCur(prog);

    Pram.ParallelStart("Det.ComputeFw");
    List.First(Va);
    WHILE List.MoreData(Va) DO
        u:= NodeGetCur(Va);

        fuw:= FvwGet(FvwStore, u, w);
        fu1:= OpGetRes(prog, u^.op1);
        fu2:= OpGetRes(prog, u^.op2);
        Reli.InsertBehind(AddList, fu1 * fu2 * fuw);

        Pram.Prozessoren(1);
        Pram.Schritte(2);
        Pram.NaechsterBlock("Det.ComputeFw");
        List.Next(Va)
    END;

    List.First(Va1);
    WHILE List.MoreData(Va1) DO
        u:= NodeGetCur(Va1);

        fuw:= FvwGet(FvwStore, u, w);
        fu2:= OpGetRes(prog, u^.op2);
        Reli.InsertBehind(AddList, fu2 * fuw );

        Pram.Prozessoren(1);
        Pram.Schritte(1);
        Pram.NaechsterBlock("Det.ComputeFw");
        List.Next(Va1)
    END;
    Pram.ParallelEnde("Det.ComputeFw");

    res:= Pram.AddList(AddList);
        (* Alle Summanden werden nach der Binaerbaummethode addiert.
           Der Aufwand dafuer wird in 'Pram.AddList' gezaehlt. *)
 
    List.SetPos(prog, cur);
    w^.res:= res;
    w^.ResValid:= TRUE;
    List.DontUse(AddList);
END ComputeFw;

PROCEDURE GetV(vList, prog: List.tList; from, to: LONGCARD);
(* Fuer den aktuellen Knoten 'w' von 'prog' werden alle potentiellen
   Knoten 'v' aus 'prog' herausgesucht, so dass der Grad von f(v;w)
   mindestens 'from' und hoechstens 'to' betraegt. In 'vList' wird eine
   Liste dieser Knoten zurueckgegeben.
   Es wird nicht geprueft, ob fuer einen bestimmten Knoten 'v' der Wert
   von 'f(v;w)' ungleich Null ist.
*)
VAR cur: List.tPos;
    w: tNode;
        (* aktueller Knoten von 'prog' beim Prozeduraufruf *)
    v: tNode;
    deg: LONGCARD;
        (* Grad von f(v;w) *)
BEGIN
    cur:= List.GetPos(prog);
    w:= NodeGetCur(prog);
    v:= NIL;
    List.Empty(vList);

    List.First(prog);
    REPEAT
        v:= NodeGetCur(prog);
        deg:= NodeGetDeg(w) - NodeGetDeg(v);
        IF (from <= deg) AND (deg <= to) THEN
            List.InsertBehind(vList, List.Cur(prog))
        END;
        List.Next(prog);
    UNTIL NOT List.MoreData(prog) OR (v = w);

    List.SetPos(prog, cur);
END GetV;

PROCEDURE ComputeFvw(vList, prog: List.tList; FvwStore: tFvwStore;
                     from: LONGCARD);
(* Der aktuelle Knoten von 'prog' werde mit 'w' bezeichnet. Fuer
   alle Knoten 'v' in 'vList' werden die Zwischenergebnisse der
   Form  f(v;w)  (siehe Kapitel 'Parallele Berechnung von Termen')
   berechnet und in 'FvwStore' abgelegt. Alle bereits vorher berech-
   neten Ergebnisse muessen in 'FvwStore' abgelegt sein. In 'from'
   muss der Grad uebergeben werden, den die 'f(v;w)' mindestens haben
   muessen. (Der maximale Grad wird automatisch bestimmt.)
*)
VAR cur: List.tPos;
    a: LONGCARD;
    Va, Va1: List.tList;
    w: tNode;
        (* aktueller Knoten von 'prog' beim Prozeduraufruf *)
    v,u: tNode;
    res: LONGREAL; (* f(v;w) *)
    fu2, fvu1, fuw, fvu2: LONGREAL;
        (* Zwischenergebnisse zur Berechnung von 'res' *)
    AddList: Reli.tReli;
BEGIN
    Reli.Use(AddList);
    cur:= List.GetPos(prog);
    List.Use(Va, NodeId); List.AddRef(Va);
    List.Use(Va1, NodeId); List.AddRef(Va1);
    w:= NodeGetCur(prog);
 
    List.First(vList);
    WHILE List.MoreData(vList) DO
        List.Empty(AddList);
        v:= NodeGetCur(vList);
        a:= NodeGetDeg(v) + from;
        GetVa(prog, Va, a);
        GetVa1(prog, Va1, a);

        Pram.ParallelStart("Det.ComputeFvw");
        List.First(Va);
        WHILE List.MoreData(Va) DO
             u:= NodeGetCur(Va);
             
             fuw:= FvwGet(FvwStore, u, w);
             fvu1:= FvwGetOp(prog, FvwStore, v, u^.op1);
             IF (fuw # 0.0) AND (fvu1 # 0.0) THEN
                 fu2:= OpGetRes(prog, u^.op2);
                 Reli.InsertBehind(AddList, fu2 * fvu1 * fuw);

                 Pram.Prozessoren(1);
                 Pram.Schritte(2);
                 Pram.NaechsterBlock("Det.ComputeFvw")
             END;

             List.Next(Va)
        END;

        List.First(Va1);
        WHILE List.MoreData(Va1) DO
             u:= NodeGetCur(Va1);

             fvu2:= FvwGetOp(prog, FvwStore, v, u^.op2);
             fuw:= FvwGet(FvwStore, u, w);
             res:= res + (fvu2 * fuw);

             Pram.Prozessoren(1);
             Pram.Schritte(1);
             Pram.NaechsterBlock("Det.ComputeFvw");
             List.Next(Va1)
        END;
        Pram.ParallelEnde("Det.ComputeFvw");

        res:= Pram.AddList(AddList);
        FvwEnter(FvwStore, v, w, res);
        List.Next(vList)
    END;

    List.DontUse(Va);
    List.DontUse(Va1);
    List.SetPos(prog, cur);
END ComputeFvw;

PROCEDURE PerformStage(prog: List.tList; stage: LONGCARD;
                       VAR context: tContext);
(* Fuer das Program 'prog' wird Berechnungsstufe 'stage' mit dem
   Berechnungskontext 'context' durchgefuehrt. *)
VAR DegFrom, (* kleinster / ... *)
    DegTo (* ... groesster Grad der f(w) und f(v;w), die in Stufe
                 'stage' zu berechnen sind *)
        :LONGCARD;
    deg: LONGCARD;
        (* Grad des aktuellen Knotens *)
    vList: List.tList;
        (* Liste aller v fuer aktuellen Knoten w zur Berechnung von
           f(v;w) *)
    a: LONGCARD;
        (* Knotengrad fuer die Listen V_a und V'_a *)
    Va: List.tList;
        (* Liste der Knoten V_a *)
    Va1: List.tList;
        (* Liste der Knoten V'_a *)
BEGIN
    context.AllDone:= TRUE;
    List.Use(vList, NodeId); List.AddRef(vList);
    List.Use(Va, NodeId);    List.AddRef(Va);
    List.Use(Va1, NodeId);   List.AddRef(Va1);

    IF stage = 0 THEN
        DegFrom:= 1;
        DegTo:= 1
    ELSE
        DegFrom:= LReal2LCard(
                      power( 2.0, LCard2LReal(stage - 1) )
                  ) + 1;
        DegTo:= LReal2LCard(  power( 2.0, LCard2LReal(stage) )  )
    END;

    a:= DegFrom;
    GetVa(prog, Va, a);
    GetVa1(prog, Va1, a);

    Pram.ParallelStart("Det.PerformStage");
    List.First(prog);
    WHILE List.MoreData(prog) DO
        deg:= NodeGetDeg(NodeGetCur(prog));
        IF (DegFrom <= deg) AND (deg <= DegTo) THEN
            context.AllDone:= FALSE;
            ComputeFw(prog, context.Fvw, Va, Va1);
            Pram.NaechsterBlock("Det.PerformStage")
        END
    END;
    Pram.ParallelEnde("Det.PerformStage");
        
    Pram.ParallelStart("Det.PerformStage:2");
    List.First(prog);
    WHILE List.MoreData(prog) DO
        GetV(vList, prog, DegFrom, DegTo);
        IF List.Count(vList) > 0 THEN
            context.AllDone:= FALSE;
            ComputeFvw(vList, prog, context.Fvw, DegFrom);
            Pram.NaechsterBlock("Det.PerformStage:2");
        END;
        List.Next(prog);
    END;
    Pram.ParallelEnde("Det.PerformStage:2");
    
    List.DontUse(vList);
    List.DontUse(Va);
    List.DontUse(Va1)
END PerformStage;

PROCEDURE AllDone(VAR context: tContext): BOOLEAN;
(* Falls der Berechnungskontext 'context' angibt, dass alle Berech-
   nungen fuer das zugrunde liegende Programm durchgefuehrt sind,
   ist das Funktionsergebnis TRUE. *)
BEGIN
    RETURN context.AllDone
END AllDone;

PROCEDURE ExecProgram(prog: List.tList): LONGREAL;
(* Das in 'prog' enthaltene Programm wird ausgefuehrt. Das Ergebnis
   der letzten Anweisung des Programms wird als Funktionswert zurueck-
   gegeben.
*)
VAR stage: LONGCARD;
    context: tContext;
BEGIN
    ContextUse(context);
    ComputeDegrees(prog);
    
    IF BGHDebug THEN
        OneRun(prog)
    END;

    stage:= 0;
    REPEAT
        PerformStage(prog, stage, context);
        INC(stage)
    UNTIL AllDone(context);

    IF BGHDebug THEN
        Message("Det.(BGH.)ExecProgram",
            "Anzahl der Berechnungsstufen ");
        WriteCard(stage, 0); WriteLn
    END;

    ContextDontUse(context);
    List.Last(prog);
    RETURN NodeGetRes(NodeGetCur(prog))
END ExecProgram;

(* ------------------------------------------------ *)
(* exportierte Prozedur zum Aufruf des Algorithmus: *)

PROCEDURE BGH(a: tMat): LONGREAL;
VAR aCopy: Rema.tMat; (* Arbeitskopie von 'a' *)
    det: LONGREAL; (* Determinate von 'a' *)
    m2:  LONGREAL;
        (* Faktor zur Berechung der Determinante der Ursprungs-
           matrix 'a' aus der Determinante einer konvertieren
           Repraesentation von 'a' *)
    prog: List.tList;
        (* Programm (im Sinne des Kapitels 'Parallele Berechnung
           von Termen) zur Berechnung der Determinate von 'a' *)
BEGIN
    CheckSquare(a,"Det.BGH");
    IF Rows(a) = 1 THEN
        RETURN Elem(a,1,1)
    END;
    vMaxDeg:= Rows(a);
    List.Use(prog, NodeId);
    aCopy:= Rema.Copy(a);

    ConvertMat(aCopy, m2);
    BuildProgram(prog, aCopy);
    det:= ExecProgram(prog) * m2;

    List.DontUse(prog);
    Rema.DontUse(aCopy);

    RETURN det
END BGH;

(**************************************)
(***** Algorithmus von Berkowitz: *****)

PROCEDURE EpsilonMult(VAR res: List.tList; start, MultMat: tMat;
              OneStep, maximum: LONGINT; RightMult: BOOLEAN);
(* Die Matrix 'start' wird so oft mit der Matrix 'MultMat'
   multipliziert, wie 'maximum' angibt. Sowohl das Endergebnis
   als auch alle Zwischenergebnisse und 'start' selbst werden
   in der Liste 'res' zurueckgegeben.
   Bei 'RightMult = TRUE' wird 'start' von rechts mit 'MultMat'
   multipliziert, sonst von links.
   'res' wird in 'EplilonMult' angelegt. 'OneStep' muss angeben,
   wieviele Potenzen von 'MultMat' in einem Schleifendurchlauf
   berechnet werden sollen.
*)
VAR
    Y: Mali.tMali; (* Liste der Potenzen von 'MultMat' *)
    X: Mali.tMali; (* Liste neuer Elemente fuer Z *)
    Z: Mali.tMali; (* potentielles Ergebnis fuer 'res' *)
    ToBePowered: tMat;
        (* Potenz von 'MultMat', die ihrerseits im naechsten
           Schleifendurchlauf so oft potenziert wird, wie
           'OneStep' angibt *)
    i: LONGCARD; (* Schleifenzaehler *)
    hilf: LONGCARD;
BEGIN
    IF OneStep < 1 THEN OneStep:= 1 END;
  
    Mali.Use(Y);
    Mali.Use(X);
    Mali.Use(Z);

    Mali.InsertBehind( Z, Rema.Copy(start) );
    ToBePowered:= Rema.Copy(MultMat);

    WHILE List.Count(Z) < (LONGCARD(maximum + 1)) DO
        (* berechne Vektor 'Y': *)
        MultLadnerFischer(Y, ToBePowered, OneStep);
        (* Der Aufwand wird in 'MultLadnerFischer' gezaehlt. *)

        (* Die letzte Potenz wird fuer den naechsten Durchlauf
           aufgehoben: *)
        List.Last(Y);
        ToBePowered:= Mali.OutCur(Y);
        
        (* berechne Vektor 'X' aus 'Z' und 'Y': *)
        List.First(Y);
        Pram.ParallelStart("Det.EpsilonMult");
        REPEAT
            List.First(Z);
            Pram.ParallelStart("Det.EpsilonMult:2");
            REPEAT
                IF RightMult THEN
                    Mali.InsertBehind(X,
                        Rema.CreateMult(
                             Mali.Cur(Z), Mali.Cur(Y)
                        )
                    )
                ELSE
                    Mali.InsertBehind(X,
                        Rema.CreateMult(
                            Mali.Cur(Y), Mali.Cur(Z)
                        )
                    )
                END;
                (* Der Aufwand wird in 'Rema.CreateMult' gezaehlt. *)

                List.Next(Z);
                Pram.NaechsterBlock("Det.EpsilonMult:2");
            UNTIL NOT List.MoreData(Z);
            Pram.ParallelEnde("Det.EpsilonMult:2");

            List.Next(Y);
            Pram.NaechsterBlock("Det.EpsilonMult");
        UNTIL NOT List.MoreData(Y);
        Pram.ParallelEnde("Det.EpsilonMult");
        List.Empty(Y);
        
        (* haenge 'X' an 'Z': *)
        List.Last(Z);
        List.First(X);
        REPEAT
            Mali.InsertBehind(Z, Mali.OutCur(X))
        UNTIL (List.Count(X) = 0) OR (List.Count(Z) = LONGCARD(maximum + 1))
    END;

    List.DontUse(Y);
    List.DontUse(X);
    res:= Z
END EpsilonMult;

PROCEDURE GetM(a: tMat; i: LONGCARD): tMat;
(* Funktionsergebnis ist 'M_i' *)
VAR M: tMat; (* Funktionsergebnis *)
    n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    r, c: LONGCARD; (* Schleifenzaehler *)
BEGIN
    n:= Rows(a);
    IF i >= n THEN
        Error("Det.GetM", "M_i existiert nicht (i zu gross)")
    END;
    n:= Rows(a);
    Rema.Use(M, LCard2Card(n-i), LCard2Card(n-i));
    FOR r:= i+1 TO n DO
        FOR c:= i+1 TO n DO
            Rema.Set(M, LCard2Card(r-i), LCard2Card(c-i),
                     Rema.Elem(a, LCard2Card(r), LCard2Card(c)))
        END
    END;
    RETURN M
END GetM;

PROCEDURE GetR(a: tMat; i: LONGCARD): tMat;
(* Funktionsergebnis ist 'R_i' *)
VAR R: tMat; (* Funktionsergebnis *)
    n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    count: LONGCARD; (* Schleifenzaehler *)
BEGIN
    n:= Rows(a);
    IF i >= n THEN
        Error("Det.GetR", "R_i existiert nicht (i zu gross)")
    END;
    n:= Rows(a);
    Rema.Use(R, 1, n-i);
    FOR count:= i+1 TO n DO
        Rema.Set(R, 1, count - i,
                 Rema.Elem(a, i, count))
    END;
    RETURN R
END GetR;

PROCEDURE ComputeU(VAR U: Mali.tMali; i: LONGCARD; a: tMat);
(* In 'a' muss die Matrix uebergeben werden, deren Determinante
   zu berechnen ist.
   Die Prozedur berechnet den Vektor 'U_i' und gibt ihn
   in 'U' zurueck.
   'U' wird in 'ComputeU' angelegt.
*)
VAR n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    m: LONGCARD;
           (* hoechster Exponent von 'M' im zu berechnenden
              Vektor 'T' *)
    mRoot: LONGCARD; (* \lceil m^{0.5} \rceil *)
    mRootM1: LONGCARD;
    mEpsilon: LONGCARD; (* \lceil m^{epsilon} \rceil *)
    M, R: Rema.tMat; (* 'M_i' und 'R_i' *)
BEGIN
    n:= Rema.Rows(a);
    IF n-i-1 >= 0 THEN
        m:= n - i - 1
    ELSE
        m:= 0
    END;
    mRoot:= LCard2Card( Func.Ceil(power(real(m), 0.5)) );
    mEpsilon:= LCard2Card(
                   Func.Ceil(power( real(m), BerkEpsilon ))
               );
    M:= GetM(a, i);
    R:= GetR(a, i);

    IF mRoot > 0 THEN
        mRootM1:= mRoot - 1
    ELSE
        mRootM1:= 0
    END;
    EpsilonMult(U, R, M, mEpsilon, mRootM1, TRUE);

    Rema.DontUse(M);
    Rema.DontUse(R)
END ComputeU;

PROCEDURE ComputeMPower(a: tMat; i: LONGCARD): tMat;
(* Das Funktionsergebnis ist die Startpotenz von 'M_i' fuer
   die Prozedur 'ComputeV'. *)
VAR mat, res: Rema.tMat;
    count: LONGCARD;
    n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    m: LONGCARD;
           (* hoechster Exponent von 'M' im zu berechnenden
              Vektor 'T' *)
    mRoot: LONGCARD; (* \lceil m^{0.5} \rceil *)
    MatList: Mali.tMali;
BEGIN
    n:= Rows(a);
    IF n-i-1 >= 0 THEN
        m:= n-i-1
    ELSE
        m:= 0
    END;
    IF m > 0 THEN
        Mali.Use(MatList);
        mat:= GetM(a, i);
        mRoot:= LCard2Card( Func.Ceil(power( real(m), 0.5)) );

        FOR count:= 1 TO mRoot DO
            Mali.InsertBehind(MatList, Rema.Copy(mat))
        END;
        MultMatList(res, MatList, FALSE);
            (* Der Aufwand wird in 'MultMatList' gezaehlt. *)
        
        Rema.DontUse(mat);
        List.DontUse(MatList)
    ELSE
        Rema.Use(res, n, n);
        Rema.Unit(res)
    END;
    RETURN res
END ComputeMPower;

PROCEDURE GetS(a: tMat; i: LONGCARD): tMat;
(* Funktionsergebnis ist 'S_i' *)
VAR S: tMat; (* Funktionsergebnis *)
    n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    count: LONGCARD; (* Schleifenzaehler *)
BEGIN
    n:= Rows(a);
    IF i >= n THEN
        Error("Det.GetS", "S_i existiert nicht (i zu gross)")
    END;
    n:= Rows(a);
    Rema.Use(S, n-i, 1);
    FOR count:= i+1 TO n DO
        Rema.Set(S, count-i, 1, Rema.Elem(a, count, i))
    END;
    RETURN S
END GetS;

PROCEDURE ComputeV(VAR V: Mali.tMali; i: LONGCARD;
                   a: tMat; start: tMat);
(* In 'a' muss die Matrix uebergeben werden, deren Determinante
   zu berechnen ist.
   Die Prozedur berechnet den Vektor 'V_i' und gibt ihn
   in 'V' zurueck. 'V' wird in 'ComputeV' angelegt.
   In 'start' muss die Startpotenz der Matrix 'M_i' ueber-
   geben werden.
*)
VAR n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    m: LONGCARD;
           (* hoechster Exponent von 'M' im zu berechnenden
              Vektor 'T' *)
    mRoot: LONGCARD; (* \lceil m^{0.5} \rceil *)
    mEpsilon: LONGCARD; (* \lceil m^{epsilon} \rceil *)
    S: tMat; (* 'S_i' *)
BEGIN
    n:= Rows(a);
    IF n-i-1 >= 0 THEN
        m:= n - i - 1
    ELSE
        m:= 0
    END;
    mRoot:= LCard2Card( Func.Ceil(power( real(m), 0.5)) );
    mEpsilon:= LCard2Card(
                   Func.Ceil(power( real(m), BerkEpsilon ))
               );
    S:= GetS(a, i);

    EpsilonMult(V, S, start, mEpsilon, mRoot, FALSE);

    Rema.DontUse(S)
END ComputeV;

PROCEDURE ComputeNextTElem(U,V: Mali.tMali): LONGREAL;
(* Funktionsergebnis ist das durch die internen Zeiger von 'U' und
   'V' bestimmte naechste Element des Vektors 'T'. Die Inhalte von
   'U' und 'V' werden nicht veraendert.
*)
VAR u, v: tMat;
        (* aktuell in Bearbeitung befindliche Elemente aus
           'U' und 'V' *)
    i: LONGCARD;
        (* Schleifenzaehler *)
    length: LONGCARD;
        (* Anzahl der Elemente (bzw. Spalten) von 'u' *)
    res: LONGREAL;
        (* Funktionsergebnis *)
    AddList: Reli.tReli;
BEGIN
    Reli.Use(AddList);
    u:= Mali.Cur(U);
    v:= Mali.Cur(V);
    List.Next(U);
    IF NOT List.MoreData(U) THEN
        List.First(U);
        List.Next(V);
        IF NOT List.MoreData(V) THEN
            Error("Det.ComputeNextTElem",
                "Vektor V enthaelt zu wenig Elemente")
        END
    END;
    length:= Columns(u);

    FOR i:= 1 TO length DO
        Reli.InsertBehind(AddList, Elem(u,1,i) * Elem(v,i,1))
    END;
    (* Die Schleifendurchlaeufe werden parallel durchgefuehrt: *)
    Pram.Prozessoren(length);
    Pram.Schritte(1);

    res:= Pram.AddList(AddList);
        (* Der weitere Aufwand wird in 'Pram.AddList' gezaehlt. *)

    List.DontUse(AddList);
    RETURN res
END ComputeNextTElem;

PROCEDURE ComputeT(VAR T: Reli.tReli; i: LONGCARD; a: tMat);
(* Fuer die Matrix 'a' wird der Vektor T_i berechnet und als
   Liste von LONGREAL-Zahlen in 'T' zurueckgegeben. 'T' wird in
   'ComputeT' angelegt und initialisiert.
*)
VAR
    U, V: Mali.tMali;
           (* Die Vektoren 'U', und 'V' werden als Listen
              von Matrizen implementiert. *)
    n: LONGCARD;
        (* Anzahl der Zeilen und Spalten von 'a' *)
    k: LONGCARD; (* Schleifenzaehler *)
    mPower: tMat;
BEGIN
    n:= Rows(a);

    Reli.Use(T);

    IF n-i > 0 THEN (* n-i: Anzahl der Elemente von T *)
        (* Es ist nur etwas zu tun, wenn T nicht leer sein soll: *)

        (* berechne Vektor 'U': *)
        Pram.ParallelStart("Det.ComputeT");
            ComputeU(U, i, a);
        Pram.NaechsterBlock("Det.ComputeT");
            mPower:= ComputeMPower(a, i);
        Pram.ParallelEnde("Det.ComputeT");
        
        (* berechne Vektor 'V': *)
        ComputeV(V, i, a, mPower);
        Rema.DontUse(mPower);
        
        (* berechne Vektor 'T' aus 'U' und 'V': *)
        List.First(U); List.First(V);
        Pram.ParallelStart("Det.ComputeT:FOR");
        FOR k:= 1 TO n-i DO
            Reli.InsertBehind(T, ComputeNextTElem(U, V) );
            Pram.NaechsterBlock("Det.ComputeT:FOR")
        END;
        Pram.ParallelEnde("Det.ComputeT:FOR");
        
        List.DontUse(U);
        List.DontUse(V)
    END
END ComputeT;

PROCEDURE CreateC(VAR C: tMat; a: tMat;
                  index: LONGCARD; T: Reli.tReli);
(* Als 'C' wird die Matrix C_{index} zurueckgegeben. Sie wird
   aus 'T' und 'a' zusammengestellt. In 'a' muss die zugrunde-
   liegende Matrix, deren Determinante zu berechnen ist,
   uebergeben werden und in 'T' der zu C_{index} gehoerige
   Vektor T_{index} (implementiert als Liste von LONGREAL-Zahlen).
   'T' wird in 'CreateC' deinitalisiert.
   Bei 'index = Rows(a)' wird kein Vektor 'T' benoetigt. In
   diesem Fall muss 'NIL' als 'T' uebergeben werden. *)
VAR n: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    i: LONGCARD; (* Schleifenzaehler *)
BEGIN
    n:= Rows(a);
    Rema.Use(C, n-index+2, n-index+1);
    Set(C, 1, 1, -1.0);
    Set(C, 2, 1, Elem(a, index, index) );
    IF index < n THEN
        List.First(T);
        FOR i:= 3 TO Rows(C) DO
            IF NOT List.MoreData(T) THEN
                Error("Det.CreateC",
                    "Vektor T enthaelt zu wenig Elemente");
            END;
            Set(C, i, 1, Reli.OutCur(T) )
        END;
        SetToeplitz(C);
        List.DontUse(T)
    ELSE
        IF T # List.tList(NIL) THEN
            Error("Det.CreateC",
            "Programmfehler: nicht benoetigter Vektor T uebergeben");
        END
    END
END CreateC;

PROCEDURE Berkowitz(a: tMat): LONGREAL;
VAR t, (* Zaehler der Matrizen T *)
    c: (* Zaehler der Matrizen C *)
       LONGCARD;
    size: LONGCARD; (* Anzahl der Zeilen und Spalten von 'a' *)
    Tlist: List.tList; (* Liste der Vektoren T *)
    Clist: Mali.tMali; (* Liste der Matrizen C *)
        (* 'Tlist' und 'Clist' werden zur besseren Uebersichtlichkeit
           getrennt verwaltet. *)
    WorkMat: tMat; (* Arbeitsmatrix *)
    WorkList: List.tList; (* Arbeitsliste *)
    det: LONGREAL; (* Determinante von 'a' *)
BEGIN
    CheckSquare(a,"Det.Berkowitz");
    IF Rows(a) = 1 THEN
        RETURN Elem(a, 1, 1)
    END;

    size:= Rows(a);
    List.Use( Tlist, ListId );
    Mali.Use( Clist );

    Pram.ParallelStart("Det.Berkowitz");
    FOR t:= 1 TO size-1 DO
        ComputeT( WorkList, t, a );
        List.InsertBehind( Tlist, tPOINTER(WorkList) );
        Pram.NaechsterBlock("Det.Berkowitz")
    END;
    Pram.ParallelEnde("Det.Berkowitz");

    (* Baue anhand der Vektoren T die Matrizen C auf
       ( Da nur Zuweisungen durchgefuehrt werden, wird dafuer
         kein Aufwand fuer eine PRAM in Rechnung gestellt. ):
    *)
    List.First(Tlist);
    FOR c:= 1 TO size DO
        IF (c < size) AND NOT List.MoreData(Tlist) THEN
            Error("Det.Berkowitz",
                "Es wurden nicht alle Vektoren T berechnet.");
        END;
        IF List.MoreData(Tlist) THEN
            CreateC( WorkMat, a, c, Reli.tReli(List.OutCur(Tlist)) )
        ELSE
            CreateC( WorkMat, a, c, Reli.tReli(NIL) )
        END;
        Mali.InsertBehind( Clist, WorkMat )
    END;

    MultMatList(WorkMat, Clist, TRUE);
    IF BerkDebug THEN
        WriteString("*** Det.Berkowitz: Ergebnisvektor:"); WriteLn;
        Rema.Write(WorkMat)
    END;
    det:= Elem(WorkMat, size + 1, 1);

    Rema.DontUse(WorkMat);
    List.DontUse(Clist);
    List.DontUse(Tlist);
    RETURN det
END Berkowitz;

(********************************)
(***** Algorithmus von Pan: *****)

PROCEDURE GetKrylovVector(n: LONGCARD): tMat;
(* Als Funktionswert wird der fuer den Algorithmus gewaehlte Krylov-Vektor
   zurueckgegeben. In 'n' muss die gewuenschte Laenge des Vektors
   angegeben werden.
*)
VAR i: LONGCARD;
    z: tMat;
BEGIN
    Rema.Use(z, n, 1);
    FOR i:= 1 TO n DO
        Set(z, i, 1, 1.0)
    END;
    RETURN z
END GetKrylovVector;

PROCEDURE BuildMatrixFromVectors(l: Mali.tMali; VAR v: tMat);
(* In 'l' muss eine Liste gleichgrosser Matrizen 'bzw.' Vektoren
   uebergeben werden. Sie werden zu einer einzigen Matrix zusammenge-
   fasst und in 'v' zurueckgegeben.
   Die Vektoren in 'l' werden spaltenweise nebeneinander angeordnet.
*)
VAR r, c: LONGCARD; (* Zeilen bzw. Spalten von 'v' *)
    i, j: LONGCARD;
BEGIN
    List.First(l);
    r:= Rows( Mali.Cur(l) );
    c:= List.Count(l) * Columns(Mali.Cur(l)) ;
    Rema.Use(v, r, c);
    FOR j:= 1 TO c DO
        FOR i:= 1 TO r DO
            Set(v, i, j, Elem(Mali.Cur(l), i, 1) )
        END;
        List.Next(l)
    END
END BuildMatrixFromVectors;

PROCEDURE ComputeKrylovMatrix(a: tMat; VAR kry, vec: tMat);
(* In 'kry' wird die Krylov-Matrix zu 'a' zurueckgegeben und in
   'vec' der zugehoerige 'n+1'-te iterierte Vektor. *)
VAR old, new: Mali.tMali; (* Listen iterierter Vektoren *)
    power: tMat; (* aktuelle Potenz von 'a' *)
    n: LONGCARD;
        (* Anzahl der Zeilen und Spalten von 'a' *)
BEGIN
    n:= Rows(a);

    Mali.Use(old); Mali.Use(new);
    Rema.Use(power, n, n);

    Rema.Assign(a, power);
    Mali.InsertBehind(old, GetKrylovVector(n));

    WHILE List.Count(old) < n+1 DO
        List.First(old);
        Pram.ParallelStart("Det.ComputeKrylovMatrix");
        REPEAT
            Mali.InsertBehind(new, Rema.CreateMult(power, Mali.Cur(old)));
            List.Next(old);
            Pram.NaechsterBlock("Det.ComputeKrylovMatrix")
        UNTIL NOT List.MoreData(old);
        Pram.ParallelEnde("Det.ComputeKrylovMatrix");
        Rema.Mult(power, power, power);

        List.Last(old);
        List.First(new);
        WHILE List.MoreData(new) DO
            Mali.InsertBehind(old, Mali.OutCur(new))
        END
    END;
    
    List.Last(old);
    WHILE List.Count(old) > n+1 DO
        List.DelCur(old)
    END;
    vec:= Mali.OutCur(old);
    BuildMatrixFromVectors(old, kry);

    Rema.DontUse(power);
    List.DontUse(old); List.DontUse(new)
END ComputeKrylovMatrix;

PROCEDURE Transpose(a: tMat; VAR b: tMat);
VAR r,c: LONGCARD;
BEGIN
    Rema.Use(b, Columns(a), Rows(a));
    FOR r:= 1 TO Rows(a) DO
        FOR c:= 1 TO Columns(a) DO
            Set(b, c, r, Elem(a, r, c))
        END
    END
END Transpose;

PROCEDURE ColSum(m: tMat; c: LONGCARD): LONGREAL;
VAR k: LONGCARD;
    res: LONGREAL;
BEGIN
    res:= 0.0;
    FOR k:= 1 TO Rows(m) DO
        res:= res + ABS( Elem(m, k, c) )
    END;
    RETURN res
END ColSum;

PROCEDURE Norm1(m: tMat): LONGREAL;
VAR max: LONGREAL;
    k: LONGCARD;
BEGIN
    max:= ColSum(m, 1);
    FOR k:= 2 TO Columns(m) DO
        max:= Func.MaxReal( max, ColSum(m, k) )
    END;
    RETURN max
END Norm1;

PROCEDURE GetApproximatedInv(mat: tMat; VAR AproxInv: tMat);
VAR t: LONGREAL;
    mult: tMat;
BEGIN
    Transpose(mat, AproxInv);
    mult:= Rema.CreateMult(mat, AproxInv);
    t:= 1.0 / Norm1(mult);
    Rema.DontUse(mult);
    Rema.ScalMult(t, AproxInv, AproxInv)
END GetApproximatedInv;

PROCEDURE InvertIterative(mat: tMat; VAR inv: tMat);
(* In 'inv' wird die iterativ berechnete Inverse von 'mat' zurueck-
   gegeben. 'inv' wird in 'InvertIterative' neu angelegt. *)
VAR AproxInv: tMat;
    k,loops: LONGCARD;
    unit: tMat;
    bWork: tMat;
BEGIN
    GetApproximatedInv(mat, AproxInv);

    loops:= Func.Ceil( ld(  LCard2LReal(Rows(mat))  ) );

    Rema.Use(unit, Rows(mat), Columns(mat));
    Rema.ScalMult(2.0, unit, unit);
    Rema.Use(bWork, Rows(mat), Columns(mat));
    FOR k:= 1 TO loops DO
        Rema.Mult(AproxInv, mat, bWork);
        Rema.Sub(unit, bWork, bWork);
        Rema.Mult(bWork, AproxInv, AproxInv);
    END;
    Rema.DontUse(bWork);
    Rema.DontUse(unit);
    
    inv:= AproxInv
END InvertIterative;

PROCEDURE RoundReal(r: LONGREAL): LONGREAL;
BEGIN
    IF r >= 0.0 THEN
        RETURN LInt2LReal(Func.Floor(r + 0.5))
    ELSE
        RETURN LInt2LReal(Func.Ceil(r - 0.5))
    END
END RoundReal;

PROCEDURE RoundElements(a: tMat);
VAR r,c: LONGCARD;
BEGIN
    FOR r:= 1 TO Rows(a) DO
        FOR c:= 1 TO Columns(a) DO
            Set(a, r, c, RoundReal(Elem(a, r, c)))
        END
    END
END RoundElements;

PROCEDURE Pan(a: tMat): LONGREAL;
VAR kry: tMat; (* Krylov-Matrix zu 'a' *)
    vec: tMat; (* 'n+1'-ter iterierter Vektor zu 'a' *)
    inv: tMat; (* Inverse zu 'kry' *)
    koeff: tMat; (* Vektor der Koeffizienten des charakteristischen
                    Polynoms von 'a' *)
    n: LONGCARD;
    det: LONGREAL;
BEGIN
    CheckSquare(a, "Det.Pan");
    IF Rows(a) = 1 THEN
        RETURN Elem(a, 1, 1)
    END;

    n:= Rows(a);
    kry:= tMat(NIL);
    vec:= tMat(NIL);
    inv:= tMat(NIL);
    koeff:= tMat(NIL);

    ComputeKrylovMatrix(a, kry, vec);
    InvertIterative(kry, inv);
    koeff:= Rema.CreateMult(vec, inv);
    RoundElements(koeff);
    det:= Elem(koeff, n, 1);

    Rema.DontUse(koeff);
    Rema.DontUse(inv);
    Rema.DontUse(vec);
    Rema.DontUse(kry);

    RETURN det
END Pan;

BEGIN
    MatId:= Type.GetId("Rema.tMat");
    ListId:= Type.GetId("List.tList");
    
    NodeId:= Type.New(TSIZE(tNodeRec));
    Type.SetNewProc(NodeId, NewNodeI);
    Type.SetDelProc(NodeId, DelNodeI);
    
    OpId:= Type.New(TSIZE(tOpRec));
    Type.SetNewProc(OpId, NewOpI);
    
    SerId:= Type.Copy(Type.GetId("Frag.tFrag"));
    Type.SetNewProc(SerId, NewSerI);
    Type.SetDelProc(SerId, DelSerI);
    
    FvwId:= Type.New(TSIZE(tFvwRec));
    Type.SetEquProc(FvwId, EquFvwI);
    Type.SetHashProc(FvwId, HashFvwI)
END Det.

\end{verbatim}
\end{ImpModul}

