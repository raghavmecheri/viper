(* * * * *
   This file semantically checks all variable and function declarations in the AST.
   Duplicate variables, nah variable declarations, and function declarations
   with the same parameters throw errors.
   A scoped symbol table mapping variable names to their types is returned, along with  
   a mapping of functions to their scoped formal and local variables.
 * * * * *)

open Ast

module StringMap = Map.Make(String)

(* Data structure that holds scoped variables *)
type scope_table = {
  variables : typ StringMap.t;
  parent : scope_table option;
}

let rec string_of_scope scope = 
  let print_bind name ty str = ("(" ^ name ^ ": " ^ (string_of_typ ty) ^ ")\n" ^ str) in
  let this_scope = StringMap.fold (fun k t s -> print_bind k t s) scope.variables "" in 
  let parent_scope = match scope.parent with
      Some(parent) -> string_of_scope parent
    | None -> ""
  in "{" ^ this_scope ^ "}\n|\nV\n{" ^ parent_scope ^ "}"  


(* Data structure that stores function declarations *)
type func_table = {
  formals : scope_table;
  locals : scope_table;
  ret_typ : typ;
}

(* Names of built-in Viper functions *)
(* User-defined functions cannot have any name in this list *)
let illegal_func_names = ["print"; "len"; "int"; "char"; "float"; "bool"; "string"; "nah"; "pow2"; "append"]

(* Retrieves a type from an ID name *)
let rec toi scope s =
  if StringMap.mem s scope.variables then
    StringMap.find s scope.variables 
  else match scope.parent with
      Some(parent) -> toi parent s 
    | _ -> raise (Failure ("Variable " ^ s ^ " not found"))

(* Builds a comma-separated string out of a list of parameters *)
(* For example, [int, char, bool] becomes "(int, char, bool)" *)
let rec string_of_params params = match params with
    (typ, _) :: [] -> string_of_typ typ
  | (typ, _) ::  p -> string_of_typ typ ^ ", " ^ string_of_params p
  | _              -> "" 

(* Creates a key string used in mapping functions to their declarations *)
(* Strings include function name and a list of parameters to allow overloaded functions *)
and key_string name params = name ^ " (" ^ string_of_params params ^ ")"

let rec string_of_params_built_in params = match params with
  | typ :: []   -> string_of_typ typ 
  | typ :: p    -> string_of_typ typ ^ ", " ^ string_of_params_built_in p
  | _           -> "" 

and key_string_built_in_functions name params = name ^ " (" ^ string_of_params_built_in params ^ ")"

(* Checks to see if a variable name is a duplicate *)
let rec is_valid_dec name scope = 
  if StringMap.mem name scope.variables then
    raise (Failure ("Error: variable " ^ name ^ " is already defined"))
  else match scope.parent with
      Some(parent) -> is_valid_dec name parent
    | _ -> true

(* Adds a (name, type) pair to a symbol table *)
let add_symbol name ty scope = match ty with
    Nah -> raise (Failure ("Error: variable " ^ name ^ " declared with type nah"))
  | _  -> if is_valid_dec name scope then {
      variables = StringMap.add name ty scope.variables;
      parent = scope.parent;
    } else scope (* Never enters else clause, but still needed to avoid type error *)

let add_symbol_driver name ty scope = match ty with
    Nah -> raise (Failure ("Error: variable " ^ name ^ " declared with type nah"))
  | _  ->  {
      variables = StringMap.add name ty scope.variables;
      parent = scope.parent;
    } 

(* Adds declarations from a bind into a symbol table *)
let get_bind_decs scope bind = 
  let ty, name = bind in add_symbol name ty scope

(* Adds declarations from expressions into a symbol table *)
let rec get_expr_decs scope expr = 
  match expr with
    Binop(e1, _, e2) -> 
    let expr_list = [e1; e2] in List.fold_left get_expr_decs scope expr_list
  | Unop(_, e) -> get_expr_decs scope e
  | Ternop(e1, e2, e3) -> 
    let expr_list = [e1; e2; e3] in List.fold_left get_expr_decs scope expr_list
  | OpAssign(_, _, e)
  | Assign(_, e) -> get_expr_decs scope e
  | DecAssign(ty, name, e) -> 
    let updated_scope = get_expr_decs scope e in add_symbol name ty updated_scope
  | Deconstruct(b_list, e) -> 
    let updated_scope = List.fold_left get_bind_decs scope b_list in get_expr_decs updated_scope e
  | Access(arr, index) ->
    let expr_list = [arr; index] in List.fold_left get_expr_decs scope expr_list
  | AccessAssign(e1, e2, e3) ->
    let expr_list = [e1; e2; e3] in List.fold_left get_expr_decs scope expr_list
  | Call(_, expr_list) -> List.fold_left get_expr_decs scope expr_list
  | AttributeCall(e1, _, e_list) -> 
    let expr_list = e1 :: e_list in List.fold_left (get_expr_decs) scope expr_list
  | _ -> scope

