
\begin{DefModul}{Rama}
\begin{verbatim}


DEFINITION MODULE Rema;  (* REal MAtrix *)

(*       2-dimensionale LONGREAL-Matrizen

    Im Modul 'Type' werden Matrizen unter dem Typnamen
    'Matrix' gefuehrt.
    (d. h.
        Type.GetId("Matrix");
     ergibt die zugehoerige Typnummer)

    Verbesserungsmoeglichkeiten:
    - Angabe der gewuenschten Eigenwerte fuer 'Randomize'
    - Ermoeglichung nichtganzzahliger Eigenwerte
    - Abfrage der Parameter fuer 'Randomize'
      (bisher nur Setzen moeglich)
    - Fehlermeldungen bei widerspruechlichen Parametern
      fuer 'Randomize'
    - Erzeugung nichtdiagonalisierbarer Matrizen durch 'Randomize'
    - 'Randomize' auch fuer nichtquadratische Matrizen
    - Angabe eines Intervalls, indem die Elemente der durch
      'Randomize' erzeugten Matrizen liegen
    - automatische Erkennung der Version der Datenstruktur
      durch 'Write', 'WriteF', 'Read' und 'ReadF'
*)
    
IMPORT Sys, SysMath, Func, Rnd, Type, Frag, List, Simptype,
       Inli, Cali, Reli, Mat, Pram;
FROM Sys IMPORT File;

TYPE tMat;
         (* Dieser Typ ist fuer Variablen vom Typ 'Matrix'
            zu benutzen. *)

CONST MaxIoRow = 6; (* gibt an, wieviele Matrizenelemente von
                       'WriteReal' maximal in eine Zeile
                       ausgegeben werden *)

PROCEDURE Use(VAR mat: tMat; row, col: LONGCARD);
(* Vor der Benutzung einer Variablen vom Typ 'tMat' muss diese
   Prozedur einmal fuer diese Variable aufgerufen
   werden.
   Eine Ausnahme hierzu bilden Variablen, denen eine Matrix mit
   Hilfe von 'Copy' oder 'CreateMult' zugewiesen wird. Diese
   Variablen duerfen nicht durch 'Use' initialisiert worden
   sein.
   Nach der Grundinitialisierung wird automatisch 'Init(mat,row,col)'
   aufgerufen.
*)

PROCEDURE DontUse(mat: tMat);
(* Wenn eine Variable vom Typ 'tMat' nie wieder benutzt werden soll
   (besonders bei lokalen Variablen am Ende von Prozeduren, da dann der
   zugehoerige Speicherplatz automatisch freigegeben wird) muss diese
   Prozedur fuer diese Variable einmal aufgerufen werden.
*)

PROCEDURE Empty(mat: tMat);
(* Alle Elemente der angegebenen Matrix werden mit 0 belegt. *)
   
PROCEDURE Unit(mat: tMat);
(* Die Elemente der Hauptdiagonalen von 'mat' werden auf 1
   gesetzt, alle anderen Elemente auf 0 *)

PROCEDURE Assign(mat1, mat2: tMat);
(* Diese Prozedur weist die Elemente von Matrix 'mat1' den
   Elementen von Matrix 'mat2' zu. Dazu muessen die Matrizen die
   gleich Anzahl von Zeilen und Spalten besitzen.
*)

PROCEDURE Copy(mat1: tMat): tMat;
(* Es wird eine Kopie der Matrix 'mat1' angelegt und als Funktions-
   wert zurueckgegeben. Die Variable, der dieser Funktionswert
   zugewiesen wird, darf vorher nicht mit 'Use' initialisiert
   worden sein.
*)

PROCEDURE Elem(mat: tMat; row, col: LONGCARD): LONGREAL;
(* Diese Funktion ergibt den Wert des Elementes an der angegebenen
   Position von Matrix 'mat'.
*)

PROCEDURE Set(mat: tMat; row,col: LONGCARD; val: LONGREAL);
(* Diese Prozedur belegt das Element an der angegebenen Position
   der Matrix 'mat' mit dem in 'val' angegebenen Wert.
*)

PROCEDURE Rows(mat: tMat): LONGCARD;
(* Diese Funktion ergibt die Anzahl der Zeilen der
   Matrix 'mat'.
*)

PROCEDURE Columns(mat: tMat): LONGCARD;
(* Diese Funktion liefert die Anzahl der Spalten der
   Matrix 'mat'.
*)

PROCEDURE SetSize(mat: tMat; r,c: LONGCARD);
(* Fuer die Matrix 'mat' wird festgelegt, dass sie 'r' Zeilen
   und 'c' Spalten besitzt. Durch den Aufruf dieser Prozedur
   werden alle evtl. in 'mat' gespeicherten Daten geloescht.
*)

PROCEDURE SetReal(mat: tMat; real: BOOLEAN);
(* Es wird festgelegt, ob die durch 'Randomize' zu erzeugende
   Matrix 'mat' Elemente mit Nachkommastellen besitzen darf.
   'real' gibt an, ob Nachkommastellen erlaubt sind:
       TRUE :  erlaubt
       FALSE:  verboten
*)

