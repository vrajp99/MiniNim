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

typedef enum{
    BASIC_TYPE,
    ARRAY_TYPE
} meta_type;

typedef enum{
  False,
  True
} bool;

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
  meta_type aux_type;
  int is_ident;
} idorlit;

/* Data type for links in the chain of symbols.      */
typedef struct symrec{
  char *name;  /* name of symbol */
  char *alias;
  int scope;
  bool is_copy;
  var_type type;   /* type of symbol: either VAR or FNCT */
  meta_type aux_type;
  int arr_data[10];
  int arr_size;
  int width;
  struct symrec *prev;    /* link field */
} symrec;

typedef struct sdd{
  char *code;
  char *next;
  char *addr;
  var_type type;
  meta_type aux_type;
  bp_node *truelist;
  bp_node *falselist;
  bp_node *nextlist;
  bp_node *breaklist;
} sdd;

typedef struct arr_deref{
  char *code;
  int arr_size;
  char* arr_data[10];
} arr_deref;

/* The symbol table: a chain of `struct symrec'.     */
extern symrec *sym_table;
void putsym(char*,var_type);
symrec* getsym(char *);
int *func();

#endif // __symrec_h__