(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | Has

type uop = Neg | Not | Incr | Decr

type typ = 
    Int 
  | Bool 
  | Nah 
  | Char
  | Float
  | String
  | Array of typ
  | Function of typ
  | Group of typ list
  | Dictionary of typ * typ

type bind = typ * string

type expr =
    IntegerLiteral of int
  | CharacterLiteral of char
  | BoolLit of bool
  | FloatLiteral of float
  | StringLiteral of string
  | ListLit of expr list
  | DictElem of expr * expr
  | DictLit of expr list

  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Ternop of expr * expr * expr
  
  | Assign of string * expr
  | Deconstruct of bind list * expr
  | OpAssign of string * op * expr
  | DecAssign of typ * string * expr
  | Access of expr * expr 
  | AccessAssign of expr * expr * expr

  | MatchPattern of expr list * expr
  | ConditionalPattern of expr * expr
  | PatternMatch of string * expr
  | DecPatternMatch of typ * string * expr
  
  | Call of string * expr list
  | AttributeCall of expr * string * expr list

  | Noexpr

type stmt =
    Block of stmt list
  | PretendBlock of stmt list
  | Expr of expr
  | Dec of typ * string
  | Return of expr
  | Skip of expr
  | Abort of expr
  | Panic of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | ForIter of string * expr * stmt
  | DecForIter of typ * string * expr * stmt
  | DeconstForIter of bind list * expr * stmt
  | While of expr * stmt

type func_decl = {
    vtyp : typ;
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
  | Nah -> "nah"
  | Char -> "char"
  | Float -> "float"
  | String -> "string"
  | Array(t) -> string_of_typ t ^ "[]"
  | Function(t) -> string_of_typ t ^ " func"
  | Group(t) -> "(" ^ String.concat ", " (List.map string_of_typ t) ^ ")"
  | Dictionary(t1, t2) -> "[" ^ string_of_typ t1 ^ ":" ^ string_of_typ t2 ^ "]" 

let rec string_of_expr = function
    IntegerLiteral(l) -> string_of_int l
  | CharacterLiteral(l) -> "'" ^ Char.escaped l ^ "'"
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | FloatLiteral(l) -> string_of_float l
  | StringLiteral(s) -> "\"" ^ s ^ "\""
  | ListLit(lst) -> "[" ^ String.concat ", " (List.map string_of_expr lst) ^ "]"
  | DictElem(e1, e2) -> string_of_expr e1 ^ ": " ^ string_of_expr e2 
  | DictLit(lst) ->  "[" ^ String.concat ", " (List.map string_of_expr lst) ^ "]"

  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | OpAssign(v, o, e) -> v ^ " " ^ string_of_op o ^ "= " ^ string_of_expr e
  | Ternop(e1, e2, e3) -> string_of_expr e1 ^ " ? " ^ string_of_expr e2 ^ " : " ^ string_of_expr e3
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Access(e, l) -> string_of_expr e ^ "[" ^ string_of_expr l ^ "]" (*List.fold_left (fun s e -> s ^ "[" ^ string_of_expr e ^ "]") "" l*) 
  | DecAssign(t, v, e) -> string_of_typ t ^ " " ^ v ^ " = " ^ string_of_expr e
  | Deconstruct(v, e) ->  "(" ^ String.concat ", " (List.map snd v) ^ ") = " ^ string_of_expr e  

  | AccessAssign(i, idx, e) -> string_of_expr i ^ "[" ^ string_of_expr idx ^ "]" ^ " = " ^ string_of_expr e

  | ConditionalPattern(c, r) -> string_of_expr c ^ " : " ^ string_of_expr r
  | MatchPattern(c, b) -> "?? " ^ String.concat " | " (List.map string_of_expr c) ^ " ?? " ^ string_of_expr b 
  | PatternMatch(s, e) -> s ^ " = " ^ string_of_expr e
  | DecPatternMatch(t, s, e) -> string_of_typ t ^ " " ^ s ^ " = " ^ string_of_expr e
  
  | Call(f, el) -> f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | AttributeCall(e, f, el) -> string_of_expr e ^ "." ^ f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"

  | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | PretendBlock(stmts) -> "\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "\n" 
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Dec(t, v) -> string_of_typ t ^ " " ^ v ^ ";\n";
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
  | DeconstForIter(p, expr, s) -> "for ((" ^ String.concat ", " (List.map snd p) ^ ") in " ^ string_of_expr expr ^ ") " ^ string_of_stmt s 
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

