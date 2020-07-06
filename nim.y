/* 
Reference: http://dinosaur.compilertools.net/bison/bison_5.html
*/

%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h> 
#include <math.h> 
#include "symrec.h"  /* Contains definition of `symrec'        */
int  yylex(void);
void yyerror (char  *); 
%}

%union {
int integer;
double floater;  /* For returning numbers.                   */
char *str;
char ch;
struct symrec  *tptr;   /* For returning symbol-table pointers      */
}

%token <integer> INTLIT
%token <floater> FLOATLIT
%token <str> STRLIT
%token <ch> CHARLIT
%token <integer> BOOLLIT
%token <str> IDENT
%token <str> INDG
%token <str> INDEQ
%token <str> DED

%nonassoc IFX
%nonassoc INDEQ

// %type  <int> exp

%left "xor"
%left "or" 
%left "and"
%left "!=" 
%left ">" 
%left ">=" 
%left "<" 
%left "<=" 
%left "==" 
%left ".." 
%left "-" 
%left "+" 
%left "%" 
%left "mod"
%left "div"
%left "/" 
%left "*" 
%right "$"
%right "not"
%right UPLUS
%right UMINUS
%nonassoc LPAREN

%locations

/* Grammar follows */

%%

module: complexOrSimpleStmt
        | complexOrSimpleStmt module2 
        | 
;
module2: INDEQ complexOrSimpleStmt module2 
        | INDEQ complexOrSimpleStmt
;
comma: ","
;
colon: ":"
;
// prefixOperator: "not" 
//                | "+"
//                | "-"
//                | "$"
// ;
sExpr: sExpr "xor" sExpr  
      | sExpr "or" sExpr
      | sExpr "and" sExpr 
      | sExpr "!=" sExpr 
      | sExpr ">" sExpr 
      | sExpr ">=" sExpr 
      | sExpr "<" sExpr 
      | sExpr "<=" sExpr 
      | sExpr "==" sExpr 
      | sExpr ".." sExpr 
      | sExpr "-" sExpr 
      | sExpr "+" sExpr 
      | sExpr "%" sExpr 
      | sExpr "mod" sExpr 
      | sExpr "div" sExpr 
      | sExpr "/" sExpr 
      | sExpr "*" sExpr 
      | "+" sExpr %prec UPLUS
      | "-" sExpr %prec UMINUS
      | "$" sExpr
      | "not" sExpr
      | '(' sExpr ')' %prec LPAREN
      | primary
;
symbol: IDENT
;

exprList: expr comma exprList 
         | expr
;
literal: BOOLLIT 
        | INTLIT 
        | FLOATLIT 
        | STRLIT 
        | CHARLIT 
        | "nil"
;
identOrLiteral: symbol 
               | literal 
               | arrayConstr  
               | tupleConstr
;
tupleConstr: "(" exprList ")"
;
arrayConstr: "[" exprList "]"
;
primarySuffix: "(" exprList ")" 
              | "("")" 
              | "["  expr  "]" 
              | "."  symbol
;
ifExpr: "if" condExpr
;
condExpr: expr colon expr elifCondExpr 
;
elifCondExpr: "elif" expr colon expr elifCondExpr 
             | "else" colon expr
;
symbolCommaNoHang: symbolCommaNoHang comma symbol 
                | symbol comma symbol 
;
declColon: symbol ":"  typeDescFunc
;
inlTupleDecl: "tuple" "["   declColonCommaNoHang   "]"
;
arrayDecl: "array" "["  INTLIT comma typeDesc "]"
;
paramList: "(" declColonCommaNoHang ")" 
          | "(" ")"
;
declColonCommaNoHang: declColon comma declColonCommaNoHang 
                     | declColon 
;
paramListColon: paramList ":"  typeDescFunc 
               | ":"  typeDesc
               |
;
typeDescFunc: typeDesc 
             | "var" typeDesc
;
forStmt: "for"  symbolCommaNoHang  "in" expr colonBody
        | "for"  symbol  "in" expr colonBody
;
expr: ifExpr 
     | sExpr
;
primary: identOrLiteral primary2
        | identOrLiteral
;
primary2: primarySuffix primary2 
         | primarySuffix
;
typeDesc: symbol 
         | inlTupleDecl 
         | arrayDecl
;
// typeDesc: symbol 
//          | enum 
//          | inlTupleDecl 
//          | arrayDecl
// ;
exprStmt: sExpr 
         | symbol "=" expr
         | symbol "+=" expr
         | symbol "*=" expr
;
// exprStmt: sExpr 
//          | varTuple "=" expr 
//          | symbol "+=" expr
//          | symbol "*=" expr
// ;
returnStmt: "return" expr 
           | "return"
;
breakStmt: "break"
;
continueStmt: "continue" 
;
condStmt: expr colonBody elifCondStmt %prec IFX
         | expr colonBody elifCondStmt INDEQ "else" colonBody 
         | expr colonBody %prec IFX
         | expr colonBody INDEQ "else" colonBody
;
elifCondStmt: elifCondStmt INDEQ "elif" expr colonBody
             | INDEQ "elif" expr colonBody
;
ifStmt: "if" condStmt
;
whileStmt: "while" expr colonBody
;
routine:  symbol paramListColon "=" stmt 
        | symbol paramListColon
;
// enum: "enum"  symbolCommaNoHang
//         | "enum" symbol
// ;
typeDef: symbol "="  typeDesc
;
// varTuple: "("  symbolCommaNoHang ")" "="  expr
//         | "("  symbol ")" "="  expr
// ;
colonBody: colon stmt
;
// variable: varTuple 
//          | declColon "=" expr 
//          | declColon
// ;
variable: declColon "=" expr 
         | declColon
;
secVariable: variable 
            | INDG variable serVariable DED
;
serVariable: INDEQ variable serVariable 
            | 
;
simpleStmt: returnStmt 
            | breakStmt 
            | continueStmt 
            | exprStmt
;
complexOrSimpleStmt: ifStmt 
                    | whileStmt 
                    | forStmt 
                    | "proc" routine 
                    | "type" typeDef 
                    | "var" secVariable 
                    | simpleStmt
;
stmt: INDG complexOrSimpleStmt stmt2 DED 
     | simpleStmt
;
stmt2: INDEQ complexOrSimpleStmt stmt2 
      | 
;

%%
/* End of grammar */


// input:   /* empty */
//         | input line
// ;

// line:
//           '\n'
//         | exp '\n'   { printf ("\t%lf\n", $1); }
//         | error '\n' { yyerrok;                  }
// ;

// exp:      NUM                { $$ = $1;}
//         | VAR                { $$ = $1->value.var;}
//         | VAR '=' exp        { $$ = $3; $1->value.var = $3;}
//         | FNCT '(' exp ')'   { $$ = (*(($1)->value.fptr))($3);}
//         | exp '+' exp        { $$ = $1 + $3;}
//         | exp '-' exp        { $$ = $1 - $3;}
//         | exp '*' exp        { $$ = $1 * $3;}
//         | exp '/' exp        { $$ = $1 / $3;}
//         | '-' exp  %prec NEG { $$ = -$2;}
//         | '(' exp ')'        { $$ = $2;}
// ;

// void init_table (){
//    symrec *ptr1, *ptr2;
//    ptr1 = putsym("sin", FNCT);
//    ptr1->value.fptr = sin;
//    ptr2 = putsym("cos", FNCT);
//    ptr2->value.fptr = cos;
// }

int main (){
   yyparse ();
}

void yyerror (char *s)  /* Called by yyparse on error */{
  printf ("%s\n", s);
}