
DEFINITION MODULE LList; (* List of LISTs *)

(* Listen von Listen

   Das Modul baut auf dem Modul 'List' auf. Die Implementierung 
   geht davon aus, dass 'List.tList' ein Zeigertyp ist.
*)

IMPORT List;

TYPE tLList; (* Dieser Typ ist fuer Variablen vom Typ
                'Liste von Listen' zu verwenden. *)

(* Die folgenden Prozeduren entsprechen in ihrer Bedeutung den
   gleichnamigen im Modul 'List', jedoch angepasst auf den 
   Typ 'List.tList' als Listenelemente. *)

PROCEDURE Use(VAR list: tLList);

PROCEDURE InsertBefore(list: tCaLi; item: List.tList);

PROCEDURE InsertBehind(list: tCaLi; item: List.tList);

PROCEDURE Cur(list: tCaLi): List.tList;

PROCEDURE OutCur(list: tCaLi): List.tList;

(* Fuer 'Listen von Listen' koennen weiterhin die Prozeduren/Funk-
   tionen aus dem Modul 'List' verwendet werden, die nicht 
   namensgleich zu den obigen sind.
*)

END LList.

