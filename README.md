# MiniNim
This project seeks to implement a compiler for a tiny subset of the **Nim Programming Language** which we call MiniNim. The compiler outputs a MIPS Assembly code which can be run in simulators like MARS.

## Features Covered
We included the following features in MiniNim:
- **Data Types:** Double Precision Floating Point (`float`) and Integers (`int`) and their arrays (multidimensional arrays are allowed). Note that we have implemented the standard Nim array which is very much like the C array, so the size/dimensions of the array has to be known at compile time.
- **Variable Declaration:** Variable declaration using the `var` keyword is supported. You can also assign values while declaring the variables. Do note that in MiniNim, specifying the type of the variable during declaration is a must unlike Nim.
- **Conditional Statement:** The `if`, `elif` and `else` construct.
- **Relational Operators:** Equals (`==`), Not Equals (`!=`), Greater Than or Equal (`>=`), Less Than or Equal (`<=`), Greater Than (`>`) and Less Than (`<`).
- **Boolean Logic:** `and`, `or`, `xor` and `not` are allowed in condition expressions in conditional statements. These are short-circuit boolean operators. Note that the boolean literals `true` and `false` can also be used in condition expressions.
- **Basic Arithmetic:** Addition (`+`), Subtraction (`-`), Multiplication (`*`), Float Division (`/`), Integer Division (`div`), Modulus (`mod`), Unary Minus and Plus. Bitwise `and`, `or` and `xor` is also supported on integer operands. `+`, `-`, `/` and `*` do implicit type conversion from `int` to `float` if one of the operands is `float`.
- **Assignment Operation:** Assignment (`=`) of values to variables and array indices. Note that the array has to be fully dereferenced before any assignments are made. This does implicit type casting from `int` to `float` if the RHS is an `int` but LHS is a `float`.
- **For Loop:** The For Loop (`for`) iterates over values specified in the slice syntax (`..`) only (no iteration over arrays). 
- **While Loop:** The usual While Loop (`while`) syntax as in Nim.
- **Break and Continue Statements:** Break (`break`) and Continue (`continue`) which breaks or continues the innermost loop respectively. No labels can be specified as in Nim because MiniNim does not have named Blocks (`block`).
- **Scoping of Variables:** The body of `if`, `elif`, `else`, `while` and `for` open a new scope and variables declared here are not visible in outer scope. Also, a variable with the same name as one present in outer scope can be declared and used throughout the inner scope. 
- **Input:** Since functions are not yet covered by MiniNim, we define a `readInt` command which reads an integer into a variable and a `readFloat` command which reads a floating point number into a variable. Note that the equivalents of these can easily be defined in standard Nim as done in `mininim_compat.nim` whose use is explained in the Compatibility With Nim section. 
- **Output:** The `echo` command as present in Nim can be used. Along with printing `float` and `int` types, printing string literals (`string`) is also supported. Note that array types cannot be printed without fully dereferencing/resolving to `float` or `int`. 
- **Comments:** Single line comments (starting with `#`) are supported in MiniNim. 

## Compatibility with Nim
Most of the code which runs on MiniNim will run the same way in standard Nim compiler with the following exceptions:
- Nim does not do implicit type casting from `float` to `int` for variables but we do it because we need function call syntax (which is not yet implemented in MiniNim) to achieve explicit conversion. To run such code on the standard Nim compiler, just make all type conversions explicit.
- Nim does not have `readInt` and `readFloat` commands but to run our examples in the Nim Compiler you can put the `mininim_compat.nim` in the directory where you are running the file and write `import mininim_compat` at the beginning of the file to add these commands to the standard Nim compiler.

## Usage
### How to Build MiniNim Compiler
To build MiniNim compiler, just run `make` in the terminal in the root directory of this project. The executable `mininim` is created in the root directory. 

### How to Use MiniNim
To compile a file (suppose `example.nim`), just run `./mininim example.nim` in the terminal in the root directory of the projects. An assembly file of the same name is created in the same directory as the source file (`example.asm` is generated in this case). If you want to run the file, run `./mininim run mininim.nim` in the terminal (The `.asm` file is executed using Mars simulator).

