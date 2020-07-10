/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.4"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 5 "nim.y" /* yacc.c:339  */

#include<stdio.h>
#include<string.h>
#include<stdlib.h> 
#include <stdarg.h>
#include <math.h>
#include "backpatch.h"
#include "symrec.h"  /* Contains definition of `symrec" */
int  yylex(void);
void yyerror (char  *); 
FILE *yyin;
int curr_scope = 0;
symrec *sym_table = (symrec *)0;
char* new_label();
char* new_temp();
char* new_bplabel();
char* sc(char * s1, char *s2);
char* scc(int num,...);
void dump_IR(char *);
char boolean[2][10] = {"false","true"};
char* putl(char * s){
    return sc(s,":\n");
}
bp_node *create_bp(char * temp_label) {
    bp_node *v = (bp_node *) malloc(sizeof(bp_node));
    v->temp_label = temp_label;
    v->bp_label = NULL;
    v->prev = NULL;
    return v;
}

bp_node *merge(bp_node *l1, bp_node *l2){
    if (l1==NULL) return l2;
    if (l2==NULL) return l1;
    bp_node *temp = l1;
    while (temp->prev != NULL) temp = temp->prev;
    temp->prev = l2;
    return l1;    
}

void backpatch(bp_node *l, char *bp_label){
    if (l==NULL) return;
    l->bp_label = bp_label;
    backpatch(l->prev, bp_label);
}

void print_list(bp_node* l){
    if (l==0) return;
    if (l->bp_label == NULL){
        printf("Internal Warning: Null Label Found for backpatch label: %s", l->temp_label);
    } else {
        printf("%s   %s\n", l->temp_label, l->bp_label);
        print_list(l->prev);
    }
}


bp_node* globaltruelist = NULL;
bp_node* globalfalselist = NULL;
bp_node* globalnextlist = NULL;
char * final_IR;

#line 129 "nim.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* In a future release of Bison, this section will be replaced
   by #include "nim.tab.h".  */
#ifndef YY_YY_NIM_TAB_H_INCLUDED
# define YY_YY_NIM_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INTLIT = 258,
    FLOATLIT = 259,
    STRLIT = 260,
    CHARLIT = 261,
    BOOLLIT = 262,
    IDENT = 263,
    INDG = 264,
    INDEQ = 265,
    DED = 266,
    BREAK = 267,
    CONTINUE = 268,
    ELIF = 269,
    ELSE = 270,
    FOR = 271,
    IF = 272,
    IN = 273,
    NIL = 274,
    PROC = 275,
    RETURN = 276,
    TUPLE = 277,
    TYPE = 278,
    VAR = 279,
    WHILE = 280,
    IFX = 281,
    ELSEX = 282,
    XOR = 283,
    OR = 284,
    AND = 285,
    NE = 286,
    GE = 287,
    LE = 288,
    EQ = 289,
    SLICE = 290,
    MOD = 291,
    DIV = 292,
    NOT = 293,
    PEQ = 294,
    MEQ = 295,
    UPLUS = 296,
    UMINUS = 297,
    LPAREN = 298
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 68 "nim.y" /* yacc.c:355  */

int integer;
double floater;  /* For returning numbers.                   */
char *str;
char ch;
idorlit idl;
// symrec  *tptr;   /* For returning symbol-table pointers      */
sdd s_tree;

#line 223 "nim.tab.c" /* yacc.c:355  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;
extern YYLTYPE yylloc;
int yyparse (void);

#endif /* !YY_YY_NIM_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 254 "nim.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL \
             && defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
  YYLTYPE yyls_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE) + sizeof (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  67
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   525

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  61
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  45
/* YYNRULES -- Number of rules.  */
#define YYNRULES  117
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  216

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   299

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,    48,    45,     2,     2,
      54,    55,    47,    44,    52,    43,    58,    46,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    53,     2,
      42,    60,    41,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    56,     2,    57,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    49,    50,    51,    59
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   156,   156,   163,   173,   175,   182,   187,   189,   191,
     212,   220,   228,   235,   242,   249,   256,   263,   270,   271,
     277,   283,   289,   295,   301,   307,   313,   319,   325,   326,
     331,   337,   345,   351,   352,   354,   356,   358,   360,   362,
     364,   366,   370,   378,   379,   381,   383,   385,   386,   387,
     388,   390,   392,   394,   395,   397,   398,   400,   402,   404,
     406,   407,   409,   410,   412,   413,   414,   416,   417,   419,
     420,   427,   428,   462,   463,   465,   466,   467,   474,   475,
     476,   477,   484,   485,   487,   489,   491,   492,   493,   500,
     512,   515,   520,   522,   523,   528,   533,   539,   540,   542,
     543,   545,   546,   548,   549,   550,   551,   553,   554,   555,
     556,   557,   558,   559,   561,   562,   570,   577
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "INTLIT", "FLOATLIT", "STRLIT",
  "CHARLIT", "BOOLLIT", "IDENT", "INDG", "INDEQ", "DED", "\"break\"",
  "\"continue\"", "\"elif\"", "\"else\"", "\"for\"", "\"if\"", "\"in\"",
  "\"nil\"", "\"proc\"", "\"return\"", "\"tuple\"", "\"type\"", "\"var\"",
  "\"while\"", "IFX", "ELSEX", "\"xor\"", "\"or\"", "\"and\"", "\"!=\"",
  "\">=\"", "\"<=\"", "\"==\"", "\"..\"", "\"mod\"", "\"div\"", "\"not\"",
  "\"+=\"", "\"*=\"", "'>'", "'<'", "'-'", "'+'", "'%'", "'/'", "'*'",
  "'$'", "UPLUS", "UMINUS", "LPAREN", "','", "':'", "'('", "')'", "'['",
  "']'", "'.'", "\"array\"", "'='", "$accept", "module", "module2",
  "comma", "colon", "sExpr", "symbol", "exprList", "literal",
  "identOrLiteral", "tupleConstr", "arrayConstr", "primarySuffix",
  "ifExpr", "condExpr", "elifCondExpr", "symbolCommaNoHang", "declColon",
  "inlTupleDecl", "arrayDecl", "paramList", "declColonCommaNoHang",
  "paramListColon", "forStmt", "expr", "primary", "primary2", "typeDesc",
  "exprStmt", "returnStmt", "breakStmt", "continueStmt", "ifStmt",
  "elifCondStmt", "whileStmt", "routine", "typeDef", "colonBody",
  "variable", "secVariable", "serVariable", "simpleStmt",
  "complexOrSimpleStmt", "stmt", "stmt2", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,    62,    60,    45,    43,    37,    47,    42,    36,   296,
     297,   298,    44,    58,    40,    41,    91,    93,    46,   299,
      61
};
# endif

