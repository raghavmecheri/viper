(*****
This file handles Viper's type casting, defining what types can and cannot be cast to another.
*****)

open Ast
open Sast

let to_char params =  
  if List.length params != 1 then
    raise (Failure ("Error: char() requires one argument"))
  else match List.hd params with 
      (_, SIntegerLiteral(i)) when i > -1 && i < 256 -> SCharacterLiteral(Char.chr i)
    | (_, SIntegerLiteral(i)) -> raise (Failure("Error: Integer " ^ string_of_int i ^ " cannot be cast to Char, 
                                          it must have a value between 0 and 127")) 
    | (_, SStringLiteral("")) -> raise (Failure("Error: empty string cannot be cast to Char"))
    | (_, SStringLiteral(s)) -> SCharacterLiteral(String.get s 0)
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to char()"))

let to_int params = 1
    