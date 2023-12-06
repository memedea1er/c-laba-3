%{
#include <stdio.h>
extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

%}

%token NUMBER

%%

expression: NUMBER { printf("NUMBER "); }
          |  expression NUMBER { printf("NUMBER "); }
          |  expression '+' { printf("PLUS "); }
          |  expression '-' { printf("MINUS "); }
          |  expression '*' { printf("MULTIPLY "); }
          |  expression '/' { printf("DIVIDE "); }
          |  expression '(' { printf("LPAREN "); }
          |  expression ')' { printf("RPAREN "); }
          |  expression '\n' { printf("\n"); return 0;}
          ;


%%

int yylex();

int main() {
    yyparse();
    return 0;
}
