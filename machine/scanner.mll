{ open Parser }

rule token = parse
[' ' '\t' '\r' '\n'] { token lexbuf }
| "left" { LEFT }
| "right" { RIGHT }
| "stay" { STAY }
| ['.' '-' '+' '*' '/' '%' '$' '#' '@' '!' '&' '|' '^' '<' '>' '=' '~' '?' ':' ';' '[' ']' 'a'-'z' 'A'-'Z' '0'-'9' '_']+ as id { ID(id) }
| eof { EOF }