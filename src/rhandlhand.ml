open Sast 


let check_decassign ty1 s expr1 = 
    match expr1 with
        (ty2, _) -> if ty1 = ty2 then (ty1, SDecAssign(ty1, s, expr1)) else raise (Failure "lvalue not equal to rvalue") 
      

  (*| DecAssign(ty, string, expr1) -> check_assign ty string (expr expr1)*) 


let check_assign lvaluet rvaluet  =
      if lvaluet = rvaluet then lvaluet else raise (Failure "wrong assignment")  
  
