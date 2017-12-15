(* ###GrepMarke###
\begin{ImpModul}{Data} 
\begin{verbatim} 
   ###GrepMarke### *)

IMPLEMENTATION MODULE Data;

(*   Verwaltung der Testdaten der Diplomarbeit

     (Erklaerungen im Definitionsmodul)
*)

FROM SYSTEM IMPORT TSIZE;
FROM InOut IMPORT WriteLn, WriteString, WriteReal, WriteCard,
                  ReadLn, ReadString, ReadReal, ReadLReal,
                  ReadCard, ReadLCard;
IMPORT Sys, Str, Type, List, Rema;
FROM Rema IMPORT tMat;
FROM Sys IMPORT tPOINTER;

TYPE Id = POINTER TO tIdRecord;
     tIdRecord = RECORD
                     name: ARRAY [1..16] OF CHAR;
                         (* Name, unter dem der Datensatz
                            gefuehrt wird *)
                     mat: tMat;
                         (* Matrix, fuer die die Determinante
                            berechnet werden soll *)
                     HasChanged: BOOLEAN;
                         (* TRUE: am Datensatz wurden Veraenderungen
                                vorgenommen, die auf den Hinter-
                                grundspeicher zu uebertragen sind *)
                     AlgDat: ARRAY tAlg OF
                         RECORD  (* Datensatz fuer jeden Alg.: *)
                             det: LONGREAL; (* Determinante *)
                             p, st: LONGCARD;
                                 (* Schritte und Prozessoren *)
                             IsSet: BOOLEAN
                                 (* TRUE: es wurden Werte in
                                    det, p und st gespeichert *)
                         END
                 END;

VAR
    DatList: List.tList;
        (* Liste der sich im Speicher befindlichen Datensaetze *)
    TypeId: Type.Id;
        (* Typidentifikation fuer 'tIdRecord' *)

PROCEDURE NewI(hilf: tPOINTER);
(* Anlege-Prozedur fuer Modul 'Type' *)
VAR
    i: tAlg;
    dat: Id;
BEGIN
    dat:= hilf;
    Str.Empty(dat^.name);
    Rema.Use(dat^.mat, 1, 1);
    dat^.HasChanged:= FALSE;
    FOR i:= laplace TO pan DO
        WITH dat^.AlgDat[i] DO
            det  := 0.0;
            p    := 0;
            st   := 0;
            IsSet:= FALSE
        END
    END
END NewI;

PROCEDURE DelI(hilf: tPOINTER);
(* Loesch-Prozedur fuer Modul 'Type' *)
VAR
    dat: Id;
BEGIN
    dat:= hilf;
    Rema.DontUse(dat^.mat)
END DelI;

PROCEDURE Write(dat: Id);
(* Der Datensatz 'dat' wird auf die Standardausgabe schrieben.
   Die Matrix des Datensatzes wird dabei jedoch nicht geschrieben. *)
VAR i: tAlg;
BEGIN
    WriteString("Datensatzname: "); WriteLn;
    WriteString(dat^.name); WriteLn;
    WriteString("Algorithmus   Determinante    Schritte");
    WriteString("    Prozessoren"); WriteLn;
    FOR i:= laplace TO pan DO
        CASE i OF
            laplace: WriteString("Laplace  ");
          | csanky : WriteString("Csanky   ");
          | bgh    : WriteString("BGH      ");
          | berk   : WriteString("Berkowitz");
          | pan    : WriteString("Pan      ")
        END;
        WriteLn; WriteString("              ");
        WITH dat^.AlgDat[i] DO
            WriteReal(det,12,4);
            WriteCard(st,12);
            WriteCard(p,15)
        END;
        WriteLn  
    END
END Write;

PROCEDURE WriteF(VAR f: Sys.File; dat: Id);
(* ... analog 'Write', jedoch erfolgt die Ausgabe in die
   Datei 'f' *)
VAR
    i: tAlg;
BEGIN
    Sys.WriteString(f, "Datensatzname: "); Sys.WriteLn(f);
    Sys.WriteString(f, dat^.name); Sys.WriteLn(f);
    Sys.WriteString(f, "Algorithmus   Determinante    Schritte");
    Sys.WriteString(f, "    Prozessoren"); Sys.WriteLn(f);
    FOR i:= laplace TO pan DO
        CASE i OF
            laplace: Sys.WriteString(f, "Laplace  ");
          | csanky : Sys.WriteString(f, "Csanky   ");
          | bgh    : Sys.WriteString(f, "BGH      ");
          | berk   : Sys.WriteString(f, "Berkowitz");
          | pan    : Sys.WriteString(f, "Pan      ")
        END;
        Sys.WriteLn(f); Sys.WriteString(f,"              ");
        WITH dat^.AlgDat[i] DO
            Sys.WriteReal(f,det,12,4);
            Sys.WriteCard(f,st,12);
            Sys.WriteCard(f,p,15);
        END;
        Sys.WriteLn(f)
    END
END WriteF;

PROCEDURE ReadF(VAR f: Sys.File; dat: Id);
(* ... analog 'Read', jedoch wird aus 'f' gelesen *)
VAR
    i: tAlg;
BEGIN
    Sys.ReadLn(f);
    Sys.ReadString(f, dat^.name);
    Sys.ReadLn(f);
    FOR i:= laplace TO pan DO
        Sys.ReadLn(f);
        WITH dat^.AlgDat[i] DO
            Sys.ReadReal(f, det);
            Sys.ReadLCard(f, st);
            Sys.ReadLCard(f, p)
        END;
    END
END ReadF;

PROCEDURE End;
BEGIN
    Flush
END End;

PROCEDURE Insert(dat: Id);
(* Der Datensatz 'dat' wird in 'DatList' alphabetisch nach 'name'
   sortiert eingefuegt. *)
VAR
    cur: Id;
    ordered: BOOLEAN;
    inserted: BOOLEAN;
BEGIN
    IF List.Count(DatList) = 0 THEN
        List.InsertBefore(DatList, dat)
    ELSE
        List.First(DatList);
        inserted:= FALSE;
        REPEAT
            cur:= List.Cur(DatList);
            ordered:= Str.Ordered(cur^.name, dat^.name);
            IF NOT ordered THEN
                List.InsertBefore(DatList, dat);
                inserted:= TRUE
            ELSE
                IF List.AtLast(DatList) THEN
                    List.InsertBehind(DatList, dat);
                    inserted:= TRUE
                END
            END;
            List.Next(DatList)
        UNTIL inserted;
    END
END Insert;

PROCEDURE Search(VAR dat: Id; name: ARRAY OF CHAR): BOOLEAN;
(* Der Datensatz mit dem Namen 'name' wird in 'DatList'
   gesucht. Falls er gefunden wird, ist das Funktionsergebnis
   TRUE und in 'dat' wird der Datensatz zurueckgegeben.
   Wird er nicht gefunden, ist das Funktionsergebnis FALSE und
   'dat' ist undefiniert. *)
VAR
    found: BOOLEAN;
BEGIN
    IF List.Count(DatList) = 0 THEN
        RETURN FALSE
    END;
    List.First(DatList);
    REPEAT
        dat:= List.Cur(DatList);
        found:= Str.Equal(dat^.name, name);
        IF NOT found THEN
            List.Next(DatList)
        END
    UNTIL found OR (List.Cur(DatList) = dat);
    RETURN found
END Search;

PROCEDURE Find(VAR dat: Id; name: ARRAY OF CHAR);
VAR
    f: Sys.File;
BEGIN
    IF NOT Search(dat, name) THEN
        dat:= Type.NewI(TypeId);
        Str.Assign(dat^.name, name);
        IF Sys.Exist(name) THEN
            Sys.OpenRead(f, name);
            ReadF(f, dat);
            Rema.ReadF(f, dat^.mat);
            Sys.Close(f)
        END;
        Insert(dat)
    END
END Find;

PROCEDURE Del(VAR dat: Id); (* DELete *)
VAR
    ldat: Id;
BEGIN
    IF Search(ldat, dat^.name) THEN
        List.DelCur(DatList)
    ELSE
        WriteString("*** Data.Del:");
        WriteString("*** Datensatz nicht in Datensatzliste;");
        WriteString("*** --> Programmfehler");
        HALT
    END;
    Sys.Delete(dat^.name);
    dat:= NIL
END Del;

PROCEDURE CallFlushOnly( hilf: tPOINTER );
VAR
    dat: Id;
BEGIN
    dat:= hilf;
    FlushOnly(dat)
END CallFlushOnly;

PROCEDURE Flush();
BEGIN
    IF List.Count(DatList) > 0 THEN
        List.Scan(DatList, CallFlushOnly)
    END
END Flush;

PROCEDURE FlushOnly(dat: Id);
VAR
    f: Sys.File;
BEGIN
    IF dat^.HasChanged THEN
        Sys.OpenWrite(f, dat^.name);
        WriteF(f, dat);
        Rema.WriteF(f, dat^.mat);
        dat^.HasChanged:= FALSE;
        Sys.Close(f)
    END
END FlushOnly;

PROCEDURE HasChanged(dat: Id);
BEGIN
    dat^.HasChanged:= TRUE
END HasChanged;

VAR NextPresent: BOOLEAN;

PROCEDURE ListNames();
BEGIN
    List.First(DatList);
    NextPresent:= List.Count(DatList) > 0
END ListNames;

PROCEDURE NextName(VAR name: ARRAY OF CHAR): BOOLEAN;
VAR
    dat: Id;
BEGIN
    IF NextPresent THEN
        dat:= List.Cur(DatList);
        Str.Assign(name, dat^.name);
        List.Next(DatList);
        NextPresent:= List.Cur(DatList) # dat;
        RETURN TRUE
    ELSE
        RETURN FALSE
    END
END NextName;

(*******************************)
(* Handhabung der Datensaetze: *)

PROCEDURE GetMat(dat: Id): tMat;
BEGIN
    RETURN dat^.mat
END GetMat;

PROCEDURE SetAlg(dat: Id; alg: tAlg; pdet: LONGREAL;
                 pp, pst: LONGCARD);
BEGIN
    WITH dat^.AlgDat[alg] DO
        det:= pdet;
        p:= pp;
        st:= pst;
        IsSet:= TRUE
    END;
    dat^.HasChanged:= TRUE
END SetAlg;

PROCEDURE GetAlg(dat: Id; alg: tAlg; VAR pdet: LONGREAL;
                 VAR pp, pst: LONGCARD): BOOLEAN;
BEGIN
    WITH dat^.AlgDat[alg] DO
        pdet:= det;
        pp:= p;
        pst:= st;
        RETURN IsSet
    END
END GetAlg;

BEGIN
    TypeId:= Type.New(TSIZE(tIdRecord));
    Type.SetName(TypeId,"Data.Id");
    Type.SetNewProc(TypeId,NewI);
    Type.SetDelProc(TypeId,DelI);
    
    List.Use(DatList, TypeId)
END Data.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