#define YYPACT_NINF -152

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-152)))

#define YYTABLE_NINF -7

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     206,  -152,  -152,  -152,  -152,  -152,  -152,  -152,  -152,    22,
     290,  -152,    22,   290,    22,    50,   290,   316,   316,   316,
     316,   290,   290,    32,    27,   373,   -19,  -152,    30,  -152,
    -152,  -152,  -152,  -152,  -152,  -152,  -152,  -152,  -152,  -152,
      34,    -1,     4,   290,   373,  -152,  -152,   -11,    18,  -152,
    -152,    -8,  -152,    22,     1,     6,  -152,  -152,   -11,  -152,
    -152,  -152,  -152,   345,    14,    25,    38,  -152,   206,   316,
     316,   316,   316,   316,   316,   316,   316,   316,   316,   316,
     316,   316,   316,   316,   316,   316,   290,   290,   290,   262,
     290,    22,    30,  -152,   290,  -152,    22,   290,    22,  -152,
     -11,  -152,   234,    77,    11,     2,    37,    49,    11,    87,
      11,   290,  -152,  -152,  -152,   290,  -152,   121,   392,   410,
     427,   443,   306,   473,   478,     3,    28,    33,   459,   103,
     146,   150,   -12,    86,  -152,  -152,  -152,  -152,  -152,    80,
      84,  -152,  -152,   -11,  -152,   -11,  -152,   290,  -152,  -152,
    -152,    13,    88,    98,  -152,  -152,  -152,  -152,  -152,    25,
     100,    11,   234,  -152,    22,   145,  -152,  -152,  -152,  -152,
    -152,  -152,  -152,    79,   206,   143,   -11,    16,    22,   155,
      22,  -152,  -152,  -152,    87,  -152,   290,   -11,  -152,   142,
     290,  -152,   149,   -11,   102,    25,  -152,  -152,   -11,   290,
    -152,  -152,   -11,   290,  -152,  -152,    11,   290,  -152,  -152,
     -11,   108,    79,  -152,  -152,  -152
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       4,    36,    37,    38,    39,    35,    32,    84,    85,     0,
       0,    40,     0,    83,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    78,    41,    42,    72,    44,
      43,   109,    31,   106,   103,   104,   105,   107,   108,   113,
       2,     0,     0,     0,    70,    41,    69,     0,    66,   110,
      82,     0,   111,     0,     0,    98,    99,   112,     0,    29,
      27,    26,    28,    70,     0,    34,     0,     1,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    74,    71,     0,     7,     0,     0,     0,    51,
       0,     8,     0,    88,     0,     0,     0,    94,     0,   102,
       0,     0,    92,    30,    45,     0,    46,     3,     9,    10,
      11,    12,    14,    16,    17,    18,    22,    23,    13,    15,
      19,    20,    21,    24,    25,    80,    81,    79,    48,     0,
       0,    50,    73,     0,    56,     0,    55,     0,   117,   114,
      96,     0,     0,     0,    75,    76,    77,    65,    61,    63,
       0,     0,     0,    95,     0,     0,    57,    97,    33,    47,
      49,    68,    67,     0,     0,     0,     0,    86,     0,     0,
       0,    60,    64,    93,   102,   100,     0,     0,    52,     0,
       0,    89,     0,     0,     0,     0,    62,   101,     0,     0,
     116,   115,     0,     0,    87,    58,     0,     0,    54,    91,
       0,     0,     0,    90,    59,    53
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -152,  -152,  -152,   -29,   -55,    43,     0,   -16,  -152,  -152,
    -152,  -152,  -152,  -152,  -152,   -45,  -152,  -102,  -152,  -152,
    -152,  -151,  -152,  -152,    -5,  -152,    78,  -106,  -152,  -152,
    -152,  -152,  -152,  -152,  -152,  -152,  -152,   -42,   -35,  -152,
     -15,   -95,   -67,     9,  -152
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,    23,    24,    96,   102,    44,    45,    64,    27,    28,
      29,    30,    92,    46,    99,   188,    42,    55,   155,   156,
     106,   160,   107,    31,    65,    32,    93,   157,    33,    34,
      35,    36,    37,   177,    38,    49,    52,   103,    56,    57,
     165,    39,    40,   150,   174
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      26,   117,   163,   159,   166,    47,    66,   149,    50,    41,
       6,    58,    48,    98,    51,    54,   112,    94,   109,     6,
      86,    87,    97,   175,    77,    78,   192,   194,   176,   196,
       6,   193,    67,   152,    84,    85,   115,    68,   100,    77,
      78,    88,   101,    25,    -6,   147,    81,    82,    83,    84,
      85,    95,   108,    54,   110,   182,    95,   158,     6,    53,
      59,    60,    61,    62,    63,    78,   111,   149,    26,   114,
     153,   104,   105,   139,    84,    85,   159,    95,   159,    84,
      85,   135,   136,   137,    89,   140,    90,   151,    91,   143,
     161,   141,   145,   186,   187,   116,   144,   164,   146,   168,
     211,   171,    26,   172,   154,    54,   167,   189,   154,   162,
     154,    25,   118,   119,   120,   121,   122,   123,   124,   125,
     126,   127,   128,   129,   130,   131,   132,   133,   134,   184,
     180,    -5,   199,    85,   191,   169,    74,    75,    76,    77,
      78,   170,   173,   207,   178,    25,    81,    82,    83,    84,
      85,   204,   200,   201,   179,   181,   185,   190,   195,   205,
     209,   154,    26,   203,    54,   214,   206,   215,   213,   197,
     142,   183,     0,     0,    26,     0,     0,     0,    54,     0,
      54,   198,    77,    78,     0,   202,    77,    78,     0,     0,
      82,    83,    84,    85,   208,    83,    84,    85,   210,     0,
       0,     0,   212,     0,     0,    25,   154,     0,     0,     1,
       2,     3,     4,     5,     6,     0,     0,    25,     7,     8,
       0,     0,     9,    10,     0,    11,    12,    13,     0,    14,
      15,    16,     0,     0,     0,     0,     0,     1,     2,     3,
       4,     5,     6,   148,    17,     0,     7,     8,     0,    18,
      19,     0,     0,    11,    20,    13,     0,     0,     0,     0,
      21,     0,    22,     0,     0,     1,     2,     3,     4,     5,
       6,     0,    17,     0,     0,     0,     0,    18,    19,    43,
       0,    11,    20,     0,     0,     0,     0,     0,    21,     0,
      22,     0,     0,     1,     2,     3,     4,     5,     6,     0,
      17,     0,     0,     0,     0,    18,    19,    43,     0,    11,
      20,     0,     0,     0,     0,     0,    21,   138,    22,     1,
       2,     3,     4,     5,     6,     0,     0,     0,    17,     0,
       0,     0,     0,    18,    19,    11,     0,     0,    20,    74,
      75,    76,    77,    78,    21,     0,    22,     0,    80,    81,
      82,    83,    84,    85,    17,     0,     0,     0,     0,    18,
      19,     0,     0,     0,    20,     0,     0,     0,     0,     0,
      21,     0,    22,    69,    70,    71,    72,    73,    74,    75,
      76,    77,    78,     0,     0,     0,    79,    80,    81,    82,
      83,    84,    85,     0,     0,     0,     0,     0,     0,     0,
     113,    69,    70,    71,    72,    73,    74,    75,    76,    77,
      78,     0,     0,     0,    79,    80,    81,    82,    83,    84,
      85,    70,    71,    72,    73,    74,    75,    76,    77,    78,
       0,     0,     0,    79,    80,    81,    82,    83,    84,    85,
      71,    72,    73,    74,    75,    76,    77,    78,     0,     0,
       0,    79,    80,    81,    82,    83,    84,    85,    72,    73,
      74,    75,    76,    77,    78,     0,     0,     0,    79,    80,
      81,    82,    83,    84,    85,    73,    74,    75,    76,    77,
      78,     0,     0,     0,    79,    80,    81,    82,    83,    84,
      85,    73,    74,    75,    76,    77,    78,     0,     0,     0,
       0,    80,    81,    82,    83,    84,    85,    75,    76,    77,
      78,     0,     0,    76,    77,    78,    81,    82,    83,    84,
      85,    81,    82,    83,    84,    85
};

