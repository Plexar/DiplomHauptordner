(* ###GrepMarke###
\begin{ProgModul}{strtest} 
\begin{verbatim} 
   ###GrepMarke### *)

MODULE strtest;

(*   Test des Moduls 'str'  *)

FROM InOut IMPORT WriteString, WriteLn, ReadString, ReadCard,
                  WriteCard;
IMPORT Str, Debug;

VAR
    s1, s2: ARRAY [1..40] OF CHAR;
    input: CARDINAL;
    pos: CARDINAL;
BEGIN
    Str.Empty(s1); Str.Empty(s2);
    WriteString(">>> Test des Moduls 'str' <<<"); WriteLn;
    REPEAT
        WriteString(" 0 - Ende "); WriteLn;
        WriteString(" 1 - string1  eingeben"); WriteLn;
        WriteString(" 2 - string2  eingeben"); WriteLn;
        WriteString(" 3 - Str.Equal(string1, string2) "); WriteLn;
        WriteString(" 4 - Str.Ordered(string1, string2)"); WriteLn;
        WriteString(" 5 - Str.Append(string1, string2)"); WriteLn;
        WriteString(" 6 - Str.In(string2, string1, pos)"); WriteLn;
        WriteString(" string1 = "); WriteString(s1); WriteLn;
        WriteString(" string2 = "); WriteString(s2); WriteLn;
        WriteString(" Auswahl? "); ReadCard(input);
        CASE input OF
            0 : (* tue nichts *)
          | 1 : WriteString(" string1? ");
                ReadString(s1);
          | 2 : WriteString(" string2? ");
                ReadString(s2);
          | 3 : IF Str.Equal(s1, s2) THEN
                    WriteString(" TRUE")
                ELSE
                    WriteString(" FALSE")
                END;
                WriteLn
          | 4 : IF Str.Ordered(s1, s2) THEN
                    WriteString(" TRUE")
                ELSE
                    WriteString(" FALSE")
                END;
                WriteLn
          | 5 : Str.Append(s1, s2)
          | 6 : IF Str.In(s2, s1, pos) THEN
                    WriteString(" gefunden:  pos = ");
                    WriteCard(pos,5)
                ELSE
                    WriteString(" NICHT gefunden")
                END;
                WriteLn
        ELSE
            WriteString(" Eingabefehler")
        END
    UNTIL input = 0
END strtest.
(* ###GrepMarke###
\end{verbatim}
\end{ProgModul}
   ###GrepMarke### *)
