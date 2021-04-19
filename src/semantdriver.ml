open Ast
open Sast
open Boolcheck
open Rhandlhand 
open Decs 
 
let check(statements, functions) = 

let symbol_table = get_decs (statements, functions) in


let global_scope = fst symbol_table in


let function_scopes = snd symbol_table in

let check_expr_scope scope = function 
    DecAssign(ty, s, _) -> add_symbol_driver s ty scope 
|   _ -> scope 

in 

let check_stmt_scope scope = function 
    Expr(e) -> check_expr_scope scope e 
|   Dec(ty, s) -> add_symbol_driver s ty scope 
|   _ -> scope 

in

let rec expr scope deepscope  = function 
    IntegerLiteral l -> (Int, SIntegerLiteral l)
|   CharacterLiteral l -> (Char, SCharacterLiteral l)
|   BoolLit l -> (Bool, SBoolLiteral l) 
|   FloatLiteral l -> (Float, SFloatLiteral l)
|   StringLiteral l -> (String, SStringLiteral l) 
|   Noexpr -> (Nah, SNoexpr)
|   ListLit l -> let eval_list = List.map (expr scope deepscope) l in 
                 let rec check_types = function
                    (t1, _) :: [] -> (Array(t1), SListLiteral(eval_list))
                  |	((t1,_) :: (t2,_) :: _) when t1 != t2 ->
	                raise (Failure "List types are inconsistent")
                  | _ :: t -> check_types t
                  | [] -> raise (Failure "listlit became empty") 
                  in check_types eval_list 
|   DictElem(l, s) -> let (t1, e1) = expr scope deepscope l in 
                      let (t2, e2) = expr scope deepscope s in 
                      (Group([t1; t2]), SDictElem((t1, e1), (t2, e2)))
|   DictLit l -> let eval_list = List.map (expr scope deepscope) l in 
                 let rec check_types = function
                    (Group([t1; t2]), _) :: [] -> (Dictionary(t1, t2), SDictLiteral(eval_list))
                  |	((Group([t1; t2]), _) :: (Group([t3; t4]), _) :: _) when t1 != t3 || t2 != t4 ->
	                raise (Failure "Dictionary types are inconsistent")
                  | _ :: t -> check_types t
                  | []     -> raise (Failure "dictlit became empty") 
                  in check_types eval_list  