static const yytype_int16 yycheck[] =
{
       0,    68,   108,   105,   110,    10,    22,   102,    13,     9,
       8,    16,    12,    42,    14,    15,    58,    18,    53,     8,
      39,    40,    18,    10,    36,    37,    10,   178,    15,   180,
       8,    15,     0,    22,    46,    47,    65,    10,    43,    36,
      37,    60,    53,     0,    10,   100,    43,    44,    45,    46,
      47,    52,    60,    53,    53,   161,    52,    55,     8,     9,
      17,    18,    19,    20,    21,    37,    60,   162,    68,    55,
      59,    53,    54,    89,    46,    47,   178,    52,   180,    46,
      47,    86,    87,    88,    54,    90,    56,    10,    58,    94,
      53,    91,    97,    14,    15,    57,    96,    10,    98,   115,
     206,   143,   102,   145,   104,   105,   111,   174,   108,    60,
     110,    68,    69,    70,    71,    72,    73,    74,    75,    76,
      77,    78,    79,    80,    81,    82,    83,    84,    85,   164,
     159,    10,   187,    47,   176,    55,    33,    34,    35,    36,
      37,    57,   147,   198,    56,   102,    43,    44,    45,    46,
      47,   193,    10,    11,    56,    55,    11,    14,     3,    57,
     202,   161,   162,    14,   164,    57,   195,   212,   210,   184,
      92,   162,    -1,    -1,   174,    -1,    -1,    -1,   178,    -1,
     180,   186,    36,    37,    -1,   190,    36,    37,    -1,    -1,
      44,    45,    46,    47,   199,    45,    46,    47,   203,    -1,
      -1,    -1,   207,    -1,    -1,   162,   206,    -1,    -1,     3,
       4,     5,     6,     7,     8,    -1,    -1,   174,    12,    13,
      -1,    -1,    16,    17,    -1,    19,    20,    21,    -1,    23,
      24,    25,    -1,    -1,    -1,    -1,    -1,     3,     4,     5,
       6,     7,     8,     9,    38,    -1,    12,    13,    -1,    43,
      44,    -1,    -1,    19,    48,    21,    -1,    -1,    -1,    -1,
      54,    -1,    56,    -1,    -1,     3,     4,     5,     6,     7,
       8,    -1,    38,    -1,    -1,    -1,    -1,    43,    44,    17,
      -1,    19,    48,    -1,    -1,    -1,    -1,    -1,    54,    -1,
      56,    -1,    -1,     3,     4,     5,     6,     7,     8,    -1,
      38,    -1,    -1,    -1,    -1,    43,    44,    17,    -1,    19,
      48,    -1,    -1,    -1,    -1,    -1,    54,    55,    56,     3,
       4,     5,     6,     7,     8,    -1,    -1,    -1,    38,    -1,
      -1,    -1,    -1,    43,    44,    19,    -1,    -1,    48,    33,
      34,    35,    36,    37,    54,    -1,    56,    -1,    42,    43,
      44,    45,    46,    47,    38,    -1,    -1,    -1,    -1,    43,
      44,    -1,    -1,    -1,    48,    -1,    -1,    -1,    -1,    -1,
      54,    -1,    56,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    -1,    -1,    -1,    41,    42,    43,    44,
      45,    46,    47,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      55,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    -1,    -1,    -1,    41,    42,    43,    44,    45,    46,
      47,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      -1,    -1,    -1,    41,    42,    43,    44,    45,    46,    47,
      30,    31,    32,    33,    34,    35,    36,    37,    -1,    -1,
      -1,    41,    42,    43,    44,    45,    46,    47,    31,    32,
      33,    34,    35,    36,    37,    -1,    -1,    -1,    41,    42,
      43,    44,    45,    46,    47,    32,    33,    34,    35,    36,
      37,    -1,    -1,    -1,    41,    42,    43,    44,    45,    46,
      47,    32,    33,    34,    35,    36,    37,    -1,    -1,    -1,
      -1,    42,    43,    44,    45,    46,    47,    34,    35,    36,
      37,    -1,    -1,    35,    36,    37,    43,    44,    45,    46,
      47,    43,    44,    45,    46,    47
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     3,     4,     5,     6,     7,     8,    12,    13,    16,
      17,    19,    20,    21,    23,    24,    25,    38,    43,    44,
      48,    54,    56,    62,    63,    66,    67,    69,    70,    71,
      72,    84,    86,    89,    90,    91,    92,    93,    95,   102,
     103,    67,    77,    17,    66,    67,    74,    85,    67,    96,
      85,    67,    97,     9,    67,    78,    99,   100,    85,    66,
      66,    66,    66,    66,    68,    85,    68,     0,    10,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    41,
      42,    43,    44,    45,    46,    47,    39,    40,    60,    54,
      56,    58,    73,    87,    18,    52,    64,    18,    64,    75,
      85,    53,    65,    98,    53,    54,    81,    83,    60,    99,
      53,    60,    98,    55,    55,    64,    57,   103,    66,    66,
      66,    66,    66,    66,    66,    66,    66,    66,    66,    66,
      66,    66,    66,    66,    66,    85,    85,    85,    55,    68,
      85,    67,    87,    85,    67,    85,    67,    65,     9,   102,
     104,    10,    22,    59,    67,    79,    80,    88,    55,    78,
      82,    53,    60,    88,    10,   101,    88,    85,    68,    55,
      57,    98,    98,    85,   105,    10,    15,    94,    56,    56,
      64,    55,    88,   104,    99,    11,    14,    15,    76,   103,
      14,    98,    10,    15,    82,     3,    82,   101,    85,    65,
      10,    11,    85,    14,    98,    57,    64,    65,    85,    98,
      85,    88,    85,    98,    57,    76
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    61,    62,    62,    62,    63,    63,    64,    65,    66,
      66,    66,    66,    66,    66,    66,    66,    66,    66,    66,
      66,    66,    66,    66,    66,    66,    66,    66,    66,    66,
      66,    66,    67,    68,    68,    69,    69,    69,    69,    69,
      69,    70,    70,    70,    70,    71,    72,    73,    73,    73,
      73,    74,    75,    76,    76,    77,    77,    78,    79,    80,
      81,    81,    82,    82,    83,    83,    83,    84,    84,    85,
      85,    86,    86,    87,    87,    88,    88,    88,    89,    89,
      89,    89,    90,    90,    91,    92,    93,    93,    93,    93,
      94,    94,    95,    96,    96,    97,    98,    99,    99,   100,
     100,   101,   101,   102,   102,   102,   102,   103,   103,   103,
     103,   103,   103,   103,   104,   104,   105,   105
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     3,     0,     3,     1,     1,     1,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     2,     2,     2,     2,
       3,     1,     1,     3,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     3,     3,     3,     2,     3,
       2,     2,     4,     5,     3,     3,     3,     3,     4,     6,
       3,     2,     3,     1,     3,     2,     0,     5,     5,     1,
       1,     2,     1,     2,     1,     1,     1,     1,     1,     3,
       3,     3,     2,     1,     1,     1,     5,     7,     3,     6,
       5,     4,     3,     4,     2,     3,     2,     3,     1,     1,
       4,     3,     0,     1,     1,     1,     1,     1,     1,     1,
       2,     2,     2,     1,     1,     4,     3,     0
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)                                \
    do                                                                  \
      if (N)                                                            \
        {                                                               \
          (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;        \
          (Current).first_column = YYRHSLOC (Rhs, 1).first_column;      \
          (Current).last_line    = YYRHSLOC (Rhs, N).last_line;         \
          (Current).last_column  = YYRHSLOC (Rhs, N).last_column;       \
        }                                                               \
      else                                                              \
        {                                                               \
          (Current).first_line   = (Current).last_line   =              \
            YYRHSLOC (Rhs, 0).last_line;                                \
          (Current).first_column = (Current).last_column =              \
            YYRHSLOC (Rhs, 0).last_column;                              \
        }                                                               \
    while (0)
#endif

#define YYRHSLOC(Rhs, K) ((Rhs)[K])


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL

/* Print *YYLOCP on YYO.  Private, do not rely on its existence. */

YY_ATTRIBUTE_UNUSED
static unsigned
yy_location_print_ (FILE *yyo, YYLTYPE const * const yylocp)
{
  unsigned res = 0;
  int end_col = 0 != yylocp->last_column ? yylocp->last_column - 1 : 0;
  if (0 <= yylocp->first_line)
    {
      res += YYFPRINTF (yyo, "%d", yylocp->first_line);
      if (0 <= yylocp->first_column)
        res += YYFPRINTF (yyo, ".%d", yylocp->first_column);
    }
  if (0 <= yylocp->last_line)
    {
      if (yylocp->first_line < yylocp->last_line)
        {
          res += YYFPRINTF (yyo, "-%d", yylocp->last_line);
          if (0 <= end_col)
            res += YYFPRINTF (yyo, ".%d", end_col);
        }
      else if (0 <= end_col && yylocp->first_column < end_col)
        res += YYFPRINTF (yyo, "-%d", end_col);
    }
  return res;
 }

#  define YY_LOCATION_PRINT(File, Loc)          \
  yy_location_print_ (File, &(Loc))

# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value, Location); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  YYUSE (yylocationp);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  YY_LOCATION_PRINT (yyoutput, *yylocationp);
  YYFPRINTF (yyoutput, ": ");
  yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, YYLTYPE *yylsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                       , &(yylsp[(yyi + 1) - (yynrhs)])                       );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, yylsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
{
  YYUSE (yyvaluep);
  YYUSE (yylocationp);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Location data for the lookahead symbol.  */
YYLTYPE yylloc
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
  = { 1, 1, 1, 1 }
# endif
;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.
       'yyls': related to locations.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    /* The location stack.  */
    YYLTYPE yylsa[YYINITDEPTH];
    YYLTYPE *yyls;
    YYLTYPE *yylsp;

    /* The locations where the error started and ended.  */
    YYLTYPE yyerror_range[3];

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yylsp = yyls = yylsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  yylsp[0] = yylloc;
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;
        YYLTYPE *yyls1 = yyls;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yyls1, yysize * sizeof (*yylsp),
                    &yystacksize);

        yyls = yyls1;
        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
        YYSTACK_RELOCATE (yyls_alloc, yyls);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END
  *++yylsp = yylloc;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location.  */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 156 "nim.y" /* yacc.c:1646  */
    {   
                                char* label = new_label();
                                backpatch((yyvsp[0].s_tree).nextlist, label);
                                globalnextlist = merge(globalnextlist, (yyvsp[0].s_tree).nextlist);
                                (yyval.s_tree).code = scc(2, (yyvsp[0].s_tree).code,putl(label));
                                final_IR = (yyval.s_tree).code;
                            }
