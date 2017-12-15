(* ###GrepMarke###
\begin{DefModul}{Mat} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Mat;

(*           2-dimensionale Matrizen

   Dieses Modul erlaubt die Verwaltung von Matrizen beliebiger
   2-dimensionaler Matrizen in Verbindung mit dem Modul 'Type'.
   Als Matrizenelemente sind ausschliesslich Zeiger
   (Typ 'Sys.tPOINTER') erlaubt.
*)

IMPORT Sys, SysMath, Func, Type, Frag;
FROM Sys IMPORT tPOINTER;

TYPE tMat;

PROCEDURE Use(VAR mat: tMat; type: Type.Id);
(* Vor der Benutzung einer Variablen vom Typ 'tMat' muss diese
   Prozedur einmal fuer diese Variable aufgerufen werden.
   Die Elemente von 'mat' sind vom durch angegebenen Typ 'type',
   der vorher mit Hilfe des Moduls 'Type' vereinbart werden
   muss.
*)

PROCEDURE DontUse(VAR mat: tMat);
(* Wenn eine Variable vom Typ 'tMat' nie wieder benutzt werden soll
   (besonders bei lokalen Variablen am Ende von Prozeduren, da dann
   der zugehoerige Speicherplatz automatisch freigegeben wird) muss
   diese Prozedur fuer diese Variable einmal aufgerufen werden.
*)

PROCEDURE SetSize(mat: tMat; row, col: LONGCARD);
(* Durch den Aufruf von 'SetSize' wird die Matrix 'mat' geloescht
   und ihre Groesse auf 'row' Zeilen und 'col' Spalten beschraenkt
   (Zaehlung der Zeilen und Spalten beginnt bei 1).
   Ausserdem wird der Zugriff auf die Listenelemente beschleunigt.
*)

PROCEDURE Set(mat: tMat; row, col: LONGCARD; item: tPOINTER);
(* 'item' wird in 'mat' in Zeile 'row' und Spalte 'col' gespeichert.
   Ein evtl. bereits vorhandenes Element wird geloescht.
*)

PROCEDURE Elem(mat: tMat; row, col: LONGCARD): tPOINTER;
(* Funktionsergebnis ist das Element von 'mat' in Zeile 'row' und
   Spalte 'col'.
*)

PROCEDURE Rows(mat: tMat): LONGCARD;
(* Falls vorher 'Set' fuer 'mat' aufgerufen wurde, ist das Funktions-
   ergebnis die dort festgelegte Anzahl von Zeilen von 'mat'.
   Andernfalls ist das Funktionsergebnis der hoechste Zeilenindex,
   auf den bisher seit dem letzten 'Use'- oder 'Empty'-Aufruf
   mit 'Set' zugegriffen worden ist.
*)

PROCEDURE Columns(mat: tMat): LONGCARD;
(* ... analog 'Rows', jedoch fuer den Spaltenindex *)

PROCEDURE Empty(mat: tMat);
(* Alle Feldelemente von 'mat' werden geloescht (mit 'Type.DelI'). *)

END Mat.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
