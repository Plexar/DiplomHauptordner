(* ###GrepMarke###
\begin{ImpModul}{Type}
\begin{verbatim}
   ###GrepMarke### *)

IMPLEMENTATION MODULE Type;

(* Verwaltung von Elemente selbst definierte Datentypen

   ( Erklaerungen im Definitionsmodul )
*)
(* Verbesserungsmoeglichkeit:
    - Verwaltung von Initialisierungswerten fuer 'NewProcs'
      ( - Export von zusaetzlichen Prozeduren zur Verwaltung der
          Werte
        - Implementierung durch Stapel fuer Initialisierungs-
          werte
        - Unterscheidung zwischen Standardinitialisierungswerten
          und variablen Initialisierungswerten
      )
*)

FROM SYSTEM IMPORT TSIZE, ADR;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM InOut IMPORT WriteString, WriteLn;
IMPORT Sys, Str;
FROM Sys IMPORT tPOINTER;

CONST MaxTypes= 30;
          (* maximale Anzahl von Typen, die verwaltet werden
             koennen *)
      MaxName= 32;
          (* maximale Laenge eines Namens fuer eine Typ *)

TYPE tProcs       = RECORD
                        (* Operationsprozeduren fuer Listen-
                           element-Typen *)
                        NewProc: tNewProc;
                        DelProc: tDelProc;
                        EquProc: tEquProc;
                        OrdProc: tOrdProc;
                        orddef : BOOLEAN; (* ORDer DEFined *)
                                 (* TRUE: es wurde eine Prozedur
                                    fuer 'OrdProc' angegeben *)
                        HashProc: tHashProc
                    END;
     tPoiTypeRec = POINTER TO tTypeRec;
     Id= tPoiTypeRec;
     tTypeRec    = RECORD
                       InUse  : BOOLEAN;
                           (* TRUE: dieser Datensatz wird bereits
                              fuer die Beschreibung eines Typs
                              verwendet *)
                       name : ARRAY [1..MaxName] OF CHAR;
                       size : LONGINT;
                           (* Groesse eines Elementes des Typs *)
                       procs: tProcs
                   END;
     tTypeArray  = ARRAY [1..MaxTypes] OF tTypeRec;
VAR
    TypeArray: tTypeArray;

PROCEDURE DefaultNewProc(adr: tPOINTER);
BEGIN
    (* tue nichts *)
END DefaultNewProc;

PROCEDURE DefaultDelProc(adr: tPOINTER);
BEGIN
    (* tue nichts *)
END DefaultDelProc;

PROCEDURE DefaultEquProc(adr1,adr2: tPOINTER): BOOLEAN;
BEGIN
    WriteLn;
    WriteString("*** Type.DefaultEquProc:"); WriteLn;
    WriteString("*** keine Vergleichsprozedur vereinbart");
    WriteLn;
    HALT;
    RETURN FALSE;
END DefaultEquProc;

PROCEDURE DefaultOrdProc(adr1,adr2: tPOINTER): BOOLEAN;
BEGIN
    WriteLn;
    WriteString("*** Type.DefaultOrdProc:"); WriteLn;
    WriteString("*** keine Ordnungsprozedur vereinbart");
    WriteLn;
    HALT;
    RETURN TRUE;
END DefaultOrdProc;

PROCEDURE DefaultHashProc(adr1: tPOINTER; size: LONGCARD): LONGCARD;
BEGIN
    WriteLn;
    WriteString("*** Type.DefaultHashProc:"); WriteLn;
    WriteString("*** keine Hash-Prozedur vereinbart");
    WriteLn;
    HALT;
    RETURN 0;
END DefaultHashProc;

PROCEDURE New(size: LONGCARD):Id;
VAR i,j: CARDINAL;
BEGIN
    i:= 1;
    LOOP
        IF NOT TypeArray[i].InUse THEN EXIT END;
        INC(i);
        IF i>MaxTypes THEN EXIT END
    END;
    IF i>MaxTypes THEN
        WriteLn;
        WriteString("*** Type.New:                         ***");
        WriteLn;
        WriteString("***     zu viele Typen;               ***");
        WriteLn;
        WriteString("***     Konstante 'MaxTypes' erhoehen ***");
        WriteLn;
        HALT
    END;
    FOR j:= 1 TO MaxName DO
        TypeArray[i].name[j]:= ' '
    END;
    TypeArray[i].InUse:= TRUE;
    TypeArray[i].size:= size;
    TypeArray[i].procs.NewProc:= DefaultNewProc;
    TypeArray[i].procs.DelProc:= DefaultDelProc;
    TypeArray[i].procs.EquProc:= DefaultEquProc;
    TypeArray[i].procs.OrdProc:= DefaultOrdProc;
    TypeArray[i].procs.orddef:= FALSE;
    TypeArray[i].procs.HashProc:= DefaultHashProc;
    RETURN ADR(TypeArray[i])
END New;

PROCEDURE Copy(type: Id): Id;
VAR NewType: Id;
BEGIN
    NewType:= New(type^.size);
    NewType^.procs.NewProc:= type^.procs.NewProc;
    NewType^.procs.DelProc:= type^.procs.DelProc;
    NewType^.procs.EquProc:= type^.procs.EquProc;
    NewType^.procs.OrdProc:= type^.procs.OrdProc;
    NewType^.procs.orddef:= type^.procs.orddef;
    NewType^.procs.HashProc:= type^.procs.HashProc;
    RETURN NewType
END Copy;

PROCEDURE SetName(type: Id; name: ARRAY OF CHAR);
BEGIN
    Str.Assign(type^.name, name)
END SetName;
   
PROCEDURE GetName(type: Id; VAR name: ARRAY OF CHAR);
BEGIN
    Str.Assign(name, type^.name)
END GetName;

PROCEDURE GetId(name: ARRAY OF CHAR): Id;
VAR i: CARDINAL;
    res: Id;
BEGIN
    i:= 1; res:= Id(NIL);
    LOOP
        IF TypeArray[i].InUse THEN
            IF Str.Equal(name,TypeArray[i].name) THEN
                res:= ADR(TypeArray[i]);
                EXIT
            END
        END;
        INC(i);
        IF i > MaxTypes THEN
            WriteString("*** Type.GetId:"); WriteLn;
            WriteString("*** Typ nicht gefunden"); WriteLn;
            HALT
        END
    END;
    RETURN res
END GetId;

PROCEDURE NoType(): Id;
BEGIN
    RETURN Id(NIL)
END NoType;

PROCEDURE Equal(t1,t2: Id): BOOLEAN;
BEGIN
    RETURN t1=t2
END Equal;

PROCEDURE SetNewProc(type: Id; NewProc: tNewProc);
BEGIN
    type^.procs.NewProc:= NewProc
END SetNewProc;

PROCEDURE SetDelProc(type: Id; DelProc: tDelProc);
BEGIN
    type^.procs.DelProc:= DelProc
END SetDelProc;

PROCEDURE SetEquProc(type: Id; EquProc: tEquProc);
BEGIN
    type^.procs.EquProc:= EquProc
END SetEquProc;

PROCEDURE SetOrdProc(type: Id; OrdProc: tOrdProc);
BEGIN
    type^.procs.OrdProc:= OrdProc;
    type^.procs.orddef:= TRUE
END SetOrdProc;

PROCEDURE SetHashProc(type: Id; HashProc: tHashProc);
BEGIN
    type^.procs.HashProc:= HashProc;
    type^.procs.orddef:= TRUE
END SetHashProc;

PROCEDURE OrdProcDefined(type: Id): BOOLEAN;
BEGIN
    RETURN type^.procs.orddef
END OrdProcDefined;

PROCEDURE NewI(type: Id): tPOINTER; (* NEW Item *)
VAR NewMem: tPOINTER;
BEGIN
    ALLOCATE(NewMem, type^.size);
    type^.procs.NewProc(NewMem);
    RETURN NewMem
END NewI;
       (* DELete Item *)
PROCEDURE DelI(type: Id; VAR item: tPOINTER);
BEGIN
    IF (type # Id(NIL)) AND (item # NIL) THEN
        type^.procs.DelProc(item);
        DEALLOCATE(item, type^.size);
        item:= NIL
    END
END DelI;

PROCEDURE EquI(type: Id; a,b: tPOINTER): BOOLEAN; (* EQUal Items *)
BEGIN
    RETURN type^.procs.EquProc(a,b)
END EquI;

PROCEDURE OrdI(type: Id; a,b: tPOINTER): BOOLEAN; (* ORDered Items *)
BEGIN
    RETURN type^.procs.OrdProc(a,b)
END OrdI;

PROCEDURE HashI(type: Id; a: tPOINTER; size: LONGCARD): LONGCARD;
BEGIN
    RETURN type^.procs.HashProc(a, size)
END HashI;

VAR j: CARDINAL;

BEGIN
    FOR j:= 1 TO MaxTypes DO
        TypeArray[j].InUse:= FALSE
    END
END Type.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
