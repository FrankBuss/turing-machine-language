%{ %}

%token EOF
%token <string> SYMBOL

%start tape
%type <string list> symbol_list
%type <string list> tape

%%

symbol_list:
	symbol_list SYMBOL	{ $2::$1 }
	| SYMBOL			{ [$1] }

tape:
	symbol_list EOF		{ List.rev $1 }
	| EOF				{ [] }
