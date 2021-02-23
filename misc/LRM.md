# Overview
Tommy

# Lexical Conventions
## 2.1) TODO: Comments
Single-line comments begin with a single octothorpe (#) when used outside of a string literal. All content until the end of the physical line is ignored.

Viper allows for multi-line comments that begin with an opening forward slash followed by a star (/\*) and end with a closing backward slash followed by a star (\*\\). All content within the bounds of these symbols is ignored.

## 2.2) Identifiers
All user-defined identifiers (variable and function names) must begin with an ASCII letter and can contain any mix of ASCII letters and numbers. 

Example valid identifiers:
```
lambda_bamba
pythonCython
RatGhav
V1P3RisTh3b3sT
```

Example invalid identifiers:
```
68vip
--!x
V*x
```

## 2.3) TODO: Reserved Keywords, Identifiers, and Operators
Any Viper reserved keywords can not be used as user-defined identifiers. A list of reserved Viper keywords include:


```
# control flow
while if elif else for in skip abort panic 

# function and types
func return char int float bool nah string dict group 

# operators and values
+ - * / // ** = == != > >= < <= -= += and or is not true false
```

## 2.4) TODO: Indentation and Scoping
TODO: Do we have +=, -=, etc? The mix use of semicolons is kind of confusing, we should pick one (require them everywhere?) 

Viper allows for users to choose how they want to signify scoping and groups of statements within their programs. Following the use of a control-flow structure or function definition, users can choose to utilize indentation or brackets to signify scope as long as their use is consistent within the scope. 

When using indentation, the number of tabs (or equivalent number of spaces) determines how statements are grouped. All control-flow and function definitions must be immediately followed by a single colon and each statement within the desired scope must be indented one tab further than the line that begins the scope.

Example indentation usage:
```
func void foo():
    print("bar")

count = 0
while count < 10:
    if count % 2 == 0:
        count += 1
    
    count += 1
```

When using brackets, a pair of opening and closing curly brackets ({}) represents a scope of statements within control-flow and function definition. All statements within the scope must be followed by a semi-colon, but are not required to be on a new line or indentation as previous statements. The core of the control-flow statement following the keyword must be surrounded by parenthesis as well.

Example bracket scope usage:
```
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

## 2.5) Literals
Literals are the values that primitive types within Viper take on within the source code.

Literals include:
* boolean
* char
* int
* float
* nah

### 2.5.1) Boolean Literals
Boolean literals are used to indicate the truth value of an expression and are represented by the _bool_ data type. The two boolean literals used by Viper are the keywords _true_ and _false_.


### 2.5.2) Char Literals
Char literals represent a single Unicode letter and expressed as a letter within single quotes. They also can represent escape sequences and special tokens such as '\t' and '\n'. These individual literals can be combined to make up a String when surrounded by double quotes. These character literals are always assigned to variables of the type _char_. 

Examples of char literals:
```
'a'
'+'
'\n'
'\\'
```

### 2.5.3) Int Literals
Int literals represent a whole decimal number as an integer and always takes on the _int_ type. 

Examples of int literals:
```
0
42
-70843
```

### 2.5.4) Float Literals
A float literal represents a decimal floating point number and always takes on the _float_ data type. A float literal consists of a sequence of numbers representing the whole-number part, followed by an ASCII decimal point, followed by a sequence of numbers representing the decimal portion.

Examples of float literals:
```
123.45
-0.007
3.485
```

### 2.5.5) Nah Literals
The nah literal represents a reference to a null value and always takes on the nah type. This literal is represented by _nah_ made from ASCII characters.


# Data Types  
Viper supports the same primitive and higher-order data types as many modern languages. Primitive types are supported natively, while higher-order types are implemented in Viper's standard library. 

## Primitive Data Types
The five primitive types supported by Viper are `char`, `int`, `float`, `bool`, and `nah`. The table below summarizes their properties and declarations, with more details in the following sections.  
| Primitive Type | Size | Description | Declaration/Usage |
|-----------|-----------|-----------|-----------|
| `char` | 2 bytes | Represents single ASCII characters | `char a = 'a';`<br>`char c = 'b' + 1;`<br>`char newline = '\n';` |
| `int` | 8 bytes | Stores signed integer values | `int pos = 12;`<br>`int neg = -980;`<br>`int sum = 4 + 5;` |
| `float` | 8 bytes | Stores signed floating-point numbers | `float pos = 3.2;`<br>`float neg = -29.7;`<br>`float dec = 0.003;`<br>`float whole_num = 2.0;` |
| `bool` | 1 byte | Stores either `true` or `false` | `bool t = true;`<br>`bool f = false;`<br>`bool falsy = t && f;` |
| `nah`  | 1 byte | Viper's `null` value | `int nil = nah;`<br>`char empt = nah;`<br>`return nah;` |

### `char`
`char` is the type that represents single ASCII characters. In Viper, a `char` is represented as an ASCII character enclosed in single quotes. Special characters, like the newline and tab characters, are defined with an escape backslash (`'\n'` and `'\t'`, respectively). Each `char` behaves like an `int` in that it takes on the decimal value of its assigned ASCII character. Therefore, numerical operations that are valid for integers are also valid for `char`s.  

### `int`
`int`s represent signed integer values. The minimum value of an `int` is -2<sup>31</sup>, and the maximum value is 2<sup>31</sup> - 1. Negative integer values must be defined with a preceding minus (-) symbol, but positive integer values cannot be defined with a preceding plus (+) symbol.  

### `float`
`float`s represent signed floating-point numbers. To define a `float` at least one digit must precede a decimal point (.), and at least one digit must follow. For example, `.8` and `8.` are invalid, and result in syntax errors. These values are correctly defined as `0.8` and `1.0`, with padding zeroes to ensure that there is a least one digit on each side of the decimal point.  

### `bool`
`bool`s hold one of the two Boolean values: `true` or `false`. Expressions using the logical and (`&&`), logical or (`||`), and equality operators are evaluated to `bool`s. For example, the expression `(1 < 2) && ('c' == 'c')` evaluates to a `bool` with value `true`. Additionally, specific values of each primitive type evaluate to certain `bool` values. See the table below for details (note that `nah` always evaluates to `false`).  
| Primitive Type | `true` values | `false` values |
|-----|------|-----|
| `char` | All values but `'\0'` | `'\0'`
| `int` | [-2<sup>31</sup>, -1], [1, 2<sup>31</sup> - 1] | 0
| `float` | All values but 0.0 | 0.0
| `bool` | `true` | `false`
| `nah` | n/a | `nah`   

### `nah`
`nah` is Viper's `null` value. It can be used to initialize any other data type, and is a valid return value for any function, regardless of the expected return type. Functions with no return value are declared with type `nah`.  

## Higher-Order Data Types  
Viper also supports various higher-order data types, including `list`, `string`, `group`, and `dict`. More details can be found in the Standard Library section.
| Type | Description | Declaration/Usage |
|-----------|-----------|-----------|
| `list` | Ordered lists of any type | `int[3] array; /* Empty list of size 3 */`<br>`float[] scores = [9.7, 8.2];` |
| `string` | Stores sequences of character literals | `string pet = "bear";`<br>`string date = "2/24/21";` |
| `group` | Lightweight structure to hold type-specified collections of data | `(int x, int y) coord = (3, -4);`<br>`(string, int) name_id = ("Bon", 4432);` |
| `dict` | Key-value pairs with random access | `[int: int] pos; /* Empty */ `<br>`[string: (string, int)] items = [`<br>                          `"milk": ("dairy", 5),   `<br>                        `"apple": ("fruit", 3) ];`


### `list`
Like many languages, Viper supports random access `list`s of any data type. A `list` is defined by specifying a non-`list` data type, followed by at least one set of square brackets (`[]`). Multi-dimesional lists can be created with additional sets of square brackets. `list`s have fixed types and fixed lengths, which must be declared at creation in the following ways:
```java
/* 0. Empty with size explicitly given: */
int[3] dust;
float[10][10] edges;

/* 1. Size given implicitly by the length of the list literal: */
string[] cheese = ["chewy", "bendy", "wiggly"];
bool[][] outcomes = [[false, false], [false, true]];

/* 2. Size given implicityly by copy construction */
string[] glizzy = cheese;
```  

`list`s can be accessed and modified directly by specifying indices in square brackets. Indices are integers in the range [0, length - 1). Attempting to access or modify an index outside this range throw errors.
```java
int[3] nums = [4, 0, 8];
nums[2] = nums[1];   /* Sets the last element to 0 */
nums[1] = 2;         /* Sets the middle element to 2 */

int error = nums[3]; /* Throws an error */
```

### `string`
The `string` type of Viper is implented as a `list` of `char`s. `string`s are defined with the standard double quote notation.  
```java
string name = "Ghav"
```
Internally, a `string` is stored as a sequence of defined chars, followed by the null terminal character `'\0'`. The `string` `rat` is internally `['r', 'a', 't', '\0]`.

### `group`  
A `group` is a type-specified collection of data. Any number of types can be specified, but their order is fixed. `group`s are declared with parentheses:
```java
(string, int) order = ("Chicken Katsu", 17);
(float[2], string, bool) = ([0.1, 2.1], "boo", false);
```
Elements of `group`s can be accessed and modified by passing an index into a set of parentheses. Like `list` indices, `group` indices are zero-indexed and must be in the range [0, length - 1).
```java
(int, int) paws = (3, -2);
int x = paws(1); /* Sets x to 3 */
paws(2) = x;     /* Sets paws(2) to 3 */
```
Elements of `groups` can also be named at creation. Named elements are then accessible and modifyable by using their names as indices.
```java
(int r, int g, int b) color = (240, 130, 202);
int red = color(r);
color(b) = 112;
```
### `dict` 
A `dict` is a mapping of key-value pairs. The types of both keys and values must be specified at creation, and keys must be unique. `dict` literals are defined with square brackets (`[]`), in which a colon (`:`) separates key and values, and commas separate key-value pairs.
```java
[int: string] map = [1: "one", 2: "two", 3: "three"]
```

`dict`s can be accessed and modified similarly to `list`s. Instead of using indices, however, `dict`s only accept key values. Attempting to use a key of an unexpected type, or using a key with no mapped value will result in an error.
```java
/* Note: nested dicts */
[char: [int: string]] wordmap = [
        'a': [1: "aab", 2: "ab"],
        'b': [1: "baa", 2: "bad"],
        'c': [1: "cbb"]];
[int: string] b_words = wordmap['b']; /* Retrieves [1: "baa", 2: "bad"] */
b_words[3] = "bing";
int no_no = b_words[4]; /* Error: dict has no key 3 */
int bad_idea = wordmap["a"]; /* Error: key type is char, not string */
```

# Type System
## Overview
Viper utilizes a static typing system to benefit from the provided type safety and optimizations of a staticly typed compiled language. 

## Explicit Types
Viper requires explicit user-specified types for variable declarations, function parameters, and return types in function definitions. 

Examples include:
```
char x = 'y';

func int foo(int x) {
    return x+1;
}
```

## TODO: Implicit Type Conversions

## TODO: User Defined Types?

# 5) Statements, Expressions, Operators and Scope
## 5.1) Statements
Viper programs are composed of a list of statements. Statements are selector statements, iterator statements and jump statements. 
### 5.1.1) Selector Statements
Selector Statements are involved with Viper's control flow. These statements are the conditionals that Viper uses to control the flow of a program. These statements include the if statement and the if/elif/else statement.
#### 5.1.1.1) If Statement
The if statement takes in a boolean expression within parentheses and runs the statements within its scope if the boolean expression returns true. 
#### 5.1.1.2) If/Elif/Else Statement
The if statement has optional statements that can come after it such as elif and else. Elif is shorthand for "else if" which means that it will be run if the previous if statement's boolean expression was false. An elif statement is like an if statement in that it takes in a boolean expression in parentheses and if the boolean expression returns a value of true, then the statements within its scope will be run. There can be infinitely many elif statements after an if statement. The else statement must come after the if and all elif statements, if any. The else statement will run the statements inside its scope if all the if statements and elif statements have a boolean expression that returns false.
```python
if a == b:
    print(a)
elif a > b:
    print(b)
else:
    print("something is wrong")
    
```
### 5.1.2) Iterator Statements
Iterator Statements are involved with Viper's ability to loop through statements. These statements compose for loops and while loops.
#### 5.1.2.1) For Statement
A for statement takes in an argument in the form of (assignment; condition; iterator), followed by a list of statements within its scope. The assignment creates a variable and initializes it to a given number. The condition is a boolean expression; if it returns true, the list of statements within the for statement's scope is run. The iterator changes the value of the variable in the assignment. Then the condition is checked with the new value and if it returns true, the statements are run again, otherwise the statements are not run again.
```C
for (int i = 0; i<sizeof(arr); i++){  # More on indentation vs explicit scoping below
    print(arr[i]);
}
```

A for statement can take a second form as well. The second form of a for statement is an identifer, followed by the keyword in, followed by an object that is iterable. This statement will iterate over the values in the iterable object, using the identifier for each value, and run the statements in its scope. Once there is no elements left in the iterable object, the for statement will stop.
```python
for int element in arr:
    print(element)
```
#### 5.1.2.2) While Statement
A while statement takes in a boolean expression. If the boolean expression returns a value of true, the statements within its scope are run. After all statements are run, the boolean expression is evaluated again; if true then statements are run again, otherwise, the while statement is done. This process repeats until the boolean expression returns a value of false.
```python
while (condition):
    print("chilling")
```
### 5.1.3) Jump Statements
Jump statements are statements located within the scope of an iterator statement which dictates how to proceed within the iterator statement. 
#### 5.1.3.1) Skip Statement
The skip statement appears in for statements and while statements. When the program encounters this statement, it will ignore any statements left in the iterator statement and go back to the beginning of the iterator statement.
```python
for int element in arr:
    if element == 2:
        print("I'm going to skip the remaining statements")
    skip
    print("This element isn't a 2")
```
#### 5.1.3.2) Abort Statement
The abort statement appears in for statements and while statements. When the program encounters this statement, it will ignore any statements left in the iterator statement and leave the iterator statement, proceeding with other statements within the code, if any.
```python
for int element in arr:
    if element == 2:
        print("found it")
    abort
```
## 5.2) Expressions
Expressions in viper yield the recipe for evaluation. Expressions can be any data type in its simplest form and it can include operators in more complex forms. These include simple arithmetic expressions which yield a float or integer type, or boolean expressions which yield a true or false when evaluated. Functions, which take in input as parameters and returns a value are also considered expressions in Viper.
### 5.2.1) Truth-Value Expression
Truth-Value expressions in Viper are boolean expressions. They can include logical operators and when evaluated, must return a value of type bool. 
### 5.2.2) Functions
Functions take input and may return output. Functions take the form of "returnType func functionName(parameter1, parameter2, ...)" The returnType is the type of the output that must be returned from the function. The func, is literally the word func. The functionName is the name of the function which must use the same convention as variables in Viper. The (parameter1, parameter2, ...), is the input of the function where each parameter is a variable. If a function is called, the statements in its scope will run, using any parameters given to the function and then returning the value of type, returnType, using the keyword return. Functions are called by writing the function name followed by a parantheses of parameters, if any. 
```python
nah func foo():
    print("Hello World!")
foo()
```
#### 5.2.2.1) Arrow Functions
Similar to arrow functions in Javascript, or Python lambda functions, users are able to define functions with arrow functions.
Users are required to specify the type of the arrow function’s return value and parameters. The syntax is as follows:

```javascript
<ret_type> (<param_type> param1, ..., <param_type> paramN) => expression output
```

```javascript
<ret_type> (<param_type> param1, ..., <param_type> paramN) => {
    return complex expression output
}
```

```javascript
<ret_type> (<param_type> param1, ... , <param_type> paramN) => :
    return complex expression output
```

Additionally, these arrow functions can be assigned to function variables:

```javascript
func x = <ret_type> (<param_type> param1, ...,<param_type> paramN) => {
    return expression output
}
```

Note that even with zero parameters or one parameter, the () are still necessary
```javascript
func myFunc = <ret_type> () => expression output

<ret_type> (<param_type> param) => expression output
```

Example Function Calls:
```javascript
int func y(int x, int y, func z) {
    return z(x + y);
}

y(10, 20, int (int a, int b) => a * b);
```

Anonymous Function Call Example

```javascript
nah (int a, int b) => {
    print(a);
    print(b);
} (10, 20);
``` 
### 5.2.3) Guard Expression
Guard expressions are an alternative way of using conditional statements. When assigning a variable, Viper uses the symbol "??" to indicate the start of a guard expression. Each subsequent statement uses a "|" followed by a boolean expression, a ":", and then a value which fits the variable data type. If the boolean expression returns a value of true, then the expression to the right of the symbol ":" is used for the value of the variable. If the boolean expression is false, the program runs the next statement following the next symbol "|". The last statement in a guard expression contains a "|" followed by a value consistent with the data type for the variable. This can be thought of as a combination of if, elif and else statements for assigning a variable.
```python
int x = ??
| 4 == 4 : 42;
| 0;
print(x);
```
stdout:
```
42
```
## 5.3) Operators
Operators are used on values to change them. This leads to interesting and complex expressions which can be useful. The different kinds of operators are Unary, Binary, Comparative, Logical and Variable.
### 5.3.1) Unary Operators
Unary operators act on only one value. These include the not operator, the increment operator and the decrement operator.
#### 5.3.1.1) The NOT Operator
The NOT operator is given the symbol "!". When placed to the left of a bool, the value of the bool is flipped. If the value was true it is now false, vice versa. 
```python
bool example = true;
print(!example);
```
stdout:
```
false
```
#### 5.3.1.2) The Increment Operator
The increment operator is given the symbol "++". When placed to the right of an integer, the value of the integer is incremented by one.
```python
int example = 0;
print(example++);
```
stdout:
```
1
```
#### 5.3.1.3) The Decrement Operator 
The decrement operator is given the symbol "--". When placed to the right of an integer, the value of the integer is decremented by one.
```python
int example = 0;
print(example--);
```
stdout:
```
-1
```
### 5.3.2) Binary Operators 
Binary operators act on two values. These include the addition operator, the subtraction operator, the multiplicative operator, the division operator, and the modulus operator.
#### 5.3.2.1) The Addition Operator
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
#### 5.3.2.2) The Subtraction Operator
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
#### 5.3.2.3) The Multiplicative Operator
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
#### 5.3.2.4) The Division Operator
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
#### 5.3.2.5) The Modulus Operator
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
### 5.3.3) Comparative Operators
Comparative Operators compare two values and returns a bool.
#### 5.3.3.1) The Greater Than Operator
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
#### 5.3.3.2) The Greater Than Or Equal To Operator
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
#### 5.3.3.3) The Less Than Operator
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
#### 5.3.3.4) The Less Than Or Equal To Operator
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
#### 5.3.3.5) The Equals Operator
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
#### 5.3.3.6) The Not Equals Operator
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
### 5.3.4) Logical Operators
The logical operators take in two bool values and returns a bool value. These operators include the AND operator and the OR operator.
#### 5.3.4.1) The AND Operator
The AND operator is given the symbol, "and". When written in between two bool values, it returns true if both values are true and false otherwise.
```python
bool example1 = true;
bool example2 = false;
print((example1 and example2));
```
stdout:
```
false
```
#### 5.3.4.2) The OR Operator
The OR operator is given the symbol, "or". When written in between two bool values, it returns false if both values are false and true otherwise.
```python
bool example1 = true;
bool example2 = false;
print((example1 or example2));
```
stdout:
```
true
```
### 5.3.5) Variable Operators
Variable operators act on a variable and an integer. These include +=, -=, \*=, and /=.
#### 5.3.5.1) The += Operator
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
#### 5.3.5.2) The -= Operator
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
#### 5.3.5.3) The \*= Operator
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
#### 5.3.5.4) The /= Operator
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
#### 5.3.5.5) The = Operator
The = operator is written between a variable name on the left hand side and a value on the right hand side. The value on the right hand side is assigned as the value for the variable on the left hand side. If the variable exists already, the value of the variable is overwritten, otherwise a new variable is created.
```python
int example1 = 1;
print(example1);
```
stdout:
```
1
```
### 5.3.6) Precedence of Operators
The precedence of operators is important for determining how to write programs in Viper. It is important to note that any expression within parentheses has the highest precedence.
#### 5.3.6.1) Precedence of Unary Operators
Unary operators receive the highest precedence, second to parentheses.
#### 5.3.6.2) Precedence of Binary Operators
The multiplicative operator, division operator, and modulus operator are left associative and have a higher precedence than the addition operator and the subtraction operator. The addition and subtraction operator are also left associative. 
#### 5.3.6.3) Precedence of Comparative Operators
The >, >=, <, <= operators are given higher precedence than the != and == operators.
#### 5.3.6.4) Precedence of Logical Operators
The and operator is given higher precedence than the or operator.
#### 5.3.6.5) Precedence of Variable Operators
Variable operators are given a lower precedence than binary operators and are right associative. 
## 5.4) Scope
Scope in Python is traditionally defined with whitespace.
Viper retains this option, while also giving users the alternative (via curly braces) to take a more traditional approach and avoid whitespace concerns.
With this method, everything within the scope will be equivalent to four added spaces of indentation.
Note that if this method is used, whitespace will be ignored for everything within the scope and every statement within a scope defined by `{}` must end with a semicolon.
For example, a for loop can be established in a number of different ways:
```go
for string elem in list:
    print(elem)

# Is the same as:

for string elem in list {
    print(elem);
}

# Is the same as:

for string elem in list
{
    print(elem);
}

# Is the same as:

for string elem in list
{ print(elem); }
```

Examples of snippets that wouldn't work are:
```go
for string elem in list
{
    for char letter in elem:
        print(letter)
}
```

Once you use traditional scoping, whitespace is ignored. The other way around would work fine though:
```go
for string elem in list:
    for char letter in elem 
    {
        print(letter);
    }
```

This will function in the same manner as expected with function definitions, conditionals, etc.

# 6) Standard Library

## 6.1) Type Casting

## 6.2) Lists

## 6.3) Strings


# 7) Sample Code
Example programs writtin in Viper below.

Fizzbuzz examples:
```{java}
# fizzbuzz for-loop solution
# standard simple solution
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

# fizzbuzz for-loop with nested ternary operator
# valid, but overly complex solution
for (int i = 0; i <= 100; i++) {
    (i % 15 == 0) 
        ? print("fizzbuzz")
        : (i % 3 == 0) 
            ? print("fizz") 
            : (i % 5 == 0)
                ? print("buzz")
                : print(i);
}

# fizzbuzz for-loop with pattern-matching
# valid, short, and easily comprehensible solution
for (int i = 0; i <= 100; i++) {
    string output = ??
        i % 15 == 0 : "fizzbuzz"
        | i % 3 == 0 : "fizz"
        | i % 5 == 0 : "buzz"
        ?? i;

    print(output);
}
```

Int array sum examples:
```{java}
# printing an average of a list of ints, (almost) C-style
int[] nums = [1, 2, 3, 4];
int sum = 0;

for(int i = 0; i < len(nums); i++) {
    sum = sum + nums[i];
}

float avg = sum/len(nums);
print(avg);

# printing an average of a list of ints using Viper conventions
int[] nums = [1, 2, 3, 4];
int sum = 0;

for (num in nums) {
    sum += num;
}

float avg = sum/len(nums);
print(avg)

# printing an average of a list of ints using Viper standard library
int[] nums = [1,2,3,4];
float avg = sum(nums)/len(nums);
print(avg)