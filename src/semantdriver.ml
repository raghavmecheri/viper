open Ast
open Sast
open Boolcheck
open Rhandlhand 
open Decs 
 
let check (statements, functions) = 

(* Gets symbol table of statement scope, and a list of symbol tables with each function's scope *)
let symbol_table = get_decs (statements, functions) in
let global_scope = fst symbol_table in
let function_scopes = snd symbol_table in

(* Verifies that a function has a valid return statement *)
let rec check_return slist ret = match slist with 
    Return _ :: _ -> if ret != Nah then true else raise(Failure "Function of type Nah should not have a return statement") 
  | s :: ss -> ignore(print_endline (string_of_stmt s)); check_return ss ret 
  | [] -> if ret = Nah then true else raise (Failure "Function has an empty body at the highest level but returns (?)") in 


let check_expr_scope scope = function 
    DecAssign(ty, s, _) -> add_symbol_driver s ty scope 
  | _ -> scope in 

let check_stmt_scope scope = function 
    Expr(e) -> check_expr_scope scope e 
  | Dec(ty, s) -> add_symbol_driver s ty scope 
  | _ -> scope in

(* Bug fix for function return type mismatching *)
let return_func = function 
    Function(e) -> e 
  | e           -> e 
  | _           -> raise (Failure "function return type is flawed") in 

(* Driver for semantically checking expressions *)
let rec expr scope deepscope  = function 
    IntegerLiteral l -> (Int, SIntegerLiteral l)
  | CharacterLiteral l -> (Char, SCharacterLiteral l)
  | BoolLit l -> (Bool, SBoolLiteral l) 
  | FloatLiteral l -> (Float, SFloatLiteral l)
  | StringLiteral l -> (String, SStringLiteral l) 
  | Noexpr -> (Nah, SNoexpr)
  | ListLit l -> let eval_list = List.map (expr scope deepscope) l in 
      let rec check_types = function
          [] -> (Array(Nah), SListLiteral([]))
        | (t1, _) :: [] -> (Array(t1), SListLiteral(eval_list))
        |	((t1,_) :: (t2,_) :: _) when t1 != t2 ->  
	      raise (Failure ("Error: list types " ^ string_of_typ t1 ^ " and " ^ string_of_typ t2 ^ " are inconsistent"))
        | _ :: t -> check_types t
      in check_types eval_list 
  | DictElem(l, s) -> let (t1, e1) = expr scope deepscope l in 
      let (t2, e2) = expr scope deepscope s in 
      (Group([t1; t2]), SDictElem((t1, e1), (t2, e2)))
  | DictLit l -> let eval_list = List.map (expr scope deepscope) l in 
      let rec check_types = function
          [] -> (Dictionary(Nah, Nah), SDictLiteral([]))
        | (Group([t1; t2]), _) :: [] -> (Dictionary(t1, t2), SDictLiteral(eval_list))
        |	((Group([t1; t2]), _) :: (Group([t3; t4]), _) :: _) when t1 != t3 || t2 != t4 ->  
	       raise (Failure "Dictionary types are inconsistent")
        | _ :: t -> check_types t
      in check_types eval_list  
  | Id l -> (toi scope l, SId l)
  | Binop(e1, op, e2) as e -> 
      let (t1, e1') = expr scope deepscope e1 
      and (t2, e2') = expr scope deepscope e2 in
      (* All binary operators require operands of the same type *)
      let same = t1 = t2 in
      (* Determine expression type based on operator and operand types *)
      let ty = match op with
          Add | Sub | Mult | Div | Mod when same && t1 = Int   -> Int
        | Add | Sub | Mult | Div | Mod when same && t1 = Float -> Float
        | Equal | Neq                  when same               -> Bool
        | Less | Leq | Greater | Geq   when same && (t1 = Int || t1 = Float) -> Bool
        | And | Or | Has               when same && t1 = Bool -> Bool
        | _ -> raise (Failure ("illegal binary operator " ^
                      string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                      string_of_typ t2 ^ " in " ^ string_of_expr e))
      in (ty, SBinop((t1, e1'), op, (t2, e2')))
  | Unop(uop, e) as ex -> 
      let (t, e') = expr scope deepscope e in
      let ty = match uop with
          Neg | Incr | Decr when t = Int || t = Float -> t
        | Not when t = Bool -> Bool
        | _ -> raise (Failure ("illegal unary operator " ^ 
                              string_of_uop uop ^ string_of_typ t ^
                              " in " ^ string_of_expr ex))
      in (ty, SUnop(uop, (t, e')))
  | Assign(s, e) -> 
      let lt = toi scope s 
      and (rt, e') = expr scope deepscope e in
      (check_assign lt rt, SAssign(s, (rt, e')))
  | Deconstruct(l, e) -> (****** Work in progress, discrepancy between group and list literals ******)
      let (e_typ, _) = expr scope deepscope e in
      let _ = match e_typ with
          Group(typs) -> typs
        | _ -> raise (Failure ("Error: deconstruct requires a Group, but was given " ^ string_of_typ e_typ ^ " " ^ string_of_expr e))
      in (Int, SDeconstruct(l, expr scope deepscope e)) 
  | OpAssign(s, op, e) -> let (t, e1) = expr scope deepscope e in 
      if t = (toi scope s) then (t, SOpAssign(s, op, (t, e1))) else raise (Failure "types not the same") 
  | DecAssign(ty, l, expr1) -> check_decassign ty l (expr scope deepscope expr1) 
  | Access(e1, e2) -> 
      let (t1, e1') = expr scope deepscope e1
      and (t2, e2') = expr scope deepscope e2 in 
      (match t1 with
          Array(t) when t2 = Int -> (t, SAccess((t1, e1'), (t2, e2')))
        | Array(_) -> raise (Failure ("Error: Integer required for Array access, given type " ^ string_of_typ t2))
        | Dictionary((key_t, _)) when t2 = key_t -> (key_t, SAccess((t1, e1'), (t2, e2')))
        | Dictionary((key_t, _)) -> raise (Failure ("Error: " ^ string_of_typ key_t ^ " required for Dictionary access, given type " ^ string_of_typ t2))
        | _ -> raise (Failure ("Error: access not invalid for type " ^ string_of_typ t1)))
  | AccessAssign(e1, e2, e3) ->       
      let (t1, e1') = expr scope deepscope e1
      and (t2, e2') = expr scope deepscope e2
      and (t3, e3') = expr scope deepscope e3 in
      (match t1 with
          Dictionary((key_t, val_t)) when t3 = val_t ->
            if t2 = key_t then (t3, SAccessAssign((t1, e1'), (t2, e2'), (t3, e3')))
            else raise (Failure ("Error: key type " ^ string_of_typ key_t ^ " expected for Dictionary access, but " ^
                                string_of_typ t2 ^ " given in expression " ^ string_of_expr e2))
        | Dictionary((_, val_t)) -> raise (Failure ("Error: value type " ^ string_of_typ t3 ^ " cannot be included in Dictionary " ^ 
                                            string_of_expr e1 ^ " with value type " ^ string_of_typ val_t))
        | Array(t) when t = t3 -> 
            if t2 = Int then (t3, SAccessAssign((t1, e1'), (t2, e2'), (t3, e3')))
            else raise (Failure ("Error: integer expected for Array access, but " ^ string_of_typ t2 ^ 
                                " given in expression " ^ string_of_expr e2))
        | Array(t) -> raise (Failure ("Error: type " ^ string_of_typ t3 ^ " cannot be included in Array " ^ string_of_expr e1 ^ 
                                      " with type " ^ string_of_typ t))
        | _ -> raise (Failure ("Error: expression " ^ string_of_expr e1 ^ " has type " ^ string_of_typ t1 ^
                                ", expected type Array")))
  | Call(fname, args) -> 
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
      in (return_func fd.ret_typ, SCall(fname, args')) 
  | AttributeCall(e, fname, args) -> 
      let eval_list = List.map (expr scope deepscope) args in
      let key_func = key_string fname eval_list in  
      print_endline key_func;
      let fd = StringMap.find key_func function_scopes in
      let param_length = StringMap.cardinal fd.formals.variables in
      if List.length args + 1 != param_length then raise (Failure ("expecting " ^ string_of_int param_length ^ " arguments in function call"))
      else let check_call (_, ft) e =  
      let (et, e') = expr scope deepscope e in 
      (check_assign ft et, e') in 
      let args' = List.map2 check_call (StringMap.bindings fd.formals.variables) args
      in (return_func fd.ret_typ, SAttributeCall(expr scope deepscope e, fname, args')) 
  | Ternop(_,_,_) -> raise (Failure "Ternop slipped through... BLAME RATGHAV")
  | _  -> raise (Failure "expression is not an expression")  
in 

(* Driver for semantically checking statements *)
let rec check_stmt scope inloop = 
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in function 
    Expr e -> SExpr (expr scope inloop e) 
  | Skip e -> if inloop then SSkip (expr scope inloop e) else raise (Failure "skip not in a loop")  
  | Abort e -> if inloop then SAbort (expr scope inloop e) else raise (Failure "abort not in a loop")  
  | Panic e -> SPanic (expr scope inloop e) 
  | If(p, b1, b2) -> SIf(check_bool (expr scope inloop p), check_stmt scope inloop b1, check_stmt scope inloop b2) 
  | While(p, s) -> SWhile(check_bool (expr scope inloop p), check_stmt new_scope true s) 
  | Return _ -> raise (Failure "return outside a function")
  | Block sl -> 
      let rec check_stmt_list blockscope = function
          [Return _ as s] -> [check_stmt blockscope inloop s]
        | Return _ :: _   -> raise (Failure "nothing may follow a return")
        | Block sl :: ss  -> check_stmt_list blockscope (sl @ ss) (* Flatten blocks *)
        | s :: ss         -> check_stmt blockscope inloop s :: check_stmt_list blockscope ss
        | []              -> []
      in SBlock(check_stmt_list (List.fold_left (fun m f -> check_stmt_scope m f) new_scope sl) sl)
  | PretendBlock sl -> SBlock (List.map (check_stmt scope false) sl )
  | Dec(ty, l) -> SDec(ty, l)
  | _  -> raise (Failure "statement is not a statement") 
in

(* Check statements within functions *)
let rec check_stmt_func scope inloop ret = 
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in function 
    Expr e -> SExpr (expr scope inloop e) 
  | Skip e -> if inloop then SSkip (expr scope inloop e) else raise (Failure "skip not in a loop") 
  | Abort e -> if inloop then SAbort (expr scope inloop e) else raise (Failure "abort not in a loop") 
  | Panic e -> SPanic (expr scope inloop e) 
  | If(p, b1, b2) -> SIf(check_bool (expr scope inloop p), check_stmt_func scope inloop ret b1, check_stmt_func scope inloop ret b2) 
  | While(p, s) -> SWhile(check_bool (expr scope inloop p), check_stmt_func new_scope true ret s) 
  | Return e -> let (t, e') = expr scope inloop e in 
      if t = ret then SReturn (t, e') 
      else raise (
      Failure ("return gives " ^ string_of_typ t ^ " expected " ^
        string_of_typ ret ^ " in " ^ string_of_expr e)) 
  | Block sl -> 
      let rec check_stmt_list blockscope = function
          [Return _ as s] -> [check_stmt_func blockscope inloop ret s]
        | Return _ :: _   -> raise (Failure "nothing may follow a return")
        | Block sl :: ss  -> check_stmt_list blockscope (sl @ ss) (* Flatten blocks *)
        | s :: ss         -> check_stmt_func blockscope inloop ret s :: check_stmt_list blockscope ss
        | []              -> []
      in SBlock(check_stmt_list (List.fold_left (fun m f -> check_stmt_scope m f) new_scope sl) sl)
  | PretendBlock sl -> SBlock(List.map (check_stmt_func scope false ret) sl )
  | Dec(ty, l) -> SDec(ty, l)
  | _  -> raise (Failure "statement is not a statement")
in

(* Check function declarations *)
let check_function (fd : func_decl) = 
  if check_return fd.body (return_func fd.typ) then 
    let key_func = key_string fd.fname fd.formals in 
      let current_function = StringMap.find key_func function_scopes in 
      { styp = return_func fd.typ;
        sfname = fd.fname;
        sformals = fd.formals;
        sbody = match check_stmt_func current_function.locals false (return_func fd.typ) (Block fd.body) with
	          SBlock(sl) -> sl
          | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
    else raise (Failure "there is not return statement at the highest level of the function")
in 

(* Collect the SAST of semantically-check statements and functions *)
let sstatements = List.map (check_stmt global_scope false) statements in
let sfuncs = List.map check_function functions in

(* Aggregate statements into an implicit main function if one isn't already defined *)
let rec has_main sfuncs = match sfuncs with
    [] -> false
  | sfd :: _ when sfd.sfname = "main" && sfd.styp = Int -> true
  | sfd :: _ when sfd.sfname = "main" -> raise (Failure ("Error: function main must return type Int, not type " ^ string_of_typ sfd.styp))
  | _ :: tail -> has_main tail in

let updated_sfuncs = if has_main sfuncs then sfuncs else
  { styp = Int;
    sfname = "main";
    sformals = [];
    sbody = List.rev sstatements;
  } :: sfuncs in

(sstatements, updated_sfuncs)
