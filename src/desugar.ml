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
      | For(e1, e2, e3, s) -> Block([Expr(e1); While(e2, Block([ (clean_statement s); Expr(e3)]), Expr(e3))])
      | ForIter(name, e2, s) -> Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_foriter name e2 (clean_statement s)]) 
      | DecForIter(t, name, e2, s) -> Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_decforiter t name e2 (clean_statement s)])
      | DeconstForIter(p, e, s) ->  Block([ Expr(DecAssign(Int, "dfi_tmp_idx", IntegerLiteral(0))); decompose_deconstforiter p e (clean_statement s)])
      | While(e, s, iterator) -> While(clean_expression e, clean_statement s, clean_statement iterator)
      | If(cond, t, f) -> If(clean_expression cond, clean_statement t, clean_statement f)
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

(*
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
*)

let rec sanitize_expr e = match e with
    Binop(e1, op, e2) -> Binop((sanitize_expr e1), op, (sanitize_expr e2))
  | Unop(op, e) -> Unop(op, (sanitize_expr e))

  | Assign(n, e) -> Assign(n, (sanitize_expr e))
  | OpAssign(n, o, e) -> OpAssign(n, o, (sanitize_expr e))
  | DecAssign(t, n, e) -> DecAssign(t, n, (sanitize_expr e))
  | AccessAssign(e1, e2, e3) -> AccessAssign((sanitize_expr e1), (sanitize_expr e2), (sanitize_expr e3))
  
  | Call(n, l) -> Call(n, (List.map sanitize_expr l))
  | AttributeCall(e, f, args) -> Call(f, List.map sanitize_expr (e::args))
  | Ternop(e, e1, e2) -> Id("ternop_tempvar")
  | _ -> e

let rec decompose_nested_ternary e e1 e2 = match e2 with
    Ternop(e', e1', e2') -> If(e, Expr(Assign("ternop_tempvar", e1)), (decompose_nested_ternary e' e1' e2'))
  | _ -> If(e, Expr(Assign("ternop_tempvar", e1)), Expr(Assign("ternop_tempvar", e2)))

let rec check_for_ternary e t = match e with
    DecAssign(t, n, e) -> check_for_ternary e t
  | Ternop(e, e1, e2) -> (true, decompose_nested_ternary e e1 e2, "ternary_tmpvar", t)
  | _ -> (false, PretendBlock([]), "ternary_tempvar_none", Int)

let sanitize_ternaries stmts =
    let generate_pb_if_needed e =
        let (to_sanitize, required_stmt, name, t) = (check_for_ternary e Int) in
        if to_sanitize then PretendBlock([ Dec(t, "ternop_tempvar"); required_stmt; Expr(sanitize_expr e) ]) else Expr(e)
    in

    (* int a = TERNARY *)
    let check_stmt stmt = match stmt with
    Expr(e) -> generate_pb_if_needed e 
  | _ -> stmt

    in List.map check_stmt stmts

let sanitize_ternaries_f fdecl = { typ=fdecl.typ; formals=fdecl.formals; fname=fdecl.fname; body = (sanitize_ternaries fdecl.body); autoreturn=fdecl.autoreturn; }

let desugar (stmts, functions) = 
  let cleaned_statements = clean_statements stmts in
  let cleaned_functions = List.map clean_function functions in
  let adjusted_statements = sanitize_ternaries cleaned_statements in
  let adjusted_functions = List.map sanitize_ternaries_f cleaned_functions in
  (adjusted_statements, adjusted_functions)
