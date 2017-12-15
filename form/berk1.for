
* Datei: berk1.for
* Datum: 20.04.92

* Versuche zur Berechnung der Stammfunkion fuer die Anzahl der Prozessoren

functions ln,exp;
symbols n,m,epsilon,gamma;

local C = (ln(n-2))^2 / ln(2) + (2 + 1/epsilon) * ln(n-2) 
          + (1/epsilon) * ln(2) - 3* ln(2);
l     t3ZaehlerA =
          (2/m + 2 * ln(2) / (m * ln(m)) ) 
          * ( C / ln(m) - ln(m) / ln(2) - 4 );
l     t3ZaehlerB = 
          (ln(m) + 2 * ln(2)) 
          * (2/(ln(2)*m) - 4/(m* ln(m)));
l     t3Nenner = ( C/ln(m) - ln(m) / ln(2) - 4)^2;
.sort
l     t3Sum3A = t3ZaehlerA / t3Nenner;
l     t3Sum3B = t3ZaehlerB / t3Nenner;
.sort
l     t3All = 2/m + gamma/m + t3Sum3A + t3Sum3B;
* l     t3Zaehler = t3ZaehlerA - t3ZaehlerB;
* l     t3All = 2/m + gamma/m + t3Zaehler / t3Nenner;
print;
.end

