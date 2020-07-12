%{
#include "symrec.h"
#include "nim.tab.h"
#include "stack.h"
#include <string.h>

node *indent_stack = NULL;

int g_current_line_indent = 0;   /* indentation of the current line */
int g_is_fake_outdent_symbol = 0;

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
#define LEXER_DEBUG
#ifdef LEXER_DEBUG
#define PRINTF(...) printf(__VA_ARGS__)
#endif
#ifndef LEXER_DEBUG
#define PRINTF(...)
#endif

%}

%x initial
%x indent
%s normal

 /* %option 8bit reentrant bison-bridge */
%option warn
%option nodefault
%option yylineno
%option noyywrap

OP \$|\^|\*|\/|div|mod|\%|\+|\-|\&|\.\.|==|<=|<|>=|>|!=|not|and|or|xor|\+=|\*=|=
KEYW break|continue|elif|else|for|if|in|nil|proc|return|tuple|type|var|while|array|echo|readInt|readFloat

letter [A-Za-z]
digit [0-9] 
IDENT {letter}("_"?({letter}|{digit}))*

INTLIT {digit}+
STRLIT \"[^"]*\"
CHARLIT \'.\'
FLOATLIT {digit}+"."{digit}+
BOOLLIT true|false

%%
    int indent_caller = normal;


<*>\n { set_yycolumn(0); yylineno--; 
      // PRINTF("REJECT\n"); 
      REJECT; }
<initial>.  { set_yycolumn(yycolumn-1); indent_caller = normal; yyless(0); 
            //  PRINTF("initial .\n");
             BEGIN(indent); }
<initial>\n { indent_caller = normal; yyless(0); BEGIN(indent);
            //   PRINTF("initial \\n"); 
            }
<indent>" "     { g_current_line_indent++; 
                // PRINTF("Indent space\n");
                }
<indent>\n      { g_current_line_indent = 0; 
                // PRINTF("Indent \\n\n");
                /* ignoring blank line */ }
<indent><<EOF>> {   
                    // PRINTF("\nEOF");
                    // When encountering the end of file, we want to emit an
                    // outdent for all indents currently left.
                    if(indent_stack->value != 0) {
                        pop(&indent_stack);

                        // See the same code below (<indent>.) for a rationale.
                        if(g_current_line_indent != indent_stack->value) {
                            unput('\n');
                            for(size_t i = 0 ; i < indent_stack->value ; ++i) {
                                unput(' ');
                            }
                        } else {
                            BEGIN(indent_caller);
                        }
                        return DED;
                    } else {
                        yyterminate();
                    }
                }

<indent>.       {   
                    // PRINTF("Indenter Entry\n");
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
                            // PRINTF("This IF\n");
                            for(size_t i = 0 ; i < g_current_line_indent ; ++i) {
                                unput(' ');
                            }
                            unput('\n');
                            unput('.');
                            g_is_fake_outdent_symbol = 1;
                            // for(size_t i = 0 ; i < indent_stack->value ; ++i) {
                            //     unput(' ');
                            // }
                            // unput('\n');
                        } else {
                            // PRINTF("That IF\n");
                            // BEGIN(indent_caller);
                        }
                        PRINTF("DED\n");
                        return DED;
                    } else {
                        BEGIN(indent_caller);
                    }
                }

<normal>\n    {
                // PRINTF("NORMAL \n"); 
                g_current_line_indent = 0; indent_caller = YY_START; BEGIN(indent); }

<normal><<EOF>> {
                // PRINTF("NORMAL \n"); 
                g_current_line_indent = 0; indent_caller = YY_START; BEGIN(indent); }

