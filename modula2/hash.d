(* ###GrepMarke###
\begin{DefModul}{Hash} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Hash;

(*               Hashing

    ( auch bekannt als 'Streuspeicherung' oder
      'Schluesseltransformation';
      siehe z. B.
          N. Wirth,
          Algorithmen und Datenstrukturen mit Modula-2,
          Teubner Verlag, Stuttgart,
          S. 277 ff.
    )

    Das Modul 'Hash' arbeitet mit dem Modul 'Type' zusammen.
    Es koennen Zeiger auf Objekte gespeichert werden, deren Typ
    in 'Type' definiert worden ist.
*)

IMPORT Sys, SysMath, Func, Type, List, Cali, Frag;
FROM Sys IMPORT tPOINTER;

TYPE tHash; (* Ein Speicher, in dem Daten mit dem Modul 'Hash' ge-
               speichert werden sollen, muss von diesem Typ sein. *)
               
PROCEDURE Use(VAR h: tHash; type: Type.Id; size: LONGCARD);
(* Vor der Benutzung einer Variablen vom Typ 'tFrag' muss diese
   Prozedur einmal fuer diese Variable aufgerufen werden.
   Die Elemente von 'f' sind vom durch angegebenen Typ 'type',
   der vorher mit Hilfe des Moduls 'Type' vereinbart werden
   muss.
   Fuer den Typ 'type' muessen dem Modul 'Type' eine Hash-Funktion
   ( 'tHashProc' ) und eine Vergleichsfunktion ( 'tEquProc' )
   bekannt sein.
   In 'size' ist die Kapazitaet von 'h' gemessen in Anzahl der
   gespeicherten Elemente anzugeben. Falls der Platz nicht ausreichen
   sollte, wird er automatisch in Schritte der Groesse 'size'
   erweitert.
*)

PROCEDURE DontUse(VAR h: tHash);
(* Wenn eine Variable vom Typ 'tFrag' nie wieder benutzt werden soll
   (besonders bei lokalen Variablen am Ende von Prozeduren, da dann
   der zugehoerige Speicherplatz automatisch freigegeben wird) muss
   diese Prozedur fuer diese Variable einmal aufgerufen werden.
*)

PROCEDURE Empty(h: tHash);
(* Alle Elemente in 'h' werden geloescht. *)

PROCEDURE CallDelete(h: tHash; call: BOOLEAN);
(* Es wird festgelegt, ob auf die Elemente von 'tFrag' zusaetzliche
   Referenzen vorhanden sind und somit beim Loeschen der Elemente
   deren Speicherplatz mit durch Aufruf von 'Type.DelI' freigegeben
   werden soll.
   Bei 'call = TRUE' wird 'Type.DelI' aufgerufen, sonst nicht.
   Voreingestellt ist 'HasRef = TRUE' fuer alle neu angelegten
   Variablen vom Typ 'tFrag'.
*)

PROCEDURE Insert(h: tHash; item: tPOINTER);
(* 'item' wird im Hash-Speicher 'h' abgelegt. *)

PROCEDURE Stored(h: tHash; item: tPOINTER;
                 VAR FoundItem: tPOINTER): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls 'item' im Hash-Speicher 'h'
   abgelegt ist. Die Gleichheit wird mit 'Type.EquI' festgestellt.
   Falls das Funktionsergebnis TRUE ist, wird das gefundene Element
   als aktuell markiert und kann anschliessend mit 'DelCur' aus
   dem Hash-Speicher entfernt werden. Es wird in 'FoundItem' zurueck-
   gegeben. *)

       (* DELete CURrent *)
PROCEDURE DelCur(h: tHash);
(* Das aktuelle Element von 'h' (siehe 'Stored') wird geloescht. *)

END Hash.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
