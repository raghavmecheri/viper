(* Ocamllex scanner for MicroC *)

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
| "int"    { INT }
| "char"   { CHAR }
| "bool"   { BOOL }
| "nah"    { VOID }
| "=>"     { ARROW }
| "true"   { TRUE }
| "false"  { FALSE }
| ['0'-'9']+ as lxm { INTLIT(int_of_string lxm) }
| ['\''](['a'-'z' 'A'-'Z'] as lxm)['\''] { CHARLIT(lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }
