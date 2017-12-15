
(*$ e mtp *)

MODULE Grep;

(* Suche von Zeilen in Dateien
  
   Das Programm ist kommandozeilengesteuert. Der erste Parameter, der
   keine Flagge ist, wird als Zeichenkette interpretiert, die in den
   angegebenen Dateien (weitere Parameter) zu suchen ist. Alle
   Zeilen die die Zeichenkette enthalten werden auf die Standard-Ausgabe
   geschrieben.
   
   erlaubte Flaggen:
      -v   schreibe alle Zeilen, die die Zeichenkette nicht enthalten

*)

IMPORT Sys, Str;
FROM InOut IMPORT WriteString, WriteLn, Write, WriteInt;
FROM ArgCV IMPORT ArgStr, PtrArgStr, InitArgCV;

CONST MaxParam= 100;
          (* maximale Anzahl der Kommandozeilen-Parameter *)
      MaxLine= 200;
          (* maximale Laenge einer Zeile in einer zu durchsuchenden
             Datei *)


PROCEDURE CheckFile(VAR f: Sys.File);
VAR StatNum: INTEGER;
BEGIN
    StatNum:= Sys.State(f);
    IF StatNum < 0 THEN
        WriteString("grep: access on file: status ");
        WriteInt(StatNum, 0);
        WriteLn;
        HALT
    END
END CheckFile;

PROCEDURE usage;
BEGIN
    WriteString("grep: usage: [-v] string file1 file2 ...");
    WriteLn;
    HALT
END usage;

PROCEDURE FewArguments;
BEGIN
    WriteString("grep: too few arguments");
    WriteLn;
    HALT
END FewArguments;

VAR cLine: ARRAY [1..MaxParam] OF PtrArgStr;
    count: CARDINAL;
         (* Anzahl der an das Programm uebergebenen Parameter *)
    i: CARDINAL;
    StrIndex: CARDINAL;
        (* Nummer des Elementes in 'cLine', dass auf die zu suchende
           Zeichenkette zeigt *)
    f: Sys.File;
        (* aktuelle Datei *)
    fLine: ARRAY [1..MaxLine] OF CHAR;
        (* aktuelle Zeile in 'f' *)
    vFlag: BOOLEAN;
        (* TRUE: -v wurde in der Kommandozeile angegeben *)
    dummy: ARRAY [1..3] OF CHAR;
    dummy2: BOOLEAN;
    dummy3: CARDINAL;
BEGIN
    StrIndex:= 0;
    vFlag:= FALSE;

    InitArgCV(count, cLine);
    IF count < 3 THEN
        usage
    ELSE
        FOR i:= 2 TO count DO
            IF cLine[i]^[0] = '-' THEN
                vFlag:= cLine[i]^[1] = 'v';
                IF NOT vFlag THEN
                    WriteString("grep: unknown flag: ");
                    Write(cLine[i]^[1]);
                    WriteLn;
                    HALT
                END
            ELSIF StrIndex = 0 THEN
                StrIndex:= i;
                
                (* initialisiere Suche von 'cLine[i]^' : *)
                Str.Empty(dummy);
                dummy2:= Str.In(cLine[i]^, dummy, dummy3);
                Str.NewSub(FALSE)
            ELSE
                IF StrIndex = 0 THEN
                    FewArguments
                ELSE
                    Sys.OpenRead(f, cLine[i]^);
                    CheckFile(f);
                    WHILE NOT Sys.EOF(f) DO
                        Sys.ReadLine(f, fLine);
                        IF Str.In(cLine[StrIndex]^, fLine, dummy3) THEN
                            IF NOT vFlag THEN
                                WriteString(fLine); WriteLn
                            END
                        ELSE
                            IF vFlag THEN
                                WriteString(fLine); WriteLn
                            END
                        END
                    END;
                    Sys.Close(f)
                END
            END
        END; (* FOR *)
        IF vFlag AND (count = 3) THEN
            FewArguments
        END;
    END (* ELSE *)
END Grep.
