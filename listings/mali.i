
\begin{ImpModul}{Mali} 
\begin{verbatim} 

IMPLEMENTATION MODULE Mali;  (* MAtrix LIst *)

(*
   Listen von Matrizen (Typ 'Rema.tMat') unter Verwendung
   des Moduls 'list'

     (Erklaerungen im Definitionsmodul)
*)

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, List, Type, Rema;
FROM Sys IMPORT tPOINTER;
FROM Rema IMPORT tMat;

VAR MatId: Type.Id; (* Typnummer fuer 'Rema.tMat' *)

PROCEDURE Use(VAR list: tMali);
BEGIN
    List.Use(list, MatId)
END Use;

PROCEDURE InsertBefore(list: tMali; item: tMat);
BEGIN
    List.InsertBefore(list, tPOINTER(item))
END InsertBefore;

PROCEDURE InsertBehind(list: tMali; item: tMat);
BEGIN
    List.InsertBehind(list, tPOINTER(item))
END InsertBehind;

PROCEDURE Insert(list: tMali; item: tMat);
BEGIN
    List.InsertBehind(list, tPOINTER(item))
END Insert;

PROCEDURE Cur(list: tMali): tMat;
VAR ListItem: tMat;
BEGIN
    ListItem:= tMat( List.Cur(list) );
    RETURN ListItem
END Cur;

PROCEDURE OutCur(list: tMali): tMat;
VAR ListItem: tMat;
BEGIN
    ListItem:= tMat( List.OutCur(list) );
    RETURN ListItem
END OutCur;

BEGIN
    MatId:= Type.GetId("Rema.tMat")
END Mali.

\end{verbatim}
\end{ImpModul}
