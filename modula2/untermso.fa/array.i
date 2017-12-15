(* Dieses Modul ist fertig implementiert, jedoch nicht getestet. *)

IMPLEMENTATION MODULE Array;

(*      Felder veraenderlicher Groesse

     ( Erklaerungen im Definitionsmodul )
*)

(* Verbesserungsmoeglichkeiten:
    - physikalische Representation nicht mehr benutzter
      Feldelemente wird wieder entfernt
    - Speicherung der Feldteile in einer Hash-Tabelle
*)

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, Func, Type, Frag, List;
FROM Sys IMPORT tPOINTER;
FROM Func IMPORT Error;

TYPE tArray = POINTER TO tArrayRec;
     tArrayRec= RECORD
                    type: Type.Id;
                        (* Typ der Feldelemente *)
                    FragList: List.tList
                        (* Das Feld ist als nach den Indizes
                           sortierte Liste von Indexteilbereichen
                           implementiert.
                        *)
                END;
VAR
    FragId: Type.Id;   (* Typ der Indexteilbereiche *)
    ArrayId: Type.Id;  (* Typ der Felder *)
    ListId: Type.Id;   (* Typ von 'List.tList' *)

(*********************************)
(* Handhabung von Feldelementen: *)

       (* Fragment LIST CURrent element *)
PROCEDURE fListCur(f: List.tList): Frag.tFrag;
BEGIN
    RETURN Frag.tFrag(List.Cur(f))
END fListCur;

PROCEDURE GetPosItem(a: tArray; pos: List.tPos;
                     index: LONGCARD): tPOINTER;
(* Das Funktionsergebnis ist das in der Fragmentliste von 'a'
   an der Position 'pos' unter dem angegebenen Index gespeicherte
   Feldelement. Bei 'pos = NIL' ist das Funktionsergebnis ebenfalls
   NIL .
*)
VAR cur: List.tPos;
    res: tPOINTER;
BEGIN
    IF pos # List.tPos(NIL) THEN
        cur:= List.GetPos(a^.FragList);

        List.SetPos(a^.FragList, pos);
        res:= Frag.GetItem(fListCur(a^.FragList), index);

        List.SetPos(a^.FragList, cur);
        RETURN res
    ELSE
        RETURN NIL
    END
END GetPosItem;

PROCEDURE SetPosItem(a: tArray; pos: List.tPos; index: LONGCARD;
                     item: tPOINTER; delete: BOOLEAN);
(* zu 'GetPosItem' gehoerige zum Setzen des Feldinhalts; bei
   'delete = TRUE' wird ein bereits vorhandenes Feldelement
   mit 'Type.DelI' geloescht
*)
VAR cur: List.tPos;
BEGIN
    cur:= List.GetPos(a^.FragList);

    List.SetPos(a^.FragList, pos);
    Frag.AddRef(fListCur(a^.FragList), NOT delete);
    Frag.SetItem(fListCur(a^.FragList), index, item);
    Frag.AddRef(fListCur(a^.FragList), TRUE);

    List.SetPos(a^.FragList, cur)
END SetPosItem;

PROCEDURE SetCurPosItem(a: tArray; index: LONGCARD; item: tPOINTER;
                        delete: BOOLEAN);
(* Mit dem angegebenen Index im aktuellen Feldfragment von 'a' wird
   'item' als Feldelement gespeichert. Bei 'delete = TRUE' wird ein
   schon vorhandenes Feldelement mit 'Type.DelI' geloescht. *)
VAR pos: List.tPos;
BEGIN
    pos:= List.GetPos(a^.FragList);
    SetPosItem(a, pos, index, item, delete)
END SetCurPosItem;

(***************************************)
(* Handhabung einzelner Feldfragmente: *)

PROCEDURE FindFrag(VAR pos: List.tPos; a: tArray; index: LONGCARD);
(* In 'pos' wird die Position des Feldfragments in 'a' zurueckge-
   geben, in dem das Feldelement mit dem in 'index' angegebenen
   Index gespeichert ist. Falls keine physikalische Representation
   fuer 'index' existiert wird NIL in 'pos' zurueckgegeben.
*)
VAR frag: Frag.tFrag;
BEGIN
    List.First(a^.FragList);
    pos:= List.tPos(NIL);
    WHILE ( List.MoreData(a^.FragList) )
                               AND ( pos = List.tPos(NIL) ) DO
        frag:= fListCur(a^.FragList);
        IF (Frag.GetLow(frag) <= index)
            AND (index <= Frag.GetHigh(frag)) THEN
            pos:= List.GetPos(a^.FragList)
        END;
        List.Next(a^.FragList)
    END
END FindFrag;

PROCEDURE GetFragLow(pos: List.tPos; a: tArray;
                     low: LONGCARD): LONGCARD;
(* Falls 'pos # NIL', ist das Funktionsergebnis die untere Index-
   grenze des Feldfragments an der Position 'pos'.
   Andernfalls ist 'low' das Funktionsergebnis.
*)
VAR f: Frag.tFrag;
BEGIN
    IF pos = List.tPos(NIL) THEN
        RETURN low
    ELSE
        List.SetPos(a^.FragList, pos);
        f:= fListCur(a^.FragList);
        RETURN Frag.GetLow(f)
    END
