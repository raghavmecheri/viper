module L = Llvm
open Ast

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
  and void_t     = L.void_type   context in

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

  (* Construct code for an expression; return its value *)
  let rec expr builder e = match e with
      IntegerLiteral i    -> L.const_int i32_t i
      (*
    | Call ("print", [e]) ->
      L.build_call printf_func [| int_format_str ; (expr builder e) |]
        "printf" builder
    | Call ("printbig", [e]) ->
      L.build_call printbig_func [| (expr builder e) |] "printbig" builder
    | Call ("printf", [e]) -> 
      L.build_call printf_func [| float_format_str ; (expr builder e) |]
        "printf" builder
        *)
    | _ -> raise (Error "Expression not implemented")
  in

  (* Define built-in functions at top of every file *)  
  let printf_t : L.lltype = 
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
    L.declare_function "printf" printf_t the_module in

  (* define our main, TODO: make this optional if main provided *)
  let main_t = L.function_type i32_t [| |] in
  let main_f = L.define_function "main" main_t the_module in

  (* main builder *)
  let builder = L.builder_at_end context (L.entry_block main_f) in

  (* format characters for printf *)
  let char_format_str = L.build_global_stringptr "%c" "fmt" builder
  and int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
  and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder in

  (* iterate over statments to add to main function *)
  let rec build_main (st :: sts) = match st with
    (* match a print statement *)
    | (Expr (Call ("print", exp_list) ) ) -> 
      (* TODO: recurse over statements here *)
      let call_print e b = match e with
        | IntegerLiteral(num) -> 
          L.build_call printf_func [| int_format_str ; L.const_int i32_t num |]
            "printf" b
          (*
          L.build_call printbig_func [| L.const_int i32_t num |] "printbig" builder
          *)
        | _ -> raise (Error "print passed non-integer literal")
      in call_print (List.hd exp_list) builder

    | Expr (IntegerLiteral(num)) -> raise (Error "matched the integer expression")
    | _ -> raise (Error "First statement must be expression")

  (* build a main function from top-level statements and return the_module *)
  in let _ = build_main statements ; L.build_ret (L.const_int i32_t 0) builder in
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

(* from MicroC: Build the code for the given statement; return the builder for
   the statement's successor (i.e., the next instruction will be built
   after the one generated by this call) *)

    (*
  let rec stmt builder = function
    (* only need to match for print statement (expression) *)
    | Expr e -> ignore(expr builder e); builder
    | _ -> raise (Error "Statement not implemented")
  in
  *)