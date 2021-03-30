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

let rec get_stmt_decs stmt scope =
  match stmt with
    Block(stmt_list) -> 
      let new_scope = {
        variables = StringMap.empty;
        parent = Some(scope);
      } in List.fold_left (fun t s -> get_stmt_decs s t) new_scope stmt_list
  | _ -> scope

let check_decs (stmts, funcs) = 

  let rec dup_var name (scope : symbol_table) = 
    if StringMap.mem name scope.variables then
      raise (Failure ("Error: " ^ " is already  defined"))
    else match scope.parent with
        Some(parent) -> dup_var name parent
      | _ -> ()

in (stmts, funcs)