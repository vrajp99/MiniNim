#ifndef __symrec_h__
#define __symrec_h__
#include "backpatch.h"
typedef enum{
    INT_TYPE,
    FLOAT_TYPE,
    BOOL_TYPE,
    STR_TYPE,
    CHAR_TYPE
} var_type;

typedef struct literal{
  union value{
    int ival;
    double fval;
    char cval;
    char *sval;
    int bval;
    char* name;
  } value;
  var_type type;
  int is_ident;
} idorlit;

/* Data type for links in the chain of symbols.      */
typedef struct symrec{
  char *name;  /* name of symbol */
  int scope;
  var_type type;   /* type of symbol: either VAR or FNCT */
  struct symrec *next;    /* link field */
} symrec;

typedef struct sdd{
  char *code;
  char *next;
  char *addr;
  bp_node *truelist;
  bp_node *falselist;
  bp_node *nextlist;
} sdd;

/* The symbol table: a chain of `struct symrec'.     */
extern symrec *sym_table;

symrec *putsym ();
symrec *getsym ();
int *func();

#endif // __symrec_h__