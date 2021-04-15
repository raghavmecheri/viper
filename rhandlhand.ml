open Ast
open Sast 


let check_assign ty1 s expr1 = 
    match expr1 with
        (ty2, _) -> if ty1 = ty2 then (ty1, SDecAssign(ty1, s, expr1)) else raise (Failure "lvalue not equal to rvalue") 
      | _ -> raise (Failure "what the hell happened?") 

  (*| DecAssign(ty, string, expr1) -> check_assign ty string (expr expr1)*) 
  
