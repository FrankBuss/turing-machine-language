open Ast
open Printf

let outfile = ref stdout

let write_transition (current_state, input_symbol, next_state, output_symbol, move) =
  fprintf !outfile "s%i %s s%i %s %s\n"
          current_state input_symbol next_state output_symbol move

exception Undefined_symbol of string

let check_symbol alphabet sym =
  if not (List.mem sym alphabet) then
    raise (Undefined_symbol ("error: undefined symbol '" ^ sym ^ "'"))

let check_symbol_list alphabet syms =
  if syms = [] then
    []  (* Allow empty symbol lists for function calls with no parameters *)
  else
    (List.iter (check_symbol alphabet) syms; syms)

let functions : (string, (string list * stmt)) Hashtbl.t = Hashtbl.create 16

let rec substitute statement env =
  let map_syms syms =
    List.map (fun s -> try List.assoc s env with Not_found -> s) syms
  in
  match statement with
  | Block(stmts) ->
      Block(List.map (fun st -> substitute st env) stmts)
  | If(syms, body) ->
      If(map_syms syms, substitute body env)
  | IfElse(syms, s_if, s_else) ->
      IfElse(map_syms syms, substitute s_if env, substitute s_else env)
  | Unless(syms, body) ->
      Unless(map_syms syms, substitute body env)
  | While(syms, body) ->
      While(map_syms syms, substitute body env)
  | Until(syms, body) ->
      Until(map_syms syms, substitute body env)
  | Left | Right | Exit ->
      statement
  | Write(sym) ->
      let sym' = try List.assoc sym env with Not_found -> sym in
      Write(sym')
  | FunctionCall(fnName, actuals) ->
      let actuals' = map_syms actuals in
      FunctionCall(fnName, actuals')
  | FunctionDef(_, _, _) ->
      statement

let rec eval (alphabet, state) stm =
  match stm with
  | Left ->
      List.iter
        (fun sym ->
          write_transition (state, sym, state + 1, sym, "left"))
        alphabet;
      (alphabet, state + 1)
  | Right ->
      List.iter
        (fun sym ->
          write_transition (state, sym, state + 1, sym, "right"))
        alphabet;
      (alphabet, state + 1)
  | Write out_sym ->
      check_symbol alphabet out_sym;
      List.iter
        (fun sym ->
          write_transition (state, sym, state + 1, out_sym, "stay"))
        alphabet;
      (alphabet, state + 1)
  | Exit ->
      (alphabet, state + 1)
  | If(syms, body) ->
      if syms = [] then
        raise (Failure "error: empty symbol list in condition");
      List.iter (check_symbol alphabet) syms;
      let (alphabet, afterBody) = eval (alphabet, state + 1) body in
      List.iter (fun tapeSym ->
        let nextSt = if List.mem tapeSym syms then (state + 1) else afterBody in
        write_transition (state, tapeSym, nextSt, tapeSym, "stay")
      ) alphabet;
      (alphabet, afterBody)
  | IfElse(syms, s_if, s_else) ->
      if syms = [] then
        raise (Failure "error: empty symbol list in condition");
      List.iter (check_symbol alphabet) syms;
      let (alphabet, endIf) = eval (alphabet, state + 1) s_if in
      let (alphabet, endElse) = eval (alphabet, endIf + 1) s_else in
      List.iter (fun tapeSym ->
        let branchSt = if List.mem tapeSym syms then (state + 1) else (endIf + 1) in
        write_transition (state, tapeSym, branchSt, tapeSym, "stay")
      ) alphabet;
      List.iter (fun tapeSym ->
        write_transition (endIf, tapeSym, endElse, tapeSym, "stay")
      ) alphabet;
      (alphabet, endElse)
  | Unless(syms, body) ->
      if syms = [] then
        raise (Failure "error: empty symbol list in condition");
      List.iter (check_symbol alphabet) syms;
      let (alphabet, endBody) = eval (alphabet, state + 1) body in
      List.iter (fun tapeSym ->
        let nextSt = if List.mem tapeSym syms then endBody else (state + 1) in
        write_transition (state, tapeSym, nextSt, tapeSym, "stay")
      ) alphabet;
      (alphabet, endBody)
  | While(syms, body) ->
      if syms = [] then
        raise (Failure "error: empty symbol list in condition");
      List.iter (check_symbol alphabet) syms;
      let (alphabet, endBody) = eval (alphabet, state + 1) body in
      let outState = endBody + 1 in
      List.iter (fun tapeSym ->
        let jump = if List.mem tapeSym syms then (state + 1) else outState in
        write_transition (state, tapeSym, jump, tapeSym, "stay")
      ) alphabet;
      List.iter (fun tapeSym ->
        write_transition (endBody, tapeSym, state, tapeSym, "stay")
      ) alphabet;
      (alphabet, outState)
  | Until(syms, body) ->
      if syms = [] then
        raise (Failure "error: empty symbol list in condition");
      List.iter (check_symbol alphabet) syms;
      let (alphabet, endBody) = eval (alphabet, state + 1) body in
      let outState = endBody + 1 in
      List.iter (fun tapeSym ->
        let jump = if List.mem tapeSym syms then outState else (state + 1) in
        write_transition (state, tapeSym, jump, tapeSym, "stay")
      ) alphabet;
      List.iter (fun tapeSym ->
        write_transition (endBody, tapeSym, state, tapeSym, "stay")
      ) alphabet;
      (alphabet, outState)
  | Block(stmts) ->
      List.fold_left (fun (alpha, st) s -> eval (alpha, st) s) (alphabet, state) stmts
  | FunctionCall(fnName, actuals) ->
      (* Function calls can have empty parameter lists *)
      List.iter (fun param -> check_symbol alphabet param) actuals;
      begin
        try
          let (formals, body) = Hashtbl.find functions fnName in
          if List.length formals <> List.length actuals then
            failwith ("error: arity mismatch in call to function " ^ fnName);
          let env = List.combine formals actuals in
          let expanded = substitute body env in
          eval (alphabet, state) expanded
        with Not_found ->
          failwith ("error: undefined function: " ^ fnName)
      end
  | FunctionDef(_, _, _) ->
      (alphabet, state)

let compile_program (prg : program) =
  match prg with
  | Program(alphabet, fnDefs, mainStmts) ->
      List.iter (fun (fnName, params, bodyStmt) ->
        Hashtbl.add functions fnName (params, bodyStmt)
      ) fnDefs;
      let all_syms =
        if List.mem "_" alphabet then alphabet
        else "_" :: alphabet
      in
      ignore (List.fold_left eval (all_syms, 0) mainStmts)

let () =
  if Array.length Sys.argv < 3 then begin
    eprintf "Usage: %s <source.tmsl> <output.tm>\n" Sys.argv.(0);
    exit 1
  end;
  let input_file = Sys.argv.(1) in
  let output_file = Sys.argv.(2) in
  outfile := open_out output_file;
  let lexbuf = Lexing.from_channel (open_in input_file) in
  let parsed_ast =
    try
      Parser.program Scanner.token lexbuf
    with
    | Scanner.Lexer_error msg ->
        eprintf "%s\n" msg;
        exit 1
    | Failure msg ->
        eprintf "%s\n" msg;
        exit 1
    | Parsing.Parse_error ->
        eprintf "error: syntax error at offset %d\n" (Lexing.lexeme_start lexbuf);
        exit 1
  in
  try
    compile_program parsed_ast;
    close_out !outfile;
    exit 0
  with
  | Undefined_symbol err ->
    eprintf "%s\n" err;
    close_out !outfile;
    exit 1
  | Failure msg ->
    eprintf "%s\n" msg;
    close_out !outfile;
    exit 1