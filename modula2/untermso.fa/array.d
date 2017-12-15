(* Dieses Modul ist fertig implementiert, jedoch nicht getestet. *)

DEFINITION MODULE Array;

(*     Felder veraenderlicher Groesse

   Dieses Modul erlaubt es, Felder unbestimmter veraenderlicher
   Groesse zu verwalten. Als Feldelemente sind nur Zeiger
   ( Typ 'Sys.tPOINTER' ) erlaubt. Das Modul arbeitet bei der
   Verwaltung der Feldelemente mit dem Modul 'Type' zusammen.
*)

IMPORT Sys, Func, Type, Frag, List;
FROM Sys IMPORT tPOINTER;

TYPE tArray;

PROCEDURE Use(VAR a: tArray; type: Type.Id);
(* Vor der Benutzung einer Variablen vom Typ 'tList' muss diese
   Prozedur einmal fuer diese Variable aufgerufen werden.
   Nach der Grundinitialisierung wird automatsch 'Init(list)'
   aufgerufen.
   Die Elemente in 'list' sind vom durch angegebenen Typ 'type',
   der vorher mit Hilfe des Moduls 'Type' vereinbart werden
   muss.
*)

PROCEDURE DontUse(VAR a: tArray);
(* Wenn eine Variable vom Typ 'tList' nie wieder benutzt werden soll
   (besonders bei lokalen Variablen am Ende von Prozeduren, da dann
   der zugehoerige Speicherplatz automatisch freigegeben wird) muss
   diese Prozedur fuer diese Variable einmal aufgerufen werden.
*)

PROCEDURE PredictRange(a: tArray; low, high: LONGCARD);
(* Neu benutzte Feldelemente werden automatisch angelegt. Jedoch ist
   es bei vorher bekanntem Indexbereich effizienter, dem Modul
   'Array' mit Hilfe von 'PredictRange' den Indexbereich mitzuteilen.
   'low' gibt die untere Indexgrenze und 'high' die obere. Es ist
   auch weiterhin moeglich Feldelemente jenseits dieser Grenzen
   anzusprechen.
*)

PROCEDURE Elem(a: tArray; index: LONGCARD): tPOINTER;
(* Funktionsergebnis ist das Element von 'a' mit dem angegebenen
   Index.
*)

PROCEDURE OutItem(a: tArray; index: LONGCARD): tPOINTER;
(* 'OutItem' arbeitet analog zu 'Item', jedoch mit dem Unterschied,
   das die Eintragung als Feldelement geloescht wird.
   Falls in 'a' unter dem gleichen Index ein neues Element gespei-
   chert wird, fuehrt das somit nicht dazu, dass der Speicherbereich
   fuer das Vorgaengerelement freigegeben wird.
*)

PROCEDURE Set(a: tArray; index: LONGCARD; item: tPOINTER);
(* Dem Element von 'a' mit dem angegebenen Index wird 'item' als
   neuer Inhalt zugewiesen. Ein bereits unter diesem Index gespei-
   chertes Feldelement wird geloescht.
*)

PROCEDURE Empty(a: tArray);
(* Alle Elemente von 'a' werden geloescht. *)

END Array.

