/* 
    MiniNim: Parser (with Intermediate Code Generation)
    Reference: http://dinosaur.compilertools.net/bison/bison_5.html

*/

%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include <unistd.h>
#include <stdarg.h>
#include "backpatch.h"
#include "symrec.h"

/*Comment the line below to switch of the printing of Parser Debug information*/
#define PARSER_DEBUG
#ifdef PARSER_DEBUG
#define PRINTF(...) printf(__VA_ARGS__)
#endif
#ifndef PARSER_DEBUG
#define PRINTF(...)
#endif

/* Color codes, for print */
#define TO_RED "\033[1;31m"
#define TO_NORMAL "\033[0m"
#define TO_GREEN "\033[01;32m"
#define TO_YELLOW "\033[01;33m"

/* Globals and Functions Declarations */
int  yylex(void);
void yyerror (char *); 
FILE *yyin;

int curr_scope = 0;
char * final_IR;
symrec *sym_table = NULL;
bp_node* globaltruelist = NULL;
bp_node* globalfalselist = NULL;
bp_node* globalnextlist = NULL;
symrec* final_sym_table = NULL;

char* new_label();
char* new_temp();
char* new_bplabel();
char* sc(char *, char *);
char* scc(int ,...);
void dump_IR(char *);
char* putl(char * s){
    return sc(s,":\n");
}

bp_node* create_bp(char *);
bp_node* merge(bp_node *, bp_node *);
void backpatch(bp_node *, char *);
void print_list(bp_node *);
void open_scope();
void close_scope();
void puttemp(char*,var_type);
void print_symtab(symrec *);

char boolean[2][5] = {"0","1"};
%}

