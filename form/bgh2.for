
* Datei: bgh2.for

* Test des Algorithmus von Borodin, von zur Gathen und Hopcroft fuer
* 3*3-Matrix

nwrite statistics;
nprint;

s a,b,c,d;

#procedure homogen3()

* Alle homogenen Komponenten mit einem Grad groesser als 3 
* werden eliminiert.

id a?^4              = 0;
id a?^3 * b?         = 0;
id a?^2 * b? *c?     = 0;
id a?^2 * b?^2       = 0;
id a? * b?^3         = 0;
id a? * b? * c?^2    = 0;
id a? * b? * c? * d? = 0;

.sort
#endprocedure


#procedure predivide(reihe, prediv)

* Fuer die Potenzreihe 'reihe' der Form '1-g' wird in 'prediv'
* der Term '1+g+g^2+g^3' zurueckgegeben. Alle homogenen Komponenten mit
* einem Grad groesse als 3 werden eliminiert.

l hilf2= ('reihe' - 1) * (-1);
l 'prediv'= 1 + hilf2 + hilf2 * hilf2 + hilf2 * hilf2 * hilf2;

drop hilf2;
.sort 

#call homogen3{}

.sort

#endprocedure


* Matrizenelemente:

s [a11], [a12], [a13], 
  [a21], [a22], [a23],
  [a31], [a32], [a33];

*****************
* Transformation:
*****************
g [a11,1] = 1 - [a11];  
g [a12,1] = 0 - [a12];
g [a13,1] = 0 - [a13];
g [a21,1] = 0 - [a21];
g [a22,1] = 1 - [a22];
g [a23,1] = 0 - [a23];
g [a31,1] = 0 - [a31];
g [a32,1] = 0 - [a32];
g [a33,1] = 1 - [a33];

* Inverses von [a11,1] nach [a11,1p]:
g [a11,1g] = [a11];
l [a11,1p] = 1 + [a11,1g] 
               + [a11,1g] * [a11,1g] 
               + [a11,1g] * [a11,1g] * [a11,1g];

**********************
* Nullen in 1. Spalte:
**********************

l [factor2,2] = [a21,1] * [a11,1p];
l [a22,2] = [a22,1] - [factor2,2] * [a12,1];
l [a23,2] = [a23,1] - [factor2,2] * [a13,1];
l [factor2,3] = [a31,1] * [a11,1p];
l [a32,2] = [a32,1] - [factor2,3] * [a12,1];
l [a33,2] = [a33,1] - [factor2,3] * [a13,1];

#call homogen3{}

* Inverses von [a22,2] nach [a22,2p]:
#call predivide{[a22,2]|[a22,2p]}

print [a22,2], [a23,2], [a32,2], [a33,2], [a22,2p];
.sort

**********************
* Nullen in 2. Spalte:
**********************

l [a33,3] = [a33,2] - [a32,2] * [a22,2p] * [a23,2];

#call homogen3{}
nprint;
print [a33,3];
.sort

l det = [a11,1] * [a22,2] * [a33,3];
#call homogen3{}
nprint;
print det;

drop [a33,3], [factor2,2], [factor2,3], [a22,2], [a23,2], [a32,2], [a33,2];
drop [a11,1], [a12,1], [a13,1];
drop [a21,1], [a22,1], [a23,1];
drop [a31,1], [a32,1], [a33,1];
drop [a11,1g], [a22,2p];
.sort

s [b11], [b12], [b13], 
  [b21], [b22], [b23], 
  [b31], [b32], [b33];

* Ruecktransformation:

id [a11] = 1 - [b11];
id [a12] = - [b12];
id [a13] = - [b13];

id [a21] = - [b21];
id [a22] = 1 - [b22];
id [a23] = - [b23];

id [a31] = - [b31];
id [a32] = - [b32];
id [a33] = 1 - [b33];

#call homogen3{}
nprint;
print det;

.end