**Note:** Do ensure that the file extension is `.nim`, as for now we have assumed this in our code for generating the assembly file with the same name.

### Example Programs
There are several sample programs provided in the `examples/` directory which illustrate what MiniNim is capable of. The following tasks are demonstrated:
- `Codeforces_576A.nim`: Solves Codeforces Problem A from Codeforces Round #576 (Div. 2).
- `factorial.nim`: Prints factorials of numbers from 1 to a given number.
- `fibonacci.nim`: Prints the first `n` terms of Fibonacci sequence for given `n`.
- `fizzbuzz.nim`: Implements Fizz Buzz.
- `knapsack.nim`: Solves the Knapsack Problem for given input using Dynamic Programming.
- `nimgame.nim`: Gives the winner of Nim Game played between Alice and Bob for given configuration.
- `sieve.nim`: Printing all primes upto a given number using the Sieve of Eratosthenes.
- `sqrt.nim`: Finding square root of a number using binary search.

## Implementation Overview
The formal description, token and grammar are based on the Nim Manual. 
### Lexing
The lexing has been done using Flex library. Since Nim is indentation scoped, there are additional things to deal with. The indentation information is captured by generating tokens. So, when the indentation increases compared to the previous line the token `INDG` is generated, when the indentation remains same as the previous line, `INDEQ` is generated and when the indentation level decreases (dedents) as compared to the previous line,`DED` is generated. Do note that like Nim, MiniNim also doesn't support the use of tabs in source code which simplifies the implementation. Since you also need to know by how much the indentation level decreases, we have to maintain a stack of indentation levels (i.e. number of spaces that make up the indent). For doing this in Flex start conditions are used.

Now, we give the the regular definitions used. The identifiers in Nim have to start with a letter and then can contain letters, digits and underscores but 2 underscores cannot occur together.
```
letter [A-Za-z]
digit [0-9] 
IDENT {letter}("_"?({letter}|{digit}))*
```
The below regular defninitions are self-explanatory.
```
INTLIT {digit}+
STRLIT \"[^"\n]*\"
CHARLIT \'.\'
FLOATLIT {digit}+"."{digit}+
BOOLLIT true|false
```
Additionally, the following keywords have been defined and caught in the Lexer and will not be matched with any identifier. 

```
KEYW break|continue|elif|else|for|if|in|var|while|array|echo|readInt|readFloat|nil|proc|return|tuple|type
```
### Parsing
The following is the grammar written in BNF form which has been fed into Bison.

