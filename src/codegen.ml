module L = Llvm
module A = Ast
open Cast
open Sast

exception Error of string

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module 
   a viper program consists of statements and function defs
*)
let translate (_, functions) =
  let context    = L.global_context () in

  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "Viper" in

  (* define llytype variables *)
  let i64_t      = L.i64_type    context
  and i32_t      = L.i32_type    context
  and i16_t      = L.i16_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context in
  let str_t      = L.pointer_type i8_t
  in

  (* Return the LLVM lltype for a Viper type *)
  let rec ltype_of_typ = function
      A.Int               -> i64_t
    | A.Bool              -> i1_t
    | A.Nah               -> void_t
    | A.Char              -> i16_t
    | A.Float             -> float_t
    | A.String            -> str_t
    | A.Array(_)          -> raise (Error "Array lltype not implemented")
    | A.Function(t)       -> (ltype_of_typ t)
    | A.Group(_)          -> raise (Error "Group lltype not implemented")
    | A.Dictionary(_, _)  -> raise (Error "Dictionary lltype not implemented")
  in

  (* function to return initial value for a declaration*)
  let rec lvalue_of_typ typ = function
      A.Int | A.Bool | A.Nah | A.Char -> L.const_int (ltype_of_typ typ) 0
    | A.Float                         -> L.const_float (ltype_of_typ typ) 0.0
    | A.String                        -> L.const_pointer_null (ltype_of_typ typ)
    | A.Array(_)                      -> raise (Error "Array lltype not implemented")
    | A.Group(_)                      -> raise (Error "Group lltype not implemented")
    | A.Dictionary(_, _)              -> raise (Error "Dictionary lltype not implemented")
    | A.Function(_)                   -> raise (Error "What should a function init be ?")
  in

  (* Define built-in functions at top of every file *)  
  let printf_t : L.lltype = 
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
    L.declare_function "printf" printf_t the_module in

  (* Define each function (arguments and return type) so we can 
     call it even before we've created its body *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types = 
        Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in

  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    (* TODO: move this so it wont get redefined for every function declaration *)
    let char_format_str = L.build_global_stringptr "%c\n" "fmt" builder
    and int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and str_format_str = L.build_global_stringptr "%s\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder
    in

    (* determines appropriate printf format string for given literal *)
    (* TODO: type inference for which print format string to use*)
    (* let get_format_str (_, params) = match params with
        SIntegerLiteral(_) -> int_format_str
       | SStringLiteral(_) -> str_format_str
       | SCharacterLiteral(_) -> char_format_str
       | SFloatLiteral(_) -> float_format_str
       | SBoolLiteral(_) -> str_format_str
       | _ -> raise (Error "print passed an invalid/unimplemented literal")
       in *)

    let get_format_str (t, _) = match t with
        A.Int -> int_format_str
      | A.Char -> char_format_str
      | A.String -> str_format_str
      | _ -> raise (Error "print passed an invalidtype")
    in

    (* create empty local_vars Hashtbl*)
    let local_vars:(string, L.llvalue) Hashtbl.t = Hashtbl.create 50 in

    (* function takes in a formal binding and parameter values to add to map*)
    let add_formal (t, n) p = 
      L.set_value_name n p;
      let local = L.build_alloca (ltype_of_typ t) n builder in
      ignore (L.build_store p local builder);
      Hashtbl.add local_vars n local;
    in 

    (* iterate over the list of formal bindings and their values to add to local_vars *)
    let _ = List.iter2 add_formal fdecl.sformals (Array.to_list (L.params the_function)) in

    (* Return the value for a variable or formal argument *)
    (* let print_vars key value = print_string (key ^ " " ^ value ^ "\n") in *)
    let lookup n = try Hashtbl.find local_vars n
      with Not_found -> raise (Error "variable not found in locals map")
    in

    (* LLVM insists each basic block end with exactly one "terminator" 
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in

    let rec expr builder ((_, e) : sexpr) = match e with
        SIntegerLiteral(num)      -> L.const_int (ltype_of_typ A.Int) num
      | SCharacterLiteral(chr)    -> L.const_int (ltype_of_typ A.Char) (Char.code chr)
      | SBoolLiteral(bln)         -> L.const_int i1_t (if bln then 1 else 0)
      | SFloatLiteral(flt)        -> L.const_float (ltype_of_typ A.Float) flt
      | SStringLiteral(str)       -> L.build_global_stringptr str "" builder
      | SListLiteral(list)        -> raise (Error "SListLiteral not implemented")
      | SDictElem(e1, e2)         -> raise (Error "SDictElem not implemented")
      | SDictLiteral(list)        -> raise (Error "SDictLiteral not implemented")

      | SId s                     -> L.build_load (lookup s) s builder
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

      | SUnop(op, ((t, _) as e)) ->
        let e' = expr builder e in
        (match op with
           A.Neg when t = A.Float -> L.build_fneg 
         | A.Neg                  -> L.build_neg
         | A.Not                  -> L.build_not 
         | A.Incr                 -> raise (Error "Incr not implemented")
         | A.Decr                 -> raise (Error "Decr not implemented")
        ) e' "tmp" builder

      | SAssign (s, e)            -> 
        let e' = expr builder e in
        ignore(L.build_store e' (lookup s) builder); e'
      | SDeconstruct(v, e)        -> raise (Error "SDeconstruct not implemented")
      | SOpAssign(v, o, e)        ->
        (* compute value to assign *)
        let value = expr builder (A.Nah, SBinop( (A.Nah, SId(v)), o, e)) in
        (* assign result to variable*)
        ignore(L.build_store value (lookup v) builder); value
      | SDecAssign(t, s, e)       -> 
        let local_var = L.build_alloca (ltype_of_typ t) s builder in
        Hashtbl.add local_vars s local_var;
        let e' = expr builder e in
        ignore(L.build_store e' (lookup s) builder); e'
      | SAccess(e, l)             -> raise (Error "SAccess not implemented")
      | SAccessAssign(i, idx, e)  -> raise (Error "SAccessAssign not implemented")

      (* hardcoded SCalls for built-ins *)
      | SCall ("print", [params]) -> let print_value = (get_print_value builder params)
        in L.build_call printf_func [| (get_format_str params) ; print_value |] "printf" builder
      | SCall("toChar", params) -> expr builder (Cast.to_char params)
      | SCall("toInt", params) -> expr builder (Cast.to_int params)
      | SCall("toFloat", params) -> expr builder (Cast.to_float params)
      | SCall("toBool", params) -> expr builder (Cast.to_bool params)
      | SCall("toString", params) -> 
          let cast_val = expr builder (Cast.verify_params params "string") 
          in expr builder (Cast.to_string cast_val)
      | SCall("toNah", params) -> expr builder (Cast.to_nah params)

      (* SCall for user defined functions *)
      | SCall (f, args)           -> 
        let (fdef, fdecl) = StringMap.find f function_decls in
        let llargs = List.rev (List.map (expr builder) (List.rev args)) in
        let result = (match fdecl.styp with 
              A.Nah -> ""
            | _ -> f ^ "_result") in
        L.build_call fdef (Array.of_list llargs) result builder

      (* this is so sketch lol*)
      | SAttributeCall(e, f, el)  -> expr builder (A.Nah, SCall(f, e::el))
      | SNoexpr                   -> L.const_int i32_t 0
      | _ -> raise (Error "Expression match not implemented")

    and
      (* used to map bool values to strings for printf *)
      get_print_value builder (t, e) = match e with
        SBoolLiteral(bln) -> let strlit = (SStringLiteral (if bln then "true" else "false"))
        in expr builder (A.Bool, strlit)
      | _ -> expr builder (t, e)
    in

    let rec stmt builder = function
      | SBlock sl                               -> List.fold_left stmt builder sl
      | SExpr e                                 -> ignore(expr builder e); builder
      | SDec (t, n)                             -> 
        let local_var = L.build_alloca (ltype_of_typ t) n builder
        in Hashtbl.add local_vars n local_var; builder
      | SReturn e -> ignore(match fdecl.styp with
          (* Special "return nothing" instr *)
            A.Nah -> L.build_ret_void builder 
          (* Build return statement *)
          | _ -> L.build_ret (expr builder e) builder );
        builder
      | SSkip expr                              -> raise (Error "Skip statement not implemented")
      | SAbort expr                             -> raise (Error "Abort statement not implemented")
      | SPanic expr                             -> raise (Error "Panic statement not implemented")

      (* this if and while is straight from microc if issues arise *)
      | SIf (predicate, then_stmt, else_stmt)   -> 
        let bool_val = expr builder predicate in
        let merge_bb = L.append_block context "merge" the_function in
        let build_br_merge = L.build_br merge_bb in (* partial function *)

        let then_bb = L.append_block context "then" the_function in
        add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
          build_br_merge;

        let else_bb = L.append_block context "else" the_function in
        add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
          build_br_merge;

        ignore(L.build_cond_br bool_val then_bb else_bb builder);
        L.builder_at_end context merge_bb

      | SWhile (predicate, body) ->
        let pred_bb = L.append_block context "while" the_function in
        ignore(L.build_br pred_bb builder);

        let body_bb = L.append_block context "while_body" the_function in
        add_terminal (stmt (L.builder_at_end context body_bb) body)
          (L.build_br pred_bb);

        let pred_builder = L.builder_at_end context pred_bb in
        let bool_val = expr pred_builder predicate in

        let merge_bb = L.append_block context "merge" the_function in
        ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
        L.builder_at_end context merge_bb
      | _                                       -> raise (Error "Statement match not implemented")
    in 

    (* Build the code for each statement in the function *)
    let builder = stmt builder (SBlock fdecl.sbody) in

    (* Add a return if the last block falls off the end *)
    (* TODO: do we need this or does semantic checking check for this? *)
    add_terminal builder (match fdecl.styp with
          A.Nah -> L.build_ret_void
        | A.Float -> L.build_ret (L.const_float float_t 0.0)
        | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  (* build all function bodies *)
  let _ = List.map build_function_body functions in

  (* return the LLVM module *)
  the_module


(* Old code, may be useful if we try to implement globals *)

(* Define main function for top-level, should be built like any other function *)
(* let main_t = L.function_type i32_t [| |] in
   let main_f = L.define_function "main" main_t the_module in

   (* main function builder *)
   let builder = L.builder_at_end context (L.entry_block main_f) in *)

(* format characters for printf *)

(* let build_main st = match st with 
   | SExpr e -> ignore(expr builder e); builder
   | _ -> raise (Error "Statement match not implemented")
   in  *)

(* 
  let rec build_main st = function
    | SBlock sl                               -> raise (Error "Block statement not implemented") (* List.fold_left build_main sl *)
    | SExpr e                                 -> ignore(expr builder e); builder
    | SDec (t, v)                             -> raise (Error "Dec statement not implemented")
    | SReturn e                               -> raise (Error "Return statement not implemented")
    | SSkip expr                              -> raise (Error "Skip statement not implemented")
    | SAbort expr                             -> raise (Error "Abort statement not implemented")
    | SPanic expr                             -> raise (Error "Panic statement not implemented")
    | SIf (predicate, then_stmt, else_stmt)   -> raise (Error "If statement not implemented")
    | SWhile (predicate, body)                -> raise (Error "While statement not implemented")
    | _ -> raise (Error "Statement match not implemented for stmt builder")
  in  *)

(* build a main function around top-level statements *)
(* let _ = List.map build_main (List.rev statements) in

   (* add a return statement to the main function *)
   let _ = L.build_ret (L.const_int i32_t 0) builder in *)