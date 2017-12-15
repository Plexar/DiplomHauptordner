(* ###GrepMarke###
\begin{ProgModul}{main}
\begin{verbatim}
   ###GrepMarke### *)

MODULE main;

(* Hauptmodul der Implementierungen zur Diplomarbeit
   'Algorithmen zur parallelen Determinantenberechnung'
   
   Dieses Modul erlaubt es, die implementierten Algorithmen
   auszuprobieren.
*)

FROM InOut IMPORT WriteReal, WriteString, WriteLn,
                  ReadCard, ReadString, ReadLn;

(* Um die korrekte Reihenfolge bei automatischer Kompilation und
   Initialisierung zu gewaehrleisten, werden hier auch die Module
   importiert, die nicht direkt in 'main' verwendet werden.
*)

IMPORT SysMath, Sys,
       Func,
       Rnd, Str,
       Type,
       Frag, List, Simptype,
       Mat, Cali, Inli, Reli,
       Hash, Pram,
       Rema,
       Data, Mali,
       Det;
       
VAR
    cur: Data.Id;
        (* aktuell in Bearbeitung befindlicher Testdatensatz *)

PROCEDURE WaitReturn;
VAR
    input: ARRAY [1..2] OF CHAR;
BEGIN
    WriteString("    <RETURN> ...");
    ReadString(input)
END WaitReturn;

PROCEDURE PrintHelp();
(* Diese Prozedur gibt einen Hilfstext fuer den Benutzer aus. *)
BEGIN
    WriteString(
    ">>>> Hilfe zur Programmbedienung <<<<");
    WriteLn; WriteString(
    "Das Programm versteht folgende Befehle (Gross- / ");
    WriteLn; WriteString(
    "Kleinschreibung wird nicht beachtet):");
    WriteLn; WriteLn; WriteString(
    "  Befehl       Wirkung");
    WriteLn; WriteString(
    "  ------       -------");
    WriteLn; WriteString(
    "  ?, h,        diesen Text ausgegeben");
    WriteLn; WriteString(
    "  help, hilfe");
    WriteLn; WriteString(
    "  q, exit      Programm beenden");
    WriteLn; WriteString(
    "  find         anderen/neuen Testdatensatz bearbeiten");
    WriteLn; WriteString(
    "  show         Testdatensatz anzeigen (Falls die Matrix zu");
    WriteLn; WriteString(
    "                   gross ist, wird sie nicht automatisch mit");
    WriteLn; WriteString(
    "                   angezeigt. Dies kann mit 'mshow' geschehen)");
    WriteLn; WriteString(
    "  mshow        Matrix des Testdatensatzes anzeigen");
    WriteLn; WriteString(
    "  del          Testdatensatz loeschen");
    WriteLn; WriteString(
    "  ls           Testdatensaetze auflisten");
    WriteString(" (die im Speicher stehen)");
    WriteLn; WriteString(
    "  param        Parameter fuer Matrizengenerierung festlegen");
    WriteLn; WriteString(
    "  gen          Matrix generieren");
    WriteLn; WaitReturn; WriteString(
    "  csanky       Det. mit Alg. von Csanky berechnen");
    WriteLn; WriteString(
    "  bgh          Det. mit Alg. von Borodin, von zur Gathen");
    WriteLn; WriteString(
    "                   und Hopcroft berechnen");
    WriteLn; WriteString(
    "  berk         Det. mit Alg. von Berkowitz berechnen");
    WriteLn; WriteString(
    "  pan          Det. mit Alg. von Pan berechnen");
    WriteLn;
END PrintHelp;

PROCEDURE CommandNumber(VAR c, i: ARRAY OF CHAR): CARDINAL;
(* 'c' muss eine Zeichenkette entsprechend der Beschreibung fuer
   die Variable 'commands' enthalten. 'i' wird als Befehl
   betrachtet. Anhand von 'commands' wird diesem Befehl eine
   Befehlsnummer zugeordnet und als Funktionswert zurueck-
   gegeben. *)
VAR
    pos: CARDINAL;
    erg: CARDINAL; (* Funktionsergebnis *)
BEGIN
    IF Str.In(i,c,pos) THEN
        WHILE (c[pos] # ',') DO
            INC(pos)
        END;
        INC(pos);
        erg:= 0;
        REPEAT
            erg:= erg*10 + (ORD(c[pos]) - ORD('0'));
            INC(pos);
        UNTIL (c[pos] = ';') OR (c[pos] = CHR(0));
    ELSE
        erg:= 0
    END;
    RETURN erg
END CommandNumber;

PROCEDURE dummy;
BEGIN
    WriteString(" Befehl noch nicht implementiert"); WriteLn
END dummy;

PROCEDURE IsSet(dat: Data.Id): BOOLEAN;
(* Falls 'dat = NIL' wird eine Fehlermeldung ausgeben. In diesem
   Fall ist der Funktionswert FALSE, andernfalls TRUE. *)
BEGIN
    IF (dat = Data.Id(NIL)) THEN
        WriteString(" kein Datensatz ausgewaehlt");
        WriteString(" (zuerst  find  benutzen)");
        WriteLn;
        RETURN FALSE
    END;
    RETURN TRUE
END IsSet;

VAR
    input: ARRAY [1..10] OF CHAR;
        (* Eingabe des Benutzers *)
    commands: ARRAY [1..160] OF CHAR;
        (* Zeichenkette zur Zuordnung von Befehlen zu Befehlsnummern;
           Format:
               command    :  Befehlskode ";" { Befehlskode ";" }
               Befehlskode:  <Zeichenkette> "," <Ziffernfolge>
        *)
    CommNum: CARDINAL;
        (* Befehlsnummer zu 'input' *)
    name: ARRAY [1..16] OF CHAR;
        (* vom Benutzer eingegebener Dateiname *)

PROCEDURE ComParam;
(* Befehl 'param' *)
VAR
    input: ARRAY [1..2] OF CHAR;
    size: CARDINAL; (* vom Benutzer angegebene Matrizengroesse *)
    rank: CARDINAL; (* ... Rang *)
    mult: CARDINAL; (* ... Vielfachheit eines Eigenwertes *)
    i: Data.tAlg;
BEGIN
    IF IsSet(cur) THEN
        FOR i:= Data.laplace TO Data.pan DO
            Data.SetAlg(cur, i, 0.0, 0, 0)
        END;
        
        WriteLn;
        WriteString("Anzahl der Zeilen und Spalten? ");
        ReadCard(size); WriteLn;
        WriteString("Rang? "); ReadCard(rank); WriteLn;
        WriteString("Nachkommastellen (j/n)? ");
        ReadString(input); WriteLn;
        Rema.SetSize( Data.GetMat(cur), size, size);
        Rema.SetRank( Data.GetMat(cur), size);
        Rema.SetReal( Data.GetMat(cur),
                     Str.Equal(input,"j")
        );
        REPEAT
            WriteString("Vielfachheit ungleich 1 eines");
            WriteString(" Eigenwertes (0,1 : Ende) ? ");
            ReadCard(mult); WriteLn;
            IF mult > 1 THEN
                Rema.SetMultiplicity(
                    Data.GetMat(cur), mult
                );
            END
        UNTIL mult <= 1;
        Data.HasChanged(cur)
    END
END ComParam;

PROCEDURE ComAlg(alg: Data.tAlg);
(* Befehle: csanky, bgh, berk, pan;
   'alg' gibt zu benutzenden Algorithmus an *)
VAR
    det: LONGREAL;
BEGIN
    Pram.Start;
    CASE alg OF
        Data.csanky :
            det:= Det.Csanky( Data.GetMat(cur) )
      | Data.bgh :
            det:= Det.BGH( Data.GetMat(cur) )
      | Data.berk :
            det:= Det.Berkowitz( Data.GetMat(cur) )
      | Data.pan :
            det:= Det.Pan( Data.GetMat(cur) )
    END;
    Pram.Ende;
    Data.SetAlg(cur, alg, det, Pram.GezaehlteProzessoren(),
                Pram.GezaehlteSchritte()
    )
END ComAlg;

BEGIN
    Str.Empty(commands);
    Str.Assign(commands,"h,1;?,1;help,1;hilfe,1;q,2;exit,2;");
    Str.Append(commands,"find,3;show,4;mshow,5;param,6;gen,7;");
    Str.Append(commands,";csanky,9;bgh,10;berk,11;pan,12;");
    Str.Append(commands,"del,13;ls,14;");
    cur:= Data.Id(NIL);

    WriteLn;
    WriteString("*** Algorithmen zur parallelen ");
    WriteString("Determinantenberechnung ***"); WriteLn;
    REPEAT
        WriteLn;
        WriteString(">> "); ReadString(input);
        WriteLn;
        Str.Lower(input);
        CommNum:= CommandNumber(commands, input);
        CASE CommNum OF
            1 : (* h, ?, help, hilfe *)
                PrintHelp
          | 2 : (* q, exist *)
                (* tue nichts *)
          | 3 : (* find *)
                IF cur # Data.Id(NIL) THEN
                    Data.FlushOnly(cur)
                END;
                WriteString("Name? "); ReadString(name); WriteLn;
                Data.Find(cur,name);
          | 4 : (* show *)
                IF IsSet(cur) THEN
                    Data.Write(cur);
                    WriteString("Bei der Generierung bestimmte");
                    WriteString(" Determinante: ");
                    WriteReal( Rema.Det( Data.GetMat(cur) ), 12, 4);
                    WriteLn;
                    WriteString(
                    " ... zur Fortsetzung 'RETURN'-Taste ...");
                    ReadString(input);
                    IF Rema.Rows( Data.GetMat(cur) )
                       <= Rema.MaxIoRow
                    THEN
                        Rema.Write( Data.GetMat(cur) )
                    END
                END
          | 5 : (* mshow *)
                IF IsSet(cur) THEN
                    Rema.Write(Data.GetMat(cur))
                END
          | 6 : (* param *)
                ComParam
          | 7 : (* gen *)
                IF IsSet(cur) THEN
                    Rema.Randomize( Data.GetMat(cur) )
                END;
          | 9..12 :
                (* csanky, bgh, berk, pan *)
                IF IsSet(cur) THEN
                    ComAlg(VAL(Data.tAlg, CommNum-8))
                END;
          | 13: (* del *)
                IF cur # Data.Id(NIL) THEN
                    Data.FlushOnly(cur)
                END;
                WriteString("Name? "); ReadString(name); WriteLn;
                Data.Find(cur,name);
                Data.Del(cur)
          | 14: (* ls *)
                Data.ListNames;
                WHILE Data.NextName(name) DO
                    WriteString(name); WriteLn
                END
        ELSE
            WriteString(" Befehl unbekannt");
            WriteString(" (fuer Hilfestellung  h  eingeben)");
            WriteLn
        END
    UNTIL CommNum= 2;
    Data.End
END main.
(* ###GrepMarke###
\end{verbatim}
\end{ProgModul}
   ###GrepMarke### *)
