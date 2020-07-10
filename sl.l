%{
#include "calc.tab.h"
#include "calc.h"

symrec *sym_table = (symrec *)0;
%}
number [0-9]+\.?|[0-9]*\.[0-9]+
id [a-z]+
%%
[ ] {}
{number} {sscanf(yytext,"%lf",&yylval.val);return NUM;}
{id} {symrec *s;s=getsym(yytext); if(s==0) s=putsym(yytext,VAR);yylval.tptr=s;return s->type;}
\n|.  {return yytext[0];}
%%

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