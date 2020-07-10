#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

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

int main(){
    dump_IR("Hahaha\nhahahah\nhohoho");
    return 0;
}