/* 
    MiniNim: Lexer
    Reference (for handling indentation): https://github.com/lucasb-eyer/flex-bison-indentation
*/
%{
#include "symrec.h" 
#include "nim.tab.h"
#include "stack.h"
#include <string.h>

/* globals to track current indentation */
int g_current_line_indent = 0;    // indentation of the current line
node *indent_stack = NULL;        // Stack used for the indentation
int g_is_fake_outdent_symbol = 0; // Used when fake characters are unput. See in <indent> mode

#define YY_USER_INIT { \
        push(&indent_stack,0); \
        BEGIN(initial); \
    }

int yycolumn = 1;
int ft = 0;
void set_yycolumn(int val) {
    yycolumn = val;
    yylloc.first_column = yycolumn;
    yylloc.last_column = yycolumn + yyleng - 1;
}

#define YY_USER_ACTION { \
    yylloc.first_line = yylloc.last_line = yylineno; \
    set_yycolumn(yycolumn); \
    yycolumn += yyleng; \
}

/*Comment the line below to switch of the printing of Parser Debug information*/
#define LEXER_DEBUG
#ifdef LEXER_DEBUG
#define PRINTF(...) printf(__VA_ARGS__)
#endif
#ifndef LEXER_DEBUG
#define PRINTF(...)
#endif
%}

/* This is a sub-parser (state) for indentation-sensitive scoping */
%x initial
%x indent
%s normal

/* %option 8bit reentrant bison-bridge */
%option warn
%option nodefault
%option yylineno
%option noyywrap

/* Regular Definitions */

OP \*|\/|div|mod|\%|\+|\-|\&|\.\.|==|<=|<|>=|>|!=|not|and|or|xor|\+=|\*=|=
KEYW break|continue|elif|else|for|if|in|var|while|array|echo|readInt|readFloat|nil|proc|return|tuple|type

letter [A-Za-z]
digit [0-9] 
IDENT {letter}("_"?({letter}|{digit}))*

INTLIT {digit}+
STRLIT \"[^"\n]*\"
CHARLIT \'.\'
FLOATLIT {digit}+"."{digit}+
BOOLLIT true|false

ELSEINDENT "else "|"else:"
ELIFINDENT "elif "|"elif("
LINECOMMENT "#"[^\n]*

%%
    int indent_caller = normal; /* Stores which mode called the <indent> mode, to return once processing is done. */

    /* This helps to keep track of the column number.*/
<*>\n               {   /* On encountering newline, set the indentation column to be 0 */
                        set_yycolumn(0);
                        yylineno--; 
                        REJECT; // \n should not match with any other rule
                    }

    /* 
        The entire lexing takes place in <normal> mode. We enter the <indent> mode only when 
        a newline is encountered. 
        Also, at the beginning of a file, there is no newline. Hence, when we start in 
        the <initial> mode, we manually go to the <indent> mode.
    */

<initial>.          {   /* On encountering anything (newline is not matched) at start of file, Go to <indent> mode */
                        set_yycolumn(yycolumn-1); 
                        indent_caller = normal; // Set indent caller to normal, to return to <normal> mode once done.
                        yyless(0); 
                        BEGIN(indent); 
                    }

<initial>\n         {   /* On encountering a newline at start of file, Go to <indent> mode */
                        indent_caller = normal; // Set indent caller to normal, to return to <normal> mode once done.
                        yyless(0); 
                        BEGIN(indent);
                    }
    /*
        For managing indentations, we will use three tokens: 
            INDG (if indentation is greater than previous line)
            INDEQ (if indentation is same as the previous line)
            DED (If we have to dedent)
        In the below rules, we will see how and when these tokens are emitted to the parser.

    */


<indent>" "         {   g_current_line_indent++; } /* Increment indent value of current line */

<indent>\n          {   g_current_line_indent = 0; } /* ignoring blank line */

<indent>{LINECOMMENT} {/* For ignoring comments in code*/}

<indent><<EOF>>     {   /* On encountering EOF, check if any DED (dedents) are to be emitted, emit them and then terminate */
                        if(indent_stack->value != 0) {
                            pop(&indent_stack);

                            if(g_current_line_indent != indent_stack->value) {
                                unput('\n');
                                for(size_t i = 0 ; i < indent_stack->value ; ++i) {
                                    unput(' ');
                                }
                            } else {
                                BEGIN(indent_caller);
                            }
                            PRINTF("DED\n");
                            return DED;
                        } else {
                            yyterminate();
                        }
                    }

