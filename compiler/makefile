all: compiler.exe

compiler.exe: ast.cmi ast.cmo parser.cmi parser.cmo scanner.cmo compiler.cmo
	ocamlc -o compiler.exe parser.cmo scanner.cmo compiler.cmo

ast.cmi: ast.mli
	ocamlc -c ast.mli

ast.cmo: ast.ml ast.cmi
	ocamlc -c ast.ml

parser.mli parser.ml: parser.mly
	ocamlyacc parser.mly

parser.cmi: parser.mli ast.cmi
	ocamlc -c parser.mli

parser.cmo: parser.ml parser.cmi
	ocamlc -c parser.ml

scanner.ml: scanner.mll
	ocamllex scanner.mll

scanner.cmo: scanner.ml parser.cmi
	ocamlc -c scanner.ml

compiler.cmo: compiler.ml parser.cmi scanner.cmi ast.cmi
	ocamlc -c compiler.ml

clean:
	rm -f *.cmi *.cmo *.exe parser.ml parser.mli scanner.ml
