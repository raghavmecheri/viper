(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | Has

type uop = Neg | Not | Incr | Decr

type typ = 
    Int 
  | Bool 
  | Void 
  | Char
  | Float
  | String
  | Array of typ
  | Tuple of typ list

type bind = typ * string

type expr =
    IntegerLiteral of int
  | CharacterLiteral of char
  | BoolLit of bool
  | FloatLiteral of float
  | StringLiteral of string
  | ListLit of expr list
  | TupleLit of expr list

  | Id of string
  | Dec of typ * string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Ternop of expr * expr * expr
  
  | Assign of string * expr
  | OpAssign of string * op * expr
  | DecAssign of typ * string * expr
  | Access of expr * expr 
  
  | MatchPattern of expr list * expr
  | ConditionalPattern of expr * expr
  | PatternMatch of string * expr
  | DecPatternMatch of typ * string * expr
  
  | Call of string * expr list
  | Noexpr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | Skip of expr
  | Abort of expr
  | Panic of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | ForIter of string * expr * stmt
  | DecForIter of typ * string * expr * stmt
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
  | Mod -> "%"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"
  | Has -> "has"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"
  | Incr -> "++"
  | Decr -> "--"

let rec string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Void -> "nah"
  | Char -> "char"
  | Float -> "float"
  | String -> "string"
  | Array(t) -> string_of_typ t ^ "[]"
  | Tuple(t) -> "(" ^ List.fold_left (fun str elem -> str ^ string_of_typ elem ^ ",") "" t ^ ")"

let rec string_of_expr = function
    IntegerLiteral(l) -> string_of_int l
  | CharacterLiteral(l) -> "'" ^ Char.escaped l ^ "'"
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | FloatLiteral(l) -> string_of_float l
  | StringLiteral(s) -> "\"" ^ s ^ "\""
  | ListLit(lst) -> "[" ^ List.fold_left (fun str elem -> str ^ string_of_expr elem ^ ",") "" lst ^ "]"
  | TupleLit(lst) -> "(" ^ List.fold_left (fun str elem -> str ^ string_of_expr elem ^ ",") "" lst ^ ")"
  | Id(s) -> s
  | Dec(t, v) -> string_of_typ t ^ " " ^ v
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | OpAssign(v, o, e) -> v ^ " " ^ string_of_op o ^ "= " ^ string_of_expr e
  | Ternop(e1, e2, e3) -> string_of_expr e1 ^ " ? " ^ string_of_expr e2 ^ " : " ^ string_of_expr e3
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Access(e, l) -> string_of_expr e ^ "[" ^ string_of_expr l ^ "]" (*List.fold_left (fun s e -> s ^ "[" ^ string_of_expr e ^ "]") "" l*) 
  | DecAssign(t, v, e) -> string_of_typ t ^ " " ^ v ^ " = " ^ string_of_expr e
  | ConditionalPattern(c, r) -> string_of_expr c ^ " : " ^ string_of_expr r
  | MatchPattern(c, b) -> List.fold_left(fun s e -> string_of_expr e ^ " | " ^ s) "" c  ^ " | " ^ string_of_expr b 
  | PatternMatch(s, e) -> s ^ " = " ^ string_of_expr e
  | DecPatternMatch(t, s, e) -> string_of_typ t ^ " " ^ s ^ " = " ^ string_of_expr e
  | Call(f, el) -> f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | Skip(expr) -> "skip " ^ string_of_expr expr ^ ";\n";
  | Abort(expr) -> "abort " ^ string_of_expr expr ^ ";\n";
  | Panic(expr) -> "panic " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | ForIter(name, e2, s) ->
      "for (" ^ name ^ " in " ^ string_of_expr e2 ^ ") " ^ string_of_stmt s
  | DecForIter(t, name, e2, s) ->
      "for (" ^ string_of_typ t ^ " " ^ name ^ " in " ^ string_of_expr e2 ^ ") " ^ string_of_stmt s
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

