########## grammer for SIL ########## 

s --> <glob_decl> <funct_def> <main_funct_def>

glob_decl --> decl (<datatype> <var>((,<var>)*)?;)+ enddecl

funct_def --> <datatype> <funct> { <loc_decl> <funct_body> }



loc_decl --> decl (<datatype> <id> ((,<id>)*)?;)+ enddecl

funct_body -->



var --> <id> | <array> | <funct>

array --> <id>[<int>]

funct --> <id> (<arg_list>*)

int --> [0-9][0-9]*

arg_list --> <datatype> (&)?<id> ((,(&)?<id>)*)?;

datatype --> (integer|boolean)

id --> [a-zA-Z][a-zA-Z0-9]*
