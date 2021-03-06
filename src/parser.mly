%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA ARROPEN ARRCLOSE DOT
%token PLUS MINUS TIMES DIVIDE ASSIGN NOT PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIVIDE_ASSIGN MODULO HAS QUESTION COLON
%token EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR MATCH BAR
%token RETURN IF ELSE FOR WHILE INT CHAR BOOL FLOAT STRING NAH FUNC IN ARROW PANIC
%token SKIP ABORT
%token <int> INTLIT
%token <char> CHARLIT
%token <float> FLOATLIT
%token <string> STRLIT
%token <string> ID
%token EOF

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN
%left QUESTION COLON MATCH
%left BAR
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%right HAS
%left PLUS MINUS PLUS_ASSIGN MINUS_ASSIGN
%left TIMES DIVIDE MODULO TIMES_ASSIGN DIVIDE_ASSIGN
%nonassoc INCR DECR
%right NOT NEG
%left ARROPEN ARRCLOSE DOT

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
   typ ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
     { { typ = $1;
	   fname = $2;
	   formals = $4;
     body = List.rev $7;
     autoreturn = false } }
    | typ ID LPAREN formals_opt RPAREN ARROW stmt
     { { typ = $1;
     fname = $2;
     formals = $4;
     body = [$7];
     autoreturn = true } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [($1,$2)] }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }

typ:
    INT { Int }
  | BOOL { Bool }
  | NAH { Nah }
  | CHAR { Char }
  | FLOAT { Float }
  | STRING { String }
  | typ FUNC { Function($1) }
  | typ ARROPEN ARRCLOSE { Array($1) }
  | LPAREN type_list RPAREN { Group($2) }
  | ARROPEN typ COLON typ ARRCLOSE { Dictionary($2, $4) }

type_list:
    typ            { [$1] }
  | typ COMMA type_list { $1 :: $3 }

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr $1 }
  | typ ID SEMI { Dec($1, $2) }
  | RETURN SEMI { Return Noexpr }
  | RETURN expr SEMI { Return $2 }
  | SKIP SEMI { Skip Noexpr }
  | ABORT SEMI { Abort Noexpr }
  | PANIC expr SEMI { Panic $2 }
  | LBRACE stmt_list RBRACE { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
     { For($3, $5, $7, $9) }
  | FOR LPAREN ID IN expr RPAREN stmt { ForIter($3, $5, $7) }
  | FOR LPAREN typ ID IN expr RPAREN stmt { DecForIter($3, $4, $6, $8) }
  | FOR LPAREN LPAREN formal_list RPAREN IN expr RPAREN stmt { DeconstForIter($4, $7, $9) }
  | WHILE LPAREN expr RPAREN stmt { While($3, $5, Expr(Noexpr)) }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    INTLIT          { IntegerLiteral($1) }
  | CHARLIT         { CharacterLiteral($1) }
  | FLOATLIT        { FloatLiteral($1) }
  | STRLIT          { StringLiteral($1) }
  | TRUE             { BoolLit(true) }
  | FALSE            { BoolLit(false) }
  | ID               { Id($1) }
  | list_exp         { $1 }
  | dict_exp         { $1 }

  | expr PLUS   expr { Binop($1, Add,   $3) }
  | expr MINUS  expr { Binop($1, Sub,   $3) }
  | expr TIMES  expr { Binop($1, Mult,  $3) }
  | expr DIVIDE expr { Binop($1, Div,   $3) }
  | expr MODULO expr { Binop($1, Mod, $3) }

  | ID PLUS_ASSIGN expr { OpAssign($1, Add, $3) }
  | ID MINUS_ASSIGN expr { OpAssign($1, Sub, $3) }
  | ID TIMES_ASSIGN expr { OpAssign($1, Mult, $3) }
  | ID DIVIDE_ASSIGN expr { OpAssign($1, Div, $3) }
 
  | expr EQ     expr { Binop($1, Equal, $3) }
  | expr NEQ    expr { Binop($1, Neq,   $3) }
  | expr LT     expr { Binop($1, Less,  $3) }
  | expr LEQ    expr { Binop($1, Leq,   $3) }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3) }
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | expr HAS     expr { Binop($1, Has,    $3) }

  | expr QUESTION expr COLON expr { Ternop($1, $3, $5) }
  
  | MINUS expr %prec NEG { Unop(Neg, $2) }
  | NOT expr         { Unop(Not, $2) }
  | expr PLUS PLUS %prec INCR   { Unop(Incr, $1) }
  | expr MINUS MINUS %prec DECR { Unop(Decr, $1) }

  | typ ID ASSIGN expr { DecAssign($1, $2, $4) }
  | ID ASSIGN expr   { Assign($1, $3) }
  | LPAREN formal_list RPAREN ASSIGN expr { Deconstruct($2, $5) }

  | expr ARROPEN expr ARRCLOSE { Access($1, $3) }
  | expr ARROPEN expr ARRCLOSE ASSIGN expr { AccessAssign($1, $3, $6) } 

  | typ ID ASSIGN MATCH pattern { DecPatternMatch($1, $2, $5) }
  | ID ASSIGN MATCH pattern { PatternMatch($1, $4) }

  | ID LPAREN actuals_opt RPAREN { Call($1, $3) }
  | expr DOT ID LPAREN actuals_opt RPAREN { AttributeCall($1, $3, $5) }
  
  | LPAREN expr RPAREN { $2 }

pattern:
    c_pattern MATCH expr { MatchPattern($1, $3) }

c_pattern:
    expr COLON expr { [ConditionalPattern($1, $3)] }
  | expr COLON expr BAR c_pattern { ConditionalPattern($1, $3) :: $5 }

dict_exp:
    ARROPEN dict_elems ARRCLOSE { DictLit($2) }

dict_elems:
    dict_elem   { [$1] }
    | dict_elem COMMA dict_elems  { $1 :: $3 }

dict_elem:
    expr COLON expr { DictElem($1, $3) }

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


/* MARK: Stuff that we aren't using, but we might use (lol) */

/*
tuple_exp:
    LPAREN tuple_elems RPAREN   { TupleLit($2) }

tuple_elems:
    expr           { [$1] }
  | expr COMMA tuple_elems  { $1 :: $3 }
*/

/* 
    | typ LPAREN formals_opt RPAREN ARROW stmt
      { { typ = $1;
      fname = "anon";
      formals = $4;
      body = [$7];
      autoreturn = true } }
    | typ LPAREN formals_opt RPAREN ARROW LBRACE stmt_list RBRACE
      { { typ = $1;
      fname = "anon";
      formals = $4;
      body = List.rev $8;
      autoreturn = false } }
 */
