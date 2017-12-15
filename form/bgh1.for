
* Datei: bgh1.for

* Test des Algorithmus von Borodin, von zur Gathen und Hopcroft fuer
* 2*2-Matrix

s [a11],[a12],[a21],[a22];

l m11= 1-[a11];
l m12= 0-[a12];
l m21= 0-[a21];
l m22= 1-[a22];

l M11= (m11-1) *(-1);
l [M11,s] = 1 + M11 + M11 * M11;
l [m22,2]= m22 - m21 * [M11,s] * m12;
l det= m11 * [m22,2];

print;
.end
