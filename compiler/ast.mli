type symbol = string

type stmt =                                   (* Statements *)
   Block of stmt list                          (* { ... } *)
| If of symbol list * stmt                  (* if (0,1) {} *)
| IfElse of symbol list * stmt * stmt
| Unless of symbol list * stmt
| While of symbol list * stmt             (* while (0,1) { left } *)
| Until of symbol list * stmt             (* until (0,1) { left } *)
| Left
| Right
| Write of symbol                            (* Write (0) *)
| Exit
| Program of symbol list * stmt list

type program = Program of symbol list * stmt list