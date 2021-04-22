module L = Llvm
module A = Ast
open Sast

exception Error of string

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module 
   a viper program is statements and function defs
*)
let translate (statements, functions) =
  let context    = L.global_context () in

  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "Viper" in

  (* Get types from the context *)
  let i64_t      = L.i64_type    context
  and i32_t      = L.i32_type    context
  and i16_t      = L.i16_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context
  in

  (* Return the LLVM type for a Viper primitive type *)
  let rec ltype_of_typ = function
      A.Int   -> i64_t
    | A.Char  -> i16_t
    | A.Float -> float_t
    | A.Bool  -> i1_t
    | A.Nah   -> void_t
    | A.Function(t) -> (ltype_of_typ t)
    | _       -> raise (Error "Argument is not implemented or is not a Viper type")
  in

  (* Define built-in functions at top of every file *)  
  let printf_t : L.lltype = 
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
    L.declare_function "printf" printf_t the_module in

  (* Define main function for top-level, should be built like any other function *)
  let main_t = L.function_type i32_t [| |] in
  let main_f = L.define_function "main" main_t the_module in

  (* Define each function (arguments and return type) so we can 
     call it even before we've created its body *)
  (* let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
     let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types = 
        Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
     List.fold_left function_decl StringMap.empty functions in *)

  (* main function builder *)
  let builder = L.builder_at_end context (L.entry_block main_f) in

  (* format characters for printf *)
  let char_format_str = L.build_global_stringptr "%c\n" "fmt" builder
  and int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
  and str_format_str = L.build_global_stringptr "%s\n" "fmt" builder
  and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder
  in

  (* determines appropriate printf format string for given literal *)
  (* TODO: type inference for which print format string to use*)
  let get_format_str (_, params) = match params with
      SIntegerLiteral(_) -> int_format_str
    | SStringLiteral(_) -> str_format_str
    | SCharacterLiteral(_) -> char_format_str
    | SFloatLiteral(_) -> float_format_str
    | SBoolLiteral(_) -> str_format_str
    | _ -> raise (Error "print passed an invalid/unimplemented literal")
  in

  (* expression evaluation function *)
  let rec expr builder ((_, e) : sexpr) = match e with
      SIntegerLiteral(num)      -> L.const_int (ltype_of_typ A.Int) num
    | SCharacterLiteral(chr)    -> L.const_int (ltype_of_typ A.Char) (Char.code chr)
    | SBoolLiteral(bln)         -> L.const_int i1_t (if bln then 1 else 0)
    | SFloatLiteral(flt)        -> L.const_float (ltype_of_typ A.Float) flt
    | SStringLiteral(str)       -> L.build_global_stringptr str "str" builder
    | SId s                     -> raise (Error "SId not implemented")
    | SAssign (s, e)            -> raise (Error "SAssign not implemented")
    | SDecAssign (t, s, e)      -> raise (Error "SDecAssign not implemented")
    | SListLiteral(list)        -> raise (Error "SListLiteral not implemented")
    | SDictElem(e1, e2)         -> raise (Error "SDictElem not implemented")
    | SDictLiteral(list)        -> raise (Error "SDictLiteral not implemented")
    (* | SId s                     -> L.build_load (global_lookup s) s builder *)
    (* | SAssign (s, e) -> let e' = expr builder e in
       ignore(L.build_store e' (global_lookup s) builder); e'
       | SDecAssign (t, s, e) -> let e' = expr builder e in
       ignore(L.build_store e' (global_lookup s) builder); e' *)
    | SUnop(op, ((t, _) as e)) ->
      let e' = expr builder e in
      (match op with
         A.Neg when t = A.Float -> L.build_fneg 
       | A.Neg                  -> L.build_neg
       | A.Not                  -> L.build_not 
       | A.Incr                 -> raise (Error "Incr not implemented")
       | A.Decr                 -> raise (Error "Decr not implemented")
      ) e' "tmp" builder
    | SBinop (e1, op, e2) ->
      let e1' = expr builder e1
      and e2' = expr builder e2 in
      (match op with
         A.Add     -> L.build_add
       | A.Sub     -> L.build_sub
       | A.Mult    -> L.build_mul
       | A.Div     -> L.build_sdiv
       | A.And     -> L.build_and
       | A.Or      -> L.build_or
       | A.Equal   -> L.build_icmp L.Icmp.Eq
       | A.Neq     -> L.build_icmp L.Icmp.Ne
       | A.Less    -> L.build_icmp L.Icmp.Slt
       | A.Leq     -> L.build_icmp L.Icmp.Sle
       | A.Greater -> L.build_icmp L.Icmp.Sgt
       | A.Geq     -> L.build_icmp L.Icmp.Sge
       | A.Mod     -> raise (Error "Mod not implemented")
       | A.Has     -> raise (Error "Has not implemented")
      ) e1' e2' "tmp" builder
    | SCall ("print", [params]) -> let print_value = (get_print_value builder params)
      in L.build_call printf_func [| (get_format_str params) ; print_value |] "printf" builder
    | SCall (f, args) -> raise (Error "SCall not implemented")
    (* let (fdef, fdecl) = StringMap.find f function_decls in
       let llargs = List.rev (List.map (expr builder) (List.rev args)) in
       let result = (match fdecl.styp with 
          A.Nah -> ""
        | _ -> f ^ "_result") in
       L.build_call fdef (Array.of_list llargs) result builder *)
    | _ -> raise (Error "Expression match not implemented")

  and
    get_print_value builder (t, e) = match e with
      SBoolLiteral(bln) -> let strlit = (SStringLiteral (if bln then "true" else "false"))
      in expr builder (A.Bool, strlit)
    | _ -> expr builder (t, e)
  in

  let build_main st = match st with 
    | SExpr e -> ignore(expr builder e); builder
    | _ -> raise (Error "Statement match not implemented")
  in 

  (* MAIN BUILDING CODE (statements)*)

  (* build a main function around top-level statements *)
  let _ = List.map build_main (List.rev statements) in

  (* add a return statement to the main function *)
  let _ = L.build_ret (L.const_int i32_t 0) builder in

  (* return the LLVM module *)
  the_module

(* FUNCTION BUILDING CODE (functions)*)

(* Fill in the body of the given function *)
(* let build_function_body fdecl =
   let (the_function, _) = StringMap.find fdecl.sfname function_decls in
   let builder = L.builder_at_end context (L.entry_block the_function) in

   let rec stmt builder = function
    | SBlock sl                               -> List.fold_left stmt builder sl
    | SExpr e                                 -> ignore(expr builder e); builder
    | SDec (t, v)                             -> raise (Error "Dec statement not implemented")
    | SReturn e -> ignore(match fdecl.styp with
        (* Special "return nothing" instr *)
          A.Nah -> L.build_ret_void builder 
        (* Build return statement *)
        | _ -> L.build_ret (expr builder e) builder );
      builder
    | SSkip expr                              -> raise (Error "Skip statement not implemented")
    | SAbort expr                             -> raise (Error "Abort statement not implemented")
    | SPanic expr                             -> raise (Error "Panic statement not implemented")
    | SIf (predicate, then_stmt, else_stmt)   -> raise (Error "If statement not implemented")
    | SWhile (predicate, body)                -> raise (Error "While statement not implemented")
    | _ -> raise (Error "Statement match not implemented for stmt builder")
   in 

   (* LLVM insists each basic block end with exactly one "terminator" 
     instruction that transfers control.  This function runs "instr builder"
     if the current block does not already have a terminator.  Used,
     e.g., to handle the "fall off the end of the function" case. *)
   let add_terminal builder instr =
    match L.block_terminator (L.insertion_block builder) with
      Some _ -> ()
    | None -> ignore (instr builder) in

   (* Build the code for each statement in the function *)
   let builder = stmt builder (SBlock fdecl.sbody) in

   (* Add a return if the last block falls off the end *)
   add_terminal builder (match fdecl.styp with
        A.Nah -> L.build_ret_void
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
   in

   (* build all function bodies *)
   List.iter build_function_body functions; *)



(* GLOBALS ARE A NO GO ATM, WILL FIGURE OUT LATER *)

(* Create a map of global variables *)
(* let global_vars : L.llvalue StringMap.t = StringMap.empty in

   (* function to retrieve a global variable*)
   let global_lookup n = StringMap.find n global_vars in

   (* function to initialize a global variable to 0 on declaration *)
   let global_init m (t, n) = match t with
    A.Float   -> L.const_float (ltype_of_typ t) 0.0
   | A.Int     -> L.const_int (ltype_of_typ t) 0
   | _         -> raise (Error "Variable type init not defined") 
   in *)

(* function to assign a new value to global variable on declaration *)
(* let global_assign = 
   in *)

(* let global_var m (t, n) = 
   let init = match t with
     A.Float -> L.const_float (ltype_of_typ t) 0.0
   | _ -> L.const_int (ltype_of_typ t) 0
   in StringMap.add n (L.define_global n init the_module) m in
   List.fold_left global_var StringMap.empty globals in *)