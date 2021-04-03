(* * * * *
  This file semantically checks all variable and function declarations in the AST.
  Duplicate variables, nah variable declarations, and function declarations
  with the same parameters throw errors.
  A scoped symbol table mapping variable names to their types is returned, along with  
  a mapping of functions to their scoped formal and local variables.
* * * * *)

open Ast

module StringMap = Map.Make(String)
type scope_table = {
  variables : typ StringMap.t;
  parent : scope_table option;
}

type func_table = {
  formals : scope_table;
  locals : scope_table;
  ret_typ : typ;
}

let rec string_of_params params = match params with
  (typ, _) :: [] -> string_of_typ typ ^ ")"
  | (typ, _) :: p -> string_of_typ typ ^ ", " ^ string_of_params p
  | _             -> ")" 
and key_string name params = name ^ " (" ^ string_of_params params 

let rec is_valid_dec name scope = 
  if StringMap.mem name scope.variables then
    raise (Failure ("Error: variable " ^ name ^ " is already defined"))
  else match scope.parent with
      Some(parent) -> print_endline name; is_valid_dec name parent
    | _ -> print_endline (name ^ " not found"); true

let add_symbol name ty scope = match ty with
    Nah -> raise (Failure ("Error: variable " ^ name ^ " declared with type nah"))
  | _  -> if is_valid_dec name scope then {
            variables = StringMap.add name ty scope.variables;
            parent = scope.parent;
          } else scope (* Never enters else clause, but still needed to avoid type error *)

let get_bind_decs scope bind = 
  let ty, name = bind in add_symbol name ty scope
          
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

let get_func_table (func_dec : func_decl) global_scope = 
  let formals_scope = List.fold_left get_bind_decs {
    variables = StringMap.empty;
    parent = None;
  } func_dec.formals in 
  let locals_scope = List.fold_left get_stmt_decs {
    variables = StringMap.empty;
    parent = Some(formals_scope);
  } func_dec.body in
  let ty = func_dec.typ 
  and updated_scope = { 
    variables = formals_scope.variables;
    parent = Some(global_scope); } 
  in {
    formals = updated_scope;
    locals = locals_scope;
    ret_typ = ty;
  }

let get_decs (s_list, f_list) = 

  let get_vars stmts = 
    List.fold_left get_stmt_decs {
      variables = StringMap.empty;
      parent = None;
    } stmts in

  (* TODO : major cleanup, duplicate checking for overloaded funcs *)

  let globals = get_vars (List.rev s_list) in
  let add_func_dec map func_dec global_scope = 
    let key = key_string func_dec.fname func_dec.formals
    and func_table = get_func_table func_dec global_scope
    in StringMap.add key func_table map
  in let get_funcs fd_list globs = 
    List.fold_left (fun map fd -> add_func_dec map fd globs) StringMap.empty fd_list

in let _ = (globals, get_funcs f_list globals) in (s_list, f_list)