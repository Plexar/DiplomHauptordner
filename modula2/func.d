(* ###GrepMarke###
\begin{DefModul}{Func} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Func; (* procedures and FUNCtions *)

(*  Prozeduren und Funktionen fuer diverse Zwecke  *)

IMPORT SysMath;

PROCEDURE Message(name, text: ARRAY OF CHAR);
(* Es wird eine Meldung ausgegeben, in der 'name' als Name der aus-
   loesenden Funktion und 'text' als Text der Meldung erscheint.
*)

PROCEDURE Error(name, text: ARRAY OF CHAR);
(* Diese Prozedur gibt eine Fehlermeldung aus. In der Meldung
   erscheint 'name' als ausloesende Prozedur und 'text' als
   Text der Meldung.
*)

PROCEDURE MaxCard(a,b: CARDINAL): CARDINAL;
(* Das Funktionsergebnis ist der groessere der beiden
   Werte 'a' und 'b'. *)

PROCEDURE MaxLCard(a,b: LONGCARD): LONGCARD;
(* ... analog 'MaxCard', jedoch fuer LONGCARD *)
   
PROCEDURE MinCard(a,b: CARDINAL): CARDINAL;
(* Das Funktionsergebnis ist der kleinere er beiden
   Werte 'a' und 'b'. *)

PROCEDURE MinLCard(a,b: LONGCARD): LONGCARD;
(* ... analog 'MinCard', jedoch fuer LONGCARD *)

PROCEDURE MaxReal(a,b: LONGREAL): LONGREAL;
(* ... analog 'MaxCard' ... *)

PROCEDURE Ceil(a: LONGREAL): LONGINT;
(* Das Funktionsergebnis ist die kleinste ganze Zahl 'b', fuer
   die gilt 'b >= a'. *)
   
PROCEDURE Floor(a: LONGREAL): LONGINT;
(* Das Funktionsergebnis ist die groesste ganze Zahl 'b', fuer
   die gilt 'b <= a'. *)

PROCEDURE ModReal(a,b: LONGREAL): LONGREAL;
(* Das Funktionsergebnis ist der Rest der Division von
   a durch b:
       a - b * real(entier(a/b))  *)

END Func.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
