
\begin{DefModul}{Pram}
\begin{verbatim}

DEFINITION MODULE Pram;

(* Laufzeitmessung in PRAM-Schritten und PRAM-Prozessoren

   Dieses Modul erlaubt es, durch Aufruf von Zaehlprozeduren
   festzustellen, wieviele Schritte und Prozessoren eine PRAM
   (Parallel Random Access Machine) zur Abarbeitung des
   jeweiligen Algorithmus benoetigt.
*)

IMPORT List, Cali, Reli;
FROM Reli IMPORT tReli;

CONST MaxBlockName = 32;
          (* Maximale Laenge, die eine an 'ParallelStart', 'NaechsterBlock'
             oder 'ParallelEnde' uebergebene Zeichenkette haben darf *) 
             
PROCEDURE Start();
(* Die internen Zaehler werden fuer eine neue Messung
   initialisiert. *)

PROCEDURE Ende();
(* Es wird 'SchrittEnde' aufgerufen und anschliežend werden
   die Staende des Schritt- und des Prozessorzaehlers
   ausgewertet. *)

PROCEDURE Schritte(wert: LONGCARD);
(* Der Prozessorzaehler wird ausgewertet und auf Null gesetzt.
   Der Schrittzaehler wird um den angegebenen Wert inkremen-
   tiert. *)
   
PROCEDURE Prozessoren(wert: LONGCARD);
(* Der Prozessorzaehler fuer den laufenden Schritt wird um den
   angegebenen Wert inkrementiert.
   Falls z. B. ein Schritt mit einem Prozessor gezaehlt werden
   soll ist
       Pram.Prozessoren(1);
       Pram.Schritte(1);
   aufzurufen. Die umgekehrte Reihenfolge ergibt einen
   Schritt mit 0 Prozessoren!
*)

PROCEDURE ParallelStart(Blockname: ARRAY OF CHAR);
(* Dieser Prozeduraufruf markiert den Anfang einer Kette von
   Anweisungsblocks, die zueinander parallel durchgefuehrt werden.
   Sie werden durch 'NaechsterBlock'-Aufrufe voneinander getrennt.
   
   Die Kette der Anweisungsblocks wird durch 'ParallelEnde' beendet.
   
   Die 'ParallelStart'-'ParallelEnde' Aufrufe koennen geschachtelt werden.

   'Blockname' dient zur Pruefung der korrekten Blockschachtelung.
   An alle zusammgehoerigen 'ParallelStart - NaechsterBlock - ParallelEnde'
   Aufrufe muessen die gleichen Zeichenketten an 'Blockname' uebergeben
   werden. Die Konstante 'MaxBlockName' gibt die maximal erlaubte Laenge
   fuer die an 'Blockname' uebergebene Zeichenkette an.
*)

PROCEDURE NaechsterBlock(Blockname: ARRAY OF CHAR);
(* siehe 'ParallelStart' *)

PROCEDURE ParallelEnde(Blockname: ARRAY OF CHAR);
(* siehe 'ParallelStart' *)

PROCEDURE GezaehlteSchritte(): LONGCARD;
(* Der Funktionswert ist nach einem 'Start'-Aufruf und vor einem
   'Ende'-Aufruf der aktuelle Wert des Schrittzaehlers.
   Nach einem 'Ende'-Aufruf und vor dem naechsten 'Start'-Aufruf
   ist der Funktionswert die Anzahl der Schritte im vorangegangenen
   'Start'-'Ende'-Block. *)
   
PROCEDURE GezaehlteProzessoren(): LONGCARD;
(* analog 'GezaehlteSchritte', jedoch fuer den Prozessorenzaehler *)

PROCEDURE AddList(l: tReli): LONGREAL;
(* Die Elemente in 'l' werden nach der Binaerbaummethode addiert.
   Das Ergebnis wird zurueckgegeben. Der Aufwand wird durch Aufruf
   der Zaehlprozeduren protokolliert.
*)

END Pram.

\end{verbatim}
\end{DefModul}
  
