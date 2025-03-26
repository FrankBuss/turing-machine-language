ocamllex scanner.mll
ocamlyacc parser.mly
ocamlc -c ast.mli
ocamlc -c parser.mli
ocamlc -c scanner.ml
ocamlc -c parser.ml
ocamlc -c compiler.ml
ocamlc -o compiler.exe parser.cmo scanner.cmo compiler.cmo

pause