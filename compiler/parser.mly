%{
  open Ast
%}

%nonassoc IF
%nonassoc ELSE

%token <string> IDENT
%token <string> SYMBOL
%token LPAREN RPAREN LBRACE RBRACE COMMA
%token DEF
%token IF ELSE UNLESS WHILE UNTIL LEFT RIGHT WRITE EXIT
%token EOF

%start program
%type <Ast.program> program

%%

program:
  symbol_list function_defs stmt_list EOF
    {
      Program($1, List.rev $2, List.rev $3)
    }

function_defs:
    { [] }
  | function_defs function_def
    { $2 :: $1 }

function_def:
  DEF SYMBOL LPAREN opt_param_list RPAREN block
    {
      ($2, $4, $6)
    }

opt_param_list:
    { [] }
  | param_list
    { List.rev $1 }

param_list:
    SYMBOL
    { [$1] }
  | param_list COMMA SYMBOL
    { $3 :: $1 }

symbol_list:
    SYMBOL
    { [$1] }
  | symbol_list COMMA SYMBOL
    { $3 :: $1 }

stmt_list:
    { [] }
  | stmt_list stmt
    { $2 :: $1 }

stmt:
  IF LPAREN opt_symbol_list RPAREN stmt %prec IF
    { If($3, $5) }
| IF LPAREN opt_symbol_list RPAREN stmt ELSE stmt
    { IfElse($3, $5, $7) }
| UNLESS LPAREN opt_symbol_list RPAREN stmt
    { Unless($3, $5) }
| WHILE LPAREN opt_symbol_list RPAREN stmt
    { While($3, $5) }
| UNTIL LPAREN opt_symbol_list RPAREN stmt
    { Until($3, $5) }
| LEFT
    { Left }
| RIGHT
    { Right }
| WRITE SYMBOL
    { Write($2) }
| EXIT
    { Exit }
| block
    { $1 }
| SYMBOL LPAREN opt_symbol_list RPAREN
    { FunctionCall($1, $3) }

opt_symbol_list:
    { [] }
  | symbol_list
    { List.rev $1 }

block:
  LBRACE stmt_list RBRACE
    {
      Block(List.rev $2)
    }