(* ###GrepMarke###
\begin{DefModul}{Data} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Data;

(*   Verwaltung der Testdaten der Diplomarbeit

     Dieses Modul ermoeglicht die Handhabung aller anfallenden
     Testdaten.
     Es wird dabei nicht zwischen im Hauptspeicher stehenden und
     im Hintergrundspeicher (Festplatte) stehenden Daten unter-
     schieden.
     Variablen vom Typ 'Id' (s. u.) koennen bedenkenlos neu
     gesetzt werden. Etwaige Referenzen werden im Modul zusaetz-
     lich verwaltet, so dass auf diese Weise Daten nicht
     verloren gehen.
*)

IMPORT Sys, Str, Type, List, Rema;
FROM Rema IMPORT tMat;

TYPE Id; (* Dies ist der abstrakte Datentyp, mit dessen Hilfe
            die Testdaten bearbeitet werden. Es muss eine
            Variable dieses Typs deklariert werden, die dann
            mit den Prozeduren dieses Moduls bearbeitet
            werden kann. *)

    tAlg = ( laplace, csanky, bgh, berk, pan );
         (* Aufzaehlung der Algorithmen, fuer die Daten 
            verwaltet werden. *)

(**************************)
(* allgemeine Verwaltung: *)

PROCEDURE End;
(* Vor dem Beenden des Programms muss diese Prozedur aufgerufen
   werden, sonst kommt es zu Datenverlusten. *)

PROCEDURE Find(VAR dat: Id; name: ARRAY OF CHAR);
(* Diese Prozedur sucht den zu 'name' gehoerigen Datensatz und
   liefert in 'dat' den zugehoerigen Identifikator zurueck.
   Es wird auf jeden Fall ein Datensatz angelegt. Ob er
   neu angelegt wurde kann mit 'NeverUsed' festgestellt werden. *)

PROCEDURE Del(VAR dat: Id); (* DELete *)
(* Der Datensatz 'dat' wird geloescht. *)

PROCEDURE Flush();
(* Diese Prozedur dient zur Steigerung der Datensicherheit.
   Sie bewirkt, dass alle evtl. im Hauptspeicher vorgenommenen
   Aenderungen an Datensaetzen auf den Hintergrundspeicher
   uebertragen werden. *)

PROCEDURE FlushOnly(dat: Id);
(* ... analog 'Flush', jedoch nur fuer den Datensatz 'dat' *)

PROCEDURE HasChanged(dat: Id);
(* Der Datensatz 'dat' wird als veraendert markiert. Mit Hilfe
   dieser Prozedur kann man das Modul ueber Veraenderungen
   an der Matrix des Datensatzes informieren. *)

PROCEDURE ListNames();
(* Vor der Auflistung der gegenwaertig in Bearbeitung befindlichen
   Datensatze mit Hilfe von 'NextName' muss 'ListNames' zur
   Initialisierung der Auflistung aufgerufen werden. *)

PROCEDURE NextName(VAR name: ARRAY OF CHAR): BOOLEAN;
(* Nachdem mit 'ListNames' die Auflistung der Datensatzname
   initialisiert wurde, kann durch wiederholtes Aufrufen von
   'NextName' eine Liste aller gegenwaertig in Bearbeitung
   befindlichen Datensaetze erstellt werden. In 'name' wird
   jeweils der Name des Datensatzes zurueckgegeben. Das
   Funktionsergebnis ist TRUE, falls ein Datensatz gefunden
   wurde; in diesem Fall wird in 'name' der zugehoerige
   Name zurueckgegeben.
   Die Auflistung erfolgt sortiert.*)


(*******************************)
(* Handhabung der Datensaetze: *)

PROCEDURE Write(dat: Id);
(* Der Datensatz 'dat' wird in die Standardausgabe ausgegeben. *)

PROCEDURE GetMat(dat: Id): tMat;
(* Das Funktionsergebnis ist die Matrix, des Datensatzes 'dat'.
   Sie wird beim Anlegen eines neuen Datensatzes automatisch
   mit angelegt. *)

PROCEDURE SetAlg(dat: Id; alg: tAlg; pdet: LONGREAL;
                 pp, pst: LONGCARD);
(* Im Datensatz 'dat' werden fuer den Algorithmus 'alg' die
   Determinante 'pdet', die Anzahl der Prozessoren 'pp' und
   die Anzahl der Schritte 'pst' gespeichert. *)

PROCEDURE GetAlg(dat: Id; alg: tAlg; VAR pdet: LONGREAL;
                 VAR pp, pst: LONGCARD): BOOLEAN;
(* ... zu 'SetAlg' gehoerige Prozedur zum Lesen aus dem
   Datensatz. Das Funktionsergebnis ist TRUE, falls vorher
   schon mit 'SetAlg' Daten fuer den Algorithmus
   gespeichert wurden. *)
   
END Data.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
