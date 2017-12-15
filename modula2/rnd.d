(* ###GrepMarke###
\begin{DefModul}{Rnd} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Rnd;

(*        Zufallszahlengeneratoren
   
   Mit Hilfe der linearen Kongruenzmethode werden gleich-
   oder normalverteilte Zufallszahlen erzeugt.
   
   Das Modul verwaltet die Erzeugung von Zufallszahlen objekt-
   orientiert. D. h. es koennen Zufallszahlengeneratoren unter-
   schiedlicher Charakterististiken vereinbart und nebenein-
   ander benutzt werden.
*)

IMPORT SysMath, Func, Sys;

TYPE tGen; (* Dieser Typ muss fuer eine Variable vom Typ
             'Zufallsgenerator' benutzt werden. *)

PROCEDURE Use(VAR gen: tGen);
(* Bevor ein Zufallsgenerator benutzt werden soll, muss 'Use'
   fuer die entsprechende Variable aufgerufen werden. *)

PROCEDURE DontUse(VAR gen: tGen);
(* Falls ein Zufallsgenerator nicht mehr benutzt werden soll,
   insbesondere, wenn der aktuelle Parameter fuer 'gen' eine
   lokale Variable ist, muss 'DontUse' fuer diese Variable
   aufgerufen werden. *)

PROCEDURE Start(gen: tGen; num: LONGCARD);
(* 'num' wird als neuer Startwert fuer den Generator 'gen'
   verwendet.
   Fuer alle Generatoren werden Startwerte voreingestellt,
   um neue Folgen von Zufallszahlen zu erhalten sollte jedoch
   zumindest fuer den ersten mit 'Use' angelegten Generator
   ein jeweils anderer Startwert festgelegt werden.
   'num' muss ein Wert im Bereich von 0 bis 199017 sein.
*)

PROCEDURE Range(gen: tGen; bot,top: LONGREAL);
(* F"ur 'gen' wird der Bereich festgelegt, in dem die Zufalls-
   zahlen liegen sollen. Voreingestellt ist 'bot=0' und 'top=1'.
   Durch ganzzahlige Zufallszahlen koennen diese Randwerte
   erreicht werden.
   Die Grenzen duerfen auch nachtraeglich veraendert werden,
   ohne dass dies zu Problemen im Modul fuehrt.
*)

PROCEDURE Int(gen: tGen):LONGINT;
(* Mit Hilfe des Generators 'gen' wird als Funktionswert eine
   Zufallszahl entsprechend der vorher mit den anderen Funktionen
   festgelegten Parameter erzeugt.
   Die Zahlen sind im mit 'Range' festgelegten Bereich gleichmaessig
   verteilt.
*)

PROCEDURE LongReal(gen: tGen): LONGREAL;
(* analog 'Int', jedoch wird eine Zahl mit Nachkommastellen
   erzeugt *)

PROCEDURE St(gen: tGen; num: LONGREAL);
(* Fuer den Generator 'gen' wird 'num' als Standardabweichung
   fuer die Erzeugung von Zufallszahlen mit Hilfe von 'Norm'
   festgelegt. Voreingestellt ist 1.
*)

PROCEDURE Mid(gen: tGen; num: LONGREAL);
(* Fuer den Generator 'gen' wird 'num' als Mittelwert fuer die
   Erzeugung von Zufallszahlen mit Hilfe von 'Norm' festgelegt.
   Voreingestellt ist 0.
*)

PROCEDURE Norm(gen: tGen): LONGREAL;
(* Das Funktionsergebnis ist eine mit Hilfe von 'gen' erzeugte
   Zufallszahl entsprechend der vorher mit 'St' und 'Mid'
   eingestellten Parameter.
*)

END Rnd.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
