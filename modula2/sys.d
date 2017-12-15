(* ###GrepMarke###
\begin{DefModul}{Sys} 
\begin{verbatim} 
   ###GrepMarke### *)

DEFINITION MODULE Sys;

(*      Systemabhaengige nichtmathematische Prozeduren
        (Atari ST, TOS 2.06, Megamax Modula-2 Compiler V4.2)

    In diesem Modul sind alle nichtmathematischen Prozeduren 
    gesammelt, deren Implementierung von dem System abhaengt, 
    auf dem das Programm uebersetzt wurde.
    
*)

FROM SYSTEM IMPORT ADDRESS;

TYPE File;
     tPOINTER= ADDRESS;
         (* 'tPOINTER' ist zuweisungskompatibel zu allen
            Zeigern *)

PROCEDURE OpenRead(VAR f: File; name: ARRAY OF CHAR);
(* Die Datei 'f' wird unter dem in 'name' angegebenen Namen zum
   Lesen geoeffnet. *)

PROCEDURE OpenWrite(VAR f: File; name: ARRAY OF CHAR);
(* Die Datei 'f' wird unter dem in 'name' angegebenen Namen zum
   Schreiben geoeffnet. Ein bereits existierende Datei wird
   geloescht. *)

PROCEDURE Close(VAR f: File);
(* Die Datei 'f' wird geschlossen. *)
 
PROCEDURE Exist(name: ARRAY OF CHAR): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls eine Datei mit dem in 'name'
   angegebenen Namen existiert. *)

PROCEDURE Delete(name: ARRAY OF CHAR);
(* Die Datei mit dem angegebenen Namen wird geloescht. *)

PROCEDURE EOF(VAR f: File): BOOLEAN;
(* Das Funktionsergebnis ist TRUE, falls das Ende der Datei 'f'
   erreicht ist. *)

PROCEDURE State(VAR f: File): INTEGER;
(* Das Funktionsergebnis ist ein nichtnegativer Wert, falls die 
   letzte Operation auf 'f' erfolgreich war. *)

PROCEDURE WriteLn(VAR f: File);
(* Die Ausgabe der laufenden Zeile in die Datei 'f' wird beendet. *)

PROCEDURE WriteCard(VAR f: File; val: LONGCARD; length: CARDINAL);
(* 'val' wird in die Datei 'f' ausgegeben. Die Ausgabe hat eine
   Laenge von 'length' Zeichen. *)

PROCEDURE WriteReal(VAR f: File; val: LONGREAL; 
                    length, dec: CARDINAL);
(* ... analog 'WriteCard'. Es werden 'dec' Nachkommastellen ausge-
   geben (also  length <= dec+1).  *)

PROCEDURE WriteString(VAR f: File; val: ARRAY OF CHAR);
(* ... analog 'WriteCard' *)

PROCEDURE ReadCard(VAR f: File; VAR val: CARDINAL);
(* Eine Zahl von Typ CARDINAL wird aus 'f' gelesen und in 'val'
   zurueckgegeben. *)

PROCEDURE ReadLCard(VAR f: File; VAR val: LONGCARD);
(* ... analog 'ReadCard', jedoch fuer Typ 'LONGCARD' *)

PROCEDURE ReadReal(VAR f: File; VAR val: LONGREAL);
(* Eine Zahl von Typ LONGREAL wird aus 'f' gelesen und in 'val'
   zurueckgegeben. *)

PROCEDURE ReadString(VAR f: File; VAR val: ARRAY OF CHAR);
(* Aus der Datei 'f' wird eine Zeichenkette gelesen und in 'val'
   zurueckgegeben. Fuehrende Leerstellen werden ignoriert.
   Das Lesen wird am Zeilenende oder bei der ersten Leerstelle
   nach der Zeichenkette abgebrochen. *)

PROCEDURE ReadLine(VAR f: File; VAR val: ARRAY OF CHAR);
(* Die aktuelle Zeile wird bis zum Zeilenende gelesen und in
   'val' zurueckgegeben. Nachfolgende Leseversuche werden
   in der naechsten Zeile fortgesetzt. *)

PROCEDURE ReadLn(VAR f: File);
(* Die aktuelle Zeile wird bis zu ihrem Ende verworfen. Das
   Lesen wird mit der naechsten Zeile fortgesetzt. *)

END Sys.
(* ###GrepMarke###
\end{verbatim}
\end{DefModul}
   ###GrepMarke### *)
