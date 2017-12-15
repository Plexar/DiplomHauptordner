
\begin{ProgModul}{listtest} 
\begin{verbatim} 
 

MODULE listtest;

(*
     Test der Module 'List' und 'Cali'
*)

IMPORT Debug;
FROM InOut IMPORT WriteCard, WriteString,
                  ReadCard, ReadString, WriteLn;
IMPORT Sys, Type, Simptype, List, Cali;
FROM Sys IMPORT tPOINTER;
FROM Simptype IMPORT pCard;

VAR
    eingabe: CARDINAL;
    wert: CARDINAL;
    l: Cali.tCali;

    pos: List.tPos;
    
PROCEDURE PrintItem(item: tPOINTER);
VAR
    p: pCard;
BEGIN
    p:= item;
    WriteCard(p^,5);
    IF List.GetPos(l) = pos THEN
        WriteString("<-- ")
    END
END PrintItem;

PROCEDURE PrintList(l: Cali.tCali);
(* Gibt die Elemente von 'l' auf der Standardausgabe aus. *)
BEGIN
    pos:= List.GetPos(l);
    List.Scan(l,PrintItem);
    List.SetPos(l,pos)
END PrintList;

PROCEDURE WriteBool(v: BOOLEAN);
(* Gibt 'v' auf der Standardausgabe aus. *)
BEGIN
    IF v THEN
        WriteString("TRUE")
    ELSE
        WriteString("FALSE")
    END
END WriteBool;

BEGIN
    WriteLn;
    WriteString(">>> Test der Module 'List' und 'Cali' <<<");
    WriteLn;
    Cali.Use(l);
    REPEAT
        WriteString(" 0 - Ende"); WriteLn;
        WriteString(" 1 - Empty"); WriteLn;
        WriteString(" 2 - Next"); WriteLn;
        WriteString(" 3 - Prev"); WriteLn;
        WriteString(" 4 - InsertBefore"); WriteLn;
        WriteString(" 5 - InsertBehind"); WriteLn;
        WriteString(" 6 - DelCur"); WriteLn;
        WriteString(" 7 - AtFirst"); WriteLn;
        WriteString(" 8 - AtLast"); WriteLn;
        WriteString(" 9 - Count"); WriteLn;
        WriteString(" Liste: ");
        PrintList(l); WriteLn;
        WriteString("Auswahl? "); ReadCard(eingabe); WriteLn;
        CASE eingabe OF
            0: (* tue nichts *)
          | 1: List.Empty(l)
          | 2: List.Next(l)
          | 3: List.Prev(l)
          | 4: WriteString(" Wert? "); ReadCard(wert); WriteLn;
               Cali.InsertBefore(l,wert)
          | 5: WriteString(" Wert? "); ReadCard(wert); WriteLn;
               Cali.InsertBehind(l,wert)
          | 6: List.DelCur(l)
          | 7: WriteBool(List.AtFirst(l)); WriteLn
          | 8: WriteBool(List.AtLast(l)); WriteLn
          | 9: WriteString(" Laenge der Liste: ");
               WriteCard(List.Count(l),4); WriteLn
        ELSE
            WriteString(" Eingabefehler"); WriteLn
        END;
        List.CheckStructure(l)
    UNTIL eingabe=0;
END listtest.

\end{verbatim}
\end{ProgModul}