PROCEDURE SetRank(mat: tMat; rank: LONGCARD);
(* Fuer 'mat' wird der gewuenschte Rang 'rank' zur Benutzung durch
   'Randomize' festgelegt.
*)

PROCEDURE SetMultiplicity(mat: tMat; mult: LONGCARD);
(* Fuer 'mat' wird zur Benutzung durch 'Randomize' festgelegt, dass
   ein Eigenwert die Vielfachheit 'mult' besitzt. Falls mit
   'SetMultiplicity keine Vielfachheiten festgesetzt werden, wird
   fuer jeden Eigenwert (ungleich 0) die Vielfachheit 1 angenommen.
*)

PROCEDURE Randomize(mat: tMat);
(* 'mat' wird anhand der mit 'SetIntervall', 'SetRank' und
   'SetMultiplicity' festgesetzten Parameter mit zufaelligen Werten
   belegt. Die Vielfachheiten (mit 'SetMultiplicity' festgelegt)
   werden nur beachtet, soweit es Matrixgroesse und Rang (mit
   'SetRank' festgelegt) zulassen.
   'mat' muss eine quadratische Matrix sein.
*)

PROCEDURE Det(mat: tMat): LONGREAL;
(* Fuer eine durch 'Randomize' generierte Matrix kann mit dieser
   Funktion ihre Determinante festgestellt werden.
   ('Abfallprodukt' des Generierungsvorganges)
*)
 
PROCEDURE Write(mat: tMat);
(* Diese Prozedur schreibt den Inhalt der Matrix 'mat' in den
   Standardausgabekanal.
*)

PROCEDURE WriteF(VAR f: File; mat: tMat);
(* ... analog 'Write', jedoch erfolgt die Ausgabe in die Datei 'f' *)

PROCEDURE Read(mat: tMat);
(* Diese Prozedur liest die Werte fuer die Elemente der Matrix
   'mat' aus dem Standard-Eingabekanal. Mit 'Write' ausgegebene
   Matrizen koennen mit dieser Prozedur wieder eingelesen werden.
   Die Anzahlen der Zeilen und Spalten der einzulesenden Matrix
   duerfen die entsprechenden Werte von 'mat' nicht uebersteigen.
   Evtl. ueberzaehlige Zeilen und Spalten von 'mat' werden mit
   Nullen belegt.
*)

PROCEDURE ReadF(VAR f: File; mat: tMat);
(* ... analog 'Read', jedoch erfolgt die Ausgabe in die Datei 'f' *)

PROCEDURE Add(mat1, mat2, res: tMat);
(* Die Matrizen 'mat1' und 'mat2' werden addiert. Das Ergebnis
   wird in 'res' gespeichert. 'mat1' und 'mat2' muessen die
   gleiche Groesse besitzen. 'mat1', 'mat2' und 'res' koennen
   dieselben Matrizen sein.
   Es werden Zaehlprozeduren des Moduls 'Pram' zur Protokollierung
   des Berechnungsaufwandes aufgerufen.
*)

PROCEDURE Sub(mat1, mat2, res: tMat);
(* Matrix 'mat2' wird von 'mat1' elementweise subtrahiert. Alles
   weitere ist gleich zu 'Add'.
*)

PROCEDURE Mult(mat1, mat2, res: tMat);
(* Die 'a*b'-Matrix 'mat1' wird mit der 'b*c'-Matrix 'mat2'
   multipliziert. Das Ergebnis wird in der 'a*c'-Matrix 'res'
   gespeichert. Die Zeilenanzahl 'a' und die Spaltenanzahl 'c'
   koennen zwischen 1 und 'ArrayMax' liegen. 'mat1', 'mat2' und
   'res' koennen dieselben Matrizen sein.
   Es werden Zaehlprozeduren des Moduls 'Pram' zur Protokollierung
   des Berechnungsaufwandes aufgerufen.
*)

PROCEDURE CreateMult(mat1, mat2: tMat): tMat;
(* 'CreateMult' arbeitet wie 'Mult', jedoch wird fuer das
   Ergebnis eine Matrix passender Groesse neue angelegt und als
   Funktionswert zurueckgegeben. Die Variable, der dieser Funktions-
   wert zugewiesen wird, darf vorher nicht mit 'Use' initialisiert
   worden sein.
*)

(* SCALar MULTiplication*)
PROCEDURE ScalMult(num: LONGREAL; mat1, res: tMat);
(* Die Matrix 'mat1' wird mit 'num' multipliziert. Das
   Ergebnis wird in 'res' gespeichert. 'mat1' und 'res'
   duerfen dieselben Matrizen sein.
   Es werden Zaehlprozeduren des Moduls 'Pram' zur Protokollierung
   des Berechnungsaufwandes aufgerufen.
*)

PROCEDURE Trace(mat: tMat): LONGREAL;
(* Das Funktionsergebnis ist die Summe der Elemente der
   Hauptdiagonalen (Spur) von 'mat'.
   Es werden Zaehlprozeduren des Moduls 'Pram' zur Protokollierung
   des Berechnungsaufwandes aufgerufen.
*)

END Rema.

\end{verbatim}
\end{DefModul}