#line 1654 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 3:
#line 163 "nim.y" /* yacc.c:1646  */
    {
                                        char *label1 = new_label();
                                        char *label2 = new_label();
                                        backpatch((yyvsp[-2].s_tree).nextlist, label1);
                                        backpatch((yyvsp[0].s_tree).nextlist, label2);
                                        globalnextlist = merge(globalnextlist, (yyvsp[-2].s_tree).nextlist);
                                        globalnextlist = merge(globalnextlist, (yyvsp[0].s_tree).nextlist);
                                        (yyval.s_tree).code = scc(4, (yyvsp[-2].s_tree).code, putl(label1), (yyvsp[0].s_tree).code, putl(label2)); 
                                        final_IR = (yyval.s_tree).code;
                                      }
#line 1669 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 4:
#line 173 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = ""; final_IR = (yyval.s_tree).code;}
#line 1675 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 5:
#line 175 "nim.y" /* yacc.c:1646  */
    {
                                            char* label = new_label();
                                            backpatch((yyvsp[-2].s_tree).nextlist, label);
                                            globalnextlist = merge(globalnextlist, (yyvsp[-2].s_tree).nextlist);
                                            (yyval.s_tree).nextlist = (yyvsp[0].s_tree).nextlist;
                                            (yyval.s_tree).code = scc(3, (yyvsp[-2].s_tree).code,putl(label),(yyvsp[0].s_tree).code);
                                           }
