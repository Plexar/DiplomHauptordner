
\begin{ImpModul}{SysMath}
\begin{verbatim}


IMPLEMENTATION MODULE SysMath;

(*          Systemabhaengige mathematische Prozeduren
       (Atari ST, TOS 2.06, Megamax Modula-2 Compiler V4.2)

            (Erklaerungen im Definitionsmodul)
*)

IMPORT MathLib0;

(*******************************)
(***** Typkonvertierungen: *****)

(* zu den Funktionen sind nur Erklaerungen angegeben, falls sie
   neben der Typkonvertierung noch weitere Effekte auf den
   jeweiligen Wert besitzen *)

PROCEDURE LCard2Card(x: LONGCARD): CARDINAL;
BEGIN
    RETURN SHORT(x)
END LCard2Card;

PROCEDURE LCard2LReal(x: LONGCARD): LONGREAL;
BEGIN
    RETURN LInt2LReal(x)
END LCard2LReal;

PROCEDURE Card2LCard(x: CARDINAL): LONGCARD;
BEGIN
    RETURN LONG(x)
END Card2LCard;

PROCEDURE Card2LReal(x: CARDINAL): LONGREAL;
BEGIN
    RETURN LInt2LReal(LONG(x))
END Card2LReal;

PROCEDURE LReal2Card(x: LONGREAL): CARDINAL;
BEGIN
    RETURN LInt2Int(LReal2LInt(x))
END LReal2Card;

PROCEDURE LReal2LCard(x: LONGREAL): LONGCARD;
BEGIN
    RETURN LReal2LInt(x)
END LReal2LCard;

PROCEDURE LReal2LInt(x: LONGREAL): LONGINT;
BEGIN
    RETURN MathLib0.entier(x)
END LReal2LInt;

PROCEDURE entier(x: LONGREAL): LONGINT;
BEGIN
    RETURN LReal2LInt(x)
END entier;

PROCEDURE LInt2Int(x: LONGINT): INTEGER;
BEGIN
    RETURN SHORT(x)
END LInt2Int;

PROCEDURE LInt2LReal(x: LONGINT): LONGREAL;
BEGIN
    RETURN MathLib0.real(x)
END LInt2LReal;

PROCEDURE real(x: LONGINT): LONGREAL;
BEGIN
    RETURN LInt2LReal(x)
END real;

PROCEDURE Int2LInt(x: INTEGER): LONGINT;
BEGIN
    RETURN LONG(x)
END Int2LInt;

(*************************)
(***** Berechnungen: *****)

PROCEDURE cos(x: LONGREAL): LONGREAL;
BEGIN
    RETURN MathLib0.cos(x)
END cos;

PROCEDURE sin(x: LONGREAL): LONGREAL;
BEGIN
    RETURN MathLib0.sin(x)
END sin;

PROCEDURE ln(x: LONGREAL): LONGREAL;
BEGIN
    RETURN MathLib0.ln(x)
END ln;

PROCEDURE ld(x: LONGREAL): LONGREAL;
(* Logarithmus zur Basis 2 von x *)
BEGIN
    RETURN MathLib0.ld(x)
END ld;

PROCEDURE lg(x: LONGREAL): LONGREAL;
BEGIN
    RETURN MathLib0.log(x)
END lg;

PROCEDURE power(b, x: LONGREAL): LONGREAL;
BEGIN
    RETURN MathLib0.power(b, x)
END power;

PROCEDURE sqrt(x: LONGREAL): LONGREAL;
BEGIN
    RETURN MathLib0.sqrt(x)
END sqrt;

END SysMath.

\end{verbatim}
\end{ImpModul}

