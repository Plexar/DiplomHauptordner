(* ###GrepMarke###
\begin{ImpModul}{Rnd} 
\begin{verbatim} 
   ###GrepMarke### *)

IMPLEMENTATION MODULE Rnd;

(*  Erzeugung von Zufallszahlen

   ( Erklaerungen im Definitionsmodul )
*)

FROM SYSTEM IMPORT TSIZE;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM InOut IMPORT WriteLn, WriteString;
IMPORT SysMath, Func, Sys;
FROM SysMath IMPORT sqrt, cos, ln, entier, real;

CONST
    RndInfoFile= "rnd.inf";
        (* Datei mit Anfangszahl fuer Zufallsgenerator *)

    (* Konstanten zur Erzeugung von Zufallszahlen
       (Es muss mit LONGREAL-Zahlen gerechnet werden,
        da der Wertebereich von 'LONGCARD' nicht
        ausreicht) : *)
    a= 24298.0;
    c= 99991.0;
    m= 199017.0;
    pi= 3.1415926;
    (* Konstanten zur Voreinstellung von Generatorparametern: *)
    PreX= 42.0; (* Dieser Wert wird als Startwert fuer das
                   Modul benutzt, falls 'RndInfoFile' nicht
                   existiert. *)
    PreNewX = 7.0; (* Um diesen Wert wird der Startwert fuer den
                    letzten neu angelegten Generator inkre-
                    mentiert (modulo 'm'), um den Startwert fuer
                    den naechsten Generator voreinzustellen. *)
    PreNewNextX = 11.0;
        (* Um diesen Wert wird der aus 'RndInfoFile' gelesene
           Startwert inkrementiert (modulo 'm') um den Wert
           fuer den naechsten Programmstart zu erhalten. *)
    PreHi= 1.0; (* untere Grenze *)
    PreLo= 0.0; (* obere Grenze *)
    PreMid = 0.0; (* Mittelwert *)
    PreSt= 1.0; (* Standardabweichung *)

TYPE
   tGen = POINTER TO tGenRec;
   tGenRec = RECORD (* einzelner Generator *)
                 x: LONGREAL;
                     (* letzte erzeugte Zufallszahl *)
                 lo,hi: LONGREAL;
                     (* untere bzw. obere Grenze des Bereichs,
                        in dem die Zahlen liegen sollen *)
                 mid, st: LONGREAL;
                     (* Mittelwert, Varianz *)
             END;

VAR
   NextX: LONGREAL; (* naechster fuer einen Generator zur
                       Voreinstellung zu benutzt Startwert *)

PROCEDURE Use(VAR gen: tGen);
BEGIN
    ALLOCATE(gen, TSIZE(tGenRec));
    WITH gen^ DO
        x  := NextX;
        lo := PreLo;
        hi := PreHi;
        mid:= PreMid;
        st := PreSt
    END;
    NextX:= Func.ModReal( NextX + PreNewX , m )
END Use;

PROCEDURE DontUse(VAR gen: tGen);
BEGIN
    DEALLOCATE(gen,TSIZE(tGenRec));
    gen:= NIL
END DontUse;

PROCEDURE Start(gen: tGen; num: LONGCARD);
BEGIN
    gen^.x:= real(num);
    NextX:= Func.ModReal( real(num) + PreNewX , m )
END Start;

PROCEDURE Range(gen: tGen; bot,top: LONGREAL);
BEGIN
    IF bot >= top THEN
        WriteLn;
        WriteString("*** Rnd.Range:"); WriteLn;
        WriteString("*** Die untere Intervallgrenze ist ");
        WriteLn;
        WriteString("groesser als die obere.");
        WriteLn;
        HALT
    END;
    gen^.lo:= bot;
    gen^.hi:= top
END Range;

PROCEDURE New(gen: tGen);
BEGIN
    gen^.x:= Func.ModReal( a * gen^.x + c , m )
END New;

PROCEDURE Int(gen: tGen): LONGINT;
BEGIN
    New(gen);
    RETURN entier( ( gen^.x / m )
                   * (gen^.hi + 1.0 - gen^.lo)
                   + gen^.lo
                 )
END Int;

PROCEDURE LongReal(gen: tGen): LONGREAL;
BEGIN
    New(gen);
    RETURN ( gen^.x / m )
           * (gen^.hi-gen^.lo)
           + gen^.lo
END LongReal;

PROCEDURE St(gen: tGen; num: LONGREAL);
BEGIN
    gen^.st:= num
END St;

PROCEDURE Mid(gen: tGen; num: LONGREAL);
BEGIN
    gen^.mid:= num
END Mid;

PROCEDURE Norm(gen: tGen): LONGREAL;
BEGIN
    RETURN gen^.st*(
                 sqrt( -2.0*ln( LongReal(gen) ) )
                 * cos( 2.0*pi*LongReal(gen) )
              ) + gen^.mid
END Norm;

VAR f: Sys.File;

BEGIN
    IF Sys.Exist(RndInfoFile) THEN
        Sys.OpenRead(f,RndInfoFile);
        Sys.ReadReal(f,NextX);
        Sys.Close(f)
    ELSE
        NextX:= PreX
    END;
    NextX:= Func.ModReal( NextX + PreNewNextX, m );
    Sys.OpenWrite(f,RndInfoFile);
    Sys.WriteReal(f,NextX,8,0);
    Sys.Close(f)
END Rnd.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
