(* ###GrepMarke###
\begin{ImpModul}{Reli} 
\begin{verbatim} 
   ###GrepMarke### *)

IMPLEMENTATION MODULE Reli;  (* REalLIst *)

(*
   Listen von Fliesskommazahlen (Typ LONGREAL) unter Verwendung
   des Moduls 'list'

     (Erklaerungen im Definitionsmodul)
*)

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, Type, Simptype, List;
FROM Sys IMPORT tPOINTER;
FROM Simptype IMPORT RealId, NewReal, DelReal, pReal;

PROCEDURE Use(VAR list: tReli);
BEGIN
    List.Use(list, RealId())
END Use;

PROCEDURE InsertBefore(list: tReli; item: LONGREAL);
VAR ListItem: pReal;
BEGIN
    ListItem:= NewReal(item);
    ListItem^:= item;
    List.InsertBefore(list,ListItem)
END InsertBefore;

PROCEDURE InsertBehind(list: tReli; item: LONGREAL);
VAR ListItem: pReal;
BEGIN
    ListItem:= NewReal(item);
    ListItem^:= item;
    List.InsertBehind(list,ListItem)
END InsertBehind;

PROCEDURE Insert(list: tReli; item: LONGREAL);
BEGIN
    InsertBehind(list,item)
END Insert;

PROCEDURE Cur(list: tReli): LONGREAL;
VAR ListItem: pReal;
BEGIN
    ListItem:= List.Cur(list);
    RETURN ListItem^
END Cur;

PROCEDURE OutCur(list: tReli): LONGREAL;
VAR ListItem: pReal;
    erg     : LONGREAL;
BEGIN
    ListItem:= List.OutCur(list);
    erg     := ListItem^;
    DelReal(ListItem);
    RETURN erg
END OutCur;

END Reli.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
