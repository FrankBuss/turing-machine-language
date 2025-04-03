{
  open Parser
  exception Lexer_error of string
}

rule token = parse
| [' ' '\t' '\r' '\n'] { token lexbuf }
| "/*" { comment lexbuf }
| "if" { IF }
| "else" { ELSE }
| "unless" { UNLESS }
| "while" { WHILE }
| "until" { UNTIL }
| "left" { LEFT }
| "right" { RIGHT }
| "write" { WRITE }
| "exit" { EXIT }
| "def" { DEF }
| '(' { LPAREN }
| ')' { RPAREN }
| '{' { LBRACE }
| '}' { RBRACE }
| ',' { COMMA }
| eof { EOF }
| "_" { SYMBOL("_") }
| ['.' '-' '+' '*' '/' '%' '$' '#' '@' '!' '&' '|' '^' '<' '>' '=' '~' '?' ':' ';' '[' ']' 'a'-'z' 'A'-'Z' '0'-'9'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '.' '-' '+' '*' '/' '%' '$' '#' '@' '!' '&' '|' '^' '<' '>' '=' '~' '?' ':' ';' '[' ']']* as lex {
    match lex with
    | "if" -> IF
    | "else" -> ELSE
    | "unless" -> UNLESS
    | "while" -> WHILE
    | "until" -> UNTIL
    | "left" -> LEFT
    | "right" -> RIGHT
    | "write" -> WRITE
    | "exit" -> EXIT
    | "def" -> DEF
    | _ -> SYMBOL(lex)  (* All identifiers treated as SYMBOL tokens *)
}
| _ as char { 
    let msg = Printf.sprintf "error: illegal character '%c' at offset %d" 
                char (Lexing.lexeme_start lexbuf) in
    raise (Lexer_error msg)
}

and comment = parse
| "*/" { token lexbuf }
| _ { comment lexbuf }