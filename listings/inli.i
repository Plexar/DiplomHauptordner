
\begin{ImpModul}{Inli}
\begin{verbatim}
 
IMPLEMENTATION MODULE Inli;

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, Type, Simptype, List;
FROM Sys IMPORT tPOINTER;
FROM Simptype IMPORT IntId, NewInt, DelInt, pInt;

PROCEDURE Use(VAR list: tInli);
BEGIN
    List.Use(list, IntId())
END Use;

PROCEDURE InsertBefore(list: tInli; item: LONGINT);
VAR ListItem: pInt;
BEGIN
    ListItem:= NewInt(item);
    ListItem^:= item;
    List.InsertBefore(list,ListItem)
END InsertBefore;

PROCEDURE InsertBehind(list: tInli; item: LONGINT);
VAR ListItem: pInt;
BEGIN
    ListItem:= NewInt(item);
    ListItem^:= item;
    List.InsertBehind(list,ListItem)
END InsertBehind;

PROCEDURE Insert(list: tInli; item: LONGINT);
BEGIN
    InsertBehind(list,item)
END Insert;

PROCEDURE Cur(list: tInli): LONGINT;
VAR ListItem: pInt;
BEGIN
    ListItem:= List.Cur(list);
    RETURN ListItem^
END Cur;

PROCEDURE OutCur(list: tInli): LONGINT;
VAR ListItem: pInt;
    erg     : LONGINT;
BEGIN
    ListItem:= List.OutCur(list);
    erg     := ListItem^;
    DelInt(ListItem);
    RETURN erg
END OutCur;

END Inli.

\end{verbatim}
\end{ImpModul}

