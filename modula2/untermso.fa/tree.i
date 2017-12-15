
IMPLEMENTATION MODULE Tree;

(*   Allgemeine Verwaltung von n-aeren Baeumen
   
        ( Erklaerungen im Definitionsmodul )
*)

IMPORT Type;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM SYSTEM IMPORT TSIZE, ADDRESS;
FROM InOut IMPORT WriteLn, WriteString;

CONST MaxSucc = 2; 
      (* maximale Anzahl der Nachfolger eines Knotens *)

TYPE tSuccNum = [1 .. MaxSucc];
     tNode = POINTER TO tNodeRec;
     tNodeRec = RECORD 
                    succ: ARRAY tSuccNum OF tNode;
                        (* Nachfolger des Knotens *)
                    pred: tNode;
                        (* Vorgaenger des Knotens;
                           NIL: Knoten ist Wurzel *)
                    value: ADDRESS;
                END;
     tTree = POINTER TO tTreeRec;
     tTreeRec = RECORD
                    root: tNode; (* Wurzel *)
                    cur : tNode; (* aktueller Knoten *)
                    type: Type.Id;
                    NumSucc: tSuccNum
                        (* maximale Anzahl der Nachfolger
                           eines Knotens *)
                END;

PROCEDURE Use(VAR tree: tTree; successors: CARDINAL; type: Type.Id);
BEGIN
    ALLOCATE(tree, TSIZE(tTree));
    tree^.root:= NIL; 
    tree^.cur:= NIL;
    tree^.type:= type;
    tree^.NumSucc:= successors;
END Use;

PROCEDURE DontUse(VAR tree: tTree);
BEGIN
    Empty(tree);
    DEALLOCATE(tree,0);
    tree:= NIL
END DontUse;

PROCEDURE Init(tree: tTree; successors: CARDINAL; type: Type.Id); 
BEGIN
    Empty(tree);
    tree^.type:= type;
    tree^.NumSucc:= successors
END Init;

PROCEDURE rEmpty(tree: tTree; VAR node: tNode); (* Recursive EMPTY *)
(* Der Teilbaum von 'tree', dessen Wurzel 'node' ist, wird
   geloescht. *)
VAR i: CARDINAL;
BEGIN
    IF node # NIL THEN
        FOR i:= 1 TO tree^.NumSucc DO
            rEmpty(tree,node^.succ[i]);
            Type.DelI(tree^.type, node^.value);
            DEALLOCATE(node, 0);
            node:= NIL
        END
    END
END rEmpty;

PROCEDURE Empty(tree: tTree);
BEGIN
    rEmpty(tree,tree^.root);
    tree^.cur:= NIL
END Empty;

PROCEDURE rSize(node: tNode): CARDINAL;
(* Das Funktionsergebnis ist die Groesse des Teilbaumes, dessen
   Wurzel 'node' ist. *)
VAR erg,i: CARDINAL;
BEGIN
    erg:= 0;
    IF node # NIL THEN
        FOR i:= 1 TO MaxSucc DO
            erg:= erg + rSize(node^.succ[i])
        END
    END;
    RETURN erg;
END rSize;

PROCEDURE Size(tree: tTree): CARDINAL;
BEGIN
    RETURN rSize(tree^.root)
END Size;

(***********************************************************)
(* Prozeduren, die sich auf den aktuellen Knoten beziehen: *)

PROCEDURE Cur(tree: tTree): ADDRESS; (* CURrent *)
BEGIN
    RETURN tree^.cur^.value
END Cur;

PROCEDURE ToRoot(tree: tTree);
BEGIN
    tree^.cur:= tree^.root
END ToRoot;

PROCEDURE Down(tree: tTree; succ: CARDINAL);
BEGIN
    IF SuccPres(tree,succ) THEN
        tree^.cur:= tree^.cur^.succ[succ]
    ELSE
        WriteLn;
        WriteString("*** Tree.Down:                 ***");
        WriteLn;
        WriteString("*** Nachfolger existiert nicht ***");
        WriteLn;
        HALT
    END
END Down;

PROCEDURE Up(tree: tTree);
BEGIN
    IF tree^.cur^.pred # NIL THEN
        tree^.cur:= tree^.cur^.pred
    ELSE
        WriteLn;
        WriteString("*** Tree.Up:                   ***");
        WriteLn;
        WriteString("*** Vorgaenger existiert nicht ***");
        WriteLn;
        HALT
    END
