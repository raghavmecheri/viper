open Ast
open Sast 


let check_bool e = 
    match get_expr_decs e with
        (ty, _) -> if ty = Bool then () else raise (Failure "value must be a bool") 
      | _ -> raise (Failure "what the hell just happened?") 
let rec get_expr_decs expr scope = 
  match expr with
  | BoolLit l  -> (Bool, SBoolLiteral l)
  | _ -> ()

let rec get_stmt_decs stmt  =
  match stmt with
    Block(stmt_list) -> 
      let _ = List.iter (get_stmt_decs) stmt_list
  | If(cond, then_stmt, else_stmt) -> check_bool cond 
  | While(cond, stmtb) -> check_bool cond 
  | _ -> ()

let check_decs (stmts, funcs) = 
  
  in List.iter (get_stmt_decs) stmts
  in (stmts, funcs)