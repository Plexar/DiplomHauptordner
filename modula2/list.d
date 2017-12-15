(* ###GrepMarke###
\begin{DefModul}{List} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE List;

(*         Lineare Listen
   
   Zur Handhabung einzelner Elemente einer Liste wird
   das Modul 'Types' verwendet. D. h. fuer jeden Art
   von Elementen, die in einer Liste verwaltet werden
   sollen muss mit Hilfe von 'Types' ein entsprechender
   Type vereinbart werden.
   
   Jede Liste kann nur Elemente eines Datentyps enthalten.

   Fuer jeden Datentyp muessen Prozeduren vereinbart werden,
   die die Behandlung von Elementen dieses Typs ermoeglichen.
   Die erforderlichen Operationen sind:
       Anlegen, Loeschen, auf Gleichheit pruefen, auf Erfuellung
       einer Ordnungsrelation pruefen
   Die Angabe der Prozeduren fuer die Operationen ist optional,
   in Abhaengigkeit davon, wie weit die Moeglichkeiten des Moduls
   genutzt werden.

   Der Zugriff auf Listenelemente erfolgt grundsaetzlich ueber die
   zugehoerigen Adressen.

   In der Liste gibt es immer ein (ggf. undefiniertes) 'aktuelles
   Listenelement', auf das in verschiedenen Prozeduren Bezug genommen
   wird.
   
   Im Modul 'Type' werden Listen unter dem Typnamen 'List' gefuehrt.
   
   Listen von Listen koennen durch
       List.Use(ListListVar, Type.GetId("List"));
   vereinbart werden. Alle Listenprozeduren koennen unveraendert
   benutzt werden. Zu beachten ist, dass beim Einfuegen oder
   Entfernen keine Kopien von Listen angelegt werden.
   
   Listen von Matrizen (Modul 'Mat') koennen durch
       List.Use(MatListVar, Type.GetId("Matrix"));
   vereinbart werden. Es gelten alle Bemerkungen analog zu
   'Listen von Listen'.
*)

IMPORT Sys, Str, Type;
FROM Sys IMPORT tPOINTER;

TYPE tList; (* Dieser Typ ist fuer Variablen zu benutzen, die
               Listen darstellen sollen. *)
     tPos;  (* Dieser Typ ist in Verbindung mit den Prozeduren
               'GetPos' und 'SetPos' zu benutzen. *)

(*************************************)
(* allgemeine Verwaltungsprozeduren: *)

PROCEDURE Use(VAR list: tList; type: Type.Id);
(* Vor der Benutzung einer Variablen vom Typ 'tList' muss diese
   Prozedur einmal fuer diese Variable aufgerufen werden.
   Die Elemente in 'list' sind vom durch angegebenen Typ 'type',
   der vorher mit Hilfe des Moduls 'Type' vereinbart werden
   muss.
*)

PROCEDURE DontUse(VAR list: tList);
(* Wenn eine Variable vom Typ 'tList' nie wieder benutzt werden soll
   (besonders bei lokalen Variablen am Ende von Prozeduren, da dann
   der zugehoerige Speicherplatz automatisch freigegeben wird) muss
   diese Prozedur fuer diese Variable einmal aufgerufen werden.
*)

PROCEDURE Empty(list: tList);
(* Die angegebene Liste wird geleert. *)

(*****************************************************************)
(* Prozeduren, die sich auf das aktuelle Listenelement beziehen: *)

PROCEDURE DelCur(list: tList); (* DELete CURrent *)
(* Falls mit 'AddRef' vereinbart wurde, dass weitere Referenzen
   auf Elemente in der angegebenen Liste existieren, wird
   das aktuelle Listenelement mit Hilfe von 'OutCur' aus
   der Liste entfernt, ansonsten durch 'Type.DelI'.
   
   Es wird das Element zum 'aktuellen Listenelement', welches
   auf das geloeschte folgt. Falls kein weiteres Element folgt,
   wird das vorhergehende Element zum aktuellen.
*)

PROCEDURE InsertBefore(list: tList; item: tPOINTER);
(* 'item' wird in 'list' vor dem 'aktuellen Element'
   eingefuegt. Falls das 'aktuelle Element' undefiniert ist, wird
   'item' am Anfang eingefuegt. 'item' wird zum neuen 'aktuellen
   Element'.
*)

PROCEDURE InsertBehind(list: tList; item: tPOINTER);
(* 'item' wird in 'list' hinter dem 'aktuellen Element'
   eingefuegt. Falls das 'aktuelle Element' undefiniert ist, wird
   'item' am Ende eingefuegt. 'item' wird zum neuen 'aktuellen
   Element'.
*)

PROCEDURE Insert(list: tList; item: tPOINTER);
(* 'item' wird in 'list' eingefuegt. Die Stelle, an der die
   Einfuegung vorgenommen wird, ist undefiniert. 
*)

PROCEDURE First(list: tList);
(* In 'list' wird das erste Listenelement zum aktuellen. Falls
   die Liste keine Elemente enthaelt, ist nach diesem Aufruf
   das 'aktuelle Listenelement' undefiniert.
*)

PROCEDURE Last(list: tList);
(* In 'list' wird das letzte Listenelement zum aktuellen. Falls
   die Liste keine Elemente enthaelt, ist nach diesem Aufruf
   das 'aktuelle Listenelement' undefiniert.
*)

PROCEDURE Prev(list: tList); (* PREVious *)
(* Das vor dem aktuellen Listenelement stehende Element wird zum
   neuen aktuellen.
   Falls vor dem Aktuellen kein Element existiert bleibt das
   erste Element das Aktuelle.
   Falls das aktuelle Listenelement undefiniert war, bleibt es
   undefiniert.
   Der Funktionswert ist TRUE, falls das aktuelle Listenelement
   definiert war und vor ihm ein weiteres existierte.
*)

PROCEDURE AtFirst(list: tList): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls das erste
   Listenelement das Aktuelle ist. In allen anderen
   Faellen (auch wenn das aktuelle Element undefiniert ist)
   lautet das Ergebnis FALSE.
*)

