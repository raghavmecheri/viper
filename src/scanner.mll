(* Ocamllex scanner for viper, adapted from that of the MicroC compiler. Ref: https://github.com/cwabbott0/microc-llvm *)

{ open Parser }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { comment lexbuf }           (* Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['      { ARROPEN }
| ']'      { ARRCLOSE }
| ';'      { SEMI }
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '%'      { MODULO }
| '='      { ASSIGN }
| "+="     { PLUS_ASSIGN }
| "-="     { MINUS_ASSIGN }
| "*="     { TIMES_ASSIGN }
| "/="     { DIVIDE_ASSIGN } 
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| "!"      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "func"   { FUNC }
| "in"     { IN }
| "has"    { HAS }
| "int"    { INT }
| "char"   { CHAR }
| "bool"   { BOOL }
| "float"  { FLOAT }
| "string" { STRING }
| "nah"    { NAH }
| "=>"     { ARROW }
| "true"   { TRUE }
| "false"  { FALSE }
| "skip"   { SKIP }
| "abort"  { ABORT }
| "panic"  { PANIC }
| '?'      { QUESTION }
| "??"     { MATCH }
| '|'      { BAR }
| '.'      { DOT }
| ':'      { COLON }
| ['0'-'9']+['.']['0'-'9']+ as lxm { FLOATLIT(float_of_string lxm) }
| ['0'-'9']+ as lxm { INTLIT(int_of_string lxm) }
| ['\''](['\x20'-'\x7E'] as lxm)['\''] { CHARLIT(lxm) }
| ['\"'](['\x20'-'\x21' '\x23' - '\x7E']* as lxm)['\"'] { STRLIT(lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }
