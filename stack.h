#include <stdio.h>
#include <stdlib.h>

typedef struct nd{
	int value;
	struct nd* next;
}node;

node * getnode(){
	return (node *) malloc(sizeof(node));
}

int pop(node ** head){
	node * cur = *head;
	int val;
	if(cur == NULL){
		printf("Stack Empty");
		return -1;
	}
	else{
		val = cur->value;
		*head = cur->next;
		free(cur);
		return val;
	}
}

void push(node ** head,int val){
	node * nn = getnode();
	nn->next = *head;
	nn->value = val;
	*head = nn;
}

extern node *indent_stack;

// int main(){
// 	node * head = NULL;
// 	printf("%d\n",pop(&head));
// 	push(&head,10);
// 	push(&head,1);
// 	push(&head,40);
// 	push(&head,1);
// 	push(&head,20);
// 	push(&head,30);
// 	printf("%d\n",pop(&head));
// 	printf("%d\n",pop(&head));
// 	printf("%d\n",pop(&head));
// 	printf("%d\n",pop(&head));
// 	printf("%d\n",pop(&head));
// 	printf("%d\n",pop(&head));
// 	printf("%d\n",pop(&head));
// 	printf("%d\n",pop(&head));
// }