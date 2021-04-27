# Viper  🐍
### An amalgamation of all our favorite language quirks.
A hosted copy of this manual may be found [here](https://github.com/raghavmecheri/viper/blob/main/misc/LRM.md).
<br><br>

Authors:  

- Mustafa Eyceoz (me2680)
- Tommy Gomez (tjk2132)
- Trey Gilliland (jlg2266)
- Matthew Ottomano (mro2120)
- Raghav Mecheri (rm3614)


# `0` Contents 📌
1. [Overview 🚁](#1-overview)  
2. [Lexical Coventions 📝](#2-lexical-conventions)  
    1. [Comments](#21-comments)  
    2. [Identifiers](#22-identifiers)  
    3. [Reserved Keywords](#23-reserved-keywords)
    4. [Scoping](#24-scoping)
    5. [Literals](#25-literals)
        1. [char](#251-char-literals)
        2. [int](#252-int-literals)
        3. [float](#253-float-literals)
        4. [bool](#254-boolean-literals)
        5. [string](#255-string-literals)
        6. [nah](#256-nah-literals)
        7. [list](#257-list-literals)
3. [Data Types  💾](#3-data-types)
    1. [Primitive Types](#31-primitive-data-types)
        1. [char](#311-char)
        2. [int](#312-int)
        3. [float](#313-float)
        4. [bool](#314-bool)
        5. [string](#315-string)
        6. [nah](#316-nah)
    2. [Higher-Order Data Types](#32-higher-order-data-types)
        1. [list](#321-list)
        2. [dict](#322-dict)
4. [Type System 🗃](#4-type-system)
    1. [Explicit Types](#41-explicit-types)
    2. [Explicit Type Conversion](#42-explicit-type-conversions)
5. [Statements 🗣](#5-statements)
    1. [Selector Statements](#51-selector-statements)
        1. [if](#511-if-statement)
        2. [if/elif/else](#512-if/elif/else-statement)
    2. [Iterator Statements](#52-iterator-statements)
        1. [for](#521-for-statement)
        2. [while](#522-while-statement)
    3. [Jump Statements](#53-jump-statements)
        1. [skip](#531-skip-statement)
        2. [abort](#532-abort-statement)
    4. [Function Statement](#54-function-statement)
        1. [Arrow Functions](#541-arrow-functions)
6. [Expressions 🖥](#6-expressions)
    1. [Truth-Value Expressions](#61-truth-value-expressions)
    3. [Guard Expressions](#62-guard-expressions)
7. [Operators ➗](#7-operators)
    1. [Unary Operators](#71-unary-operators)
        1. [! (NOT)](#711-the-not-operator)
        2. [++ (increment)](#712-the-increment-operator)
        3. [-- (decrement)](#713-the-decrement-operator)
    2. [Binary Operators](#72-binary-operators)
        1. [+ (addition)](#721-the-addition-operator)
        2. [- (subtraction)](#722-the-subtraction-operator)
        3. [* (multiplication)](#723-the-multiplicative-operator)
        4. [/ (division)](#724-the-division-operator)
        5. [% (modulo)](#725-the-modulus-operator)
    3. [Comparative Operators](#73-comparative-operators)
        1. [> (greater than)](#731-the-greater-than-operator)
        2. [>= (greater than or equal to)](#732-the-greater-than-or-equal-to-operator)
        3. [< (less than)](#733-the-less-than-operator)
        4. [<= (less than or equal to)](#734-the-less-than-or-equal-to-operator)
        5. [== (equals)](#735-the-equals-operator)
        6. [!= (not equals)](#736-the-not-equals-operator)
    4. [Logical Operators](#74-logical-operators)
        1. [and](#741-the-and-operator)
        2. [or](#742-the-or-operator)
    5. [Variable Operators](#75-variable-operators)
        1. [+= (quick add)](#751-the--operator)
        2. [-= (quick subtract)](#752-the--operator)
        3. [*= (quick multiply)](#753-the--operator)
        4. [/= (quick divide)](#754-the--operator)
        5. [= (assign)](#755-the--operator)
        6. [? : (ternary operators)](#756-the-ternary-operator)
    6. [Precedence of Operators](#76-precedence-of-operators)
        1. [Unary](#761-precedence-of-unary-operators)
        2. [Binary](#762-precedence-of-binary-operators)
        3. [Comparative](#763-precedence-of-comparative-operators)
        4. [Logical](#764-precedence-of-logical-operators)
        5. [Variable](#765-precedence-of-variable-operators)
8. [Scope 👀](#8-scope)
9. [Standard Library 📚](#9-standard-library)
    1. [Math Functions](#91-math-functions)
        1. [sqrt()](#911-sqrt)
        2. [pow()](#912-pow)
        3. [floor()](#913-floor)
        4. [ceil()](#914-ceil)
        5. [round()](#915-round)
        6. [min()](#916-min)
        7. [max()](#917-max)
        8. [trunc()](#918-trunc)
    2. [Primitive Type Casting Functions](#92-primitive-type-casting-functions)
        1. [char()](#921-char)
        2. [int()](#922-int)
        3. [float()](#923-float)
        4. [bool()](#924-bool)
        5. [str()](#925-str)
    3. [Miscellaneous Functions](#9.3-miscellaneous-functions)
        1. [print()](#931-print)
        2. [len()](#932-len)
    4. [Lists](#94-lists)
        1. [append()](#941-append)
        2. [contains()](#942-contains)
    5. [Dicts](#95-dicts)
        1. [add()](#941-add)
        2. [keys()](#942-keys)
        3. [contains()](#943-contains)
10. [Sample Code 🧩](#10-sample-code)
    1. [Fizzbuzz](#101-fizzbuzz-examples)
    2. [Calculate Function Example](#calculate-function-example)
    3. [Wordcounts in a string array](#103-wordcounts-in-a-string-array)
11. [Language Grammar](#11-language-grammar)

# `1` Overview  🚁
Viper is a statically-typed imperative programming language that incorporates powerful functionality into a clean syntax. By requiring users to declare the types of functions and variables, Viper benefits from the safety mechanisms and increased efficiency of type checking. It also includes useful features like pattern matching, arrow functions, and an intuitive standard library. See the following sections for a complete introduction to the language.

## `1.1` Background
Modern day scripting languages like Python and Javascript are incredibly convenient. They make it incredibly easy to write short, readable code that makes both prototyping and collaboration a breeze. The issue, however, is that this level of convenience and accesibility comes at a cost: computational efficiency. While simple, forgiving, dynamically-typed languages like the previously mentioned are useful, it requires one to forgo the traditional compiler, and instead use an interpreter when attempting to execute code. The process of simultaneously translating into machine code and executing takes orders of magnitude more time then executing a pre-compiled piece of code, and even the efforts of just-in-time compilers like PyPy have been unsuccessful in completely bridging the gap. To achieve similar efficiency to languages like C and C++, a proper compiler is a necessity.

We set into this project with exactly that in mind: come up with a language that retains all of the simplicity, ease-of-use, and functionality of modern scripting languages, while introducing a proper static typing system to allow for efficient compilation. We wanted it to feel like you are writing in Python or Javascript, but then afterwards to feel like you are running a C program. With that in mind, we first thought about all the features we wanted to carry over from the dynamic scripting languages. First, a user has to be able to open a file and just start typing. The top-level should be a place where code is directly executed, without the need for any complex class-structure. Additionally, we would require a lot of syntactic sugar for different means of iteration, declaration, and assignment. We would also need to include the functionality of mechanics like arrow functions and ternaries, as well as standard data structures like lists and dictionaries. At this point, we also had some new ideas for features like pattern matching to replace nested ternaries and switches, and built-in index values for iterators. All together, these core ideas came to be what we now call Viper.

## `1.2` Related Work
Most features found in Viper derive from one or more of Python, Javascript, or C. While our scoping and execution rules match Python closest, Viper does not use whitespace to identify scoping, but instead uses the standard brace notation from the other two languages. Additionally, while more abstract than C (as memory allocation is handled for the user), Viper also requires static typing for all variables upon declaration. Operator precedence and applicative-order reduction is the same in Viper as one might expect from any of the aforementioned programming languages.

The one other reference worth mentioning is in relation to Viper's pattern-matching eyntax. While not exactly the same functionally, we got the idea to include this feature after extensive use of pattern matching in OCaml. Additionally, OCaml was used in almost all components of the Viper compiler pipeline, with the exception of the standard library being written in C.

## `1.3` Goals - To Preserve While Becoming Compilable:
### `Accessibility, Readability`
Despite changing to a statically typed language, we want to ensure that Viper code is just as readable and easy to learn as Python code. The only added level of difficulty should be with declaring and tracking static types. Any user should be able to begin their coding journey with this language, and and user should be able to read and understand another user's work without three cyphers and a thesaurus.

### `Prototyping/Writing Efficiency`
In addition to readability, writability is also important. We want users to be able to express their ideas quickly and effectively, with common-sense, intuitive syntax. We want to preserve the idea that the thought->prototype pipeline should be as quickly traversable as possible.

### `Functionality`
Finally, we want to make sure that in Viper, users can still do all the things they need to. While this goal is more of a continuous process rather than a current guarantee, the initial release of Viper still has a lot of the features that make languages like Python more immediately advantageous than those like C without as many supported data structures and operations.

## `1.4` How to Obtain and Use Viper
To obtain the Viper code repository, simply clone this repo: https://github.com/raghavmecheri/viper
 - Once cloned, type `cd src && make && cd ..`
 - Next, write some Viper code in a (filename).vp file (details on how to write Viper in next sections)
     - For an example, open a `test.vp` and inside write `print("hello world");`
 - Running `src/viper.native test.vp` will output the llvm code if desired
 - Running `./exec.sh test.vp` will generate three files:
     - `a.ll` = llvm code
     - `a.s` = assembly code
     - `a.exe` = executable for code
 - NOTE: Using `exec.sh` will also run `a.exe` for you
 - If you add `-v`, like: `./exec.sh test.vp -v`, you will also receive the llvm output `viper.native` would provide

[↩️  Back to Contents 📌](#0-contents)

# `2` Lexical Conventions 📝
## `2.1` Comments
Viper allows for multi-line comments that begin with an opening forward slash followed by a star (/\*) and end with a closing backward slash followed by a star (\*\\). All content within the bounds of these symbols is ignored. 

```java
/* Single-line comments anyone? */

/* How about 
multi-line? 
*/
```

## `2.2` Identifiers
All user-defined identifiers (variable and function names) must begin with an ASCII letter and can contain any mix of ASCII letters and numbers. 

Example valid identifiers:
```java
lambda_bamba
pythonCython
RatGhav
V1P3RisTh3b3sT
```

Example invalid identifiers:
```java
68vip
--!x
V*x
```

## `2.3` Reserved Keywords
Any Viper reserved keywords can not be used as user-defined identifiers. A list of reserved Viper keywords include:

```java
/* control flow */
if else for while return skip abort panic in has 

/* function and types */
func char int float bool nah string dict group 

/* operators and literals */
and or is not true false
```

## `2.4` Scoping
Viper uses a pair of opening and closing curly brackets ({}) to represents a scope of statements within control-flow and function definitions. All statements within the scope must be followed by a semi-colon, but are not required to be on a new line or indentation as previous statements. The core of the control-flow statement following the keyword must be surrounded by parenthesis as well.

Example bracket scope usage:
```java
func void foo() {
    print("bar");
}

count = 0
while (count < 10) {
    if (count % 2 == 0) {
        count += 1;
    }

    count += 1;
}
```

For more information on statements and scoping, see Section 5.

## `2.5` Literals
Literals are the values that primitive types within Viper take on within the source code.

Literals include:
* boolean
* char
* int
* float
* nah

### `2.5.1` Char Literals
Char literals represent a single ASCII character and expressed as a letter within single quotes. They also can represent escape sequences and special tokens such as '\t' and '\n'. These individual literals can be combined to make up a String when surrounded by double quotes. These character literals are always assigned to variables of the type _char_.

Examples of char literals:
```java
'a'
'+'
'\n'
```

### `2.5.2` Int Literals
Int literals represent a whole decimal number as an integer and always takes on the _int_ type. 

Examples of int literals:
```java
0
42
-70843
```

### `2.5.3` Float Literals
A float literal represents a decimal floating point number and always takes on the _float_ data type. A float literal consists of a sequence of numbers representing the whole-number part, followed by an ASCII decimal point, followed by a sequence of numbers representing the decimal portion.

Examples of float literals:
```java
123.45
-0.007
3.485
```

### `2.5.4` Boolean Literals
Boolean literals are used to indicate the truth value of an expression and are represented by the _bool_ data type. The two boolean literals used by Viper are the keywords _true_ and _false_.

### `2.5.5` String Literals
String literals are a sequence of chars surrounded by double quotes. These literals can be assigned to variables of the type _string_.

### `2.5.6` Nah Literals
The nah literal represents a reference to a null value and always takes on the nah type. This literal is represented by _nah_ made from ASCII characters.

Examples of string literals:
```java
"Stringy123"
"ratghav merch boi"
"H3sKell >>>"
```

### `2.5.7` List Literals
All list literals consist of an opening square bracket, a sequence of objects/values all of the same type sepereated by commas, and a closing square bracket. List literals must be assigned to variables of the type _list_ wrapping the same type the array literal contains. List literals can contain array list within themselves, leading to multi-dimensional lists.

Examples of valid list literals:
```java
[1, 2, 3]
["a", "b", "c"]
[[1], [10]]
```

Examples of invalid list literals:
```java
[1, 'a', "3"]
[nah, "beach"]
[1, [5, 9]]
```

[↩️  Back to Contents 📌](#0-contents)

# `3` Data Types 💾
Viper supports the same primitive and higher-order data types as many modern languages. Primitive types are supported natively, while higher-order types are implemented in Viper's [Standard Library 📚](#9-standard-library). 

## `3.1` Primitive Data Types
The six primitive types supported by Viper are `char`, `int`, `float`, `bool`, `string` and `nah`. The table below summarizes their properties and declarations, with more details in the following sections.

| Primitive Type | Size | Description | Declaration/Usage |
|-----------|-----------|-----------|-----------|
| `char` | 1 byte | Represents single ASCII characters | `char a = 'a';`<br>`char c = 'b' + 1;`<br>`char newline = '\n';` |
| `int` | 4 bytes | Stores signed integer values | `int pos = 12;`<br>`int neg = -980;`<br>`int sum = 4 + 5;` |
| `float` | 4 bytes | Stores signed floating-point numbers | `float pos = 3.2;`<br>`float neg = -29.7;`<br>`float dec = 0.003;`<br>`float whole_num = 2.0;` |
| `bool` | 1 byte | Stores either `true` or `false` | `bool t = true;`<br>`bool f = false;`<br>`bool falsy = t and f;` |
| `string` | varies | Stores a sequence of `char`s representing a word | `string s = "yeehaw"`<br>`string name = "mro";`
| `nah`  | 1 byte | Viper's `null` value | `int nil = nah;`<br>`char empt = nah;`<br>`return nah;` |

### `3.1.1` `char`
`char` is the type that represents single ASCII characters. In Viper, a `char` is represented as an ASCII character enclosed in single quotes. Special characters, like the newline and tab characters, are defined with an escape backslash (`'\n'` and `'\t'`, respectively). Each `char` behaves like an `int` in that it takes on the decimal value of its assigned ASCII character. Therefore, numerical operations that are valid for integers are also valid for `char`s.  

### `3.1.2` `int`
`int`s represent signed integer values. The minimum value of an `int` is -2<sup>31</sup>, and the maximum value is 2<sup>31</sup> - 1. Negative integer values must be defined with a preceding minus (-) symbol, but positive integer values cannot be defined with a preceding plus (+) symbol.  

### `3.1.3` `float`
`float`s represent signed floating-point numbers. To define a `float` at least one digit must precede a decimal point (.), and at least one digit must follow. For example, `.8` and `8.` are invalid, and result in syntax errors. These values are correctly defined as `0.8` and `1.0`, with padding zeroes to ensure that there is a least one digit on each side of the decimal point.  

### `3.1.4` `bool`
`bool`s hold one of the two Boolean values: `true` or `false`. Expressions using the logical `and`, logical `or`, and equality operators are evaluated to `bool`s. For example, the expression `(1 < 2) and ('c' == 'c')` evaluates to a `bool` with value `true`. Additionally, specific values of each primitive type evaluate to certain `bool` values. See the table below for details (note that `nah` always evaluates to `false`).

| Primitive Type | `true` values | `false` values |
|-----|------|-----|
| `char` | All `char`s but `'\0'` and `''` | `'\0'` and `''`
| `int` | [-2<sup>31</sup>, -1], [1, 2<sup>31</sup> - 1] | 0
| `float` | All `float`s but 0.0 | 0.0
| `bool` | `true` | `false`
| `string` | All non-empty `string`s | `""`
| `nah` | n/a | `nah`   

### `3.1.5` `string`
The `string` type of Viper is implented as a `list` of `char`s. `string`s are defined with the standard double quote notation.  
```java
string name = "Ghav";
```
Internally, a `string` is stored as a sequence of defined chars, followed by the null terminal character `'\0'`. The `string` "rat" is internally `['r', 'a', 't', '\0']`.

### `3.1.6` `nah`
`nah` is Viper's `null` value. It can be used to initialize any other data type, and is a valid return value for any function, regardless of the expected return type. Functions with no return value are declared with type `nah`.  

## `3.2` Higher-Order Data Types  
Viper also supports various higher-order data types, including `list`, `group`, and `dict`. More details can be found in the Standard Library section.

| Type | Description | Declaration/Usage |
|-----------|-----------|-----------|
| `list` | Ordered lists of any type | `int[0] array; /* Empty list */`<br>`float[] scores = [9.7, 8.2];` |
| `dict` | Key-value pairs with random access | `[int: int] pos; /* Empty */ `<br>`[string: (string, int)] items = [`<br>                          `"milk": ["dairy", 5],   `<br>                        `"apple": ["fruit", 3] ];`


### `3.2.1` `list`
Like many languages, Viper supports random access `list`s of any data type. A `list` is defined by specifying a non-`list` data type, followed by at least one set of square brackets (`[]`). Multi-dimesional lists can be created with additional sets of square brackets. `list`s have fixed types, and can be created in the following ways:
```java
/* 0. Empty lists: */
int[] dust;
float[][] edges;

/* 1. Size given implicitly by the length of the list literal: */
string[] cheese = ["chewy", "bendy", "wiggly"];
bool[][] outcomes = [[false, false], [false, true]];

/* 2. Size given implicityly by copy construction */
string[] glizzy = cheese;
```  

`list`s can be accessed and modified directly by specifying indices in square brackets. Indices are integers in the range [0, length - 1). Attempting to access or modify an index outside this range throw errors.
```java
int[] nums = [4, 0, 8];
nums[2] = nums[1];   /* Sets the last element to 0 */
nums[1] = 2;         /* Sets the middle element to 2 */

int error = nums[3]; /* Throws an error */
```

### `3.2.3` `dict` 
A `dict` is a mapping of key-value pairs. The types of both keys and values must be specified at creation, and keys must be unique. `dict` literals are defined with square brackets (`[]`), in which a colon (`:`) separates key and values, and commas separate key-value pairs.
```java
[int: string] map = [1: "one", 2: "two", 3: "three"]
```

`dict`s can be accessed and modified similarly to `list`s. Instead of using indices, however, `dict`s only accept key values. Attempting to use a key of an unexpected type, or using a key with no mapped value will result in an error.
```java
/* Note: nested dicts */
[char: [string: int]] wordmap = [
        'a': ["add": 2, "and": 3],
        'b': ["blob": 1, "bap": 14],
        'd': ["doink": 1]];
[string: int] b_words = wordmap['b']; /* Retrieves ["blob": 1, "bap": 14] */
b_words["bing"] = 4; /* Adds key-value pair ["bing": 4] to b_words */
int no_no = b_words["balloon"]; /* Error: b_words has no key "balloon" */
int bad_idea = wordmap["a"]; /* Error: key type is char, not string */
```
Empty dicts can also be declared.
```python
[string: int] rat = [];
```

[↩️  Back to Contents 📌](#0-contents)

# `4` Type System 🗃
Viper utilizes a static typing system to benefit from the provided type safety and optimizations of a staticly typed compiled language. 

## `4.1` Explicit Types
Viper requires explicit user-specified types for variable declarations, function parameters, control flow, and return types in function definitions. An explicit type is required when new variables, placeholders, and parameters are created and need a type to be referenced against.

Variable intialization and assignment:
```java
string wow; 
char x = 'y';
wow = "doge"; /* Note: not required with assignment when type of identifier has been initialized */
```

Function definitions:
```javascript
int func incrementer(int x) {
    x += 1;
}

int func sum (int c) => c + c;
```

Control-flow:
```java
for (int i = 0; i <= 10; i++) {
    print(i);
}

int[] nums = [1,2,3,4];
for (int num in nums) {
    print(num);
}
```

## `4.2` Explicit Type Conversions
Viper utilizes casting functions available in the standard library to convert between types as needed. For example, casting up from an int to a float is a simple as wrapping an integer value expression in the _float_ function.

Explicit type conversion functions include:
* toString(x) - converts x to a string
* toFloat(x) - converts x to a float
* toInt(x) - converts x to an int
* toBool(x) - converts x to a bool
* toChar(x) - converts x to a char

Examples of using explicit type conversions:
```java
/* converts 1 into '1' */
char y = toChar(1);

int x = 2;
int y = 5;
/* "25" */
string xyz = toString(2) + toString(5);
```

Note:
See Section 6 for more details on explicit type casting functions.

[↩️  Back to Contents 📌](#0-contents)

# `5` Statements 🗣
Viper programs are composed of a list of statements. Statements are selector statements, iterator statements, jump statements, and function statements. 
## `5.1` Selector Statements
Selector Statements are involved with Viper's control flow. These statements are the conditionals that Viper uses to control the flow of a program. These statements include the if statement and the if/elif/else statement.
### `5.1.1` If Statement
The if statement takes in a boolean expression within parentheses and runs the statements within its scope if the boolean expression returns true. 
### `5.1.2` If / Else if / Else Statement
The if statement has optional statements that can come after it such as elif and else. Else if will be run if the previous if statement's boolean expression was false. An else if statement is like an if statement in that it takes in a boolean expression in parentheses and if the boolean expression returns a value of true, then the statements within its scope will be run. There can be infinitely many elif statements after an if statement. The else statement must come after the if and all else if statements, if any. The else statement will run the statements inside its scope if all the if statements and elif statements have a boolean expression that returns false.
```java
if (a == b){
    print(a);
}
else if (a > b){
    print(b);
}
else{
    print("something is wrong");
}
    
```

If statements also can use a special keyword "has" to check if an element is in an array. The "has" keyword returns true if the element is in the array and false otherwise. The syntax is written by typing the name of the array, followed by "has" followed by the element.
```java
if (arr has 42){
  print(true);
}
else{
  print(false);
}
```

## `5.2` Iterator Statements
Iterator Statements are involved with Viper's ability to loop through statements. These statements compose for loops and while loops.
### `5.2.1` For Statement
A for statement takes in an argument in the form of (assignment; condition; iterator), followed by a list of statements within its scope. The assignment creates a variable and initializes it to a given number. The condition is a boolean expression; if it returns true, the list of statements within the for statement's scope is run. The iterator changes the value of the variable in the assignment. Then the condition is checked with the new value and if it returns true, the statements are run again, otherwise the statements are not run again.
```java
for (int i = 0; i < sizeof(arr); i++){  
    print(arr[i]);
}
```

A for statement can take a second form as well. The second form of a for statement is an identifer, followed by the keyword in, followed by an object that is iterable. This statement will iterate over the values in the iterable object, using the identifier for each value, and run the statements in its scope. Once there is no elements left in the iterable object, the for statement will stop.
```java
for (int element in arr) {
    print(element);
}
```
### `5.2.2` While Statement
A while statement takes in a boolean expression. If the boolean expression returns a value of true, the statements within its scope are run. After all statements are run, the boolean expression is evaluated again; if true then statements are run again, otherwise, the while statement is done. This process repeats until the boolean expression returns a value of false.
```java
while (condition){
    print("chilling");
}
```
## `5.3` Jump Statements
Jump statements are statements located within the scope of an iterator statement which dictates how to proceed within the iterator statement. 
### `5.3.1` Skip Statement
The skip statement appears in for statements and while statements. When the program encounters this statement, it will ignore any statements left in the iterator statement and go back to the beginning of the iterator statement.
```java
for (int element in arr){
    if (element == 2) {
        print("I'm going to skip the remaining statements");
    }
    skip;
    print("This element isn't a 2");
}
```
### `5.3.2` Abort Statement
The abort statement appears in for statements and while statements. When the program encounters this statement, it will ignore any statements left in the iterator statement and leave the iterator statement, proceeding with other statements within the code, if any.
```java
for (int element in arr){
    if (element == 2){
        print("found it");
    }
    abort;
}
```
## `5.4` Function Statement
Functions take input and may return output. Functions take the form of "returnType func functionName(parameter1, parameter2, ...)" The returnType is the type of the output that must be returned from the function. The func, is literally the word func. The functionName is the name of the function which must use the same convention as variables in Viper. The (parameter1, parameter2, ...), is the input of the function where each parameter is a variable. If a function is called, the statements in its scope will run, using any parameters given to the function and then returning the value of type, returnType, using the keyword return. Functions are called by writing the function name followed by a parantheses of parameters, if any. 
```java
nah func foo(){
    print("Hello World!");
}
foo();
```
### `5.4.1` Arrow Functions
Similar to arrow functions in Javascript, or Python lambda functions, users are able to define functions with arrow functions.
Users are required to specify the type of the arrow function’s return value and parameters. The syntax is as follows:

```javascript
<ret_type> func <name> (<param_type> param1, ..., <param_type> paramN)
    => expression output;
```

Note that even with zero parameters or one parameter, the () are still necessary.

Example Function Calls:
```javascript
int func y(int x, int y, int func z) {
    return z(x + y);
}
int func times (int a, int b) => a * b;
y(10, 20, times);
```
### `5.4.2` Attribute Calls
Viper supports attribute calls using a Java-like syntax with a period and parentheses in parameters. For example,
```
int[] list = [1,2,3,4];
list.contains(4); /*Attribute call of contains on list. */
```
An attribute call is equivalent to a stand-alone function call that prepends the calling object to the front of its list of parameters. The following two calls are equivalent:
```
list.contains(4);
contains(list, 4);
```

[↩️  Back to Contents 📌](#0-contents)

# `6` Expressions 🖥
Expressions in Viper yield the recipe for evaluation. Expressions can be any data type in its simplest form and it can include operators in more complex forms. These include simple arithmetic expressions which yield a float or integer type, or boolean expressions which yield a true or false when evaluated. 
## `6.1` Truth-Value Expressions
Truth-Value expressions in Viper are boolean expressions. They can include logical operators and when evaluated, must return a value of type bool. 
## `6.2` Guard Expressions
Guard expressions are an alternative way of using conditional statements. When assigning a variable, Viper uses the symbol "??" to indicate the start of a guard expression. Each subsequent statement uses a "|", except the first one and last one, followed by a boolean expression, a ":", and then a value which fits the variable data type. If the boolean expression returns a value of true, then the expression to the right of the symbol ":" is used for the value of the variable. If the boolean expression is false, the program runs the next statement following the next symbol "|". The last statement in a guard expression contains a "??" followed by a value consistent with the data type for the variable. The first statement has neither a "|" nor a "??". This can be thought of as a combination of if, elif and else statements for assigning a variable.
```python
int x = ??
4 == 4 : 42;
| 5 == 3 : 24;
?? 0;
print(x);
```
stdout:
```
42
```
[↩️  Back to Contents 📌](#0-contents)

# `7` Operators ➗
Operators are used on values to change them. This leads to interesting and complex expressions which can be useful. The different kinds of operators are Unary, Binary, Comparative, Logical and Variable.
## `7.1` Unary Operators
Unary operators act on only one value. These include the not operator, the increment operator and the decrement operator.
### `7.1.1` The NOT Operator
The NOT operator is given the symbol "!". When placed to the left of a bool, the value of the bool is flipped. If the value was true it is now false, vice versa. 
```python
bool example = true;
print(!example);
```
stdout:
```
false
```
### `7.1.2` The Increment Operator
The increment operator is given the symbol "++". When placed to the right of an integer, the value of the integer is incremented by one.
```python
int example = 0;
print(example++);
```
stdout:
```
1
```
### `7.1.3` The Decrement Operator 
The decrement operator is given the symbol "--". When placed to the right of an integer, the value of the integer is decremented by one.
```python
int example = 0;
print(example--);
```
stdout:
```
-1
```
## `7.2` Binary Operators 
Binary operators act on two values. These include the addition operator, the subtraction operator, the multiplicative operator, the division operator, and the modulus operator.
### `7.2.1` The Addition Operator
The addition operator is given the symbol, "+". It acts like addition in mathematics, i.e. it is written in between two values which result in the sum of the two values.
```python
int example1 = 1;
int example2 = 2;
print(example1 + example2);
```
stdout:
```
3
```
### `7.2.2` The Subtraction Operator
The subtraction operator is given the symbol, "-". It acts like subtraction in mathematics, i.e. it is written in between two values which result in the difference of the two values.
```python
int example1 = 1;
int example2 = 2;
print(example1 - example2);
```
stdout:
```
-1
```
### `7.2.3` The Multiplicative Operator
The multiplicative operator is given the symbol, "\*". It acts like multiplication in mathematics, i.e. it is written in between two values which result in the product of the two values.
```python
int example1 = 1;
int example2 = 2;
print(example1 * example2);
```
stdout:
```
2
```
### `7.2.4` The Division Operator
The division operator is given the symbol, "/". It acts like division in mathematics, i.e. it is written in between two values which result in the quotient of the two values.
```python
int example1 = 1;
int example2 = 2;
print(example1 / example2);
```
stdout:
```
0.5
```
### `7.2.5` The Modulus Operator
The modulus operator is given the symbol, "%". It acts like modulus in mathematics, i.e. it is written in between two values which result in the remainder of the two values when divided. 
```python
int example1 = 4;
int example2 = 2;
print(example1 % example2);
```
stdout:
```
0
```
## `7.3` Comparative Operators
Comparative Operators compare two values and returns a bool.
### `7.3.1` The Greater Than Operator
The greater than operator is given the symbol, ">". When written in between two values, it returns false if the first value is less than or equal to the second value and returns true if the first value is greater than the second value.
```python
int example1 = 2;
int example2 = 2;
print(example1 > example2);
```
stdout:
```
false
```
### `7.3.2` The Greater Than Or Equal To Operator
The greater than or equal to operator is given the symbol, ">=". When written in between two values, it returns false if the first value is less than the second value and returns true if the first value is greater than or equal to the second value.
```python
int example1 = 2;
int example2 = 2;
print(example1 >= example2);
```
stdout:
```
true
```
### `7.3.3` The Less Than Operator
The less than operator is given the symbol, "<". When written in between two values, it returns true if the first value is less than the second value and returns false if the first value is greater than or equal to the second value.
```python
int example1 = 2;
int example2 = 2;
print(example1 < example2);
```
stdout:
```
false
```
### `7.3.4` The Less Than Or Equal To Operator
The less than or equal to operator is given the symbol, "<=". When written in between two values, it returns true if the first value is less than or equal to the second value and returns false if the first value is greater than the second value.
```python
int example1 = 2;
int example2 = 2;
print(example1 <= example2);
```
stdout:
```
true
```
### `7.3.5` The Equals Operator
The equals operator is given the symbol, "==". When written in between two values, it returns true if the first value is equal to the second value and returns false if the first value is not equal to the second value.
```python
int example1 = 2;
int example2 = 2;
print(example1 == example2);
```
stdout:
```
true
```
### `7.3.6` The Not Equals Operator
The not equals operator is given the symbol, "!=". When written in between two values, it returns true if the first value is not equal to the second value and returns false if the first value is equal to the second value.
```python
int example1 = 2;
int example2 = 2;
print(example1 != example2);
```
stdout:
```
false
```
## `7.4` Logical Operators
The logical operators take in two bool values and returns a bool value. These operators include the AND operator and the OR operator. The HAS operator, which takes in an object containing elements and an element, returning a bool value.
### `7.4.1` The AND Operator
The AND operator is given the symbol, "&&". When written in between two bool values, it returns true if both values are true and false otherwise.
```python
bool example1 = true;
bool example2 = false;
print((example1 && example2));
```
stdout:
```
false
```
### `7.4.2` The OR Operator
The OR operator is given the symbol, "||". When written in between two bool values, it returns false if both values are false and true otherwise.
```python
bool example1 = true;
bool example2 = false;
print((example1 || example2));
```
stdout:
```
true
```
## `7.5` Variable Operators
Variable operators act on a variable and an integer. These include +=, -=, \*=, and /=.
### `7.5.1` The += Operator
The += operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side is added to the variable value, which is updated as the new value for the variable.
```python
int example1 = 1;
example1 += 1;
print(example1);
```
stdout:
```
2
```
### `7.5.2` The -= Operator
The -= operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side is subtracted from the variable value, which is updated as the new value for the variable.
```python
int example1 = 1;
example1 -= 1;
print(example1);
```
stdout:
```
0
```
### `7.5.3` The \*= Operator
The \*= operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side is multiplied by the variable value, which is updated as the new value for the variable.
```python
int example1 = 1;
example1 *= 1;
print(example1);
```
stdout:
```
1
```
### `7.5.4` The /= Operator
The /= operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side divides the variable value, which is updated as the new value for the variable.
```python
int example1 = 1;
example1 /= 1;
print(example1);
```
stdout:
```
1
```
### `7.5.5` The = Operator
The = operator is written between a variable name on the left hand side and a value on the right hand side. The value on the right hand side is assigned as the value for the variable on the left hand side. If the variable exists already, the value of the variable is overwritten, otherwise a new variable is created.
```python
int example1 = 1;
print(example1);
```
stdout:
```
1
```
### `7.5.6` The Ternary Operator
The Ternary Operator is given the symbol "?". This operator provides a short hand for an if-else statement and saves the result in a variable. When using the ternary operator in assigning a variable, Viper expects a boolean expression followed by the ternary operator "?". After the ternary operator, a value that matches the type of the variable being assigned is expected, followed by a ":" and another value that matches the type of the variable being assigned. If the boolean expression returns a truth value of true, then the first value is assigned to the variable, otherwise the second value is assigned.
```python
int x = 5 < 10 ? 42 : 0;
print(x);
```
stdout:
```
42
```
## `7.6` Precedence of Operators
The precedence of operators is important for determining how to write programs in Viper. It is important to note that any expression within parentheses has the highest precedence.

### `7.6.1` Precedence of Unary Operators
Unary operators receive the highest precedence, second to parentheses.

### `7.6.2` Precedence of Binary Operators
The multiplicative operator, division operator, and modulus operator are left associative and have a higher precedence than the addition operator and the subtraction operator. The addition and subtraction operator are also left associative. 

### `7.6.3` Precedence of Comparative Operators
The >, >=, <, <= operators are given higher precedence than the != and == operators.

### `7.6.4` Precedence of Logical Operators
The and operator is given higher precedence than the or operator.

### `7.6.5` Precedence of Variable Operators
Variable operators are given a lower precedence than binary operators and are right associative. 

[↩️  Back to Contents 📌](#0-contents)

# `8` Scope 👀
Viper uses curly braces to define scope.
For example, a for loop can be established in a number of different ways:
```java
for (string elem in list) {
    print(elem);
}

/* Is the same as: */

for (string elem in list)
{
    print(elem);
}

/* Is the same as: */

for (string elem in list)
{ print(elem); }
```

This will function in the same manner as expected with function definitions, conditionals, etc.

[↩️  Back to Contents 📌](#0-contents)

# `9` Standard Library 📚
Viper's standard library includes methods and functionalities that are used in nearly every program. This is to balance the tediousness of requiring numerous lines of imports and keeping compilation quick and program bloat low.

## `9.1` Math Functions
Viper provides built-in methods for common arithmetic operations.

### `9.1.1` `sqrt()`
`sqrt()` returns the square root of the given `int`, `float`, or `char` as a `float`. If a `char` is given, the decimal value of its ASCII symbol is used.
```java
float four = sqrt(16); /* Returns 4.0 */
float two = sqrt(four); /* Returns 2.0 */
float eight = sqrt('@'); /* Returns 8.0 */
```

### `9.1.2` `pow()`
`pow()` can be polymorphically used into two ways. If only one `int`, `float`, or `char` input is given, it returns the square (x<sup>2</sup>) of that input. If two `int`, `float`, or `char` inputs are given, it returns the `float` result of raising the first input to the power of the second. If `char`s are given, the decimal values of their ASCII symbols are used.
```java
float one_four_four = pow(12); /* Returns 144.0 */
float a_milly = pow(10.0, 6); /* Returns 1000000.0 */
```

### `9.1.3` `floor()`
`floor()` takes a `float` input and returns the `int` result of truncating the `float`'s decimal components.
```java
int zero = floor(0.999); /* Returns 0 */
int whole_num = floor(72.0); /* Returns 72 */
```

### `9.1.4` `ceil()`
`ceil()` does the opposite of `floor()`. It takes a `float` input and returns the closest `int` greater than or equal to the given value.
```java
int five = ceil(4.1); /* Returns 5 */
int four = ceil(4.0); /* Returns 4 */
```

### `9.1.5` `round()`
`round()` takes a `float` input and returns the closest `int` to the given value. Values of ending in .5 always round to the next greatest `int`.
```java
int three = round(3.2); /* Returns 3 */
int also_three = round(3.3); /* Returns 3 */
int neg_three = round(-3.5); /* Returns -3 */
```

### `9.1.6` `min()`
`min()` takes either two `float`s, two `int`s, or two `char`s as input and returns the smallest value between the two. If `char`s are given, the decimal values of their ASCII symbols are used. The function is overloaded, so the return type is the same as the input type.
```java
int negative1 = min(-1, 1); /* Returns -1 */
float gpa = min(5.7, 4.0); /* Returns 4.0 */
char a_char = min('b', 'a'); /* Returns 'a' */
```

### `9.1.7` `max()`
`max()` takes either two `float`s, two `int`s, or two `char`s as input and returns the largest value between the two. If `char`s are given, the decimal values of their ASCII symbols are used. The function is overloaded, so the return type is the same as the input type.
```java
int positive1 = max(-1, 1); /* Returns 1 */
float big = max(8.78, 9.9); /* Returns 9.9 */
char e_char = max('e', 'a'); /* Returns 'e' */
```

### `9.1.8` `trunc()`
`trunc()` takes a `float` and `int` as input, and returns the `float` truncated to the number of decimal points specified by the `int`. The `int` must be greater than zero.
```java
float whee = trunc(0.123456789, 3); /* Returns 0.123 */
float almost_whole_num = trunc(whee, 1); /* Returns 0.1 */
float bad_bad_bad = trunc(0.99, 0); /* Throws an error */
```

## `9.2` Primitive Type Casting Functions
Viper's standard library provides methods for casting between types for ease of use and readability. Type casting functions include:

### `9.2.1` `toChar()`
`toChar()` converts to `char`s. The input can be an `int` in range [0, 255], for which the output is the `char` corresponding to the ASCII value of the `int`. The input can also be a `string`, for which the output is the `char` value of the first character in the `string`. Passing any other types or `nah` to `toChar()` results in an error.
```java
char int_chr = char(36); /* Returns '$' */
char str_char = char(string(true)); /* Returns 't' */
char no_dont_do_it = char(33.4); /* Throws an error */
``` 

### `9.2.2` `toInt()`
`toInt()` casts certain types to integer values. Given a `char`, `toInt()` returns the decimal value of the `char`'s ASCII code. Given a `float`, `toInt()` returns the result of truncating all decimal components. Given a `bool`, `int()` returns 0 for values of `false`, and 1 for values of `true`. Passing any other types or `nah` to `toInt()` results in an error.
```java
int chr_int = toInt('R'); /* Returns 82 */
int str_int = toInt(7.999); /* Returns 7 */
int zero = toInt(false); /* Returns 0 */
int one = toInt(true); /* Returns 1 */
``` 

### `9.2.3` `toFloat()`
`toFloat()` casts `int`s and `char`s to float values. Given an `int`, `toFloat()` returns the `float` equivalent of that `int`, appending a decimal point and a single 0. Given a `char`, `float` does the same thing with the decimal value of the `char`'s ASCII code. Passing any other types or `nah` to `toFloat()` results in an error.
```java
float int_float = toFloat(333); /* Returns 333.0 */
float char_float = toFloat('&'); /* Returns 38.0 */
float noooooo = toFloat("if you smoke"); /* Returns an error */
``` 

### `9.2.4` `toBool()`
`toBool()` converts any data type to either `true` or `false`, depending on the value. It's called implicitly when using a non-boolean type in a boolean expression For example, the following code implicitly calls `toBool()` on `x`:
```java
int x = 0;
if (x) {
    print("Yes");
}
```
See the below table for details on what values `toBool()` maps to true and result in `true` and what values result in `false`:

| Type | `true` values | `false` values |
|-----|------|-----|
| `char` | All `char`s but `'\0'` and `''` | `'\0'` and `''`
| `int` | [-2<sup>31</sup>, -1], [1, 2<sup>31</sup> - 1] | 0
| `float` | All `float`s but 0.0 | 0.0
| `bool` | `true` | `false`
| `string` | All non-empty `string`s | `""`
| `nah` | n/a | `nah`   


### `9.2.5` `toString()`
`toString()` converts any type to a `string`, which is useful for printing. See the below examples for type-specific details.
```java
string char_str = toString('z'); /* Returns "z" */
string int_str = toString(30); /* Returns "30" */
string float_str = toString(34.5); /* Returns "34.5" */
string bool_str = toString(false); /* Returns "false" */
```

## `9.3` Miscellaneous Functions
These functions are unclassified, and are useful in a variety of situation.

### `9.3.1` `print()`
`print()` prints the given `string` to a new line of standard output. It throws errors if it encounters a type other than `string`, and prints an empty new line if no inputs are given. To get around this, use the [str()](#925-str()) method with `string` concatenation (+).
```java
print("Hola Mundo");
print();
print(str('a'));
print("I have " + str(388) + " bananas");
float nose = -0.3;
print(str(true) + str(nose));

/* print(4999); Uncommenting this line throws an error */
```
stdout:
```
Hola Mundo

a
I have 388 bananas
true-0.3
```

### `9.3.2` `len()`
The `len()` function is an all-purpose method that returns the `int` size of `string`s, `list`s, `group`s, and `dict`s. For `string`s, `len()` returns the number of characters in the `string` (excluding the null terminator at the end of its underlying `list` of `char`s). For `list`s, `len()` returns the number of elements in the `list`. For `group`s, `len()` returns the number of elements in the `group`, and for `dict`s, `len()` returns the number of key-value pairs.
```java
int str_length = len("Nice sock!\n\t"); /* str_length = 12 */
int list_length = len([3, 1, 6, 76]); /* list_length = 4 */
(int, float) groupie = (8, 8.8);
int group_length = len(groupie); /* group_length = 2 */
int dict_length = len(["word": 3,
                       "knees": 5, 
                       "port": 90]); /* dict_length = 3 */
```

### `9.3.3` `contains()`
The `contains()` function returns 1 if the element exists in the object of elements and 0 otherwise.
```java
char[] chrlist = ['a', 'b', 'c'];
if (chrlist.contains('a'){        /* same as contains(chrlist, 'a'); */
  print(true);
}
else{
  print(false);
}

```

## `9.4` Lists
List functionality is provided through the standard library. Lists are mutable, static sequences of a single data type with fixed sizes. Lists are accessed and modified with square brackets ([]). See [Higher-Order Data Types: lists](#321-list) for more details on instantiation and modification. The following sections describe additional list-specific operations implemented in the list api. These operations are all called on instances of lists, and thus take the form `list.operation(parameters)`.

### `9.4.1` `append()`
`append()` adds an input element to the end of a specified list. Because lists have fixed sizes, the original list remains unmodified, and `append()` returns a new list with the input element attached. The type of the input to `append()` must match the type of the list. 
```java
int[] channels = [31, 44, 21];
int[] new_channels = channels.append(54);
/* new_channels contains: [31, 44, 21, 54] */
```

### `9.4.2` `contains()`
`contains()` takes in an element of the list type and checks as to whether that element exists within the last. If the element exists, the function returns the `int` value of 1, and `int` value of 0 if the element does not exist.
```java
char[] notes = ['a', 'c', 'd', 'c'];
print(notes.contains('a'))
print(notes.contains('b'))
/*
1
-1
*/
```

## `9.5` Dicts
Dictionary functionality is provided through the standard library. Dictionaries are mutable sequences of a two data types with dynamic sizes. Dictionary key, value pairs are accessed and modified with square brackets ([]). See [Higher-Order Data Types: dicts](#322-dict) for more details on instantiation and modification. The following sections describe additional dict-specific operations implemented in the list api. These operations are all called on instances of dict, and thus take the form `dict.operation(parameters)`.

### `9.5.1` `add()`
`add()` adds an input key and value, and adds it to the dictionary. If the key already exists, then the value for the same is overriden. 
```java
[string: int] word_counts = [];
word_counts.add("a", 1);
/* word_counts contains: [["a", 1]] */
```

### `9.5.2` `keys()`
`keys()` outputs a unique list of all the keys present the dictionary. The return type for the `keys()` function is dependant on the key type for the dictionary being called. An empty list is returned if no keys exist
```java
[string: int] word_counts = [];
word_counts.add("a", 1);
print(word_counts.keys())
/* word_counts contains: ["a"] */
```

### `9.5.3` `contains()`
`contains()` takes in an of the dict's key type and returns an `int` value of `0` if the key does not exist in the dict, and `1` if it does.
```java
[string: int] word_counts = [];
word_counts.add("a", 1);
print(word_counts.contains("a"))
/*
1
*/
```

[↩️  Back to Contents 📌](#0-contents)

# `10` Sample Code 🧩
Example programs written in Viper below.

## `10.1` Fizzbuzz examples:
```java
/* standard fizzbuzz
for-loop solution */
for (int i = 1; i <= 100; i++) {
   if (i % 15 == 0) {
       print("fizzbuzz");
   } else if (i % 3 == 0) {
       print("fuzz");
   } else if (i % 5 == 0) {
       print("buzz");
   } else {
       print(i);
   }
}

/* fizzbuzz for-loop using an arrow function for divisibity*/
bool func isDivisible(int x, int div) => (x % div == 0);

for(int i = 1; i <= 100; i+=1) {
    if(isDivisible(i, 15)) {
        print("fizzbuzz");
    }
    else if(isDivisible(i, 3)) {
        print("fizz");
    } else if(isDivisible(i, 5)) {
        print("buzz");
    } else {
        print(i);
    }
}
```

## `10.2` Calculate Function Example
```java
/* Choosing an operation to compute, using if-else */
int func calc(int a, int b, char op) {
    int res;
    if(op == '+') {
        res = a + b;
    } else if (op == '-') {
        res = a - b;
    } else if (op == '*') {
        res = a * b;
    } else if (op == '/') {
        res = a / b;
    } else {
        res = a;
    }
    return res;
}

/* The same code, using guard matching!*/
int func calc(int a, int b, char op) {
    int res = ??
        op == '+' : (a + b)
      | op == '-' : (a - b)
      | op == '*' : (a * b)
      | op == '/' : (a / b)
    ?? a ;

    return res;
}
```

## `10.3` Wordcounts in a string array
```Java
[string: int] func count_words(string[] str) {
    [string: int] word_counts = [];
    for(string x in str) {
        if(word_counts.contains(x) == 1) {
            word_counts.add(x, word_counts[x] + 1);
        } else {
            word_counts.add(x, 1);
        }
    }
    return word_counts;
}

string [] test = ["Hello", "world", "succotash", "am", "world", "hello", "world", "viper", "Viper", "viper"];

[string: int] counts = count_words(test);

string[] unique_keys = counts.keys();

for(string key in unique_keys) {
    print(key);
    print("=");
    print(counts[key]);
    print("|");
}
```

# `11` Language Grammar
```
program -> decls | EOF

decls ->
  ''
| decls fdecl
| decls stmt

fdecl ->
  typ ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
| typ ID LPAREN formals_opt RPAREN ARROW stmt

formals_opt ->
  ''
| formal_list

formal_list ->
  typ ID
| formal_list COMMA typ ID

typ ->
  INT
| BOOL
| NAH
| CHAR
| FLOAT
| STRING
| typ FUNC
| typ ARROPEN ARRCLOSE
| LPAREN type_list RPAREN
| ARROPEN typ COLON typ ARRCLOSE

type_list ->
  typ
| typ COMMA type_list

stmt_list ->
  ''
| stmt_list stmt

stmt ->
  expr SEMI
| typ ID SEMI
| RETURN SEMI
| RETURN expr SEMI
| SKIP SEMI
| ABORT SEMI
| PANIC expr SEMI
| LBRACE stmt_list RBRACE
| IF LPAREN expr RPAREN stmt %prec NOELSE
| IF LPAREN expr RPAREN stmt ELSE stmt
| FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
| FOR LPAREN ID IN expr RPAREN stmt
| FOR LPAREN typ ID IN expr RPAREN stmt
| FOR LPAREN LPAREN formal_list RPAREN IN expr RPAREN stmt
| WHILE LPAREN expr RPAREN stmt

expr_opt ->
  ''
| expr

expr -> 
  INTLIT
| CHARLIT
| FLOATLIT
| STRLIT
| TRUE
| FALSE
| ID
| list_exp
| dict_exp
| expr PLUS   expr
| expr MINUS  expr
| expr TIMES  expr
| expr DIVIDE expr
| expr MODULO expr
| ID PLUS_ASSIGN expr
| ID MINUS_ASSIGN expr
| ID TIMES_ASSIGN expr
| ID DIVIDE_ASSIGN expr
| expr EQ     expr
| expr NEQ    expr
| expr LT     expr
| expr LEQ    expr
| expr GT     expr
| expr GEQ    expr
| expr AND    expr
| expr OR     expr
| expr HAS     expr
| expr QUESTION expr COLON expr
| MINUS expr %prec NEG
| NOT expr
| expr PLUS PLUS %prec INCR
| expr MINUS MINUS %prec DECR
| typ ID ASSIGN expr
| ID ASSIGN expr
| LPAREN formal_list RPAREN ASSIGN expr
| expr ARROPEN expr ARRCLOSE
| expr ARROPEN expr ARRCLOSE ASSIGN expr
| typ ID ASSIGN MATCH pattern
| ID ASSIGN MATCH pattern
| ID LPAREN actuals_opt RPAREN
| expr DOT ID LPAREN actuals_opt RPAREN
| LPAREN expr RPAREN

pattern -> c_pattern MATCH expr

c_pattern -> 
  expr COLON expr
| expr COLON expr BAR c_pattern

dict_exp -> ARROPEN dict_elems ARRCLOSE

dict_elems ->
  dict_elem
| dict_elem COMMA dict_elems

dict_elem -> expr COLON expr

list_exp -> ARROPEN list_elems ARRCLOSE

list_elems ->
  ''
| expr
| expr COMMA list_elems

actuals_opt ->
  ''
| actuals_list

actuals_list ->
  expr
| actuals_list COMMA expr
```
# `12` Project Plan
## `12.1` Specification Process
We started by creating an initial list of all the various features we thought would be cool to include in a language. While keeping in mind our initial goal of a statically-typed, compilable, scripting language, we thought about what the most important features and pieces of syntactic sugar would also have to be inherited from the inspiration languages Python and Javascript. We compiled a list of everything we thought necessary, from dicts, lists, and useful math operations to more complex features like arrow functions, ternaries, and iterator sugar. Additionally, we planned to add scoping identification through curly braces or indentation, but had to cut the white-space scoping due to time constraints.

From there, our first concrete specification came when we defined our lexicon and syntax, which then got translated into the scanner and parser, respectively. We figured out how many features we wanted to be expressible, and then decided how they would be expressed syntactically. This was then inscribed into our original Language Reference Manual.

As we continued working on semantic checks, codegen, and the standard library, we had frequent iterative updates to our specification due to new, better ideas, conflicts, or removed features. The only major changes were the removal of whitespace scoping and the addition of pattern matching. Otherwise, most changes were minor syntax changes. We also intended to add tuples (or “groups” as we called them), but ultimately decided against it in order to put resources into more interesting features.
## `12.2` Development Process
Development followed the stages of the compiler architecture. We began with the scanner, parser, and ast, with the three honestly being quite simultaneous, although each individual change occurred in that order. We then got `print(“hello world”)` working in codegen while simultaneously working on semantic checking. After hello world, we shifted into first desugaring syntax in layer one of semantic analysis, then type/validity checking in layer two. From here progress continued on updated iterations of semantic checking, while the rest of codegen and the standard library began to ramp up. The standard library was completed before the codegen, which was our final push on the project. It is worth noting that there was overlap in these tasks (they were not completed in isolation), and testing was set up at each one of these checkpoints that allowed us to easily identify where blocks were occurring. 
## `12.3` Testing Process
Viper’s test suite supports testing for semantic analysis and LLVM code generation. The test suite can also run both types of tests sequentially, allowing a complete end-to-end check of the compiler. Semantic checks scan and parse a program into an AST, desugar applicable nodes in the AST, and then semantically check the AST. Upon success, the check produces no output, indicating that the program is semantically valid and is ready to be broken down into LLVM. Upon failure, the check will print an error corresponding to the step that failed. LLVM tests have a few options. One test simply prints the LLVM of the code created in codegen.ml, allowing analysis of the generated basic blocks. The other option executes the LLVM and prints the corresponding output if valid, or a Codgen error if invalid. Testing all of our test programs runs this last option, and compares each program’s output to the corresponding .out file. If all outputs match their .out files, the test succeeds, but if any one fails, an error message is displayed describing the file that failed and the exception that resulted in failure. 
## `12.4` Team Responsibilities 
Raghav - Lexer, Parser, AST, Desugaring  
Mustafa - Lexer, Parser, AST, C Libraries  
Matthew - Semantics, Documentation  Tommy - Semantics, Documentation  
Trey - Code Generation, Documentation
## `12.5` Project Timeline
| Date          | Milestone                                        |
|---------------|--------------------------------------------------|
| February 24th | Scanner, Parser, AST Implemented and LRM Written |
| March 24th    | Hello World Implemented                          |
| April 7th     | Desugar Implemented                              |
| April 16th    | Semantic Checking Implemented                    |
| April 25th    | Codegen Implemented                              |
## `12.6` Software Development Environment
We had the following programming and development environment: 

Programming language for building compiler : Ocaml version 4.05.0  

Development environments: We used vscode and vim.

## `12.7` Programming Style
We generally wrote code according to the following style guidelines: 

Some files begin with multi-line OCaml functions that describe their purpose, especially when the file name is vague.  
Open and import statements are the first lines of compiled code in every file.  
Modules, types, data structures, exceptions, and global variables follow open statements.  
Non-nested global function declarations are preceded by multi-line OCaml comments describing general behavior.  
Nested functions are only used in their parent function, and usually don’t include descriptive comments. Particularly important nested functions include comments.  OCaml “in” statements appear at the end of lines (when applicable), allowing following “let” statements to begin the next line.  
Pattern matching guard statements for S/AST elements appear in the same order that they are defined in the S/AST.  
Pattern matching on elements with tuples uses parentheses (for example, For(e1, e2, e3, s) instead of For e1, e2, e3, s.).  
Lines generally wrap at around 80 characters, when applicable.
# `13` Architectural Design
## `13.1` The Compiler
Our compiler closely follows the structure we learned about in lecture, with the addition of a desugaring step between the parser and semantic checker. See below for more details. 
## `13.2` The Lexer
The first step of the compiler is the lexer. The lexer scans the program and creates tokens based on spaces. The tokens include common tokens such as assignment(=), operations(+,-,) etc. Some of the less common tokens Viper accepts are guards(|) and ternaries(??).
## `13.3` The Parser
After the lexer returns a list of tokens, the compiler then parses through the tokens and returns types based on the Abstract Syntax Tree. The Abstract Syntax tree separates types by expressions and statements. Statements include things like if conditionals and loops while expressions include binary operations, unary operations and some of our cool syntactic sugar like ternaries. The parser also separates the Viper program into a tuple of global statements and function declarations. This allows Viper to support statements outside of functions. The current scoping system uses “{}”. 
## `13.4` Desugaring
A big portion of the compiler is the desugaring stage. The cool parts of Viper are pattern matching, ternary operators, for loop iterators and more. These parts, while they seem new and interesting, are simply syntactic sugar. The desugaring stage takes the syntactic sugar and replaces the instances in the Abstract Syntax Tree with simpler instances such as if conditionals and while loops. The for loop is also syntactic sugar and is desugared into a while loop. 
## `13.5` The Semantic Checker
After desugaring the AST, it is sent to the semantic checker. The semantic checker is composed of several modules and driven by a driver file. First, all declarations and declaration assignments are checked for Nah types and duplicates. Viper allows for declarations inside of loops, therefore scoping becomes complicated. To achieve the desired scoping outcome, we implemented symbol tables that are connected like a tree, each having a parent which is in an outer scope. Using this method, we are able to check the declarations and declaration assignments inside of loops while creating symbol tables for the global statements and the function declarations which the driver uses. Viper also allows overloading functions, therefore the key for these symbol tables are a concatenation of the function name and the parameter types. After checking and creating these symbol tables, the driver semantically checks the global statements and then the function declarations, returning an SAST. The semantic checker then checks to see if a main exists; if it does then it does nothing, however if a main does not exist, it creates a main and puts all the global statements in it. Finally, the semantically checked global statements and function declarations are returned for code generation. 
## `13.6` The Code Generator
## `13.7` C Libraries 
The C library is used for three components of Viper, Advanced math functions/operations, List data structure and methods, Dictionary data structure and methods
The C library can be found in `library.c`, with optional tests for all standard library data structures and functions included in the main function (blocked by an ifdef). Note that `library.c` also includes `stdio.h`, `stdlib.h`, `math.h`, and `string.h`.
# `14` Testing
## `14.1` Scanner, Parser, AST 
Tests for the scanning and parsing stage contain syntactically correct code which may or may not be semantically correct code. The tests also include demonstrations of incorrect syntax which yields a syntax error. There is a test that covers everything in the AST for robustness. 
## `14.2` Semantic Checker
The AST tests are not the right kind to test on the semantic checker. This is because an assignment can be syntactically correct, however if the variable never was declared, the Semantic Checker will throw an error. Therefore a new list of tests had to be created to abide by the semantic checker. The most important tests regard type checking; this includes checking the types of declaration assignments, assignments, function return types, loop predicates, etc. This set of tests was forced to be type sensitive.
## `14.3` Code Generation 
# `15` Lessons Learned
Raghav -  

Mustafa - Grammars are wild and powerful. I had a ton of fun taking time experimenting with all of the funky syntax and features possible when building the grammar for our parser. That’s one of the bigger bottlenecks in your language’s power, so make sure to mess around with it and add some new stuff. Also, lambda calculus is cracked. Super cool lesson towards the end of the class, I absolutely loved it.  
  
Advice: Don’t try to get everything working at once. Nothing will ever work. Get one thing working. Then another. And another. The grammar, parser, and AST will need to be kinda-complete before semantics and codegen, but start by making the simplest things fully compile, then start adding more and more.  
    
Matthew - I have a newfound respect for semantic checking, which is where I spent a majority of my time coding. The semantic checker is the glue between the frontend and backend of the compiler. I needed to make sure that I was reaching every case in the AST properly, bend to the structure in which our program is situated, and then return a simplified SAST to make codegen as easy as it can be. I also learned how important communication is for a large project with many moving parts. A lot of time can be saved by collaborating and planning the architecture of the compiler together opposed to trying to figure out everyone's code alone.

Advice: Start early, ask questions, and try to have your demo working early so that you can build more and enjoy the potential of writing a compiler.

Tommy - The beauty of this course is that it bridges the gap between programmer and computer. Before PLT, I knew almost nothing about the compilation process, except that it magically sucks in a program and produces some output. Today, not only do I know how to think like a programmer, but I’ve also learned how to think like a computer. I now understand why programming languages look the way they do, and what implications small changes in code can have for the computer running it, down to the lowest levels of compilation. Knowing how the code I write will be interpreted, checked, and eventually run has made me a more thoughtful developer and a more efficient debugger. In addition to this general knowledge, I’ve picked up a number of concrete skills. Some of these include generating Makefiles, better understanding the command line, thinking about low-level languages like LLVM and assembly, and of course, coding in the first functional language I’ve seen, OCaml.

Advice: My advice to future students would be to start with a smaller set of language functionality. We started by brainstorming our favorite features of many different languages, and then sought to encapsulate them all in Viper. This seemed really cool at first, but we didn’t realize how much work it would create in the future. By the time we got to code generation, we were stretched pretty thin, and we weren’t able to flush out all of our language’s features as fully as I would have liked. I also would recommend not using as much desugaring as we did. While desugars seemed like clever and efficient ways to bring new features to Viper’s syntax, they proved to be difficult to maintain in semantic checking and LLVM generation. Keeping them as their own statements makes for more work, but allows for better control and understanding of the language as a whole.

Trey - 
# `16` Appendix



[↩️  Back to Contents 📌](#0-contents)
