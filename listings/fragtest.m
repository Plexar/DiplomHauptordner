
\begin{ProgModul}{fragtest}
\begin{verbatim}
 

MODULE fragtest;

FROM InOut IMPORT WriteLn, WriteLReal, WriteString, ReadCard, ReadLReal;
IMPORT Type, Frag;

(*  Test des Moduls 'frag' *)

CONST StartIndex = 5; (* Anzahl der Elemente des Testfeldes 'TestFrag' *)

TYPE pReal = POINTER TO LONGREAL;

VAR
    TestFrag: Frag.tFrag;
    RealId: Type.Id;

PROCEDURE l(text: ARRAY OF CHAR);
BEGIN
    WriteString(text); WriteLn
END l;

PROCEDURE WriteFrag(f: Frag.tFrag);
VAR i,low,high: LONGCARD;
    p: pReal;
BEGIN
    low:= Frag.GetLow(f);
    high:= Frag.GetHigh(f);
    FOR i:= low TO high DO
        p:= GetItem(f, i);
        IF p#NIL THEN
            WriteReal(p^,7,3)
        ELSE
            WriteReal(0.0, 7, 3)
        END
    END
END WriteFrag;

PROCEDURE WriteMenu;
BEGIN
    l("0 - Ende");
    l("1 - SetRange");
    l("2 - SetType");
    l("3 - AddRef");
    l("4 - Empty");
    l("5 - SetItem");
    l("6 - Transfer");
    WriteFrag(TestFrag); WriteLn;
END WriteMenu;

PROCEDURE ReadSelection(VAR eingabe: CARDINAL);
BEGIN
    WriteString("Auswahl? "); ReadCard(eingabe)
END ReadSelection;

PROCEDURE DoSelection(selected: CARDINAL);
VAR InReal: LONGREAL;
    index, i1, i2: LONGCARD;
    pointer: pReal;
BEGIN
    CASE selected OF
        0: (* tue nichts *)
      | 1: WriteString("Unterer Index? "); ReadCard(i1); WriteLn;
           WriteString("Oberer Index? "); ReadCard(i2); WriteLn;
           Frag.SetRange(TestFrag);
      | 2:
      | 3:
      | 4:
      | 5:
           WriteString("Index? "); ReadCard(index); WriteLn;
           WriteString("Wert? "); ReadReal(InReal);
           pointer:= Type.NewI(RealId);
           pointer^:= InReal;
           Frag.SetItem(TestFrag, index, pointer)
      | 6:
    ELSE
        l("DoSelection: Auswahl unbekannt")
    END
END DoSelection;

BEGIN
    RealId:= Type.GetId("LONGREAL");
    Frag.Use(TestFrag, RealId, 1, MaxIndex);
    REPEAT
        WriteMenu;
        ReadSelection(eingabe);
        DoSelection(eingabe)
    UNTIL eingabe = 0
END 


\end{verbatim}
\end{ProgModul}
  