<indent>{ELSEINDENT}|{ELIFINDENT} {   /* Do not emit an INDEQ after an IF (or ELIF), if followed by ELIF or ELSE */
                        if(!g_is_fake_outdent_symbol) { // If the symbol is not fake, unput it.
                            int match_len = strlen(yytext);
                            for(int i=match_len-1;i>=0;i--){
                                unput(yytext[i]);
                            }
                        }
                        set_yycolumn(yycolumn-1); // reduce column number
                        g_is_fake_outdent_symbol = 0; 
                        /* 
                            If current indent is greater than previous line indent (present on indent stack), emit an INDG 
                            Else, if current indent is less than previous line indent (present on indent stack), emit as many DED's 
                                required (at least one, based on requirement), based on indent value of previous line present in stack.
                                This part is done cleverly, unput appropriate no. of whitespaces and then a '.'. And update that 
                                the next symbol is fake. So, in the next iteration, it can be taken care of. Emit a DED in each 
                                iteration.
                            Else, return to indent caller (as no INDEQ must be emitted).

                        */
                        if(g_current_line_indent > indent_stack->value) { 
                            push(&indent_stack,g_current_line_indent);
                            BEGIN(indent_caller); // return to caller of <indent> mode
                            PRINTF("INDG\n"); // Debug
                            return INDG;
                        } else if(g_current_line_indent < indent_stack->value) {
                            pop(&indent_stack);
                            if(g_current_line_indent != indent_stack->value) {
                                for(size_t i = 0 ; i < g_current_line_indent ; ++i) {
                                    unput(' ');
                                }
                                unput('\n');
                                unput('.');
                                g_is_fake_outdent_symbol = 1;
                            } else {
                            }
                            PRINTF("DED\n");
                            return DED;
                        } else {
                            BEGIN(indent_caller);
                        }
                    }
<indent>.           {   /* 
                            Once we are in this mode, we do the same as described above, just that we will emit an INDEQ in case the 
                            indentation is same.
                        */
                        if(!g_is_fake_outdent_symbol) {
                            unput(*yytext);
                        }
                        set_yycolumn(yycolumn-1);
                        g_is_fake_outdent_symbol = 0;
                        if(g_current_line_indent > indent_stack->value) {
                            push(&indent_stack,g_current_line_indent);
                            BEGIN(indent_caller);
                            PRINTF("INDG\n");
                            return INDG;
                        } else if (g_current_line_indent == indent_stack->value) {
                            BEGIN(indent_caller);
                            if(ft==0)
                            {
                                ft = 1;
                            } else {
                                PRINTF("INEQ\n");
                                return INDEQ;
                            }
                        } else if(g_current_line_indent < indent_stack->value) {
                            pop(&indent_stack);
                            if(g_current_line_indent != indent_stack->value) {
                                for(size_t i = 0 ; i < g_current_line_indent ; ++i) {
                                    unput(' ');
                                }
                                unput('\n');
                                unput('.');
                                g_is_fake_outdent_symbol = 1;
                            } else {
                            }
                            PRINTF("DED\n");
                            return DED;
                        } else {
                            BEGIN(indent_caller);
                        }
                    }

<normal>\n          {   /* On detecting a newline in normal mode, go to the indent mode above */
                        g_current_line_indent = 0; 
                        indent_caller = YY_START; 
                        BEGIN(indent); 
                    }

<normal>{LINECOMMENT}   /* Ignoring comments in code */

<normal><<EOF>>     {   /* On detecting EOF in normal mode, go to the indent mode above */
                        g_current_line_indent = 0; 
                        indent_caller = YY_START; 
                        BEGIN(indent); 
                    }

