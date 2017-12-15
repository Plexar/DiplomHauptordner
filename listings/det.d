
\begin{DefModul}{Det}
\begin{verbatim}

DEFINITION MODULE Det;

(* Verschiedene Algorithmen zur Determinantenberechnung

   In den Algorithmen dieses Moduls werden die Zaehlprozeduren
   des Moduls 'Pram' aufgerufen, so dass nach jeder Berechnung
   einer Determinante festgestellt werden kann, wieviele
   Schritte und Prozessoren eine PRAM zur Abarbeitung des
   Algorithmus benoetigt.
*)

IMPORT Sys, SysMath, Func, Type, List, Frag, Hash, Reli, Mat,
       Pram, Rema, Mali;
FROM Rema IMPORT tMat;

PROCEDURE EineSpalte(mat: tMat): LONGREAL;
(* ... Entwicklungssatz von Laplace (Entwicklung nach einer
       Spalte) *)

PROCEDURE Laplace(mat: tMat): LONGREAL;
(* ... Entwicklungssatz von Laplace (Entwicklung nach k Spalten) *)

PROCEDURE Csanky(mat: tMat): LONGREAL;
(* ... Algorithmus von Csanky *)

PROCEDURE BGH(mat: tMat): LONGREAL;
(* ... Algorithmus von Borodin, von zur Gathen und Hopcroft *)

PROCEDURE Berkowitz(mat: tMat): LONGREAL;
(* ... Algorithmus von Berkowitz *)

PROCEDURE Pan(mat: tMat): LONGREAL;
(* ... Algorithmus von Pan *)

END Det.
\end{verbatim}
\end{DefModul}

