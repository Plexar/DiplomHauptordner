
MODULE Testall;

FROM InOut IMPORT WriteLn, WriteString, ReadCard;
IMPORT IntList, CardList, Tree;

VAR
    eingabe: CARDINAL;

BEGIN
    WriteLn;
    WriteString("*** Testall ***"); WriteLn;
    WriteString(" 0 - Ende "); WriteLn;
    WriteString("Eingabe: "); ReadCard(eingabe)
END Testall.
