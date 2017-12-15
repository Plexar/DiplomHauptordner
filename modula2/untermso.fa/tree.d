
DEFINITION MODULE Tree;

(*
      Allgemeine Verwaltung von n-aeren Baeumen

   Um das Modul allgemein zu halten, werden als Knoten nur
   Adressen (Typ ADDRESS) verwaltet, die ggf. vom 
   benutzenden Modul selbst zu interpretieren sind.
   Mit Hilfe des Moduls 'Type' muss ein Elementtyp vereinbart
   worden sein, bevor dieser mit dem Modul 'tree' in 
   Baeumen verwaltet werden kann.
   
   Im Baum gibt es immer einen (ggf. undefinierten) aktuellen
   Knoten.
*)

FROM SYSTEM IMPORT ADDRESS;
IMPORT Type;

(* Konstanten zum lesbareren Aufbau von binaeren Baeumen *)
CONST binary= 2; (* Anzahl moeglicher Nachfolger *)
      left= 1;   (* Nummer des linken Nachfolgers *)
      right= 2;  (* Nummer des rechten Nachfolgers *)

TYPE tTree;

(**************************)
(* Allgemeine Verwaltung: *)

PROCEDURE Use(VAR tree: tTree; successors: CARDINAL; type: Type.Id);
(* Bevor ein Baum das erste Mal benutzt werden soll, muss diese
   Prozedur aufgerufen werden, um die Verwaltung des Baumes zu
   initialisieren und die Anzahl der Nachfolger eines Knotens sowie
   den Knotentyp festzulegen. *)

PROCEDURE DontUse(VAR tree: tTree);
(* Wenn ein Baum nie wieder benutzt werden soll, muss diese
   Prozedur aufgerufen werden (insbesondere am Ende von Prozeduren 
   um den Speicherplatz wieder freizugeben, der zur Verwaltung 
   des Baumes belegt wurde. *)

PROCEDURE Init(tree: tTree; successors: CARDINAL; type: Type.Id); 
(* Der Baum wird geleert und die Anzahl der Nachfolger sowie 
   der Elementtyp wird neu gesetzt. *)

PROCEDURE Empty(tree: tTree);
(* Alle Knoten werden aus dem Baum entfernt. *)

PROCEDURE Size(tree: tTree): CARDINAL;
(* Der Funktionswert ist die Anzahl der Knoten im Baum. *)

(***********************************************************)
(* Prozeduren, die sich auf den aktuellen Knoten beziehen: *)

PROCEDURE Cur(tree: tTree): ADDRESS; (* CURrent *)
(* Der Funktionswert ist der aktuelle Knoten. *)

PROCEDURE ToRoot(tree: tTree);
(* Im angegebenen Baum wird die Wurzel zum aktuellen Knoten. *)

PROCEDURE Down(tree: tTree; succ: CARDINAL);
(* Im angegebenen Baum wird der Nachfolger, den 'succ' angibt,
   zum aktuellen Knoten. *)

PROCEDURE Up(tree: tTree);
(* Im angegebenen Baum wird der Vorgaenger des aktuellen 
   Knotens zum aktuellen Knoten. *)

PROCEDURE AtRoot(tree: tTree): BOOLEAN;
(* Der Funktionswert ist TRUE, falls der aktuelle Knoten die
   Wurzel ist. *)

PROCEDURE AtLeaf(tree: tTree): BOOLEAN;
(* Der Funktionswert ist FALSE, falls der aktuelle Knoten ein
   Blatt ist. *)

       (* SUCCessor is PRESent *)
PROCEDURE SuccPres(tree: tTree; succ: CARDINAL): BOOLEAN;
(* Der Funktionswert ist TRUE, falls der aktuelle Knoten im
   Baum 'tree' einen Nachfolger mit der Nummer 'succ' 
   besitzt. *)

PROCEDURE GetPos(tree: tTree): ADDRESS; (* GET POSition *)
(* Als Funktionswert wird die Position des aktuellen 
   Knotens zurueckgegeben. Die Verwendung dieses Wertes
   ist nur in Verbindung mit der Prozedur 'SetPos' 
   sinnvoll. *)

PROCEDURE SetPos(tree: tTree; pos: ADDRESS); (* SET POSition *)
(* Die Position des aktuellen Knotens wird auf 'pos' gesetzt.
   'pos' muss vorher mit 'GetPos' festgestellt worden sein. *)

PROCEDURE NewLeaf(tree: tTree; item: ADDRESS; num: CARDINAL);
(* Das angegebenen Element wird dem aktuellen Knoten als 
   Nachfolger Nummer 'num' angehaengt. Der Platz muss noch
   frei sein, andernfalls erfolgt eine Fehlermeldung. Der
   neue Knoten wird automatisch zum Aktuellen. *)

PROCEDURE DelCur(tree: tTree);
(* Der aktuelle Knoten wird geloescht. Er muss ein Blatt sein! 
   Der aktuelle Knoten ist danach undefiniert. *)

PROCEDURE OutCur(tree: tTree): ADDRESS;
(* Falls der aktuelle Knoten ein Blatt ist, wird er aus dem
   Baum entfernt und als Funktionswert zurueckgegeben. 
   Danach ist der aktuelle Knoten undefiniert.
   Falls der aktuelle Knoten kein Blatt ist, erfolgt eine
   Fehlermeldung. 
*)
   
PROCEDURE UnHook(tree, unhooked: tTree);
(* 'unhooked' muss ein initialisierter leerer Baum mit dem 
   gleichen Elementtyp und der gleichen Nachfolgeranzahl sein
   wie 'tree'. Der Teilbaum von 'tree', dessen Wurzel der
   aktuelle Knoten (dieser muss also kein Blatt sein) ist, 
   wird aus 'tree' entfernt und nach
   'unhooked' verschoben. *)

PROCEDURE Hook(tree, ToHook: tTree; succ: CARDINAL);
(* 'tree' und 'ToHook' muessen die gleichen Elementtypen
   und Nachfolgeranzahlen besitzen. Der Baum 'ToHook' wird
   dem aktuellen Element von 'tree' als Nachfolger Nummer 
   'succ' angehaengt. Der Platz muss noch frei sein, sonst
   erfolgt eine Fehlermeldung. *)

END Tree.

