(* * * * *
  This file semantically checks all variable declarations in the AST.
  Duplicate variables, nah declarations, and declarations in illegal places all throw errors.
  A scoped symbol table mapping variable names to their types is returned.
* * * * *)

open Ast

module StringMap = Map.Make(String)
type symbol_table = {
  variables : typ StringMap.t;
  parent : symbol_table option;
}

let rec not_dup_var name scope = 
  if StringMap.mem name scope.variables then
    raise (Failure ("Error: " ^ name ^ " is already defined"))
  else match scope.parent with
      Some(parent) -> print_endline name; not_dup_var name parent
    | _ -> print_endline (name ^ " not found"); true

let add_symbol name ty scope = 
  if not_dup_var name scope then {
    variables = StringMap.add name ty scope.variables;
    parent = scope.parent;
  } else scope (* Never enters else clause, but still needed to avoid type error *)

let rec get_expr_decs scope expr = 
  match expr with
    DecAssign(ty, name, _) -> add_symbol name ty scope
  | _ -> scope

let rec get_stmt_decs scope stmt =
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in 
  match stmt with
    Block(s_list) -> 
      let _ = List.fold_left get_stmt_decs new_scope s_list in scope
  | Expr(e) -> get_expr_decs scope e
  | Dec(ty, name) -> add_symbol name ty scope
  | If(cond, then_s, else_s) -> 
      let cond_scope = get_expr_decs new_scope cond in
      let _ = (get_stmt_decs cond_scope then_s, get_stmt_decs cond_scope else_s) in scope
  | For(e1, e2, e3, s) -> let expr_list = [e1; e2; e3] in
      let for_scope = List.fold_left get_expr_decs new_scope expr_list in
      let _ = get_stmt_decs for_scope s in scope
  | DecForIter(ty, name, e, s) -> let iter_scope = add_symbol name ty new_scope in
      let for_scope = get_expr_decs iter_scope e in
      let _ = get_stmt_decs for_scope s in scope
  | While(e, s) -> let while_scope = get_expr_decs new_scope e in
      let _ = get_stmt_decs while_scope s in scope
  | _ -> scope

let check_decs (stmts, funcs) = 
  let globals = {
    variables = StringMap.empty;
    parent = None;
  } 
  in let globals = List.fold_left get_stmt_decs globals (List.rev stmts)
  in let names = globals.variables in StringMap.iter (fun a b -> print_endline ("glob " ^ a)) names; (stmts, funcs)