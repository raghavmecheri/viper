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

let rec get_expr_decs expr scope = 
  match expr with
    DecAssign(ty, name, _) -> add_symbol name ty scope
  | _ -> scope

let rec get_stmt_decs stmt scope =
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in 
  match stmt with
    Block(stmt_list) -> 
      let _ = List.fold_left (fun t s -> get_stmt_decs s t) new_scope stmt_list in scope
  | Expr(e) -> get_expr_decs e scope
  | Dec(ty, name) -> add_symbol name ty scope
  | If(cond, then_stmt, else_stmt) -> scope
  | _ -> scope

let check_decs (stmts, funcs) = 
  let globals = {
    variables = StringMap.empty;
    parent = None;
  } 
  in let symbs = List.fold_left (fun t s -> get_stmt_decs s t) globals stmts
  in (stmts, funcs)