(* Adds declarations from statements into a symbol table *)
let rec get_stmt_decs scope stmt =
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in match stmt with
    Block(s_list) -> 
    let _ = List.fold_left get_stmt_decs new_scope s_list in scope
  | Expr(e) -> get_expr_decs scope e
  | Dec(ty, name) -> add_symbol name ty scope
  | If(cond, then_s, else_s) -> 
    let cond_scope = get_expr_decs new_scope cond in
    let _ = (get_stmt_decs cond_scope then_s, get_stmt_decs cond_scope else_s) in scope
  | For(e1, e2, e3, s) -> 
    let expr_list = [e1; e2; e3] in
    let for_scope = List.fold_left get_expr_decs new_scope expr_list in 
    let _ = get_stmt_decs for_scope s in scope
  | DecForIter(ty, name, e, s) -> 
    let iter_scope = add_symbol name ty new_scope in
    let for_scope = get_expr_decs iter_scope e in 
    let _ = get_stmt_decs for_scope s in scope
  | While(e, s, _) -> 
    let while_scope = get_expr_decs new_scope e in 
    let _ = get_stmt_decs while_scope s in scope
  | PretendBlock(s_list) -> 
    let _ = List.fold_left get_stmt_decs new_scope s_list in scope
  | _ -> scope

(* Driver for getting declarations from a list of statements *)
let get_vars scope s_list = List.fold_left get_stmt_decs scope s_list

(* Ensure that no functions are duplicated *)
(* Functions are invalid if they share the name with a built-in Viper function, or it
   two user-defined functions have the same name and list of formal arguments *)
let valid_func_name fd map = 
  let rec unused_name name illegals = match illegals with
      [] -> ()
    | illegal_name :: _ when name = illegal_name ->
      raise (Failure ("Error: illegal function name " ^ name))
    | _ :: tail -> unused_name name tail
  in let _ = unused_name fd.fname illegal_func_names in
  let key = key_string fd.fname fd.formals in
  if StringMap.mem key map then 
    raise (Failure("Error: function " ^ fd.fname ^ " is already defined with formal arguments (" ^ 
                   (string_of_params fd.formals) ^ ")"))
  else key

(* Builds a function table for a function declaration *)
let build_func_table global_scope (fd : func_decl) map = 
  let key = valid_func_name fd map in
  let formals_scope = List.fold_left get_bind_decs {
      variables = StringMap.empty;
      parent = None;
    } fd.formals in
  let updated_scope = { 
    variables = formals_scope.variables;
    parent = Some(global_scope); } in
  let locals_scope = get_vars {
      variables = StringMap.empty;
      parent = Some(updated_scope);
    } fd.body in StringMap.add key {
    formals = updated_scope;
    locals = locals_scope;
    ret_typ = fd.typ;
  } map

(* Driver for getting declarations *)
let get_decs (s_list, f_list) = 
  let globals = get_vars {
      variables = StringMap.empty;
      parent = None;
    } (List.rev s_list) in

  (* Collect declarations for Viper's built-in functions *)
  let built_in_funcs = 
    let build_built_in_func_table map (name, param_typ, typ) = 
      let args = List.fold_left 
          (fun m f -> let param_name = ("p" ^ string_of_int (StringMap.cardinal m.variables)) in add_symbol param_name f m) {
          variables = StringMap.empty;
          parent = None;
        } param_typ in
      let key = (key_string_built_in_functions name param_typ)
      in StringMap.add key {
        formals = args; 
        locals = {
          variables = StringMap.empty;
          parent = None;
        };
        ret_typ = typ;
      } map
    in List.fold_left build_built_in_func_table StringMap.empty [
      ("print", [], Nah);
      ("print", [Int], Nah);
      ("print", [String], Nah);
      ("print", [Char], Nah);
      ("print", [Bool], Nah);
      ("print", [Float], Nah);
      ("print", [Array(Char)], Nah);
      ("print", [Array(String)], Nah);

      ("len", [Array(Int)], Int);
      ("len", [Array(Float)], Int);
      ("len", [Array(Bool)], Int);
      ("len", [Array(String)], Int);
      ("len", [Array(Char)], Int);

      ("append", [Array(Char); Char], Nah);
      ("append", [Array(String); String], Nah);
      ("append", [Array(Int); Int], Nah);
      ("append", [Array(Float); Float], Nah);

      ("contains", [Array(Char); Char], Int);
      ("contains", [Array(String); String], Int);
      ("contains", [Array(Float); Float], Int);
      ("contains", [Array(Int); Int], Int);
      ("contains", [Dictionary(String, Int); String], Int);

      ("add", [String; Int], Nah);
      ("add", [Dictionary(String, Int); String; Int], Nah);

      ("keys", [Dictionary(String, Int)], Array(String));

      ("toInt", [Float], Int);
      ("toInt", [String], Int);
      ("toInt", [Char], Int);
      ("toInt", [Bool], Int);
      ("toInt", [Int], Int);
      ("toChar", [Int], Char);
      ("toChar", [String], Char); 
      ("toChar", [Char], Char);
      ("toFloat", [Int], Float);
      ("toFloat", [String], Float);
      ("toFloat", [Char], Float);
      ("toFloat", [Float], Float);
      ("toBool", [Int], Bool);
      ("toBool", [String], Bool);
      ("toBool", [Char], Bool);
      ("toBool", [Bool], Bool);
      ("toString", [Int], String);
      ("toString", [Float], String);
      ("toString", [Bool], String);
      ("toString", [String], String);
      ("toNah", [Int], Nah); 
      ("toNah", [String], Nah); 
      ("toNah", [Char], Nah); 
      ("toNah", [Float], Nah); 
      ("toNah", [Bool], Nah);
      ("pow2", [Float], Float);
      ("pow2", [Int], Float);
    ] 
  in

  (* Collects function tables for a list of function declarations *)
  let get_funcs f_list = 
    List.fold_left (fun m f -> build_func_table globals f m) built_in_funcs f_list

  in (globals, get_funcs f_list)
