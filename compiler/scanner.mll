{ open Parser }

rule token = parse
| "if" { IF } 
| "else" { ELSE }
| "unless" { UNLESS }
| "while" { WHILE }
| "until" { UNTIL }
| "left" { LEFT } 
| "right" { RIGHT }
| "write" { WRITE }
| "exit" { EXIT }
| "else" { ELSE }
| '(' { LPAREN } 
| ')' { RPAREN }
| '{' { LBRACE } 
| '}' { RBRACE }
| (('_')  | (['a'-'z''A'-'Z''0'-'9']+)) as lxm { SYMBOL(lxm) } (* blanks are special symbols which should never be concatenated *)
| ',' { COMMA }
| [' ' '\t' '\r' '\n'] { token lexbuf }
| "/*" { comment lexbuf }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
"*/" { token lexbuf } (* we had issues ending comments with newline due to variet in operating systems so went with c-style comments insteads *)
| _ { comment lexbuf }