PROCEDURE AtLast(list: tList): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls das letzte
   Listenelement das Aktuelle ist. In allen anderen
   Faellen (auch wenn das aktuelle Element undefiniert ist)
   lautet das Ergebnis FALSE.
*)

PROCEDURE Next(list: tList);
(* Das hinter dem aktuellen Listenelement stehende Element wird zum
   neuen aktuellen.
   Falls hinter dem Aktuellen kein Element existiert, bleibt das
   letzte Element das Aktuelle.
   Falls das aktuelle Listenelement undefiniert war, bleibt es
   undefiniert.
   Der Funktionswert ist TRUE, falls das aktuelle Listenelement
   definiert war und hinter ihm ein weiteres existierte.
*)

PROCEDURE MoreData(list: tList): BOOLEAN;
(* Nach dem Aufruf der Prozeduren 'First', 'Last', 'Next'
   und 'Prev' kann mit dieser Funktion festgestellt werden,
   ob die Prozeduren das aktuelle Listenelement neu definiert
   haben. Das Funktionsergebnis ist TRUE, falls dies der Fall
   ist, sonst FALSE.
   Durch diese Funktion kann eine Liste nicht nur mit 'Scan',
   sondern auch mit
       List.First(mylist);
       WHILE List.MoreData(mylist) DO
           ...
           List.Next(mylist)
       END
   durchlaufen werden.
   Die Verwendung von 'MoreData' in Verbindung mit Prozeduren
   ausser den oben genannten ist nicht sinnvoll.
*)

PROCEDURE Cur(list: tList): tPOINTER; (* CURrent *)
(* Das Funktionsergebnis ist das aktuelle Listenelement. *)

PROCEDURE GetPos(list: tList): tPos; (* GET POSition *)
(* Das Funktionsergebnis ist die Position des aktuellen
   Listenelements innerhalb der Liste. Dies ist KEINE
   Ordnungszahl fuer die Listenposition. Aus dem Wert kann
   keinerlei weitergehende Information entnommen werden.
   Er kann nur in Verbindung mit 'SetPos' weiter verwendet
   werden.
   Auf diese Weise ist es moeglich, auf bestimmte Listenelement
   sofort zuzugreifen, ohne sie erst die Liste durchsuchen zu
   muessen. *)

PROCEDURE SetPos(list: tList; pos: tPos); (* SET POSition *)
(* Diese Prozedur ist das Gegenstueck zu 'GetPos' (s. o.).
   Das Listenelement an der angegebenen Position wird zum neuen
   aktuellen Listenelement. Fuer 'pos' duerfen als Werte NUR
   Funktionswerte von 'GetPos' verwendet werden. Insbesondere
   darf bei 'SetPos' keine andere Liste als bei 'GetPos' angegeben
   werden. Dies wird nicht ueberprueft und fuehrt zu unvor-
   hersehbaren Reaktionen. *)

PROCEDURE OutCur(list: tList): tPOINTER; (* OUT CURrent *)
(* Das aktuelle Listenelement wird aus der Liste entfernt, jedoch
   nicht geloescht. Es wird als Funktionswert zurueckgegeben.
   Das auf dieses Element folgende wird zum neuen aktuellen Element.
   Falls kein weiteres Element existiert, wird das vorhergehende
   Element zum aktuellen.
*)

(*************)
(* Diverses: *)

TYPE tScanProc= PROCEDURE(tPOINTER);

PROCEDURE Scan(list: tList; proc: tScanProc);
(* 'proc' wird mit jedem Element in 'list' als Parameter
   (beginnend beim ersten Element) genau einmal aufgerufen.
   Anschliessend ist das erste Listenelement das Aktuelle.
*)

PROCEDURE AddRef(list: tList); (* ADDitional REFerences *)
(* Nachdem diese Prozedur aufgerufen wurde, erfolgt das Loeschen
   von Elementen aus dieser Liste nur durch Aufloesung von
   Referenzen und NICHT MEHR durch den Aufruf von 'Types.DelI'.
*)

PROCEDURE GetType(list: tList): Type.Id;
(* Das Funktionsergebnis ist der Typ der Elemente in der
   angegebenen Liste.
*)

PROCEDURE Count(list: tList): LONGCARD;
(* Das Ergebnis dieser Funktion ist die Anzahl der Elemente in
   'list'.
*)

PROCEDURE CheckStructure(list: tList);
(* Diese Prozedur dient zur Fehlersuche. Sie prueft die interne
   Verwaltungsstruktur von 'list' und gibt Meldungen in die
   Standardausgabe aus, falls sie Strukturfehler entdeckt. *)

END List.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)  
