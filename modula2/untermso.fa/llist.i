
IMPLEMENTATION MODULE LList;

(* Listen von Listen

   (Erklaerungen im Definitionsmodul)
*)

IMPORT List, Type;
FROM SYSTEM IMPORT TSIZE, ADDRESS;

TYPE tLList= List.tList;

PROCEDURE Use(VAR list: tLList);
BEGIN
    List.Use(list, Type.GetId("List"))
END Use;

PROCEDURE InsertBefore(list: tLList; item: List.tList);
BEGIN
    List.InsertBefore(list,item)
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

