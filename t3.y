%{
#include <stdio.h>
extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

%}

%union {
     double number;
}
%token <number> NUMBER
%type <number> factor
%type <number> term
%type <number> expr

%%

expr: expr '\n' { printf("\nResult: %.2f\n", $1); return 0;}  
    | term                 { $$ = $1; }
    | expr '+' term        { printf("+ "); $$ = $1 + $3; }
    | expr '-' term        { printf("- "); $$ = $1 - $3; }
    ;

term: factor               { $$ = $1; }
    | term '*' factor      { printf("* "); $$ = $1 * $3; }
    | term '/' factor      { printf("/ "); $$ = $1 / $3; }
    ;

factor: NUMBER            { printf("%.2f ", $1); $$ = $1; }
      | '(' expr ')'       { $$ = $2; }
      ;

%%

int yylex();

int main() {
    yyparse();
    return 0;
}