#line 1687 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 6:
#line 182 "nim.y" /* yacc.c:1646  */
    {
                                (yyval.s_tree).nextlist = (yyvsp[0].s_tree).nextlist;
                                (yyval.s_tree).code = (yyvsp[0].s_tree).code;
                              }
#line 1696 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 9:
#line 191 "nim.y" /* yacc.c:1646  */
    {
                            char *t = new_temp();
                            char *label = new_label();
                            char *B1_truelabel = new_label();
                            char *B1_falselabel = new_label();
                            char *B2_truelabel = new_label();
                            char *B2_falselabel = new_label();
                            char *bptlabel = new_bplabel();
                            char *bpflabel = new_bplabel();
                            backpatch((yyvsp[-2].s_tree).falselist,B1_falselabel);
                            backpatch((yyvsp[-2].s_tree).truelist,B1_truelabel);
                            backpatch((yyvsp[0].s_tree).falselist,B2_falselabel);
                            backpatch((yyvsp[0].s_tree).truelist,B2_truelabel);
                            globaltruelist = merge(globaltruelist, (yyvsp[-2].s_tree).truelist);
                            globaltruelist = merge(globaltruelist, (yyvsp[0].s_tree).truelist);
                            globalfalselist = merge(globalfalselist, (yyvsp[-2].s_tree).falselist);
                            globalfalselist = merge(globalfalselist, (yyvsp[0].s_tree).falselist);
                            (yyval.s_tree).truelist = create_bp(bptlabel);
                            (yyval.s_tree).falselist = create_bp(bpflabel);
                            (yyval.s_tree).code = scc(31, t, " = 0\n", (yyvsp[-2].s_tree).code, putl(B1_truelabel), t, " = 1\ngoto c", label, "\n", putl(B1_falselabel), t, " = 0\n", putl(label), (yyvsp[0].s_tree).code, putl(B2_truelabel), "if ", t, " goto ", bpflabel, "\n", "goto ", bptlabel, "\n", putl(B2_falselabel), "ifFalse ", t, " goto ", bpflabel, "\n", "goto ", bptlabel, "\n");
                          }
#line 1722 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 10:
#line 212 "nim.y" /* yacc.c:1646  */
    {
                            char *label = new_label();
                            backpatch((yyvsp[-2].s_tree).falselist,label);
                            globalfalselist = merge(globalfalselist, (yyvsp[-2].s_tree).falselist);
                            (yyval.s_tree).truelist = merge((yyvsp[-2].s_tree).truelist,(yyvsp[0].s_tree).truelist);
                            (yyval.s_tree).falselist = (yyvsp[0].s_tree).falselist;
                            (yyval.s_tree).code = scc(3,(yyvsp[-2].s_tree).code, putl(label), (yyvsp[0].s_tree).code);
                          }
#line 1735 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 11:
#line 220 "nim.y" /* yacc.c:1646  */
    {
                            char *label = new_label();
                            backpatch((yyvsp[-2].s_tree).truelist,label);
                            globaltruelist = merge(globaltruelist, (yyvsp[-2].s_tree).truelist);
                            (yyval.s_tree).falselist = merge((yyvsp[-2].s_tree).falselist,(yyvsp[0].s_tree).falselist);
                            (yyval.s_tree).truelist = (yyvsp[0].s_tree).truelist;
                            (yyval.s_tree).code = scc(3,(yyvsp[-2].s_tree).code, putl(label), (yyvsp[0].s_tree).code);
                          }
