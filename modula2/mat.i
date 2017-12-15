(* ###GrepMarke###
\begin{ImpModul}{Mat}
\begin{verbatim}
   ###GrepMarke### *)

IMPLEMENTATION MODULE Mat;

(*        2-dimensionale Matrizen

    ( Erklaerungen im Definitionsmodul )
*)

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, SysMath, Func, Type, Frag;
FROM Sys IMPORT tPOINTER;
FROM Func IMPORT Error;

TYPE tMat = POINTER TO tMatRecord;
     tMatRecord = RECORD
                      type: Type.Id; (* Typ der Matrizenelemente *)
                      fix: BOOLEAN;
                          (* TRUE: die Groesse der Matrix ist auf
                                   die in 'r' und 'c' angegebenen
                                   Werte beschraenkt;
                             FALSE: die Groesse der Matrix ist un-
                                   beschraenkt; 'r' und 'c' geben
                                   die maximalen Zeilen- bzw. Spal-
                                   tenindizes an auf die bisher mit
                                   'Set' zugegriffen wurde *)
                      r, c: LONGCARD;
                          (* siehe Erklaerung zur Komponente 'fix' *)
                      rows: Frag.tFrag
                          (* Feld der Matrix-Zeilen *)
                  END;

VAR MatId, FragId: Type.Id;

PROCEDURE CheckIndices(mat: tMat; row, col: LONGCARD;
                       proc: ARRAY OF CHAR);
(* Es wird eine Fehlermeldung ausgegeben, wenn der Zeilenindex
   'row' oder der Spaltenindex 'col' fuer einen Zugriff auf 'mat'
   ausserhalb des erlaubten Bereiches liegt.
*)
BEGIN
    IF mat^.fix THEN
        IF (row > mat^.r) OR (col > mat^.c) THEN
            Error(proc,
                "Zugriff auf nicht existierendes Matrizenelement");
        END
    END
END CheckIndices;

PROCEDURE Use(VAR mat: tMat; type: Type.Id);
BEGIN
    mat:= Type.NewI(MatId);
    mat^.type:= type;
    mat^.fix:= FALSE;
    mat^.r:= 0;
    mat^.c:= 0
END Use;

PROCEDURE DontUse(VAR mat: tMat);
BEGIN
    Type.DelI(MatId, mat)
END DontUse;

PROCEDURE SetSize(mat: tMat; rows, columns: LONGCARD);
VAR WorkRow: Frag.tFrag;
    k: LONGCARD;
BEGIN
    IF mat^.rows # Frag.tFrag(NIL) THEN
        Frag.DontUse(mat^.rows)
    END;
    Frag.Use(mat^.rows, FragId, 1, rows);
    mat^.fix:= TRUE;
    mat^.r:= rows;
    mat^.c:= columns;
    FOR k:= 1 TO rows DO
        WorkRow:= Frag.tFrag(
                      Frag.GetItem(mat^.rows, k)
                  );
        IF WorkRow = Frag.tFrag(NIL) THEN
            Frag.Use(WorkRow, mat^.type, 1, columns);
            Frag.SetItem(mat^.rows, k, tPOINTER(WorkRow))
        ELSE
            Error("Mat.SetSize","bereits initialisierte Zeilen vorhanden");
        END
    END
END SetSize;

PROCEDURE Set(mat: tMat; row, col: LONGCARD; item: tPOINTER);
VAR WorkRow: Frag.tFrag;
BEGIN
    CheckIndices(mat, row, col, "Mat.Set");
    IF mat^.fix THEN
        WorkRow:= Frag.tFrag(
                      Frag.GetItem(mat^.rows, row)
                  );
        IF WorkRow = Frag.tFrag(NIL) THEN
            Frag.Use(WorkRow, mat^.type, 1, mat^.c);
            Frag.SetItem(mat^.rows, row, tPOINTER(WorkRow))
        END;
    ELSE
        Error("Mat.Set","Behandlung von  fix=FALSE  nicht implementiert")
    END;
    Frag.SetItem(WorkRow, col, item)
END Set;

PROCEDURE Elem(mat: tMat; row, col: LONGCARD): tPOINTER;
VAR WorkRow: Frag.tFrag;
BEGIN
    CheckIndices(mat, row, col, "Mat.Elem");
    WorkRow:= Frag.tFrag( Frag.GetItem(mat^.rows, row) );
    IF WorkRow # Frag.tFrag(NIL) THEN
        RETURN Frag.GetItem(WorkRow, col)
    ELSE
        RETURN NIL
    END
END Elem;

PROCEDURE Rows(mat: tMat): LONGCARD;
BEGIN
    RETURN mat^.r
END Rows;

PROCEDURE Columns(mat: tMat): LONGCARD;
BEGIN
    RETURN mat^.c
END Columns;

PROCEDURE Empty(mat: tMat);
BEGIN
    Frag.Empty(mat^.rows);
    IF NOT mat^.fix THEN
        mat^.r:= 0;
        mat^.c:= 0
    END
END Empty;

PROCEDURE MatNewI(m: tPOINTER);
VAR M: tMat;
BEGIN
    M:= m;
    M^.rows:= Frag.tFrag(NIL);
END MatNewI;

PROCEDURE MatDelI(m: tPOINTER);
VAR M: tMat;
BEGIN
    M:= m;
    Frag.DontUse(M^.rows)
END MatDelI;

BEGIN
    MatId:= Type.New(TSIZE(tMatRecord));
    Type.SetName(MatId, "Mat.tMat");
    Type.SetNewProc(MatId, MatNewI);
    Type.SetDelProc(MatId, MatDelI);

    FragId:= Type.GetId("Frag.tFrag")
END Mat.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
