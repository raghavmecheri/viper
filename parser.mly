%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA ARROPEN ARRCLOSE
%token PLUS MINUS TIMES DIVIDE ASSIGN NOT
%token EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR
%token RETURN IF ELSE FOR WHILE INT CHAR BOOL VOID FUNC IN ARROW
%token <int> INTLIT
%token <char> CHARLIT
%token <string> ID
%token EOF

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT NEG

%start program
%type <Ast.program> program

%%

program:
  decls EOF { $1 }

decls:
   /* nothing */ { [], [] }  
 | decls fdecl { fst $1, ($2 :: snd $1) }
 | decls stmt { ($2 :: fst $1), snd $1 }

fdecl:
   typ FUNC ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
     { { typ = $1;
	   fname = $3;
	   formals = $5;
     body = List.rev $8;
     autoreturn = false } }
   | typ FUNC ID LPAREN formals_opt RPAREN ARROW stmt
     { { typ = $1;
     fname = $3;
     formals = $5;
     body = [$8];
     autoreturn = true } }
   | typ FUNC ID LPAREN formals_opt RPAREN ARROW LBRACE stmt_list RBRACE
     { { typ = $1; 
     fname = $3; 
     formals = $5;  
     body = List.rev $9; 
     autoreturn = false } } 
   | typ FUNC LPAREN formals_opt RPAREN ARROW stmt
     { { typ = $1;
     fname = "anon";
     formals = $4;
     body = [$7]; 
     autoreturn = true } }
   | typ FUNC LPAREN formals_opt RPAREN ARROW LBRACE stmt_list RBRACE
     { { typ = $1;
     fname = "anon";
     formals = $4; 
     body = List.rev $8;
     autoreturn = false } }  

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [($1,$2)] }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }

typ:
    INT { Int }
  | BOOL { Bool }
  | VOID { Void }
  | CHAR { Char }

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr $1 }
  | RETURN SEMI { Return Noexpr }
  | RETURN expr SEMI { Return $2 }
  | LBRACE stmt_list RBRACE { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
     { For($3, $5, $7, $9) }
  | FOR LPAREN ID IN expr RPAREN stmt { ForIter($3, $5, $7) }
  | WHILE LPAREN expr RPAREN stmt { While($3, $5) }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    INTLIT          { IntegerLiteral($1) }
  | CHARLIT         { CharacterLiteral($1) }
  | TRUE             { BoolLit(true) }
  | FALSE            { BoolLit(false) }
  | ID               { Id($1) }
  | typ ID           { Dec($1, $2) }
  | typ ID list_exp  { AccessDec($1, $2, $3) }
  | typ list_exp ID  { AccessDec($1, $3, $2) }
  | list_exp         { $1 }
  | expr PLUS   expr { Binop($1, Add,   $3) }
  | expr MINUS  expr { Binop($1, Sub,   $3) }
  | expr TIMES  expr { Binop($1, Mult,  $3) }
  | expr DIVIDE expr { Binop($1, Div,   $3) }
  | expr EQ     expr { Binop($1, Equal, $3) }
  | expr NEQ    expr { Binop($1, Neq,   $3) }
  | expr LT     expr { Binop($1, Less,  $3) }
  | expr LEQ    expr { Binop($1, Leq,   $3) }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3) }
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | MINUS expr %prec NEG { Unop(Neg, $2) }
  | NOT expr         { Unop(Not, $2) }
  | typ ID ASSIGN expr { DecAssign($1, $2, $4) }
  | typ ID list_exp ASSIGN expr { AccessDecAssign($1, $2, $3, $5) }
  | typ list_exp ID ASSIGN expr { AccessDecAssign($1, $3, $2, $5) }  
  | ID ASSIGN expr   { Assign($1, $3) }
  | expr list_exp { Access($1, $2)  }
  | ID list_exp ASSIGN expr { AccessAssign($1, $2, $4) }
  | expr LPAREN actuals_opt RPAREN { Call($1, $3) }
  | LPAREN expr RPAREN { $2 }

list_exp:
  ARROPEN list_elems ARRCLOSE { ListLit($2) }

list_elems:
  /* nothing */           { [] }
  | expr                  { [$1] }
  | expr COMMA list_elems { $1 :: $3 }

actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [$1] }
  | actuals_list COMMA expr { $3 :: $1 }
