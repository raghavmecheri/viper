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
      (_, (SCharacterLiteral(_) as c)) -> c
    | (_, SIntegerLiteral(i)) when i > -1 && i < 256 -> SCharacterLiteral(char_of_int i)
    | (_, SIntegerLiteral(i)) -> raise (Failure("Error: Integer " ^ string_of_int i ^ " cannot be cast to Char, 
        it must have a value between 0 and 255")) 
    | (_, SStringLiteral("")) -> raise (Failure("Error: empty string cannot be cast to Char"))
    | (_, SStringLiteral(s)) -> SCharacterLiteral(String.get s 0)
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to Char"))

let to_int params = 
  match verify_params params "int" with
      (_, (SIntegerLiteral(_) as i)) -> i
    | (_, SCharacterLiteral(c)) -> SIntegerLiteral(int_of_char c)
    | (_, SFloatLiteral(f)) -> SIntegerLiteral(int_of_float f)
    | (_, SBoolLiteral(true)) -> SIntegerLiteral(1)
    | (_, SBoolLiteral(false)) -> SIntegerLiteral(0)
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to Int"))

let to_float params = 
  match verify_params params "float" with
      (_, (SFloatLiteral(_) as f)) -> f
    | (_, SIntegerLiteral(i)) -> SFloatLiteral(float_of_int i)
    | (_, SCharacterLiteral(c)) -> SFloatLiteral(float_of_int (int_of_char c))
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to Float"))

let to_bool params = 
  match verify_params params "bool" with
      (_, (SBoolLiteral(_) as b)) -> b
    | (_, SCharacterLiteral(c)) when c = '\x00' -> SBoolLiteral(false)
    | (_, SIntegerLiteral(i)) when i = 0 -> SBoolLiteral(false)
    | (_, SFloatLiteral(f)) when f = 0.0 -> SBoolLiteral(false)
    | (_, SStringLiteral(s)) when String.length s > 0 -> SBoolLiteral(false)
    | (Nah, _) -> SBoolLiteral(false)
    | (_, SCharacterLiteral(_))
    | (_, SIntegerLiteral(_))
    | (_, SFloatLiteral(_))
    | (_, SStringLiteral(_)) -> SBoolLiteral(true)
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to Bool"))

let to_string params = 
  match verify_params params "string" with
      (_, (SStringLiteral(_) as s)) -> s
    | (_, SCharacterLiteral(c)) -> SStringLiteral(String.make 1 c)
    | (_, SIntegerLiteral(i)) -> SStringLiteral(string_of_int i)
    | (_, SFloatLiteral(f)) -> SStringLiteral(string_of_float f)
    | (_, SBoolLiteral(true)) -> SStringLiteral("true")
    | (_, SBoolLiteral(false)) -> SStringLiteral("false")
    | (Nah, _) -> SStringLiteral("nah")
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to String"))

let to_nah params = 
  match verify_params params "nah" with
      _ -> SNoexpr
