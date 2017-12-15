
MODULE endbem;

(* Berechnung einer Tabelle von Wertebeispielen fuer Schritte und
   Prozessoren bei gegebener Matrizengroesse n
   
   Es werden die entsprechenden Terme fuer die vier Algorithmen
   ausgewertet.
   
*)

FROM InOut IMPORT WriteCard, WriteString, WriteLn, ReadString;
FROM SysMath IMPORT sqrt, power, ld, LCard2LReal, LInt2LReal;
FROM Func IMPORT Ceil, Floor;

PROCEDURE log(x: LONGINT): LONGINT;
BEGIN
    IF x=0 THEN x:= 1 END;
    RETURN Ceil( ld(LCard2LReal(x)) )
END log;

PROCEDURE pow(b: LONGINT; x: LONGREAL): LONGINT;
BEGIN
    RETURN Ceil( power(LCard2LReal(b), x) )
END pow;

PROCEDURE div(a: LONGINT; b: LONGREAL): LONGINT;
BEGIN
    RETURN Ceil( LInt2LReal(a) / b );
END div;

PROCEDURE IntMax(a,b: LONGINT): LONGINT;
BEGIN
    IF a>b THEN
        RETURN a
    ELSE
        RETURN b
    END
END IntMax;
       
PROCEDURE Wait;
VAR dummy: ARRAY [1..3] OF CHAR;
BEGIN
    ReadString(dummy)
END Wait;

PROCEDURE sCsanky(n: LONGINT): LONGINT;
BEGIN

(* \lc \log(n) \rc^2 + 4 \lc \log(n) \rc + 4 *)

    RETURN log(n)*log(n) + 4 * log(n) + 4
END sCsanky;

PROCEDURE pCsanky(n: LONGINT): LONGINT;
BEGIN

(* \lc \frac{n^4}{2} \rc *)

    RETURN n*n*n*n DIV 2 + (n*n*n*n MOD 2)
END pCsanky;

PROCEDURE sBGH(n: LONGINT): LONGINT;
VAR n3,s3,n2,s2: LONGINT;
BEGIN
(*
        2\lc \log(s) \rc \\
    & &
        * \lb
            \lc
            \log\lb
   \frac{1}{4}
   \lb
       n^3 s^3 + 2 n^3 s^2 + \frac{1}{3}n^3 s - n s^3 + n s^2 +
       \frac{5}{3}n s - 4 n - 6 s^2 - 2 s + 4
   \rb
            \rb
            \rc + 2
        \rb \\
    & & + \lc \log(s+1) \rc
*)
    n2:= n*n; s2:= n2; n3:= n2*n; s3:= n3;
    RETURN
        2 * log(n) *
        (
            log(
               (
                  n3*s3 + 2*n3*s2 + (n3*n)DIV 3 - n*s3 + n*s2 +
                  (3*n*n)DIV 5 - 4 * n - 6 * s2 - 2 * n + 4
               ) DIV 4
               )
        + 2
        ) + log(n+1)
END sBGH;

PROCEDURE pBGH(n: LONGINT): LONGINT;
VAR n3, s3: LONGINT;
BEGIN
(*
   \frac{1}{4}
   \lb
       n^3 s^3 + 2 n^3 s^2 + \frac{1}{3}n^3 s - n s^3 + n s^2 +
       \frac{5}{3}n s - 4 n - 6 s^2 - 2 s + 4
   \rb
*)
    n3:= n*n*n; s3:= n3;
    RETURN
       ( n3*s3 + 2*n3*n*n + (n3 * n) DIV 3 - n * s3 + n * n*n +
         (5 * n * n) DIV 3 - 4 * n - 6 * n * n - 2 * n + 4
       ) DIV 4
END pBGH;

PROCEDURE sBerk(n: LONGINT): LONGINT;
BEGIN

(* \gamma_S
   \lc
       \lc \log(n-2) \rc^2
       + \left( 1 + \frac{1}{\gamma_S}
       + \frac{1}{\epsilon} \right) \lc \log(n-2) \rc +
       \frac{1}{\epsilon} + \frac{1}{\gamma_S} + 0.5
   \rc +
   (\lc \log(n+1) \rc + 1) \lc \log(n) \rc
*)
    RETURN
       log(n-2) * log(n-2)
       + 9 + log(n-2)
       + (log(n+1) + 1) * log(n)
END sBerk;

PROCEDURE pBerk(n: LONGINT): LONGINT;
VAR hilf: LONGINT;
    hilf2: LONGREAL;
    n4: LONGINT;
BEGIN
      hilf2:= LCard2LReal(n-2) / sqrt(2.0);
      IF hilf2 < 1.0 THEN hilf2:= 1.0 END;
      hilf:= Ceil (power( 2.0,
                LCard2LReal( Floor( ld(hilf2) ))
             ));
      IF n<4 THEN n4:= 4 ELSE n4:= n END;
RETURN
         4 + pow( n-2, 3.5) +
              pow(n-2,3.5) DIV 2
         + IntMax( 0, n-2 - 2 )+
           IntMax( 0, (pow( n4-2, 4.5)  - pow(2 , 4.5) ) DIV 9)
        +
           IntMax( 0, div( (pow( n-2, 4.5) - pow(hilf, 4.5)), 4.5) )
       +
          IntMax( 0, pow(hilf, 4.5) - pow(2 , 4.5))
END pBerk;

PROCEDURE pPan(n: LONGINT): LONGINT;
BEGIN
(*
    \gamma_P n^{2+\gamma}
*)
    RETURN n*n*n
END pPan;

PROCEDURE sPan(n: LONGINT): LONGINT;
BEGIN
(*
    \gamma_S \lb 3 \lc\log(n)\rc^2 + 7 \lc\log(n)\rc
    + \frac{3}{\gamma_S} + 2 \rb \MyPunkt

*)
    RETURN 3*log(n)*log(n) + 7 * log(n) + 5
END sPan;

PROCEDURE Beispiele(n: LONGINT);
BEGIN
    WriteCard(n,0);
    WriteString(" Csan: s"); WriteCard(sCsanky(n),0);
    WriteString(" p"); WriteCard(pCsanky(n), 0);
    WriteString(" BGH: s"); WriteCard(sBGH(n),0);
    WriteString(" p"); WriteCard(pBGH(n), 0);
    WriteString(" Berk: s"); WriteCard(sBerk(n),0);
    WriteString(" p"); WriteCard(pBerk(n), 0);
    WriteString(" Pan: s"); WriteCard(sPan(n),0);
    WriteString(" p"); WriteCard(pPan(n), 0);
    WriteLn;
END Beispiele;
VAR n: LONGINT;
BEGIN
    FOR n:= 2 TO 20 BY 2 DO
        Beispiele(n)
    END;
    Wait
END endbem.
