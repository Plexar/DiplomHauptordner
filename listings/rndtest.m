
\begin{ProgModul}{rndtest} 
\begin{verbatim} 


MODULE rndtest;

(*   Test des Moduls 'Rnd'  *)

FROM InOut IMPORT WriteString, WriteLn, ReadString, ReadCard,
                  WriteCard;
IMPORT Rnd;

VAR
    w: ARRAY [1..6] OF LONGCARD;
    Wurfzahl,i : CARDINAL;
    input, input2: CARDINAL;
    gen: Rnd.tGen;
    
BEGIN
    WriteString(">>> Test des Moduls 'rnd' <<<"); WriteLn;
    Rnd.Use(gen);
    WriteString(" Anfangszahl? "); ReadCard(input);
    WriteLn;
    Rnd.Start(gen, input);
    REPEAT
        WriteString(" 0 - Ende "); WriteLn;
        WriteString(" 1 - neue Anfangszahl"); WriteLn;
        WriteString(" 2 - neuer Generator"); WriteLn;
        WriteString(" 3 - Wuerfeltest"); WriteLn;
        WriteString(" Auswahl? "); ReadCard(input);
        CASE input OF
            0 : (* tue nichts *)
          | 1 : WriteString(" Anfangszahl? "); ReadCard(input2);
                WriteLn;
                Rnd.Start(gen, input2)
          | 2 : Rnd.DontUse(gen);
                Rnd.Use(gen)
          | 3 : WriteString(" Anzahl der Wuerfe? ");
                ReadCard(Wurfzahl);
                Rnd.Range(gen,1.0,6.0);
                FOR i:= 1 TO 6 DO
                    w[i]:= 0;
                END;
                FOR i:= 1 TO Wurfzahl DO
                    INC( w[ SHORT(Rnd.Int(gen)) ] )
                END;
                FOR i:= 1 TO 6 DO
                    WriteCard(i,2); WriteString(": ");
                    WriteCard(w[i],0);
                    WriteLn
                END
        ELSE
            WriteString(" Eingabefehler")
        END
    UNTIL input = 0
END rndtest.

\end{verbatim}
\end{ProgModul}

