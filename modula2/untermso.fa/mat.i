
IMPLEMENTATION MODULE Mat;

(*           Matrizenrechnung
   
   (Erlaeuterungen im Definitionsmodul)
*)

FROM SYSTEM IMPORT TSIZE;
FROM InOut IMPORT WriteLn, WriteCard, ReadCard, ReadLCard,
                  ReadLReal, WriteReal, WriteString, ReadLn,
                  ReadString;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM SysMath IMPORT real, entier, ShortCard;
IMPORT Rnd, Type, List, IntList, CaLi, Func, Sys;
FROM Sys IMPORT tPOINTER;

CONST RndCharSize= 2 * ArrayMax;
          (* maximale Groesse eines Elements der Matrix 'a'
             in 'Randomize' *)
      RndMixSize = 9.0;
          (* maximale Groessen von Elementen der Matrizen
             's' und 'si' in 'Randomize' *)
          
TYPE
    tValues = ARRAY [1..ArrayMax],[1..ArrayMax] OF LONGREAL;
        (* Feld fuer Matrizenelemente *)
    tMat= POINTER TO tMatRecord;
    tMatRecord= RECORD
                    rows, columns: CARDINAL;
                        (* Anzahl der Zeilen und Spalten
                           der Matrix *)
                    longreal: BOOLEAN;
                        (* TRUE: die Matrizenelemente duerfen
                                 Nachkommastellen besitzen *)
                    rank: CARDINAL;
                        (* mit Hilfe von 'SetRank'
                           festgelegter Wert *)
                    mult: CaLi.tCaLi;
                        (* CARDINAL-Liste mit gewuenschten
                           Vielfachheiten von Eigenwerten beim
                           Erzeugen durch 'Randomize' *)
                    values : tValues
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
        (* Typnummer 'Matrix' *)
 
PROCEDURE MatNewI(hilf: tPOINTER);
VAR
    mat: tMat;
BEGIN
    mat:= hilf;
    CaLi.Use(mat^.mult)
END MatNewI;

PROCEDURE Use(VAR mat: tMat; row, col: CARDINAL);
BEGIN
    mat:= tMat( Type.NewI(MatId) );
    SetSize(mat, row, col)
END Use;

PROCEDURE MatDelI(hilf: tPOINTER);
VAR
    mat: tMat;
BEGIN
    mat:= hilf;
    List.DontUse(mat^.mult)
END MatDelI;

PROCEDURE DontUse(mat: tMat);
BEGIN
    Type.DelI(MatId, mat)
END DontUse;

PROCEDURE Empty(mat: tMat);
VAR i,j: CARDINAL;
BEGIN
    FOR i:= 1 TO Rows(mat) DO
        FOR j:= 1 TO Columns(mat)DO
            Set(mat,i,j,0.0)
        END
    END
END Empty;

PROCEDURE Unit(mat: tMat);
VAR i: CARDINAL;
BEGIN
    Empty(mat);
    FOR i:= 1 TO Func.MinCard(Rows(mat), Columns(mat)) DO
        Set(mat,i,i,1.0)
    END
END Unit;

PROCEDURE Assign(mat1, mat2: tMat);
VAR
    i,j: CARDINAL;
