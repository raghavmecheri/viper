(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or

type uop = Neg | Not

type typ = 
    Int 
  | Bool 
  | Void 
  | Char

type bind = typ * string

type expr =
    IntegerLiteral of int
  | CharacterLiteral of char
  | BoolLit of bool
  | ListLit of expr list
  | Id of string
  | ArrId of string
  | Dec of typ * expr
  | Access of expr * expr
  | AccessAssign of expr * expr * expr
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of expr * expr
  | DecAssign of typ * expr * expr
  | Call of expr * expr list
  | Noexpr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | ForIter of string * expr * stmt
  | While of expr * stmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    body : stmt list;
    autoreturn: bool;
  }

type program = stmt list * func_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Void -> "nah"
  | Char -> "char"

let rec string_of_expr = function
    IntegerLiteral(l) -> string_of_int l
  | CharacterLiteral(l) -> "'" ^ Char.escaped l ^ "'"
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | ListLit(lst) -> "[" ^ List.fold_left (fun str elem -> str ^ "," ^ string_of_expr elem) "" lst ^ "]"
  | Id(s) -> s
  | ArrId(s) -> s ^ "[]"
  | Dec(t, e) -> string_of_typ t ^ " " ^ string_of_expr e
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> string_of_expr v ^ " = " ^ string_of_expr e
  | DecAssign(t, v, e) -> string_of_typ t ^ " " ^ string_of_expr v ^ " = " ^ string_of_expr e 
  | Access(e, idx) -> string_of_expr e ^ "[" ^ string_of_expr idx ^ "]"
  | AccessAssign(e, idx, l) -> string_of_expr e ^  "[" ^ string_of_expr idx ^ "] = " ^ string_of_expr l
  | Call(f, el) ->
      string_of_expr f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | ForIter(name, e2, s) ->
      "for (" ^ name ^ " in " ^ string_of_expr e2 ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^ (if fdecl.autoreturn then "return " else "") ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"

let string_of_program (sts, funcs) =
  (* Do we reverse to pretty-print? Is upside down stuff an indicator of the AST *)
  String.concat "" (List.map string_of_fdecl funcs) ^ "\n" ^
  String.concat "\n" (List.map string_of_stmt (List.rev sts))

