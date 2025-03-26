open Ast

exception Execution_halted

let rec follow_transition table state symbol = match table with
	[] -> raise Execution_halted
	| head::tail ->
		if (state, symbol) = (head.current_state, head.input_symbol) then 
			(head.next_state, head.output_symbol, head.move)
		else
			follow_transition tail state symbol
	
let rec trim_blanks_front tape = match tape with
	[] -> []
	| head::tail -> if head = "_" then trim_blanks_front tail else head::tail

let trim_blanks tape = 
	let tape = Array.to_list tape in
		Array.of_list (List.rev (trim_blanks_front (List.rev (trim_blanks_front tape))))

let write_output outfile tape = Array.iter (fun symbol -> output_string outfile symbol; output_char outfile ' ') (trim_blanks tape)

let rec execute table tape state pos = 
	(* print_string "execute state = "; print_string state; print_string " pos = "; print_int pos; print_newline (); *)
	let symbol = try tape.(pos) with Invalid_argument err -> "_" in
	(* print_string "tape = "; write_output stdout tape; print_newline (); *)
	(* print_string "symbol = "; print_string symbol; print_newline (); print_newline (); *)
	try
		let (next_state, output_symbol, move) = follow_transition table state symbol in
		let next_pos = pos + move in
		try
			tape.(pos) <- output_symbol;
			execute table tape next_state next_pos
		with Invalid_argument err ->
			if pos < 0 then
			(
				assert (pos = -1);
				let next_pos = next_pos + 1 in	(* I'm appending to the front of the array, so all the positions shift by 1 *)
				execute table (Array.append [| output_symbol |] tape) next_state next_pos
			)
			else
			(
				assert (pos = Array.length tape);
				execute table (Array.append tape [| output_symbol |]) next_state next_pos
			)
	with Execution_halted ->
		(* print_string "execution halted"; *)
		tape

let _ = 
let lexbuf = Lexing.from_channel (open_in Sys.argv.(1)) in
let table = Parser.table Scanner.token lexbuf in
let lexbuf = Lexing.from_channel (open_in Sys.argv.(2)) in
let tape = Tape_parser.tape Tape_scanner.token lexbuf in
let tape = execute table (Array.of_list tape) "s0" 0 in
let outfile = open_out Sys.argv.(3) in
write_output outfile tape

