(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sexpr = typ * sx
and sx =
    SIntegerLiteral of int
  | SCharacterLiteral of char
  | SBoolLiteral of bool
  | SFloatLiteral of float
  | SStringLiteral of string
  | SListLiteral of sexpr list
  | SDictElem of sexpr * sexpr
  | SDictLiteral of sexpr list

  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | STernop of sexpr * sexpr * sexpr

  | SAssign of string * sexpr
  | SDeconstruct of bind list * sexpr
  | SOpAssign of string * op * sexpr
  | SDecAssign of typ * string * sexpr
  | SAccess of sexpr * sexpr
  | SAccessAssign of sexpr * sexpr * sexpr

  | SCall of string * sexpr list
  | SAttributeCall of sexpr * string * sexpr list

  | SNoexpr

type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SDec of typ * string
  | SReturn of sexpr
  | SSkip of sexpr
  | SAbort of sexpr
  | SPanic of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SWhile of sexpr * sstmt

type sfunc_decl = {
  styp : typ;
  sfname : string;
  sformals : bind list;
  sbody : sstmt list;
}

type sprogram = sstmt list * sfunc_decl list

(* Pretty-printing functions *)

let rec string_of_sexpr (t, e) =
  "(" ^ string_of_typ t ^ " : " ^ (match e with
    SIntegerLiteral(l) -> string_of_int l
  | SCharacterLiteral(l) -> "'" ^ Char.escaped l ^ "'"
  | SBoolLiteral(true) -> "true"
  | SBoolLiteral(false) -> "false"
  | SFloatLiteral(l) -> string_of_float l
  | SStringLiteral(s) -> "\"" ^ s ^ "\""
  | SListLiteral(list) -> "[" ^ String.concat ", " (List.map string_of_sexpr list) ^ "]"
  | SDictElem(e1, e2) -> string_of_sexpr e1 ^ ": " ^ string_of_sexpr e2
  | SDictLiteral(list) -> "[" ^ String.concat ", " (List.map string_of_sexpr list) ^ "]"

  | SId(s) -> s
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SOpAssign(v, o, e) -> v ^ " " ^ string_of_op o ^ "= " ^ string_of_sexpr e
  | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
  | SAccess(e, l) -> string_of_sexpr e ^ "[" ^ string_of_sexpr l ^ "]"
  | SAccessAssign(i, index, e) -> string_of_sexpr i ^ "[" ^ string_of_sexpr index ^ "] = " ^ string_of_sexpr e 
  | SDecAssign(t, v, e) -> string_of_typ t ^ " " ^ v ^ " = " ^ string_of_sexpr e
  | SDeconstruct(v, e) -> "(" ^ String.concat ", " (List.map snd v) ^ ") = " ^ string_of_sexpr e

  
  

  | SCall(f, el) -> f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SAttributeCall(e, f, el) -> string_of_sexpr e ^ "." ^ f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"

  | SNoexpr -> "") 
    ^ ")"				     

let rec string_of_sstmt = function
    SBlock(stmts) -> "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n"
  | SDec(t, v) -> string_of_typ t ^ " " ^ v ^ ";\n"
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n"
  | SSkip(expr) -> "skip " ^ string_of_sexpr expr ^ ";\n"
  | SAbort(expr) -> "abort " ^ string_of_sexpr expr ^ ";\n"
  | SPanic(expr) -> "panic " ^ string_of_sexpr expr ^ ";\n"
  | SIf(e, s, SBlock([])) -> "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s

let string_of_sfdecl fdecl =
  string_of_typ fdecl.styp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map snd fdecl.sformals) ^
  ")\n{\n" ^ 
  String.concat "" (List.map string_of_sstmt fdecl.sbody) ^
  "}\n"

let string_of_sprogram (sts, funcs) =
  String.concat "" (List.map string_of_sfdecl funcs) ^ "\n" ^
  String.concat "\n" (List.map string_of_sstmt (List.rev sts))
