%{
#include "t2.tab.h"
%}

%%

[0-9]+ { yylval = atoi(yytext); return NUMBER; }
[-+\n] { return yytext[0]; }
.

%%