#line 1748 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 228 "nim.y" /* yacc.c:1646  */
    {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            (yyval.s_tree).truelist = create_bp(bplabel1);
                            (yyval.s_tree).falselist = create_bp(bplabel2);
                            (yyval.s_tree).code = scc(11, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, "if ", (yyvsp[-2].s_tree).addr, " neq ", (yyvsp[0].s_tree).addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
#line 1760 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 235 "nim.y" /* yacc.c:1646  */
    {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            (yyval.s_tree).truelist = create_bp(bplabel1);
                            (yyval.s_tree).falselist = create_bp(bplabel2);
                            (yyval.s_tree).code = scc(11, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, "if ", (yyvsp[-2].s_tree).addr, " gt ", (yyvsp[0].s_tree).addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                        }
#line 1772 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 242 "nim.y" /* yacc.c:1646  */
    {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            (yyval.s_tree).truelist = create_bp(bplabel1);
                            (yyval.s_tree).falselist = create_bp(bplabel2);
                            (yyval.s_tree).code = scc(11, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, "if ", (yyvsp[-2].s_tree).addr, " geq ", (yyvsp[0].s_tree).addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
#line 1784 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 15:
#line 249 "nim.y" /* yacc.c:1646  */
    {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            (yyval.s_tree).truelist = create_bp(bplabel1);
                            (yyval.s_tree).falselist = create_bp(bplabel2);
                            (yyval.s_tree).code = scc(11, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, "if ", (yyvsp[-2].s_tree).addr, " lt ", (yyvsp[0].s_tree).addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                        }
#line 1796 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 256 "nim.y" /* yacc.c:1646  */
    {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            (yyval.s_tree).truelist = create_bp(bplabel1);
                            (yyval.s_tree).falselist = create_bp(bplabel2);
                            (yyval.s_tree).code = scc(11, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, "if ", (yyvsp[-2].s_tree).addr, " leq ", (yyvsp[0].s_tree).addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
#line 1808 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 263 "nim.y" /* yacc.c:1646  */
    {
                            char *bplabel1 = new_bplabel();
                            char *bplabel2 = new_bplabel();
                            (yyval.s_tree).truelist = create_bp(bplabel1);
                            (yyval.s_tree).falselist = create_bp(bplabel2);
                            (yyval.s_tree).code = scc(11, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, "if ", (yyvsp[-2].s_tree).addr, " eq ", (yyvsp[0].s_tree).addr, " goto ", bplabel1, "\ngoto ", bplabel2, "\n");
                         }
#line 1820 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 18:
#line 270 "nim.y" /* yacc.c:1646  */
    {}
#line 1826 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 19:
#line 271 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL;
                            (yyval.s_tree).addr = new_temp(); 
                            (yyval.s_tree).code = scc(8 , (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, (yyval.s_tree).addr," = ", (yyvsp[-2].s_tree).addr," - ", (yyvsp[0].s_tree).addr, "\n");
                        }
#line 1837 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 20:
#line 277 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL;
                            (yyval.s_tree).addr = new_temp(); 
                            (yyval.s_tree).code = scc(8, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, (yyval.s_tree).addr," = ", (yyvsp[-2].s_tree).addr," + ", (yyvsp[0].s_tree).addr,"\n");
                        }
#line 1848 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 283 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL;
                            (yyval.s_tree).addr = new_temp(); 
                            (yyval.s_tree).code = scc(8, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, (yyval.s_tree).addr," = ", (yyvsp[-2].s_tree).addr," mod ", (yyvsp[0].s_tree).addr,"\n");
                        }
#line 1859 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 289 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL;
                            (yyval.s_tree).addr = new_temp(); 
                            (yyval.s_tree).code = scc(8, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, (yyval.s_tree).addr," = ", (yyvsp[-2].s_tree).addr," mod ", (yyvsp[0].s_tree).addr,"\n");
                          }
#line 1870 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 295 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL;
                            (yyval.s_tree).addr = new_temp(); 
                            (yyval.s_tree).code = scc(8, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, (yyval.s_tree).addr," = ", (yyvsp[-2].s_tree).addr," idiv ", (yyvsp[0].s_tree).addr,"\n");
                          }
#line 1881 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 24:
#line 301 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL;
                            (yyval.s_tree).addr = new_temp(); 
                            (yyval.s_tree).code = scc(8, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, (yyval.s_tree).addr," = ", (yyvsp[-2].s_tree).addr," / ", (yyvsp[0].s_tree).addr,"\n");
                        }
#line 1892 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 25:
#line 307 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL;   
                            (yyval.s_tree).addr = new_temp();
                            (yyval.s_tree).code = scc(8, (yyvsp[-2].s_tree).code, (yyvsp[0].s_tree).code, (yyval.s_tree).addr," = ", (yyvsp[-2].s_tree).addr," * ", (yyvsp[0].s_tree).addr,"\n");
                        }
#line 1903 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 313 "nim.y" /* yacc.c:1646  */
    {
                                (yyval.s_tree).truelist = NULL;
                                (yyval.s_tree).falselist = NULL;
                                (yyval.s_tree).code = (yyvsp[0].s_tree).code;
                                (yyval.s_tree).addr = (yyvsp[0].s_tree).addr;
                              }
#line 1914 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 319 "nim.y" /* yacc.c:1646  */
    {
                                (yyval.s_tree).truelist = NULL;
                                (yyval.s_tree).falselist = NULL;
                                (yyval.s_tree).addr = new_temp(); 
                                (yyval.s_tree).code = scc(5, (yyvsp[0].s_tree).code, (yyval.s_tree).addr, " = - ", (yyvsp[0].s_tree).addr, "\n");
                               }
#line 1925 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 325 "nim.y" /* yacc.c:1646  */
    {}
#line 1931 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 326 "nim.y" /* yacc.c:1646  */
    {
                        (yyval.s_tree).falselist = (yyval.s_tree).truelist;
                        (yyval.s_tree).truelist = (yyval.s_tree).falselist;
                        (yyval.s_tree).code = (yyvsp[0].s_tree).code;
                    }
#line 1941 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 30:
#line 331 "nim.y" /* yacc.c:1646  */
    {
                                    (yyval.s_tree).truelist = (yyvsp[-1].s_tree).truelist;
                                    (yyval.s_tree).falselist = (yyvsp[-1].s_tree).falselist;
                                    (yyval.s_tree).code = (yyvsp[-1].s_tree).code;
                                    (yyval.s_tree).addr = (yyvsp[-1].s_tree).addr;
                                   }
#line 1952 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 31:
#line 337 "nim.y" /* yacc.c:1646  */
    {   
                    // TODO: Add support for true false
                    (yyval.s_tree).truelist = (yyvsp[0].s_tree).truelist;
                    (yyval.s_tree).falselist = (yyvsp[0].s_tree).falselist;
                    (yyval.s_tree).code = (yyvsp[0].s_tree).code; 
                    (yyval.s_tree).addr = (yyvsp[0].s_tree).addr;
                }
#line 1964 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 32:
#line 345 "nim.y" /* yacc.c:1646  */
    {
               (yyval.idl).value.name = (yyvsp[0].str);
               (yyval.idl).is_ident=1;
              }
#line 1973 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 35:
#line 354 "nim.y" /* yacc.c:1646  */
    {(yyval.idl).value.bval = (yyvsp[0].integer); 
                  (yyval.idl).type = BOOL_TYPE;(yyval.idl).is_ident=0;}
#line 1980 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 36:
#line 356 "nim.y" /* yacc.c:1646  */
    {(yyval.idl).value.ival = (yyvsp[0].integer); 
                  (yyval.idl).type = INT_TYPE;(yyval.idl).is_ident=0;}
#line 1987 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 37:
#line 358 "nim.y" /* yacc.c:1646  */
    {(yyval.idl).value.fval = (yyvsp[0].floater); 
                    (yyval.idl).type = FLOAT_TYPE;(yyval.idl).is_ident=0;}
#line 1994 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 38:
#line 360 "nim.y" /* yacc.c:1646  */
    {(yyval.idl).value.sval = (yyvsp[0].str); 
                  (yyval.idl).type = STR_TYPE;(yyval.idl).is_ident=0;}
#line 2001 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 39:
#line 362 "nim.y" /* yacc.c:1646  */
    {(yyval.idl).value.cval = (yyvsp[0].ch); 
                  (yyval.idl).type = CHAR_TYPE;(yyval.idl).is_ident=0;}
#line 2008 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 40:
#line 364 "nim.y" /* yacc.c:1646  */
    {(yyval.idl).is_ident=0;}
#line 2014 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 41:
#line 366 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.idl).value.name = (yyvsp[0].idl).value.name; 
                            (yyval.idl).is_ident = 1;
                       }
#line 2023 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 42:
#line 370 "nim.y" /* yacc.c:1646  */
    {
                            if((yyvsp[0].idl).type==INT_TYPE){(yyval.idl).value.ival=(yyvsp[0].idl).value.ival;} 
                            else if((yyvsp[0].idl).type==FLOAT_TYPE){(yyval.idl).value.fval=(yyvsp[0].idl).value.fval;} 
                            else if((yyvsp[0].idl).type==CHAR_TYPE){(yyval.idl).value.cval=(yyvsp[0].idl).value.cval;} 
                            else if((yyvsp[0].idl).type==STR_TYPE){(yyval.idl).value.sval=(yyvsp[0].idl).value.sval;} 
                            else if((yyvsp[0].idl).type==INT_TYPE){(yyval.idl).value.bval=(yyvsp[0].idl).value.bval;} 
                            (yyval.idl).type = (yyvsp[0].idl).type; (yyval.idl).is_ident=0;
                         }
#line 2036 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 70:
#line 420 "nim.y" /* yacc.c:1646  */
    {
                (yyval.s_tree).code = (yyvsp[0].s_tree).code; 
                (yyval.s_tree).addr = (yyvsp[0].s_tree).addr;
                (yyval.s_tree).truelist = (yyvsp[0].s_tree).truelist;
                (yyval.s_tree).falselist = (yyvsp[0].s_tree).falselist;
             }
#line 2047 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 72:
#line 428 "nim.y" /* yacc.c:1646  */
    {
                            (yyval.s_tree).addr = new_temp();
                            (yyval.s_tree).truelist = NULL;
                            (yyval.s_tree).falselist = NULL; 
                            if((yyvsp[0].idl).is_ident){(yyval.s_tree).code = scc(4, (yyval.s_tree).addr, " = ", (yyvsp[0].idl).value.name, "\n");} 
                            else if((yyvsp[0].idl).type==INT_TYPE){
                                char *int_str = (char *)malloc(50 * sizeof(char));
                                sprintf(int_str,"%d",(yyvsp[0].idl).value.ival);
                                (yyval.s_tree).code = scc(4, (yyval.s_tree).addr, " = ", int_str, "\n");
                            }
                            else if((yyvsp[0].idl).type==FLOAT_TYPE){
                                char *float_str = (char *)malloc(50 * sizeof(char));
                                sprintf(float_str,"%f",(yyvsp[0].idl).value.fval);
                                (yyval.s_tree).code = scc(4, (yyval.s_tree).addr, " = ", float_str,"\n");
                            }
                            else if((yyvsp[0].idl).type==STR_TYPE){
                                (yyval.s_tree).code = scc(4, (yyval.s_tree).addr, " = ", (yyvsp[0].idl).value.sval, "\n");
                            }
                            else if((yyvsp[0].idl).type==CHAR_TYPE){
                                char *char_str = (char *)malloc(3 * sizeof(char));
                                sprintf(char_str,"%c",(yyvsp[0].idl).value.cval);
                                (yyval.s_tree).code = scc(4, (yyval.s_tree).addr, " = ", char_str, "\n");
                            }
                            else if((yyvsp[0].idl).type==BOOL_TYPE){
                                char* bplabel = new_bplabel();
                                if ((yyvsp[0].idl).value.bval==1)
                                    {(yyval.s_tree).truelist = create_bp(bplabel);}
                                else
                                    {(yyval.s_tree).falselist = create_bp(bplabel);}
                                // $$.code = scc(4, $$.addr, " = ", boolean[$1.value.bval], "\n"));
                                (yyval.s_tree).code = scc(3, "goto ", bplabel, "\n");
                            }
                         }
#line 2085 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 78:
#line 474 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = (yyvsp[0].s_tree).code; (yyval.s_tree).nextlist = NULL;}
#line 2091 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 79:
#line 475 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = scc(5, (yyvsp[0].s_tree).code, (yyvsp[-2].idl).value.name, " = ", (yyvsp[0].s_tree).addr, "\n"); (yyval.s_tree).nextlist = NULL;}
#line 2097 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 80:
#line 476 "nim.y" /* yacc.c:1646  */
    {}
#line 2103 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 81:
#line 477 "nim.y" /* yacc.c:1646  */
    {}
#line 2109 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 86:
#line 491 "nim.y" /* yacc.c:1646  */
    {}
#line 2115 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 87:
#line 492 "nim.y" /* yacc.c:1646  */
    {}
#line 2121 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 88:
#line 493 "nim.y" /* yacc.c:1646  */
    {
                                            char *label = new_label();
                                            backpatch((yyvsp[-1].s_tree).truelist, label);
                                            globaltruelist = merge(globaltruelist, (yyvsp[-1].s_tree).truelist);
                                            (yyval.s_tree).nextlist = merge((yyvsp[-1].s_tree).falselist, (yyvsp[0].s_tree).nextlist);
                                            (yyval.s_tree).code = scc(3, (yyvsp[-1].s_tree).code, putl(label), (yyvsp[0].s_tree).code);
                                          }
#line 2133 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 89:
#line 500 "nim.y" /* yacc.c:1646  */
    {
                                                        char *label1 = new_label();
                                                        char *label2 = new_label();
                                                        char *bplabel = new_bplabel();
                                                        backpatch((yyvsp[-4].s_tree).truelist, label1);
                                                        backpatch((yyvsp[-4].s_tree).falselist, label2);
                                                        globalfalselist = merge(globalfalselist, (yyvsp[-4].s_tree).falselist);
                                                        globaltruelist = merge(globaltruelist, (yyvsp[-4].s_tree).truelist);
                                                        (yyval.s_tree).nextlist = merge(create_bp(bplabel) ,merge((yyvsp[-3].s_tree).nextlist, (yyvsp[0].s_tree).nextlist));
                                                        (yyval.s_tree).code = scc(8, (yyvsp[-4].s_tree).code, putl(label1), (yyvsp[-3].s_tree).code, "goto ", bplabel, "\n", putl(label2), (yyvsp[0].s_tree).code);
                                                      }
#line 2149 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 90:
#line 512 "nim.y" /* yacc.c:1646  */
    {
                                                        // $$.code = scc(8, $2.code, putl(label1), $3.code, "goto ", bplabel, "\n", putl(label2), $6.code);
                                                       }
#line 2157 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 91:
#line 515 "nim.y" /* yacc.c:1646  */
    {
                                            // char *label = new_label();
                                            // $$.code = scc(8, $3.code, putl(label), $4.code, "goto ", bplabel, "\n", putl(label2), $6.code);
                                           }
#line 2166 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 96:
#line 533 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = (yyvsp[0].s_tree).code; (yyval.s_tree).nextlist = (yyvsp[0].s_tree).nextlist;}
#line 2172 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 106:
#line 551 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = (yyvsp[0].s_tree).code; (yyval.s_tree).nextlist = NULL;}
#line 2178 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 107:
#line 553 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = (yyvsp[0].s_tree).code; (yyval.s_tree).nextlist = (yyvsp[0].s_tree).nextlist;}
#line 2184 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 108:
#line 554 "nim.y" /* yacc.c:1646  */
    {}
#line 2190 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 113:
#line 559 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = (yyvsp[0].s_tree).code; (yyval.s_tree).nextlist = NULL;}
#line 2196 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 114:
#line 561 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = (yyvsp[0].s_tree).code; (yyval.s_tree).nextlist = (yyvsp[0].s_tree).nextlist;}
#line 2202 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 115:
#line 562 "nim.y" /* yacc.c:1646  */
    {
                                            char *label = new_label(); 
                                            backpatch((yyvsp[-2].s_tree).nextlist, label);
                                            globalnextlist = merge(globalnextlist, (yyvsp[-2].s_tree).nextlist);
                                            (yyval.s_tree).nextlist = (yyvsp[-1].s_tree).nextlist;
                                            (yyval.s_tree).code = scc(3, (yyvsp[-2].s_tree).code, putl(label), (yyvsp[-1].s_tree).code);
                                           }
#line 2214 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 116:
#line 570 "nim.y" /* yacc.c:1646  */
    {
                                        char *label = new_label(); 
                                        backpatch((yyvsp[-2].s_tree).nextlist, label);
                                        globalnextlist = merge(globalnextlist, (yyvsp[-2].s_tree).nextlist);
                                        (yyval.s_tree).nextlist = (yyvsp[-1].s_tree).nextlist;
                                        (yyval.s_tree).code = scc(3, (yyvsp[-2].s_tree).code, putl(label), (yyvsp[-1].s_tree).code);
                                       }
#line 2226 "nim.tab.c" /* yacc.c:1646  */
    break;

  case 117:
#line 577 "nim.y" /* yacc.c:1646  */
    {(yyval.s_tree).code = ""; (yyval.s_tree).nextlist = NULL;}
#line 2232 "nim.tab.c" /* yacc.c:1646  */
    break;


#line 2236 "nim.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }

  yyerror_range[1] = yylloc;

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval, &yylloc);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  yyerror_range[1] = yylsp[1-yylen];
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;

      yyerror_range[1] = *yylsp;
      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp, yylsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  yyerror_range[2] = yylloc;
  /* Using YYLLOC is tempting, but would change the location of
     the lookahead.  YYLOC is available though.  */
  YYLLOC_DEFAULT (yyloc, yyerror_range, 2);
  *++yylsp = yyloc;

  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, &yylloc);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp, yylsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 580 "nim.y" /* yacc.c:1906  */

