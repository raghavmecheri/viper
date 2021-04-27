(*
Top-level of the Viper compiler: scan & parse the input, check the resulting AST, generate LLVM IR, and dump the module 
REF: https://github.com/cwabbott0/microc-llvm/blob/master/microc.ml
*)

type action = Ast | Sast | LLVM_IR | Compile

let _ =
  let action = ref Compile in
  let input = ref "" in
  let set_action a () = action := a in
  let speclist = [
    ("-a", Arg.Unit (set_action Ast), "Pretty print the AST");
    ("-s", Arg.Unit (set_action Sast), "Pretty print the SAST");
    ("-l", Arg.Unit (set_action LLVM_IR), "Print the generated LLVM IR");
    ("-c", Arg.Unit (set_action Compile),
     "Check and print the generated LLVM IR (default)");
  ] in
  let usage_msg = "usage: ./viper.native [-a|-l] [file]" in
  Arg.parse speclist (fun s -> input := s) usage_msg;
  let channel = if !input = "" then
      stdin
    else
      open_in !input
  in
  let lexbuf = Lexing.from_channel channel in
  let ast = Parser.program Scanner.token lexbuf in
  (* this is sast, currently not used so replace _ with sast when used *)
  let desugared = Desugar.desugar ast in
  let sast = Semantdriver.check desugared in
  match !action with
    Ast -> print_string (Ast.string_of_program desugared)
  | Sast -> print_string (Sast.string_of_sprogram sast)
  | LLVM_IR -> print_string (Llvm.string_of_llmodule (Codegen.translate sast))
  | Compile -> let m = Codegen.translate sast in 
    Llvm_analysis.assert_valid_module m;
    print_string (Llvm.string_of_llmodule m)
