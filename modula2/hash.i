(* ###GrepMarke###
\begin{ImpModul}{Hash} 
\begin{verbatim} 
   ###GrepMarke### *)

IMPLEMENTATION MODULE Hash;

(*              Hashing

    ( Erklaerungen im Definitionsmodul )
*)

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, SysMath, Func, Type, List, Cali, Frag;
FROM SysMath IMPORT sqrt, real;
FROM Sys IMPORT tPOINTER;
FROM Func IMPORT Error;

CONST PrimFile = "hash.inf";
          (* In dieser Datei werden berechnete Primzahlen
             gespeichert. *)
      HashFactor = 10L;
          (* Prozentsatz des Hash-Speichers, der nach dem Reorgani-
             sieren durch 'Reorg' belegt sein soll (muss auf jeden
             Fall unter 50 liegen, sonst ist nicht garantiert, dass
             'Reorg' fuer das naechste neue Element einen freien
             Speicherplatz schafft). 
          *)
      HashDiff = 10L;
          (* Beim Einfuegen werden mindestens 
             ' HashFactor + HashDiff ' Prozent des Speichers durch 
             'Insert' durchsucht, bevor der Speicher neu organisiert
             wird. 'HashDiff' muss groesser oder gleich 1 sein.
             ' HashFactor + HashDiff ' muss kleiner als 50 sein
             um einen Effekt zu erzielen.
          *)

TYPE tHash = POINTER TO tHashRec;
      tHashRec = RECORD
                    current: LONGCARD;
                        (* Index des aktuellen Elements von 'items' *)
                    InsertCount: LONGCARD;
                        (* Anzahl der mit 'Insert' eingefuegten
                           Elemente (einschliesslich der bereits
                           wieder geloeschten) *)
                    MinSize: LONGCARD;
                        (* Mindestgroesse von 'items' 
                           (ist nach unten durch 100 begrenzt) *)
                    deleted: Cali.tCali;
                        (* Indizes der geloeschten Elemente *)
                    items: Frag.tFrag
                END;
VAR
    HashId: Type.Id;
        (* Typidentifikator fuer 'tHashRec' *)
    PrimList: Cali.tCali;
        (* Liste von Primzahlen *)

PROCEDURE WritePrim();
(* 'PrimList' wird in 'PrimFile' gespeichert. *)
VAR f: Sys.File;
BEGIN
    Sys.OpenWrite(f, PrimFile);

    List.First(PrimList);
    REPEAT
        Sys.WriteCard(f, Cali.Cur(PrimList), 0);
        List.Next(PrimList)
    UNTIL NOT List.MoreData(PrimList);

    Sys.Close(f)
END WritePrim;

PROCEDURE ReadPrim();
(* 'PrimList' wird aus 'PrimFile' gelesen. *)
VAR f: Sys.File;
    val: LONGCARD;
BEGIN
    Sys.OpenRead(f, PrimFile);

    List.Empty(PrimList);
    REPEAT
        Sys.ReadLCard(f, val);
        List.InsertBehind(PrimList, val)
    UNTIL Sys.EOF(f);

    Sys.Close(f)
END ReadPrim;

PROCEDURE NewPrim(z: LONGCARD);
(* Es wird sichergestellt, dass 'PrimList' eine Primzahl enthaelt, die
   groesser oder gleich 'z' ist (ggf. werden neue berechnet). *)
VAR i, end, SqrtEnd: LONGCARD;
    cur: List.tPos; CurVal: LONGCARD;
BEGIN
    List.Last(PrimList);
    IF Cali.Cur(PrimList) < z THEN
        REPEAT
            end:= Cali.Cur(PrimList) + z;
            SqrtEnd:= Func.Ceil( sqrt(real(end)) );
            FOR i:= Cali.Cur(PrimList) + 1 TO end DO
                IF (( i MOD 2 ) # 0) AND ((i MOD 3) # 0) THEN
                    Cali.InsertBehind(PrimList, i)
                END
            END;

            List.First(PrimList);
            List.Next(PrimList); List.Next(PrimList);
            REPEAT
                cur:= List.GetPos(PrimList);
                CurVal:= Cali.Cur(PrimList);
                List.Next(PrimList);
                WHILE List.MoreData(PrimList) DO
                    IF (Cali.Cur(PrimList) DIV CurVal) = 0 THEN
                        List.DelCur(PrimList)
                    ELSE
                        List.Next(PrimList)
                    END
                END;
                List.SetPos(PrimList, cur);
                List.Next(PrimList)
            UNTIL List.AtLast(PrimList)
                      OR (Cali.Cur(PrimList) > SqrtEnd)
        UNTIL Cali.Cur(PrimList) >= z;
        WritePrim
    END
END NewPrim;

PROCEDURE GetPrim(z: LONGCARD): LONGCARD;
(* Funktionsergebnis ist die zu 'z' naechst groessere Primzahl.
   Falls 'z' eine Primzahl ist, wird sie als Ergebnis zurueck-
   gegeben.
   Zur Berechnung der Primzahlen wird das Sieb des Eratostenes
   verwendet.
*)
BEGIN
    NewPrim(z);

    List.Last(PrimList);
    WHILE (Cali.Cur(PrimList) > z) AND List.MoreData(PrimList) DO
        List.Prev(PrimList)
    END;
    IF Cali.Cur(PrimList) = z THEN
        RETURN z
    ELSE
        IF Cali.Cur(PrimList) < z THEN
            List.Next(PrimList)
        END;
        RETURN Cali.Cur(PrimList)
    END
END GetPrim;

PROCEDURE Use(VAR h: tHash; type: Type.Id; size: LONGCARD);
BEGIN
    IF size < 100 THEN
        size:= 100
    END;

    h:= Type.NewI(HashId);
    Frag.SetType(h^.items, type);
    Frag.SetRange(h^.items, 0, GetPrim(size));
    h^.MinSize:= Frag.GetHigh(h^.items)
END Use;

PROCEDURE DontUse(VAR h: tHash);
BEGIN
    Type.DelI(HashId, h)
END DontUse;

PROCEDURE Empty(h: tHash);
BEGIN
    List.Empty(h^.deleted);
    Frag.Empty(h^.items);
    h^.InsertCount:= 0;
    h^.current:= 0
END Empty;

PROCEDURE CallDelete(h: tHash; call: BOOLEAN);
BEGIN
    Frag.AddRef(h^.items, NOT call)
END CallDelete;

PROCEDURE Transfer(from, to: tHash);
(* Alle nicht als geloescht markierten Elemente in 'from' werden
   nach 'to' uebertragen.
   Nach dem Aufruf von 'Transfer' ist 'from' vollstaendig leer.
*)
VAR i: LONGCARD;
BEGIN
     IF Frag.GetType(from^.items) # Frag.GetType(to^.items) THEN
         Error("Hash.Transfer",
             "Die Elementtypen der Hash-Speicher sind verschieden.")
     END;
     List.First(from^.deleted);
     WHILE List.MoreData(from^.deleted) DO
         Frag.SetItem(from^.items, Cali.Cur(from^.deleted), NIL);
         List.Next(from^.deleted)
     END;
     FOR i:= 0 TO Frag.GetHigh(from^.items) DO
         IF Frag.GetItem(from^.items, i) # NIL THEN
             Insert(to, Frag.GetItem(from^.items, i))
         END
     END;
     Empty(from)
END Transfer;

PROCEDURE Assign(from, to: tHash);
(* Die Verwaltungsdaten von 'from' werden 'to' zugewiesen.
   Die Elementtypen von 'h1' und 'h2' muessen gleich sein. *)
BEGIN
    to^.current:= from^.current;
    to^.InsertCount:= from^.InsertCount;
    to^.MinSize:= from^.MinSize;
    to^.deleted:= from^.deleted;
    to^.items:= from^.items
END Assign;

PROCEDURE Swap(h1, h2: tHash);
(* Die Verwaltungsdaten von 'h1' und 'h2' werden vertauscht.
   Die Elementtypen von 'h1' und 'h2' muessen gleich sein. *)
VAR tmp: tHash;
BEGIN
    Use(tmp, Frag.GetType(h1^.items), Frag.GetHigh(h1^.items));
    Assign(h1, tmp);
    Assign(h2, h1);
    Assign(tmp, h2);
    DontUse(tmp)
END Swap;

PROCEDURE Reorg(h: tHash);
(* Die Element in 'h' werden neu organisiert, so dass maximal soviel
   Prozent des Hash-Speichers belegt sind, wie 'HashFactor' angibt. *)
VAR NewSize: LONGCARD;
    NewHash: tHash;
BEGIN
    NewSize:= Func.MaxLCard(
                  (h^.InsertCount - List.Count(h^.deleted))
                      DIV HashFactor + 1 * 100
                , h^.MinSize
              );
    
    Use(NewHash, Frag.GetType(h^.items), NewSize);
    Transfer(h, NewHash);
    Swap(h, NewHash);
    DontUse(NewHash)
END Reorg;

VAR level: CARDINAL;
        (* Variable zum Test der Rekursion *)

PROCEDURE Insert(h: tHash; item: tPOINTER);
VAR index, FirstIndex, delta: LONGCARD;
    end: BOOLEAN;
    MaxTries: LONGCARD;
        (* Anzahl der Einfuege-Versuche, bevor 'Reorg' 
           angestossen wird *)
    tries: LONGCARD;
        (* Anzahl der bereits durchgefuehrten Versuche *)
BEGIN
    INC(level);
    tries:= 0;
    MaxTries:= Frag.GetHigh(h^.items) DIV 100 + 1 
               * (HashFactor + HashDiff);

    index:= Type.HashI( Frag.GetType(h^.items), item,
                        Frag.GetHigh(h^.items)
                      );
    FirstIndex:= index;
    delta:= 1;
    REPEAT
        end:= ( Frag.GetItem(h^.items, index) = NIL );
        IF NOT end THEN
            index:= ( index + delta ) MOD Frag.GetHigh(h^.items);
            delta:= ( delta + 2 ) MOD Frag.GetHigh(h^.items);
            INC(tries);
        ELSE
            Frag.SetItem(h^.items, index, item);
            INC(h^.InsertCount)
        END
    UNTIL end OR (index = FirstIndex) OR (tries > MaxTries);
    IF NOT end THEN
        IF level > 1 THEN
            Error("Hash.Insert",
            "'Garbage Collection' schafft keinen freien Speicher");
        ELSE
            Reorg(h);
            Insert(h, item)
        END
    END;
    
    DEC(level)
END Insert;

PROCEDURE Stored(h: tHash; item: tPOINTER;
                 VAR FoundItem: tPOINTER): BOOLEAN;
VAR index, FirstIndex, delta: LONGCARD;
    end, res: BOOLEAN;
BEGIN
    index:= Type.HashI(Frag.GetType(h^.items), item, 
                       Frag.GetHigh(h^.items));
    FirstIndex:= index;
    delta:= 1;
    REPEAT
        end:= ( Frag.GetItem(h^.items, index) = NIL );
        IF NOT end THEN
            index:= ( index + delta ) MOD Frag.GetHigh(h^.items);
            delta:= ( delta + 2 ) MOD Frag.GetHigh(h^.items)
        END
    UNTIL end OR (index = FirstIndex);
    IF end THEN
        FoundItem:= Frag.GetItem(h^.items, index)
    ELSE
        FoundItem:= NIL
    END;
    RETURN end
END Stored;

       (* DELete CURrent *)
PROCEDURE DelCur(h: tHash);
BEGIN
    IF h^.current = 0 THEN
        Error("Hash.DelCur",
            "Das aktuelle Element ist undefiniert.")
    END;
    Cali.Insert(h^.deleted, h^.current)
END DelCur;

PROCEDURE NewHash(h: tPOINTER);
VAR H: tHash;
BEGIN
    H:= h;

    H^.current:= 0;
    H^.InsertCount:= 0;
    H^.MinSize:= 1;
    Cali.Use(H^.deleted);
    Frag.Use(H^.items, Type.NoType(), 1, 1)
END NewHash;

PROCEDURE DelHash(h: tPOINTER);
VAR H: tHash;
BEGIN
    H:= h;
    List.DontUse(H^.deleted);
    Frag.DontUse(H^.items)
END DelHash;

BEGIN
    HashId:= Type.New(TSIZE( tHashRec ) );
    Type.SetName(HashId, "Hash.tHash");
    Type.SetNewProc(HashId, NewHash);
    Type.SetDelProc(HashId, DelHash);

    Cali.Use(PrimList);
    IF Sys.Exist(PrimFile) THEN
        ReadPrim
    ELSE
        Cali.InsertBehind(PrimList, 2);
        Cali.InsertBehind(PrimList, 3)
    END;
    
    level:= 0;
END Hash.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
