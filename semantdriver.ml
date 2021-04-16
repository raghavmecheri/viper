open Ast
open Sast
open Boolcheck
open Rhandlhand 
open Decs 
open Typeof 


let symbol_table = get_decs (statements, functions);

let global_scope = fst symbol_table;

let function_scopes = snd symbol_table;

let check_function ( fd : func_decl ) = 
    let key_func = key_string fd.fname fd.formals in 
      let current_function = StringMap.find key_func symbol_table in
        List.map (check_stmt current_function.locals false) fd.locals 

 

in

let rec expr scope deepscope = function 
    IntegerLiteral l -> (Int, SIntegerLiteral l)
|   CharacterLiteral l -> (Char, SCharacterLiteral l)
|   BoolLit l -> (Bool, SBoolLit l) 
|   FloatLiteral l -> (Float, SFloatLiteral l)
|   StringLiteral l -> (String, SStringLiteral l) 
|   Noexpr -> (Nah, SNoexpr)
|   ListLit l -> ()
|   DictElem(l, s) -> ()
|   DictLit l -> () 
|   Id l -> (toi scope l, SId l)
|   Binop(e1, op, e2) as e -> 
          let (t1, e1') = expr e1 
          and (t2, e2') = expr e2 in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Mult | Div | Mod when same && t1 = Int   -> Int
          | Add | Sub | Mult | Div | Mod when same && t1 = Float -> Float
          | Equal | Neq            when same               -> Bool
          | Less | Leq | Greater | Geq
                     when same && (t1 = Int || t1 = Float) -> Bool
          | And | Or | Has when same && t1 = Bool -> Bool
          | _ -> raise (
	      Failure ("illegal binary operator " ^
                       string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                       string_of_typ t2 ^ " in " ^ string_of_expr e))
          in (ty, SBinop((t1, e1'), op, (t2, e2')))
|   Unop(uop, e) as ex -> 
          let (t, e') = expr e in
          let ty = match op with
            Neg | Incr | Decr when t = Int || t = Float -> t
          | Not when t = Bool -> Bool
          | _ -> raise (Failure ("illegal unary operator " ^ 
                                 string_of_uop op ^ string_of_typ t ^
                                 " in " ^ string_of_expr ex))
          in (ty, SUnop(op, (t, e')))
|   Assign(s, e) -> ()
|   Deconstruct(l, e) -> ()
|   OpAssign(s, op, e) -> ()
|   DecAssign(ty, l, expr1) -> if deepscope then (add_symbol l ty scope ; check_assign ty string (expr expr1)) else check_assign ty string (expr expr1)
|   Access(e1, e2) -> () 
|   AccessAssign(e1, e2, e3) -> () 
|   Call(s, l) -> ()
|   AttributeCall(e, s, l) -> () 

in 

let rec check_stmt scope deepscope = 
  let new_scope = {
    variables = StringMap.empty;
    parent = Some(scope);
  } in function 
    Expr e -> SExpr (expr scope deepscope e) 
|   Skip e -> SSkip (expr scope deepscope e) 
|   Abort e -> SAbort (expr scope deepscope e) 
|   Panic e -> SPanic (expr scope deepscope e) 
|   If(p, b1, b2) -> SIf(check_bool p, check_stmt scope deepscope b1, check_stmt scope deepscope b2) 
|   While(p, s) -> SWhile(check_bool p, check_stmt new_scope true s) 
|   Return e -> let (t, e') = expr scope deepscope e in 
    if t = fd.typ then SReturn (t, e') 
    else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_expr e)) 
|   Block sl -> 
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt new_scope deepscope s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt new_scope deepscope s :: check_stmt_list ss
            | []              -> []
          in SBlock(check_stmt_list sl)
|   PretendBlock sl -> List.map (check_stmt scope false) sl 

|   Dec(ty, l) -> if deepscope then (add_symbol l ty scope ; SDec(ty, l)) else SDec(ty, l)

 in

let check(statements, functions) = (List.map (check_stmt global_scope false) statements, List.map check_function functions)