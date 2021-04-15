open Ast
open Sast
open Boolcheck
open Rhandlhand 
open Decs 


let symbol_table = get_decs (statements, functions);

let check_function ( fd : func_decl ) = 
    let key_func = key_string fd.fname fd.formals in 
      let current_function = StringMap.find key_func symbol_table in

let rec expr = function 


let rec check_stmt = function
    Expr e -> SExpr (expr e) 
|   Skip e -> SSkip (expr e) 
|   Abort e -> SAbort (expr e) 
|   Panic e -> SPanic (expr e) 
|   If(p, b1, b2) -> SIf(check_bool p, check_stmt b1, check_stmt b2) 
|   While(p, s) -> SWhile(check_bool p, check_stmt s) 
|   Return e -> let (t, e') = expr e in 
    if t = fd.typ then SReturn (t, e') 
    else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_expr e)) 
|   Block sl -> 
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
          in SBlock(check_stmt_list sl)

|   Dec ty l -> SDec(ty, l)

in (List.map check_stmt statements, List.map check_function functions)
