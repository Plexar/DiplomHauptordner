(* ###GrepMarke###
\begin{ImpModul}{Frag}
\begin{verbatim}
   ###GrepMarke### *)

IMPLEMENTATION MODULE Frag; (* array FRAGments *)

(*    Eindimensionale Felder beliebiger Laenge

        ( Erklaerungen im Definitionsmodul )
*)

FROM SYSTEM IMPORT ADR, TSIZE;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
IMPORT Sys, Func, Type;
FROM Sys IMPORT tPOINTER;
FROM Func IMPORT Error;

TYPE tFrag = POINTER TO tFragRec;
     tFragRec = RECORD
                    type: Type.Id;
                        (* Typ der Feldelemente *)
                    low, high: LONGCARD;
                        (* untere bzw. obere Indexgrenze *)
                    AddRef: BOOLEAN;
                        (* TRUE: beim Loeschen von Feldelementen
                                 'Type.DelI' nicht aufrufen *)
                    items: tPOINTER
                        (* Zeiger auf Speicherbereich
                           der Groesse
                           '( high-low+1 ) * TSIZE(tPOINTER) )'
                           mit den Feldelementen
                        *)
                END;

VAR FragId: Type.Id;

PROCEDURE ComputeFragBytes(low, high: LONGCARD): LONGCARD;
(* Das Funktionsergebnis ist die Groesse des Speicherbereiches,
   der noetig ist, um Feldelemente (also Zeiger) fuer den
   Indexbereich mit der unteren Grenze 'low' und der oberen
   Grenze 'high' zu speichern.
*)
BEGIN
    RETURN (high - low + 1) * TSIZE(tPOINTER)
END ComputeFragBytes;

PROCEDURE ComputeLoc(p: tPOINTER; dist: LONGCARD): tPOINTER;
(* 'p' wird als Zeiger auf eine Folge hintereinander gespeicherter
   Zeiger betrachtet. Das Funktionsergebnis ist ein Zeiger auf das
   Element dieser Folge, dessen Nummer 'dist' angibt ( Zaehlung be-
   ginnt bei 0; d. h. 'ComputeLoc(p,0) = p' ) .
*)
BEGIN
    RETURN p + TSIZE(tPOINTER) * dist
END ComputeLoc;

PROCEDURE CheckIndices(proc: ARRAY OF CHAR; low, high: LONGCARD);
(* Die Indizes werden auf Plausibilitaet geprueft. Falls eine
   Fehlermeldung ausgegeben wird, erscheint 'proc' als ausloesende
   Prozedur.
*)
BEGIN
    IF low > high THEN
        Error(proc,
            "untere Indexgrenze groesser als obere Indexgrenze")
    END
END CheckIndices;

PROCEDURE CheckRange(proc: ARRAY OF CHAR;
                     index, low, high: LONGCARD);
BEGIN
    IF (index < low) OR (high < index) THEN
        Error(proc,
    "Der angegebene Index liegt ausserhalb des erlaubten Bereiches.")
    END
END CheckRange;

PROCEDURE Use(VAR frag: tFrag; type: Type.Id; low, high: LONGCARD);
VAR i: LONGCARD;
BEGIN
    CheckIndices("Frag.Use", low, high);
    frag:= Type.NewI(FragId);
    frag^.type:= type;
    frag^.low:= low;
    frag^.high:= high;
    frag^.AddRef:= TRUE;
    ALLOCATE( frag^.items, ComputeFragBytes(low, high) );
    FOR i:= frag^.low TO frag^.high DO
        SetItem(frag, i, NIL)
    END;
    frag^.AddRef:= FALSE
END Use;

PROCEDURE DontUse(VAR f: tFrag);
BEGIN
    Type.DelI(FragId, f);
END DontUse;

PROCEDURE AddRef(f: tFrag; HasRef: BOOLEAN);
BEGIN
    f^.AddRef:= HasRef
END AddRef;

PROCEDURE Empty(f: tFrag);
VAR
    WorkIndex: LONGCARD;
    WorkPointer: POINTER TO tPOINTER;
BEGIN
    CheckIndices("Frac.Empty", f^.low, f^.high);
    WorkIndex:= f^.low;
    WorkPointer:= f^.items;
    REPEAT
        IF NOT f^.AddRef THEN
            Type.DelI(f^.type, WorkPointer^)
                (* 'Type.DelI' achtet selbst auf NIL-Zeiger.
                   Deshalb wird dies hier nicht geprueft. *)
        ELSE
            WorkPointer^:= NIL
        END;
        WorkPointer:= ComputeLoc(WorkPointer, 1);
        INC(WorkIndex)
    UNTIL WorkIndex > f^.high
END Empty;

PROCEDURE Move(from, to: tFrag);
(* Der Inhalt des Datensatzes von 'from' wird ohne irgendwelche
   Pruefungen an den Datensatz von 'to' zugewiesen. *)
BEGIN
    to^.type:= from^.type;
    to^.low:= from^.low;
    to^.high:= from^.high;
    to^.AddRef:= from^.AddRef;
    to^.items:= from^.items
END Move;

PROCEDURE Swap(a, b: tFrag);
VAR hilf: tFragRec;
    pHilf: tFrag;
BEGIN
    pHilf:= ADR(hilf);
    Move(b, pHilf);
    Move(a, b);
    Move(pHilf, a)
END Swap;

PROCEDURE SetRange(f: tFrag; low, high: LONGCARD);
VAR NewF: tFragRec;
    pNewF: tFrag;
    i: LONGCARD;
    cHilf: LONGCARD;
    pHilf: POINTER TO tPOINTER;
BEGIN
     IF (f^.low # low) OR (f^.high # high) THEN
         (* neues Feld anlegen: *)
         pNewF:= ADR(NewF);
         Move(f, pNewF);
         NewF.AddRef:= TRUE;
         NewF.low:= low;
         NewF.high:= high;
         NewF.items:= NIL;
         ALLOCATE(NewF.items, ComputeFragBytes(low, high));
         FOR i:= low TO high DO
             SetItem(pNewF, i, NIL)
         END;
      
         (* Inhalt des alten Feldes in das neue kopieren: *)
         Transfer(f, pNewF);

         (* altes Feld beseitigen: *)
         DEALLOCATE(f^.items, ComputeFragBytes(f^.low, f^.high));

         (* Arbeitsdatensatz in uebergebenen Datensatz kopieren: *)
         Move(pNewF, f)
     END;
END SetRange;

PROCEDURE SetType(f: tFrag; type: Type.Id);
BEGIN
    Empty(f);
    f^.type:= type
END SetType;

PROCEDURE GetLow(f: tFrag): LONGCARD;
BEGIN
    RETURN f^.low
END GetLow;

PROCEDURE GetHigh(f: tFrag): LONGCARD;
BEGIN
    RETURN f^.high
END GetHigh;

PROCEDURE GetType(f: tFrag): Type.Id;
BEGIN
    RETURN f^.type
END GetType;

PROCEDURE GetItem(frag: tFrag; index: LONGCARD): tPOINTER;
VAR loc: POINTER TO tPOINTER;
BEGIN
    CheckRange("Frag.GetItem", index, frag^.low, frag^.high);
    loc:= ComputeLoc(frag^.items, index - frag^.low);
    RETURN loc^
END GetItem;

PROCEDURE SetItem(frag: tFrag; index: LONGCARD; item: tPOINTER);
VAR loc: POINTER TO tPOINTER;
BEGIN
    CheckRange("Frag.SetItem", index, frag^.low, frag^.high);

    loc:= ComputeLoc(frag^.items, index - frag^.low);
    IF frag^.AddRef THEN
        loc^:= NIL
    ELSE
        (* Type.DelI  prueft selbst auf NIL; deshalb wird hier
           loc^ # NIL nicht geprueft *)
        Type.DelI(frag^.type, loc^)
    END;
    loc^:= item
END SetItem;

PROCEDURE Transfer(from, to: tFrag);
VAR i: LONGCARD;
BEGIN
    IF (from^.low < to^.low) OR (from^.high > to^.high) THEN
        Error("Frag.Transfer",
            "Die Indexbereiche sind nicht kompatibel.")
    END;
    IF from^.type # to^.type THEN
        Error("Frag,Transfer",
            "Die Typen sind nicht gleich.")
    END;
    FOR i:= from^.low TO from^.high DO
        SetItem(to, i, GetItem(from, i))
    END
END Transfer;

PROCEDURE DelFragI(i: tPOINTER);
VAR I: tFrag;
BEGIN
    I:= i;
    IF I^.low > I^.high THEN
        Error("Frag.DelFragI",
            "untere Indexgrenze groesser als obere Indexgrenze");
    END;
    Empty(I);
    DEALLOCATE( I^.items, ComputeFragBytes(I^.low, I^.high) )
END DelFragI;

BEGIN
    FragId:= Type.New(TSIZE(tFragRec));
    Type.SetName(FragId, "Frag.tFrag");
    Type.SetDelProc(FragId, DelFragI)
END Frag.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
