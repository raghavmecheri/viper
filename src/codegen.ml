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
  and void_t     = L.void_type   context 
  and struct_t   = L.struct_type context in
  let str_t      = L.pointer_type i8_t
  in

  (* STRUCT CODE HERE *)

  (* create hashtbl for the structs we use in standard library *)
  let struct_types:(string, L.lltype) Hashtbl.t = Hashtbl.create 3 in

  (* lookup struct type *)
  let find_struct_type name = try Hashtbl.find struct_types name 
    with Not_found -> raise (Error "Invalid struct name")
  in 

  (* declare struct type *)
  let declare_struct_typ name =
    let struct_type = L.named_struct_type context name in
    Hashtbl.add struct_types name struct_type
  in

  (* build struct body *)
  let define_struct_body name lltypes = 
    let struct_type = try Hashtbl.find struct_types name
      with Not_found -> raise (Error "undefined struct typ") in
    L.struct_set_body struct_type lltypes false
  in

  (* declare list struct*)
  let _ = declare_struct_typ "list"
  and _ = define_struct_body "list" [| L.pointer_type (L.pointer_type i8_t); i32_t; i32_t; L.pointer_type i8_t |]

  (* declare dict_elem struct*)
  and _ = declare_struct_typ "dict_elem"
  and _ = define_struct_body "dict_elem" [| L.pointer_type i8_t; L.pointer_type i8_t |]

  (* declare dict struct*)
  and _ = declare_struct_typ "dict"
  and _ = define_struct_body "dict" [| (find_struct_type "list"); L.pointer_type i8_t; L.pointer_type i8_t |] 
  in

  (* Return the LLVM lltype for a Viper type *)
  let rec ltype_of_typ = function
      A.Int               -> i32_t
    | A.Bool              -> i1_t
    | A.Nah               -> void_t
    | A.Char              -> i8_t
    | A.Float             -> float_t
    | A.String            -> str_t
    | A.Array(_)          -> (L.pointer_type (find_struct_type "list"))
    | A.Function(t)       -> (ltype_of_typ t)
    | A.Group(_)          -> raise (Error "Group lltype not implemented")
    | A.Dictionary(_, _)  -> raise (Error "Dictionary lltype not implemented")
  in

  (* Return initial value for a declaration *)
  let rec lvalue_of_typ typ = function
      A.Int | A.Bool | A.Nah | A.Char -> L.const_int (ltype_of_typ typ) 0
    | A.Float                         -> L.const_float (ltype_of_typ typ) 0.0
    | A.String                        -> L.const_pointer_null (ltype_of_typ typ)
    | A.Array(_)                      -> raise (Error "Array llvalue not implemented")
    | A.Group(_)                      -> raise (Error "Group llvalue not implemented")
    | A.Dictionary(_, _)              -> raise (Error "Dictionary llvalue not implemented")
    | A.Function(_)                   -> raise (Error "What should a function init value be ?")
  in

  (* BUILT-IN FUNCTIONS HERE*)

  (* Define built-in functions at top of every file *)  
  let printf_t : L.lltype = 
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
    L.declare_function "printf" printf_t the_module in

  let pow2_t : L.lltype = 
    L.function_type float_t [| float_t |] in
  let pow2_func : L.llvalue = 
    L.declare_function "pow2" pow2_t the_module in

  (* BUILTIN LIST FUNCTIONS HERE*)

  (* takes in a char pointer to a string of the type *)
  let create_list_t : L.lltype =
    L.function_type (L.pointer_type (find_struct_type "list")) [| L.pointer_type i8_t |] in
  let create_list_func : L.llvalue = 
    L.declare_function "create_list" create_list_t the_module in

  (* takes in a list and an int and returns the index of the list *)
  let access_char_t : L.lltype =
    L.function_type (ltype_of_typ A.Char) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Int) |] in
  let access_char_func : L.llvalue = 
    L.declare_function "access_char" access_char_t the_module in

  (* takes in a list and an int and returns the index of the list *)
  let access_int_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Int)|] in
  let access_int_func : L.llvalue = 
    L.declare_function "access_int" access_int_t the_module in

  (* takes in a list and a char to append *)
  let append_char_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Char) |] in
  let append_char_func : L.llvalue = 
    L.declare_function "append_char" append_char_t the_module in

  (* takes in a list and a char to append *)
  let append_int_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Int) |] in
  let append_int_func : L.llvalue = 
    L.declare_function "append_int" append_int_t the_module in

  (* takes a list and a character and returns 1 if in, 0 otherwise*)
  let contains_char_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Char) |] in
  let contains_char_func : L.llvalue =
    L.declare_function "contains_char" contains_char_t the_module in

  let contains_int_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Int) |] in
  let contains_int_func : L.llvalue =
    L.declare_function "contains_int" contains_int_t the_module in

  (* given a pointer to list, returns length*)
  let listlen_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")) |] in
  let listlen_func : L.llvalue =
    L.declare_function "listlen" listlen_t the_module in

  (* BUILTIN DICT FUNCTIONS HERE *)

  (* takes in a char pointer to a string of the type *)
  let create_dict_t : L.lltype =
    L.function_type (L.pointer_type (find_struct_type "dict")) [| L.pointer_type i8_t; L.pointer_type i8_t |] in
  let create_dict_func : L.llvalue = 
    L.declare_function "create_dict" create_dict_t the_module in

  (* takes in a dict pointer and a void pointer to key and val and adds pair to dict *)
  let add_keyval_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "dict")); (L.pointer_type i8_t); (L.pointer_type i8_t) |] in
  let add_keyval_func : L.llvalue = 
    L.declare_function "add_keyval" add_keyval_t the_module in

  (* takes in a dict and a char key and returns a void pointer to the value *)
  let access_char_key_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "dict")); (ltype_of_typ A.Char) |] in
  let access_char_func : L.llvalue = 
    L.declare_function "access_char_key" access_char_key_t the_module in

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
    let (the_function, _) = try StringMap.find fdecl.sfname function_decls 
      with Not_found -> raise (Error "function definition not found")
    in
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
        A.Int     -> int_format_str
      | A.Char    -> char_format_str
      | A.String  -> str_format_str
      | A.Float   -> float_format_str
      | A.Bool    -> int_format_str
      | _ -> raise (Error "print passed an invalid type")
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

    let get_type_string_of_array e_type = match e_type with
      | A.Array (li)   -> (match li with
          | A.Char  -> "char"
          | A.Int   -> "int"
          | _       -> raise (Error "array type string nah"))
      | _ -> raise (Error "type string map not here yet ")
    in

    (* this returns an llvalue *)
    (* raise (Error "SListLiteral not implemented") *)
    let rec expr builder ((e_type, e) : sexpr) = match e with
        SIntegerLiteral(num)      -> L.const_int (ltype_of_typ A.Int) num
      | SCharacterLiteral(chr)    -> L.const_int (ltype_of_typ A.Char) (Char.code chr)
      | SBoolLiteral(bln)         -> L.const_int (ltype_of_typ A.Bool) (if bln then 1 else 0)
      | SFloatLiteral(flt)        -> L.const_float (ltype_of_typ A.Float) flt
      | SStringLiteral(str)       -> L.build_global_stringptr str "" builder
      | SListLiteral(list)        -> 
        let type_string = (get_type_string_of_array e_type) in
        let type_string_ptr = expr builder (A.String, SStringLiteral(type_string)) in
        (* create empty list llvalue *)
        let li = L.build_call create_list_func [| type_string_ptr |] "create_list" builder in
        (* map over elements to add to list *)
        let rec append_func typ = match typ with
            A.Int         -> append_int_func
          | A.Char        -> append_char_func
          | A.Nah         -> raise (Error "No such thing as nah append function")
          | A.Array(arr)  -> (append_func arr)
          | _             -> raise (Error "append function not defined for type")
        in
        let appender c = L.build_call (append_func e_type) [| li; (expr builder c) |] "" builder in
        (List.map appender list); li
      (* return the list *)

      | SDictElem(e1, e2)         -> raise (Error "SDictElem not implemented")
      | SDictLiteral(list)        -> raise (Error "SDictLiteral not implemented")

      | SId s                     -> L.build_load (lookup s) s builder

      | SBinop ((A.Float,_ ) as e1, op, e2) ->
        let e1' = expr builder e1
        and e2' = expr builder e2 in
        (match op with 
           A.Add     -> L.build_fadd
         | A.Sub     -> L.build_fsub
         | A.Mult    -> L.build_fmul
         | A.Div     -> L.build_fdiv 
         | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
         | A.Neq     -> L.build_fcmp L.Fcmp.One
         | A.Less    -> L.build_fcmp L.Fcmp.Olt
         | A.Leq     -> L.build_fcmp L.Fcmp.Ole
         | A.Greater -> L.build_fcmp L.Fcmp.Ogt
         | A.Geq     -> L.build_fcmp L.Fcmp.Oge
         | A.Mod     -> L.build_frem
         | A.And | A.Or | A.Has ->
           raise (Failure "internal error: semant should have rejected and/or on float")
        ) e1' e2' "tmp" builder

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
         | A.Mod     -> L.build_srem
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

      | STernop(predicate, e1, e2) ->
        let e1' = expr builder e1 in
        let e2' = expr builder e2 in
        (* let bool_val = expr builder predicate in
           let merge_bb = L.append_block context "merge" the_function in
           let build_br_merge = L.build_br merge_bb in (* partial function *)

           let then_bb = L.append_block context "then" the_function in
           add_terminal (expr (L.builder_at_end context then_bb) e1')
           build_br_merge;

           let else_bb = L.append_block context "else" the_function in
           add_terminal (expr (L.builder_at_end context else_bb) e2')
           build_br_merge;

           ignore(L.build_cond_br bool_val then_bb else_bb builder);
           L.builder_at_end context merge_bb*)
        e1'

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

      | SAccess((typ, _) as e, l) ->
        let index       = expr builder l in
        let li          = expr builder e in
        let rec access_func typ = match typ with
            A.Int         -> access_int_func
          | A.Char        -> access_char_func
          | A.Nah         -> raise (Error "No such thing as nah access function")
          | A.Array(arr)  -> (access_func arr)
          | _             -> raise (Error "access function not defined for type")
        in 
        L.build_call (access_func typ) [| li; index |] "access" builder

      | SAccessAssign(i, idx, e)  -> raise (Error "SAccessAssign not implemented")

      (* hardcoded SCalls for built-ins *)
      | SCall ("print", [params]) -> let print_value = (get_print_value builder params)
        in L.build_call printf_func [| (get_format_str params) ; print_value |] "printf" builder

      (* casts *)
      | SCall("toChar", params) -> expr builder (Cast.to_char params)
      | SCall("toInt", params) -> expr builder (Cast.to_int params)
      | SCall("toFloat", params) -> expr builder (Cast.to_float params)
      | SCall("toBool", params) -> expr builder (Cast.to_bool params)
      | SCall("toString", params) -> expr builder (Cast.to_string params)
      | SCall("toNah", params) -> expr builder (Cast.to_nah params)

      (* pow2 *)
      | SCall ("pow2", [params])    -> let value = expr builder params in 
        L.build_call pow2_func [| value |] "pow2" builder

      (* append *)
      | SCall ("append", params)  ->
        let li = expr builder (List.hd params) in
        let p = expr builder (List.nth params 1) in
        L.build_call append_char_func [| li; p |] "" builder

      (* len *)
      | SCall ("len", params)  ->
        let li = expr builder (List.hd params) in
        L.build_call listlen_func [| li |] "len" builder

      (* contains *)
      | SCall ("contains", params)  ->
        let typ = (fst (List.hd params)) in
        let li = expr builder (List.hd params) in
        let p = expr builder (List.nth params 1) in
        let rec contains_func typ = match typ with
            A.Int         -> contains_int_func
          | A.Char        -> contains_char_func
          | A.Nah         -> raise (Error "No such thing as nah contains function")
          | A.Array(arr)  -> (contains_func arr)
          | _             -> raise (Error "contains function not defined for type")
        in 
        L.build_call (contains_func typ) [| li; p |] "contains" builder

      (* SCall for user defined functions *)
      | SCall (f, args)           -> 
        let (fdef, fdecl) = try StringMap.find f function_decls 
          with Not_found -> raise (Error "User defined function call not found")
        in
        let llargs = List.rev (List.map (expr builder) (List.rev args)) in
        let result = (match fdecl.styp with 
              A.Nah -> ""
            | _ -> f ^ "_result") in
        L.build_call fdef (Array.of_list llargs) result builder

      | SAttributeCall(e, f, el)  -> expr builder (A.Nah, SCall(f, e::el))
      | SNoexpr                   -> L.const_int i32_t 0
      | _ -> raise (Error "Expression match not implemented")

    and

      (* TODO: used to map bool values to strings for printf *)
      get_print_value builder (t, e) = match e with
      (* SBoolLiteral(bln) -> let strlit = (SStringLiteral (if bln then "true" else "false"))
         in expr builder (A.String, strlit) *)
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
        (*print_endline "WORKING HERE";
          print_endline "entering while loop basic block";*)
        let rec loop_stmt loop_bb builder = (*print_endline "entering special case matching";*)(function
              SBlock(sl) -> List.fold_left (fun b s -> loop_stmt loop_bb b s) builder sl
            | SIf (predicate, then_stmt, else_stmt)   -> 
              let bool_val = expr builder predicate in
              let merge_bb = L.append_block context "merge" the_function in
              let build_br_merge = L.build_br merge_bb in (* partial function *)

              let then_bb = L.append_block context "then" the_function in
              add_terminal (loop_stmt loop_bb (L.builder_at_end context then_bb) then_stmt)
                build_br_merge;

              let else_bb = L.append_block context "else" the_function in
              add_terminal (loop_stmt loop_bb (L.builder_at_end context else_bb) else_stmt)
                build_br_merge;

              ignore(L.build_cond_br bool_val then_bb else_bb builder);
              L.builder_at_end context merge_bb
            | SSkip e -> (*print_endline "entering skip"; *)ignore(L.build_br loop_bb builder) ; builder
            | _ as e -> stmt builder e) in

        let pred_bb = L.append_block context "while" the_function in
        ignore(L.build_br pred_bb builder);
        let body_bb = L.append_block context "while_body" the_function in
        add_terminal (loop_stmt pred_bb (L.builder_at_end context body_bb) body)
          (L.build_br pred_bb);

        let pred_builder = L.builder_at_end context pred_bb in
        let bool_val = expr pred_builder predicate in

        let merge_bb = L.append_block context "merge" the_function in
        ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
        L.builder_at_end context merge_bb
      | _ -> raise (Error "Statement match not implemented")
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
