(* ###GrepMarke###
\begin{DefModul}{Simptype} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Simptype; (* SIMPle TYPEs *)

(*    einfache Datentypen fuer das Modul 'Type'

   'Simptype' definiert die Typen 'LONGCARD', 'LONGINT' und
   'LONGREAL' fuer das Modul 'Type'
   
*)

IMPORT Sys, Type;
FROM Sys IMPORT tPOINTER;

TYPE pCard = POINTER TO LONGCARD;
     pInt  = POINTER TO LONGINT;
     pReal = POINTER TO REAL;
     pPoint = POINTER TO tPOINTER;

PROCEDURE CardId(): Type.Id;
(* Funktionsergebnis ist der Typindetifikator fuer 'LONGCARD' *)

PROCEDURE NewCard(val: LONGCARD): pCard;
(* Funktionsergebnis ist ein Zeiger auf eine Zahl vom Typ LONGCARD
   mit dem Wert 'val' *)

PROCEDURE DelCard(VAR val: pCard);
(* Der Speicherbereich fuer die Zahl vom Typ LONGCARD, auf die 'val'
   zeigt, wird freigegeben. *)

PROCEDURE IntId(): Type.Id;
(* ... analog 'CardId', jedoch fuer LONGINT *)

PROCEDURE NewInt(val: LONGINT): pInt;
(* ... analog 'NewCard', jedoch fuer LONGINT *)

PROCEDURE DelInt(VAR val: pInt);
(* ... analog 'DelCard', jedoch fuer LONGINT *)

PROCEDURE RealId(): Type.Id;
(* ... analog 'CardId', jedoch fuer LONGREAL *)

PROCEDURE NewReal(val: LONGREAL): pReal;
(* ... analog 'NewCard', jedoch fuer LONGREAL *)

PROCEDURE DelReal(VAR val: pReal);
(* ... analog 'DelCard', jedoch fuer LONGREAL *)

PROCEDURE PointId(): Type.Id;
(* ... analog 'CardId', jedoch fuer pPoint *)

PROCEDURE NewPoint(val: pPoint): pPoint;
(* ... analog 'NewCard', jedoch fuer pPoint *)

PROCEDURE DelPoint(VAR val: pPoint);
(* ... analog 'DelCard', jedoch fuer pPoint *)

END Simptype.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *) 
