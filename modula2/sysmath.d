(* ###GrepMarke###
\begin{DefModul}{SysMath}
\begin{verbatim}
   ###GrepMarke### *)

DEFINITION MODULE SysMath;

(*          Systemabhaengige mathematische Prozeduren
       (Atari ST, TOS 2.06, Megamax Modula-2 Compiler V4.2)
       
    In diesem Modul sind alle mathematischen Prozeduren gesammelt,
    um eine Portierung auf andere Rechner/Compiler zu vereinfachen.
*)

(*******************************)
(***** Typkonvertierungen: *****)

(* zu den Funktionen sind nur Erklaerungen angegeben, falls sie
   neben der Typkonvertierung noch weitere Effekte auf den
   jeweiligen Wert besitzen *)

PROCEDURE LCard2Card(x: LONGCARD): CARDINAL;

PROCEDURE LCard2LReal(x: LONGCARD): LONGREAL;

PROCEDURE Card2LCard(x: CARDINAL): LONGCARD;

PROCEDURE Card2LReal(x: CARDINAL): LONGREAL;

PROCEDURE LReal2Card(x: LONGREAL): CARDINAL;
(* Nachkommastellen werden abgeschnitten *)

PROCEDURE LReal2LCard(x: LONGREAL): LONGCARD;
(* Nachkommastellen werden abgeschnitten *)

PROCEDURE LReal2LInt(x: LONGREAL): LONGINT;
(* Nachkommastellen werden abgeschnitten *)

PROCEDURE entier(x: LONGREAL): LONGINT;
(* identisch zu 'LReal2LInt'; zur Erhoehung der Lesbarkeit des
   Quelltextes *)

PROCEDURE LInt2Int(x: LONGINT): INTEGER;

PROCEDURE LInt2LReal(x: LONGINT): LONGREAL;

PROCEDURE real(x: LONGINT): LONGREAL;
(* identisch zu 'LInt2LReal'; zur Erhoehung der Lesbarkeit des
   Quelltextes *)

PROCEDURE Int2LInt(x: INTEGER): LONGINT;

(*************************)
(***** Berechnungen: *****)

PROCEDURE cos(x: LONGREAL): LONGREAL;
(* Cosinus von x (Bogenmass) *)

PROCEDURE sin(x: LONGREAL): LONGREAL;
(* Sinus von x (Bogenmass) *)

PROCEDURE ln(x: LONGREAL): LONGREAL;
(* Logarithmus zur Basis e von x *)

PROCEDURE ld(x: LONGREAL): LONGREAL;
(* Logarithmus zur Basis 2 von x *)

PROCEDURE lg(x: LONGREAL): LONGREAL;
(* Logarithmus zur Basis 10 von x *)

PROCEDURE power(b, x: LONGREAL): LONGREAL;
(* b^x *)

PROCEDURE sqrt(x: LONGREAL): LONGREAL;
(* Wurzel von x *)

END SysMath.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
