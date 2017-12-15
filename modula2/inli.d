(* ###GrepMarke###
\begin{DefModul}{Inli}
\begin{verbatim}
   ###GrepMarke### *)

DEFINITION MODULE Inli;

(*
   Listen von ganzen Zahlen (Typ LONGINT) unter Verwendung
   des Moduls 'list'
*)

IMPORT Sys, Type, Simptype, List;

TYPE tInli= List.tList;

(* Die folgenden Prozeduren entsprechen in ihrer Bedeutung den
   gleichnamigen im Modul 'List', jedoch angepasst auf den
   Typ LONGINT als Listenelemente. *)

PROCEDURE Use(VAR list: tInli);

PROCEDURE InsertBefore(list: tInli; item: LONGINT);

PROCEDURE InsertBehind(list: tInli; item: LONGINT);

PROCEDURE Insert(list: tInli; item: LONGINT);

PROCEDURE Cur(list: tInli): LONGINT;

PROCEDURE OutCur(list: tInli): LONGINT;

(* Fuer 'LONGINT-Listen' koennen weiterhin die Prozeduren/Funk-
   tionen aus dem Modul 'List' verwendet werden, die nicht
   namensgleich zu den obigen sind.
*)

END Inli.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
