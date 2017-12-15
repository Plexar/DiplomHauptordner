
\begin{DefModul}{Mali}
\begin{verbatim}

DEFINITION MODULE Mali; (* MAtrix LIst *)

(*
   Listen von Matrizen (Typ Rema.tMat) unter Verwendung
   des Moduls 'list'
*)

IMPORT Sys, List, Type, Rema;
FROM Rema IMPORT tMat;

TYPE tMali= List.tList;

(* Die folgenden Prozeduren entsprechen in ihrer Bedeutung den
   gleichnamigen im Modul 'List', jedoch angepasst auf den
   Typ 'Rema.tMat' als Listenelemente.
*)

PROCEDURE Use(VAR list: tMali);

PROCEDURE InsertBefore(list: tMali; item: tMat);

PROCEDURE InsertBehind(list: tMali; item: tMat);

PROCEDURE Insert(list: tMali; item: tMat);

PROCEDURE Cur(list: tMali): tMat;

PROCEDURE OutCur(list: tMali): tMat;

(* Fuer 'tMat-Listen' koennen weiterhin die Prozeduren/Funk-
   tionen aus dem Modul 'List' verwendet werden, die nicht
   namensgleich zu den obigen sind.
*)

END Mali.

\end{verbatim}
\end{DefModul}
