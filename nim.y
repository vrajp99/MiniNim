/* 
Reference: http://dinosaur.compilertools.net/bison/bison_5.html
*/

%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h> 
#include <stdarg.h>
#include <math.h>
#include "backpatch.h"
#include "symrec.h"  /* Contains definition of `symrec" */
#define PARSER_DEBUG


#ifdef PARSER_DEBUG
#define PRINTF(...) printf(__VA_ARGS__)
#endif
#ifndef PARSER_DEBUG
#define PRINTF(...)
#endif

#define TO_RED "\033[1;31m"
#define TO_NORMAL "\033[0m"

int  yylex(void);
void yyerror (char  *); 
FILE *yyin;
int curr_scope = 0;
symrec *sym_table = NULL;
char* new_label();
char* new_temp();
char* new_bplabel();
char* sc(char * s1, char *s2);
char* scc(int num,...);
void dump_IR(char *);
char boolean[2][10] = {"0","1"};
char* putl(char * s){
    return sc(s,":\n");
}
bp_node *create_bp(char * temp_label) {
    bp_node *v = (bp_node *) malloc(sizeof(bp_node));
    v->temp_label = temp_label;
    v->bp_label = NULL;
    v->prev = NULL;
    return v;
}

bp_node *merge(bp_node *l1, bp_node *l2){
    if (l1==NULL) return l2;
    if (l2==NULL) return l1;
    bp_node *temp = l1;
    while (temp->prev != NULL) temp = temp->prev;
    temp->prev = l2;
    return l1;    
}

void backpatch(bp_node *l, char *bp_label){
    if (l==NULL) return;
    l->bp_label = bp_label;
    backpatch(l->prev, bp_label);
}

void print_list(bp_node* l){
    if (l==0) return;
    if (l->bp_label == NULL){
        PRINTF("Internal Warning: Null Label Found for backpatch label: %s\n", l->temp_label);
    } else {
        PRINTF("%s   %s\n", l->temp_label, l->bp_label);
        print_list(l->prev);
    }
}

bp_node* globaltruelist = NULL;
bp_node* globalfalselist = NULL;
bp_node* globalnextlist = NULL;
char * final_IR;
symrec* final_sym_table = NULL;
void open_scope();
void close_scope();
void puttemp(char*,var_type);
%}

