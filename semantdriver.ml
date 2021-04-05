open Ast
open Sast
open Boolcheck
open Rhandlhand 
open Decs 

let rec check_stmt = function
    Expr e -> SExpr (expr e) 
|   Skip e -> SSkip (expr e) 
|   Abort e -> SAbort (expr e) 
|   Panic e -> SPanic (expr e) 
|   If(p, b1, b2) -> SIf(check_bool p, check_stmt b1, check_stmt b2) 
|   While(p, s) -> SWhile(check_bool p, check_stmt s) 
|   Return e -> let (t, e') = expr e in 
    if t = func.typ then sReturn(t, e') 
    else raise( Failure "wrong return type" )
|   Block sl -> 
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
          in SBlock(check_stmt_list sl)