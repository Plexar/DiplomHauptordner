
\begin{ImpModul}{Rema}
\begin{verbatim}
 

IMPLEMENTATION MODULE Rema; (* REal MAtrix *)

(*          2-dimensionale LONGREAL-Matrizen
   
   (Erlaeuterungen im Definitionsmodul)
*)

FROM SYSTEM IMPORT TSIZE;
FROM InOut IMPORT WriteLn, WriteCard, ReadLCard,
                  ReadLReal, WriteReal, WriteString, ReadLn,
                  ReadString;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
IMPORT Sys, SysMath, Func, Rnd, Type, Frag, List, Simptype,
       Inli, Cali, Reli, Mat, Pram;
FROM Sys IMPORT tPOINTER;
FROM SysMath IMPORT LInt2LReal, LInt2Int, Int2LInt,
                    LReal2LInt,
                    Card2LCard, LCard2Card;
FROM Simptype IMPORT RealId, NewReal, pReal,
                     CardId, NewCard, pCard;
FROM Func IMPORT Error;

CONST RndCharSize= 50;
          (* maximale Groesse eines Elements der Matrix 'a'
             in 'Randomize' *)
      RndMixSize = 9.0;
          (* maximale Groessen von Elementen der Matrizen
             's' und 'si' in 'Randomize' *)
          
TYPE
    tMat= POINTER TO tMatRecord;
    tMatRecord= RECORD
                    longreal: BOOLEAN;
                        (* TRUE: die Matrizenelemente duerfen
                                 Nachkommastellen besitzen *)
                    rank: LONGCARD;
                        (* mit Hilfe von 'SetRank'
                           festgelegter Wert *)
                    mult: Cali.tCali;
                        (* LONGCARD-Liste mit gewuenschten
                           Vielfachheiten von Eigenwerten beim
                           Erzeugen durch 'Randomize' *)
                    det: LONGREAL;
                        (* Nachdem eine Matrix durch 'Randomize'
                           generiert wurde, steht in dieser
                           Komponente die Determinante der
                           generierten Matrix. *)
                    values : Mat.tMat
                END;
(* Prozeduren, die an die fuer 'values' verwendete
   Datenstruktur angepasst werden muessen:
       Use, DontUse, Elem und Set
*)

VAR ElemGen: Rnd.tGen;
        (* Zufallsgenerator fuer Matrizenelemente *)
    IntGen: Rnd.tGen;
        (* Zufallsgenerator zur Erzeugung von zu kombinierenden
           Zeilenindizes *)
    SignGen: Rnd.tGen;
        (* Zufallsgenerator zur Erzeugung von Vorzeichen *)
    MatId: Type.Id;
        (* Typnummer 'Rema.tMat' *)
 
PROCEDURE RemaNewI(hilf: tPOINTER);
VAR
    mat: tMat;
BEGIN
    mat:= hilf;
    Cali.Use(mat^.mult);
    Mat.Use(mat^.values, RealId())
END RemaNewI;

PROCEDURE Use(VAR mat: tMat; row, col: LONGCARD);
BEGIN
    mat:= tMat( Type.NewI(MatId) );
    SetSize(mat, row, col)
END Use;

PROCEDURE RemaDelI(hilf: tPOINTER);
VAR
    mat: tMat;
BEGIN
    mat:= hilf;
    List.DontUse(mat^.mult);
    Mat.DontUse(mat^.values);
END RemaDelI;

PROCEDURE DontUse(mat: tMat);
BEGIN
    Type.DelI(MatId, mat)
END DontUse;

PROCEDURE Empty(mat: tMat);
BEGIN
    Mat.Empty(mat^.values)
END Empty;

PROCEDURE Unit(mat: tMat);
VAR i: LONGCARD;
BEGIN
    Empty(mat);
    FOR i:= 1 TO Func.MinLCard(Rows(mat), Columns(mat)) DO
        Set(mat,i,i,1.0)
    END
END Unit;

PROCEDURE Assign(mat1, mat2: tMat);
VAR
    i,j: LONGCARD;
