typedef enum Node_Type {
	BASIC_NODE,   //  0 - no special usage (for roots only)
	// declarations
	DECLARATIONS, //  1 - declarations
	DECL_NODE,    //  2 - declaration
	CONST_NODE,   //  3 - constant
	// statements
	STATEMENTS,   //  4 - statements
	IF_NODE,      //  5 - if statement
	ELIF_NODE,   //  6 - else if branch
    ELSE_NODE,
	FOR_NODE,     //  7 - for statement
	WHILE_NODE,   //  8 - while statement
	ASSIGN_NODE,  //  9 - assigment
	SIMPLE_NODE,  // 10 - continue or break statement
	INCR_NODE,    // 11 - increment statement (non-expression one)
	FUNC_CALL,    // 12 - function call
	CALL_PARAMS,  // 13 - function call parameters
	// expressions
	ARITHM_NODE,  // 14 - arithmetic expression
	REF_NODE,	  // 18 - identifier in expression
	// functions
	FUNC_DECLS,   // 19 - function declarations
	FUNC_DECL,    // 20 - function declaration
	RET_TYPE,     // 21 - function return type
	DECL_PARAMS,  // 22 - function parameters
	RETURN_NODE,  // 23 - return statement of functions
}Node_Type;

typedef enum Expr_op{
	ADD,  // + operator
	SUB,  // - operator
	MUL,  // * operator
	DIV, // / operator
    NOT,
    DOLLAR,
    GREQ,
    GR,
    LTEQ,
    LT,
    EQEQ,
    SLICE,
    NEQ
}Expr_op;

typedef enum Assign_op{
    ADDEQ,
    EQ,
    MULEQ
}Assign_op;


/* The basic node */
typedef struct AST_Node{
	enum Node_Type type; // node type
	
	struct AST_Node *left;  // left child
	struct AST_Node *right; // right child
}AST_Node;

/* Statements */
typedef struct AST_Node_Statements{
	enum Node_Type type; // node type
	
	// statements
	struct AST_Node **statements;
	int statement_count;
}AST_Node_Statements;

typedef struct AST_Node_If{
	enum Node_Type type; // node type
	
	// condition
	struct AST_Node *condition;
	
	// if branch
	struct AST_Node *if_branch;
	
	// else if branches
	struct AST_Node **elif_branches;
	int elif_count;
	
	// else branch
	struct AST_Node *else_branch;
}AST_Node_If;

typedef struct AST_Node_Elif{
	enum Node_Type type; // node type
	
	// condition
	struct AST_Node *condition;
	
	// branch
	struct AST_Node *elif_branch;
}AST_Node_Elif;

typedef struct AST_Node_For{
	enum Node_Type type; // node type
	
	// initialization
	struct AST_Node *initialize;
	
	// condition
	struct AST_Node *condition;
	
	// incrementation
	struct AST_Node *increment;
	
	// branch
	struct AST_Node *for_branch;
	
	// loop counter
	list_t *counter;
}AST_Node_For;

typedef struct AST_Node_While{
	enum Node_Type type; // node type
	
	// condition
	struct AST_Node *condition;
	
	// branch
	struct AST_Node *while_branch;
}AST_Node_While;

typedef struct AST_Node_Assign{
	enum Node_Type type; // node type
	
	// symbol table entry
	list_t *entry;

	// assignment value
	struct AST_Node *assign_val;
}AST_Node_Assign;
