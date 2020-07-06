%{
#include "nim.tab.h"
#include "symrec.h"
#include "stack.h"

symrec *sym_table = (symrec *)0;
node *indent_stack = NULL;

int g_current_line_indent = 0;   /* indentation of the current line */
int g_is_fake_outdent_symbol = 0;

#define YY_USER_INIT { \
        push(&indent_stack,0); \
        BEGIN(initial); \
    }

int yycolumn = 1;
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
%}

%x initial
%x indent
%s normal

 /* %option 8bit reentrant bison-bridge */
%option warn
%option nodefault
%option yylineno
%option noyywrap

OP10 \$|\^
OP9 \*|\/|div|mod|shl|shr|\%
OP8 \+|\-
OP7 \&
OP6 \.\.
OP5 ==|<=|<|>=|>|!=|in|notin|is|isnot|not|of|as
OP4 and
OP3 or|xor
OP1 \+=|\*=|=
KEYW addr|and|as|block|break|cast|const|int|float|bool|string|chasr|continue|elif|else|end|enum|for|if|in|is|isnot|let|mod|nil|not|notin|object|of|or|proc|return|tuple|type|using|var|when|while|xor

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


<*>\n { set_yycolumn(0); yylineno--; REJECT; }
<initial>.  { set_yycolumn(yycolumn-1); indent_caller = normal; yyless(0); BEGIN(indent); }
<initial>\n { indent_caller = normal; yyless(0); BEGIN(indent); }
<indent>" "     { g_current_line_indent++; }
<indent>\n      { g_current_line_indent = 0; /* ignoring blank line */ }
<indent><<EOF>> {
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
                    if(!g_is_fake_outdent_symbol) {
                        unput(*yytext);
                    }
                    set_yycolumn(yycolumn-1);
                    g_is_fake_outdent_symbol = 0;
                    if(g_current_line_indent > indent_stack->value) {
                        push(&indent_stack,g_current_line_indent);
                        BEGIN(indent_caller);
                        return INDG;
                    } else if (g_current_line_indent == indent_stack->value) {
                        BEGIN(indent_caller);
                        return INDEQ;
                    } else if(g_current_line_indent < indent_stack->value) {
                        pop(&indent_stack);
                        if(g_current_line_indent != indent_stack->value) {
                            for(size_t i = 0 ; i < g_current_line_indent ; ++i) {
                                unput(' ');
                            }
                            unput('\n');
                            unput('.');
                            g_is_fake_outdent_symbol = 1;
                            for(size_t i = 0 ; i < indent_stack->value ; ++i) {
                                unput(' ');
                            }
                            unput('\n');
                        } else {
                            BEGIN(indent_caller);
                        }

                        return DED;
                    } else {
                        BEGIN(indent_caller);
                    }
                }

<normal>\n    { g_current_line_indent = 0; indent_caller = YY_START; BEGIN(indent); }

<normal>{OP10}        {}

<normal>{OP9}         {}

<normal>{OP8}         {}

<normal>{OP7}         {}

<normal>{OP6}         {}

<normal>{OP5}         {}

<normal>{OP4}         {}

<normal>{OP3}         {}

<normal>{OP1}         {}

<normal>{KEYW}        

<normal>{INTLIT}      {sscanf(yytext,"%d",&yylval.integer);return INTLIT;}

<normal>{FLOATLIT}    {sscanf(yytext,"%lf",&yylval.floater);return FLOATLIT;}

<normal>{STRLIT}      {sscanf(yytext,"%s",yylval.str);return STRLIT;}

<normal>{BOOLLIT}     {if (yytext[0]=='t') {yylval.integer = 1;} else {yylval.integer = 0;} return BOOLLIT;}

<normal>{IDENT}       {sscanf(yytext,"%s",yylval.str);return IDENT;}

<normal>[ ]+          /* eat up whitespace */

<normal>.              {printf( "Unrecognized character: %s\n", yytext );}

%%
// {number} {sscanf(yytext,"%lf",&yylval.val);return NUM;}
// {id} {symrec *s;s=getsym(yytext); if(s==0) s=putsym(yytext,VAR);yylval.tptr=s;return s->type;}
// \n|.  {return yytext[0];}

// "+"|"-"|"*"|"/"   printf( "An operator: %s\n", yytext );

// "{"[^}\n]*"}"     /* eat up one-line comments */

/* The symbol table: a chain of `struct symrec'.  */

symrec * putsym (char *sym_name,int sym_type){
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof (symrec));
  ptr->name = (char *) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name,sym_name);
  ptr->type = sym_type;
  ptr->value.var = 0; /* set value to 0 even if fctn.  */
  ptr->next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}

symrec *getsym (char *sym_name){
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
    if (strcmp (ptr->name,sym_name) == 0)
      return ptr;
  return 0;
}