BEGIN
    IF (Rows(mat1) # Rows(mat2)) OR
       (Columns(mat1) # Columns(mat2))
    THEN
        WriteLn;
        WriteString("*** Mat.Assign:"); WriteLn;
        WriteString("*** die Matrizen besitzen nicht ");
        WriteLn;
        WriteString("die gleiche Groesse"); WriteLn;
        HALT
    END;
    FOR i:= 1 TO Rows(mat1) DO
        FOR j:= 1 TO Columns(mat2) DO
            Set(mat2,i,j,Elem(mat1,i,j))
        END
    END
END Assign;

PROCEDURE Elem(mat: tMat; row, col: CARDINAL): LONGREAL;
BEGIN
    IF (row > mat^.rows) OR
       (col > mat^.columns)
    THEN
        WriteLn;
        WriteString("*** Mat.Elem:"); WriteLn;
        WriteString("*** Index zu gross;"); WriteLn;
        WriteString("*** das angegebene Matrizenelement ");
        WriteLn;
        WriteString("existiert nicht"); WriteLn;
        HALT
    END;
    RETURN mat^.values[row,col]
END Elem;

PROCEDURE Set(mat: tMat; row,col: CARDINAL; val: LONGREAL);
BEGIN
    mat^.values[row,col]:= val
END Set;

PROCEDURE Rows(mat: tMat): CARDINAL;
BEGIN
    RETURN mat^.rows
END Rows;

PROCEDURE Columns(mat: tMat): CARDINAL;
BEGIN
    RETURN mat^.columns
END Columns;

PROCEDURE SetSize(mat: tMat; r,c: CARDINAL);
BEGIN
    IF (r > ArrayMax) OR (c > ArrayMax) THEN
        WriteString("*** Mat.SetSize:"); WriteLn;
        WriteString("*** Die gewuenschte Matrizengroesse kann");
        WriteString(" nicht verarbeitet werden."); WriteLn;
        WriteString("*** (ggf. Konstante 'ArrayMax' erhoehen)");
        WriteLn;
        HALT
    END;
    mat^.rows:= r;
    mat^.columns:= c;
    Empty(mat);
    List.Empty(mat^.mult);
    CaLi.InsertBefore(mat^.mult, 0);
    mat^.longreal:= FALSE;
    mat^.rank:= Func.MinCard(r,c)
END SetSize;

PROCEDURE SetReal(mat: tMat; real: BOOLEAN);
BEGIN
    mat^.longreal:= real
END SetReal;

PROCEDURE SetRank(mat: tMat; rank: CARDINAL);
BEGIN
    IF (rank <= 0) OR
       (Func.MinCard( Rows(mat), Columns(mat) ) < rank)
    THEN
        WriteLn;
        WriteString("*** Mat.SetRank:"); WriteLn;
        WriteString("*** Der gewuenschte Rang liegt ausserhalb ");
        WriteString("des erlaubten Bereiches."); WriteLn;
        HALT
    END;
    mat^.rank:= rank
END SetRank;

PROCEDURE SetMultiplicity(mat: tMat; mult: CARDINAL);
(* Verbesserungsmoeglichkeit:
   Pruefung der Liste der Vielfachheiten auf Plausibilitaet *)
BEGIN
    List.First(mat^.mult);
    CaLi.InsertBefore(mat^.mult,mult);
END SetMultiplicity;
(*$ d+,e+ *)
PROCEDURE GetRndDiagonal(
              a: tMat; rank: CARDINAL;
              MultList: CaLi.tCaLi; max: CARDINAL; decimal: BOOLEAN
          );
(* In 'a' wird eine zufaellig bestimmte Diagonalmatrix mit dem
   Rang 'rank' und Eigenwerten der in 'MultList' angegebenen
   Vielfachheiten. Die Elemente von 'a' besitzen hoechstens
   die Groesse 'max'. Falls in 'decimal' der Wert TRUE uebergeben
   wird, besitzen die Elemente von 'a' Nachkommastellen. *)
VAR
    num: CARDINAL;
        (* Nummer des Elements der Hauptdiagonalen, dass
           zu erzeugen ist *)
    mult: LONGCARD;
        (* aktuell zu verarbeitende Vielfachheit *)
    CharVal: LONGREAL;
        (* naechster zu verwendender Eigenwert zum Erzeugen
           der Diagonalmatrix *)
    size: CARDINAL;
        (* Minimum von Anzahl der Zeilen und Anzahl der Spalten
           von 'a' *)
BEGIN
    size:= Func.MinCard( Rows(a), Columns(a) );
    Empty(a);
    mult:= 0;
    List.First(MultList);
    num:= 1;
    IF decimal THEN
        Rnd.Range(ElemGen, 0.0,
            (real(max) / real(size)) );
        CharVal:= Rnd.LongReal(ElemGen)
    ELSE
        Rnd.Range(ElemGen, 1.0,
            real( max DIV size ));
        CharVal:= real(Rnd.Int(ElemGen))
    END;
    WHILE num <= rank DO
        IF mult <= 0 THEN
            Set(a, num, num, CharVal);
            IF decimal THEN
                CharVal:= CharVal + Rnd.LongReal(ElemGen);
            ELSE
                CharVal:= CharVal + real(Rnd.Int(ElemGen));
            END;
            IF NOT List.AtLast(MultList) THEN
                mult:= CaLi.OutCur(MultList)
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
 
PROCEDURE RndMixIndices(list: CaLi.tCaLi; max: CARDINAL);
(* Die Prozedur liefert in 'list' die Zahlen von 1 bis 'max'
   in zufaelliger Reihenfolge. *)
VAR
    MixArray: ARRAY [1..ArrayMax] OF CARDINAL;
        (* Feld zum Mischen der Zeilenindizes *)
    i: CARDINAL; (* Zaehler *)
    SwapCount: CARDINAL;
        (* Anzahl der Vertauschungen von Elementen von
           'MixArray', die zur Produktion von Unordnung
           durchzufuehren sind *)
    hilf: CARDINAL;
        (* Hilfsvar. zum Vertauschen von Elementen in
           'MixArray' *)
    i1, i2: CARDINAL;
        (* Indizes der zu vertauschenden Elemente in
           'MixArray' *)
BEGIN
    Rnd.Range(IntGen, 1.0, real(max) );
    SwapCount:= 3 * max;
    FOR i:= 1 TO max DO
        MixArray[i]:= i
    END;
    FOR i:= 1 TO SwapCount DO
        i1:= ShortCard( Rnd.Int(IntGen) );
        i2:= ShortCard( Rnd.Int(IntGen) );
        hilf:= MixArray[i1];
        MixArray[i1]:= MixArray[i2];
        MixArray[i2]:= hilf
    END;
    List.Empty(list);
    FOR i:= 1 TO max DO
        CaLi.InsertBehind(list,MixArray[i])
    END
END RndMixIndices;

PROCEDURE GetRndInvertible(s: tMat; max: LONGREAL);
(* In 's' wird eine zufaellige invertierbare Matrix 
   entsprechend den fuer 's' eingestellten Parametern
   zurueckgegeben. Ihre Elemente sind ganzzahlig und
   besitzen den maximalen Betrag 'max'. *)
VAR
    MixedList: CaLi.tCaLi;
        (* Liste der gemischten Zeilenindizes *)
    In1, In2: CARDINAL;
        (* zu kombinierende Zeilen bzw. Spalten *)
    In: CARDINAL;
        (* aktueller Index beim Verknuepfen von Zeilen
           bzw. Spalten *)
    MaxElem: LONGREAL;
        (* maximaler Betrag eines Matrizenelements *)
    sign: LONGREAL;
        (* -1.0 : Zeilen in 's' werden voneinander abgezogen;
            1.0 : Zeilen in 's' werden zueinander addiert *)
    size: CARDINAL;
        (* Groesse von 's'  *)
BEGIN
    CaLi.Use(MixedList);
    size:= Rows(s);
    Unit(s);
    MaxElem:= 0.0;
    sign:= 1.0;
    REPEAT
        RndMixIndices(MixedList, size);
        List.First(MixedList);
        REPEAT
            In1:= ShortCard( CaLi.OutCur(MixedList) );
            In2:= ShortCard( CaLi.OutCur(MixedList) );
            FOR In:= 1 TO size DO
                Set(s, In2, In,
                        Elem(s, In2, In)
                        + Elem(s, In1, In) * sign
                );
                MaxElem:= Func.MaxReal(
                              MaxElem, ABS( Elem(s, In2, In) )
                          );
                sign:= real(Rnd.Int(SignGen)) * 2.0 - 1.0
                    (* ergibt 1.0 oder -1.0 (!) *)
            END;
        UNTIL List.Count(MixedList) <= 1;
    UNTIL MaxElem > (max / 2.0);
    List.DontUse(MixedList)
END GetRndInvertible;

PROCEDURE GetInverse(s, si: tMat);
(* In 'si' wird die Inverse zu 's' zurueckgegeben. *)
VAR
    size: CARDINAL;
    i: CARDINAL
BEGIN
    Unit(si);
    size:= Rows(s);
    $$$$$
END GetInverse;

PROCEDURE GetRndInvertiblePair(s,si: tMat; max: LONGREAL);
(* In 's' wird eine zufaellige invertierbare Matrix und in 'si'
   ihre Inverse zurueckgegeben. Die Elemente beider Matrizen sind
   ganzzahlig und ihr maximaler Betrag ist 'max'. *)
BEGIN
    GetRndInvertible(s,max);
    GetInverse(s,si);
END GetRndInvertiblePair;

VAR
    MixedList: CaLi.tCaLi;
        (* Liste der gemischten Zeilenindizes *)
    In1, In2: CARDINAL;
        (* zu kombinierende Zeilen bzw. Spalten *)
    In: CARDINAL;
        (* aktueller Index beim Verknuepfen von Zeilen
           bzw. Spalten *)
    MaxElem: LONGREAL;
        (* maximaler Betrag eines Matrizenelements *)
    sign: LONGREAL;
        (* -1.0 : Zeilen in 's' werden voneinander abgezogen;
            1.0 : Zeilen in 's' werden zueinander addiert *)
    size: CARDINAL;
        (* Groesse von 's' und 'si' *)
BEGIN
    CaLi.Use(MixedList);
    size:= Func.MinCard( Rows(s), Columns(s));
    Unit(s); Unit(si);
    MaxElem:= 0.0;
    sign:= 1.0;
    REPEAT
        RndMixIndices(MixedList, size);
        List.First(MixedList);
        REPEAT
            In1:= ShortCard( CaLi.OutCur(MixedList) );
            In2:= ShortCard( CaLi.OutCur(MixedList) );
            FOR In:= 1 TO size DO
                Set(s, In2, In,
                        Elem(s, In2, In)
                        + Elem(s, In1, In) * sign
                );
                MaxElem:= Func.MaxReal(
                              MaxElem, ABS( Elem(s, In2, In) )
                          );
                Set(si, In2, In,
                        Elem(si, In2, In)
                        + Elem(si, In1, In) * (- sign)
                );
                MaxElem:= Func.MaxReal(
                              MaxElem, ABS( Elem(si, In2, In) )
                          );
                sign:= real(Rnd.Int(SignGen)) * 2.0 - 1.0;
                    (* ergibt 1.0 oder -1.0 (!) *)
            END;
        UNTIL List.Count(MixedList) <= 1;
    UNTIL MaxElem > (max / 2.0);
    List.DontUse(MixedList)
END GetRndInvertiblePair;

PROCEDURE TestInverse(a,b: tMat);
(* Falls 'a' nicht die Inverse von 'b' ist, wird eine Fehlermeldung
   ausgegeben. *)
VAR
    res: tMat;
    i,j: CARDINAL;
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
                HALT
            END
        END
    END
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
    size: CARDINAL;
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
    GetRndDiagonal(a, mat^.rank, mat^.mult, RndCharSize,
                   mat^.longreal);

    (* berechne zufaellige invertierbare Matrix 's' sowie deren
       Inverse 'si' : *)
    GetRndInvertibelPair(s, si, RndMixSize);
    (* zur Fehlersuche: *) TestInverse(s, si);

    (* mat := s * a * si
       ('mat' hat dieselben Eigenwerte wie 'a'): *)
    Mult(s,a,sa);
    Mult(sa,si,mat);

    DontUse(a); DontUse(s); DontUse(si); DontUse(sa)
END Randomize;

PROCEDURE Write(mat: tMat);
VAR
    row,col: CARDINAL;
    i, j: CARDINAL;
BEGIN
    row:= Rows(mat);
    col:= Columns(mat);
    WriteString("Zeilen: "); WriteLn;
    WriteString("    "); WriteCard(row,0); WriteLn;
    WriteString("Spalten: "); WriteLn; 
    WriteString("    "); WriteCard(col,0); WriteLn;
    WriteString("Rang: "); WriteLn; 
    WriteString("    "); WriteCard(mat^.rank, 0); WriteLn;
    WriteString("Nachkommastellen (1: ja, 0: nein): ");
    WriteLn; WriteString("    ");
    IF mat^.longreal THEN
        WriteCard(1,0)
    ELSE
        WriteCard(0,0)
    END;
    WriteLn;
    WriteString("Vielfachheiten (groesser als 1) von Eigenwerten");
    WriteString(" (Anzahl, Wert 1, Wert 2, ...):");
    WriteLn;
    WriteCard(List.Count(mat^.mult) - 1, 5);
    List.First(mat^.mult);
    WHILE NOT List.AtLast(mat^.mult) DO
        WriteCard(CaLi.Cur(mat^.mult),5);
        List.Next(mat^.mult)
    END;
    WriteLn;
        
    FOR i:= 1 TO row DO
        FOR j:= 1 TO col DO
            WriteReal(Elem(mat,i,j),12,4);
            WriteString(" ")
        END;
        IF col<=MaxIoRow THEN WriteLn END
    END
END Write;
(*$ d-,e- *)
PROCEDURE WriteF(VAR f: Sys.File; mat: tMat);
VAR
    row,col: CARDINAL;
    i, j: CARDINAL;
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
    Sys.WriteString(f, "Nachkommastellen (1: ja, 0: nein): ");
    Sys.WriteLn(f); Sys.WriteString(f,"    ");
    IF mat^.longreal THEN
        Sys.WriteCard(f,1,0)
    ELSE
        Sys.WriteCard(f,0,0)
    END;
    Sys.WriteLn(f);
    Sys.WriteString(f,
        "Vielfachheiten (groesser als 1) von Eigenwerten");
    Sys.WriteString(f, " (Anzahl, Wert 1, Wert 2, ...):");
    Sys.WriteLn(f);
    Sys.WriteCard(f, List.Count(mat^.mult) - 1, 5);
    List.First(mat^.mult);
    WHILE NOT List.AtLast(mat^.mult) DO
        Sys.WriteCard(f, ShortCard( CaLi.Cur(mat^.mult) ), 5);
        List.Next(mat^.mult)
    END;
    Sys.WriteLn(f);
        
    FOR i:= 1 TO row DO
        FOR j:= 1 TO col DO
            Sys.WriteReal(f, Elem(mat,i,j), 12, 4);
            Sys.WriteString(f, " ")
        END;
        IF col<=MaxIoRow THEN Sys.WriteLn(f) END
    END
END WriteF;

PROCEDURE Read(mat: tMat);
VAR
    row,col: CARDINAL;
    i, j   : CARDINAL;
    hilf: CARDINAL;
    num    : LONGREAL;
BEGIN
    ReadLn; ReadCard(row);
    ReadLn; ReadCard(col);
    SetSize(mat, row, col);
    ReadLn; ReadCard(mat^.rank);
    ReadLn; ReadCard(hilf);
    mat^.longreal:=  hilf = 1;
    ReadLn; ReadLn;
    ReadCard(hilf);
    FOR i:= 1 TO hilf DO
        ReadCard(j);
        CaLi.InsertBefore(mat^.mult, j)
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
    row,col: CARDINAL;
    i, j   : CARDINAL;
    hilf: CARDINAL;
    num    : LONGREAL;
    dummy  : ARRAY [1..80] OF CHAR;
BEGIN
    Sys.ReadLn(f); Sys.ReadCard(f, row);
    Sys.ReadLn(f); Sys.ReadCard(f, col);
    SetSize(mat, row, col);
    Sys.ReadLn(f); Sys.ReadCard(f, mat^.rank);
    Sys.ReadLn(f); Sys.ReadCard(f, hilf);
    mat^.longreal:=  hilf = 1;
    Sys.ReadLn(f);
    Sys.ReadCard(f, hilf);
    FOR i:= 1 TO hilf DO
        Sys.ReadCard(f, j);
        CaLi.InsertBefore(mat^.mult, j)
    END;

    FOR i:= 1 TO row DO
        FOR j:= 1 TO col DO
            Sys.ReadReal(f, num);
            Set(mat,i,j,num)
        END
    END
END ReadF;

PROCEDURE CheckEqualSize(a,b: tMat; proc: ARRAY OF CHAR);
(* Es wird eine Fehlermeldung ausgegeben, falls die Matrizen
   'a' und 'b' nicht die gleiche Groesse besitzen. *)
BEGIN
    IF (Rows(a) # Rows(b)) OR (Columns(a) # Columns(b)) THEN
        WriteLn;
        WriteString("*** Mat."); WriteString(proc);
        WriteString(":"); WriteLn;
        WriteString("*** Die uebergebenen Matrizen haben"); WriteLn;
        WriteString(" nicht die gleiche Groesse."); WriteLn;
        HALT
    END
END CheckEqualSize;

PROCEDURE Add(mat1, mat2, res: tMat);
VAR
    i,j: CARDINAL;
    hilf: tMat;
    RowsMat1, ColumnsMat1: CARDINAL;
BEGIN
    Use(hilf,Rows(res),Columns(res));
    CheckEqualSize(mat1, mat2, "Add");
    CheckEqualSize(mat2, res, "Add");

    RowsMat1:= Rows(mat1); ColumnsMat1:= Columns(mat1);
    FOR i:= 1 TO RowsMat1 DO
        FOR j:= 1 TO ColumnsMat1 DO
            Set(hilf,i,j,Elem(mat1,i,j)+Elem(mat2,i,j))
        END
    END;
    Assign(hilf,res);
    DontUse(hilf)
END Add;

PROCEDURE Sub(mat1, mat2, res: tMat);
VAR
    i,j: CARDINAL;
    hilf: tMat;
    RowsMat1, ColumnsMat1: CARDINAL;
BEGIN
    Use(hilf,Rows(res),Columns(res));
    CheckEqualSize(mat1, mat2, "Sub");
    CheckEqualSize(mat2, res, "Sub");

    RowsMat1:= Rows(mat1); ColumnsMat1:= Columns(mat1);
    FOR i:= 1 TO RowsMat1 DO
        FOR j:= 1 TO ColumnsMat1 DO
            Set(hilf,i,j,Elem(mat1,i,j)-Elem(mat2,i,j))
        END
    END;
    Assign(hilf,res);
    DontUse(hilf)
END Sub;
            (* a*b, b*c, a*c *)
PROCEDURE Mult(mat1,mat2,res: tMat);
VAR
    i,j,k: CARDINAL;
    hilf: tMat;
    RowsRes, ColumnsRes, ColumnsMat1: CARDINAL;
BEGIN
    Use(hilf,Rows(res),Columns(res));
    IF (Columns(mat1) # Rows(mat2)) OR
       (Rows(mat1) # Rows(res)) OR
       (Columns(mat2) # Columns(res))
    THEN
        WriteLn;
        WriteString("*** Mat.Mult:"); WriteLn;
        WriteString("*** Die Groessen der uebergebenen"); WriteLn;
        WriteString(" Matrizen passen nicht zusammen."); WriteLn;
        HALT
    END;
    RowsRes:= Rows(res); ColumnsRes:= Columns(res);
    ColumnsMat1:= Columns(mat1);
    FOR i:= 1 TO RowsRes DO
        FOR j:= 1 TO ColumnsRes DO
            FOR k:= 1 TO ColumnsMat1 DO
                Set( hilf,i,j,
                     Elem(hilf,i,j)+
                     Elem(mat1,i,k)*Elem(mat2,k,j)
                   )
            END
        END
    END;
    Assign(hilf,res);
    DontUse(hilf)
END Mult;

PROCEDURE ScalMult(num: LONGREAL; mat1,res: tMat);
VAR
    i,j: CARDINAL;
    RowsRes, ColumnsRes: CARDINAL;
BEGIN
    RowsRes:= Rows(res); ColumnsRes:= Columns(res);
    FOR i:= 1 TO RowsRes DO
        FOR j:= 1 TO ColumnsRes DO
            Set(res,i,j,num*Elem(mat1,i,j))
        END
    END
END ScalMult;
    
BEGIN
    (* initialisiere Zufallsgeneratoren: *)
    Rnd.Use(ElemGen);
    Rnd.Use(IntGen);
    Rnd.Use(SignGen);
    Rnd.Range(SignGen,0.0,1.0);

    MatId:= Type.New(TSIZE(tMatRecord));
    Type.SetName(MatId,"Matrix");
    Type.SetNewProc(MatId, MatNewI);
    Type.SetDelProc(MatId, MatDelI)
    
END Mat.
       