// type of yylval
%union {
    int integer; // For integers
    double floater; // For floats
    char *str; // For strings
    char ch; // For chars
    idorlit idl; // Defined in symrec.h (For Identifier or Literal)
    sdd s_tree; // Defined in symrec.h (For Non-terminals)
    arr_deref arrd; // Defined in symrec.h (For Array Dereferencing)
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

%token BREAK "break"
%token CONTINUE "continue"
%token ELIF "elif"
%token ELSE "else"
%token FOR "for"
%token IF "if"
%token IN "in"
%token VAR "var"
%token WHILE "while"
%token ECHOP "echo"
%token ARRAY "array"
%token RDINT "readInt"
%token RDFLT "readFloat"
%token NIL "nil"
%token PROC "proc"
%token RETURN "return"
%token TUPLE "tuple"
%token TYPE "type"

%nonassoc IFX
%nonassoc INDEQ

%token XOR "xor"
%token OR "or" 
%token AND "and"
%token NE "!=" 
%token GE ">=" 
%token LE "<=" 
%token EQ "==" 
%token SLICE ".." 
%token MOD "mod"
%token DIV "div"
%token NOT "not"
%token PEQ "+="
%token MEQ "*="

%left XOR 
%left OR 
%left AND 
%left NE 
%left '>' 
%left GE 
%left '<' 
%left LE 
%left EQ 
%left SLICE
%left '-'
%left '+' 
%left '%' 
%left MOD
%left DIV 
%left '/' 
%left '*' 
%right NOT
%right UPLUS
%right UMINUS
%nonassoc LPAREN
%locations

%debug

// Non-Terminals Types
%type <s_tree> module complexOrSimpleStmt module2 sExpr primary simpleStmt expr exprStmt ifStmt stmt colonBody stmt2 elifCondStmt whileStmt breakStmt continueStmt typeDesc secVariable variable forStmt arrayDecl serVariable echoexprList
%type <idl> symbol literal identOrLiteral
%type <arrd> arrayDeref

/* Grammar follows */
%%

module: complexOrSimpleStmt             {   
                                            char* label = new_label();
                                            backpatch($1.nextlist, label);
                                            globalnextlist = merge(globalnextlist, $1.nextlist);
                                            $$.code = scc(2, $1.code,putl(label));
                                            final_IR = $$.code;
                                        }
        | module2 INDEQ complexOrSimpleStmt {
                                            char *label1 = new_label();
                                            char *label2 = new_label();
                                            backpatch($1.nextlist, label1);
                                            backpatch($3.nextlist, label2);
                                            globalnextlist = merge(globalnextlist, $1.nextlist);
                                            globalnextlist = merge(globalnextlist, $3.nextlist);
                                            $$.code = scc(4, $1.code, putl(label1), $3.code, putl(label2)); 
                                            final_IR = $$.code;
                                        }
        |                               {   $$.code = ""; final_IR = $$.code;   }
;
module2: module2 INDEQ complexOrSimpleStmt {
                                            char* label = new_label();
                                            backpatch($1.nextlist, label);
                                            globalnextlist = merge(globalnextlist, $1.nextlist);
                                            $$.nextlist = $3.nextlist;
                                            $$.code = scc(3, $1.code,putl(label),$3.code);
                                        }
        | complexOrSimpleStmt           {
                                            $$.nextlist = $1.nextlist;
                                            $$.code = $1.code;
                                        }
;
comma: ','
;
colon: ':'
;
sExpr: sExpr "xor" sExpr        {
                                    if (($1.type == BOOL_TYPE) || ($3.type == BOOL_TYPE)){
                                        char *t = new_temp();
                                        puttemp(t,INT_TYPE);
                                        char *label = new_label();
                                        char *B1_truelabel = new_label();
                                        char *B1_falselabel = new_label();
                                        char *B2_truelabel = new_label();
                                        char *B2_falselabel = new_label();
                                        char *bptlabel = new_bplabel();
                                        char *bpflabel = new_bplabel();
                                        backpatch($1.falselist,B1_falselabel);
                                        backpatch($1.truelist,B1_truelabel);
                                        backpatch($3.falselist,B2_falselabel);
                                        backpatch($3.truelist,B2_truelabel);
                                        globaltruelist = merge(globaltruelist, $1.truelist);
                                        globaltruelist = merge(globaltruelist, $3.truelist);
                                        globalfalselist = merge(globalfalselist, $1.falselist);
                                        globalfalselist = merge(globalfalselist, $3.falselist);
                                        $$.type = BOOL_TYPE;
                                        $$.truelist = create_bp(bptlabel);
                                        $$.falselist = create_bp(bpflabel);
                                        $$.code = scc(31, t, " = 0\n", $1.code, putl(B1_truelabel), t, " = 1\ngoto c", label, "\n", putl(B1_falselabel), t, " = 0\n", putl(label), $3.code, putl(B2_truelabel), "if ", t, " goto ", bpflabel, "\n", "goto ", bptlabel, "\n", putl(B2_falselabel), "ifFalse ", t, " goto ", bpflabel, "\n", "goto ", bptlabel, "\n");
                                    } else if (($1.type == INT_TYPE) || ($3.type == INT_TYPE)){
                                        $$.truelist = NULL;
                                        $$.falselist = NULL;
                                        $$.addr = new_temp();
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                        $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, " ixor ", $3.addr,"\n");
                                    } else {
                                        printf(TO_RED);
                                        printf("Error: Operands not of boolean or int type for 'xor'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                }
        | sExpr "or" sExpr      {
                                    if (($1.type == BOOL_TYPE) || ($3.type == BOOL_TYPE)){
                                        char *label = new_label();
                                        backpatch($1.falselist,label);
                                        globalfalselist = merge(globalfalselist, $1.falselist);
                                        $$.truelist = merge($1.truelist,$3.truelist);
                                        $$.falselist = $3.falselist;
                                        $$.type = BOOL_TYPE;
                                        $$.code = scc(3,$1.code, putl(label), $3.code);
                                    } else if (($1.type == INT_TYPE) || ($3.type == INT_TYPE)) {
                                        $$.truelist = NULL;
                                        $$.falselist = NULL;
                                        $$.addr = new_temp();
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                        $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, " ior ", $3.addr,"\n");
                                    } else {
                                        printf(TO_RED);
                                        printf("Error: Operands not of boolean or int type for 'or'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                }
        | sExpr "and" sExpr     {
                                    if (($1.type == BOOL_TYPE) || ($3.type == BOOL_TYPE)){
                                    char *label = new_label();
                                    backpatch($1.truelist,label);
                                    globaltruelist = merge(globaltruelist, $1.truelist);
                                    $$.falselist = merge($1.falselist,$3.falselist);
                                    $$.truelist = $3.truelist;
                                    $$.type = BOOL_TYPE;
                                    $$.code = scc(3,$1.code, putl(label), $3.code);
                                    } else if (($1.type == INT_TYPE) || ($3.type == INT_TYPE)){
                                        $$.truelist = NULL;
                                        $$.falselist = NULL;
                                        $$.addr = new_temp();
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                        $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, " iand ", $3.addr,"\n");
                                    } else {
                                        printf(TO_RED);
                                        printf("Error: Operands not of boolean or int type for 'and'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                }
        | sExpr "!=" sExpr      {
                                    char *bplabel1 = new_bplabel();
                                    char *bplabel2 = new_bplabel();
                                    $$.truelist = create_bp(bplabel1);
                                    $$.falselist = create_bp(bplabel2);
                                    $$.type = BOOL_TYPE;
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " ne ";
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " nef ";
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " fne ";
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " fnef ";
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '!='\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr , $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                                }
        | sExpr '>' sExpr       {
                                    char *bplabel1 = new_bplabel();
                                    char *bplabel2 = new_bplabel();
                                    $$.truelist = create_bp(bplabel1);
                                    $$.falselist = create_bp(bplabel2);
                                    $$.type = BOOL_TYPE;
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " lt ";
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " flt ";
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " ltf ";
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " fltf ";
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '>'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(11, $1.code, $3.code, "if ", $3.addr, opr, $1.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                                }
        | sExpr ">=" sExpr      {
                                    char *bplabel1 = new_bplabel();
                                    char *bplabel2 = new_bplabel();
                                    $$.truelist = create_bp(bplabel1);
                                    $$.falselist = create_bp(bplabel2);
                                    $$.type = BOOL_TYPE;
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " le ";
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " fle ";
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " lef ";
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " flef ";
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '>='\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(11, $1.code, $3.code, "if ", $3.addr, opr, $1.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                                }
        | sExpr '<' sExpr       {
                                    char *bplabel1 = new_bplabel();
                                    char *bplabel2 = new_bplabel();
                                    $$.truelist = create_bp(bplabel1);
                                    $$.falselist = create_bp(bplabel2);
                                    $$.type = BOOL_TYPE;
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " lt ";
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " ltf ";
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " flt ";
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " fltf ";
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '<'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr, $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                                }
        | sExpr "<=" sExpr      {
                                    char *bplabel1 = new_bplabel();
                                    char *bplabel2 = new_bplabel();
                                    $$.truelist = create_bp(bplabel1);
                                    $$.falselist = create_bp(bplabel2);
                                    $$.type = BOOL_TYPE;
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " le ";
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " lef ";
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " fle ";
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " flef ";
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '<='\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr, $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                                }
        | sExpr "==" sExpr      {
                                    char *bplabel1 = new_bplabel();
                                    char *bplabel2 = new_bplabel();
                                    $$.truelist = create_bp(bplabel1);
                                    $$.falselist = create_bp(bplabel2);
                                    $$.type = BOOL_TYPE;
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " eq ";
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " eqf ";
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " feq ";
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " feqf ";
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '=='\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr, $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                                }
        | sExpr '-' sExpr       {
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;
                                    $$.addr = new_temp(); 
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " - ";
                                        $$.type = INT_TYPE;
                                        puttemp($$.addr, INT_TYPE);
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " -f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f- ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f-f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '-'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(8 , $1.code, $3.code, $$.addr," = ", $1.addr, opr , $3.addr, "\n");
                                }
        | sExpr '+' sExpr       {
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;
                                    $$.addr = new_temp();
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " + ";
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " +f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f+ ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f+f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '+'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    } 
                                    $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr, $3.addr,"\n");
                                }
        | sExpr "mod" sExpr     {
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;
                                    $$.addr = new_temp(); 
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " mod ";
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for 'mod'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    } 
                                    $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr , $3.addr,"\n");
                                }
        | sExpr "div" sExpr     {
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;
                                    $$.addr = new_temp(); 
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " idiv ";
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for 'div'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    } 
                                    $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr , $3.addr,"\n");
                                }
        | sExpr '/' sExpr       {
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;
                                    $$.addr = new_temp();
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " / ";
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " /f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f/ ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f/f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '/'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr, $3.addr,"\n");
                                }
        | sExpr '*' sExpr       {
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;   
                                    $$.addr = new_temp();
                                    char *opr;
                                    if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                        opr = " * ";
                                        puttemp($$.addr, INT_TYPE);
                                        $$.type = INT_TYPE;
                                    } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                        opr = " *f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f* ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                        opr = " f*f ";
                                        puttemp($$.addr, FLOAT_TYPE);
                                        $$.type = FLOAT_TYPE;
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for '*'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr, $3.addr,"\n");
                                }
        | '+' sExpr %prec UPLUS {
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;
                                    $$.code = $2.code;
                                    $$.addr = $2.addr;
                                    $$.type = $2.type;
                                    if ($2.type != INT_TYPE && $2.type != FLOAT_TYPE){
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for unary '+'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                }
        | '-' sExpr %prec UMINUS{
                                    $$.truelist = NULL;
                                    $$.falselist = NULL;
                                    $$.addr = new_temp(); 
                                    $$.type = $2.type;
                                    char *opr;
                                    if ($2.type == INT_TYPE){
                                        puttemp($$.addr, INT_TYPE);
                                        opr = "- ";
                                    } else if($2.type == FLOAT_TYPE){
                                        puttemp($$.addr, FLOAT_TYPE);
                                        opr = "-f ";
                                    } else{
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for unary '-'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = scc(6, $2.code, $$.addr," = ", opr, $2.addr, "\n");
                                }
        | "not" sExpr           {
                                    $$.falselist = $$.truelist;
                                    $$.truelist = $$.falselist;
                                    if ($2.type != BOOL_TYPE){
                                        printf(TO_RED);
                                        printf("Error: Operands not of suitable type for 'not'\n");
                                        printf(TO_NORMAL);
                                        exit(EXIT_FAILURE);
                                    }
                                    $$.code = $2.code;
                                    $$.type = $2.type;
                                }
         | '(' sExpr ')' %prec LPAREN {
                                    $$.truelist = $2.truelist;
                                    $$.falselist = $2.falselist;
                                    $$.code = $2.code;
                                    $$.addr = $2.addr;
                                    $$.type = $2.type;
                                }
        | primary               {
                                    $$.truelist = $1.truelist;
                                    $$.falselist = $1.falselist;
                                    $$.code = $1.code; 
                                    $$.addr = $1.addr;
                                    $$.type = $1.type;
                                }
;
symbol: IDENT                   {
                                    $$.value.name = $1;
                                    $$.is_ident=1;
                                }
;

echoexprList: echoexprList comma expr {
                                        char * opr;
                                        if($3.type == INT_TYPE){
                                            opr = "iprint ";
                                        } else if ($3.type == FLOAT_TYPE){
                                            opr = "fprint ";
                                        } else if ($3.type == STR_TYPE){
                                            opr = "sprint ";
                                        } else {
                                            printf(TO_RED);
                                            printf("Error: Invalid type for 'echo'\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }
                                        $$.nextlist = NULL; $$.breaklist = NULL;
                                        $$.continuelist = NULL;
                                        $$.code = scc(5,$1.code,$3.code, opr ,$3.addr,"\n");
                                    }
        | expr                      {
                                        char * opr;
                                        if($1.type == INT_TYPE){
                                            opr = "iprint ";
                                        } else if ($1.type == FLOAT_TYPE){
                                            opr = "fprint ";
                                        } else if ($1.type == STR_TYPE){
                                            opr = "sprint ";
                                        } else {
                                            printf(TO_RED);
                                            printf("Error: Invalid type for 'echo'\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }
                                        $$.nextlist = NULL; $$.breaklist = NULL;
                                        $$.continuelist = NULL;
                                        $$.code = scc(4,$1.code, opr ,$1.addr,"\n");
                                    }
;
literal: BOOLLIT    {
                        $$.value.bval = $1; 
                        $$.type = BOOL_TYPE;$$.is_ident=0;
                    }
        | INTLIT    {
                        $$.value.ival = $1; 
                        $$.type = INT_TYPE;
                        $$.is_ident=0;
                    }
        | FLOATLIT  {
                        $$.value.fval = $1; 
                        $$.type = FLOAT_TYPE;
                        $$.is_ident=0;
                    }
        | STRLIT    {
                        $$.value.sval = $1;
                        $$.type = STR_TYPE;
                        $$.is_ident=0;
                    }
        | CHARLIT   {   
                        $$.value.cval = $1; 
                        $$.type = CHAR_TYPE;
                        $$.is_ident=0;
                    }
        | "nil"     {$$.is_ident=0;} // This feature is not yet included 
;
identOrLiteral: symbol      {
                                $$.value.name = $1.value.name; 
                                $$.is_ident = 1;
                            }
                | literal   {
                                $$.aux_type = BASIC_TYPE;
                                if($1.type==INT_TYPE){$$.value.ival=$1.value.ival;} 
                                else if($1.type==FLOAT_TYPE){$$.value.fval=$1.value.fval;} 
                                else if($1.type==CHAR_TYPE){$$.value.cval=$1.value.cval;} 
                                else if($1.type==STR_TYPE){$$.value.sval=$1.value.sval;} 
                                else if($1.type==INT_TYPE){$$.value.bval=$1.value.bval;} 
                                $$.type = $1.type; $$.is_ident=0;
                            }
;
arrayDecl: "array" '['  INTLIT comma typeDesc ']'   {     
                                                        if ($5.aux_type == BASIC_TYPE){
                                                            $$.arr_depth = 1;
                                                            $$.arr_data[0] = $3;
                                                        } else {
                                                            $$.arr_depth = $5.arr_depth+1;
                                                            for(int i = 1;i <= $5.arr_depth;i++) $$.arr_data[i] = $5.arr_data[i-1];
                                                            $$.arr_data[0] = $3;
                                                        }
                                                        $$.type = $5.type;
                                                        $$.aux_type = ARRAY_TYPE;
                                                    }
;
forStmt: "for"  symbol  "in" expr ".." expr {open_scope();putsym($2.value.name,INT_TYPE);} colonBody 
                                                    {
                                                        char* label = new_label();
                                                        char* label2 = new_label();
                                                        char* bplabel = new_bplabel();
                                                        symrec* sym = getsym($2.value.name);
                                                        char* sa = sym->alias;
                                                        backpatch($8.nextlist, label2);
                                                        backpatch($8.continuelist, label2);
                                                        globalnextlist = merge(globalnextlist, $8.nextlist);
                                                        globalnextlist = merge(globalnextlist, $8.continuelist);
                                                        $$.nextlist = merge($8.breaklist, create_bp(bplabel));
                                                        $$.breaklist = NULL;
                                                        $$.continuelist = NULL;
                                                        /*
                                                            expr1.code
                                                            expr2.code
                                                            sym->alias = expr1.addr
                                                            label1:
                                                            if expr2 < sym->alias goto bp_label
                                                            bodycode
                                                            sym->alias = sym->alias + _incr
                                                            goto label1
                                                        */
                                                        $$.code = scc(23, $4.code, $6.code, sa, " = ", $4.addr,"\n", putl(label), "if ", $6.addr, " lt ", sa, " goto ",bplabel, "\n", $8.code, putl(label2), sa, " = ",sa," + ","_incr\ngoto ",label,"\n");
                                                        close_scope();
                                                    }
;
expr: sExpr     {
                    $$.code = $1.code; 
                    $$.addr = $1.addr;
                    $$.type = $1.type;
                    $$.truelist = $1.truelist;
                    $$.falselist = $1.falselist;
                }
;
arrayDeref: arrayDeref '[' expr ']' {
                                        if ($3.type != INT_TYPE) {
                                            printf(TO_RED);
                                            printf("Error: Array index should be of type 'int'\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }
                                        $$.arr_depth = $1.arr_depth + 1;
                                        for (int i=0;i < $1.arr_depth; i++) $$.arr_data[i] = $1.arr_data[i];
                                        $$.arr_data[$1.arr_depth] = $3.addr;
                                        $$.code = scc(2,$1.code, $3.code);
                                    }
            |'[' expr ']'           {
                                        if ($2.type != INT_TYPE) {
                                            printf(TO_RED);
                                            printf("Error: Array index should be of type 'int'\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }
                                        $$.arr_depth = 1;
                                        $$.arr_data[0] = $2.addr; 
                                        $$.code = $2.code;
                                    }
;
primary: identOrLiteral             {
                                        $$.addr = new_temp();
                                        $$.truelist = NULL;
                                        $$.falselist = NULL; 
                                        if($1.is_ident){
                                            symrec* symb = getsym($1.value.name);
                                            puttemp($$.addr,symb->type);
                                            $$.type = symb->type;
                                            char *opr;
                                            if (symb->type == INT_TYPE){
                                                opr = " = ";
                                            } else if(symb->type == FLOAT_TYPE){
                                                opr = " f= ";
                                            } else {
                                                printf(TO_RED);
                                                printf("Error: Symbols type not currently supported in expression\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);
                                            }
                                            $$.code = scc(4, $$.addr, opr, symb->alias, "\n");
                                        } 
                                        else if($1.type==INT_TYPE){
                                            puttemp($$.addr,INT_TYPE);
                                            $$.type = INT_TYPE;
                                            char *int_str = (char *)malloc(50 * sizeof(char));
                                            sprintf(int_str,"%d",$1.value.ival);
                                            $$.code = scc(4, $$.addr, " = ", int_str, "\n");
                                        }
                                        else if($1.type==FLOAT_TYPE){
                                            puttemp($$.addr,FLOAT_TYPE);
                                            $$.type = FLOAT_TYPE;
                                            char *float_str = (char *)malloc(50 * sizeof(char));
                                            sprintf(float_str,"%lf",$1.value.fval);
                                            $$.code = scc(4, $$.addr, " f=f ", float_str,"\n");
                                        }
                                        else if($1.type==STR_TYPE){
                                            puttemp($$.addr,STR_TYPE);
                                            sym_table->width = strlen($1.value.sval)+1 - 2; // It will always be the top entry
                                            $$.type = STR_TYPE;
                                            $$.code = scc(4, $$.addr, " s=s ", $1.value.sval, "\n");
                                        }
                                        else if($1.type==CHAR_TYPE){
                                            puttemp($$.addr,CHAR_TYPE);
                                            $$.type = CHAR_TYPE;
                                            char *char_str = (char *)malloc(3 * sizeof(char));
                                            sprintf(char_str,"%c",$1.value.cval);
                                            $$.code = scc(4, $$.addr, " = ", char_str, "\n");
                                        }
                                        else if($1.type==BOOL_TYPE){
                                            puttemp($$.addr,BOOL_TYPE);
                                            $$.type = BOOL_TYPE;
                                            char* bplabel = new_bplabel();
                                            if ($1.value.bval==1){
                                                $$.truelist = create_bp(bplabel);
                                            }
                                            else{
                                                $$.falselist = create_bp(bplabel);
                                            }
                                            $$.code = scc(7, "goto ", bplabel, "\n", $$.addr, " = ", boolean[$1.value.bval], "\n");
                                        }
                                    }
        | identOrLiteral arrayDeref {
                                        $$.addr = new_temp();
                                        $$.truelist = NULL;
                                        $$.falselist = NULL;
                                        if($1.is_ident){
                                            symrec * symb = getsym($1.value.name);
                                            if (symb->aux_type != ARRAY_TYPE){
                                                printf(TO_RED);
                                                printf("Error: Cannot dereference something which is not an array\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);    
                                            } else if (symb->arr_depth != $2.arr_depth){
                                                printf(TO_RED);
                                                printf("Error: Array not fully dereferenced\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);   
                                            } else {
                                                puttemp($$.addr,symb->type);
                                                $$.type = symb->type;
                                                int type_width;
                                                if (symb->type == FLOAT_TYPE){
                                                    type_width = 8;
                                                } else {
                                                    type_width = 4;
                                                }
                                                int type_widths[10];
                                                type_widths[$2.arr_depth-1] = type_width;
                                                char type_widths_str[10][10];
                                                sprintf(type_widths_str[$2.arr_depth-1], "%d", type_widths[$2.arr_depth-1]);
                                                for(int i=$2.arr_depth-2;i>=0;i--){
                                                    type_widths[i] = type_widths[i+1]*symb->arr_data[i+1];
                                                    sprintf(type_widths_str[i], "%d", type_widths[i]);
                                                }
                                                char* ind = new_temp();
                                                $$.code = scc(3, $2.code, ind," = 0\n");
                                                puttemp(ind, INT_TYPE);
                                                for(int i=0; i<$2.arr_depth; i++){
                                                    char* temp1 = new_temp();
                                                    char* temp2 = new_temp();
                                                    puttemp(temp1,INT_TYPE);
                                                    puttemp(temp2,INT_TYPE);
                                                    $$.code = scc(17, $$.code, temp1, " = ", type_widths_str[i], "\n", temp2, " = ", temp1, " * ", $2.arr_data[i],"\n", ind, " = ", ind, " + ", temp2,"\n");
                                                }
                                                char * opr;
                                                if(symb->type == INT_TYPE){
                                                    opr = " = ";
                                                } else if (symb->type == FLOAT_TYPE){
                                                    opr = " f= ";
                                                }
                                                $$.code = scc(7, $$.code, $$.addr,opr,symb->alias,"[", ind, "]\n");
                                            }
                                        }
                                        else {
                                            printf(TO_RED);
                                            printf("Error: Dereferencing literal not of 'array' type\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }
                                    }
;
typeDesc: symbol            {  
                                $$.aux_type = BASIC_TYPE;
                                if(strcmp($1.value.name, "int")==0){
                                    $$.type = INT_TYPE;
                                } else if (strcmp($1.value.name, "float")==0){
                                    $$.type = FLOAT_TYPE;
                                } else {
                                    printf(TO_RED);
                                    printf("Error: Unknown type assigned to variable\n");
                                    printf(TO_NORMAL);
                                    exit(EXIT_FAILURE);
                                }
                            } 
        | arrayDecl         {
                                $$.aux_type = ARRAY_TYPE;
                                $$.type = $1.type;
                                $$.arr_depth = $1.arr_depth;
                                for(int i=0;i<$1.arr_depth;i++) $$.arr_data[i] = $1.arr_data[i];
                            }
;
exprStmt: symbol '=' expr           {
                                        char* opr;
                                        symrec * symb = getsym($1.value.name);
                                        if ($3.type == INT_TYPE && symb->type == FLOAT_TYPE){
                                            opr = " =f ";
                                        } else if ($3.type == INT_TYPE && symb->type == INT_TYPE){
                                            opr = " = ";
                                        } else if (symb->type == FLOAT_TYPE && $3.type == FLOAT_TYPE){
                                            opr = " f= ";
                                        }
                                        else {
                                            printf(TO_RED);
                                            printf("Error: Incompatible type assigned to variable.\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }
                                        $$.code = scc(5, $3.code, symb->alias, opr, $3.addr, "\n"); 
                                        $$.nextlist = NULL;
                                    }
        | symbol arrayDeref '=' expr{   
                                        $$.truelist = NULL;
                                        $$.falselist = NULL;
                                        if($1.is_ident){
                                            symrec * symb = getsym($1.value.name);
                                            if (symb->aux_type != ARRAY_TYPE){
                                                printf(TO_RED);
                                                printf("Error: Cannot dereference something which is not an array\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);    
                                            } else if (symb->arr_depth != $2.arr_depth){
                                                printf(TO_RED);
                                                printf("Error: Array not fully dereferenced\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);   
                                            } else {
                                                int type_width;
                                                if (symb->type == FLOAT_TYPE){
                                                    type_width = 8;
                                                } else {
                                                    type_width = 4;
                                                }
                                                int type_widths[10];
                                                type_widths[$2.arr_depth-1] = type_width;
                                                char type_widths_str[10][10];
                                                sprintf(type_widths_str[$2.arr_depth-1], "%d", type_widths[$2.arr_depth-1]);
                                                for(int i=$2.arr_depth-2;i>=0;i--){
                                                    type_widths[i] = type_widths[i+1]*symb->arr_data[i+1];
                                                    sprintf(type_widths_str[i], "%d", type_widths[i]);
                                                }
                                                char* ind = new_temp();
                                                $$.code = scc(3, $2.code, ind," = 0\n");
                                                puttemp(ind, INT_TYPE);
                                                for(int i=0; i<$2.arr_depth; i++){
                                                    char* temp1 = new_temp();
                                                    char* temp2 = new_temp();
                                                    puttemp(temp1,INT_TYPE);
                                                    puttemp(temp2,INT_TYPE);
                                                    $$.code = scc(17, $$.code, temp1, " = ", type_widths_str[i], "\n", temp2, " = ", temp1, " * ", $2.arr_data[i],"\n", ind, " = ", ind, " + ", temp2,"\n");
                                                }
                                                char* opr;
                                                if ($4.type == INT_TYPE && symb->type == FLOAT_TYPE){
                                                    opr = " =f ";
                                                } else if ($4.type == INT_TYPE && symb->type == INT_TYPE){
                                                    opr = " = ";
                                                } else if (symb->type == FLOAT_TYPE && $4.type == FLOAT_TYPE){
                                                    opr = " f= ";
                                                }
                                                else {
                                                    printf(TO_RED);
                                                    printf("Error: Incompatible Type assigned to variable.\n");
                                                    printf(TO_NORMAL);
                                                    exit(EXIT_FAILURE);
                                                }
                                                $$.code = scc(9,$$.code,$4.code, symb->alias,"[", ind, "]", opr, $4.addr, "\n"); 
                                                $$.nextlist = NULL;
                                            }
                                        }
                                        else {
                                            printf(TO_RED);
                                            printf("Error: Dereferencing literal not of 'array' type\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }    
                                    }
        | symbol "+=" expr          {} // Feature yet to be added
        | symbol "*=" expr          {} // Feature yet to be added
;
breakStmt: "break"          {
                                char *bplabel = new_bplabel();
                                $$.breaklist = create_bp(bplabel);
                                $$.nextlist = NULL;
                                $$.continuelist = NULL;
                                $$.code = scc(3,"goto ", bplabel, "\n");
                            }
;
continueStmt: "continue"    {
                                char *bplabel = new_bplabel();
                                $$.breaklist = NULL;
                                $$.nextlist = NULL;
                                $$.continuelist = create_bp(bplabel);
                                $$.code = scc(3,"goto ", bplabel, "\n");
                            }
;
ifStmt: "if" expr colonBody elifCondStmt %prec IFX  {
                                                        char *label1 = new_label();
                                                        char *label2 = new_label();
                                                        char *bplabel = new_bplabel();
                                                        backpatch($2.truelist, label1);
                                                        backpatch($2.falselist, label2);
                                                        globalfalselist = merge(globalfalselist, $2.falselist);
                                                        globaltruelist = merge(globaltruelist, $2.truelist);
                                                        $$.nextlist = merge(create_bp(bplabel) ,merge($3.nextlist, merge($4.nextlist,$4.falselist)));
                                                        $$.breaklist = merge($3.breaklist,$4.breaklist);
                                                        $$.continuelist = merge($3.continuelist,$4.continuelist);
                                                        $$.code = scc(8, $2.code, putl(label1), $3.code, "goto ", bplabel, "\n", putl(label2), $4.code);
                                                    }
         |"if" expr colonBody elifCondStmt "else" colonBody {
                                                        char *label1 = new_label();
                                                        char *label2 = new_label();
                                                        char *label3 = new_label();
                                                        char *bplabel = new_bplabel();
                                                        backpatch($2.truelist, label1);
                                                        backpatch($2.falselist, label2);
                                                        backpatch($4.falselist, label3);
                                                        globalfalselist = merge(globalfalselist, merge($2.falselist, $4.falselist));
                                                        globaltruelist = merge(globaltruelist, $2.truelist);
                                                        $$.nextlist = merge(create_bp(bplabel), merge($3.nextlist, merge($4.nextlist, $6.nextlist)));
                                                        $$.breaklist = merge($3.breaklist,merge($4.breaklist,$6.breaklist));
                                                        $$.continuelist = merge($3.continuelist,merge($4.continuelist,$6.continuelist));
                                                        $$.code = scc(13, $2.code, putl(label1), $3.code, "goto ", bplabel, "\n", putl(label2), $4.code, "goto ", bplabel,"\n", putl(label3), $6.code);
                                                    }
         | "if" expr colonBody %prec IFX            {
                                                        char *label = new_label();
                                                        backpatch($2.truelist, label);
                                                        globaltruelist = merge(globaltruelist, $2.truelist);
                                                        $$.nextlist = merge($2.falselist, $3.nextlist);
                                                        $$.breaklist = $3.breaklist;
                                                        $$.continuelist = $3.continuelist;
                                                        $$.code = scc(3, $2.code, putl(label), $3.code);
                                                    }
         | "if" expr colonBody "else" colonBody     {
                                                        char *label1 = new_label();
                                                        char *label2 = new_label();
                                                        char *bplabel = new_bplabel();
                                                        backpatch($2.truelist, label1);
                                                        backpatch($2.falselist, label2);
                                                        globalfalselist = merge(globalfalselist, $2.falselist);
                                                        globaltruelist = merge(globaltruelist, $2.truelist);
                                                        $$.nextlist = merge(create_bp(bplabel) ,merge($3.nextlist, $5.nextlist));
                                                        $$.breaklist = merge($3.breaklist,$5.breaklist);
                                                        $$.continuelist = merge($3.continuelist,$5.continuelist);
                                                        $$.code = scc(8, $2.code, putl(label1), $3.code, "goto ", bplabel, "\n", putl(label2), $5.code);
                                                    }
;
elifCondStmt: elifCondStmt "elif" expr colonBody    {
                                                        char *label1 = new_label();
                                                        char *label2 = new_label();
                                                        char *bplabel = new_bplabel();
                                                        backpatch($1.falselist, label1);
                                                        backpatch($3.truelist, label2);
                                                        globalfalselist = merge(globalfalselist, $1.falselist);
                                                        globaltruelist = merge(globaltruelist, $3.truelist);
                                                        $$.falselist = $3.falselist;
                                                        $$.nextlist = merge(create_bp(bplabel), merge($1.nextlist, $4.nextlist));
                                                        $$.breaklist = merge($1.breaklist,$4.breaklist);
                                                        $$.continuelist = merge($1.continuelist,$4.continuelist);
                                                        $$.code = scc(8, $1.code, "goto ", bplabel, "\n", putl(label1), $3.code, putl(label2), $4.code);
                                                    }
             | "elif" expr colonBody                {
                                                        char *label1 = new_label();
                                                        backpatch($2.truelist, label1);
                                                        globaltruelist = merge(globaltruelist, $2.truelist);
                                                        $$.falselist = $2.falselist;
                                                        $$.nextlist = $3.nextlist;
                                                        $$.breaklist = $3.breaklist;
                                                        $$.continuelist = $3.continuelist;
                                                        $$.code = scc(3, $2.code, putl(label1), $3.code);
                                                    }
;
whileStmt: "while" expr colonBody   {
                                        char* label1 = new_label();
                                        char* label2 = new_label();
                                        backpatch($3.nextlist, label1);
                                        backpatch($3.continuelist, label1);
                                        backpatch($2.truelist, label2);
                                        globalnextlist = merge(globalnextlist,$3.nextlist);
                                        globalnextlist = merge(globalnextlist, $3.continuelist);
                                        globaltruelist = merge(globaltruelist, $2.truelist);
                                        $$.nextlist = merge($2.falselist,$3.breaklist);
                                        $$.breaklist = NULL;
                                        $$.continuelist = NULL;
                                        $$.code = scc(7,putl(label1),$2.code,putl(label2),$3.code,"goto ",label1,"\n");
                                    }
;
colonBody: colon {open_scope();} stmt {close_scope();$$.code = $3.code; $$.nextlist = $3.nextlist; $$.breaklist = $3.breaklist;$$.continuelist = $3.continuelist;}
;
variable: symbol ':'  typeDesc '=' expr {
                                            if ($3.aux_type == BASIC_TYPE) {
                                            $$.nextlist = NULL; $$.breaklist = NULL;
                                            $$.continuelist = NULL;
                                            putsym($1.value.name,$3.type);
                                            symrec * symb = getsym($1.value.name);
                                            char * opr;
                                            if ($5.type == INT_TYPE && symb->type == FLOAT_TYPE){
                                                opr = " =f ";
                                            } else if ($5.type == INT_TYPE && symb->type == INT_TYPE){
                                                opr = " = ";
                                            } else if (symb->type == FLOAT_TYPE && $5.type == FLOAT_TYPE){
                                                opr = " f= ";
                                            }
                                            else {
                                                printf(TO_RED);
                                                printf("Error: Incompatible Type assigned to variable.\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);
                                            }
                                            $$.code = scc(5, $5.code, symb->alias, opr, $5.addr,"\n");
                                            }else{
                                                printf(TO_RED);
                                                printf("Error: Assignment to expression with 'array' type.\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);
                                            }
                                        }
        | symbol ':'  typeDesc          {
                                            if($3.aux_type == BASIC_TYPE){
                                                putsym($1.value.name,$3.type);
                                                $$.nextlist = NULL; $$.breaklist = NULL; 
                                                $$.continuelist = NULL;
                                                $$.code = "";
                                            }
                                            else{
                                                putsym($1.value.name, $3.type);
                                                symrec *symb = getsym($1.value.name);
                                                symb->aux_type = ARRAY_TYPE;
                                                symb->arr_depth = $3.arr_depth;
                                                for (int i=0; i<$3.arr_depth; i++) symb->arr_data[i] = $3.arr_data[i];
                                                $$.nextlist = NULL; $$.breaklist = NULL; 
                                                $$.continuelist = NULL;
                                                $$.code = "";
                                            }
                                        }
;
secVariable: variable                       {
                                                $$.code = $1.code; 
                                                $$.nextlist=NULL; 
                                                $$.breaklist = NULL; 
                                                $$.continuelist = NULL;
                                            }
            | INDG variable serVariable DED { 
                                                $$.code = scc(2,$2.code,$3.code);
                                                $$.nextlist = NULL; 
                                                $$.breaklist = NULL; 
                                                $$.continuelist = NULL;
                                            }
;
serVariable: serVariable INDEQ variable     {
                                                $$.code = scc(2,$1.code, $3.code);
                                                $$.nextlist = NULL; 
                                                $$.breaklist = NULL;
                                                $$.continuelist = NULL;
                                            }
            |                               {
                                                $$.code = ""; 
                                                $$.nextlist = NULL; 
                                                $$.breaklist = NULL;
                                                $$.continuelist = NULL;
                                            }
;
simpleStmt: breakStmt           {
                                    $$.nextlist = $1.nextlist;
                                    $$.breaklist = $1.breaklist;
                                    $$.continuelist = $1.continuelist;
                                    $$.code = $1.code;
                                }
            | continueStmt      {
                                    $$.nextlist = $1.nextlist;
                                    $$.breaklist = $1.breaklist;
                                    $$.continuelist = $1.continuelist;
                                    $$.code = $1.code;
                                } 
            | exprStmt          {
                                    $$.code = $1.code; 
                                    $$.nextlist = NULL; 
                                    $$.breaklist = NULL;
                                    $$.continuelist = NULL;
                                }
;
complexOrSimpleStmt: ifStmt                     {
                                                    $$.code = $1.code; 
                                                    $$.nextlist = $1.nextlist; 
                                                    $$.breaklist = $1.breaklist;
                                                    $$.continuelist = $1.continuelist;
                                                }
                    | whileStmt                 {
                                                    $$.code = $1.code; 
                                                    $$.nextlist = $1.nextlist; 
                                                    $$.breaklist = $1.breaklist;
                                                    $$.continuelist = $1.continuelist;
                                                }
                    | forStmt 
                    | "echo" echoexprList       {
                                                    $$.code = scc(2,$2.code,"printnl\n");
                                                    $$.nextlist = NULL; $$.breaklist = NULL;
                                                    $$.continuelist = NULL;
                                                }
                    | "var" secVariable         {
                                                    $$.code = $2.code; 
                                                    $$.nextlist = $2.nextlist; 
                                                    $$.breaklist = $2.breaklist;
                                                    $$.continuelist = $2.continuelist;
                                                }
                    | "readInt" symbol          {
                                                    symrec * symb = getsym($2.value.name);
                                                    if (symb->type != INT_TYPE){
                                                        printf(TO_RED);
                                                        printf("Error: Invalid type for 'readInt'\n");
                                                        printf(TO_NORMAL);
                                                        exit(EXIT_FAILURE);
                                                    }
                                                    $$.nextlist = NULL; $$.breaklist = NULL;
                                                    $$.continuelist = NULL;
                                                    $$.code  = scc(3,"iread ",symb->alias,"\n");
                                                }
                    | "readInt" symbol arrayDeref
                                                {
                                                    symrec * symb = getsym($2.value.name);
                                                    if (symb->aux_type != ARRAY_TYPE){
                                                        printf(TO_RED);
                                                        printf("Error: Cannot dereference something which is not an array\n");
                                                        printf(TO_NORMAL);
                                                        exit(EXIT_FAILURE);    
                                                    } else if (symb->arr_depth != $3.arr_depth){
                                                        printf(TO_RED);
                                                        printf("Error: Array not fully dereferenced\n");
                                                        printf(TO_NORMAL);
                                                        exit(EXIT_FAILURE);   
                                                    } else {
                                                        int type_width;
                                                        if (symb->type == FLOAT_TYPE){
                                                            type_width = 8;
                                                        } else {
                                                            type_width = 4;
                                                        }
                                                        int type_widths[10];
                                                        type_widths[$3.arr_depth-1] = type_width;
                                                        char type_widths_str[10][10];
                                                        sprintf(type_widths_str[$3.arr_depth-1], "%d", type_widths[$3.arr_depth-1]);
                                                        for(int i=$3.arr_depth-2;i>=0;i--){
                                                            type_widths[i] = type_widths[i+1]*symb->arr_data[i+1];
                                                            sprintf(type_widths_str[i], "%d", type_widths[i]);
                                                        }
                                                        char* ind = new_temp();
                                                        $$.code = scc(3, $3.code, ind," = 0\n");
                                                        puttemp(ind, INT_TYPE);
                                                        for(int i=0; i<$3.arr_depth; i++){
                                                            char* temp1 = new_temp();
                                                            char* temp2 = new_temp();
                                                            puttemp(temp1,INT_TYPE);
                                                            puttemp(temp2,INT_TYPE);
                                                            $$.code = scc(17, $$.code, temp1, " = ", type_widths_str[i], "\n", temp2, " = ", temp1, " * ", $3.arr_data[i],"\n", ind, " = ", ind, " + ", temp2,"\n");
                                                        }
                                                        if (symb->type != INT_TYPE){
                                                            printf(TO_RED);
                                                            printf("Error: Invalid type for 'readInt'\n");
                                                            printf(TO_NORMAL);
                                                            exit(EXIT_FAILURE);
                                                        }
                                                        $$.nextlist = NULL; $$.breaklist = NULL;
                                                        $$.continuelist = NULL;
                                                        $$.code  = scc(6,$$.code,"iread ",symb->alias,"[", ind, "]\n");
                                                    }
                                                    
                                                }
                    | "readFloat" symbol        {
                                                    symrec * symb = getsym($2.value.name);
                                                    if (symb->type != FLOAT_TYPE){
                                                        printf(TO_RED);
                                                        printf("Error: Invalid type for 'readFloat'\n");
                                                        printf(TO_NORMAL);
                                                        exit(EXIT_FAILURE);
                                                    }
                                                    $$.nextlist = NULL; $$.breaklist = NULL;
                                                    $$.continuelist = NULL;
                                                    $$.code  = scc(3,"fread ",symb->alias,"\n");
                                                }
                    | "readFloat" symbol arrayDeref 
                                                {
                                                    symrec * symb = getsym($2.value.name);
                                                    if (symb->aux_type != ARRAY_TYPE){
                                                        printf(TO_RED);
                                                        printf("Error: Cannot dereference something which is not an array\n");
                                                        printf(TO_NORMAL);
                                                        exit(EXIT_FAILURE);    
                                                    } else if (symb->arr_depth != $3.arr_depth){
                                                        printf(TO_RED);
                                                        printf("Error: Array not fully dereferenced\n");
                                                        printf(TO_NORMAL);
                                                        exit(EXIT_FAILURE);   
                                                    } else {
                                                        int type_width;
                                                        if (symb->type == FLOAT_TYPE){
                                                            type_width = 8;
                                                        } else {
                                                            type_width = 4;
                                                        }
                                                        int type_widths[10];
                                                        type_widths[$3.arr_depth-1] = type_width;
                                                        char type_widths_str[10][10];
                                                        sprintf(type_widths_str[$3.arr_depth-1], "%d", type_widths[$3.arr_depth-1]);
                                                        for(int i=$3.arr_depth-2;i>=0;i--){
                                                            type_widths[i] = type_widths[i+1]*symb->arr_data[i+1];
                                                            sprintf(type_widths_str[i], "%d", type_widths[i]);
                                                        }
                                                        for(int i=0;i<$3.arr_depth;i++){
                                                            printf("%d\n", type_widths[i]);
                                                        }
                                                        printf("-----------------------------------\n");
                                                        for(int i=0;i<$3.arr_depth;i++){
                                                            printf("%d\n", symb->arr_data[i]);
                                                        }
                                                        printf("-----------------------------------\n");
                                                        for(int i=0;i<$3.arr_depth;i++){
                                                            printf("%s\n", $3.arr_data[i]);
                                                        }
                                                        char* ind = new_temp();
                                                        $$.code = scc(3, $3.code, ind," = 0\n");
                                                        puttemp(ind, INT_TYPE);
                                                        for(int i=0; i<$3.arr_depth; i++){
                                                            char* temp1 = new_temp();
                                                            char* temp2 = new_temp();
                                                            puttemp(temp1,INT_TYPE);
                                                            puttemp(temp2,INT_TYPE);
                                                            $$.code = scc(17, $$.code, temp1, " = ", type_widths_str[i], "\n", temp2, " = ", temp1, " * ", $3.arr_data[i],"\n", ind, " = ", ind, " + ", temp2,"\n");
                                                        }
                                                        if (symb->type != FLOAT_TYPE){
                                                            printf(TO_RED);
                                                            printf("Error: Invalid type for 'readFloat'\n");
                                                            printf(TO_NORMAL);
                                                            exit(EXIT_FAILURE);
                                                        }
                                                        $$.nextlist = NULL; $$.breaklist = NULL;
                                                        $$.continuelist = NULL;
                                                        $$.code  = scc(6,$$.code,"fread ",symb->alias,"[", ind, "]\n");
                                                    }
                                                }
                    | simpleStmt                {
                                                    $$.code = $1.code; 
                                                    $$.nextlist = $1.nextlist;
                                                    $$.breaklist = $1.breaklist;
                                                    $$.continuelist = $1.continuelist;
                                                }
;
stmt: simpleStmt                            {
                                                $$.code = $1.code; 
                                                $$.nextlist = $1.nextlist; 
                                                $$.breaklist = $1.breaklist;
                                                $$.continuelist = $1.continuelist;
                                            }
      | INDG stmt2 complexOrSimpleStmt DED  {
                                                char *label = new_label(); 
                                                backpatch($2.nextlist, label);
                                                globalnextlist = merge(globalnextlist, $2.nextlist);
                                                $$.nextlist = $3.nextlist;
                                                $$.breaklist = merge($2.breaklist, $3.breaklist);
                                                $$.continuelist = merge($2.continuelist, $3.continuelist);
                                                $$.code = scc(3, $2.code, putl(label), $3.code);
                                            }
;
stmt2: stmt2 complexOrSimpleStmt INDEQ      {
                                                char *label = new_label(); 
                                                backpatch($1.nextlist, label);
                                                globalnextlist = merge(globalnextlist, $1.nextlist);
                                                $$.nextlist = $2.nextlist;
                                                $$.breaklist = merge($1.breaklist, $2.breaklist);
                                                $$.continuelist = merge($1.continuelist, $2.continuelist);
                                                $$.code = scc(3, $1.code, putl(label), $2.code);
                                            }
      |                                     {
                                                $$.code = ""; 
                                                $$.nextlist = NULL; 
                                                $$.breaklist = NULL;
                                                $$.continuelist = NULL;
                                            }
;

%%
/* End of grammar */

const char* g_current_filename = "stdin"; // Global variable to store name of input file (Could be a .nim file or stdin)

/* Function to generate a Backpatch label (Label to be backpatched) */
char* new_label(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("label",label_no_str);
    label_no++;
    return label;
}

/* Function to generate a temporary variable */
char* new_temp(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("_temp",label_no_str);
    label_no++;
    return label;
}

/* Function to generate a Backpatch label (Label to be backpatched) */
char* new_bplabel(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("_bp",label_no_str);
    label_no++;
    return label;
}

/* Utility function to concatenate two strings (returns concatenated string) */
char* sc(char * s1, char *s2){
    char* res = (char*)malloc(strlen(s1) + strlen(s2) + 2);
    strcpy(res,s1);
    strcat(res,s2);
    return res;
}

/* Utility function to concatenate variable number of strings (returns concatenated string) */
char * scc(int num,...){
    va_list args1, args2;
    va_start(args1, num);
    va_copy(args2, args1);
    int tot_len = 2;
    for (int i=0; i<num; i++){
        tot_len += strlen(va_arg(args1, char *));
    }
    va_end(args1);
    char *s = malloc(tot_len * sizeof(char*));
    s = strcpy(s,va_arg(args2, char *));
    for (int i=1; i<num; i++){
        strcat(s, va_arg(args2, char *));
    }
    va_end(args2);
    return s;
}

/* Utility function to write Intermediate code to a file */
void dump_IR(char * code){
    FILE *fptr;
    char filename[20] = ".mininimIR";
    fptr = fopen(filename, "w");
    fprintf(fptr, "%s",code);
    fclose(fptr);
}

/* Function to create a new patch labels list */
bp_node *create_bp(char * temp_label) {
    bp_node *v = (bp_node *) malloc(sizeof(bp_node));
    v->temp_label = temp_label;
    v->bp_label = NULL;
    v->prev = NULL;
    return v;
}

/* Function to merge two lists (of patch labels) */
bp_node *merge(bp_node *l1, bp_node *l2){
    if (l1==NULL) return l2;
    if (l2==NULL) return l1;
    bp_node *temp = l1;
    while (temp->prev != NULL) temp = temp->prev;
    temp->prev = l2;
    return l1;    
}

/* Recursive implementation of the backpatch function */
void backpatch(bp_node *l, char *bp_label){
    if (l==NULL) return;    
    l->bp_label = bp_label;
    backpatch(l->prev, bp_label);
}

/* Utility function to print list of patch labels */
void print_list(bp_node* l){
    if (l==0) return;
    if (l->bp_label == NULL){
        PRINTF("Internal Warning: Null Label Found for backpatch label: %s\n", l->temp_label);
    } else {
        PRINTF("%s   %s\n", l->temp_label, l->bp_label);
        print_list(l->prev);
    }
}

void dump_list_helper(FILE* fptr, bp_node* l){
    if(l==NULL) return;
    fprintf(fptr, "%s %s\n",l->temp_label,l->bp_label);
    dump_list_helper(fptr,l->prev);    
}

/* Utility function to write patch labels lists to a file */
void dump_list(bp_node* l){
    FILE *fptr;
    char filename[20] = ".mininimIR";
    fptr = fopen(filename, "a");
    fprintf(fptr, "IR_END\n");
    fprintf(fptr, "\nPATCH_LABELS\n\n");
    dump_list_helper(fptr,l);
    fclose(fptr);
}

void dump_symtab_helper(FILE* fptr, symrec* table){
    if(table==NULL) return;
    if (table->aux_type == BASIC_TYPE){
        if (table->type==FLOAT_TYPE){
            table->width = 8;
        } else if (table->type==INT_TYPE){
            table->width = 4;
        }
        fprintf(fptr, "%s %d %d\n",table->alias,table->type, table->width);
    } else {
        int width;
        if (table->type==FLOAT_TYPE){
            width = 8;
        } else if (table->type==INT_TYPE){
            width = 4;
        }
        for(int i=0;i<table->arr_depth;i++){
            width*=table->arr_data[i];
        }
        fprintf(fptr, "%s %d %d\n",table->alias,table->type, width);
    }
    dump_symtab_helper(fptr,table->prev);    
}

/* Utility function to write symbol table to file */
void dump_symtab(symrec *table){
    FILE *fptr;
    char filename[20] = ".mininimIR";
    fptr = fopen(filename, "a");
    fprintf(fptr, "\nDATA\n\n");
    dump_symtab_helper(fptr,table);
    fclose(fptr);
}

/* Utility function to print symbol table */
void print_symtab(symrec *table){
    if (table == NULL) return;
    char s[5][10] = {"INT","FLOAT","BOOL","STR","CHAR"};
    if(table->aux_type == BASIC_TYPE){
        if (strcmp(table->name,"")==0){
            PRINTF("%s    %s\n",table->alias,s[table->type]);
        } else {
            PRINTF("NIC: %s    %s    %s\n", table->name,table->alias,s[table->type]);
        }
    } else {
        PRINTF("%s    %s    %s    ",table->name,table->alias,s[table->type]);
        PRINTF("ARRAY");
        for(int i=0;i<table->arr_depth;i++){
            PRINTF("[%d]", table->arr_data[i]);
        }
        PRINTF("\n");
    }
    print_symtab(table->prev);
}

/* Function: to free copied variables and update other variable to final_sym_table  */
void purge_table(symrec* var){
    if(var == NULL) return;
    if(var->scope==curr_scope){
        symrec * prev_var = var->prev;
        if(var->is_copy == True) {
            free(var);
        } else {
            var->prev = final_sym_table;
            final_sym_table = var;
        }
        sym_table = prev_var;
        purge_table(prev_var);
    }
}

/* Function to Begin scope */
void open_scope(){
    curr_scope++;
}

/* Function to End scope */
void close_scope(){
    purge_table(sym_table);
    curr_scope--;
}

/* Function to copy a variable to new (greater) scope (where used) */
void copysymtoscope(symrec* sym){
    symrec* var = (symrec *)malloc(sizeof(symrec));
    var->name = sym->name;
    var->alias = sym->alias;
    var->type = sym->type;
    var->aux_type = sym->aux_type;
    var->arr_depth = sym->arr_depth;
    for(int i=0;i< sym->arr_depth;i++) var->arr_data[i] = sym->arr_data[i];
    var->prev = sym_table;
    var->is_copy = True;
    var->scope = curr_scope;
    sym_table = var;
}

/* Utility function for putsym() */
void putsymraw(char* name,var_type typ){
    symrec* var = (symrec *)malloc(sizeof(symrec));
    var->name = name;
    var->alias = new_temp();
    var->type = typ;
    var->aux_type = BASIC_TYPE;
    var->is_copy = False;
    var->prev = sym_table;
    var->scope = curr_scope;
    sym_table = var;
}

/* Utility function for getsym() */
symrec* getsymraw(symrec* curr_var,char *name){
    if (curr_var == NULL) return NULL;
    if(strcmp(curr_var->name, name)==0){
        return curr_var;
    } else {
        return getsymraw(curr_var->prev,name);
    }
}

/* Put temporary in symbol table */
void puttemp(char* temp_name,var_type typ){
    symrec* var = (symrec *)malloc(sizeof(symrec));
    var->name = "";
    var->alias = temp_name;
    var->type = typ;
    var->aux_type = BASIC_TYPE;
    var->is_copy = False;
    var->prev = sym_table;
    var->scope = curr_scope;
    sym_table = var;
}

/* Put in symbol table */
void putsym(char* name,var_type typ){
    symrec* res = getsymraw(sym_table,name);
    if (res == NULL || res->scope < curr_scope){
        putsymraw(name,typ);
    } else {
        printf(TO_RED);
        printf("Error: Variable redeclaration in scope\n");
        printf(TO_NORMAL);
        exit(EXIT_FAILURE);
    }
}

/* Fetch from symbol table */
symrec* getsym(char * name){
    symrec* res =  getsymraw(sym_table,name);
    if (res == NULL){
        printf(TO_RED);
        printf("Error: Variable '%s' not found\n", name);
        printf(TO_NORMAL);
        exit(EXIT_FAILURE);
    }
    if (res->scope !=curr_scope){
        copysymtoscope(res);
        return sym_table;
    } else {
        return res;
    }
}

int main(int argc, char* argv[]) {
    yyin = stdin;
    if(argc == 2) { // If no 'run' command is given: "./mininim filename.nim"
        yyin = fopen(argv[1], "r");
        g_current_filename = argv[1];
        if(!yyin) {
            printf("File Error: %s\n",argv[1]);
            return 1;
        }
    } else if (argc==3){ // If 'run' command is given: "./mininim run filename.nim"
        if (strcmp(argv[1],"run")!=0){
            printf("Argument %s not recognised\n",argv[1]);
            return 1;
        }
        yyin = fopen(argv[2], "r");
        g_current_filename = argv[2];
        if(!yyin) {
            printf("File Error: %s\n",argv[2]);
            return 1;
        }
    }
    // Begin Debug
    PRINTF(TO_YELLOW);
    PRINTF("------------------------------------------------------------------\n");
    PRINTF("LEXER OUTPUT\n");
    PRINTF("------------------------------------------------------------------\n");
    PRINTF(TO_NORMAL);

    /* Begin Parsing */
    open_scope(); //Base Scope
    do {
        yyparse();
    } while (!feof(yyin));
    close_scope();
    /* End Parsing */
    
    PRINTF(TO_YELLOW);
    PRINTF("------------------------------------------------------------------\n");
    PRINTF("PARSER OUTPUT\n");
    PRINTF("------------------------------------------------------------------\n");
    PRINTF(TO_NORMAL);
    PRINTF("True List:\n");
    print_list(globaltruelist);
    PRINTF("False List:\n");
    print_list(globalfalselist);
    PRINTF("Next List:\n");
    print_list(globalnextlist);
    PRINTF("Symbol Table:\n");
    print_symtab(final_sym_table);
    PRINTF("\nGenerated IR:\n");
    PRINTF("%s", final_IR);
    dump_IR(final_IR);
    dump_list(merge(merge(globalnextlist,globaltruelist),globalfalselist));
    dump_symtab(final_sym_table);
    /* End Debug */


    if (argc == 2){ // If 'run' command is not given, only assembly file is generated.
        /* Generating Assembly Code */
        system(scc(2,"./asmgen.py ", argv[1]));
    } else if (argc==3){ // If 'run' command is given, assembly file is executed.
        /* Generating Assembly Code */
        system(scc(2,"./asmgen.py ", argv[2]));
        
        char * fname = malloc(strlen(argv[2]) * sizeof(char));
        for(int i=0;i<strlen(argv[2]) - 3;i++){
            fname[i] = argv[2][i];
        }
        fname[strlen(argv[2])-3] = '\0';

        printf(TO_GREEN);
        printf("Running Code...\n");
        printf(TO_NORMAL);
        fflush(stdout);

        /* Executing Assembly Code using Mars.jar */
        system(scc(3,"java -jar Mars.jar nc ", fname,"asm"));
    }
}

void yyerror (char *s)  /* Called by yyparse on error */{
    printf(TO_RED);
    printf ("%s\n", s);
    printf(TO_NORMAL);
    exit(EXIT_FAILURE);
}