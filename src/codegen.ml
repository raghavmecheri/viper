module L = Llvm
module A = Ast
open Sast

exception Error of string

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module 
   a viper program is statements and function defs
*)
let translate (statements, _) =
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
  in

  (* Return the LLVM type for a Viper primitive type *)
  let ltype_of_typ = function
      A.Int   -> i64_t
    | A.Char  -> i16_t
    | A.Float -> float_t
    | A.Bool  -> i1_t
    | _     -> raise (Error "Argument is not implemented or is not a Viper type")
  in

  (* Define built-in functions at top of every file *)  
  let printf_t : L.lltype = 
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
    L.declare_function "printf" printf_t the_module in

  (* define a main function around top-level statements *)
  let main_t = L.function_type i32_t [| |] in
  let main_f = L.define_function "main" main_t the_module in

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

  (* Create a map of global variables *)
  let global_vars : L.llvalue StringMap.t = StringMap.empty in

  (* function to retrieve a global variable*)
  let global_lookup n = StringMap.find n global_vars in

  (* function to initialize a global variable to 0 on declaration *)
  let global_init m (t, n) = match t with
      A.Float   -> L.const_float (ltype_of_typ t) 0.0
    | A.Int     -> L.const_int (ltype_of_typ t) 0
    | _         -> raise (Error "Variable type init not defined") 
  in

  (* function to assign a new value to global variable on declaration *)
  (* let global_assign = 
     in *)

  (* let global_var m (t, n) = 
     let init = match t with
        A.Float -> L.const_float (ltype_of_typ t) 0.0
      | _ -> L.const_int (ltype_of_typ t) 0
     in StringMap.add n (L.define_global n init the_module) m in
     List.fold_left global_var StringMap.empty globals in *)

  (* expression evaluation function *)
  let rec expr builder ((_, e) : sexpr) = match e with
      SIntegerLiteral(num)      -> L.const_int (ltype_of_typ A.Int) num
    | SCharacterLiteral(chr)    -> L.const_int (ltype_of_typ A.Char) (Char.code chr)
    | SBoolLiteral(bln)         -> L.const_int i1_t (if bln then 1 else 0)
    | SFloatLiteral(flt)        -> L.const_float (ltype_of_typ A.Float) flt
    | SStringLiteral(str)       -> L.build_global_stringptr str "str" builder
    | SId s                     -> L.build_load (global_lookup s) s builder
    | SAssign (s, e) -> let e' = expr builder e in
      ignore(L.build_store e' (global_lookup s) builder); e'
    | SDecAssign (t, s, e) -> let e' = expr builder e in
      ignore(L.build_store e' (global_lookup s) builder); e'
    (* TODO: SListLiteral, SDictElem, SDictLiteral *)
    | SUnop(op, ((t, _) as e)) ->
      let e' = expr builder e in
      (match op with
         A.Neg when t = A.Float -> L.build_fneg 
       | A.Neg                  -> L.build_neg
       | A.Not                  -> L.build_not) e' "tmp" builder
    (* TODO: Unop: Incr, Decr *)
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
    (* TODO: SCall for general function calls *)
    | _ -> raise (Error "Expression not implemented")

  and
    get_print_value builder (t, e) = match e with
      SBoolLiteral(bln) -> let strlit = (SStringLiteral (if bln then "true" else "false"))
      in expr builder (A.Bool, strlit)
    | _ -> expr builder (t, e)
  in


  (* iterate over statments to add to main function, builder must be returned *)
  let build_main st = match st with
    | SExpr e -> ignore(expr builder e); builder
    | _ -> raise (Error "Statement not implemented")
  in 

  (* build a main function from top-level statements, add a return statement, and return the_module *)
  let _ = List.map build_main (List.rev statements) in
  let _ = L.build_ret (L.const_int i32_t 0) builder in
  the_module

(* from MicroC: Create a map of global variables after creating each *)
(* 
let global_vars : L.llvalue StringMap.t =
  let global_var m (t, n) = 
    let init = match t with
        A.Float -> L.const_float (ltype_of_typ t) 0.0
      | _ -> L.const_int (ltype_of_typ t) 0
    in StringMap.add n (L.define_global n init the_module) m in
  List.fold_left global_var StringMap.empty globals in
*)

(* from MicroC: Define each function (arguments and return type) so we can 
   call it even before we've created its body *)
       (*
     let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
      let function_decl m fdecl =
        let name = fdecl.sfname
        and formal_types = 
          Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
        in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
        StringMap.add name (L.define_function name ftype the_module, fdecl) m in
      List.fold_left function_decl StringMap.empty functions in
      *)

(* from MicroC: Fill in the body of the given function *)
     (*
     let build_function_body fdecl =
      let (the_function, _) = StringMap.find fdecl.sfname function_decls in
      let builder = L.builder_at_end context (L.entry_block the_function) in

      let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
      and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder in
    *)

(* | A.Bool  -> i1_t
   | A.Nah   -> void_t *)

(*
   and void_t     = L.void_type   context
   and i64_t      = L.i64_type    context
   and i1_t       = L.i1_type     context
   in
   *)