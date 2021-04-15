open Ast
open Sast
open Semantdriver  


let check_bool e = 
    match expr e with
        (ty, l) -> if ty = Bool then (Bool, SBoolLiteral l) else raise (Failure "value must be a bool") 
      | _ -> raise (Failure "what the hell just happened?") 