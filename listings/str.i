
\begin{ImpModul}{Str} 
\begin{verbatim} 
 

IMPLEMENTATION MODULE Str;

(*    Handhabung von Zeichenketten

   (Erklaerungen im Definitionsmodul)
*)

FROM InOut IMPORT WriteLn, WriteString;
IMPORT Func;

PROCEDURE Empty(VAR str: ARRAY OF CHAR);
VAR
    i,h: CARDINAL;
BEGIN
    h:= HIGH(str);
    FOR i:= 0 TO h DO
        str[i]:= 0C;
    END
END Empty;

PROCEDURE Assign(VAR dst: ARRAY OF CHAR; src: ARRAY OF CHAR);
VAR
    i,highd,highs: CARDINAL;
BEGIN
    highd:= HIGH(dst);
    highs:= HIGH(src);
    FOR i:= 0 TO highd DO
        IF i<= highs THEN
            dst[i]:= src[i]
        ELSE
            dst[i]:= 0C;
        END
    END
END Assign;

PROCEDURE Append(VAR dest: ARRAY OF CHAR;
                 suffix: ARRAY OF CHAR);
VAR
    InDest,InSuffix,highd,highs: CARDINAL;
BEGIN
    highd:= HIGH(dest);
    highs:= HIGH(suffix);
    InDest:= Length(dest);
    InSuffix:= 0;
    WHILE (InDest <= highd) AND (InSuffix <= highs) DO
        dest[InDest]:= suffix[InSuffix];
        INC(InDest); INC(InSuffix)
    END
END Append;

PROCEDURE Equal(VAR x: ARRAY OF CHAR;
                y: ARRAY OF CHAR): BOOLEAN;
VAR
    num, max: CARDINAL;
    equal, end: BOOLEAN;
