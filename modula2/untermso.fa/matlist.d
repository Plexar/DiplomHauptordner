
DEFINITION MODULE CaLi; (* CArdLIst*)

(* 
   Listen von ganzen Zahlen (Typ LONGCARD) unter Verwendung
   des Moduls 'List'
*)

TYPE tCaLi;

(* Die folgenden Prozeduren entsprechen in ihrer Bedeutung den
   gleichnamigen im Modul 'List', jedoch angepasst auf den 
   Typ CARDINAL als Listenelemente. *)

PROCEDURE Use(VAR list: tCaLi);

PROCEDURE InsertBefore(list: tCaLi; item: LONGCARD);

PROCEDURE InsertBehind(list: tCaLi; item: LONGCARD);

PROCEDURE Cur(list: tCaLi): LONGCARD;

PROCEDURE OutCur(list: tCaLi): LONGCARD;

(* Fuer 'LONGCARD-Listen' koennen weiterhin die Prozeduren/Funk-
   tionen aus dem Modul 'List' verwendet werden, die nicht 
   namensgleich zu den obigen sind.
*)

END CardList.

