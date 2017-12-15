(* ###GrepMarke###
\begin{ImpModul}{List} 
\begin{verbatim} 
   ###GrepMarke### *)

IMPLEMENTATION MODULE List;

(* Verwaltung von Listen

   (Erklaerungen im Definitionsmodul)
*)

FROM SYSTEM IMPORT TSIZE, ADR;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM InOut IMPORT WriteString, WriteLn;
IMPORT Sys, Str, Type;
FROM Sys IMPORT tPOINTER;

TYPE tPoiListItem = POINTER TO tListItem;
     tPos         = tPoiListItem;
     tListItem    =
         RECORD
             value    : tPOINTER;
             next,prev: tPoiListItem;
                 (* doppelt verkettet *)
         END;
     tList        = POINTER TO tListRecord;
     tListRecord  =
         RECORD (* Ringliste *)
             first  : tPoiListItem;
                      (* erstes Listenelement *)
             current: tPoiListItem;
                      (* aktuelles Listenelement;
                         vgl. 'First', 'Next', 'Previous',
                         'Current' *)
             OldCurrent: tPoiListItem;
                      (* vorangegangener Wert von 'current'
                         (wichtig fuer 'MoreData' *)
             count  : LONGCARD;
                      (* Anzahl der Elemente in der Liste *)
             type   : Type.Id;
                      (* Typ der Elemente der Liste *)
             addref : BOOLEAN (* ADDitional REFerences *)
                      (* TRUE: beim Loeschen von Elementen dieser
                               Liste werden lediglich Referenzen
                               innerhalb der Liste aufgeloest;
                               'Type.DelI' wird nicht aufgerufen *)
         END;
VAR
    i: CARDINAL;
    ListId: Type.Id;

(*************************************)
(* allgemeine Verwaltungsprozeduren: *)

PROCEDURE ListNewI(hilf: tPOINTER);
VAR
    list: tList;
BEGIN
    list:= hilf;
    list^.first:= NIL;
    list^.current:= NIL;
    list^.OldCurrent:= NIL;
    list^.count:= 0;
    list^.type:= Type.NoType();
    list^.addref:= FALSE;
END ListNewI;

PROCEDURE Use(VAR list: tList; type: Type.Id);
BEGIN
    list:= Type.NewI(ListId);
    list^.type:= type
END Use;

PROCEDURE ListDelI(hilf: tPOINTER);
VAR
    list: tList;
BEGIN
    list:= hilf;
    Empty(list)
END ListDelI;

PROCEDURE DontUse(VAR list: tList);
BEGIN
    Type.DelI(ListId, list)
END DontUse;

PROCEDURE Empty(list: tList);
BEGIN
    First(list);
    WHILE Count(list)>0 DO
        DelCur(list)
    END
END Empty;

(*****************************************************************)
(* Prozeduren, die sich auf das aktuelle Listenelement beziehen: *)

PROCEDURE DelCur(list: tList); (* DELete CURrent *)
VAR
    OldCur: tPOINTER;
BEGIN
    IF list^.current=NIL THEN
        WriteLn;
        WriteString("*** List.DeleteCur: kein aktuelles Element ***");
        WriteLn;
        HALT;
        RETURN
    END;
        
    OldCur:= OutCur(list);
    IF OldCur=NIL THEN RETURN END;
    IF NOT list^.addref THEN
        Type.DelI(list^.type, OldCur)
    END
END DelCur;

       (* INSert *)
PROCEDURE Ins(list: tList; value: tPOINTER; before: BOOLEAN);
(* 'value' wird in 'list' eingefuegt.
   Wenn 'before=TRUE', dann wird vor dem aktuellen Element ein-
   gefuegt, sonst dahinter.
   Die Liste darf leer sein. Das aktuelle Element darf undefiniert
   (=NIL) sein. *)
VAR
    JustCreated: tPoiListItem;
BEGIN
    ALLOCATE(JustCreated, TSIZE(tListItem));
    JustCreated^.value:= value;

    IF Count(list) = 0 THEN
        JustCreated^.prev:= JustCreated;
        JustCreated^.next:= JustCreated;
        list^.first:= JustCreated
    ELSE
        IF list^.current = NIL THEN
            (* fuege ganz am Anfang oder ganz am Ende ein durch
               Einfuegen zwischen Anfang und Ende und korrektes
               Setzen von 'first': *)
            list^.current:= list^.first^.prev;
            IF before THEN
                list^.first:= JustCreated
            END
        ELSE
            IF before THEN
                (* Sonderfall: aktuelles Element ist erstes
                               Element *)
                IF list^.current = list^.first THEN
                    list^.first:= JustCreated
                END;
                
                (* setze 'current' um ein Element nach vorne, damit
                   korrekt eingefuegt wird: *)
                list^.current:= list^.current^.prev;
            END
        END;
     
        (* fuege hinter 'current' ein *)
        JustCreated^.next:= list^.current^.next;
        JustCreated^.prev:= list^.current;
        JustCreated^.prev^.next:= JustCreated;
        JustCreated^.next^.prev:= JustCreated
    END;

    list^.current:= JustCreated;
    INC(list^.count)

END Ins;

PROCEDURE InsertBefore(list: tList; item: tPOINTER);
BEGIN
    Ins(list,item,TRUE)
END InsertBefore;

PROCEDURE InsertBehind(list: tList; item: tPOINTER);
BEGIN
    Ins(list,item,FALSE)
END InsertBehind;

PROCEDURE Insert(list: tList; item: tPOINTER);
BEGIN
    Ins(list,item,FALSE)
END Insert;

PROCEDURE First(list: tList);
BEGIN
    WITH list^ DO
        IF current # first THEN
            OldCurrent:= current;
            current:= first
        ELSE
            (* fuer den Sonderfall: 'First' wenn das erste
               Element bereits aktuell ist;
               in diesem Fall soll 'MoreData' trotzdem TRUE
               liefert *)
            OldCurrent:= NIL
        END
    END
END First;

PROCEDURE Last(list: tList);
BEGIN
    IF list^.first # NIL THEN
        IF list^.current # list^.first^.prev THEN
            list^.OldCurrent:= list^.current;
            list^.current:= list^.first^.prev
        ELSE
            (* fuer den Sonderfall: 'Last' wenn das letzte
               Element bereits aktuell ist;
               in diesem Fall soll 'MoreData' trotzdem TRUE
               liefert *)
            list^.OldCurrent:= NIL
        END
    ELSE
        IF list^.current # NIL THEN
            WriteString("*** List.Last:");
            WriteString(" aktuelles Listenelement ausserhalb");
            WriteString(" der Liste"); WriteLn;
            HALT
        END
    END
END Last;

PROCEDURE Prev(list: tList); (* PREVious *)
BEGIN
    IF list^.current <> NIL THEN
        IF list^.current <> list^.first THEN
            list^.OldCurrent:= list^.current;
            list^.current:= list^.current^.prev
        END
    END
END Prev;

PROCEDURE Next(list: tList);
BEGIN
    IF list^.current <> NIL THEN
        IF list^.current^.next <> list^.first THEN
            list^.OldCurrent:= list^.current;
            list^.current:= list^.current^.next
        END
    END
END Next;

PROCEDURE MoreData(list: tList): BOOLEAN;
BEGIN
    RETURN list^.current # list^.OldCurrent
END MoreData;

PROCEDURE AtFirst(list: tList): BOOLEAN;
BEGIN
    IF list^.current <> NIL THEN
        IF list^.current = list^.first THEN
            RETURN TRUE
        END
    END;
    RETURN FALSE;
END AtFirst;

PROCEDURE AtLast(list: tList): BOOLEAN;
BEGIN
    IF list^.current <> NIL THEN
        IF list^.current = list^.first^.prev THEN
            RETURN TRUE
        END
    END;
    RETURN FALSE;
END AtLast;

PROCEDURE Cur(list: tList): tPOINTER; (* CURrent *)
BEGIN
    RETURN list^.current^.value
END Cur;

PROCEDURE GetPos(list: tList): tPos; (* GET POSition *)
BEGIN
    RETURN list^.current
END GetPos;

PROCEDURE SetPos(list: tList; pos: tPos); (* SET POSition *)
BEGIN
    list^.current:= pos
END SetPos;

PROCEDURE OutCur(list: tList): tPOINTER; (* OUT CURrent *)
VAR
    erg: tPOINTER;
    item: tPoiListItem;
    OldFirst: tPoiListItem;
BEGIN
    IF list^.current = NIL THEN
        WriteLn;
        WriteString(
            "*** List.OutCur: kein aktuelles Listenelement ***");
        WriteLn;
        HALT;
        RETURN NIL
    END;

    (* Liste enthaelt mindestens ein Element: *)

    item:= list^.current;
    erg:= item^.value;

    IF Count(list) = 1 THEN
        IF list^.current<>list^.first THEN
            WriteLn;
            WriteString(
               "*** List.OutCur: Fehler in Listenverwaltung;  ***");
            WriteLn;
            WriteString(
               "*** aktuelles Listenelement in falscher Liste ***");
            WriteLn;
            HALT
        END;
        list^.first:= NIL;
        list^.current:= NIL;
        list^.OldCurrent:= NIL
    ELSE
        (* Sonderfall: erstes Element ist aktuelles *)
        OldFirst:= list^.first;
        IF list^.current = OldFirst THEN
            list^.first:= list^.first^.next
        END;
        
        IF list^.current^.next = OldFirst THEN
            list^.current:= list^.current^.prev
        ELSE
            list^.current:= list^.current^.next
        END;
        item^.prev^.next:= item^.next;
        item^.next^.prev:= item^.prev
    END;
        
    DEALLOCATE(item,TSIZE(tListItem));
    DEC(list^.count);

    RETURN erg
END OutCur;

(*************)
(* Diverses: *)

PROCEDURE Scan(list: tList; proc: tScanProc);
VAR i: LONGCARD;
BEGIN
    IF Count(list) = 0 THEN RETURN END;
    First(list);
    FOR i:= 1 TO Count(list) DO
        proc(Cur(list));
        Next(list)
    END;
    First(list)
END Scan;

PROCEDURE AddRef(list: tList);
BEGIN
    list^.addref:= TRUE
END AddRef;

PROCEDURE GetType(list: tList): Type.Id;
BEGIN
    RETURN list^.type
END GetType;

PROCEDURE Count(list: tList): LONGCARD;
BEGIN
    RETURN list^.count
END Count;

PROCEDURE StructureError(t1,t2: ARRAY OF CHAR);
(* Es wird eine Fehlermeldung fuer die Prozedur 'CheckStructure'
   ausgegeben. *)
BEGIN
    WriteString("*** List.CheckStructure:"); WriteLn;
    WriteString("*** "); WriteString(t1); WriteLn;
    WriteString("*** "); WriteString(t2); WriteLn;
    HALT
END StructureError;

PROCEDURE CheckChain(list: tList; UseNext: BOOLEAN);
(* Es wird die Verzeigerung von 'l' geprueft. Bei Strukturfehlern
   werden mit Hilfe von 'StructureError' Fehlermeldungen
   ausgegeben. Es wird   l^.first # NIL   vorausgesetzt.
   Bei 'UseNext = TRUE' wird die Verzeigerung entlang der
   'next'-Zeiger verfolgt, sonst entlang der 'prev'-Zeiger. *)
VAR
    CurrentFound: BOOLEAN;
        (* TRUE: list^.current  kann von  list^.first  aus
                 entlang der Verzeigerung erreicht werden
        *)
    MyCount: LONGCARD;
        (* Anzahl der Listenelemente durch Verfolgung der
           Verzeigerung festgestellt *)
    MyItem: tPoiListItem;
        (* Zeiger zur Verfolgung der Verzeigerung *)
    ErrorText: ARRAY [1..50] OF CHAR;
BEGIN
    IF UseNext THEN
        Str.Assign(ErrorText,
            "Verfolgung entlang  list^.first^.next^.next^. ...")
    ELSE
        Str.Assign(ErrorText,
            "Verfolgung entlang  list^.first^.prev^.prev^. ...")
    END;
    MyCount:= 0;
    MyItem:= list^.first;
    REPEAT
        INC(MyCount);
        CurrentFound:=  CurrentFound
                        OR (MyItem = list^.current);
        IF UseNext THEN
            MyItem:= MyItem^.next
        ELSE
            MyItem:= MyItem^.prev
        END
    UNTIL (MyItem = list^.first) OR (MyCount > list^.count)
          OR (MyItem = NIL);
    IF MyItem = NIL THEN
        StructureError( ErrorText,
        "ergibt keine geschlossene Ringliste")
    END;
    IF MyCount > list^.count THEN
        StructureError( ErrorText,
        "ergibt MEHR Listenelemente als  list^.count  angibt")
    END;
    IF MyCount < list^.count THEN
        StructureError( ErrorText,
        "ergibt WENIGER Listenelemente als  list^.count angibt")
    END;
    IF (list^.current # NIL) AND NOT CurrentFound THEN
        StructureError( ErrorText,
        "fuehrt nicht zum Element  list^.current")
    END
END CheckChain;

PROCEDURE CheckStructure(list: tList);
BEGIN
    IF list^.count = 0 THEN
        IF list^.current # NIL THEN
            StructureError(
            "list^.count = 0    jedoch   list^.current # NIL",
            "")
        END;
        IF list^.first # NIL THEN
            StructureError(
            "list^.count = 0    jedoch   list^.first # NIL",
            "")
        END
    ELSE
        IF list^.first = NIL THEN
            StructureError(
            "list^.count # 0    jedoch   list^.first = NIL",
            "")
        END;
        CheckChain(list,TRUE);
        CheckChain(list,FALSE)
    END
END CheckStructure;

BEGIN
    ListId:= Type.New(TSIZE(tListRecord));
    Type.SetName(ListId,"List.tList");
    Type.SetNewProc(ListId, ListNewI);
    Type.SetDelProc(ListId, ListDelI)
END List.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
