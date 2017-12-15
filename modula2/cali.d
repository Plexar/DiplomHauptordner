(* ###GrepMarke###
\begin{DefModul}{Cali} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Cali; (* CArdLIst*)

(*
   Listen von ganzen Zahlen (Typ LONGCARD) unter Verwendung
   des Moduls 'List'
*)

IMPORT Sys, Type, Simptype, List;

TYPE tCali= List.tList;

(* Die folgenden Prozeduren entsprechen in ihrer Bedeutung den
   gleichnamigen im Modul 'List', jedoch angepasst auf den
   Typ CARDINAL als Listenelemente. *)

PROCEDURE Use(VAR list: tCali);

PROCEDURE InsertBefore(list: tCali; item: LONGCARD);

PROCEDURE InsertBehind(list: tCali; item: LONGCARD);

PROCEDURE Insert(list: tCali; item: LONGCARD);

PROCEDURE Cur(list: tCali): LONGCARD;

PROCEDURE OutCur(list: tCali): LONGCARD;

(* Fuer 'LONGCARD-Listen' koennen weiterhin die Prozeduren/Funk-
   tionen aus dem Modul 'List' verwendet werden, die nicht
   namensgleich zu den obigen sind.
*)

END Cali.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
