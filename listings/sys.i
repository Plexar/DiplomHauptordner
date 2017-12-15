
\begin{ImpModul}{Sys} 
\begin{verbatim} 


IMPLEMENTATION MODULE Sys;

(*      Systemabhaengige nichtmathematische Prozeduren
        (Atari ST, TOS 2.06, Megamax Modula-2 Compiler V4.2)

          (Erklaerungen im Definitionsmodul)
*)

IMPORT Files, Text, NumberIO;
FROM Files IMPORT Access, ReplaceMode, Open, Create;

TYPE
     File= Files.File;
     
PROCEDURE OpenRead(VAR f: File; name: ARRAY OF CHAR);
BEGIN
    Open(f, name, Access(readSeqTxt))
END OpenRead;

PROCEDURE OpenWrite(VAR f: File; name: ARRAY OF CHAR);
BEGIN
    Create(f, name, Access(writeSeqTxt), ReplaceMode(replaceOld))
END OpenWrite;

PROCEDURE Close(VAR f: File);
BEGIN
    Files.Close(f)
END Close;
 
PROCEDURE Exist(name: ARRAY OF CHAR): BOOLEAN;
VAR
    f: File;
BEGIN
    Open(f, name, Access(readOnly) );
    IF Files.State(f) < 0 THEN
        RETURN FALSE
    END;
    Close(f);
    RETURN TRUE
END Exist;

PROCEDURE Delete(name: ARRAY OF CHAR);
VAR
    f: File;
BEGIN
    IF Exist(name) THEN
        OpenWrite(f, name);
        Files.Remove(f)
    END
END Delete;

PROCEDURE EOF(VAR f: File): BOOLEAN;
BEGIN
    RETURN Files.EOF(f)
END EOF;

PROCEDURE State(VAR f: File): INTEGER;
BEGIN
    RETURN Files.State(f)
END State;

PROCEDURE WriteLn(VAR f: File);
BEGIN
    Text.WriteLn(f)
END WriteLn;

PROCEDURE WriteCard(VAR f: File; val: LONGCARD; length: CARDINAL);
BEGIN
    NumberIO.WriteCard(f, val, length)
END WriteCard;

PROCEDURE WriteReal(VAR f: File; val: LONGREAL;
                    length,dec: CARDINAL);
BEGIN
    NumberIO.WriteReal(f, val, length, dec)
END WriteReal;

PROCEDURE WriteString(VAR f: File; val: ARRAY OF CHAR);
BEGIN
    Text.WriteString(f, val)
END WriteString;

PROCEDURE ReadCard(VAR f: File; VAR val: CARDINAL);
VAR
    dummy: BOOLEAN;
BEGIN
    NumberIO.ReadCard(f, val, dummy)
END ReadCard;

PROCEDURE ReadLCard(VAR f: File; VAR val: LONGCARD);
VAR
    dummy: BOOLEAN;
BEGIN
    NumberIO.ReadLCard(f, val, dummy)
END ReadLCard;

PROCEDURE ReadReal(VAR f: File; VAR val: LONGREAL);
VAR
    dummy: BOOLEAN;
BEGIN
    NumberIO.ReadLReal(f, val, dummy)
END ReadReal;

PROCEDURE ReadString(VAR f: File; VAR val: ARRAY OF CHAR);
BEGIN
    Text.ReadToken(f, val)
END ReadString;

PROCEDURE ReadLine(VAR f: File; VAR val: ARRAY OF CHAR);
BEGIN
    Text.ReadFromLine(f, val)
END ReadLine;

PROCEDURE ReadLn(VAR f: File);
VAR
    dummy: ARRAY [1..160] OF CHAR;
BEGIN
    Text.ReadFromLine(f,dummy)
END ReadLn;

END Sys.

\end{verbatim}
\end{ImpModul}
 