/* End of grammar */

const char* g_current_filename = "stdin";

char* new_label(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("label",label_no_str);
    label_no++;
    return label;
}

char* new_temp(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("temp",label_no_str);
    label_no++;
    return label;
}

char* new_bplabel(){
    static int label_no = 0;
    char *label_no_str = (char *)malloc(7 * sizeof(char));
    sprintf(label_no_str,"%d",label_no);
    char *label = sc("_bp",label_no_str);
    label_no++;
    return label;
}

char* sc(char * s1, char *s2){
    char* res = (char*)malloc(strlen(s1) + strlen(s2) + 2);
    strcpy(res,s1);
    strcat(res,s2);
    return res;
}

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

void dump_list_helper(FILE* fptr, bp_node* l){
    if(l==NULL) return;
    fprintf(fptr, "%s %s\n",l->temp_label,l->bp_label);
    dump_list_helper(fptr,l->prev);    
}


void dump_list(bp_node* l){
    FILE *fptr;
    char filename[20] = ".mininimIR";
    fptr = fopen(filename, "a");
    fprintf(fptr, "IR_END\n");
    fprintf(fptr, "\nPATCH_LABELS\n\n");
    dump_list_helper(fptr,l);
    fclose(fptr);
}

// symrec * putsym (char *sym_name,int sym_type){
//   symrec *ptr;
//   ptr = (symrec *) malloc (sizeof (symrec));
//   ptr->name = (char *) malloc (strlen (sym_name) + 1);
//   strcpy (ptr->name,sym_name);
//   ptr->type = sym_type;
//   ptr->value.var = 0; /* set value to 0 even if fctn.  */
//   ptr->next = (struct symrec *)sym_table;
//   sym_table = ptr;
//   return ptr;
// }

// symrec *getsym (char *sym_name){
//   symrec *ptr;
//   for (ptr = sym_table; ptr != (symrec *) 0;
//        ptr = (symrec *)ptr->next)
//     if (strcmp (ptr->name,sym_name) == 0)
//       return ptr;
//   return 0;
// }

int main(int argc, char* argv[]) {
    yyin = stdin;

    if(argc == 2) {
        yyin = fopen(argv[1], "r");
        g_current_filename = argv[1];
        if(!yyin) {
            perror(argv[1]);
            return 1;
        }
    }

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));
    printf("------------------------------------------------------------------\n");
    printf("BISON OUTPUT\n");
    printf("------------------------------------------------------------------\n");
    printf("True List:\n");
    print_list(globaltruelist);
    printf("False List:\n");
    print_list(globalfalselist);
    printf("Next List:\n");
    print_list(globalnextlist);
    printf("\nGenerated IR:\n");
    printf("%s", final_IR);
    dump_IR(final_IR);
    dump_list(merge(merge(globalnextlist,globaltruelist),globalfalselist));
    // Only in newer versions, apparently.
    // yylex_destroy();
}

void yyerror (char *s)  /* Called by yyparse on error */{
  printf ("%s\n", s);
}
