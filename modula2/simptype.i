(* ###GrepMarke###
\begin{ImpModul}{Simptype}
\begin{verbatim}
   ###GrepMarke### *)

IMPLEMENTATION MODULE Simptype;

(*   einfache Datentypen fuer das Modul 'Type'

       ( Erklaerungen im Definitionsmodul )
*)

FROM SYSTEM IMPORT TSIZE;
IMPORT Sys, Type;
FROM Sys IMPORT tPOINTER;

VAR vCardId, vIntId, vRealId, vPointId: Type.Id;
        (* Typidentifikatoren fuer Modul 'Type' *)

PROCEDURE CardId(): Type.Id;
BEGIN
    RETURN vCardId
END CardId;

PROCEDURE NewCard(val: LONGCARD): pCard;
VAR res: pCard;
BEGIN
    res:= Type.NewI(vCardId);
    res^:= val;
    RETURN res
END NewCard;

PROCEDURE DelCard(VAR val: pCard);
BEGIN
    Type.DelI(vCardId, val)
END DelCard;

PROCEDURE IntId(): Type.Id;
BEGIN
    RETURN vIntId
END IntId;

PROCEDURE NewInt(val: LONGINT): pInt;
VAR res: pInt;
BEGIN
    res:= Type.NewI(vIntId);
    res^:= val;
    RETURN res
END NewInt;

PROCEDURE DelInt(VAR val: pInt);
BEGIN
    Type.DelI(vIntId, val)
END DelInt;

PROCEDURE RealId(): Type.Id;
BEGIN
    RETURN vRealId
END RealId;

PROCEDURE NewReal(val: LONGREAL): pReal;
VAR res: pReal;
BEGIN
    res:= Type.NewI(vRealId);
    res^:= val;
    RETURN res
END NewReal;

PROCEDURE DelReal(VAR val: pReal);
BEGIN
    Type.DelI(vRealId, val)
END DelReal;

PROCEDURE PointId(): Type.Id;
BEGIN
    RETURN vPointId
END PointId;

PROCEDURE NewPoint(val: pPoint): pPoint;
VAR res: pPoint;
BEGIN
    res:= Type.NewI(vPointId);
    res^:= val;
    RETURN res
END NewPoint;

PROCEDURE DelPoint(VAR val: pPoint);
BEGIN
    Type.DelI(vPointId, val)
END DelPoint;

(*******************************************)
(* Operationsprozeduren fuer Modul 'Type': *)

PROCEDURE EquCard(ahilf,bhilf:tPOINTER): BOOLEAN;
VAR
    a, b: pCard;
BEGIN
    a:= ahilf; b:= bhilf;
    RETURN a^ = b^
END EquCard;

PROCEDURE OrdCard(ahilf,bhilf: tPOINTER): BOOLEAN;
VAR
    a, b: pCard;
BEGIN
    a:= ahilf; b:= bhilf;
    RETURN a^ < b^
END OrdCard;

PROCEDURE EquInt(a,b: tPOINTER): BOOLEAN;
VAR A, B: pInt;
BEGIN
    A:= a; B:= b;
    RETURN A^ = B^
END EquInt;

PROCEDURE OrdInt(a,b: tPOINTER): BOOLEAN;
VAR A, B: pInt; 
BEGIN
    A:= a; B:= b;
    RETURN A^ < B^
END OrdInt;

PROCEDURE EquReal(a,b: tPOINTER): BOOLEAN;
VAR A,B: pReal;
BEGIN
    A:= a; B:= b;
    RETURN A^ = B^
END EquReal;

PROCEDURE OrdReal(a,b: tPOINTER): BOOLEAN;
VAR A,B: pReal;
BEGIN
    A:= a; B:= b;
    RETURN A^ < B^
END OrdReal;

PROCEDURE EquPoint(a,b: tPOINTER): BOOLEAN;
VAR A,B: pPoint;
BEGIN
    A:= a; B:= b;
    RETURN A^ = B^
END EquPoint;

BEGIN
    vCardId:= Type.New(TSIZE(LONGCARD));
    Type.SetName(vCardId,"LONGCARD");
    Type.SetEquProc(vCardId,EquCard);
    Type.SetOrdProc(vCardId,OrdCard);

    vIntId:= Type.New(TSIZE(LONGINT));
    Type.SetName(vIntId,"LONGINT");
    Type.SetEquProc(vIntId,EquInt);
    Type.SetOrdProc(vIntId,OrdInt);

    vRealId:= Type.New(TSIZE(LONGREAL));
    Type.SetName(vRealId,"LONGREAL");
    Type.SetEquProc(vRealId,EquReal);
    Type.SetOrdProc(vRealId,OrdReal);

    vPointId:= Type.New(TSIZE(pPoint));
    Type.SetName(vPointId,"pPoint");
    Type.SetEquProc(vPointId,EquPoint)
END Simptype.
(* ###GrepMarke###
\end{verbatim}
\end{ImpModul}
   ###GrepMarke### *)