<normal>{OP}        {PRINTF("OP\n");if(strcmp("$",yytext)==0){return '$';}
                     else if(strcmp("*",yytext)==0){return '*';}
                     else if(strcmp("/",yytext)==0){return '/';}
                     else if(strcmp("div",yytext)==0){return DIV;}
                     else if(strcmp("mod",yytext)==0){return MOD;}
                     else if(strcmp("\%",yytext)==0){return '\%';}
                     else if(strcmp("+",yytext)==0){return '+';}
                     else if(strcmp("-",yytext)==0){return '-';}
                     else if(strcmp("&",yytext)==0){return '&';}
                     else if(strcmp("..",yytext)==0){return SLICE;}
                     else if(strcmp("==",yytext)==0){return EQ;}
                     else if(strcmp("<=",yytext)==0){return LE;}
                     else if(strcmp("<",yytext)==0){return '<';}
                     else if(strcmp(">=",yytext)==0){return GE;}
                     else if(strcmp(">",yytext)==0){return '>';}
                     else if(strcmp("!=",yytext)==0){return NE;}
                     else if(strcmp("not",yytext)==0){return NOT;}
                     else if(strcmp("and",yytext)==0){return AND;}
                     else if(strcmp("or",yytext)==0){return OR;}
                     else if(strcmp("xor",yytext)==0){return XOR;}
                     else if(strcmp("+=",yytext)==0){return PEQ;}
                     else if(strcmp("*=",yytext)==0){return MEQ;}
                     else if(strcmp("=",yytext)==0){return '=';}
                    }
<normal>{KEYW}      {PRINTF("KeyW\n");if(strcmp("break",yytext)==0){return BREAK;}
                     else if(strcmp("continue",yytext)==0){return CONTINUE;}
                     else if(strcmp("elif",yytext)==0){return ELIF;}
                     else if(strcmp("else",yytext)==0){return ELSE;}
                     else if(strcmp("for",yytext)==0){return FOR;}
                     else if(strcmp("if",yytext)==0){return IF;}
                     else if(strcmp("in",yytext)==0){return IN;}
                     else if(strcmp("nil",yytext)==0){return NIL;}
                     else if(strcmp("proc",yytext)==0){return PROC;}
                     else if(strcmp("return",yytext)==0){return RETURN;}
                     else if(strcmp("tuple",yytext)==0){return TUPLE;}
                     else if(strcmp("type",yytext)==0){return TYPE;}
                     else if(strcmp("var",yytext)==0){return VAR;}
                     else if(strcmp("while",yytext)==0){return WHILE;}
                     else if(strcmp("echo",yytext)==0){return ECHOP;}
                     else if(strcmp("readInt",yytext)==0){return RDINT;}
                     else if(strcmp("readFloat",yytext)==0){return RDFLT;}
                    }

<normal>{INTLIT}      {sscanf(yytext,"%d",&yylval.integer);PRINTF("Int\n");return INTLIT;}

<normal>{FLOATLIT}    {sscanf(yytext,"%lf",&yylval.floater);PRINTF("Float\n");return FLOATLIT;}

<normal>{STRLIT}      {yylval.str = strdup(yytext);PRINTF("String\n");return STRLIT;}

<normal>{BOOLLIT}     {if (yytext[0]=='t') {yylval.integer = 1;} else {yylval.integer = 0;} PRINTF("Bool\n");return BOOLLIT;}

<normal>{IDENT}       {yylval.str = strdup(yytext);PRINTF("IDENT\n");return IDENT;}

<normal>[ ]+          /* eat up whitespace */

<normal>.              {PRINTF("%s\n", yytext);return yytext[0];}

%%
// {number} {sscanf(yytext,"%lf",&yylval.val);return NUM;}
// {id} {symrec *s;s=getsym(yytext); if(s==0) s=putsym(yytext,VAR);yylval.tptr=s;return s->type;}
// \n|.  {return yytext[0];}

// "+"|"-"|"*"|"/"   printf( "An operator: %s\n", yytext );

// "{"[^}\n]*"}"     /* eat up one-line comments */

/* The symbol table: a chain of `struct symrec'.  */

// symrec * putsym (char *sym_name,int sym_type){
//   symrec *ptr;
//   ptr = (symrec *) malloc (sizeof (symrec));
//   ptr->name = (char *) malloc (strlen (sym_name) + 1);
//   strcpy (ptr->name,sym_name);
//   ptr->type = sym_type;
//   ptr->value.var = 0; /* set value to 0 even if fctn.  */
//   ptr->next = (struct symrec *)sym_table;
//   sym_table = ptr;
//   return ptr;
// }

// symrec *getsym (char *sym_name){
//   symrec *ptr;
//   for (ptr = sym_table; ptr != (symrec *) 0;
//        ptr = (symrec *)ptr->next)
//     if (strcmp (ptr->name,sym_name) == 0)
//       return ptr;
//   return 0;
// }