The top level rule is `module` which is a sequence of complex or simple statements.
```
module: complexOrSimpleStmt
      | module2 INDEQ complexOrSimpleStmt 
      | %empty

module2: module2 INDEQ complexOrSimpleStmt 
       | complexOrSimpleStmt  

comma: ","

colon: ":"         
```
`expr` rule defines all expressions allowed.
```
expr: sExpr

sExpr: sExpr "xor" sExpr        
     | sExpr "or" sExpr      
     | sExpr "and" sExpr     
     | sExpr "!=" sExpr      
     | sExpr ">" sExpr       
     | sExpr ">=" sExpr      
     | sExpr "<" sExpr       
     | sExpr "<=" sExpr      
     | sExpr "==" sExpr      
     | sExpr "-" sExpr       
     | sExpr "+" sExpr       
     | sExpr "mod" sExpr     
     | sExpr "div" sExpr     
     | sExpr "/" sExpr     
     | sExpr "*" sExpr      
     | "+" sExpr 
     | "-" sExpr
     | "not" sExpr        
     | "(" sExpr ")"
     | primary               

primary: identOrLiteral
       | identOrLiteral arrayDeref 
```
A symbol has to be an identifier.
```
symbol: IDENT      
```
The `echo` statement need to be followed by `echoexprList` which is a list of expressions.
```
echoexprList: echoexprList comma expr 
            | expr                      

literal: BOOLLIT   
       | INTLIT   
       | FLOATLIT  
       | STRLIT 
       | CHARLIT 
       | "nil" 

identOrLiteral: symbol
              | literal   
```
An array type declaration starts with the string "array" followed by the size of array (an integer) and the type of element in the array. 
```
arrayDecl: "array" "["  INTLIT comma typeDesc "]"   
```
The basic for statement syntax is defined by the rule `forStmt`.
```
forStmt: "for"  symbol  "in" expr ".." expr colonBody 
```
The `arrayDeref` rule describes the series of dereferencing or element access of an array and captures what are the indices for each dimension of the array. 
```                                              
arrayDeref: arrayDeref "[" expr "]"
          | "[" expr "]"
```
A type description (`typeDesc`) is either a symbol (`int` and `float` are identifiers so that later this rule could be used to support user type definitions) or an array type declaration. 
```
typeDesc: symbol
        | arrayDecl
```
An expression statement (`exprStmt`) is either an assignment to a variable or an array element.
```
exprStmt: symbol "=" expr
        | symbol arrayDeref "=" expr
        | symbol "+=" expr 
        | symbol "*=" expr
```
The break and continue statements are caputured by these really simple rules.
```
breakStmt: "break"

continueStmt: "continue"    
```
The if-elif-else construct is captured by the rule `ifStmt` which says that after the keyword `if`, the condition expression and its body there is a optional sequence of `elif` statements with their bodies followed by a single optional optional `else` statement with body.
```
ifStmt: "if" expr colonBody elifCondStmt
      | "if" expr colonBody elifCondStmt "else" colonBody 
      | "if" expr colonBody 
      | "if" expr colonBody "else" colonBody     

elifCondStmt: elifCondStmt "elif" expr colonBody 
            | "elif" expr colonBody
```
A while statement (`whileStmt`) is simply the keyword `while` folowed by an expression and then the body of code.
```
whileStmt: "while" expr colonBody   
```
`colonBody` rule simply describes a colon followed by a body of code (`stmt`).
```
colonBody: colon stmt 
```
This describes a variable declaration section after the `var` keyword. 
```
secVariable: variable
           | INDG variable serVariable DED

variable: symbol ":"  typeDesc "=" expr 
        | symbol ":"  typeDesc

serVariable: serVariable INDEQ variable   
           | %empty
```
A simple statement (`simpleStmt`) can be written in a single line after a colon in the `for`, `if` and `while` statements. The rule `complexOrSimpleStmt` captures all the forms of statements possible. 
```
simpleStmt: breakStmt           
          | continueStmt       
          | exprStmt          

complexOrSimpleStmt: ifStmt
                   | whileStmt
                   | forStmt 
                   | "echo" echoexprList
                   | "var" secVariable
                   | "readInt" symbol
                   | "readInt" symbol arrayDeref
                   | "readFloat" symbol
                   | "readFloat" symbol arrayDeref 
                   | simpleStmt

```
The `stmt` rule describes the body of `if`, `while` and `for` statements. The body of code is either a simple statement in the same line or a series of simple or complex statements in an indented block (i.e. surrounded by `INDG` and `DED`).
```
stmt: simpleStmt
    | INDG stmt2 complexOrSimpleStmt DED 

stmt2: stmt2 complexOrSimpleStmt INDEQ 
```
The parser generates an Intermediate Code directly without going through the AST generation phase. Since this way of code generation denies us the use of inherited attributes, backpatching has to be used to handle the short circuiting mechanics in the boolean expression as well as the break and continue statements since we do not know the label to jump to when the code for the jumps is generated for these cases.
### Machine Code Generation
The conversion from IR to MIPS assembly code happens through the invocation of `asmgen.py`. It does no register allocation and just has various macros set for various IR instructions. It also replaces all backpatch labels with the real label values. Data placement is also done at this stage. 
## Future Work
Here are some features that could be added later to increase the scope of this project:
- Implement functions
- Add support for strings and string operations
- Add more datatypes like enum, tuple and object
- Add support for imports
- Implement blocks (`block`)
- Add `ref`, `ptr` and garbage collection
- Register Allocation
- Machine Independent and Dependent Optimizations

Another interesting direction would be to try to rewrite this completely in a higher level language like C++ or Python using some other library to make life simpler through the use of Object Oriented Programming and better string manipulation. 

## Contributors
- Kishen Gowda (17110074)
- Vraj Patel (17110174)
- Mrinal Anand (17110087)