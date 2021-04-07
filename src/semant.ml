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
  | _ -> Expr(expr)

let clean_statements stmts = 
    let rec clean_statement stmt = match stmt with
        Block(s) -> Block(List.map clean_statement s)
      | Expr(expr) -> clean_expression expr
      | For(e1, e2, e3, s) -> Block( [ Expr(e1); While(e2, Block([ s; Expr(e3); ]))  ])
      | _ -> stmt
    in
    (List.map clean_statement stmts) 

let reshape_arrow_function fdecl = ignore (fdecl.body = (match List.hd fdecl.body with
    Expr(e) -> [Return(e)]
  | _ -> [Return(Noexpr)]
  )); ignore (fdecl.autoreturn = false); fdecl

let clean_function fdecl = if fdecl.autoreturn then reshape_arrow_function fdecl else (ignore(fdecl.body = clean_statements fdecl.body); fdecl)

let desugar (stmts, functions) = (clean_statements stmts, (List.map clean_function functions))

(*
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.

   Check each global variable, then check each function *)

let check (globals, functions) =

  (* Verify a list of bindings has no void types or duplicate names *)
  (* Since a program in Viper consists of stmt and func decls, it may make more sense to move check_binds
     inside of check_stmts *)
  let check_binds (kind : string) (binds : bind list) =
    List.iter (function
	      (Nah, b) -> raise (Failure ("illegal nah " ^ kind ^ " " ^ b))
      | _ -> ()) binds;
    let rec dups = function
        [] -> ()
      |	((_,n1) :: (_,n2) :: _) when n1 = n2 -> raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a) (_,b) -> compare a b) binds)
  in

  (**** Check global variables ****)

  check_binds "global" globals;

  (**** Check functions ****)

  (* Collect function declarations for built-in functions: no bodies *)
  let built_in_func_decls = 
    let add_bind map (name, return_typ) = StringMap.add name {
      typ = return_typ;
      fname = name; 
      formals = [];
      body = [];
      autoreturn = false;
    } map in List.fold_left add_bind StringMap.empty [ 
      ("print", Nah);
      ("len", Int);
      ("char", Char);
      ("float", Float);
      ("int", Int);
      ("bool", Bool);
      ("str", String); ]
  in

  (* Add function name to symbol table *)
  let add_func map fd = 
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "function " ^ fd.fname ^ " is already defined"
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    in match fd with
      (* No redefinitions of built-in functions *)
        _ when StringMap.mem n built_in_func_decls -> make_err built_in_err
      (* No duplicates, but allow for overloaded functions *)
      | _ when StringMap.mem n map -> 
        let dup_func = StringMap.find n map in
          (* Checks for duplicate parameters, allowing overloaded functions *)
          (let rec comp_formals l1 l2 = match l1, l2 with
              [], [] -> make_err dup_err 
            | (typ1, _) :: r1, (typ2, _) :: r2 when typ1 = typ2 -> comp_formals r1 r2
            | (typ1, _) :: r1, (typ2, _) :: r2 when typ1 != typ2 -> StringMap.add n fd map
            | [], _ -> StringMap.add n fd map
            | _, [] -> StringMap.add n fd map
          in comp_formals fd.formals dup_func.formals)
      | _ -> StringMap.add n fd map 
  in

  (* Collect all function names into one symbol table *)
  let function_decls = List.fold_left add_func built_in_func_decls functions
  in
  
  (* Return a function from our symbol table *)
  let find_func s = 
    try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let _ = find_func "main" in (* Ensure "main" is defined *)

  let check_function func =
    (* Make sure no formals or locals are void or duplicates *)
    check_binds "formal" func.formals;
    (*check_binds "local" func.locals;*)

    (* Raise an exception if the given rvalue type cannot be assigned to
       the given lvalue type *)
    let check_assign lvaluet rvaluet err =
       if lvaluet = rvaluet then lvaluet else raise (Failure err)
    in   

    (* Build local symbol table of variables for this function *)
    let symbols = List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
	                StringMap.empty (globals @ func.formals @ func.locals )
    in

    (* Return a variable from our local symbol table *)
    let type_of_identifier s =
      try StringMap.find s symbols
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr = function
        Literal  l -> (Int, SLiteral l)
      | Fliteral l -> (Float, SFliteral l)
      | BoolLit l  -> (Bool, SBoolLit l)
      | Noexpr     -> (Void, SNoexpr)
      | Id s       -> (type_of_identifier s, SId s)
      | Assign(var, e) as ex -> 
          let lt = type_of_identifier var
          and (rt, e') = expr e in
          let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
            string_of_typ rt ^ " in " ^ string_of_expr ex
          in (check_assign lt rt err, SAssign(var, (rt, e')))
      | Unop(op, e) as ex -> 
          let (t, e') = expr e in
          let ty = match op with
            Neg when t = Int || t = Float -> t
          | Not when t = Bool -> Bool
          | _ -> raise (Failure ("illegal unary operator " ^ 
                                 string_of_uop op ^ string_of_typ t ^
                                 " in " ^ string_of_expr ex))
          in (ty, SUnop(op, (t, e')))
      | Binop(e1, op, e2) as e -> 
          let (t1, e1') = expr e1 
          and (t2, e2') = expr e2 in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Mult | Div when same && t1 = Int   -> Int
          | Add | Sub | Mult | Div when same && t1 = Float -> Float
          | Equal | Neq            when same               -> Bool
          | Less | Leq | Greater | Geq
                     when same && (t1 = Int || t1 = Float) -> Bool
          | And | Or when same && t1 = Bool -> Bool
          | _ -> raise (
	      Failure ("illegal binary operator " ^
                       string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                       string_of_typ t2 ^ " in " ^ string_of_expr e))
          in (ty, SBinop((t1, e1'), op, (t2, e2')))
      | Call(fname, args) as call -> 
          let fd = find_func fname in
          let param_length = List.length fd.formals in
          if List.length args != param_length then
            raise (Failure ("expecting " ^ string_of_int param_length ^ 
                            " arguments in " ^ string_of_expr call))
          else let check_call (ft, _) e = 
            let (et, e') = expr e in 
            let err = "illegal argument found " ^ string_of_typ et ^
              " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
            in (check_assign ft et err, e')
          in 
          let args' = List.map2 check_call fd.formals args
          in (fd.typ, SCall(fname, args'))
    in

    let check_bool_expr e = 
      let (t', e') = expr e
      and err = "expected Boolean expression in " ^ string_of_expr e
      in if t' != Bool then raise (Failure err) else (t', e') 
    in

    (* Return a semantically-checked statement i.e. containing sexprs *)
    let rec check_stmt = function
        Expr e -> SExpr (expr e)
      | If(p, b1, b2) -> SIf(check_bool_expr p, check_stmt b1, check_stmt b2)
      | For(e1, e2, e3, st) ->
	  SFor(expr e1, check_bool_expr e2, expr e3, check_stmt st)
      | While(p, s) -> SWhile(check_bool_expr p, check_stmt s)
      | Return e -> let (t, e') = expr e in
        if t = func.typ then SReturn (t, e') 
        else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_expr e))
	    
	    (* A block is correct if each statement is correct and nothing
	       follows any Return statement.  Nested blocks are flattened. *)
      | Block sl -> 
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
          in SBlock(check_stmt_list sl)

    in (* body of check_function *)
    { styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      slocals  = func.locals;
      sbody = match check_stmt (Block func.body) with
	SBlock(sl) -> sl
      | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
  in (globals, List.map check_function functions)


*)
