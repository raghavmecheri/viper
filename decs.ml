(* * * * *
   This file semantically checks all variable and function declarations in the AST.
   Duplicate variables, nah variable declarations, and function declarations
   with the same parameters throw errors.
   A scoped symbol table mapping variable names to their types is returned, along with  
   a mapping of functions to their scoped formal and local variables.
 * * * * *)

open Ast

module StringMap = Map.Make(String)

(* scope table has its own scoped variables and a pointer to its parent scope*)
type scope_table = {
  variables : typ StringMap.t;
  parent : scope_table option;
}

(* func table has a return type, a scope to its formal arguments, and a scope to its locals *)
type func_table = {
  formals : scope_table;
  locals : scope_table;
  ret_typ : typ;
}

(* toi checks the variables of a scope table for s, if not exist, checks the parent*)
let rec toi scope s =
  if StringMap.mem s scope.variables then
    StringMap.find s scope.variables 
  else match scope.parent with
      Some(parent) -> toi parent s 
    | _ -> raise (Failure "Variable not found") 

(* used to turn arg to string to check in scope *)
let rec string_of_params params = match params with
    (typ, _) :: [] -> string_of_typ typ
  | (typ, _) ::  p -> string_of_typ typ ^ ", " ^ string_of_params p
  | _              -> "" 
and key_string name params = name ^ " (" ^ string_of_params params ^ ")"

(* checks to see if a variable is already defined in this scope or its parent
      : raises an error if var already declared
   question: does this mean a global and local can't share same name?
   note: this is what causes the 'var not found' printing in SAST pprint*)
let rec is_valid_dec name scope = 
  if StringMap.mem name scope.variables then
    raise (Failure ("Error: variable " ^ name ^ " is already defined"))
  else match scope.parent with
      Some(parent) -> print_endline name; is_valid_dec name parent
    | _ -> print_endline (name ^ " not found"); true

(* adds a variable to a scope table *)
let add_symbol name ty scope = match ty with
    Nah -> raise (Failure ("Error: variable " ^ name ^ " declared with type nah"))
  | _  -> if is_valid_dec name scope then {
      variables = StringMap.add name ty scope.variables;
      parent = scope.parent;
    } else scope (* Never enters else clause bc is_valid_dec raises Failure, but still needed to avoid type error *)

(* used to add symbols from inside semant.ml *)
let add_symbol_driver name ty scope = match ty with
    Nah -> raise (Failure ("Error: variable " ^ name ^ " declared with type nah"))
  | _  ->  {
      variables = StringMap.add name ty scope.variables;
      parent = scope.parent;
    } 

let get_bind_decs scope bind = 
  let ty, name = bind in add_symbol name ty scope

(* recursively goes through expressions looking for declarations, 
      adding any new declarations to scope
   note: new_scope is not used in this function, is it needed?
*)
let rec get_expr_decs scope expr = 
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in match expr with
    Binop(e1, _, e2) -> 
    let expr_list = [e1; e2] in List.fold_left get_expr_decs scope expr_list
  | Unop(_, e) -> get_expr_decs scope e
  | Ternop(e1, e2, e3) -> 
    let expr_list = [e1; e2; e3] in List.fold_left get_expr_decs scope expr_list
  | OpAssign(_, _, e)
  | Assign(_, e) -> get_expr_decs scope e
  | DecAssign(ty, name, e) -> 
    let updated_scope = get_expr_decs scope e in add_symbol name ty updated_scope
  | Deconstruct(b_list, e) -> 
    let updated_scope = List.fold_left get_bind_decs scope b_list in get_expr_decs updated_scope e
  | Access(arr, index) ->
    let expr_list = [arr; index] in List.fold_left get_expr_decs scope expr_list
  | AccessAssign(e1, e2, e3) ->
    let expr_list = [e1; e2; e3] in List.fold_left get_expr_decs scope expr_list
  | Call(_, expr_list) -> List.fold_left get_expr_decs scope expr_list
  | AttributeCall(e1, _, e_list) -> 
    let expr_list = e1 :: e_list in List.fold_left (get_expr_decs) scope expr_list
  | _ -> scope


(* recursively goes through statements looking for declarations, 
      adding any new declarations to scope
*)
let rec get_stmt_decs scope stmt =
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in match stmt with
    Block(s_list) -> 
    let _ = List.fold_left get_stmt_decs new_scope s_list in scope
  | Expr(e) -> get_expr_decs scope e
  | Dec(ty, name) -> add_symbol name ty scope
  | If(cond, then_s, else_s) -> 
    let cond_scope = get_expr_decs new_scope cond in
    let _ = (get_stmt_decs cond_scope then_s, get_stmt_decs cond_scope else_s) in scope
  | For(e1, e2, e3, s) -> 
    let expr_list = [e1; e2; e3] in
    let for_scope = List.fold_left get_expr_decs new_scope expr_list in 
    let _ = get_stmt_decs for_scope s in scope
  | DecForIter(ty, name, e, s) -> 
    let iter_scope = add_symbol name ty new_scope in
    let for_scope = get_expr_decs iter_scope e in 
    let _ = get_stmt_decs for_scope s in scope
  | While(e, s) -> 
    let while_scope = get_expr_decs new_scope e in 
    let _ = get_stmt_decs while_scope s in scope
  | _ -> scope

(* driver function for getting global declarations from statement list, builds global scope table*)
let get_vars scope s_list = List.fold_left get_stmt_decs scope s_list

(* builds function scope table*)
let build_func_table global_scope (fd : func_decl) map = 
  let key = key_string fd.fname fd.formals in
  if StringMap.mem key map then 
    raise (Failure("Error: function " ^ fd.fname ^ " is already defined with formal arguments (" ^ 
                   (string_of_params fd.formals) ^ ")"))
  else let formals_scope = List.fold_left get_bind_decs {
      variables = StringMap.empty;
      parent = None;
    } fd.formals in
    let updated_scope = { 
      variables = formals_scope.variables;
      parent = Some(global_scope); } in
    let locals_scope = get_vars {
        variables = StringMap.empty;
        parent = Some(updated_scope);
      } fd.body in StringMap.add key {
      formals = updated_scope;
      locals = locals_scope;
      ret_typ = fd.typ;
    } map

(* essentially decs.ml main function for use in semantdriver.ml
    first parses statements for globals 
    then parses through functions to add to global symbol table *)
let get_decs (s_list, f_list) = 

  let globals = get_vars {
      variables = StringMap.empty;
      parent = None;
    } (List.rev s_list) in

  let get_funcs f_list = 
    List.fold_left (fun m f -> build_func_table globals f m) StringMap.empty f_list

  in (globals, get_funcs f_list)