BEGIN
    num:= 0; max:= Func.MinCard(HIGH(x), HIGH(y));
    REPEAT
        equal:= x[num] = y[num];
        end:= (x[num] = 0C) OR (y[num] = 0C) OR (num = max);
        INC(num)
    UNTIL end OR NOT equal;
    IF equal AND (num > max) THEN
        IF (x[num-1] # 0C) AND (HIGH(x) # HIGH(y)) THEN
            IF HIGH(x) < HIGH(y) THEN
                equal:= y[num] # 0C
            ELSE
                equal:= x[num] # 0C
            END
        END
    END;
    RETURN equal
END Equal;

PROCEDURE Ordered(VAR x: ARRAY OF CHAR;
                      y: ARRAY OF CHAR): BOOLEAN;
VAR
    num, max: CARDINAL;
    equal, end, order: BOOLEAN;
BEGIN
    num:= 0; max:= Func.MinCard(HIGH(x), HIGH(y));
    REPEAT
        equal:= x[num] = y[num];
        end:= (x[num] = 0C) OR (y[num] = 0C) OR (num = max);
        INC(num)
    UNTIL end OR NOT equal;
    IF equal THEN
        (* hier gilt: (x[num-1] = y[num-1]) AND (num > max) *)
        IF x[num-1] = 0C THEN
            order:= TRUE
        ELSE
            order:= HIGH(x) <= HIGH(y)
        END
    ELSE
        order:= x[num-1] < y[num-1]
    END;
    RETURN order
END Ordered;
    
PROCEDURE Length(VAR str: ARRAY OF CHAR): CARDINAL;
(* Verbesserungsmoeglichkeit:
       Suche nach der Intervallhalbierungsmethode
*)
VAR
    i,high: CARDINAL;
    cont: BOOLEAN;
BEGIN
    i:= 0;
    high:= HIGH(str);
    WHILE (str[i] # 0C) AND (i < high) DO
        INC(i)
    END;
    IF str[i] = 0C THEN
        RETURN i
    END;
    RETURN i+1
END Length;

PROCEDURE Insert(VAR substr, str: ARRAY OF CHAR;
                 inx: CARDINAL);
VAR
    i, j, SubLength, StrEnd, SubHigh, StrHigh,
    NewLastChar: CARDINAL;
BEGIN
    StrEnd:= Length(str);
    IF inx>StrEnd THEN
        WriteLn;
        WriteString("*** Str.Insert:                     ***");
        WriteLn;
        WriteString("***     angegebener Index groesser  ***");
        WriteLn;
        WriteString("***     als Laenge der Zeichenkette ***");
        WriteLn;
        HALT
    END;

    SubLength:= Length(substr);
    SubHigh:= HIGH(substr); StrHigh:= HIGH(str);

    (* in 'str' Platz fuer 'substr' schaffen: *)
    NewLastChar:= (StrEnd-1) + SubLength;
    i:= NewLastChar; (* i: Ziel der Verschiebung *)
    FOR j:= StrEnd-1-Func.MaxCard(NewLastChar-StrHigh, 0)
    TO inx BY -1 DO
        str[i]:= str[j];
        INC(i)
    END;
    
    (* 'substr' einfuegen: *)
    j:= 0; (* j: Position in 'substr' *)
    FOR i:= inx TO Func.MaxCard(inx+SubLength-1, StrHigh) DO
        str[i]:= substr[j];
        INC(j)
    END
END Insert;

PROCEDURE Delete(VAR str: ARRAY OF CHAR; inx,len: CARDINAL);
VAR
    i, j, StrEnd, StrHigh, NewLastChar: CARDINAL;
    cont: BOOLEAN;
BEGIN
    StrEnd:= Length(str);
    IF inx>StrEnd THEN
        WriteLn;
        WriteString("*** Str.Delete:                     ***");
        WriteLn;
        WriteString("***     angegebener Index groesser  ***");
        WriteLn;
        WriteString("***     als Laenge der Zeichenkette ***");
        WriteLn;
        HALT
    END;
    
    StrHigh:= HIGH(str);

    FOR i:= inx TO StrEnd DO
        IF (i<inx+len) AND (i+len<=StrHigh) THEN
            str[i]:= str[i+len]
        ELSE
            str[i]:= 0C
        END
    END
END Delete;

VAR
    d: ARRAY [0C..255C] OF INTEGER;
        (* 'Vorrueckwerte' fuer jedes Zeichen im Zeichensatz *)
    changed: ARRAY [0..255] OF CHAR;
        (* Liste der Indizes in 'd', die veraendert wurden *)
    top: INTEGER;
        (* erstes unbenutztes Element in 'changed' *)
    newsub: BOOLEAN;
        (* FALSE: es wird angenommen, dass alle 'substr'-Parameter,
                  die an 'In' uebergeben werden, gleich sind und
                  die Suche nicht initialisiert werden muss
                  (-> schneller)
        *)
    SubLen: INTEGER;
        (* Laenge der zu suchenden Zeichenkette *)

PROCEDURE InitSearch(VAR substr: ARRAY OF CHAR);
(* 'substr' wird als zu suchende Zeichenkette betrachtet. Strukturinfor-
   mation fuer die spaetere Suche durch 'In' werden in 'd' gespeichert.
*)
VAR i, InSub: INTEGER;
BEGIN
    SubLen:= Length(substr);
    FOR i:= 0 TO top-1 DO
        d[changed[i]] := -1
    END;
    top:= 0;
    FOR InSub:= 0 TO SubLen-2 DO
        IF d[substr[InSub]] = -1 THEN
            changed[top]:= substr[InSub];
            INC(top)
        END;
        d[substr[InSub]]:= SubLen-InSub-1
    END
END InitSearch;
        
PROCEDURE In(VAR substr, str: ARRAY OF CHAR;
             VAR pos: CARDINAL): BOOLEAN;
(* Es wird der Boyer-Moore Algorithmus aus
       N. Wirth, Algorithmen und Datenstrukturen mit Modula-2,
       Teubner Verlag, S. 67 ff.
   verwendet.
*)
VAR
    StrLen, InStr, InSub, WorkInStr: INTEGER;
    stop: BOOLEAN;
    inequal: BOOLEAN;
    i: INTEGER;
BEGIN
    StrLen:= Length(str);

    IF newsub THEN
        InitSearch(substr);
        IF (SubLen < 1)  OR (SubLen > StrLen) THEN RETURN FALSE END
    ELSE
        IF SubLen > StrLen THEN RETURN FALSE END
    END;

    InStr:= SubLen-1;
    REPEAT
        WorkInStr:= InStr; InSub:= SubLen-1;
        REPEAT
            inequal:= substr[InSub] # str[WorkInStr];
            DEC(WorkInStr); DEC(InSub)
        UNTIL (InSub < 0) OR inequal;
        IF d[str[InStr]] = -1 THEN
            InStr:= InStr + SubLen
        ELSE
            InStr:= InStr + d[str[InStr]]
        END
    UNTIL ((InSub < 0) AND NOT inequal) OR (InStr >= StrLen);

    pos:= WorkInStr+1;
    RETURN (InSub < 0) AND NOT inequal
END In;

PROCEDURE NewSub(switch: BOOLEAN);
BEGIN
    newsub:= switch
END NewSub;

PROCEDURE Lower(VAR s: ARRAY OF CHAR);
VAR i: CARDINAL;
    stop: BOOLEAN;
BEGIN
    stop:= FALSE;
    i:= 0;
    REPEAT
        IF ('A' <= s[i]) AND (s[i] <= 'Z') THEN
            s[i]:= CHR(ORD('a') + ORD(s[i]) - ORD('A'))
        END;
        stop:= (s[i] = CHR(0)) OR (i+1 > HIGH(s));
        INC(i)
    UNTIL stop
END Lower;

VAR
    ch: CHAR;

BEGIN
    FOR ch:= 0C TO 255C DO d[ch]:= -1 END;
    top:= 0;
    newsub:= TRUE
END Str.

\end{verbatim}
\end{ImpModul}
 
