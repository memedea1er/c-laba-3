%{

#include <stdio.h>
#include <stdlib.h>

// yyerror: функция для вывода сообщений об ошибках от Bison/Yacc
void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}

// Определение структуры для общего узла AST
struct ast {
    int nodetype;       // Тип узла (оператор или тип данных)
    struct ast *l;      // Указатель на левый подузел
    struct ast *r;      // Указатель на правый подузел
};

// Структура для узла AST, содержащего число
struct numval {
    int nodetype;       // Тип узла
    double number;      // Значение числа
};

// Прототипы функций
struct ast *newast(int nodetype, struct ast *l, struct ast *r); // Создание нового узла AST
struct ast *newnum(double d);                                  // Создание узла AST с числом
double eval(struct ast *a);                                    // Вычисление значения AST
void treefree(struct ast *a);                                  // Очистка памяти, занятой AST

// Внешние функции Bison/Yacc
extern int yylex();
extern int yyparse();
extern struct ast *root; // Корневой узел AST, созданный Bison/Yacc

// Начало секции Bison/Yacc

    // Включения и объявления, необходимые для Bison/Yacc
%}

%union {
    struct ast *a; // Используется для хранения указателей на AST узлы
    double d;      // Используется для хранения числовых значений
}

// Определение токенов и их типов
%token <d> NUMBER
%token ADD SUB MUL DIV LPAREN RPAREN
%token EOL

// Указание типов для не терминальных символов
%type <a> expr term factor

// Определение приоритетов и ассоциативности операторов
%left ADD SUB
%left MUL DIV

%start program // Указание начальной точки грамматики

%%
// Правила грамматики Bison/Yacc

// Определение структуры программы
program:
    /* пусто */
    | program expr EOL { printf("Result: %f\n", eval($2)); treefree($2); } // Вычисление и вывод результата выражения
    ;

// Правила для выражений, термов и факторов
expr: term
    | expr ADD term { $$ = newast('+', $1, $3); } // Обработка операции сложения
    | expr SUB term { $$ = newast('-', $1, $3); } // Обработка операции вычитания
    ;

term: factor
    | term MUL factor { $$ = newast('*', $1, $3); } // Обработка операции умножения
    | term DIV factor { $$ = newast('/', $1, $3); } // Обработка операции деления
    ;

factor: NUMBER { $$ = newnum($1); }                // Обработка числового литерала
    | LPAREN expr RPAREN { $$ = $2; }              // Обработка выражений в скобках
    ;
%%

// Реализация функций для работы с AST

// Создание нового узла AST
struct ast *newast(int nodetype, struct ast *l, struct ast *r) {
    struct ast *a = malloc(sizeof(struct ast));
    if (!a) {
        yyerror("Out of memory");
        exit(1);
    }
    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

// Создание узла AST для числового значения
struct ast *newnum(double d) {
    struct numval *a = malloc(sizeof(struct numval));SS
    if (!a) {
        yyerror("Out of memory");
        exit(1);
    }
    a->nodetype = 'K'; // 'K' используется для обозначения константного узла
    a->number = d;
    return (struct ast *)a;
}

// Вычисление значения выражения AST
double eval(struct ast *a) {
    if (!a) {
        yyerror("Internal error: null pointer in eval");
        return 0.0;
    }

    double v;

    switch (a->nodetype) {
        case 'K': v = ((struct numval *)a)->number; break;
        case '+': v = eval(a->l) + eval(a->r); break;
        case '-': v = eval(a->l) - eval(a->r); break;
        case '*': v = eval(a->l) * eval(a->r); break;
        case '/': v = eval(a->l) / eval(a->r); break;
        default: yyerror("Unknown operator");
                 return 0.0;
    }
    return v;
}

// Освобождение памяти AST
void treefree(struct ast *a) {
    if (!a) return;

    switch (a->nodetype) {
        case 'K': // Для числовых узлов
            free(a);
            break;
        case '+':
        case '-':
        case '*':
        case '/':
            treefree(a->l);
            treefree(a->r);
            free(a);
            break;
        default: yyerror("Unknown operator");
    }
}

// Основная функция
int main() {
    printf("Введите арифметическое выражение: ");
    yyparse();
    return 0;
}
