
\begin{DefModul}{Type} 
\begin{verbatim} 


DEFINITION MODULE Type;
            
(* Verwaltung von Elementen selbst definierter Typen fuer die
   Benutzung in Verbindung mit komplexen Datenstrukturen
   (z. B. Listen, Baeume)
   
   Anstatt mit den Elementen der verschiedenen Typen wird mit
   deren Adressen gearbeitet. Dieses Modul dient dazu, den
   Umgang mit diesen Adressen zu uebernehmen.

   Fuer jeden Datentyp muessen Prozeduren vereinbart werden,
   die die Behandlung von Elementen dieses Typs ermoeglichen.
   Die erforderlichen Operationen sind:
       1) Anlegen
       2) Loeschen
       3) auf Gleichheit pruefen
       4) auf Erfuellung einer Ordnungsrelation pruefen
       5) Berechnung einer Hash-Funktion
   Die Angabe der Prozeduren fuer die Operationen ist optional.
*)

IMPORT Sys, Str;
FROM Sys IMPORT tPOINTER;

TYPE Id; (* Von diesem Typ sind Identifikatoren fuer
                 Typen, die mit diesem Modul verwaltet
                 werden. *)

     (* Operationsprozeduren zum Behandeln von Elementen
        selbst definierter Typen: *)

     tNewProc= PROCEDURE(tPOINTER);
         (* 'Anlegen':
            Die entsprechende Prozedur wird zum Initialisieren
            von Listenelementen benutzt. Dies ist z. B. besonders
            nuetzlich bei 'Listen von Listen' um die Tochterliste
            gleich mit zu initialisieren. Das Modul 'Type' ruft
            'Allocate' selbst auf! *)

     tDelProc= PROCEDURE(tPOINTER);
         (* 'Loeschen':
            Die entsprechende Prozedur wird zum Loeschen
            von Listenelementen benutzt. Dies ist z. B. besonders
            nuetzlich bei 'Listen von Listen' um die Tochterliste
            gleich mit zu loeschen. Das Modul 'Type' ruft
            'Deallocate' selbst auf! *)

     tEquProc= PROCEDURE(tPOINTER,tPOINTER): BOOLEAN;
         (* 'Pruefen auf Gleichheit' *)

     tOrdProc= PROCEDURE(tPOINTER,tPOINTER): BOOLEAN;
         (* 'Pruefen auf Erfuellung einer Ordnungsrelation':
            Die Prozedur muss TRUE ergeben, falls die
            angegebenen Elemente die Relation erfuellen *)

     tHashProc= PROCEDURE(tPOINTER, LONGCARD): LONGCARD;

PROCEDURE New(size: LONGCARD):Id;
(* Das Funktionsergebnis ist eine noch nicht benutzte
   Typnummer zur Verwendung fuer alle Prozeduren, an die
   Parameter vom Typ 'Id' uebergeben werden muessen.
   'size' gibt die Groesse der Elemente von dem neuen
   Typ an (mit TSIZE festgestellt). *)

PROCEDURE Copy(type: Id): Id;
(* 'Copy' arbeitet analog zu 'New', jedoch mit dem Unterschied,
   dass der neue Typ eine Kopie des angegebenen Typs ist.
   Abgesehen von einem mit 'SetName' festgelegten Namen werden
   alle Einstellungen uebernommen.
*)

PROCEDURE SetName(type: Id; name: ARRAY OF CHAR);
(* Fuer den angegebenen Typ wird die angegebene Zeichenkette
   als Name vereinbart. Vom Namen werden nur die ersten 16
   Zeichen beruecksichtigt. Bei weniger als 16 Zeichen wird
   der Rest mit Leerstellen aufgefuellt. *)
   
PROCEDURE GetName(type: Id; VAR name: ARRAY OF CHAR);
(* In 'name' wird der mit 'SetName' fuer den Typ vereinbarte
   Name zurueckgegeben. Falls kein Name vereinbart wurde,
   werden Leerstellen zurueckgegeben. Die an 'name'
   zurueckgegebene Zeichenkette wird ggf. abgeschnitten oder
   mit Leerstellen aufgefuellt.
*)

PROCEDURE GetId(name: ARRAY OF CHAR): Id;
(* Das Funktionsergebnis ist der Identifikator des Types,
   fuer den 'name' mit Hilfe von 'SetName' als Name
   vereinbart wurde. Falls der gesuchte Typ nicht bekannt
   ist, wird eine Fehlermeldung ausgegeben. *)

PROCEDURE NoType(): Id;
(* Ergibt eine Konstante zur Benutztung in Verbindung mit
   'Equal'. Diese Konstante wird ggf. von Prozeduren
   zurueckgegeben. Mit Hilfe von 'NoType' und 'Equal'
   kann so auf Nichtvorhandensein eines Typs geprueft
   werden. *)

PROCEDURE Equal(t1,t2: Id): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls 't1' und 't2' denselben
   Typ bezeichnen. *)

PROCEDURE SetNewProc(type: Id; NewProc: tNewProc);
PROCEDURE SetDelProc(type: Id; DelProc: tDelProc);
PROCEDURE SetEquProc(type: Id; EquProc: tEquProc);
PROCEDURE SetOrdProc(type: Id; OrdProc: tOrdProc);
PROCEDURE SetHashProc(type: Id; HashProc: tHashProc);
(* Fuer den angegebenen Typ wird die entsprechende Operations-
   prozedur aufgerufen. *)

PROCEDURE OrdProcDefined(type: Id): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls fuer den angegebenen
   Typ mit 'SetOrdProc' eine Prozedur vereinbart wurde. *)

PROCEDURE NewI(type: Id): tPOINTER; (*NEW Item*)
(* Der Funktionswert ist ein Zeiger auf ein initialisiertes
   Element des angegebenen Typs. Nach 'Allocate' wird 'NewProc'
   fuer dieses Element aufgerufen. *)

PROCEDURE DelI(type: Id; VAR item: tPOINTER); (* DELete Item*)
(* Das Element 'item' des Typs 'type' wird durch Aufruf von
   'DelProc' und 'Deallocate' geloescht. Es duerfen keine
   Referenzen auf das Element mehr vorhanden sein.
   Nach dem Aufruf von 'DelI' gilt 'item = NIL' .
*)

PROCEDURE EquI(type: Id; a,b: tPOINTER): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls die angegebenen
   Elemente des angegebenen Typs gleich sind.
   (benutzt die mit 'SetEquProc' definierte Prozedur)
*)

PROCEDURE OrdI(type: Id; a,b: tPOINTER): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls die angegebenen
   Elemente des angegebenen Typs die Ordnungsrelation
   erfuellen.
   (benutzt die mit 'SetOrdProc' definierte Prozedur)
*)

PROCEDURE HashI(type: Id; a: tPOINTER; max: LONGCARD): LONGCARD;
(* Zurueckgegeben wird das Ergebnis der Hash-Funktion fuer das
   angegebene Element des angegebenen Typs. In 'max' muss die 
   obere Grenze des zulaessigen Funktionswerts angegeben werden.
   Fuer den Funktionswert 'f' muss gelten ' 0 <= f < max'. 
*)

END Type.

\end{verbatim}
\end{DefModul}

