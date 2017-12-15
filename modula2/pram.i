(* ###GrepMarke###
\begin{ImpModul}{Pram}
\begin{verbatim}
   ###GrepMarke### *)

IMPLEMENTATION MODULE Pram;

(* Erklaerungen im Definitionsmodul *)

FROM SYSTEM IMPORT TSIZE;
FROM InOut IMPORT WriteLn, WriteString, WriteCard;
IMPORT Sys, Func, Str, Type, List, Cali, Reli;
FROM Sys IMPORT tPOINTER;
FROM Func IMPORT Message, Error;

TYPE tBlockname = ARRAY [1..MaxBlockName] OF CHAR;
     pBlockname = POINTER TO tBlockname;

VAR
   stack: Cali.tCali;
       (* Stapel von Zaehlerwerten fuer ParallelStart-
          ParallelEnde-Bloecke; es werden immer Paare von
          Prozessoranzahl und Schrittanzahl gespeichert;
          zweimal 0 gibt ein Blockende an *)
   names: List.tList;
       (* Stapel der Blocknamen zur Pruefung korrekter
          Schachtelung *)
   NameId: Type.Id;
       (* Typnummer fuer 'tBlockname' *)
   steps  : LONGCARD; (* Schrittzaehler der Pram *)
   pro    : LONGCARD; (* Prozessorenzaehler der Pram *)
   MaxPro : LONGCARD; (* Maximale Anzahl bisher in einem Schritt
                        beschaeftigter Prozessoren *)
   running: BOOLEAN;  (* TRUE: 'Start' wurde aufgerufen, jedoch
                               'Ende' noch nicht *)

PROCEDURE Push(value: LONGCARD);
(* schiebt 'value' auf den Stapel 'stack' *)
BEGIN
    List.First(stack);
    Cali.InsertBefore(stack,value)
END Push;

PROCEDURE Pop():LONGCARD;
(* liest oberstes Stapelelement von 'stack' *)
BEGIN
    IF List.Count(stack) = 0 THEN
        WriteLn;
        WriteString("*** Pram.Pop:"); WriteLn;
        WriteString("*** Zaehlstapel ist leer"); WriteLn;
        HALT
    END;
    List.First(stack);
    RETURN Cali.OutCur(stack)
END Pop;

PROCEDURE Start();
BEGIN
    steps:= 0;
    pro:= 0;
    MaxPro:= 0;
    running:= TRUE;
    List.Empty(stack)
END Start;

PROCEDURE Ende();
VAR block: pBlockname;
BEGIN
    running:= FALSE;
    IF List.Count(names) # 0 THEN
        WriteLn;
        WriteString("*** Pram.Ende:"); WriteLn;
        WriteString("*** Blockschachtelung fehlerhaft"); WriteLn;
        WriteString("Blockstapel:"); WriteLn;
        WriteString("###BOTTOM###"); WriteLn;
        List.Last(names);
        WHILE List.MoreData(names) DO
            block:= pBlockname(List.Cur(names));
            WriteString(block^); WriteLn;
            List.Prev(names)
        END;
        HALT
    END;
    IF List.Count(stack) > 0 THEN
        Message("Pram.Ende", "Der Zaehlstapel ist nicht leer.");
        WriteString("*** Groesse des Zaehlstapels: ");
        WriteCard( List.Count(stack), 0);
        WriteLn;
        HALT
    END
END Ende;

PROCEDURE Schritte(wert: LONGCARD);
BEGIN
    IF pro = 0 THEN
        Error("Pram.Schritte","Schritte ohne Prozessoren ?")
    END;
    IF wert= 0 THEN
        Error("Pram.Schritte","0 Schritte zaehlen ?")
    END;
    IF pro > MaxPro THEN
        MaxPro := pro
    END;
    pro:= 0;
    steps:= steps + wert
END Schritte;
   
PROCEDURE Prozessoren(wert: LONGCARD);
BEGIN
    IF wert = 0 THEN
        Error("Pram.Prozessoren","0 Prozessoren zaehlen ?")
    END;
    pro:= pro + wert
END Prozessoren;

PROCEDURE NamePush(l: List.tList; name: ARRAY OF CHAR);
VAR item: pBlockname;
BEGIN
    item:= pBlockname( Type.NewI(NameId) );
    Str.Assign(item^, name);
    List.First(l);
    List.InsertBefore(l, tPOINTER(item))
END NamePush;

PROCEDURE NameCheck(l: List.tList; name: ARRAY OF CHAR);
VAR item: pBlockname;
BEGIN
    IF List.Count(l) = 0 THEN
        Error("Pram.NameCheck", "Es existiert kein offener Block.");
    END;
    List.First(l);
    item:= pBlockname( List.Cur(l) );
    IF NOT Str.Equal(item^, name) THEN
        Message("Pram.NameCheck:", "Die Blockschachtelung ist fehlerhaft.");
        WriteString("Erwarteter Block: ");
        WriteString(name); WriteLn;
        WriteString("Gefundener Block: ");
        WriteString(item^); WriteLn;
        HALT
    END
END NameCheck;

PROCEDURE NamePop(l: List.tList);
BEGIN
    List.First(l);
    List.DelCur(l)
END NamePop;

PROCEDURE ParallelStart(Blockname: ARRAY OF CHAR);
BEGIN
    NamePush(names, Blockname);

    (* speichere bisher erzielte Ergebnisse: *)
    Push(MaxPro);
    Push(steps);

    (* markiere Blockanfang: *)
    Push(0);
    Push(0);
    MaxPro:= 0;
    steps:= 0;
    pro:= 0;
END ParallelStart;

PROCEDURE NaechsterBlock(Blockname: ARRAY OF CHAR);
BEGIN
    NameCheck(names, Blockname);

    IF pro # 0 THEN
        WriteLn;
        WriteString("*** Pram.NaechsterBlock:"); WriteLn;
        WriteString("*** Prozessoren ohne Schritte ?");
        WriteLn;
        HALT
    END;
    IF (MaxPro # 0) OR (steps # 0) THEN 
        Push(MaxPro);
        Push(steps)
    END;
    MaxPro:= 0;
    steps:= 0
END NaechsterBlock;

PROCEDURE ParallelEnde(Blockname: ARRAY OF CHAR);
VAR
    CurSteps, CurPro: LONGCARD;
        (* gerade vom Stapel gelesene Zaehlerstaende *)
    ParSt, ParPro: LONGCARD;
        (* maximale vom Stapel gelesene Zaehlerstaende *)
BEGIN
    (* laufenden Block nicht vergessen auszuwerten: *)
    IF (steps # 0) OR (MaxPro # 0) THEN
        NaechsterBlock(Blockname)
    END;
    
    (* Blockschachtelung pruefen: *)
    NameCheck(names, Blockname);
    NamePop(names);

    (* initialisiere: *)
    ParSt:= 0; ParPro:= 0;
    
    (* werte parallel ausgefuehrte Blocks aus: *)
    CurSteps:= Pop();
    CurPro:= Pop();
    WHILE (CurSteps # 0) AND (CurPro # 0) DO
        IF CurSteps > ParSt THEN
            ParSt:= CurSteps
        END;
        ParPro:= ParPro + CurPro;
        CurSteps:= Pop();
        CurPro:= Pop()
    END;
    
    (* verknuepfe Ergebnis der parallelen Blocks mit
       zuvor erzielten Ergebnissen: *)
    CurSteps:= Pop();
    CurPro:= Pop();
    steps:= CurSteps + ParSt;
    IF CurPro > ParPro THEN
       MaxPro:= CurPro
    ELSE
       MaxPro:= ParPro
    END
END ParallelEnde;

PROCEDURE GezaehlteSchritte(): LONGCARD;
BEGIN
    RETURN steps
END GezaehlteSchritte;
   
PROCEDURE GezaehlteProzessoren(): LONGCARD;
BEGIN
    IF running THEN
        RETURN pro
    ELSE
        RETURN MaxPro
    END
END GezaehlteProzessoren;

PROCEDURE AddList(l: Reli.tReli): LONGREAL;
VAR a, b, res: LONGREAL;
    li: ARRAY [1..2] OF Reli.tReli;
    from, to: CARDINAL;
BEGIN
    li[1]:= l;
    Reli.Use(li[2]);
    from:= 2; to:= 1;

    WHILE List.Count(li[to]) > 1 DO
        to:= 3 - to; from:= 3 - from;
        List.First( li[from] );

        ParallelStart("Pram.AddList");
        REPEAT
            a:= Reli.OutCur( li[from] );
            b:= Reli.OutCur( li[from] );
            Reli.InsertBehind( li[to], a+b);
            Prozessoren(1);
            Schritte(1);
            NaechsterBlock("Pram.AddList");
        UNTIL List.Count(li[from]) < 2;
        ParallelEnde("Pram.AddList");

        IF List.Count(li[from]) = 1 THEN
            List.First(li[from]);
            Reli.InsertBehind(li[to], Reli.OutCur(li[from]))
        END;
    END;
    
    IF List.Count(li[to]) >= 1 THEN
        List.First(li[to]);
        res:= Reli.OutCur(li[to]);
    ELSE
        res:= 0.0
    END;

    List.DontUse(li[2]);
    RETURN res
END AddList;

BEGIN
    Cali.Use(stack);
    steps:= 0;
    MaxPro:= 0;
    
    NameId:= Type.New(TSIZE(tBlockname));
    List.Use(names, NameId)
END Pram.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
