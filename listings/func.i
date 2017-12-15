
\begin{ImpModul}{Func} 
\begin{verbatim} 


IMPLEMENTATION MODULE Func;

(*  Prozeduren und Funktionen fuer diverse Zwecke

       ( Erklaerungen im Definitionsmodul )
*)
    
FROM InOut IMPORT WriteString, WriteLn;
IMPORT SysMath;
FROM SysMath IMPORT LReal2LInt, LInt2LReal;

PROCEDURE Message(name, text: ARRAY OF CHAR);
(* Es wird eine Meldung ausgegeben, in der 'name' als Name der aus-
   loesenden Funktion und 'text' als Text der Meldung erscheint.
*)
BEGIN
    WriteString("*** "); WriteString(name);
    WriteString(":"); WriteLn;
    WriteString("*** "); WriteString(text);
END Message;

PROCEDURE Error(name, text: ARRAY OF CHAR);
(* Diese Prozedur gibt eine Fehlermeldung aus. In der Meldung
   erscheint 'name' als ausloesende Prozedur und 'text' als
   Text der Meldung.
*)
BEGIN
    Message(name, text); WriteLn;
    HALT
END Error;

PROCEDURE MaxCard(a,b: CARDINAL): CARDINAL;
BEGIN
    IF a>b THEN
        RETURN a
    END;
    RETURN b
END MaxCard;

PROCEDURE MaxLCard(a,b: LONGCARD): LONGCARD;
BEGIN
    IF a>b THEN
        RETURN a
    END;
    RETURN b
END MaxLCard;

PROCEDURE MinCard(a,b: CARDINAL): CARDINAL;
BEGIN
    IF a>b THEN
        RETURN b
    END;
    RETURN a
END MinCard;

PROCEDURE MinLCard(a,b: LONGCARD): LONGCARD;
BEGIN
    IF a>b THEN
        RETURN b
    END;
    RETURN a
END MinLCard;

PROCEDURE MaxReal(a,b: LONGREAL): LONGREAL;
BEGIN
    IF a>b THEN
        RETURN a
    END;
    RETURN b
END MaxReal;

PROCEDURE Ceil(a: LONGREAL): LONGINT;
BEGIN
    IF (a < 0.0) OR (a = LInt2LReal(LReal2LInt(a))) THEN
        RETURN LReal2LInt(a)
    END;
    RETURN LReal2LInt(a + 1.0)
END Ceil;

PROCEDURE Floor(a: LONGREAL): LONGINT;
BEGIN
    IF (a >= 0.0) OR (a = LInt2LReal(LReal2LInt(a))) THEN
        RETURN LReal2LInt(a)
    END;
    RETURN LReal2LInt(a - 1.0)
END Floor;

PROCEDURE ModReal(a,b: LONGREAL): LONGREAL;
BEGIN
    RETURN a - b * LInt2LReal(LReal2LInt(a/b))
END ModReal;

END Func.

\end{verbatim}
\end{ImpModul}

