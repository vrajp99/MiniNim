/* 
Reference: http://dinosaur.compilertools.net/bison/bison_5.html
*/

%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h> 
#include <math.h> 
#include "calc.h"  /* Contains definition of `symrec'        */
int  yylex(void);
void yyerror (char  *); 
%}

%union {
double   val;  /* For returning numbers.                   */
struct symrec  *tptr;   /* For returning symbol-table pointers      */
}

%token <val> NUM        /* Simple double precision number   */
%token <tptr> VAR       /* Variable                         */
%token <tptr> FNCT      /* Function                         */
%type  <val>  exp

%right '='
%left '-' '+'
%left '*' '/'
%left NEG     /* Negation--unary minus */
 //%right '^' /* Exponentiation        */
/* Grammar follows */

%%
input:   /* empty */
        | input line
;

line:
          '\n'
        | exp '\n'   { printf ("\t%lf\n", $1); }
        | error '\n' { yyerrok;                  }
;

exp:      NUM                { $$ = $1;}
        | VAR                { $$ = $1->value.var;}
        | VAR '=' exp        { $$ = $3; $1->value.var = $3;}
        | FNCT '(' exp ')'   { $$ = (*(($1)->value.fptr))($3);}
        | exp '+' exp        { $$ = $1 + $3;}
        | exp '-' exp        { $$ = $1 - $3;}
        | exp '*' exp        { $$ = $1 * $3;}
        | exp '/' exp        { $$ = $1 / $3;}
        | '-' exp  %prec NEG { $$ = -$2;}
        | '(' exp ')'        { $$ = $2;}
;
/* End of grammar */
%%

void init_table (){
   symrec *ptr1, *ptr2;
   ptr1 = putsym("sin", FNCT);
   ptr1->value.fptr = sin;
   ptr2 = putsym("cos", FNCT);
   ptr2->value.fptr = cos;
}

int main (){
   init_table();
   yyparse ();
}

void yyerror (char *s)  /* Called by yyparse on error */{
  printf ("%s\n", s);
}