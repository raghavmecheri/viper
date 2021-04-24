(* Semantic checking for the MicroC compiler *)

open Ast
let placeholderCheck ast = ast

exception SemanticException of string

let rec clean_pattern_rec s e base = match e with
    ConditionalPattern(cond, exp) :: [] -> If(cond, Expr(Assign(s, exp)), Expr(Assign(s, base)))
  | ConditionalPattern(cond, exp) :: tail -> If(cond, Expr(Assign(s, exp)), clean_pattern_rec s tail base)
  | _ -> Expr(Noexpr)

let clean_pattern s e = match e with
    MatchPattern(pattern, base) -> clean_pattern_rec s pattern base
  | _ -> Expr(Noexpr)

let clean_expression expr = match expr with
    PatternMatch(s, e) -> clean_pattern s e
  | DecPatternMatch(t, s, e) -> PretendBlock([ Dec(t, s); clean_pattern s e;  ])
  | AttributeCall(e, f, args) -> ignore (print_endline "Modifying attribute call"); Expr(Call(f, e::args))
  | _ -> Expr(expr)

let decompose_deconstforiter n e s = 
    let comparison = Binop(Id("dfi_tmp_idx"), Leq, Call("len", [e]))
    in
    let (idx_t, idx_name) = List.hd n
    in
    let (el_t, el_name) = List.hd (List.rev n)
    in
    let exec = Block([ Expr(DecAssign(idx_t, idx_name, Id("dfi_tmp_idx"))); Expr(DecAssign(el_t, el_name, Access(e, Id("dfi_tmp_idx")))); s; Expr(Unop(Incr, Id("dfi_tmp_idx")))  ])
    in
    While(comparison, exec)

let decompose_foriter n e s = 
    let comparison = Binop(Id("dfi_tmp_idx"), Leq, Call("len", [e]))
    in
    let exec = Block([ Expr(Assign(n, Access(e, Id("dfi_tmp_idx")))); s; Expr(Unop(Incr, Id("dfi_tmp_idx")))  ])
    in
    While(comparison, exec)

let decompose_decforiter t n e s = 
    let comparison = Binop(Id("dfi_tmp_idx"), Leq, Call("len", [e]))
    in
    let exec = Block([ Expr(DecAssign(t, n, Access(e, Id("dfi_tmp_idx")))); s; Expr(Unop(Incr, Id("dfi_tmp_idx")))  ])
    in
    While(comparison, exec)
    
let clean_statements stmts = 
    let rec clean_statement stmt = match stmt with
        Block(s) -> Block(List.map clean_statement s)
      | Expr(expr) -> clean_expression expr 
      | For(e1, e2, e3, s) -> Block( [ Expr(e1); While(e2, Block([ s; Expr(e3); ]))  ])
      | ForIter(name, e2, s) -> Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_foriter name e2 s]) 
      | DecForIter(t, name, e2, s) -> Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_decforiter t name e2 s])
      | DeconstForIter(p, e, s) ->  Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_deconstforiter p e s])
      | _ -> stmt
    in
    (List.map clean_statement stmts)

let reshape_arrow_function fdecl = {
    typ=fdecl.typ;
    formals=fdecl.formals;
    fname=fdecl.fname;
    body = (match List.hd fdecl.body with
        Expr(e) -> [Return(e)]
      | _ -> [Return(Noexpr)]
      );
    autoreturn=false;
}
let clean_normal_function fdecl = { typ=fdecl.typ; formals=fdecl.formals; fname=fdecl.fname; body = (clean_statements fdecl.body); autoreturn=fdecl.autoreturn; }

let clean_function fdecl = if fdecl.autoreturn then reshape_arrow_function fdecl else clean_normal_function fdecl

let desugar (stmts, functions) = (clean_statements stmts, (List.map clean_function functions))
