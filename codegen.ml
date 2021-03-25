module L = Llvm
open Ast

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
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context 
  and float_t    = L.double_type context
  in

  (*
  and void_t     = L.void_type   context
  and i64_t      = L.i64_type    context
  and i16_t      = L.i16_type    context
  and i1_t       = L.i1_type     context
  in
  *)

  (* Return the LLVM type for a Viper primitive type *)
  (*
  let ltype_of_typ = function
      A.Int   -> i64_t
    | A.Char  -> i16_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Nah   -> void_t
  in
  *)

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
  let get_format_str e = match e with
      IntegerLiteral(_) -> int_format_str
    | StringLiteral(_) -> str_format_str
    | CharacterLiteral(_) -> char_format_str
    | FloatLiteral(_) -> float_format_str
    | _ -> raise (Error "print passed an invalid/unimplemented literal")
  in

  (* expression evaluation function *)
  let rec expr builder e = match e with
      IntegerLiteral(num)      -> L.const_int i32_t num
    | StringLiteral(str)       -> L.build_global_stringptr str "str" builder
    | CharacterLiteral(chr)    -> L.const_int i8_t (Char.code chr)
    | FloatLiteral(flt)        -> L.const_float float_t flt
    | Call ("print", [params])   -> L.build_call printf_func [| (get_format_str params) ; (expr builder params) |] "printf" builder
    | _ -> raise (Error "Expression not implemented") 
  in

  (* iterate over statments to add to main function, builder must be returned *)
  let build_main st = match st with
    | Expr e -> ignore(expr builder e); builder 
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