
DEFINITION MODULE Avl;

(* Datei: avl.def
   Datum: 11.05.92
   
   Aufbau und Verwaltung von AVL-Baeumen
*)

IMPORT Type, Tree;

PROCEDRUE Use(VAR tree: Tree.tTree; type: Type.TypeId);

PROCEDURE Init(VAR tree: Tree.tTree; type: Type.TypeId);

PROCEDURE Insert(tree: Tree.tTree; item: ADDRESS);

PROCEDRUE DelCur(tree: Tree.tTree); (* DELete CURrent *)

PROCEDURE Search(tree: Tree.tTree; item: ADDRESS): ADDRESS;

END Avl.