END GetFragLow;

PROCEDURE GetFragHigh(pos: List.tPos; a: tArray;
                      high: LONGCARD): LONGCARD;
(* Falls 'pos # NIL', ist das Funktionsergebnis die obere Index-
   grenze des Feldfragments an der Position 'pos'.
   Andernfalls ist 'high' das Funktionsergebnis.
*)
VAR f: Frag.tFrag;
BEGIN
    IF pos = List.tPos(NIL) THEN
        RETURN high
    ELSE
        List.SetPos(a^.FragList, pos);
        f:= fListCur(a^.FragList);
        RETURN Frag.GetHigh(f)
    END
END GetFragHigh;

PROCEDURE MergeFrags(frag: Frag.tFrag; a: tArray;
                     LowPos, HighPos: List.tPos;
                     low, high: LONGCARD);
(* 'frag' muss eine initialisiertes Feldfragment sein und gross
   genug, um alle Feldelemente im Indexbereich 'low' bis 'high'
   aufzunehmen. In 'LowPos' muss die Position des Feldfragments
   von 'a' uebergeben werden, in dem das Element mit dem Index 'low'
   gespeichert ist. In 'HighPos' muss die Position des Feldfragments
   von 'a' uebergeben werden, in dem das Element mit dem Index 'high'
   gespeichert ist. Es darf entweder 'LowPos' oder 'HighPos'
   gleich NIL sein.
   In jedem Fall werden alle Feldelemente aus Fragmenten von 'a', die
   den Indexbereich von 'low' bis 'high' ganz oder teilweise ueber-
   decken, nach 'frag' uebertragen.
*)
VAR forward: BOOLEAN;
        (* TRUE : die Uebertragung der Feldelemente wird von 'LowPos'
                  an vorwaerts durchgefuehrt;
           FALSE: die Uebertragung der Feldelemente wird von 'HighPos'
                  an rueckwaerts durchgefuehrt;
        *)
    WorkFrag: Frag.tFrag;
        (* aktuelles Feldfragment, das nach 'frag' uebertragen werden
           soll *)
    WorkItem: tPOINTER;
    end: BOOLEAN;
BEGIN
    forward:=  LowPos # List.tPos(NIL);
    IF forward THEN
        List.SetPos(a^.FragList, LowPos)
    ELSE
        List.SetPos(a^.FragList, HighPos)
    END;
    WorkFrag:= fListCur(a^.FragList);
    Frag.AddRef(frag, FALSE);

    REPEAT
        Frag.Transfer(WorkFrag, frag);
        IF forward THEN
            List.Next(a^.FragList);
            WorkFrag:= fListCur(a^.FragList);
            end:= Frag.GetLow(WorkFrag) > high
        ELSE
            List.Prev(a^.FragList);
            WorkFrag:= fListCur(a^.FragList);
            end:= Frag.GetHigh(WorkFrag) < low
        END
    UNTIL NOT List.MoreData(a^.FragList) OR end;
    Frag.AddRef(frag, FALSE)
END MergeFrags;

PROCEDURE DeleteFrags(a: tArray; LowPos, HighPos: List.tPos;
                      low, high: LONGCARD);
(* In 'LowPos' muss die Position des Feldfragments von 'a' uebergeben
   werden, in dem das Element mit dem Index 'low' gespeichert ist.
   In 'HighPos' muss die Position des Feldfragments von 'a' uebergeben
   werden, in dem das Element mit dem Index 'high' gespeichert ist.
   Es darf entweder 'LowPos' oder 'HighPos' gleich NIL sein.
   In jedem Fall werden alle Fragmente von 'a', die den Indexbereich
   von 'low' bis 'high' ganz oder teilweise ueberdecken, geloescht.
   Die Feldelemente werden NICHT (mit 'Type.DelI') geloescht.
*)
VAR forward: BOOLEAN;
        (* TRUE : die Uebertragung der Feldelemente wird von 'LowPos'
                  an vorwaerts durchgefuehrt;
           FALSE: die Uebertragung der Feldelemente wird von 'HighPos'
                  an rueckwaerts durchgefuehrt;
        *)
    WorkFrag: Frag.tFrag;
        (* aktuelle zu loeschendes Feldfragment *)
    end: BOOLEAN;
BEGIN
    forward:=  LowPos # List.tPos(NIL);
    IF forward THEN
        List.SetPos(a^.FragList, LowPos)
    ELSE
        List.SetPos(a^.FragList, HighPos)
    END;
    WorkFrag:= fListCur(a^.FragList);

    REPEAT
        Frag.AddRef(WorkFrag, TRUE);
        Frag.DontUse(WorkFrag);
        IF forward THEN
            WorkFrag:= fListCur(a^.FragList);
            end:= Frag.GetLow(WorkFrag) > high
        ELSE
            List.Prev(a^.FragList);
            WorkFrag:= fListCur(a^.FragList);
            end:= Frag.GetHigh(WorkFrag) < low
        END
    UNTIL NOT List.MoreData(a^.FragList) OR end