%union {
int integer;
double floater;  /* For returning numbers.                   */
char *str;
char ch;
idorlit idl;
// symrec  *tptr;   /* For returning symbol-table pointers      */
sdd s_tree;
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
%token NIL "nil"
%token PROC "proc"
%token RETURN "return"
%token TUPLE "tuple"
%token TYPE "type"
%token VAR "var"
%token WHILE "while"
%token ECHOP "echo"
%token ARRAY "array"
%token RDINT "readInt"
%token RDFLT "readFloat"



%nonassoc IFX
%nonassoc ELSEX
%nonassoc INDEQ

// %type  <int> exp

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
%right '$'
%right NOT
%right UPLUS
%right UMINUS
%nonassoc LPAREN
%locations
%debug
// Non-Terminals Types

%type <s_tree> module complexOrSimpleStmt module2 sExpr primary simpleStmt expr exprStmt ifStmt stmt colonBody stmt2 elifCondStmt whileStmt breakStmt continueStmt typeDesc secVariable variable forStmt
%type <idl> symbol literal identOrLiteral

/* Grammar follows */

%%

module: complexOrSimpleStmt {   
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
        | {$$.code = ""; final_IR = $$.code;}
;
module2: module2 INDEQ complexOrSimpleStmt {
                                            char* label = new_label();
                                            backpatch($1.nextlist, label);
                                            globalnextlist = merge(globalnextlist, $1.nextlist);
                                            $$.nextlist = $3.nextlist;
                                            $$.code = scc(3, $1.code,putl(label),$3.code);
                                           }
        | complexOrSimpleStmt {
                                $$.nextlist = $1.nextlist;
                                $$.code = $1.code;
                              }
;
comma: ','
;
colon: ':'
;
sExpr: sExpr "xor" sExpr  {
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
                            if (($1.type != BOOL_TYPE) || ($3.type != BOOL_TYPE)){
                                printf(TO_RED);
                                printf("Error: Operands not of boolean type for 'xor'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(31, t, " = 0\n", $1.code, putl(B1_truelabel), t, " = 1\ngoto c", label, "\n", putl(B1_falselabel), t, " = 0\n", putl(label), $3.code, putl(B2_truelabel), "if ", t, " goto ", bpflabel, "\n", "goto ", bptlabel, "\n", putl(B2_falselabel), "ifFalse ", t, " goto ", bpflabel, "\n", "goto ", bptlabel, "\n");
                          }
      | sExpr "or" sExpr  {
                            char *label = new_label();
                            backpatch($1.falselist,label);
                            globalfalselist = merge(globalfalselist, $1.falselist);
                            $$.truelist = merge($1.truelist,$3.truelist);
                            $$.falselist = $3.falselist;
                            $$.type = BOOL_TYPE;
                            if (($1.type != BOOL_TYPE) || ($3.type != BOOL_TYPE)){
                                printf(TO_RED);
                                printf("Error: Operands not of boolean type for 'or'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(3,$1.code, putl(label), $3.code);
                          }
      | sExpr "and" sExpr {
                            char *label = new_label();
                            backpatch($1.truelist,label);
                            globaltruelist = merge(globaltruelist, $1.truelist);
                            $$.falselist = merge($1.falselist,$3.falselist);
                            $$.truelist = $3.truelist;
                            $$.type = BOOL_TYPE;
                            if (($1.type != BOOL_TYPE) || ($3.type != BOOL_TYPE)){
                                printf(TO_RED);
                                printf("Error: Operands not of boolean type for 'and'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(3,$1.code, putl(label), $3.code);
                          }
      | sExpr "!=" sExpr {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            $$.truelist = create_bp(bplabel1);
                            $$.falselist = create_bp(bplabel2);
                            $$.type = BOOL_TYPE;
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " ne ";
                                // puttemp($$.addr, INT_TYPE);
                            } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                opr = " nef ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " fne ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " fnef ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for '!='\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr , $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
      | sExpr '>' sExpr {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            $$.truelist = create_bp(bplabel1);
                            $$.falselist = create_bp(bplabel2);
                            $$.type = BOOL_TYPE;
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " lt ";
                                // puttemp($$.addr, INT_TYPE);
                            } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                opr = " ltf ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " flt ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " fltf ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for '>'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(11, $1.code, $3.code, "if ", $3.addr, opr, $1.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                        }
      | sExpr ">=" sExpr {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            $$.truelist = create_bp(bplabel1);
                            $$.falselist = create_bp(bplabel2);
                            $$.type = BOOL_TYPE;
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " le ";
                                // puttemp($$.addr, INT_TYPE);
                            } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                opr = " lef ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " fle ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " flef ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for '>='\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(11, $1.code, $3.code, "if ", $3.addr, opr, $1.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
      | sExpr '<' sExpr {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            $$.truelist = create_bp(bplabel1);
                            $$.falselist = create_bp(bplabel2);
                            $$.type = BOOL_TYPE;
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " lt ";
                                // puttemp($$.addr, INT_TYPE);
                            } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                opr = " ltf ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " flt ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " fltf ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for '<'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr, $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                        }
      | sExpr "<=" sExpr {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            $$.truelist = create_bp(bplabel1);
                            $$.falselist = create_bp(bplabel2);
                            $$.type = BOOL_TYPE;
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " le ";
                                // puttemp($$.addr, INT_TYPE);
                            } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                opr = " lef ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " fle ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " flef ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for '<='\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr, $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
      | sExpr "==" sExpr {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            $$.truelist = create_bp(bplabel1);
                            $$.falselist = create_bp(bplabel2);
                            $$.type = BOOL_TYPE;
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " eq ";
                                // puttemp($$.addr, INT_TYPE);
                            } else if($1.type == INT_TYPE && $3.type == FLOAT_TYPE){
                                opr = " eqf ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == INT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " feq ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else if ($3.type == FLOAT_TYPE && $1.type == FLOAT_TYPE){
                                opr = " feqf ";
                                // puttemp($$.addr, FLOAT_TYPE);
                            } else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for '=='\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            }
                            $$.code = scc(11, $1.code, $3.code, "if ", $1.addr, opr, $3.addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
      | sExpr '-' sExpr {
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
      | sExpr '+' sExpr {
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
      | sExpr '%' sExpr {
                            $$.truelist = NULL;
                            $$.falselist = NULL;
                            $$.addr = new_temp(); 
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " mod ";
                                puttemp($$.addr, INT_TYPE);
                                $$.type = INT_TYPE;
                            }else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for 'mod'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            } 
                            $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr, $3.addr,"\n");
                        }
      | sExpr "mod" sExpr {
                            $$.truelist = NULL;
                            $$.falselist = NULL;
                            $$.addr = new_temp(); 
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " mod ";
                                puttemp($$.addr, INT_TYPE);
                                $$.type = INT_TYPE;
                            }else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for 'mod'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            } 
                            $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr , $3.addr,"\n");
                          }
      | sExpr "div" sExpr {
                            $$.truelist = NULL;
                            $$.falselist = NULL;
                            $$.addr = new_temp(); 
                            char *opr;
                            if ($1.type == INT_TYPE && $3.type == INT_TYPE){
                                opr = " idiv ";
                                puttemp($$.addr, INT_TYPE);
                                $$.type = INT_TYPE;
                            }else{
                                printf(TO_RED);
                                printf("Error: Operands not of suitable type for 'div'\n");
                                printf(TO_NORMAL);
                                exit(EXIT_FAILURE);
                            } 
                            $$.code = scc(8, $1.code, $3.code, $$.addr," = ", $1.addr, opr , $3.addr,"\n");
                          }
      | sExpr '/' sExpr {
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
      | sExpr '*' sExpr {
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
      | '-' sExpr %prec UMINUS {
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
                                $$.code = scc(6, $2.code, $$.addr, " = ", opr, $2.addr, "\n");
                               }
      | '$' sExpr {}
      | "not" sExpr {
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
      | primary {   
                    // TODO: Add support for true false
                    $$.truelist = $1.truelist;
                    $$.falselist = $1.falselist;
                    $$.code = $1.code; 
                    $$.addr = $1.addr;
                    $$.type = $1.type;
                }
;
symbol: IDENT {
               $$.value.name = $1;
               $$.is_ident=1;
              }
;

exprList: expr comma exprList 
         | expr 
;
literal: BOOLLIT {$$.value.bval = $1; 
                  $$.type = BOOL_TYPE;$$.is_ident=0;}
        | INTLIT {$$.value.ival = $1; 
                  $$.type = INT_TYPE;$$.is_ident=0;}
        | FLOATLIT {$$.value.fval = $1; 
                    $$.type = FLOAT_TYPE;$$.is_ident=0;}
        | STRLIT {$$.value.sval = $1; 
                  $$.type = STR_TYPE;$$.is_ident=0;}
        | CHARLIT {$$.value.cval = $1; 
                  $$.type = CHAR_TYPE;$$.is_ident=0;}
        | "nil" {$$.is_ident=0;} 
;
identOrLiteral: symbol {
                            $$.value.name = $1.value.name; 
                            $$.is_ident = 1;
                       }
               | literal {
                            if($1.type==INT_TYPE){$$.value.ival=$1.value.ival;} 
                            else if($1.type==FLOAT_TYPE){$$.value.fval=$1.value.fval;} 
                            else if($1.type==CHAR_TYPE){$$.value.cval=$1.value.cval;} 
                            else if($1.type==STR_TYPE){$$.value.sval=$1.value.sval;} 
                            else if($1.type==INT_TYPE){$$.value.bval=$1.value.bval;} 
                            $$.type = $1.type; $$.is_ident=0;
                         }
               | arrayConstr  
               | tupleConstr 
;
tupleConstr: '(' exprList ')' 
;
arrayConstr: '[' exprList ']'
;
primarySuffix: '(' exprList ')'
              | '('')' 
              | '['  expr  ']' 
              | '.'  symbol
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
declColon: symbol ':'  typeDesc
;
inlTupleDecl: "tuple" '['   declColonCommaNoHang   ']'
;
arrayDecl: "array" '['  INTLIT comma typeDesc ']'
;
paramList: '(' declColonCommaNoHang ')' 
          | '(' ')'
;
declColonCommaNoHang: declColon comma declColonCommaNoHang 
                     | declColon 
;
paramListColon: paramList ':'  typeDesc 
               | ':'  typeDesc
               |
;

/* forStmt: "for"  symbolCommaNoHang  "in" expr colonBody
        | "for"  symbol  "in" expr colonBody {}
; */

forStmt: "for" {open_scope();}  symbol {putsym($3.value.name,INT_TYPE);} "in" expr ".." expr colonBody {
                                                                          char* label = new_label();
                                                                          char* bplabel = new_bplabel();
                                                                          symrec* sym = getsym($3.value.name);
                                                                          char* sa = sym->alias;
                                                                          backpatch($9.nextlist, label);
                                                                          globalnextlist = merge(globalnextlist, $9.nextlist);
                                                                          $$.nextlist = merge($9.breaklist, create_bp(bplabel));
                                                                          $$.breaklist = NULL;
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
                                                                          $$.code = scc(22, $6.code, $8.code, sa, " = ", $6.addr,"\n", putl(label), "if ", $8.addr, " lt ", sa, " goto ",bplabel, "\n", $9.code, sa, " = ",sa," + ","_incr\ngoto ",label,"\n");
                                                                          close_scope();
                                                                      }
;
expr: ifExpr 
     | sExpr {
                $$.code = $1.code; 
                $$.addr = $1.addr;
                $$.type = $1.type;
                $$.truelist = $1.truelist;
                $$.falselist = $1.falselist;
             }
;
primary: identOrLiteral primary2 
        | identOrLiteral {
                            $$.addr = new_temp();
                            $$.truelist = NULL;
                            $$.falselist = NULL; 
                            if($1.is_ident){
                                symrec* symb = getsym($1.value.name);
                                puttemp($$.addr,symb->type);
                                $$.type = symb->type;
                                $$.code = scc(4, $$.addr, " = ", symb->alias, "\n");
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
                                sprintf(float_str,"%f",$1.value.fval);
                                $$.code = scc(4, $$.addr, " f=f ", float_str,"\n");
                            }
                            else if($1.type==STR_TYPE){
                                puttemp($$.addr,STR_TYPE);
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
                                // $$.code = scc(4, $$.addr, " = ", boolean[$1.value.bval], "\n"));
                                $$.code = scc(7, "goto ", bplabel, "\n", $$.addr, " = ", boolean[$1.value.bval], "\n");
                            }
                         }
;
primary2: primarySuffix primary2 
         | primarySuffix
;
typeDesc: symbol { 
                    if(strcmp($1.value.name, "int")==0){
                        $$.type = INT_TYPE;
                    } else if (strcmp($1.value.name, "float")==0){
                        $$.type = FLOAT_TYPE;
                    } else {
                        printf(TO_RED);
                        printf("Error: Unknown type assigned to variable.\n");
                        printf(TO_NORMAL);
                        exit(EXIT_FAILURE);
                    }
                } 
         | inlTupleDecl 
         | arrayDecl
;
// typeDesc: symbol 
//          | enum 
//          | inlTupleDecl 
//          | arrayDecl
// ;
exprStmt: sExpr {$$.code = $1.code; $$.nextlist = NULL;}
         | symbol '=' expr  {
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
                                    printf("Error: Type assigned to variable.\n");
                                    printf(TO_NORMAL);
                                    exit(EXIT_FAILURE);
                                }
                                $$.code = scc(5, $3.code, symb->alias, opr, $3.addr, "\n"); 
                                $$.nextlist = NULL;
                            }
         | symbol "+=" expr {}
         | symbol "*=" expr {}
;
// exprStmt: sExpr 
//          | varTuple '=' expr 
//          | symbol "+=" expr
//          | symbol "*=" expr
// ;
returnStmt: "return" expr 
           | "return"
;
breakStmt: "break" {
                        char *bplabel = new_bplabel();
                        $$.breaklist = create_bp(bplabel);
                        $$.nextlist = NULL;
                        $$.code = scc(3,"goto ", bplabel, "\n");
                   }
;
continueStmt: "continue" {
                            char *bplabel = new_bplabel();
                            $$.breaklist = NULL;
                            $$.nextlist = create_bp(bplabel);
                            $$.code = scc(3,"goto ", bplabel, "\n");
                         }
;
ifStmt: "if" expr colonBody INDEQ elifCondStmt %prec IFX {}
         |"if" expr colonBody INDEQ elifCondStmt "else" colonBody {}
         | "if" expr colonBody %prec IFX {
                                            char *label = new_label();
                                            backpatch($2.truelist, label);
                                            globaltruelist = merge(globaltruelist, $2.truelist);
                                            $$.nextlist = merge($2.falselist, $3.nextlist);
                                            $$.breaklist = $3.breaklist;
                                            $$.code = scc(3, $2.code, putl(label), $3.code);
                                          }
         | "if" expr colonBody INDEQ "else" colonBody {
                                                        char *label1 = new_label();
                                                        char *label2 = new_label();
                                                        char *bplabel = new_bplabel();
                                                        backpatch($2.truelist, label1);
                                                        backpatch($2.falselist, label2);
                                                        globalfalselist = merge(globalfalselist, $2.falselist);
                                                        globaltruelist = merge(globaltruelist, $2.truelist);
                                                        $$.nextlist = merge(create_bp(bplabel) ,merge($3.nextlist, $6.nextlist));
                                                        $$.breaklist = merge($3.breaklist,$6.breaklist);
                                                        $$.code = scc(8, $2.code, putl(label1), $3.code, "goto ", bplabel, "\n", putl(label2), $6.code);
                                                      }
;
elifCondStmt: elifCondStmt INDEQ "elif" expr colonBody {
                                                        // $$.code = scc(8, $2.code, putl(label1), $3.code, "goto ", bplabel, "\n", putl(label2), $6.code);
                                                       }
             | INDEQ "elif" expr colonBody {
                                            // char *label = new_label();
                                            // $$.code = scc(8, $3.code, putl(label), $4.code, "goto ", bplabel, "\n", putl(label2), $6.code);
                                           }
;
whileStmt: "while" expr colonBody {
                                      char* label1 = new_label();
                                      char* label2 = new_label();
                                      backpatch($3.nextlist, label1);
                                      backpatch($2.truelist, label2);
                                      globalnextlist = merge(globalnextlist,$3.nextlist);
                                      globaltruelist = merge(globaltruelist, $2.truelist);
                                      $$.nextlist = merge($2.falselist,$3.breaklist);
                                      $$.breaklist = NULL;
                                      $$.code = scc(7,putl(label1),$2.code,putl(label2),$3.code,"goto ",label1,"\n");
                                  }
;
routine:  symbol paramListColon '=' stmt 
        | symbol paramListColon
;
// enum: "enum"  symbolCommaNoHang
//         | "enum" symbol
// ;
typeDef: symbol '='  typeDesc
;
// varTuple: "("  symbolCommaNoHang ")" "="  expr
//         | "("  symbol ")" "="  expr
// ;
colonBody: colon {open_scope();} stmt { close_scope();$$.code = $3.code; $$.nextlist = $3.nextlist; $$.breaklist = $3.breaklist;}
;
// variable: varTuple 
//          | declColon "=" expr 
//          | declColon
// ;
variable: symbol ':'  typeDesc '=' expr {
                                            $$.nextlist = NULL; $$.breaklist = NULL;
                                            putsym($1.value.name,$3.type);
                                            symrec * symb = getsym($1.value.name);
                                            $$.code = scc(5, $5.code, symb->alias, " = ", $5.addr,"\n");
                                        }
         | symbol ':'  typeDesc {
                                    putsym($1.value.name,$3.type);
                                    $$.nextlist = NULL; $$.breaklist = NULL; 
                                    $$.code="";
                                }
;
secVariable: variable {$$.code = $1.code; $$.nextlist=$1.nextlist; $$.breaklist = $1.breaklist;}
            | INDG variable serVariable DED
;
serVariable: INDEQ variable serVariable 
            | 
;
simpleStmt: returnStmt 
            | breakStmt {
                            $$.nextlist = $1.nextlist;
                            $$.breaklist = $1.breaklist;
                            $$.code = $1.code;
                        }
            | continueStmt {
                               $$.nextlist = $1.nextlist;
                               $$.breaklist = $1.breaklist;
                               $$.code = $1.code;
                           } 
            | exprStmt {$$.code = $1.code; $$.nextlist = NULL; $$.breaklist = NULL;}
;
complexOrSimpleStmt: ifStmt {$$.code = $1.code; $$.nextlist = $1.nextlist; $$.breaklist = $1.breaklist;}
                    | whileStmt {$$.code = $1.code; $$.nextlist = $1.nextlist; $$.breaklist = $1.breaklist;}
                    | forStmt
                    | "echo" expr { 
                                        PRINTF("Idhar Aaya?\n");
                                        char * opr;
                                        if($2.type == INT_TYPE){
                                            opr = "iprint ";
                                        } else if ($2.type == FLOAT_TYPE){
                                            opr = "fprint ";
                                        } else if ($2.type == STR_TYPE || $2.type == CHAR_TYPE){
                                            opr = "sprint ";
                                        } else {
                                            printf(TO_RED);
                                            printf("Error: Invalid type for 'echo'\n");
                                            printf(TO_NORMAL);
                                            exit(EXIT_FAILURE);
                                        }
                                        $$.nextlist = NULL; $$.breaklist = NULL;
                                        $$.code = scc(4,$2.code, opr ,$2.addr,"\n");
                                    }
                    | "proc" routine
                    | "type" typeDef
                    | "var" secVariable {$$.code = $2.code; $$.nextlist = $2.nextlist; $$.breaklist = $2.breaklist;}
                    | "readInt" symbol {
                                            symrec * symb = getsym($2.value.name);
                                            if (symb->type != INT_TYPE){
                                                printf(TO_RED);
                                                printf("Error: Invalid type for 'readInt'\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);
                                            }
                                            $$.nextlist = NULL; $$.breaklist = NULL;
                                            $$.code  = scc(3,"iread ",symb->alias,"\n");
                                       }
                    | "readFloat" symbol {
                                            symrec * symb = getsym($2.value.name);
                                            if (symb->type != FLOAT_TYPE){
                                                printf(TO_RED);
                                                printf("Error: Invalid type for 'readFloat'\n");
                                                printf(TO_NORMAL);
                                                exit(EXIT_FAILURE);
                                            }
                                            $$.nextlist = NULL; $$.breaklist = NULL;
                                            $$.code  = scc(3,"fread ",symb->alias,"\n");
                                        }
                    | simpleStmt {$$.code = $1.code; $$.nextlist = $1.nextlist;$$.breaklist = $1.breaklist;}
;
stmt: simpleStmt {$$.code = $1.code; $$.nextlist = $1.nextlist; $$.breaklist = $1.breaklist;}
      | INDG stmt2 complexOrSimpleStmt DED {
                                            char *label = new_label(); 
                                            backpatch($2.nextlist, label);
                                            globalnextlist = merge(globalnextlist, $2.nextlist);
                                            $$.nextlist = $3.nextlist;
                                            $$.breaklist = merge($2.breaklist, $3.breaklist);
                                            $$.code = scc(3, $2.code, putl(label), $3.code);
                                           }
;
stmt2: stmt2 complexOrSimpleStmt INDEQ {
                                        char *label = new_label(); 
                                        backpatch($1.nextlist, label);
                                        globalnextlist = merge(globalnextlist, $1.nextlist);
                                        $$.nextlist = $2.nextlist;
                                        $$.breaklist = merge($1.breaklist, $2.breaklist);
                                        $$.code = scc(3, $1.code, putl(label), $2.code);
                                       }
      | {$$.code = ""; $$.nextlist = NULL; $$.breaklist = NULL;}
;

%%
/* End of grammar */

const char* g_current_filename = "stdin";

char* new_label(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("label",label_no_str);
    label_no++;
    return label;
}

char* new_temp(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("_temp",label_no_str);
    label_no++;
    return label;
}

char* new_bplabel(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("_bp",label_no_str);
    label_no++;
    return label;
}

char* sc(char * s1, char *s2){
    char* res = (char*)malloc(strlen(s1) + strlen(s2) + 2);
    strcpy(res,s1);
    strcat(res,s2);
    return res;
}

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

void dump_IR(char * code){
    FILE *fptr;
    char filename[20] = ".mininimIR";
    fptr = fopen(filename, "w");
    fprintf(fptr, "%s",code);
    fclose(fptr);
}

void dump_list_helper(FILE* fptr, bp_node* l){
    if(l==NULL) return;
    fprintf(fptr, "%s %s\n",l->temp_label,l->bp_label);
    dump_list_helper(fptr,l->prev);    
}


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
    fprintf(fptr, "%s %d %d\n",table->alias,table->type, table->type*4 + 4);
    dump_symtab_helper(fptr,table->prev);    
}

void dump_symtab(symrec *table){
    FILE *fptr;
    char filename[20] = ".mininimIR";
    fptr = fopen(filename, "a");
    fprintf(fptr, "\nDATA\n\n");
    dump_symtab_helper(fptr,table);
    fclose(fptr);
}

void print_symtab(symrec *table){
    if (table == NULL) return;
    char s[5][10] = {"INT","FLOAT","BOOL","STR","CHAR"};
    PRINTF("%s    %s\n",table->alias,s[table->type]);
    print_symtab(table->prev);
}

void open_scope(){
    curr_scope++;
}

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

void close_scope(){
    purge_table(sym_table);
    curr_scope--;
}

void putsymraw(char* name,var_type typ){
    symrec* var = (symrec *)malloc(sizeof(symrec));
    var->name = name;
    var->alias = new_temp();
    var->type = typ;
    var->is_copy = False;
    var->prev = sym_table;
    var->scope = curr_scope;
    sym_table = var;
}

void puttemp(char* temp_name,var_type typ){
    symrec* var = (symrec *)malloc(sizeof(symrec));
    var->name = "";
    var->alias = temp_name;
    var->type = typ;
    var->is_copy = False;
    var->prev = sym_table;
    var->scope = curr_scope;
    sym_table = var;
}

void copysymtoscope(symrec* sym){
    symrec* var = (symrec *)malloc(sizeof(symrec));
    var->name = sym->name;
    var->alias = sym->alias;
    var->type = sym->type;
    var->prev = sym_table;
    var->is_copy = True;
    var->scope = curr_scope;
    sym_table = var;
}

symrec* getsymraw(symrec* curr_var,char *name){
    if (curr_var == NULL) return NULL;
    if(strcmp(curr_var->name, name)==0){
        return curr_var;
    } else{
        return getsymraw(curr_var->prev,name);
    }
}

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

symrec* getsym(char * name){
    symrec* res =  getsymraw(sym_table,name);
    if (res == NULL){
        printf(TO_RED);
        printf("Error: Variable not found\n");
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

    if(argc == 2) {
        yyin = fopen(argv[1], "r");
        g_current_filename = argv[1];
        if(!yyin) {
            printf("File Error: %s\n",argv[1]);
            return 1;
        }
    }

    // parse through the input until there is no more:
    PRINTF("------------------------------------------------------------------\n");
    PRINTF("LEXER OUTPUT\n");
    PRINTF("------------------------------------------------------------------\n");
    open_scope();
    do {
        yyparse();
    } while (!feof(yyin));
    close_scope();
    PRINTF("------------------------------------------------------------------\n");
    PRINTF("PARSER OUTPUT\n");
    PRINTF("------------------------------------------------------------------\n");
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
    // Only in newer versions, apparently.
    // yylex_destroy();
}

void yyerror (char *s)  /* Called by yyparse on error */{
  printf ("%s\n", s);
}