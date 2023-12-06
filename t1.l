%{
#include "t1.tab.h"
%}

%%

[0-9]+ { return NUMBER; }
[-+*/()\n] { return yytext[0]; }
.
%%
