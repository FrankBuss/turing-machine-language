	ocamllex scanner.mll
	ocamllex tape_scanner.mll
	ocamlyacc parser.mly
	ocamlyacc tape_parser.mly
	ocamlc -c ast.mli
	ocamlc -c parser.mli
	ocamlc -c tape_parser.mli
	ocamlc -c scanner.ml
	ocamlc -c tape_scanner.ml
	ocamlc -c parser.ml
	ocamlc -c tape_parser.ml
	ocamlc -c machine.ml
	ocamlc -o machine.exe parser.cmo scanner.cmo tape_parser.cmo tape_scanner.cmo machine.cmo

