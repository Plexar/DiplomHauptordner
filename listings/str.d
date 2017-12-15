
\begin{DefModul}{Str} 
\begin{verbatim} 


DEFINITION MODULE Str;

(*    Handhabung von Zeichenketten
   
   Falls nicht anders angegeben wird 0 als erster Index
   innerhalb einer Zeichenkette betrachtet.
   Ein Null-Byte (0C) wird als einer Zeichenkette
   betrachtet.
   Zur Steigerung der Effizienz sind bei allen Prozeduren auch
   die Eingabeparameter als Variablenparameter deklariert.
*)

IMPORT Func;

CONST
     MaxString=80;

TYPE
    tStr= ARRAY [0..MaxString-1] OF CHAR;

PROCEDURE Empty(VAR str: ARRAY OF CHAR);
(* 'str' wird geloescht (mit 0C gefuellt). *)

PROCEDURE Assign(VAR dst: ARRAY OF CHAR; src: ARRAY OF CHAR);
(* 'dst' wird an 'src' zugewiesen
   (ggf. wird 'dst' mit 0C aufgefuellt).
*)

PROCEDURE Append(VAR dest: ARRAY OF CHAR;
                 suffix: ARRAY OF CHAR);
(* 'suffix' wird an 'dest' angehaengt, soweit in 'dest'
   noch Platz ist.
*)

PROCEDURE Equal(VAR x: ARRAY OF CHAR;
                    y: ARRAY OF CHAR): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls die Zeichenketten
   'x' und 'y' gleich sind, sonst FALSE. Leerstellen sind
   relevant! Angehaengte Null-Bytes werden nicht beachtet.
*)

PROCEDURE Ordered(VAR x: ARRAY OF CHAR;
                      y: ARRAY OF CHAR): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls 'a' nach lexikalischer
   Ordnung kleiner als 'b' ist. Andernfalls ist das
   Funktionsergebnis FALSE. *)

PROCEDURE Length(VAR str: ARRAY OF CHAR): CARDINAL;
(* Das Funktionsergebnis ist die Laenge von 'str'
   (Index des ersten unbenutzten Elements).
   Angehaengte Null-Bytes werden nicht beachtet.
*)

PROCEDURE Insert(VAR substr, str: ARRAY OF CHAR;
                 inx: CARDINAL);
(* 'substr' wird in 'str' eingefuegt, beginnend bei 'str[inx]'.
   'inx' darf keine Position hinter der in 'str' gespeicherten
   Zeichenkette bezeichnen.
*)

PROCEDURE Delete(VAR str: ARRAY OF CHAR; inx,len: CARDINAL);
(* Beginnend bei 'str[inx]' werden 'len' Zeichen aus 'str'
   geloescht.
*)

PROCEDURE In(VAR substr, str: ARRAY OF CHAR;
             VAR pos: CARDINAL): BOOLEAN;
(* Falls 'substr' in 'str' enthalten ist, wird in 'pos' der Index
   des ersten Auftretens zurueckgegeben und der Funktionswert ist
   TRUE. Ansonsten ist der Funktionswert FALSE und 'pos'
   undefiniert.
*)

PROCEDURE NewSub(switch: BOOLEAN);
(* Es wird die Initialisierung der Suche von 'substr' in der Prozedur
   'In' ein- oder ausgeschaltet. Bei ausgeschalteter Initialisierung
   verlaeuft die Suche u. U. deutlich schneller. In diesem Fall muss
   jedoch bei jedem Aufruf von 'In' die gleiche Zeichenkette an 'substr'
   uebergeben werden.
   'switch = TRUE' schaltet die Initialisierung ein und 'switch = FALSE'
   schaltet sie aus.
*)

PROCEDURE Lower(VAR s: ARRAY OF CHAR);
(* Alle in 's' auftretenden Grossbuchstaben werden durch die
   zugehoerigen Kleinbuchstaben ersetzt. Ein 0-Byte wird als
   Ende der Zeichenkette betrachtet. *)

END Str.

\end{verbatim}
\end{DefModul}

