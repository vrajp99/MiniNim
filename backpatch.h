#ifndef __backpatch_h__
#define __backpatch_h__
#include <stdio.h>
#include <stdlib.h>

typedef struct bp_node {
    char *temp_label;
    char *bp_label;
    struct bp_node *prev;
} bp_node;

bp_node *create_bp(char *);
bp_node *merge(bp_node *, bp_node *);
void backpatch(bp_node *, char *);
void print_list(bp_node *);
// void dump_list(FILE *);
#endif // __backpatch_h__