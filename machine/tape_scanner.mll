{ open Tape_parser }

rule token = parse
[' ' '\t' '\r' '\n'] { token lexbuf }
| ['a'-'z' 'A'-'Z' '0'-'9' '_']+ as symbol { SYMBOL(symbol) }
| eof { EOF }