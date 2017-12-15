
* Datei: vsbr1.for
* Datum: 18.05.92

* Berechnung von Analyseergebnissen

s n,s;
b n,s;

***********************************************************
* Anzahl der Anweisungen zur Verkn"upfung von Potenzreihen:
*     Addition:
l AnwAdd= s+1;
*     Multiplikation:
l AnwMult= (3*s^2 + s - 2)/2;
*     Division:
l AnwDiv= (3*s^3 + 3*s^2 - 2*s)/2;

**********************************************
* Anzahl neu zu berechnender Matrizenelemente:
*         \frac{1}{2} 
*         \lb (n^3+2n^2-n-2) +
*             + \frac{ 2n^3+3n^2+n }{ 6 } - 1
*             - ( n^3+n^2 - 2n) 
*             - \lb \frac{ 3(n^2+n) }{ 2 } - 3 \rb
*         \rb

l NeueElem
     = 1/2 *
         ( ( n^3 + 2*n^2-n-2)+
             +(2*n^3+3*n^2+n)/6-1
             -(n^3+n^2-2*n) 
             -((3*(n^2+n))/2-3) );
*****************************************
* Anzahl der Anweisungen fuer 'NeueElem':
l AnwNeueElem
  = NeueElem * ( AnwAdd + AnwMult + AnwDiv );
****************************************************************
* Anzahl der Anweisungen zur Multiplikation der Diagonalelemente:
l AnwDiagMult = (n-1)* AnwMult ;
*****************************
* Gesamtlaenge des Programms:
g Gesamt = AnwNeueElem + AnwDiagMult;
print;
.sort
**********************
* Anzahl der Schritte:
*        (\log(s) + 1) *
*        \lb \log\lb\frac{1}{4}\rb +
*            3\log(n) +
*            \log
*            \lb
*                s^3 + 2 s^2 + s
*            \rb
*        \rb
f log;
l schritte = ( log(s) + 1)*( log(1/4) + 3*log(n) +
                             log(s^3 + 2*s^2 + s)
                           );
*************************
* Anzahl der Prozessoren:
**l prozessoren = 2 * Gesamt;
skip AnwAdd, AnwMult, AnwDiv, Gesamt, AnwNeueElem, AnwDiagMult, NeueElem;
print;
.end
