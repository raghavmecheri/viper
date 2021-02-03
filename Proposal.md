# Viper

An amalgamation of all our favourite language quirks.

## Overview

Viper is a statically typed imperative scripting language with similar syntax to Python and the safety mechanisms (an increased efficiency) of type checking. Cython forces the user to declare types of functions and variables, as one would do for C, yet in an easy to read and write syntax that mimics the simplicity of Python. 

Our goals for Viper are:
* Python-styled syntax
* Types and Type Checking
* Choice of how to incorporate scope (whitespace or brackets) -- get rid of Python's tab/spaces issues
* Arrow Functions/Lambdas

# Basic Language Details

## Data Types and Operations
The standard data types in Viper are integers, floats, booleans, and characters.
Strings are simply arrays of characters.
Viper also includes a null data type, which is defined with the keyword null.
The primitive data structure which all other data structures will be built off is the array.


| Data Type 	| Description              	| Operations                                                  	| Examples                                  	|
|-----------	|--------------------------	|-------------------------------------------------------------	|-------------------------------------------	|
| char      	| A 1 byte character       	| =, ==, !=, +, ++,<br>–, <, >, =<, >=                        	| a + b<br>a >= b<br>a <= b                 	|
| int       	| A 8 byte number          	| =, ==, !=, +, -, *,<br>/, %, ++, –, +=, -=, <, >,<br>=<, >= 	| a = 1<br>a > b<br>a == b                  	|
| float     	| An 8 byte decimal number 	| =, ==, !=, +, -, *,<br>/, %, ++, –, +=, -=, <, >,<br>=<, >= 	| a = 1<br>a > b<br>a == b                  	|
| bool      	| A 1 byte boolean value   	| =, ==, !=, !, &&                                            	| a == b<br>a != b<br>!(a == b)<br>(a && b) 	|

The standard library will consist of data structures such as stacks, queues, hash maps, etc.
Viper will use imperative-style control-flow mechanisms such as the for loop and while loop.
Viper will also use if/else/elif statements. 
Viper will be able to perform addition, subtraction, multiplication, division, compare (greater than, less than, equals), modulus, powers, concatenation, and increment/decrement. We will also have arrays of primitives, and an array of `char` types would constitute a string.
See the below tables for a summary of each operation and its respective symbol.

## Keywords

|    Keyword   	|                        Usage                       	|
|:------------:	|:--------------------------------------------------:	|
| char         	| Declares a character                               	|
| int          	| Declares an integer                                	|
| float        	| Declares a floating-point number                   	|
| bool         	| Declares a boolean                                 	|
| nah           | Declares our equivalent of a nulltype                 |
| panic         | Throws an exception                                   |
| func         	| Defines a function                                 	|
| return       	| Specifies the return value of a function           	|
| abort         | Our equivalent of a break statement                   |
| skip          | Skips the loop iteration - equivalent of continue     |
| for/while    	| Defines a for or while loop, respectively          	|
| if/else/elif 	| Controls the flow of if, else, and elif statements 	|
| in           	| Specifies direct, index-free iteration             	|
| true          | true boolean value                                    |
| false         | false boolean value                                   |

## Control Flow (Todo: Ottomano)
TODO

## Functions (Todo: Raghav)
TODO

## Comments (Todo: Trey)
TODO

## Memory
The Viper language will be call by value like Python is, and all memory management will be handled internally by a simple garbage collector.

# Unique Features 

## Statically Typed Variables (Todo: Trey)
TODO

## Scope Definition Options
Scope in Python is traditionally defined with whitespace.
Viper retains this option, while also giving users the alternative to take a more traditional approach and avoid whitespace concerns.
Instead, $~ will be used to open a local scope, and ~$ will be used to close the scope.
With this method, everything within the scope will be equivalent to four added spaces of indentation.
Note that if this method is used, whitespace will be ignored for everything within the scope.
Also, all lines must be ended with a semicolon. For example, a for loop can be established in a number of different ways:
```
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
```
for string elem in list
{
    for char letter in elem:
        print(letter)
}
```

Once you use traditional scoping, whitespace is ignored. The other way around would work fine though:
```
for string elem in list:
    for char letter in elem 
    {
        print(letter);
    }
```

This will function in the same manner as expected with function definitions, conditionals, etc.

## Arrow Functions
Similar to arrow functions in Javascript, or Python lambda functions, users will be able to define functions on the fly with arrow functions.
Users are required to specify the type of the arrow function’s return value and parameters. The syntax is as follows:

```
<ret_type> (<param_type> param1, ..., <param_type> paramN) => expression output
```

```
<ret_type> (<param_type> param1, ..., <param_type> paramN) => { # (multi-line expression)
    Complex expression output
}
```

```
<ret_type> (<param_type> param1, ... , <param_type> paramN) => :
    Complex expression output
```

Additionally, these arrow functions can be assigned to function variables:

```
func x = <ret_type> (<param_type> param1, ...,<param_type> paramN) => expression output
```

Note that even with zero parameters or one parameter, the () are still necessary
```
func myFunc = <ret_type> () => expression output

<ret_type> (<param_type> param) => expression output
```

Example Function Calls:
```
# Example Use Case

int func y(int x, int y, func z) {
    return z(x + y);
}

y(10, 20, int (int a, int b) => a * b);

# Anonymous Function Call Example

nah (int a, int b) => {
    print(a);
    print(b);
}(10, 20);
```

## Syntactic Sugar (Todo: Tommy)
TODO
