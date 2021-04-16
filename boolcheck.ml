open Ast
open Sast



let check_bool e = 
    match e with
        (ty, l) -> if ty = Bool then (ty, l) else raise (Failure "value must be a bool") 
      | _ -> raise (Failure "what the hell just happened?") 
