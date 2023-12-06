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
     int number;
}

%token NUMBER
%type <number> expression
%type <number> term

%%

expression: expression '\n' { printf("Result: %d\n", $1); return 0;} 
          | expression '+' term   { $$ = $1 + $3; }
          | expression '-' term   { $$ = $1 - $3; }
          | term                  { $$ = $1; }
          ;

term: NUMBER { $$ = $1; }
    ;

%%

int yylex();

int main() {
    yyparse();
    return 0;
}
