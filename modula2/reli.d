(* ###GrepMarke###
\begin{DefModul}{Reli} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Reli; (* REalLIst *)

(* 
   Listen von Fliesskommazahlen (Typ LONGREAL) unter Verwendung
   des Moduls 'list'
*)

IMPORT Sys, Type, Simptype, List;

TYPE tReli= List.tList;

(* Die folgenden Prozeduren entsprechen in ihrer Bedeutung den
   gleichnamigen im Modul 'List', jedoch angepasst auf den 
   Typ LONGREAL als Listenelemente. *)

PROCEDURE Use(VAR list: tReli);

PROCEDURE InsertBefore(list: tReli; item: LONGREAL);

PROCEDURE InsertBehind(list: tReli; item: LONGREAL);

PROCEDURE Insert(list: tReli; item: LONGREAL);

PROCEDURE Cur(list: tReli): LONGREAL;

PROCEDURE OutCur(list: tReli): LONGREAL;

(* Fuer 'LONGREAL-Listen' koennen weiterhin die Prozeduren/Funk-
   tionen aus dem Modul 'List' verwendet werden, die nicht 
   namensgleich zu den obigen sind.
*)

END Reli.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
