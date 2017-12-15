
\begin{DefModul}{Frag}
\begin{verbatim}
  

DEFINITION MODULE Frag; (* array FRAGments *)

(*       Eindimensionale Felder beliebiger Laenge

   Mit diesem Modul koennen Felder veraenderlicher Laenge
   verwaltet werden.
   
*)

IMPORT Sys, Func, Type;
FROM Sys IMPORT tPOINTER;

TYPE tFrag;

PROCEDURE Use(VAR f: tFrag; type: Type.Id; low, high: LONGCARD);
(* Vor der Benutzung einer Variablen vom Typ 'tFrag' muss diese
   Prozedur einmal fuer diese Variable aufgerufen werden.
   Die Elemente von 'f' sind vom durch angegebenen Typ 'type',
   der vorher mit Hilfe des Moduls 'Type' vereinbart werden
   muss.
   Die weiteren Parameter entsprechen denen von 'SetRange' und
   'SetType'.
*)

PROCEDURE DontUse(VAR f: tFrag);
(* Wenn eine Variable vom Typ 'tFrag' nie wieder benutzt werden soll
   (besonders bei lokalen Variablen am Ende von Prozeduren, da dann
   der zugehoerige Speicherplatz automatisch freigegeben wird) muss
   diese Prozedur fuer diese Variable einmal aufgerufen werden.
*)

PROCEDURE SetRange(f: tFrag; low, high: LONGCARD);
(* Fuer 'f' wird der Indexbereich neue festgelegt. 'low' bestimmt
   die untere neue Grenze und 'high' die obere. Alle Elemente von
   'f', die aus dem neuen Indexbereich herausfallen werden auto-
   matisch geloescht. (siehe auch 'AddRef')
*)

PROCEDURE SetType(f: tFrag; type: Type.Id);
(* Der Typ der in 'f' zu speichernden Elemente wird festgesetzt.
   'f' wird geloescht.
*)
       (* ADDition REFerences *)
PROCEDURE AddRef(f: tFrag; HasRef: BOOLEAN);
(* Es wird festgelegt, ob auf die Elemente von 'tFrag' zusaetzliche
   Referenzen vorhanden sind und somit beim Loeschen der Elemente
   deren Speicherplatz mit durch Aufruf von 'Type.DelI' freigegeben
   werden soll.
   Bei 'HasRef = FALSE' wird 'Type.DelI' aufgerufen, sonst nicht.
   Voreingestellt ist 'HasRef = FALSE' fuer alle neu angelegten
   Variablen vom Typ 'tFrag'.
*)

PROCEDURE Empty(f: tFrag);
(* Alle Elemente in 'f' werden geloescht. *)

PROCEDURE GetLow(f: tFrag): LONGCARD;
(* Funktionsergebnis ist die untere Indexgrenze von 'f'. *)

PROCEDURE GetHigh(f: tFrag): LONGCARD;
(* Funktionsergebnis ist die obere Indexgrenze von 'f'. *)

PROCEDURE GetType(f: tFrag): Type.Id;
(* Funktionsergebnis ist der Typ der Elemente von 'f'. *)

PROCEDURE GetItem(f: tFrag; index: LONGCARD): tPOINTER;
(* Das Funktionsergebnis ist das im Feld 'f' unter dem angegebenen
   Index gespeicherte Feldelement. *)

PROCEDURE SetItem(f: tFrag; index: LONGCARD; item: tPOINTER);
(* 'SetItem' ist die zu 'GetItem' gehoerige Prozedur zum Setzen
   des Feldinhalts. Ein vorhandenes Feldelement wird automatisch
   geloescht. (siehe auch 'AddRef')
*)

PROCEDURE Transfer(from, to: tFrag);
(* Alle Feldelement von 'from' werden nach 'to' uebertragen. Dazu muss
   der Indexbereich von 'from' innerhalb des Bereiches von 'to'
   liegen. In 'to' bereits vorhandene Feldelemente werden automatisch
   geloescht. (siehe auch 'AddRef')
*)

END Frag.

\end{verbatim}
\end{DefModul}
  
