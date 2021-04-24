(*****
This file handles Viper's type casting, defining what types can and cannot be cast to another.
*****)

open Ast
open Sast

let verify_params params func = 
  if List.length params != 1 then
    raise (Failure ("Error: " ^ func ^ "() requires one argument"))
  else List.hd params

let to_char params =  
  match verify_params params "char" with 
      (_, SIntegerLiteral(i)) when i > -1 && i < 256 -> SCharacterLiteral(Char.chr i)
    | (_, SIntegerLiteral(i)) -> raise (Failure("Error: Integer " ^ string_of_int i ^ " cannot be cast to Char, 
        it must have a value between 0 and 255")) 
    | (_, SStringLiteral("")) -> raise (Failure("Error: empty string cannot be cast to Char"))
    | (_, SStringLiteral(s)) -> SCharacterLiteral(String.get s 0)
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to Char"))

let to_int params = 
  match verify_params params "int" with
      (_, SCharacterLiteral(c)) -> SIntegerLiteral(int_of_char c)
    | (_, SFloatLiteral(f)) -> SIntegerLiteral(int_of_float f)
    | (_, SBoolLiteral(true)) -> SIntegerLiteral(1)
    | (_, SBoolLiteral(false)) -> SIntegerLiteral(0)
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to Int"))
    