|   Id l -> (toi scope l, SId l)
|   Binop(e1, op, e2) as e -> 
          let (t1, e1') = expr scope deepscope e1 
          and (t2, e2') = expr scope deepscope e2 in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Mult | Div | Mod when same && t1 = Int   -> Int
          | Add | Sub | Mult | Div | Mod when same && t1 = Float -> Float
          | Equal | Neq            when same               -> Bool
          | Less | Leq | Greater | Geq
                     when same && (t1 = Int || t1 = Float) -> Bool
          | And | Or | Has when same && t1 = Bool -> Bool
          | _ -> raise (
	      Failure ("illegal binary operator " ^
                       string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                       string_of_typ t2 ^ " in " ^ string_of_expr e))
          in (ty, SBinop((t1, e1'), op, (t2, e2')))
|   Unop(uop, e) as ex -> 
          let (t, e') = expr scope deepscope e in
          let ty = match uop with
            Neg | Incr | Decr when t = Int || t = Float -> t
          | Not when t = Bool -> Bool
          | _ -> raise (Failure ("illegal unary operator " ^ 
                                 string_of_uop uop ^ string_of_typ t ^
                                 " in " ^ string_of_expr ex))
          in (ty, SUnop(uop, (t, e')))
|   Assign(s, e) -> 
          let lt = toi scope s 
          and (rt, e') = expr scope deepscope e in
          (check_assign lt rt, SAssign(s, (rt, e')))
|   Deconstruct(l, e) -> (Int, SDeconstruct(l, expr scope deepscope e)) 
|   OpAssign(s, op, e) -> let (t, e1) = expr scope deepscope e in 
                          if t = (toi scope s) then (t, SOpAssign(s, op, (t, e1))) else raise (Failure "types not the same") 
|   DecAssign(ty, l, expr1) -> check_decassign ty l (expr scope deepscope expr1) 
|   Access(e1, e2) -> (Int, SAccess( expr scope deepscope e1, expr scope deepscope e2))  
|   AccessAssign(e1, e2, e3) -> (Int, SAccessAssign( expr scope deepscope e1, expr scope deepscope e2, expr scope deepscope e3)) 
|   Call(fname, args) -> 
                  let eval_list = List.map (expr scope deepscope) args in 
                  let key_func = key_string fname eval_list in  
                  let fd = StringMap.find key_func function_scopes in
                  let param_length = StringMap.cardinal fd.formals.variables in
                  if List.length args != param_length then
                  raise (Failure ("expecting " ^ string_of_int param_length ^ 
                            " arguments in function call" ))
                  else let check_call (_, ft) e = 
                  let (et, e') = expr scope deepscope e in 
                  (check_assign ft et, e')
                  in 
                  let args' = List.map2 check_call (StringMap.bindings fd.formals.variables) args
                  in (fd.ret_typ, SCall(fname, args')) 
|   AttributeCall(e, s, l) -> (Int, SAttributeCall(expr scope deepscope e, s, List.map (expr scope deepscope) l )) 
|   _  -> raise (Failure "expression is not an expression")  

in 

let rec check_stmt scope inloop  = 
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in function 
    Expr e -> SExpr (expr scope inloop e) 
|   Skip e -> if inloop then SSkip (expr scope inloop e) else raise (Failure "skip not in a loop")  
|   Abort e -> if inloop then SAbort (expr scope inloop e) else raise (Failure "abort not in a loop")  
|   Panic e -> SPanic (expr scope inloop e) 
|   If(p, b1, b2) -> SIf(check_bool (expr scope inloop p), check_stmt scope inloop b1, check_stmt scope inloop b2) 
|   While(p, s) -> SWhile(check_bool (expr scope inloop p), check_stmt new_scope true s) 
|   Return _ -> raise (Failure "return outside a function")
|   Block sl -> 
          let rec check_stmt_list blockscope = function
              [Return _ as s] -> [check_stmt blockscope inloop s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list blockscope (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt blockscope inloop s :: check_stmt_list blockscope ss
            | []              -> []
          in SBlock(check_stmt_list (List.fold_left (fun m f -> check_stmt_scope m f) new_scope sl) sl)
|   PretendBlock sl -> SBlock (List.map (check_stmt scope false) sl )

|   Dec(ty, l) -> SDec(ty, l)
|   _  -> raise (Failure "statement is not a statement") 

 in

 let rec check_stmt_func scope inloop ret = 
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in function 
    Expr e -> SExpr (expr scope inloop e) 
|   Skip e -> if inloop then SSkip (expr scope inloop e) else raise (Failure "skip not in a loop") 
|   Abort e -> if inloop then SAbort (expr scope inloop e) else raise (Failure "abort not in a loop") 
|   Panic e -> SPanic (expr scope inloop e) 
|   If(p, b1, b2) -> SIf(check_bool (expr scope inloop p), check_stmt_func scope inloop ret b1, check_stmt_func scope inloop ret b2) 
|   While(p, s) -> SWhile(check_bool (expr scope inloop p), check_stmt_func new_scope true ret s) 
|   Return e -> let (t, e') = expr scope inloop e in 
    if t = ret then SReturn (t, e') 
    else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ ret ^ " in " ^ string_of_expr e)) 
|   Block sl -> 
          let rec check_stmt_list blockscope = function
              [Return _ as s] -> [check_stmt_func blockscope inloop ret s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list blockscope (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt_func blockscope inloop ret s :: check_stmt_list blockscope ss
            | []              -> []
          in SBlock(check_stmt_list (List.fold_left (fun m f -> check_stmt_scope m f) new_scope sl) sl)
|   PretendBlock sl -> SBlock(List.map (check_stmt_func scope false ret) sl )

|   Dec(ty, l) -> SDec(ty, l)
|   _  -> raise (Failure "statement is not a statement")

in
 let return_func = function 
      Function(e) -> e 
  |   _           -> raise (Failure "function return type is flawed") 

  in 

 let check_function ( fd : func_decl ) = 
 
    let key_func = key_string fd.fname fd.formals in 
      let current_function = StringMap.find key_func function_scopes in 
      { styp = fd.typ;
        sfname = fd.fname;
        sformals = fd.formals;
        sbody = match check_stmt_func current_function.locals false (return_func fd.typ) (Block fd.body) with
	    SBlock(sl) -> sl
      | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
        (*List.map (check_stmt_func current_function.locals false fd.typ) fd.body *)

in 

(List.map (check_stmt global_scope false) statements, List.map check_function functions)