END Up;

PROCEDURE AtRoot(tree: tTree): BOOLEAN;
BEGIN
    IF tree^.cur^.pred = NIL THEN
        RETURN TRUE
    END;
    RETURN FALSE
END AtRoot;

PROCEDURE AtLeaf(tree: tTree): BOOLEAN;
VAR i: CARDINAL;
BEGIN
    FOR i:= 1 TO tree^.NumSucc DO
        IF SuccPres(tree,i) THEN
            RETURN FALSE
        END
    END;
    RETURN TRUE
END AtLeaf;

PROCEDURE CheckCurrent(t: tTree; calling: ARRAY OF CHAR);
(* Falls der aktuelle Knoten in 't' undefiniert ist, wird
   eine Fehlermeldung ausgegeben. *)
BEGIN
    IF t^.cur = NIL THEN
        WriteLn;
        WriteString("*** Tree."); 
        WriteString(calling); WriteString(" ...");
        WriteLn;
        WriteString("*** Der aktuelle Knoten ist undefiniert. ***");
        WriteLn;
        HALT
    END
END CheckCurrent;

       (* SUCCessor is PRESent *)
PROCEDURE SuccPres(tree: tTree; succ: CARDINAL): BOOLEAN;
BEGIN
    CheckCurrent(tree,"SuccPres");
    RETURN tree^.cur^.succ[succ] # NIL
END SuccPres;

PROCEDURE GetPos(tree: tTree): ADDRESS; (* GET POSition *)
BEGIN
    RETURN tree^.cur
END GetPos;

PROCEDURE SetPos(tree: tTree; pos: ADDRESS); (* SET POSition *)
BEGIN
    tree^.cur:= pos;
    WHILE NOT AtRoot(tree) DO
       Up(tree)
    END;
    IF tree^.root # tree^.cur THEN
        WriteLn;
        WriteString("*** Tree.SetPos:                          ***");
        WriteLn;
        WriteString("*** Die angegebene Position befindet sich ***");
        WriteLn;
        WriteString("*** nicht im angegebenen Baum.            ***");
        WriteLn;
    END;
    tree^.cur:= pos;    
END SetPos;

PROCEDURE CheckSuccFree(t: tTree; succ: CARDINAL; 
                        calling: ARRAY OF CHAR);
(* Falls der Nachfolger Nummer 'succ' des aktuellen
   Knotens im Baum 't' bereits vorhanden ist, 
   erfolgt eine Fehlermeldung. *)
BEGIN
    IF t^.cur^.succ[succ] # NIL THEN
        WriteLn;
        WriteString("*** Tree.");
        WriteString(calling); WriteString(" ...");
        WriteString("*** Der angesprochene Nachfolger des ***");
        WriteLn;
        WriteString("*** aktuellen Knotens ist bereits    ***");
        WriteLn;
        WriteString("*** vorhanden.                       ***");
        WriteLn;
        HALT
    END
END CheckSuccFree;

PROCEDURE NewLeaf(tree: tTree; item: ADDRESS; num: CARDINAL);
VAR leaf: tNode;
    i   : CARDINAL;
