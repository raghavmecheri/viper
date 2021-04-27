(*
This file handles Viper's type casting, defining what types can and cannot be cast to another.
*)

open Ast
open Sast

let verify_params params func = 
  if List.length params != 1 then
    raise (Failure ("Error: " ^ func ^ "() requires one argument"))
  else List.hd params

let to_char params =  
  match verify_params params "char" with 
      (_, (SCharacterLiteral(_) as c)) -> (Char, c)
    | (_, SIntegerLiteral(i)) when i > -1 && i < 256 -> (Char, SCharacterLiteral(char_of_int i))
    | (_, SIntegerLiteral(i)) -> raise (Failure("Error: integer " ^ string_of_int i ^ " cannot be cast to char, 
        it must have a value between 0 and 255")) 
    | (_, SStringLiteral("")) -> raise (Failure("Error: empty string cannot be cast to char"))
    | (_, SStringLiteral(s)) -> (Char, SCharacterLiteral(String.get s 0))
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to char"))

let to_int params = 
  match verify_params params "int" with
      (_, (SIntegerLiteral(_) as i)) -> (Int, i)
    | (_, SCharacterLiteral(c)) -> (Int, SIntegerLiteral(int_of_char c))
    | (_, SFloatLiteral(f)) -> (Int, SIntegerLiteral(int_of_float f))
    | (_, SBoolLiteral(true)) -> (Int, SIntegerLiteral(1))
    | (_, SBoolLiteral(false)) -> (Int, SIntegerLiteral(0))
    | (_, SStringLiteral(s)) -> (
        try (Int, SIntegerLiteral(int_of_string s))
        with Failure _ -> raise (Failure ("Error: string \"" ^ s ^ "\" cannot be cast to int")))
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to int"))

let to_float params = 
  match verify_params params "float" with
      (_, (SFloatLiteral(_) as f)) -> (Float, f)
    | (_, SIntegerLiteral(i)) -> (Float, SFloatLiteral(float_of_int i))
    | (_, SCharacterLiteral(c)) -> (Float, SFloatLiteral(float_of_int (int_of_char c)))
    | (_, SStringLiteral(s)) -> (
      try (Int, SFloatLiteral(float_of_string s))
      with Failure _ -> raise (Failure ("Error: string \"" ^ s ^ "\" cannot be cast to float")))
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to float"))

let to_bool params = 
  match verify_params params "bool" with
      (_, (SBoolLiteral(_) as b)) -> (Bool, b)
    | (_, SCharacterLiteral(c)) when c = '\x00' -> (Bool, SBoolLiteral(false))
    | (_, SIntegerLiteral(i)) when i = 0 -> (Bool, SBoolLiteral(false))
    | (_, SFloatLiteral(f)) when f = 0.0 -> (Bool, SBoolLiteral(false))
    | (_, SStringLiteral(s)) when s = "" -> (Bool, SBoolLiteral(false))
    | (Nah, _) -> (Bool, SBoolLiteral(false))
    | (_, SCharacterLiteral(_))
    | (_, SIntegerLiteral(_))
    | (_, SFloatLiteral(_))
    | (_, SStringLiteral(_)) -> (Bool, SBoolLiteral(true))
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to bool"))

let to_string params = 
  match verify_params params "string" with
      (_, (SStringLiteral(_) as s)) -> (String, s)
    | (_, SCharacterLiteral(c)) -> (String, SStringLiteral(String.make 1 c))
    | (_, SIntegerLiteral(i)) -> (String, SStringLiteral(string_of_int i))
    | (_, SFloatLiteral(f)) -> (String, SStringLiteral(string_of_float f))
    | (_, SBoolLiteral(true)) -> (String, SStringLiteral("true"))
    | (_, SBoolLiteral(false)) -> (String, SStringLiteral("false"))
    | (Nah, _) -> (String, SStringLiteral("nah"))
    | (typ, _) -> raise (Failure ("Error: type " ^ string_of_typ typ ^ " cannot be cast to string"))

let to_nah params = 
  match verify_params params "nah" with
      _ -> (Nah, SNoexpr)
