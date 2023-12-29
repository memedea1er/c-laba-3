%{
#include "t4.tab.h"
%}

%%
"+"     { return ADD; }
"-"     { return SUB; }
"*"     { return MUL; }
"/"     { return DIV; }
"("     { return LPAREN; }
")"     { return RPAREN; }
[0-9]+  { yylval.d = atof(yytext); return NUMBER; }
\n      { return EOL; }
[ \t]   ; /* пропуск пробелов и табуляций */
.       { return yytext[0]; } /* остальные символы обрабатываются как есть */

%%

int yywrap() {
    return 1;
}
