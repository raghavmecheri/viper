open Sast 
open Ast

let check_decassign ty1 s expr1 = 
    match expr1 with
        (* Allows declarations of empty list and dictionary literals *)
        (Array(Nah), SListLiteral([])) -> (ty1, SDecAssign(ty1, s, expr1)) 
      | (Dictionary(Nah, Nah), SDictLiteral([])) -> (ty1, SDecAssign(ty1, s, expr1))
      | (ty2, _) when ty1 = ty2 -> (ty1, SDecAssign(ty1, s, expr1)) 
      | (ty2, _) -> raise (Failure ("lvalue " ^ string_of_typ ty1 ^ " not equal to rvalue " ^ string_of_typ ty2)) 
  (*| DecAssign(ty, string, expr1) -> check_assign ty string (expr expr1)*) 

let check_assign lvaluet rvaluet  =
      if lvaluet = rvaluet then lvaluet else raise (Failure "wrong assignment")  
  
