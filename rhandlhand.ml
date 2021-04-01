open Ast
open Sast 


let check_assign ty1 expr1 err = 
    match expr1 with
        (ty2, _) -> if ty1 = ty2 then () else raise (Failure "lvalue not equal to rvalue") 
      | _ -> ()
let rec get_expr_decs expr scope = 
  match expr with
    IntegerLiteral  l -> (Int, SIntegerLiteral l)
  | CharacterLiteral l -> (Char, SCharacterLiteral l)
  | BoolLit l  -> (Bool, SBoolLiteral l)
  | FloatLiteral l -> (Float, SFloatLiteral l)
  | StringLiteral l -> (String, SStringLiteral l)
  | DecAssign(ty, _, expr1) -> check_assign ty (expr expr1)
  | _ -> ()

let rec get_stmt_decs stmt  =
  match stmt with
    Block(stmt_list) -> 
      let _ = List.iter (get_stmt_decs) stmt_list
  | Expr(e) -> get_expr_decs e
  | If(cond, then_stmt, else_stmt) -> List.iter (get_stmt_decs) then_stmt ; List.iter (get_stmt_decs) else_stmt 
  | While(cond, stmtb) -> List.iter (get_stmt_decs) stmtb 
  | _ -> ()

let check_decs (stmts, funcs) = 
  
  in List.iter (get_stmt_decs) stmts
  in (stmts, funcs)