BEGIN
    (* pruefe Konsistenz des Baumes: *)
    IF (tree^.root = NIL) AND (tree^.cur # NIL) THEN
        WriteLn;
        WriteString("*** Tree.NewLeaf:          ***"); WriteLn;
        WriteString("*** aktueller Knoten nicht ***"); WriteLn;
        WriteString("*** im angegebenen Baum    ***"); WriteLn;
        HALT
    END;

    (* lege Blatt an: *)
    ALLOCATE(leaf,TSIZE(tNodeRec));
    leaf^.pred:= tree^.cur;
    FOR i:= 1 TO MaxSucc DO
        leaf^.succ[i]:= NIL
    END;
    leaf^.value:= item;

    (* fuege Blatt ein: *)
    IF tree^.root = NIL THEN
        tree^.root:= leaf
    ELSE
        CheckCurrent(tree,"NewLeaf");
        CheckSuccFree(tree,num,"NewLeaf");

        tree^.cur^.succ[num]:= leaf;
        tree^.cur:= leaf
    END
END NewLeaf;

PROCEDURE DelCur(tree: tTree);
VAR item: ADDRESS;
BEGIN
    item:= OutCur(tree);
    Type.DelI(tree^.type, item);
END DelCur;    
    
PROCEDURE GetSuccNum(tree: tTree): CARDINAL;
(* Das Funktionsergebnis ist die Nachfolgernummer, die 
   fuer den aktuellen Knoten in dessen Vorgaengerknoten
   gespeichert ist. Null als Funktionsergebnis gibt an,
   dass kein Vorgaenger vorhanden ist.  *)
VAR 
    p: tNode; (* Vorgaener von tree^.cur *)
    i: CARDINAL;
BEGIN
    CheckCurrent(tree,"GetSuccNum");
    p:= tree^.cur^.pred;
    IF p = NIL THEN 
        RETURN 0
    ELSE
        FOR i:= 1 TO tree^.NumSucc DO
            IF p^.succ[i] = tree^.cur THEN
               RETURN i
            END
        END
    END
END GetSuccNum;

PROCEDURE OutCur(tree: tTree): ADDRESS;
VAR 
    item: ADDRESS;
    hilf: tNode;
BEGIN
    IF (tree^.root = NIL) AND (tree^.cur # NIL) THEN
        WriteLn;
        WriteString("*** Tree.OutCur:           ***"); WriteLn;
        WriteString("*** aktueller Knoten nicht ***"); WriteLn;
        WriteString("*** im angegebenen Baum    ***"); WriteLn;
        HALT
    END;

    IF AtLeaf(tree) THEN
        item:= tree^.cur^.value;
        IF tree^.root = tree^.cur THEN
            tree^.root:= NIL
        ELSE 
            tree^.cur^.pred^.succ[GetSuccNum(tree)]:= NIL
        END;
        hilf:= tree^.cur;
        tree^.cur:= tree^.cur^.pred;
        DEALLOCATE(tree^.cur, 0)
    ELSE
        WriteLn;
        WriteString("*** Tree.OutCur:                        ***");
        WriteLn;
        WriteString("*** Der aktuelle Knoten ist kein Blatt. ***");
        WriteLn;
        HALT
    END;
    RETURN item
END OutCur;

PROCEDURE CheckTypes(t1,t2: tTree; calling: ARRAY OF CHAR);
(* Falls 't1' und 't2' nicht kompatibel sind wird eine 
   Fehlermeldung ausgegeben. *)
BEGIN
    IF (t1^.type # t2^.type) OR
       (t1^.NumSucc # t2^.NumSucc) 
    THEN
        WriteLn;
        WriteString("*** Tree.");
        WriteString(calling); WriteString(" ...");
        WriteLn;
        WriteString("*** Die angegebenen Baeume besitzen     ***");
        WriteLn;
        WriteString("*** unterschiedliche Typen oder         ***");
        WriteLn;
        WriteString("*** unterschiedlichen Verzweigungsgrad. ***");
        WriteLn;
        HALT
    END
END CheckTypes;

PROCEDURE UnHook(tree, unhooked: tTree);
BEGIN
    CheckTypes(tree,unhooked,"UnHook");
    IF unhooked^.root # NIL THEN
        WriteLn;
        WriteString("*** Tree.UnHook:                 ***");
        WriteLn;
        WriteString("*** Der Zielbaum ist nicht leer. ***");
        WriteLn;
        HALT
    END;
    CheckCurrent(tree,"UnHook (im Quellbaum)");

    IF tree^.cur = tree^.root THEN
        tree^.root:= NIL
    ELSE
        tree^.cur^.pred^.succ[GetSuccNum(tree)]:= NIL
    END;
    unhooked^.root:= tree^.cur;
    tree^.cur:= tree^.cur^.pred;
    unhooked^.root^.pred:= NIL
END UnHook;

PROCEDURE Hook(tree, ToHook: tTree; succ: CARDINAL);
BEGIN
    CheckTypes(tree,ToHook,"Hook");
    IF tree^.root = NIL THEN
        tree^.root:= ToHook^.root;
    ELSE
        CheckCurrent(tree,"Hook (im Zielbaum)");
        CheckSuccFree(tree,succ,"Hook (im Zielbaum)");
        tree^.cur^.succ[succ]:= ToHook^.root;
        ToHook^.root^.pred:= tree^.cur
    END;
    ToHook^.root:= NIL;
    ToHook^.cur:= NIL
END Hook;

END Tree.
