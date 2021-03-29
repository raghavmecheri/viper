(* * * * *
  This file semantically checks all variable declarations in the AST.
  Duplicate variables, nah declarations, and declarations in illegal places all throw errors.
  A scoped symbol table mapping variable names to their types is returned.
* * * * *)

open Ast

module StringMap = Map.Make(String)
type symbol_table = {
  variables : typ StringMap.t
  parent : symbol_table option
}

let rec find_variable name (scope : symbol_table) = 
  try
    StringMap.find name scope.variables
  with Not_found ->
    match scope.parent with
      Some(parent) -> find_variable name parent
      _ -> raise Not_found