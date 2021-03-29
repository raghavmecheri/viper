(* Semantic checking for the MicroC compiler *)

open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.

   Check each functionless statement, then check each function *)

let check (statements, functions) =

  (**** Check functions ****)

  (* Generate keys for functions in the symbol table.
     For user-defined functions, these unique keys allow for function overloading. *)
  let rec string_of_params params = match params with
      (typ, _) :: [] -> string_of_typ typ ^ ")"
    | (typ, _) :: p -> string_of_typ typ ^ ", " ^ string_of_params p
    | _             -> ")" 
  and key_string name params = name ^ " (" ^ string_of_params params in

  (* Collect function declarations for built-in functions: no bodies *)
  let built_in_func_decls = 
    let add_bind map (name, return_typ) = StringMap.add (key_string name []) {
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
      ("str", String) ]

  (* Add user-declared functions to the symbol table. *)
  (* The table's keys are strings built from the function name and its parameters' types. 
     By including parameter types in keys, the table can support overloaded functions. *)
  in let add_func map fd = 
    let key = key_string fd.fname fd.formals
    and built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "function " ^ fd.fname ^ " is already defined with params ("
    and make_err er = raise (Failure er)
    in match fd with
      (* No redefinitions of built-in functions *)
        _ when StringMap.mem fd.fname built_in_func_decls -> make_err built_in_err
      (* No duplicates, but allow for overloaded functions *)
      | _ when StringMap.mem key map -> make_err (dup_err ^ string_of_params fd.formals)
      | _ -> StringMap.add key fd map 

  (* Collect all function names into one symbol table *)
  in let function_decls = List.fold_left add_func built_in_func_decls functions

  (* Return a function from our symbol table *)
  in let find_func name params = 
    try StringMap.find (key_string name params) function_decls
    with Not_found -> raise (Failure ("function " ^ name ^ " with parameters " ^ string_of_params params ^ " does not exist"))
  
  (* Verify a list of declarations has no void types or duplicate names *)
  (* This is used to check function parameters and free-standing variable declarations *)

  (* Globally defined symbol table type (possible sol to duplicate variable checking)
  map variable name -> Ast.typ
  kill two birbs with one stone:
    1) duplicate var names
    2) valid types

  type symbol_table = {
    vars: ty StringMap.t;
    parent: symbol_table option;
  }
  
  *)

  in let check_decs kind decs =
    List.iter (function
        (Nah, b) -> raise (Failure ("illegal nah " ^ kind ^ " " ^ b))
      | _ -> ()) decs;
    let rec dups = function
      (* Problem: need to compare both dec and decassign, which are different types *)
      (* Possible solution: global set of string variables *)
        [] -> ()
      |	((_,n1) :: (_,n2) :: _) when n1 = n2 -> raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a) (_,b) -> compare a b) decs)
  
  in let check_function func =
    (* Make sure no function formals are void or duplicates *)
    check_decs "formal" func.formals;
  
    (* Raise an exception if the given rvalue type cannot be assigned to
       the given lvalue type *)
    (* May make more sense to move this down into check_expr *)
    in let check_assign lvaluet rvaluet err =
      if lvaluet = rvaluet then lvaluet else raise (Failure err)  

  (* Keep this b/c it allows compilation *)
  in (statements, functions)
(*)
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
    (* TODO: use viper AST types -> SAST types *)
    let rec expr = function
        IntegerLiteral  l -> (Int, SIntegerLiteral l)
      | CharacterLiteral l -> (Char, SCharacterLiteral l)
      | BoolLit l  -> (Bool, SBoolLiteral l)
      | FloatLiteral l -> (Float, SFloatLiteral l)
      | StringLiteral l -> (String, SStringLiteral l)
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
          | Dec -> check_dec dec

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