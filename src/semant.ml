(* Semantic checking for the MicroC compiler *)

open Ast
let placeholderCheck ast = ast

exception SemanticException of string

let rec clean_pattern_rec e base = match e with
    ConditionalPattern(cond, exp) :: [] -> Ternop(cond, exp, base)
  | ConditionalPattern(cond, exp) :: tail -> Ternop(cond, exp, (clean_pattern_rec tail base))
  | _ -> Noexpr


let rec clean_expression expr = match expr with
    MatchPattern(p, b) -> clean_expression (clean_pattern_rec p b)
  | PatternMatch(s, e) -> Assign(s, clean_expression e)
  | DecPatternMatch(t, s, e) -> DecAssign(t, s, clean_expression e)
  | Ternop(e, e1, e2) -> Ternop((clean_expression e), (clean_expression e1), (clean_expression e2))

  | Binop(e1, op, e2) -> Binop((clean_expression e1), op, (clean_expression e2))
  | Unop(op, e) -> Unop(op, (clean_expression e))

  | Assign(n, e) -> Assign(n, (clean_expression e))
  | OpAssign(n, o, e) -> OpAssign(n, o, (clean_expression e))
  | DecAssign(t, n, e) -> DecAssign(t, n, (clean_expression e))
  | AccessAssign(e1, e2, e3) -> AccessAssign((clean_expression e1), (clean_expression e2), (clean_expression e3))
  
  | Call(n, l) -> Call(n, (List.map clean_expression l))
  | AttributeCall(e, f, args) -> Call(f, List.map clean_expression (e::args))

  | _ -> expr

let decompose_deconstforiter n e s = 
    let comparison = Binop(Id("dfi_tmp_idx"), Leq, Call("len", [e]))
    in
    let (idx_t, idx_name) = List.hd n
    in
    let (el_t, el_name) = List.hd (List.rev n)
    in
    let exec = Block([ Expr(DecAssign(idx_t, idx_name, Id("dfi_tmp_idx"))); Expr(DecAssign(el_t, el_name, Access(e, Id("dfi_tmp_idx")))); s; Expr(Unop(Incr, Id("dfi_tmp_idx")))  ])
    in
    While(comparison, exec, Expr(Noexpr))

let decompose_foriter n e s = 
    let comparison = Binop(Id("dfi_tmp_idx"), Leq, Call("len", [e]))
    in
    let (iterator : Ast.stmt) = Expr(Unop(Incr, Id("dfi_tmp_idx"))) in
    let exec = Block([ Expr(Assign(n, Access(e, Id("dfi_tmp_idx")))); s; iterator])
    in
    While(comparison, exec, iterator)

let decompose_decforiter t n e s = 
    let comparison = Binop(Id("dfi_tmp_idx"), Leq, Call("len", [e]))
    in
    let exec = Block([ Expr(DecAssign(t, n, Access(e, Id("dfi_tmp_idx")))); s; Expr(Unop(Incr, Id("dfi_tmp_idx")))  ])
    in
    While(comparison, exec, Expr(Noexpr))
    
let clean_statements stmts = 
    let rec clean_statement stmt = match stmt with
        Block(s) -> Block(List.map clean_statement s)
      | Expr(expr) -> Expr(clean_expression expr) 
      | For(e1, e2, e3, s) -> Block( [ Expr(e1); While(e2, Block([ (clean_statement s); Expr(e3)]), Expr(e3))  ])
      | ForIter(name, e2, s) -> Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_foriter name e2 (clean_statement s)]) 
      | DecForIter(t, name, e2, s) -> Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_decforiter t name e2 (clean_statement s)])
      | DeconstForIter(p, e, s) ->  Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_deconstforiter p e (clean_statement s)])
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

let rec eliminate_ternaries stmts =
  let new_functions = [] in

  let rec eliminate_ternaries_from_expr expr = match expr with
      Ternop(e, e1, e2) -> (* Do something here, return append_function_call + do recursively *)
    | _ -> expr
  in 

  let rec clean_statement = match stmt with
    Expr(e) -> eliminate_ternaries_from_expr e
  | _ -> stmt
  in

  let cleaned_stmts = List.map clean_statement stmts in
  (cleaned_stmts, new_functions)


let desugar (stmts, functions) = 
  let cleaned_statements = clean_statements stmts in
  let cleaned_functions = List.map clean_function functions in
  let (adjusted_statements, new_functions) = eliminate_ternaries cleaned_statements in
  let adusted_functions = add_adjusted_functions cleaned_functions new_functions
  (adjusted_statements, adusted_functions)
