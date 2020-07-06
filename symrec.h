/* Data type for links in the chain of symbols.      */
typedef struct symrec{
  char *name;  /* name of symbol                     */
  int type;   /* type of symbol: either VAR or FNCT */
  union {
    double var;           /* value of a VAR          */
    double (* fptr)();    /* Function Value        */
  } value;
  struct symrec *next;    /* link field              */
} symrec;

/* The symbol table: a chain of `struct symrec'.     */
extern symrec *sym_table;

symrec *putsym ();
symrec *getsym ();
int *func();