<normal>{OP}        {   /* Operators */
                        PRINTF("OP<%s>\n", yytext); // Debug

                        if(strcmp("*",yytext)==0) 
                            return '*';
                        else if(strcmp("/",yytext)==0)
                            return '/';
                        else if(strcmp("div",yytext)==0)
                            return DIV;
                        else if(strcmp("mod",yytext)==0)
                            return MOD;
                        else if(strcmp("+",yytext)==0)
                            return '+';
                        else if(strcmp("-",yytext)==0)
                            return '-';
                        else if(strcmp("&",yytext)==0)
                            return '&';
                        else if(strcmp("..",yytext)==0)
                            return SLICE;
                        else if(strcmp("==",yytext)==0)
                            return EQ;
                        else if(strcmp("<=",yytext)==0)
                            return LE;
                        else if(strcmp("<",yytext)==0)
                            return '<';
                        else if(strcmp(">=",yytext)==0)
                            return GE;
                        else if(strcmp(">",yytext)==0)
                            return '>';
                        else if(strcmp("!=",yytext)==0)
                            return NE;
                        else if(strcmp("not",yytext)==0)
                            return NOT;
                        else if(strcmp("and",yytext)==0)
                            return AND;
                        else if(strcmp("or",yytext)==0)
                            return OR;
                        else if(strcmp("xor",yytext)==0)
                            return XOR;
                        else if(strcmp("+=",yytext)==0)
                            return PEQ;
                        else if(strcmp("*=",yytext)==0)
                            return MEQ;
                        else if(strcmp("=",yytext)==0)
                            return '=';
                    }
<normal>{KEYW}      {   /* Keywords */
                        PRINTF("KeyW<%s>\n", yytext); // Debug

                        if(strcmp("break",yytext)==0)
                            return BREAK;
                        else if(strcmp("continue",yytext)==0)
                            return CONTINUE;
                        else if(strcmp("elif",yytext)==0)
                            return ELIF;
                        else if(strcmp("else",yytext)==0)
                            return ELSE;
                        else if(strcmp("for",yytext)==0)
                            return FOR;
                        else if(strcmp("if",yytext)==0)
                            return IF;
                        else if(strcmp("in",yytext)==0)
                            return IN;
                        else if(strcmp("var",yytext)==0)
                            return VAR;
                        else if(strcmp("while",yytext)==0)
                            return WHILE;
                        else if(strcmp("echo",yytext)==0)
                            return ECHOP;
                        else if(strcmp("readInt",yytext)==0)
                            return RDINT;
                        else if(strcmp("readFloat",yytext)==0)
                            return RDFLT;
                        else if(strcmp("array",yytext)==0)
                            return ARRAY;
                        else if(strcmp("nil",yytext)==0)
                            return NIL;
                        else if(strcmp("proc",yytext)==0)
                            return PROC;
                        else if(strcmp("return",yytext)==0)
                            return RETURN;
                        else if(strcmp("tuple",yytext)==0)
                            return TUPLE;
                        else if(strcmp("type",yytext)==0)
                            return TYPE;
                    }

<normal>{INTLIT}    {   /* Integer literals (Ex: 1, 105, 1729, etc.) */
                        PRINTF("Int<%s>\n", yytext); // Debug
                        sscanf(yytext,"%d",&yylval.integer);
                        return INTLIT;
                    }

<normal>{FLOATLIT}  {   /* Float literals (Ex: 3.14, 1.414, 0.0001, etc.) */
                        PRINTF("Float<%s>\n", yytext); // Debug
                        sscanf(yytext,"%lf",&yylval.floater);
                        return FLOATLIT;
                    }

<normal>{STRLIT}    {   /* String literals (Ex: "Hello World\n", etc.) */
                        PRINTF("String<%s>\n", yytext); // Debug
                        yylval.str = strdup(yytext);
                        return STRLIT;
                    }

<normal>{CHARLIT}   {   /* Character literals (Ex: 'n', 'i', 'm', etc.) */
                        PRINTF("Char<%c>\n", yytext[1]); // Debug
                        yylval.ch = yytext[1];
                        return CHARLIT;
                    }

<normal>{BOOLLIT}   {   /* Boolean Literals (Ex: true, false) */
                        PRINTF("Bool<%s>\n",yytext); // Debug
                        if (yytext[0]=='t'){ // Will be stored in yylval.integer
                            yylval.integer = 1; // true = 1
                        } else{
                            yylval.integer = 0; // false = 0
                        }
                        return BOOLLIT;
                    }

<normal>{IDENT}     {   /* Identifiers (Ex: a, arr, point, etc.) */
                        PRINTF("IDENT<%s>\n", yytext); // Debug
                        yylval.str = strdup(yytext);
                        return IDENT;
                    }

<normal>[ ]+        /* eat up whitespace */

<normal>.           {   /* Everything else, send it (the first char) to the parser. */
                        PRINTF("%s\n", yytext); // Debug
                        return yytext[0];
                    }

%%