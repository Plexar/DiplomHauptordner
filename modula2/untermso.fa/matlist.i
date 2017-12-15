
IMPLEMENTATION MODULE CaLi; (* CArdLIst *)

IMPORT List, Type;
FROM SYSTEM IMPORT TSIZE, ADDRESS;

TYPE tCardList= List.tList;
     pCard= POINTER TO LONGCARD;

VAR CardId: Type.Id; (* Typnummer fuer LONGCARD *)

PROCEDURE Use(VAR list: tCaLi);
BEGIN
    List.Use(list, CardId)
END Use;

PROCEDURE InsertBefore(list: tCaLi; item: LONGCARD);
VAR ListItem: pCard;
BEGIN
    ListItem:= Type.NewI(CardId);
    ListItem^:= item;
    List.InsertBefore(list,ListItem)
END InsertBefore;

PROCEDURE InsertBehind(list: tCaLi; item: LONGCARD);
VAR ListItem: pCard;
BEGIN
    ListItem:= Type.NewI(CardId);
    ListItem^:= item;
    List.InsertBehind(list,ListItem)
END InsertBehind;

PROCEDURE Cur(list: tCaLi): LONGCARD;
VAR ListItem: pCard;
BEGIN
    ListItem:= List.Cur(list);
    RETURN ListItem^
END Cur;

PROCEDURE OutCur(list: tCaLi): LONGCARD;
VAR ListItem: pCard;
    erg     : LONGCARD;
BEGIN
    ListItem:= List.OutCur(list);
    erg     := ListItem^;
    Type.DelI(CardId,ListItem);
    RETURN erg
END OutCur;

PROCEDURE EquCard(a,b: ADDRESS): BOOLEAN;
BEGIN
    RETURN LONGCARD(a^) = LONGCARD(b^)
END EquCard;

PROCEDURE OrdCard(a,b: ADDRESS): BOOLEAN;
BEGIN
    RETURN LONGCARD(a^) < LONGCARD(b^)
END OrdCard;

BEGIN
    CardId:= Type.New(TSIZE(LONGCARD));
    Type.SetName(CardId,"LONGCARD");
    Type.SetEquProc(CardId,EquCard);
    Type.SetOrdProc(CardId,OrdCard)
END CardList.

