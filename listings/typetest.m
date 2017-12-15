
\begin{ProgModul}{typetest} 
\begin{verbatim} 


MODULE typetest;

(*
     Test des Moduls 'Type'
*)

IMPORT Debug;
FROM InOut IMPORT WriteCard, WriteString,
                  ReadCard, ReadLCard, ReadString, WriteLn;
FROM Sys IMPORT tPOINTER;
IMPORT Type;

TYPE tTestRec = RECORD
                   id: Type.Id;
                   size: LONGCARD;
                   val: ARRAY [1..4] OF tPOINTER
               END;
     tTestArray = ARRAY [1..4] OF tTestRec;

VAR
    eingabe: CARDINAL;
    wert: CARDINAL;
    TestArray: tTestArray;
    i: CARDINAL;
    cur: CARDINAL;
    name: ARRAY [1..40] OF CHAR;
    FoundId: Type.Id;
    dummy: BOOLEAN;

PROCEDURE NewProc1(h: tPOINTER);
BEGIN
    WriteString("Hier ist NewProc1 ."); WriteLn
END NewProc1;

PROCEDURE DelProc1(h: tPOINTER);
BEGIN
    WriteString("Hier ist DelProc1 ."); WriteLn
END DelProc1;

PROCEDURE EquProc1(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc1 ."); WriteLn;
    RETURN TRUE
END EquProc1;

PROCEDURE OrdProc1(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc1 ."); WriteLn;
    RETURN TRUE
END OrdProc1;

PROCEDURE NewProc2(h: tPOINTER);
BEGIN
    WriteString("Hier ist NewProc2 ."); WriteLn
END NewProc2;

PROCEDURE DelProc2(h: tPOINTER);
BEGIN
    WriteString("Hier ist DelProc2 ."); WriteLn
END DelProc2;

PROCEDURE EquProc2(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc2 ."); WriteLn;
    RETURN TRUE
END EquProc2;

PROCEDURE OrdProc2(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc2 ."); WriteLn;
    RETURN TRUE
END OrdProc2;

PROCEDURE NewProc3(h: tPOINTER);
BEGIN
    WriteString("Hier ist NewProc3 ."); WriteLn
END NewProc3;

PROCEDURE DelProc3(h: tPOINTER);
BEGIN
    WriteString("Hier ist DelProc3 ."); WriteLn
END DelProc3;

PROCEDURE EquProc3(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc3 ."); WriteLn;
    RETURN TRUE
END EquProc3;

PROCEDURE OrdProc3(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc3 ."); WriteLn;
    RETURN TRUE
END OrdProc3;

PROCEDURE NewProc4(h: tPOINTER);
BEGIN
    WriteString("Hier ist NewProc4 ."); WriteLn
END NewProc4;

PROCEDURE DelProc4(h: tPOINTER);
BEGIN
    WriteString("Hier ist DelProc4 ."); WriteLn
END DelProc4;

PROCEDURE EquProc4(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc4 ."); WriteLn;
    RETURN TRUE
END EquProc4;

PROCEDURE OrdProc4(h1, h2: tPOINTER): BOOLEAN;
BEGIN
    WriteString("Hier ist EquProc4 ."); WriteLn;
    RETURN TRUE
END OrdProc4;

BEGIN
    cur:= 4;
    WriteLn;
    WriteString(">>> Test des Moduls 'Type' <<<");
    WriteLn;
    REPEAT
        WriteString(" 0 - Ende"); WriteLn;
        WriteString(" 1 - Typ waehlen"); WriteLn;
        WriteString(" 2 - New"); WriteLn;
        WriteString(" 3 - SetName"); WriteLn;
        WriteString(" 4 - GetId"); WriteLn;
        WriteString(" 5 - NewI"); WriteLn;
        WriteString(" 6 - DelI"); WriteLn;
        WriteString(" 7 - Proc's"); WriteLn;
        WriteString(" aktueller Typ: ");
        WriteCard(cur,5); WriteLn;
        WriteString("Auswahl? "); ReadCard(eingabe); WriteLn;
        WITH TestArray[cur] DO
            CASE eingabe OF
                0: (* tue nichts *)
              | 1: WriteString(" Typ [1..4]? ");
                   ReadCard(cur); WriteLn;
              | 2: WriteString(" Groesse? ");
                   ReadLCard(size);
                   id:= Type.New(size);
                   CASE cur OF
                       1:
                          Type.SetNewProc(id, NewProc1);
                          Type.SetDelProc(id, DelProc1);
                          Type.SetEquProc(id, EquProc1);
                          Type.SetOrdProc(id, OrdProc1)
                     | 2:
                          Type.SetNewProc(id, NewProc2);
                          Type.SetDelProc(id, DelProc2);
                          Type.SetEquProc(id, EquProc2);
                          Type.SetOrdProc(id, OrdProc2)
                     | 3:
                          Type.SetNewProc(id, NewProc3);
                          Type.SetDelProc(id, DelProc3);
                          Type.SetEquProc(id, EquProc3);
                          Type.SetOrdProc(id, OrdProc3)
                     | 4:
                          Type.SetNewProc(id, NewProc4);
                          Type.SetDelProc(id, DelProc4);
                          Type.SetEquProc(id, EquProc4);
                          Type.SetOrdProc(id, OrdProc4)
                   END;
              | 3: WriteString(" Name? ");
                   ReadString(name);
                   Type.SetName(id, name);
              | 4: WriteString(" Name? ");
                   ReadString(name);
                   WriteString("Id: ");
                   WriteCard(LONGCARD(Type.GetId(name)), 5);
                   WriteLn;
              | 5: WriteString(" Nummer [1..4]? ");
                   ReadCard(wert);
                   val[wert]:= Type.NewI(id)
              | 6: WriteString(" Nummer [1..4]? ");
                   ReadCard(wert);
                   Type.DelI(id, val[wert])
              | 7: WriteString(" EquProc: "); WriteLn;
                   dummy:= Type.EquI(id, val[1], val[2]);
                   WriteString(" OrdProc: "); WriteLn;
                   dummy:= Type.OrdI(id, val[1], val[2])
            ELSE
                WriteString(" Eingabefehler"); WriteLn
            END;
        END;
    UNTIL eingabe=0;
END typetest.

\end{verbatim}
\end{ProgModul}

