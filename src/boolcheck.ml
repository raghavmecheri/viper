(*
One function that just checks if an if-condition or while loops have a bool predicate
*)

open Ast 
open Sast
open Decs

let check_bool e = 
    match e with
        (ty, l) -> if ty = Bool then (ty, l) else raise (Failure "value must be a bool") 
      