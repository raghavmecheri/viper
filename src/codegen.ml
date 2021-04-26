module L = Llvm
module A = Ast
module Str = Str
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
  and float_t    = L.float_type  context
  and double_t   = L.double_type context
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
      A.Int                     -> i32_t
    | A.Bool                    -> i1_t
    | A.Nah                     -> void_t
    | A.Char                    -> i8_t
    | A.Float                   -> float_t
    | A.String                  -> str_t
    | A.Array(_)                -> (L.pointer_type (find_struct_type "list"))
    | A.Function(_)             -> raise (Error "fucntion lltype? idk chief") (* (ltype_of_typ t) *)
    | A.Group(_)                -> raise (Error "Group lltype not implemented")
    | A.Dictionary(_, _)        -> (L.pointer_type (find_struct_type "dict"))
  in

  (* Return initial value for a declaration *)
  let rec lvalue_of_typ typ = function
      A.Int | A.Bool | A.Nah | A.Char -> L.const_int (ltype_of_typ typ) 0
    | A.Float                         -> L.const_float (ltype_of_typ typ) 0.0
    | A.String                        -> L.const_pointer_null (ltype_of_typ typ)
    (* TODO: I believe null pointers would work here, but leaving as exception *)
    | A.Array(_)                      -> L.const_pointer_null (find_struct_type "list")
    | A.Group(_)                      -> raise (Error "Group llvalue not implemented")
    | A.Dictionary(_, _)              -> L.const_pointer_null (find_struct_type "dict")
    | A.Function(_)                   -> raise (Error "What should a function init value be ?")
  in

  (* BUILT-IN FUNCTIONS HERE*)

  (* PRINT FUNCTIONS HERE *)

  let printf_t : L.lltype = 
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
    L.declare_function "printf" printf_t the_module in

  let print_char_list_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "list")) |] in 
  let print_char_list_func : L.llvalue =
    L.declare_function "print_char_list" print_char_list_t the_module in 

  let print_str_list_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "list")) |] in 
  let print_str_list_func : L.llvalue =
    L.declare_function "print_str_list" print_str_list_t the_module in 

  (* C STANDARD LIBRARY FUNCTIONS HERE *)

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

  (* ACCESS LIST FUNCTIONS HERE*)

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

  let access_str_t : L.lltype =
    L.function_type (ltype_of_typ A.String) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Int)|] in
  let access_str_func : L.llvalue = 
    L.declare_function "access_str" access_str_t the_module in

  let access_float_t : L.lltype =
    L.function_type (ltype_of_typ A.Float) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Int)|] in
  let access_float_func : L.llvalue = 
    L.declare_function "access_float" access_float_t the_module in

  (* APPEND LIST FUNCTIONS HERE *)

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

  let append_str_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.String) |] in
  let append_str_func : L.llvalue = 
    L.declare_function "append_str" append_str_t the_module in

  let append_float_t : L.lltype =
    L.function_type (ltype_of_typ A.Nah) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Float) |] in
  let append_float_func : L.llvalue = 
    L.declare_function "append_float" append_float_t the_module in

  (* CONTAINS LIST FUNCTIONS HERE *)

  (* takes a list and a character and returns 1 if in, 0 otherwise*)
  let contains_char_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Char) |] in
  let contains_char_func : L.llvalue =
    L.declare_function "contains_char" contains_char_t the_module in

  let contains_int_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Int) |] in
  let contains_int_func : L.llvalue =
    L.declare_function "contains_int" contains_int_t the_module in

  let contains_str_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.String) |] in
  let contains_str_func : L.llvalue =
    L.declare_function "contains_str" contains_str_t the_module in

  let contains_float_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "list")); (ltype_of_typ A.Float) |] in
  let contains_float_func : L.llvalue =
    L.declare_function "contains_float" contains_float_t the_module in


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
    L.function_type (L.pointer_type i8_t) [| (L.pointer_type (find_struct_type "dict")); (ltype_of_typ A.Char) |] in
  let access_char_key_func : L.llvalue = 
    L.declare_function "access_char_key" access_char_key_t the_module in

  let access_str_key_t : L.lltype =
    L.function_type (L.pointer_type i8_t) [| (L.pointer_type (find_struct_type "dict")); (L.pointer_type (ltype_of_typ A.Char)) |] in
  let access_str_key_func : L.llvalue = 
    L.declare_function "access_str_key" access_str_key_t the_module in

  (* type -> void pointer alloc funtions *)
  let int_alloc_t : L.lltype =
    L.function_type (L.pointer_type i8_t) [| (ltype_of_typ A.Int) |] in 
  let int_alloc_func : L.llvalue =
    L.declare_function "int_alloc_zone" int_alloc_t the_module in

  let char_alloc_t : L.lltype =
    L.function_type (L.pointer_type i8_t) [| (ltype_of_typ A.Char) |] in 
  let char_alloc_func : L.llvalue =
    L.declare_function "char_alloc_zone" char_alloc_t the_module in

  let str_alloc_t : L.lltype =
    L.function_type (L.pointer_type i8_t) [| (ltype_of_typ A.String) |] in 
  let str_alloc_func : L.llvalue =
    L.declare_function "str_alloc_zone" str_alloc_t the_module in

  (* CONTAINS DICT FUNCTIONS HERE *)

  let contains_str_key_t : L.lltype =
    L.function_type (ltype_of_typ A.Int) [| (L.pointer_type (find_struct_type "dict")); (L.pointer_type (ltype_of_typ A.Char)) |] in 
  let contains_str_key_func : L.llvalue =
    L.declare_function "contains_str_key" contains_str_key_t the_module in

  (* KEYS DICT FUNCTIONS *)

  let get_str_keys_t : L.lltype =
    L.function_type (L.pointer_type (find_struct_type "list")) [| (L.pointer_type (find_struct_type "dict")) |] in 
  let get_str_keys_func: L.llvalue =
    L.declare_function "get_str_keys" get_str_keys_t the_module in

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
      with Not_found -> raise (Error ("variable " ^ n ^ " not found in locals map"))
    in

    (* LLVM insists each basic block end with exactly one "terminator" 
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in

    (* maps a Viper type to a string for use in array/dict functions *)
    let rec get_type_string e_type = match e_type with
      | A.Array (li_t)              -> get_type_string li_t
      | A.Dictionary (key_t, val_t) -> 
        let key_t_str = get_type_string key_t in
        let val_t_str = get_type_string val_t in
        key_t_str ^ " " ^ val_t_str
      | A.Char    -> "char"
      | A.Int     -> "int"
      | A.Nah     -> "nah"
      | A.String  -> "string"
      | A.Float   -> "float"
      | _                           -> raise (Error "type string map not implemented")
    in

    (* this returns an llvalue *)
    let rec expr builder ((e_type, e) : sexpr) = match e with
        SIntegerLiteral(num)      -> L.const_int (ltype_of_typ A.Int) num
      | SCharacterLiteral(chr)    -> L.const_int (ltype_of_typ A.Char) (Char.code chr)
      | SBoolLiteral(bln)         -> L.const_int (ltype_of_typ A.Bool) (if bln then 1 else 0)
      | SFloatLiteral(flt)        -> L.const_float (ltype_of_typ A.Float) flt
      | SStringLiteral(str)       -> L.build_global_stringptr str "" builder
      | SListLiteral(list)        -> 
        (* (match e_type with
           | A.Nah -> L.const_pointer_null (find_struct_type "list")
             | _ -> *)
        let type_string = (get_type_string e_type) in
        let type_string_ptr = expr builder (A.String, SStringLiteral(type_string)) in
        (* create empty list llvalue *)
        let li = L.build_call create_list_func [| type_string_ptr |] "create_list" builder in
        (* map over elements to add to list *)
        let rec append_func typ = match typ with
            A.Int         -> append_int_func
          | A.Char        -> append_char_func
          | A.String      -> append_str_func
          | A.Float       -> append_float_func
          | A.Array(arr)  -> (append_func arr)
          | A.Nah         -> raise (Error "No such thing as nah append function")
          | _             -> raise (Error "list append function not defined for type")
        in
        let appender c = L.build_call (append_func e_type) [| li; (expr builder c) |] "" builder in
        (List.map appender list); li

      | SDictLiteral(dict_elem_list)        -> (* raise (Error "SDictLiteral not implemented") *)
        (* returns a list of [key_type_string, val_type_string] *)
        let dict_type_string_tup  = Str.split (Str.regexp " ") (get_type_string e_type) in
        let key_type_string       = List.hd dict_type_string_tup in
        let key_type_string_ptr   = expr builder (A.String, SStringLiteral(key_type_string)) in
        let val_type_string       = List.nth dict_type_string_tup 1 in
        let val_type_string_ptr   = expr builder (A.String, SStringLiteral(val_type_string)) in

        (* create empty dict llvalue *)
        let dict = L.build_call create_dict_func [| key_type_string_ptr; val_type_string_ptr |] "create_dict" builder in

        (* takes in a SDictElem *)
        let adder (dict_elem_t, dict_elem) = (match dict_elem with 
            | SDictElem(key, value) ->
              (* takes in (typ,sx) and returns a build_call *)
              let void_alloc ((z_t, z_x) as z) = (match z_t with
                  (* | A.Int -> raise (Error "Int alloc")
                     | A.Char -> raise (Error "Char alloc") *)
                  | A.Int       -> L.build_call int_alloc_func [| (expr builder z) |] "int_alloc" builder
                  | A.Char      -> L.build_call char_alloc_func [| (expr builder z) |] "char_alloc" builder
                  | A.String    -> L.build_call str_alloc_func [| (expr builder z) |] "str_alloc" builder
                  | A.Array(_)  -> 
                    let list_ptr = expr builder z in 
                    L.build_bitcast list_ptr (L.pointer_type i8_t) (L.value_name list_ptr) builder 

                  (* cast to void pointer here *)
                  | A.Dictionary(_, _)  -> 
                    let dict_ptr = expr builder z in 
                    L.build_bitcast dict_ptr (L.pointer_type i8_t) (L.value_name dict_ptr) builder 
                  (* cast to void pointer here *)
                  | _       -> raise (Error "No alloc function for type")) 
              in

              (* call alloc functions for the key and value in the dict element*)
              let key_ll = (void_alloc key) in
              let val_ll = (void_alloc value) in

              (* call add_keyval_func *)
              L.build_call add_keyval_func [| dict; key_ll; val_ll |] "" builder 

            | _             -> raise(Error "not a dict-elem??? this shouldn't happen")
          ) in

        (* map over list of dict elements to add them to dict *)
        (List.map adder dict_elem_list); dict

      | SDictElem(e1, e2)         -> raise (Error "SDictElem not implemented")

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

      | SUnop(op, ((t, var) as e)) -> 
        let e' = expr builder e in
        (match op with
           A.Neg when t = A.Float -> L.build_fneg e' "tmp" builder
         | A.Neg                  -> L.build_neg e' "tmp" builder
         | A.Not                  -> L.build_not e' "tmp" builder
         (* Incr will only work with ints *)
         | A.Incr -> 
           let added = L.build_nsw_add e' (L.const_int (ltype_of_typ t) 1) (L.value_name e') builder in 
           let var_name vr = (match vr with
               | SId(s)  -> s 
               | _       -> raise (Error "Incr can only be used with SId"))
           in
           L.build_store added (lookup (var_name var)) builder
         | A.Decr ->
           let added = L.build_nsw_add e' (L.const_int (ltype_of_typ t) (-1)) (L.value_name e') builder in 
           let var_name vr = (match vr with
               | SId(s)  -> s 
               | _       -> raise (Error "Incr can only be used with SId"))
           in
           L.build_store added (lookup (var_name var)) builder
        )


      (*
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
        *)

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

      (* typ will be a dictionary or a dict *)
      | SAccess((typ, _) as e, l) -> 
        (* (match typ with
           | A.Array(arr_t) ->  *)
        (* index is an int for lists *)
        let index       = expr builder l in
        (* li is the list to pass to access*)
        let li          = expr builder e in
        let rec access_func typ = match typ with
            A.Int         -> access_int_func
          | A.Char        -> access_char_func
          | A.String      -> access_str_func
          | A.Float       -> access_float_func
          | A.Array(arr)  -> (access_func arr)
          | A.Dictionary(key_t, key_v) -> (match key_t with
              | A.Char    -> access_char_key_func
              | A.String  -> access_str_key_func
              | _     -> raise (Error "dictionary access function not defined for key type")
            )
          | A.Nah         -> raise (Error "No such thing as nah access function") 
          | _             -> raise (Error "list access function not defined for type")
        in 
        (match typ with
         (* Dictionary access requires pointer bitcasting *)
         | A.Dictionary(_, val_t) -> 
           let void_ptr = L.build_call (access_func typ) [| li; index |] "access" builder in
           (match val_t with 
            | A.Int -> 
              let int_ptr = L.build_bitcast void_ptr (L.pointer_type (ltype_of_typ A.Int)) (L.value_name void_ptr) builder in
              L.build_load int_ptr (L.value_name int_ptr) builder
            | A.Char -> raise (Error "val is char")
            | A.Dictionary(_, _) -> 
              L.build_bitcast void_ptr (L.pointer_type (find_struct_type "dict")) (L.value_name void_ptr) builder
            | _       -> raise (Error "idk what this dict val type is chief"))
         (* Array access is a simple function call*)
         | A.Array(_)        -> L.build_call (access_func typ) [| li; index |] "access" builder
         | _                 -> raise (Error "SAccess on something that isn't a list or a dictionary not supported"))
      (* | A.Dictionary(key_t, key_v) -> 
         (* key can be a number of things*)
         let key            = expr builder l in
         (* dict is the dict to pass to access *)
         let dict          = expr builder e in
         let rec access_func typ = match typ with
            A.Int         -> access_int_func
          | A.Char        -> access_char_func
          | A.Nah         -> raise (Error "No such thing as nah access function")
          | A.Array(arr)  -> (access_func arr)
          (*  | A.Dictionary(key_t, key_v) -> (match key_t with
              | A.Char -> access_char_key_func
              | _     -> raise (Error "dictionary access function not defined for key type")
              ) *)
          | _             -> raise (Error "list access function not defined for type")
         in 
         L.build_call (access_func typ) [| li; index |] "access" builder *)
      (* | _ -> raise (Error "Access only supported for lists and dicts")) *)

      | SAccessAssign(i, idx, e)  -> raise (Error "SAccessAssign not implemented")

      (* USER-EXPOSED BUILT-INS: Must be added to check in decs.ml *)

      (* print *)
      | SCall("print", []) -> let newline = expr builder (String, SStringLiteral(""))
        in L.build_call printf_func [| str_format_str ; newline |] "printf" builder

      | SCall("print", [((p_t, p_v) as params)]) -> (match p_t with
          | A.Dictionary(_,_) -> raise (Error "Printing dictionary not supported currently")
          | A.Array(arr) -> (match arr with 
              | A.Char   -> L.build_call print_char_list_func [| (expr builder params) |] "" builder
              | A.String -> L.build_call print_str_list_func [| (expr builder params) |] "" builder
              | _ -> raise (Error "Print not supported for array type"))
          | _ -> 
            let print_value = (match p_t with
                | A.Float -> L.build_fpext (expr builder params) double_t "ext" builder
                | _       -> expr builder params)
            in 
            let format_str = (match p_t with
                  A.Int     -> int_format_str
                | A.Char    -> char_format_str
                | A.String  -> str_format_str
                | A.Float   -> float_format_str
                | A.Bool    -> int_format_str
                | _ -> raise (Error "print passed an invalid type"))
            in
            L.build_call printf_func [| format_str ; print_value |] "printf" builder)

      | SCall("print", params) -> raise (Error "print not supported with multiple params currently")

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
        let li_e = List.hd params in
        let p_e = List.nth params 1 in
        let li = expr builder li_e in
        let p = expr builder p_e in
        let append_func = (match p_e with
            | (A.Char, _)    -> append_char_func
            | (A.String, _)  -> append_str_func
            | (A.Int, _)     -> append_int_func
            | (A.Float, _)   -> append_float_func
            | _         -> raise (Error "Append parameter type invalid"))
        in
        L.build_call append_func [| li; p |] "" builder

      (* len *)
      | SCall ("len", params)  ->
        let li = expr builder (List.hd params) in
        L.build_call listlen_func [| li |] "len" builder

      (* contains *)
      | SCall ("contains", params) ->
        let typ = (fst (List.hd params)) in
        let li = expr builder (List.hd params) in
        let p = expr builder (List.nth params 1) in
        let rec contains_func typ = match typ with
            A.Int         -> contains_int_func
          | A.Char        -> contains_char_func
          | A.Float       -> contains_float_func
          | A.String      -> contains_str_func
          | A.Nah         -> raise (Error "No such thing as nah contains function")
          | A.Array(arr)  -> (contains_func arr)
          | A.Dictionary(_,_) -> contains_str_key_func
          | _             -> raise (Error "contains function not defined for type")
        in 
        L.build_call (contains_func typ) [| li; p |] "contains" builder

      (* takes in a dict pointer and returns a list pointer of the keys in the dict *)
      | SCall ("keys", [params]) ->
        let typ = fst params in
        (match typ with 
         | A.Dictionary(_,_) ->
           let dict = expr builder params in 
           L.build_call get_str_keys_func [| dict |] "get_str_keys" builder
         | _                 -> raise (Error "Keys only supported for Dictionaries"))

      (* add is a wrapper over keyval, takes in dict, void * key, void * to val *)
      | SCall ("add", params) ->
        let ds = expr builder (List.hd params) in 
        let key = (List.nth params 1) in 
        let value = (List.nth params 2) in

        let void_alloc ((z_t, z_x) as z) = (match z_t with
            (* | A.Int -> raise (Error "Int alloc")
               | A.Char -> raise (Error "Char alloc") *)
            | A.Int       -> L.build_call int_alloc_func [| (expr builder z) |] "int_alloc" builder
            | A.Char      -> L.build_call char_alloc_func [| (expr builder z) |] "char_alloc" builder
            | A.String    -> L.build_call str_alloc_func [| (expr builder z) |] "str_alloc" builder
            | A.Array(_)  -> 
              let list_ptr = expr builder z in 
              L.build_bitcast list_ptr (L.pointer_type i8_t) (L.value_name list_ptr) builder 

            (* cast to void pointer here *)
            | A.Dictionary(_, _)  -> 
              let dict_ptr = expr builder z in 
              L.build_bitcast dict_ptr (L.pointer_type i8_t) (L.value_name dict_ptr) builder 
            (* cast to void pointer here *)
            | _       -> raise (Error "No alloc function for type"))
        in

        (* cast key and value pointers to void pointers*)
        let key_void_ptr = (void_alloc key) in
        let value_void_ptr = (void_alloc value) in

        L.build_call add_keyval_func [| ds; key_void_ptr; value_void_ptr |] "" builder

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
    in

    let rec stmt builder = function
      | SBlock sl                               -> List.fold_left stmt builder sl
      | SExpr e                                 -> ignore(expr builder e); builder
      (* this doesnt work for list dict *)
      | SDec (t, n)                             -> 
        let local_var = L.build_alloca (ltype_of_typ t) n builder
        in Hashtbl.add local_vars n local_var; builder
      | SReturn e -> ignore(match fdecl.styp with
          (* Special "return nothing" instr *)
            A.Nah -> L.build_ret_void builder 
          (* Build return statement *)
          | _ -> L.build_ret (expr builder e) builder );
        builder

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

      | SWhile (predicate, body, increment) -> 
        let rec loop_stmt loop_bb exit_bb builder = (function
              SBlock(sl) -> List.fold_left (fun b s -> loop_stmt loop_bb exit_bb b s) builder sl
            | SIf (predicate, then_stmt, else_stmt)   -> 
              let bool_val = expr builder predicate in
              let merge_bb = L.append_block context "merge" the_function in
              let build_br_merge = L.build_br merge_bb in (* partial function *)

              let then_bb = L.append_block context "then" the_function in
              add_terminal (loop_stmt loop_bb exit_bb (L.builder_at_end context then_bb) then_stmt)
                build_br_merge;

              let else_bb = L.append_block context "else" the_function in
              add_terminal (loop_stmt loop_bb exit_bb (L.builder_at_end context else_bb) else_stmt)
                build_br_merge;

              ignore(L.build_cond_br bool_val then_bb else_bb builder);
              L.builder_at_end context merge_bb
            | SSkip _ -> 
              let skip_bb = L.append_block context "skip" the_function in 
              ignore (L.build_br skip_bb builder);
              let skip_builder = (L.builder_at_end context skip_bb) in
              add_terminal (loop_stmt loop_bb exit_bb skip_builder increment) (L.build_br loop_bb);
              builder 
            | SAbort _ -> ignore(L.build_br exit_bb builder); builder
            | _ as e -> stmt builder e) in

        let pred_bb = L.append_block context "while" the_function 
        and merge_bb = L.append_block context "merge" the_function in

        ignore(L.build_br pred_bb builder);
        let body_bb = L.append_block context "while_body" the_function in
        add_terminal (loop_stmt pred_bb merge_bb (L.builder_at_end context body_bb) body)
          (L.build_br pred_bb);

        let pred_builder = L.builder_at_end context pred_bb in
        let bool_val = expr pred_builder predicate in

        ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
        L.builder_at_end context merge_bb
      | SSkip _     -> raise (Failure "Error: skip occurs outside of loop")
      | SAbort _    -> raise (Failure "Error: abort occurs outside of loop")
      | SPanic expr -> raise (Error "Panic statement not implemented")
      | _           -> raise (Error "Statement match for stmt builder not implemented")
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