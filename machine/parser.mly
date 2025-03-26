%{ open Ast %}

%token LEFT RIGHT STAY EOF
%token <string> ID

%start table
%type <int> direction
%type <Ast.transition> transition
%type <Ast.transition list> transitionlist
%type <Ast.transition list> table

%%

direction:
	LEFT		{ -1 }
	| RIGHT		{ 1 }
	| STAY		{ 0 }

transition:
	ID ID ID ID direction	{ {current_state = $1;
								input_symbol = $2;
								next_state = $3;
								output_symbol = $4;
								move = $5} }
	
transitionlist:
	transitionlist transition	{ $2::$1 }
	| transition		{ [$1] }
	
table:
	transitionlist EOF	{ List.rev $1 }
