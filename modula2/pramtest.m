(* ###GrepMarke###
\begin{ProgModul}{pramtest}
\begin{verbatim}
   ###GrepMarke### *)

MODULE pramtest;

(*
     Test des Moduls 'Pram'
*)

IMPORT Debug;
FROM InOut IMPORT WriteCard, ReadLCard, ReadCard,
                  WriteString, ReadString, WriteLn;
FROM Sys IMPORT tPOINTER;
IMPORT Pram;

VAR
    eingabe: CARDINAL;
    wert: LONGCARD;
    
BEGIN
    WriteLn;
    WriteString(">>> Test des Moduls 'Pram' <<<");
    WriteLn;
    REPEAT
        WriteString(" 0 - Ende"); WriteLn;
        WriteString(" 1 - Pram.Start"); WriteLn;
        WriteString(" 2 - Pram.Ende"); WriteLn;
        WriteString(" 3 - Prozessoren eingeben"); WriteLn;
        WriteString(" 4 - Schritte eingeben"); WriteLn;
        WriteString(" 5 - ParallelStart"); WriteLn;
        WriteString(" 6 - NaechsterBlock"); WriteLn;
        WriteString(" 7 - ParallelEnde"); WriteLn;
        WriteString(" GezaehlteSchritte() = ");
        WriteCard(Pram.GezaehlteSchritte(), 4);
        WriteString(";   GezaehlteProzessoren() = ");
        WriteCard(Pram.GezaehlteProzessoren(), 4);
        WriteLn;
        WriteString("Auswahl? "); ReadCard(eingabe); WriteLn;
        CASE eingabe OF
            0: (* tue nichts *)
          | 1: Pram.Start
          | 2: Pram.Ende
          | 3: WriteString("   Prozessoren? ");
               ReadLCard(wert); WriteLn;
               Pram.Prozessoren(wert);
          | 4: WriteString("   Schritte? ");
               ReadLCard(wert); WriteLn;
               Pram.Schritte(wert);
          | 5: Pram.ParallelStart("pramtest")
          | 6: Pram.NaechsterBlock("pramtest")
          | 7: Pram.ParallelEnde("pramtest")
        ELSE
            WriteString(" Eingabefehler"); WriteLn
        END
    UNTIL eingabe=0;
END pramtest.
(* ###GrepMarke###
\end{verbatim}
\end{ProgModul}
   ###GrepMarke### *)
