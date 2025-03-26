open Ast
open Printf

let outfile = open_out Sys.argv.(2)

let write_transition(current_state, input_symbol, next_state, output_symbol, move) = 
	fprintf outfile "s%i %s s%i %s %s\n" current_state input_symbol next_state output_symbol move

exception Undefined_symbol of string

let check_symbol all_symbols symbol = if List.mem symbol all_symbols then () else raise (Undefined_symbol symbol)

let check_symbol_list all_symbols symbol_list = List.iter (check_symbol all_symbols) symbol_list

let rec eval (symbols, state) = function
	Left -> List.iter ( fun sym -> write_transition(state, sym, state + 1, sym, "left") ) symbols; (symbols, state + 1)
	
	| Right -> List.iter ( fun sym -> write_transition(state, sym, state + 1, sym, "right") ) symbols; (symbols, state + 1)
	
	| Write(out_sym) -> check_symbol symbols out_sym; 
						List.iter (fun sym -> write_transition(state, sym, state + 1, out_sym, "stay") ) symbols;
						(symbols, state + 1)
	
	| Exit -> (symbols, state + 1)
	
	| If(symbol_list, statements) -> 
		check_symbol_list symbols symbol_list;
		let (symbols, next_state) = eval (symbols, state + 1) statements in
		List.iter (fun sym ->
				let next_state = if List.mem sym symbol_list then state + 1 else next_state in
				write_transition(state, sym, next_state, sym, "stay") )
			symbols;
		(symbols, next_state)
		
	| IfElse(symbol_list, if_statements, else_statements) ->
		check_symbol_list symbols symbol_list;
		let (symbols, else_state) = eval (symbols, state + 1) if_statements in
		List.iter (fun sym ->
				let next_state = if List.mem sym symbol_list then state + 1 else else_state + 1 in
				write_transition(state, sym, next_state, sym, "stay") )
			symbols;
		let (symbols, next_state) = eval (symbols, else_state + 1) else_statements in
		List.iter (fun sym -> write_transition(else_state, sym, next_state, sym, "stay")) symbols;
		(symbols, next_state)

	| Unless(symbol_list, statements) -> 
		check_symbol_list symbols symbol_list;
		let (symbols, next_state) = eval (symbols, state + 1) statements in
		List.iter (fun sym ->
				let next_state = if List.mem sym symbol_list then next_state else state + 1 in 
				write_transition(state, sym, next_state, sym, "stay") )
			symbols;
		(symbols, next_state)		
	
	| While(symbol_list, statements) -> 
		check_symbol_list symbols symbol_list;
		let (symbols, jumpback_state) = eval (symbols, state + 1) statements in
		let next_state = jumpback_state + 1 in
		(* write transitions for condition test state *)
		List.iter (fun sym ->
				let next_state = if List.mem sym symbol_list then state + 1 else next_state in
				write_transition(state, sym, next_state, sym, "stay") )
			symbols;
		(* write transitions for jump-back state *)
		List.iter ( fun sym -> write_transition(jumpback_state, sym, state, sym, "stay") ) symbols;
		(symbols, next_state)
		
		
	| Until(symbol_list, statements) -> 
		check_symbol_list symbols symbol_list;
		let (symbols, jumpback_state) = eval (symbols, state + 1) statements in
		let next_state = jumpback_state + 1 in
		(* write transitions for condition test state *)
		List.iter (fun sym ->
				let next_state = if List.mem sym symbol_list then next_state else state + 1 in
				write_transition(state, sym, next_state, sym, "stay") )
			symbols;
		(* write transitions for jump-back state *)
		List.iter ( fun sym -> write_transition(jumpback_state, sym, state, sym, "stay") ) symbols;
		(symbols, next_state)
		
	| Block(statements) -> List.fold_left eval (symbols, state) statements
	
	| _ -> (symbols, state) (* everything else is unimplemented. do nothing *)

let program = function 
	Program(symbols, statements) -> let symbols = if List.mem "_" symbols then symbols else "_" :: symbols in List.fold_left eval (symbols, 0) statements

let _ = 
let lexbuf = Lexing.from_channel (open_in Sys.argv.(1)) in
program (Parser.program Scanner.token lexbuf)