END DeleteFrags;

PROCEDURE InsertFrag(a: tArray; frag: Frag.tFrag);
(* Das Feldfragment 'frag' wird anhand der Indexgrenzen in die
   Fragmentliste von 'a' einsortiert. *)
VAR inserted: BOOLEAN;
    cur: Frag.tFrag;
BEGIN
    IF List.Count(a^.FragList) = 0 THEN
        List.Insert(a^.FragList, tPOINTER(frag))
    ELSE
        List.First(a^.FragList);
        inserted:= FALSE;
        REPEAT
            cur:= fListCur(a^.FragList);
            IF Frag.GetHigh(frag) < Frag.GetLow(cur) THEN
                List.InsertBefore(a^.FragList, tPOINTER(frag));
                inserted:= TRUE
            END;
            List.Next(a^.FragList);
            IF NOT List.MoreData(a^.FragList) THEN
                List.InsertBehind(a^.FragList, tPOINTER(frag));
                inserted:= TRUE
            END
        UNTIL inserted
    END
END InsertFrag;

(********************************)
(* zu exportierende Prozeduren: *)

PROCEDURE Use(VAR a: tArray; type: Type.Id);
BEGIN
    a:= Type.NewI(ArrayId);
    a^.type:= type;
    List.Use(a^.FragList, FragId)
END Use;

PROCEDURE DontUse(VAR a: tArray);
BEGIN
    Type.DelI(ArrayId, a)
END DontUse;

PROCEDURE PredictRange(a: tArray; low, high: LONGCARD);
VAR pos1, pos2: List.tPos;
    frag: Frag.tFrag;
BEGIN
    FindFrag(pos1, a, low);
    FindFrag(pos2, a, high);
    IF NOT ((pos1 = pos2) AND (pos1 # List.tPos(NIL))) THEN
        low:= GetFragLow(pos1, a, low);
        high:= GetFragHigh(pos2, a, high);
        Frag.Use(frag, a^.type, low, high);
        MergeFrags(frag, a, pos1, pos2, low, high);
        DeleteFrags(a, pos1, pos2, low, high);
        InsertFrag(a, frag)
    END
END PredictRange;

PROCEDURE Elem(a: tArray; index: LONGCARD): tPOINTER;
VAR pos: List.tPos;
BEGIN
    FindFrag(pos, a, index);
    RETURN GetPosItem(a, pos, index)
END Elem;

PROCEDURE OutItem(a: tArray; index: LONGCARD): tPOINTER;
VAR pos: List.tPos;
    res: tPOINTER;
BEGIN
   FindFrag(pos, a, index);
   res:= GetPosItem(a, pos, index);
   IF pos # List.tPos(NIL) THEN
       SetPosItem(a, pos, index, NIL, FALSE)
   END;
   RETURN res
END OutItem;

PROCEDURE Set(a: tArray; index: LONGCARD; item: tPOINTER);
VAR pos, lower, higher: List.tPos;
    NewLow, NewHigh: LONGCARD;
    frag: Frag.tFrag;
BEGIN
    FindFrag(pos, a, index);
    IF pos = List.tPos(NIL) THEN
        FindFrag(lower, a, index-1);
        FindFrag(higher, a, index+1);
        IF (lower # List.tPos(NIL)) OR (higher # List.tPos(NIL)) THEN
            NewLow := GetFragLow(lower, a, index);
            NewHigh := GetFragHigh(higher, a, index);
            Frag.Use(frag, a^.type, NewLow, NewHigh);
            MergeFrags(frag, a, lower, higher, NewLow, NewHigh);
            DeleteFrags(a, lower, higher, NewLow, NewHigh)
        ELSE
            Frag.Use(frag, a^.type, index, index)
        END;
        InsertFrag(a, frag);
        SetCurPosItem(a, index, item, TRUE);
    ELSE
        SetPosItem(a, pos, index, item, TRUE)
    END
END Set;

PROCEDURE Empty(a: tArray);
BEGIN
    List.Empty(a^.FragList)
END Empty;

(*********************************)
(* Prozeduren fuer Modul 'Type': *)

PROCEDURE NewArrayI(a: tPOINTER);
VAR A: tArray;
BEGIN
    A:= a;
    List.Use(A^.FragList, FragId)
END NewArrayI;

PROCEDURE DelArrayI(a: tPOINTER);
VAR A: tArray;
BEGIN
    A:= a;
    List.DontUse(A^.FragList)
END DelArrayI;

BEGIN
    FragId:= Type.GetId("Frag.tFrag");

    ArrayId:= Type.New(TSIZE(tArrayRec));
    Type.SetName(ArrayId, "Array.tArray");
    Type.SetNewProc(ArrayId, NewArrayI);
    Type.SetDelProc(ArrayId, DelArrayI);
    
    ListId:= Type.GetId("List.tList")
END Array.