BEGIN
    IF (Rows(mat1) # Rows(mat2)) OR
       (Columns(mat1) # Columns(mat2))
    THEN
        Error("Mat.Assign",
            "Die Matrizen besitzen nicht die gleiche Groesse.")
    END;
    FOR i:= 1 TO Rows(mat1) DO
        FOR j:= 1 TO Columns(mat2) DO
            Set(mat2,i,j,Elem(mat1,i,j))
        END
    END
END Assign;

PROCEDURE Copy(mat1: tMat): tMat;
VAR res: tMat;
BEGIN
    Use(res, Rows(mat1), Columns(mat1));
    Assign(mat1, res);
    RETURN res
END Copy;

PROCEDURE Elem(mat: tMat; row, col: LONGCARD): LONGREAL;
VAR erg: pReal;
BEGIN
    IF (row > Rows(mat) ) OR
       (col > Columns(mat) )
    THEN
        Error("Mat.Elem",
            "Der verwendete Index ist zu gross.")
    END;
    erg:= pReal( Mat.Elem(mat^.values, row, col) );
    IF erg # pReal(NIL) THEN
        RETURN erg^
    ELSE
        RETURN 0.0
    END
END Elem;

PROCEDURE Set(mat: tMat; row, col: LONGCARD; val: LONGREAL);
VAR item: pReal;
BEGIN
    item:= NewReal(val);
    Mat.Set(mat^.values, row, col, item)
END Set;

PROCEDURE Rows(mat: tMat): LONGCARD;
BEGIN
    RETURN Mat.Rows(mat^.values)
END Rows;

PROCEDURE Columns(mat: tMat): LONGCARD;
BEGIN
    RETURN Mat.Columns(mat^.values)
END Columns;

PROCEDURE SetSize(mat: tMat; r,c: LONGCARD);
BEGIN
    Mat.SetSize(mat^.values, r, c);
    List.Empty(mat^.mult);
    Cali.InsertBefore(mat^.mult, 0);
    mat^.longreal:= FALSE;
    mat^.rank:= Func.MinLCard(r,c);
    mat^.det:= 0.0
END SetSize;

PROCEDURE SetReal(mat: tMat; real: BOOLEAN);
BEGIN
    mat^.longreal:= real
END SetReal;

PROCEDURE SetRank(mat: tMat; rank: LONGCARD);
BEGIN
    IF (rank <= 0) OR
       (Func.MinLCard( Rows(mat), Columns(mat) ) < rank)
    THEN
        Error("Mat.SetRank",
            "Der gewuenschte Rang ist zu gross.")
    END;
    mat^.rank:= rank
END SetRank;

PROCEDURE SetMultiplicity(mat: tMat; mult: LONGCARD);
(* Verbesserungsmoeglichkeit:
   Pruefung der Liste der Vielfachheiten auf Plausibilitaet *)
BEGIN
    List.First(mat^.mult);
    Cali.InsertBefore(mat^.mult,mult);
END SetMultiplicity;

PROCEDURE GetRndDiagonal(
              a: tMat; rank: LONGCARD;
              MultList: Cali.tCali; max: LONGCARD; decimal: BOOLEAN
          );
(* In 'a' wird eine zufaellig bestimmte Diagonalmatrix mit dem
   Rang 'rank' und Eigenwerten der in 'MultList' angegebenen
   Vielfachheiten. Die Elemente von 'a' besitzen hoechstens
   die Groesse 'max'. Falls in 'decimal' der Wert TRUE uebergeben
   wird, besitzen die Elemente von 'a' Nachkommastellen. *)
VAR
    num: LONGCARD;
        (* Nummer des Elements der Hauptdiagonalen, dass
           zu erzeugen ist *)
    mult: LONGCARD;
        (* aktuell zu verarbeitende Vielfachheit *)
    CharVal: LONGREAL;
        (* naechster zu verwendender Eigenwert zum Erzeugen
           der Diagonalmatrix *)
    size: LONGCARD;
        (* Minimum von Anzahl der Zeilen und Anzahl der Spalten
           von 'a' *)
BEGIN
    size:= Rows(a); (* Die Matrizen sind quadratisch. *)
    Empty(a);
    mult:= 0;
    List.First(MultList);
    num:= 1;
    IF decimal THEN
        Rnd.Range(ElemGen, 0.0,
            (LInt2LReal(max) / LInt2LReal(size)) );
        CharVal:= Rnd.LongReal(ElemGen)
    ELSE
        Rnd.Range(ElemGen, 1.0,
            LInt2LReal( max DIV size ));
        CharVal:= LInt2LReal(Rnd.Int(ElemGen))
    END;
    WHILE num <= rank DO
        IF mult <= 0 THEN
            Set(a, num, num, CharVal);
            IF decimal THEN
                CharVal:= CharVal + Rnd.LongReal(ElemGen)
            ELSE
                CharVal:= CharVal + LInt2LReal(Rnd.Int(ElemGen))
            END;
            IF NOT List.AtLast(MultList) THEN
                mult:= Cali.Cur(MultList);
                List.Next(MultList)
            ELSE
                mult:= 1
            END
        ELSE
            Set(a, num, num, Elem(a,num-1,num-1))
        END;
        INC(num);
        DEC(mult)
    END
END GetRndDiagonal;
 
PROCEDURE RndMixIndices(list: Cali.tCali; max: LONGCARD);
(* Diese Prozedur liefert in 'list' die Zahlen von 1 bis 'max'
   in zufaelliger Reihenfolge. *)
VAR
    MixArray: Frag.tFrag;
        (* Feld zum Mischen der Zeilenindizes *)
    i: LONGCARD; (* Zaehler *)
    SwapCount: LONGCARD;
        (* Anzahl der Vertauschungen von Elementen von
           'MixArray', die zur Produktion von Unordnung
           durchzufuehren sind *)
    hilf: tPOINTER;
        (* Hilfsvar. zum Vertauschen von Elementen in
           'MixArray' *)
    hilf2: pCard;
    i1, i2: LONGCARD;
        (* Indizes der zu vertauschenden Elemente in
           'MixArray' *)
BEGIN
    Frag.Use(MixArray, CardId(), 1, max);
    Rnd.Range(IntGen, 1.0, LInt2LReal(max) );
    SwapCount:= 3 * max;
    FOR i:= 1 TO max DO
        Frag.SetItem(MixArray, i, tPOINTER(NewCard(i)))
    END;
    Frag.AddRef(MixArray, TRUE);
    FOR i:= 1 TO SwapCount DO
        i1:= Rnd.Int(IntGen);
        i2:= Rnd.Int(IntGen);
        hilf:= Frag.GetItem(MixArray, i1);
        Frag.SetItem(MixArray, i1, Frag.GetItem(MixArray, i2));
        Frag.SetItem(MixArray, i2, hilf)
    END;
    Frag.AddRef(MixArray, FALSE);
    List.Empty(list);
    FOR i:= 1 TO max DO
        hilf2:= pCard( Frag.GetItem(MixArray, i) );
        Cali.InsertBehind(list, hilf2^)
    END;
    Frag.DontUse(MixArray)
END RndMixIndices;

PROCEDURE GetRndInverse(s,si: tMat; max: LONGREAL);
(* In 's' wird eine zufaellige invertierbare Matrix und in 'si'
   ihre Inverse zurueckgegeben. Die Elemente beider Matrizen sind
   ganzzahlig und ihr maximaler Betrag ist 'max'. *)
VAR
    MixedList: Cali.tCali;
        (* Liste der gemischten Zeilenindizes *)
    AddedList: Inli.tInli;
        (* Liste der zueinander addierten / voneinander
           subtrahierten Zeilen in 's'; die gleichen
           Zeilenoperationen werden in umgekehrter
           Reihenfolge verwendet, um 'si' zu
           berechnen; Bedeutung der Listenelemente:
           1.: Index der Zeile die addiert wird,
           2.: Index der Zeile zu der addiert wird,
           3.: verwendetes Vorzeichen
             ...
         *)
    In1, In2: LONGCARD;
        (* zu kombinierende Zeilen bzw. Spalten *)
    In: LONGCARD;
        (* aktueller Index beim Verknuepfen von Zeilen
           bzw. Spalten *)
    MaxElem: LONGREAL;
        (* maximaler Betrag eines Matrizenelements *)
    sign: LONGREAL;
        (* -1.0 : Zeilen in 's' werden voneinander abgezogen;
            1.0 : Zeilen in 's' werden zueinander addiert *)
    size: LONGCARD;
        (* Groesse von 's' und 'si' *)
BEGIN
    Cali.Use(MixedList);
    Inli.Use(AddedList);
    size:= Rows(s); (* Die Matrizen sind quadratisch. *)

    (* berechne 's': *)
    Unit(s);
    MaxElem:= 0.0;
    sign:= 1.0;
    REPEAT
        RndMixIndices(MixedList, size);
        List.First(MixedList);
        REPEAT
            In1:= LCard2Card( Cali.OutCur(MixedList) );
            In2:= LCard2Card( Cali.OutCur(MixedList) );
            FOR In:= 1 TO size DO
                Set(s, In2, In,
                        Elem(s, In2, In)
                        + Elem(s, In1, In) * sign
                );
                MaxElem:= Func.MaxReal(
                              MaxElem, ABS( Elem(s, In2, In) )
                          )
            END;
            Inli.InsertBefore(AddedList,
                LInt2Int( LReal2LInt(sign) )
            );
            Inli.InsertBefore(AddedList, In2);
            Inli.InsertBefore(AddedList, In1);
            sign:= LInt2LReal(Rnd.Int(SignGen)) * 2.0 - 1.0
                (* ergibt 1.0 oder -1.0 (!) *)
        UNTIL List.Count(MixedList) <= 1
    UNTIL MaxElem > (max / 2.0);

    (* berechne 'si': *)
    List.First(AddedList);
    Unit(si);
    WHILE List.Count(AddedList) > 0 DO
        In1:= Inli.OutCur(AddedList);
        In2:= Inli.OutCur(AddedList);
        sign:= LInt2LReal( Inli.OutCur(AddedList) );
        FOR In:= 1 TO size DO
            Set(si, In2, In, Elem(si, In2, In)
                             + Elem(si, In1, In) * (- sign)
            )
        END
    END;
    List.DontUse(MixedList);
    List.DontUse(AddedList)
END GetRndInverse;

PROCEDURE TestInverse(a,b: tMat);
(* Diese Prozedur dient zur Fehlersuche.
   Falls 'a' nicht die Inverse von 'b' ist, wird eine Fehlermeldung
   ausgegeben. *)
VAR
    res: tMat;
    i,j: LONGCARD;
    fehler: BOOLEAN;
    input: ARRAY [1..2] OF CHAR;
BEGIN
    Use(res, Rows(a), Columns(b));
    Mult(a, b, res);
    FOR i:= 1 TO Rows(res) DO
        FOR j:= 1 TO Columns(res) DO
            IF i = j THEN
                fehler:= Elem(res, i, j) # 1.0
            ELSE
                fehler:= Elem(res, i, j) # 0.0
            END;
            IF fehler THEN
                WriteString("*** Mat.TestInverse:"); WriteLn;
                WriteString("*** Matrizen nicht invers");
                WriteString(" zueinander"); WriteLn;
                WriteString("*** sollte Einheitsmatrix sein:");
                WriteLn;
                Write(res);
                WriteString("   <RETURN> ..."); ReadString(input);
                Write(a);
                WriteString("   <RETURN> ..."); ReadString(input);
                Write(b);
                HALT;
                RETURN
            END
        END
    END;
    WriteString("*** Mat.TestInverse: OK");
    WriteLn
END TestInverse;

PROCEDURE Randomize(mat: tMat);
VAR
    a, s, si, sa: tMat;
        (* a : zufaellig zu erzeugende Diagonalmatrix
           s : zufaellige invertierbare Matrix
           si: Inverse von 's'
           sa:= s * a

           Bedingungen fuer die Matrizengroesse (Indizes: i,j,k):
           - Voraussetzungen: mat: i*j, a: i*j
           - sa:= s * a  ==> s: k*i, sa: k*j
           - mat:= sa * si ==> si: j*j, k=i
           - si Inverse von s (damit 'mat' und 'a' die gleichen
             Eigenwerte besitzen) ==> i=j
        *)
    size: LONGCARD;
        (* Anzahl der Zeilen und Spalten der zu verarbeitenden
           Matrizen *)
BEGIN
    IF Rows(mat) # Columns(mat) THEN
        WriteLn;
        WriteString("*** Mat.Randomize:"); WriteLn;
        WriteString("*** Die zu erzeugende Matrix ist ");
        WriteString("nicht quadratisch."); WriteLn;
        HALT
    END;
    size:= Rows(mat);
    Use(a,size,size); Use(s,size,size);
    Use(sa,size,size); Use(si,size,size);

    (* erzeuge zufaellige Diagonalmatrix 'a': *)
    GetRndDiagonal(a, mat^.rank, mat^.mult,
                   Func.MaxLCard(size + 10, size * 2),
                   mat^.longreal);
    mat^.det:= Trace(a);

    (* berechne zufaellige invertierbare Matrix 's' sowie deren
       Inverse 'si' : *)
    GetRndInverse(s, si, RndMixSize);

    (* zur Fehlersuche: *)
    TestInverse(s, si);

    (* mat := s * a * si
       ('mat' hat dieselben Eigenwerte wie 'a'): *)
    Mult(s,a,sa);
    Mult(sa,si,mat);

    DontUse(a); DontUse(s); DontUse(si); DontUse(sa)
END Randomize;

PROCEDURE Det(mat: tMat): LONGREAL;
BEGIN
    RETURN mat^.det
END Det;

PROCEDURE Write(mat: tMat);
VAR
    row,col: LONGCARD;
    i, j: LONGCARD;
BEGIN
    row:= Rows(mat);
    col:= Columns(mat);
    WriteString("Zeilen: "); WriteLn;
    WriteString("    "); WriteCard(row,0); WriteLn;
    WriteString("Spalten: "); WriteLn;
    WriteString("    "); WriteCard(col,0); WriteLn;
    WriteString("Rang: "); WriteLn;
    WriteString("    "); WriteCard(mat^.rank, 0); WriteLn;
    WriteString("Determinante: "); WriteLn;
    WriteString("    "); WriteReal(mat^.det,12,4); WriteLn;
    WriteString("Nachkommastellen (1: ja, 0: nein): ");
    WriteLn; WriteString("    ");
    IF mat^.longreal THEN
        WriteCard(1,0)
    ELSE
        WriteCard(0,0)
    END;
    WriteLn;
    WriteString("Vielfachheiten ( >1 ) von Eigenwerten");
    WriteString(" (Anzahl, Wert 1, Wert 2, ...):");
    WriteLn;
    WriteCard(List.Count(mat^.mult) - 1, 5);
    List.First(mat^.mult);
    WHILE NOT List.AtLast(mat^.mult) DO
        WriteCard(Cali.Cur(mat^.mult),5);
        List.Next(mat^.mult)
    END;
    WriteLn;
        
    FOR i:= 1 TO row DO
        FOR j:= 1 TO col DO
            WriteReal(Elem(mat,i,j), 12, 4);
            WriteString(" ")
        END;
        IF col<=MaxIoRow THEN WriteLn END
    END
END Write;

PROCEDURE WriteF(VAR f: Sys.File; mat: tMat);
VAR
    row,col: LONGCARD;
    i, j: LONGCARD;
BEGIN
    row:= Rows(mat);
    col:= Columns(mat);
    Sys.WriteString(f, "Zeilen: "); Sys.WriteLn(f);
    Sys.WriteString(f,"    ");
    Sys.WriteCard(f, row, 0); Sys.WriteLn(f);

    Sys.WriteString(f, "Spalten: "); Sys.WriteLn(f);
    Sys.WriteString(f,"    ");
    Sys.WriteCard(f, col, 0); Sys.WriteLn(f);

    Sys.WriteString(f, "Rang: "); Sys.WriteLn(f);
    Sys.WriteString(f,"    ");
    Sys.WriteCard(f, mat^.rank, 0); Sys.WriteLn(f);

    Sys.WriteString(f, "Determinante: "); Sys.WriteLn(f);
    Sys.WriteString(f, "    ");
    Sys.WriteReal(f, mat^.det,12,4); Sys.WriteLn(f);

    Sys.WriteString(f, "Nachkommastellen (1: ja, 0: nein): ");
    Sys.WriteLn(f); Sys.WriteString(f,"    ");
    IF mat^.longreal THEN
        Sys.WriteCard(f, 1, 0)
    ELSE
        Sys.WriteCard(f, 0, 0)
    END;
    Sys.WriteLn(f);
    Sys.WriteString(f,
        "Vielfachheiten (groesser als 1) von Eigenwerten");
    Sys.WriteString(f, " (Anzahl, Wert 1, Wert 2, ...):");
    Sys.WriteLn(f);
    Sys.WriteCard(f, List.Count(mat^.mult) - 1, 5);
    List.First(mat^.mult);
    WHILE NOT List.AtLast(mat^.mult) DO
        Sys.WriteCard(f, LCard2Card( Cali.Cur(mat^.mult) ), 5);
        List.Next(mat^.mult)
    END;
    Sys.WriteLn(f);
        
    FOR i:= 1 TO row DO
        FOR j:= 1 TO col DO
            Sys.WriteReal(f, Elem(mat,i,j), 12, 4);
            IF j < col THEN
                Sys.WriteString(f, " ")
            END
        END;
        IF col<=MaxIoRow THEN Sys.WriteLn(f) END
    END
END WriteF;

PROCEDURE Read(mat: tMat);
VAR
    row,col: LONGCARD;
    i, j   : LONGCARD;
    hilf   : LONGCARD;
    num    : LONGREAL;
BEGIN
    ReadLn; ReadLCard(row);
    ReadLn; ReadLCard(col);
    SetSize(mat, row, col);
    ReadLn; ReadLCard(mat^.rank);
    ReadLn; ReadLReal(mat^.det);
    ReadLn; ReadLCard(hilf);
    mat^.longreal:=  hilf = 1;
    ReadLn; ReadLn;
    ReadLCard(hilf);
    FOR i:= 1 TO hilf DO
        ReadLCard(j);
        Cali.InsertBefore(mat^.mult, j)
    END;
    ReadLn;

    FOR i:= 1 TO row DO
        FOR j:= 1 TO col DO
            ReadLReal(num);
            Set(mat,i,j,num)
        END
    END
END Read;

PROCEDURE ReadF(VAR f: Sys.File; mat: tMat);
VAR
    row,col: LONGCARD;
    i, j   : LONGCARD;
    hilf: LONGCARD;
    num    : LONGREAL;
    dummy  : ARRAY [1..80] OF CHAR;
BEGIN
    Sys.ReadLn(f); Sys.ReadLCard(f,row);
    Sys.ReadLn(f); Sys.ReadLCard(f,col);
    SetSize(mat, row, col);
    Sys.ReadLn(f); Sys.ReadLCard(f,mat^.rank);
    Sys.ReadLn(f); Sys.ReadReal(f,mat^.det);
    Sys.ReadLn(f); Sys.ReadLCard(f,hilf);
    mat^.longreal:=  hilf = 1;
    Sys.ReadLn(f);
    Sys.ReadLCard(f, hilf);
    FOR i:= 1 TO hilf DO
        Sys.ReadLCard(f, j);
        Cali.InsertBefore(mat^.mult,j)
    END;

    FOR i:= 1 TO row DO
        FOR j:= 1 TO col DO
            Sys.ReadReal(f,num);
            Set(mat, i, j, num)
        END
    END
END ReadF;

PROCEDURE CheckEqualSize(a,b: tMat; proc: ARRAY OF CHAR);
(* Es wird eine Fehlermeldung ausgegeben, falls die Matrizen
   'a' und 'b' nicht die gleiche Groesse besitzen. *)
BEGIN
    IF (Rows(a) # Rows(b)) OR (Columns(a) # Columns(b)) THEN
        Error(proc,
            "Die Matrizen sind verschieden gross.");
    END
END CheckEqualSize;

PROCEDURE Add(mat1, mat2, res: tMat);
VAR
    i,j: LONGCARD;
    hilf: tMat;
    RowsMat1, ColumnsMat1: LONGCARD;
BEGIN
    Use(hilf,Rows(res),Columns(res));
    CheckEqualSize(mat1, mat2, "Mat.Add");
    CheckEqualSize(mat2, res, "Mat.Add");

    RowsMat1:= Rows(mat1); ColumnsMat1:= Columns(mat1);
    FOR i:= 1 TO RowsMat1 DO
        FOR j:= 1 TO ColumnsMat1 DO
            Set(hilf, i, j, Elem(mat1, i, j) + Elem(mat2, i, j))
        END
    END;
    (* Alle Schleifendurchlaeufe werden parallel durchgefuehrt: *)
    Pram.Prozessoren(RowsMat1 * ColumnsMat1);
    Pram.Schritte(1);

    Assign(hilf,res);
    DontUse(hilf)
END Add;

PROCEDURE Sub(mat1, mat2, res: tMat);
VAR
    i,j: LONGCARD;
    hilf: tMat;
    RowsMat1, ColumnsMat1: LONGCARD;
BEGIN
    Use(hilf,Rows(res),Columns(res));
    CheckEqualSize(mat1, mat2, "Mat.Sub");
    CheckEqualSize(mat2, res, "Mat.Sub");

    RowsMat1:= Rows(mat1); ColumnsMat1:= Columns(mat1);
    FOR i:= 1 TO RowsMat1 DO
        FOR j:= 1 TO ColumnsMat1 DO
            Set(hilf, i, j, Elem(mat1, i, j) - Elem(mat2, i, j))
        END
    END;
    (* Alle Schleifendurchlaeufe werden parallel durchgefuehrt: *)
    Pram.Prozessoren(RowsMat1 * ColumnsMat1);
    Pram.Schritte(1);

    Assign(hilf,res);
    DontUse(hilf)
END Sub;
            (* a*b, b*c, a*c *)
PROCEDURE Mult(mat1,mat2,res: tMat);
VAR
    i,j,k: LONGCARD;
    hilf: tMat;
    RowsRes, ColumnsRes, ColumnsMat1: LONGCARD;
    AddList: Reli.tReli;
BEGIN
    Reli.Use(AddList);
    Use(hilf, Rows(res), Columns(res));
    IF (Columns(mat1) # Rows(mat2)) OR
       (Rows(mat1) # Rows(res)) OR
       (Columns(mat2) # Columns(res))
    THEN
        Error("Mat.Mult",
            "Die Groessen der Matrizen passen nicht zusammen.")
    END;
    RowsRes:= Rows(res); ColumnsRes:= Columns(res);
    ColumnsMat1:= Columns(mat1);

    Pram.ParallelStart("Rema.Mult");
    FOR i:= 1 TO RowsRes DO
        Pram.ParallelStart("Rema.Mult:Zeile");
        FOR j:= 1 TO ColumnsRes DO
            List.Empty(AddList);

            FOR k:= 1 TO ColumnsMat1 DO
                Reli.InsertBehind(AddList,
                     Elem(mat1, i, k)*Elem(mat2, k, j)
                );
            END;
            (* Die Durchlaeufe der Schleife werden parallel durchge-
               fuehrt: *)
            Pram.Prozessoren( ColumnsMat1 );
            Pram.Schritte( 1 );

            Set( hilf, i, j, Pram.AddList(AddList) );

            Pram.NaechsterBlock("Rema.Mult:Zeile");
        END;
        Pram.ParallelEnde("Rema.Mult:Zeile");
 
        Pram.NaechsterBlock("Rema.Mult");
    END;
    Pram.ParallelEnde("Rema.Mult");

    Assign(hilf,res);
    DontUse(hilf);
    List.DontUse(AddList)
END Mult;

PROCEDURE CreateMult(mat1, mat2: tMat): tMat;
VAR res: tMat;
BEGIN
    Use(res, Rows(mat1), Columns(mat2));
    Mult(mat1, mat2, res);
    RETURN res
END CreateMult;

PROCEDURE ScalMult(num: LONGREAL; mat1,res: tMat);
VAR
    i,j: LONGCARD;
    RowsRes, ColumnsRes: LONGCARD;
BEGIN
    RowsRes:= Rows(res); ColumnsRes:= Columns(res);
    FOR i:= 1 TO RowsRes DO
        FOR j:= 1 TO ColumnsRes DO
            Set(res,i,j,num*Elem(mat1,i,j))
        END
    END;
    (* Alle Schleifendurchlaeufe werden parallel durchgefuehrt: *)
    Pram.Prozessoren( RowsRes * ColumnsRes );
    Pram.Schritte( 1 )
END ScalMult;

PROCEDURE Trace(mat: tMat): LONGREAL;
(* Das Funktionsergebnis ist die Summe der Elemente der
   Hauptdiagonalen (Spur) der angegebenen Matrix. *)
VAR
    res: LONGREAL;  (* Funktionsergebnis *)
    i: LONGCARD;
    size: LONGCARD; (* Groesse von 'mat' *)
    AddList: Reli.tReli;
BEGIN
    Reli.Use(AddList);
    size:= Func.MinLCard( Rows(mat), Columns(mat) );

    FOR i:= 1 TO size DO
        Reli.InsertBehind( AddList, Elem(mat, i, i) )
    END;
    res:= Pram.AddList(AddList);

    List.DontUse(AddList);
    RETURN res
END Trace;
    
BEGIN
    (* initialisiere Zufallsgeneratoren: *)
    Rnd.Use(ElemGen);
    Rnd.Use(IntGen);
    Rnd.Use(SignGen);
    Rnd.Range(SignGen, 0.0, 1.0);

    MatId:= Type.New(TSIZE(tMatRecord));
    Type.SetName(MatId, "Rema.tMat");
    Type.SetNewProc(MatId, RemaNewI);
    Type.SetDelProc(MatId, RemaDelI)
END Rema.

\end{verbatim}
\end{ImpModul}

