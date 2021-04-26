open Ast
open Sast
open Boolcheck
open Rhandlhand 
open Decs 
open Semant
 
let check (statements, functions) = 

(* Gets symbol table of statement scope, and a list of symbol tables with each function's scope *)
let symbol_table = get_decs (statements, functions) in
let global_scope = fst symbol_table in
let function_scopes = snd symbol_table in

(* Verifies that a function has a valid return statement *)
let rec check_return slist ret = match slist with 
    Return _ :: _ -> if ret != Nah then true else raise(Failure "Function of type Nah should not have a return statement") 
  | s :: ss -> check_return ss ret 
  | [] -> if ret = Nah then true else raise (Failure "Function has an empty body at the highest level but returns (?)") in 


let check_expr_scope scope = function 
    DecAssign(ty, s, _) -> add_symbol_driver s ty scope 
  | _ -> scope in 

let rec check_stmt_scope scope = function 
    Expr(e) -> check_expr_scope scope e 
  | Dec(ty, s) -> add_symbol_driver s ty scope 
  | While(p, _, _) -> check_expr_scope scope p
  | If(p, _, _) -> check_expr_scope scope p
  | PretendBlock(sl) -> List.fold_left (fun m f -> check_stmt_scope m f) scope sl
  | _ -> scope in

(* Bug fix for function return type mismatching *)
let return_func = function 
    Function(e) -> e 
  | e           -> e 
  | _           -> raise (Failure "function return type is flawed") in 

let type_check t1 t2 = 
  let type1 = match t1 with 
  Group([ta; tb]) -> (ta, tb) 
| _ -> (t1, t1) in 
  let type2 = match t2 with 
  Group([tc; td]) -> (tc, td) 
| _ -> (t2, t2) in
(fst type1 = fst type2) && (snd type1 = snd type2)  

in

(* Driver for semantically checking expressions *)
let rec expr scope deepscope e = match e with
    IntegerLiteral l -> (Int, SIntegerLiteral l)
  | CharacterLiteral l -> (Char, SCharacterLiteral l)
  | BoolLit l -> (Bool, SBoolLiteral l) 
  | FloatLiteral l -> (Float, SFloatLiteral l)
  | StringLiteral l -> (String, SStringLiteral l) 
  | Noexpr -> (Nah, SNoexpr)
  | ListLit l -> let eval_list = List.map (expr scope deepscope) l in 
      let rec check_types = function
          [] -> (Nah, SDictLiteral([]))
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
        | (Group([t1; t2]), _) :: [] -> (Dictionary(t1, t2), SDictLiteral(eval_list))
        |	((Group([t1; t2]), _) :: (Group([t3; t4]), _) :: _) when not ((type_check t1 t3)) || not ((type_check t2 t4)) (*t1 != t3 || t2 != t4 *)->  
	       raise (Failure (string_of_typ t1 ^ string_of_typ t2 ^ string_of_typ t3 ^ string_of_typ t4))
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
  | DecAssign(ty, l, expr1) -> (match ty, l, expr1 with
        (Array(t), n, ListLit([])) -> (Array(t), SDecAssign(Array(t), n, (Array(t), SListLiteral([]))))
      | (Dictionary(t1, t2), n, DictLit([])) -> (Dictionary(t1, t2), SDecAssign(Dictionary(t1, t2), n, (Dictionary(t1, t2), SDictLiteral([]))))
      | _ -> check_decassign ty l (expr scope deepscope expr1) )
  | Access(e1, e2) -> 
      let (t1, e1') = expr scope deepscope e1
      and (t2, e2') = expr scope deepscope e2 in 
      (match t1 with
          Array(t) when t2 = Int -> (t, SAccess((t1, e1'), (t2, e2')))
        | Array(_) -> raise (Failure ("Error: integer required for array access, given type " ^ string_of_typ t2))
        | Dictionary((key_t, value_t)) when t2 = key_t -> (value_t, SAccess((t1, e1'), (t2, e2')))
        | Dictionary((key_t, _)) -> raise (Failure ("Error: " ^ string_of_typ key_t ^ " required for dictionary access, given type " ^ string_of_typ t2))
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
      let fd = StringMap.find key_func function_scopes in
      let param_length = StringMap.cardinal fd.formals.variables in
      if List.length args + 1 != param_length then raise (Failure ("expecting " ^ string_of_int param_length ^ " arguments in function call"))
      else let check_call (_, ft) e =  
      let (et, e') = expr scope deepscope e in 
      (check_assign ft et, e') in 
      let args' = List.map2 check_call (StringMap.bindings fd.formals.variables) args
      in (return_func fd.ret_typ, SAttributeCall(expr scope deepscope e, fname, args')) 
  (*
  | Ternop(e1, e2, e3) -> 
      let (e1t, e1') = expr scope deepscope e1 in
      if e1t != Bool then raise (Failure "Error: expected bool in first expression of ternary operator") else
      let (e2t, e2') = expr scope deepscope e2 
      and (e3t, e3') = expr scope deepscope e3 in
      if e2t != e3t then raise (Failure ("Error: ternary operator types " ^ string_of_typ e2t ^ " and " ^ string_of_typ e3t ^ " do not match"))
      else (e2t, STernop((e1t, e1'), (e2t, e2'), (e3t, e3'))) *)
  | _  -> raise (Failure "expression is not an expression")  
in 

(* Driver for semantically checking statements *)
let rec check_stmt scope inloop s =
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in match s with 
    Expr e -> SExpr (expr scope inloop e) 
  | Skip e -> if inloop then SSkip (expr scope inloop e) else raise (Failure "skip not in a loop")  
  | Abort e -> if inloop then SAbort (expr scope inloop e) else raise (Failure "abort not in a loop")  
  | Panic e -> SPanic (expr scope inloop e) 
  | If(p, b1, b2) as i -> 
      let scope = get_expr_decs scope p in
      let pred = check_bool (expr scope inloop p) 
      and t = check_stmt scope inloop b1
      and f = check_stmt scope inloop b2 in SIf(pred, t, f) 
  | While(p, s, inc) -> 
      let scope = get_expr_decs scope p in
      let pred = check_bool (expr scope inloop p)
      and loop = check_stmt scope true s in SWhile(pred, loop, check_stmt scope inloop inc) 
  | For(e1, e2, e3, s) -> raise (Failure ("Error: nested for loops currently broken"))
  | Return _ -> raise (Failure "return outside a function")
  | Block sl -> 
      let rec check_stmt_list blockscope = function
          [Return _ as s] -> [check_stmt blockscope inloop s]
        | Return _ :: _   -> raise (Failure "nothing may follow a return")
        (*| Block s :: ss   -> check_stmt_list blockscope (s @ ss)  Flatten blocks 
        | PretendBlock sl :: ss -> check_stmt_list blockscope (sl @ ss)  Flatten blocks *)
        | s :: ss         -> check_stmt blockscope inloop s :: check_stmt_list blockscope ss 
        | [] -> []
      in SBlock(check_stmt_list (List.fold_left (fun m f -> check_stmt_scope m f) new_scope sl) sl)
  | PretendBlock sl -> 
         SBlock(List.map (check_stmt scope inloop) sl)
  | Dec(ty, l) -> SDec(ty, l)
  | _ as s -> raise (Failure ("statement " ^ string_of_stmt s ^ " is not a statement"))
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
  | While(p, s, inc) -> SWhile(check_bool (expr scope inloop p), check_stmt_func new_scope true ret s, check_stmt scope inloop inc) 
  | Return e -> let (t, e') = expr scope inloop e in 
      if t = ret then SReturn (t, e') 
      else raise (
      Failure ("return gives " ^ string_of_typ t ^ " expected " ^
        string_of_typ ret ^ " in " ^ string_of_expr e)) 
  | Block sl -> 
      let rec check_stmt_list blockscope = function
          [Return _ as s] -> [check_stmt_func blockscope inloop ret s]
        | Return _ :: _   -> raise (Failure "nothing may follow a return")
        (*| Block sl :: ss  -> check_stmt_list blockscope (sl @ ss)  Flatten blocks 
        | PretendBlock sl :: ss -> check_stmt_list blockscope (sl @ ss)  Flatten blocks *)
        | s :: ss         -> check_stmt_func blockscope inloop ret s :: check_stmt_list blockscope ss
        | []              -> []
      in SBlock(check_stmt_list (List.fold_left (fun m f -> check_stmt_scope m f) new_scope sl) sl)
  | PretendBlock sl -> 
      SBlock(List.map (check_stmt_func scope inloop ret) sl)
  | Dec(ty, l) -> SDec(ty, l)
  | _ as s -> raise (Failure ("statement " ^ string_of_stmt s ^ " is not a statement"))
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
