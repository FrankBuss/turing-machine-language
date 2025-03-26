%{ open Ast %}

%token LPAREN RPAREN LBRACE RBRACE COMMA 
%token IF ELSE UNLESS WHILE UNTIL LEFT RIGHT WRITE EXIT EOF 
%token <string> SYMBOL

%start program
%type <Ast.program> program

%nonassoc IF
%nonassoc ELSE

%%

stmt:
 IF LPAREN symbol_list RPAREN stmt %prec IF { If($3, $5) }
| IF LPAREN symbol_list RPAREN stmt ELSE stmt { IfElse($3, $5, $7) }
| UNLESS LPAREN symbol_list RPAREN stmt { Unless($3, $5) }
| WHILE LPAREN symbol_list RPAREN stmt { While($3, $5) }
| UNTIL LPAREN symbol_list RPAREN stmt { Until($3, $5) }
| LEFT { Left }
| RIGHT { Right }
| WRITE SYMBOL { Write($2) }
| EXIT { Exit }
| LBRACE stmt_list RBRACE { Block(List.rev $2) }

stmt_list:
{ [] } /* nothing */ 
| stmt_list stmt { $2 :: $1 }

symbol_list:
 SYMBOL { [$1] }
| symbol_list COMMA SYMBOL { $3 :: $1 } /* a symbol list: e.g., write(a1, b2, c3) */

program:
symbol_list stmt_list EOF { Program($1, List.rev $2) }
