type symbol = string
type stmt =
  | Block of stmt list
  | If of symbol list * stmt
  | IfElse of symbol list * stmt * stmt
  | Unless of symbol list * stmt
  | While of symbol list * stmt
  | Until of symbol list * stmt
  | Left
  | Right
  | Write of symbol
  | Exit
  | FunctionCall of string * symbol list
  | FunctionDef of string * string list * stmt
type program =
  Program of symbol list
           * (string * string list * stmt) list
           * stmt list