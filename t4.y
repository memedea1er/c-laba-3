%{

#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *msg) {
    fprintf(stderr, "%s\n", msg);
}

struct tree {
    int type;
    struct tree *left;
    struct tree *right;
};

struct value {
    int type;
    double val;
};

struct tree *newTree(int type, struct tree *left, struct tree *right);
struct tree *newValue(double d);
double evaluate(struct tree *t);
void freeTree(struct tree *t);

extern int yylex();
extern int yyparse();
extern struct tree *root;

%}

%union {
    struct tree *t;
    double d;
}

%token <d> NUM
%token ADD SUB MUL DIV LPAREN RPAREN
%token EOL

%type <t> expr term factor

%left ADD SUB
%left MUL DIV

%start program

%%

program:
    | program expr EOL { printf("Result: %f\n", evaluate($2)); freeTree($2); return 0; }
    ;

expr: term
    | expr ADD term { $$ = newTree('+', $1, $3); }
    | expr SUB term { $$ = newTree('-', $1, $3); }
    ;

term: factor
    | term MUL factor { $$ = newTree('*', $1, $3); }
    | term DIV factor { $$ = newTree('/', $1, $3); }
    ;

factor: NUM { $$ = newValue($1); }
    | LPAREN expr RPAREN { $$ = $2; }
    ;
%%

struct tree *newTree(int type, struct tree *left, struct tree *right) {
    struct tree *t = malloc(sizeof(struct tree));
    if (!t) {
        yyerror("Out of memory");
        exit(1);
    }
    t->type = type;
    t->left = left;
    t->right = right;
    return t;
}

struct tree *newValue(double d) {
    struct value *v = malloc(sizeof(struct value));
    if (!v) {
        yyerror("Out of memory");
        exit(1);
    }
    v->type = 'K';
    v->val = d;
    return (struct tree *)v;
}

double evaluate(struct tree *t) {
    if (!t) {
        yyerror("Internal yyerror: null pointer in eval");
        return 0.0;
    }

    double v;

    switch (t->type) {
        case 'K': v = ((struct value *)t)->val; break;
        case '+': v = evaluate(t->left) + evaluate(t->right); break;
        case '-': v = evaluate(t->left) - evaluate(t->right); break;
        case '*': v = evaluate(t->left) * evaluate(t->right); break;
        case '/': v = evaluate(t->left) / evaluate(t->right); break;
        default: yyerror("Unknown operator");
                 return 0.0;
    }
    return v;
}

void freeTree(struct tree *t) {
    if (!t) return;

    switch (t->type) {
        case 'K':
            free(t);
            break;
        case '+':
        case '-':
        case '*':
        case '/':
            freeTree(t->left);
            freeTree(t->right);
            free(t);
            break;
        default: yyerror("Unknown operator");
    }
}

int main() {
    printf("Input expression: ");
    yyparse();
}
