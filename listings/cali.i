
\begin{ImpModul}{Cali} 
\begin{verbatim} 

IMPLEMENTATION MODULE Cali; (* CArdLIst *)

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, Type, Simptype, List;
FROM Sys IMPORT tPOINTER;
FROM Simptype IMPORT CardId, NewCard, DelCard, pCard;

PROCEDURE Use(VAR list: tCali);
BEGIN
    List.Use(list, CardId())
END Use;

PROCEDURE InsertBefore(list: tCali; item: LONGCARD);
VAR ListItem: pCard;
BEGIN
    ListItem:= NewCard(item);
    ListItem^:= item;
    List.InsertBefore(list,ListItem)
END InsertBefore;

PROCEDURE InsertBehind(list: tCali; item: LONGCARD);
VAR ListItem: pCard;
BEGIN
    ListItem:= NewCard(item);
    ListItem^:= item;
    List.InsertBehind(list, ListItem)
END InsertBehind;

PROCEDURE Insert(list: tCali; item: LONGCARD);
BEGIN
    InsertBehind(list, item)
END Insert;

PROCEDURE Cur(list: tCali): LONGCARD;
VAR ListItem: pCard;
BEGIN
    ListItem:= List.Cur(list);
    RETURN ListItem^
END Cur;

PROCEDURE OutCur(list: tCali): LONGCARD;
VAR ListItem: pCard;
    erg     : LONGCARD;
BEGIN
    ListItem:= List.OutCur(list);
    erg     := ListItem^;
    DelCard(ListItem);
    RETURN erg
END OutCur;

END Cali.
\end{verbatim}
\end{ImpModul}

