# Overview
Tommy

# Lexical Conventions
Trey

# Data Types
Tommy

# Type System
Trey

# 5 Statements, Expressions, Operators and Scope
## 5.1 Statements
Viper programs are composed of a list of statements. Statements are selector statements, iterator statements and jump statements. 
### 5.1.1 Selector Statements
Selector Statements are involved with Viper's control flow. These statements are the conditionals that Viper uses to control the flow of a program. These statements include the if statement and the if/elif/else statement.
#### 5.1.1.1 If Statement
The if statement takes in a boolean expression within parentheses and runs the statements within its scope if the boolean expression returns true. 
#### 5.1.1.2 If/Elif/Else Statement
The if statement has optional statements that can come after it such as elif and else. Elif is shorthand for "else if" which means that it will be run if the previous if statement's boolean expression was false. An elif statement is like an if statement in that it takes in a boolean expression in parentheses and if the boolean expression returns a value of true, then the statements within its scope will be run. There can be infinitely many elif statements after an if statement. The else statement must come after the if and all elif statements, if any. The else statement will run the statements inside its scope if all the if statements and elif statements have a boolean expression that returns false.
```python
if a == b:
    print(a)
elif a > b:
    print(b)
else:
    print("something is wrong")
    
```
### 5.1.2 Iterator Statements
Iterator Statements are involved with Viper's ability to loop through statements. These statements compose for loops and while loops.
#### 5.1.2.1 For Statement
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
#### 5.1.2.2 While Statement
A while statement takes in a boolean expression. If the boolean expression returns a value of true, the statements within its scope are run. After all statements are run, the boolean expression is evaluated again; if true then statements are run again, otherwise, the while statement is done. This process repeats until the boolean expression returns a value of false.
```python
while (condition):
    print("chilling")
```
### 5.1.3 Jump Statements
Jump statements are statements located within the scope of an iterator statement which dictates how to proceed within the iterator statement. 
#### 5.1.3.1 Skip Statement
The skip statement appears in for statements and while statements. When the program encounters this statement, it will ignore any statements left in the iterator statement and go back to the beginning of the iterator statement.
```python
for int element in arr:
    if element == 2:
        print("I'm going to skip the remaining statements")
    skip
    print("This element isn't a 2")
```
#### 5.1.3.2 Abort Statement
The abort statement appears in for statements and while statements. When the program encounters this statement, it will ignore any statements left in the iterator statement and leave the iterator statement, proceeding with other statements within the code, if any.
```python
for int element in arr:
    if element == 2:
        print("found it")
    abort
```
## 5.2 Expressions
Expressions in viper yield the recipe for evaluation. Expressions can be any data type in its simplest form and it can include operators in more complex forms. These include simple arithmetic expressions which yield a float or integer type, or boolean expressions which yield a true or false when evaluated. Functions, which take in input as parameters and returns a value are also considered expressions in Viper.
### 5.2.1 Truth-Value Expression
Truth-Value expressions in Viper are boolean expressions. They can include logical operators and when evaluated, must return a value of type bool. 
### 5.2.2 Functions
Functions take input and may return output. Functions take the form of "returnType func functionName(parameter1, parameter2, ...)" The returnType is the type of the output that must be returned from the function. The func, is literally the word func. The functionName is the name of the function which must use the same convention as variables in Viper. The (parameter1, parameter2, ...), is the input of the function where each parameter is a variable. If a function is called, the statements in its scope will run, using any parameters given to the function and then returning the value of type, returnType, using the keyword return. Functions are called by writing the function name followed by a parantheses of parameters, if any. 
```python
nah func foo():
    print("Hello World!")
foo()
```
#### 5.2.2.1 Arrow Functions
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
## 5.3 Operators
Operators are used on values to change them. This leads to interesting and complex expressions which can be useful. The different kinds of operators are Unary, Binary, Comparative, Logical and Variable.
### 5.3.1 Unary Operators
Unary operators act on only one value. These include the not operator, the increment operator and the decrement operator.
#### 5.3.1.1 The NOT Operator
The NOT operator is given the symbol "!". When placed to the left of a bool, the value of the bool is flipped. If the value was true it is now false, vice versa. 
#### 5.3.1.2 The Increment Operator
The increment operator is given the symbol "++". When placed to the right of an integer, the value of the integer is incremented by one.
#### 5.3.1.3 The Decrement Operator 
The decrement operator is given the symbol "--". When placed to the right of an integer, the value of the integer is decremented by one.
### 5.3.2 Binary Operators 
Binary operators act on two values. These include the addition operator, the subtraction operator, the multiplicative operator, the division operator, and the modulus operator.
#### 5.3.2.1 The Addition Operator
The addition operator is given the symbol, "+". It acts like addition in mathematics, i.e. it is written in between two values which result in the sum of the two values.
#### 5.3.2.2 The Subtraction Operator
The subtraction operator is given the symbol, "-". It acts like subtraction in mathematics, i.e. it is written in between two values which result in the difference of the two values.
#### 5.3.2.3 The Multiplicative Operator
The multiplicative operator is given the symbol, "\*". It acts like multiplication in mathematics, i.e. it is written in between two values which result in the product of the two values.
#### 5.3.2.4 The Division Operator
The division operator is given the symbol, "/". It acts like division in mathematics, i.e. it is written in between two values which result in the quotient of the two values.
#### 5.3.2.5 The Modulus Operator
The modulus operator is given the symbol, "%". It acts like modulus in mathematics, i.e. it is written in between two values which result in the remainder of the two values when divided. 
### 5.3.3 Comparative Operators
Comparative Operators compare two values and returns a bool.
#### 5.3.3.1 The Greater Than Operator
The greater than operator is given the symbol, ">". When written in between two values, it returns false if the first value is less than or equal to the second value and returns true if the first value is greater than the second value.
#### 5.3.3.2 The Greater Than Or Equal To Operator
The greater than or equal to operator is given the symbol, ">=". When written in between two values, it returns false if the first value is less than the second value and returns true if the first value is greater than or equal to the second value.
#### 5.3.3.3 The Less Than Operator
The less than operator is given the symbol, "<". When written in between two values, it returns true if the first value is less than the second value and returns false if the first value is greater than or equal to the second value.
#### 5.3.3.4 The Less Than Or Equal To Operator
The less than or equal to operator is given the symbol, "<=". When written in between two values, it returns true if the first value is less than or equal to the second value and returns false if the first value is greater than the second value.
#### 5.3.3.5 The Equals Operator
The equals operator is given the symbol, "==". When written in between two values, it returns true if the first value is equal to the second value and returns false if the first value is not equal to the second value.
#### 5.3.3.6 The Not Equals Operator
The not equals operator is given the symbol, "!=". When written in between two values, it returns true if the first value is not equal to the second value and returns false if the first value is equal to the second value.
### 5.3.4 Logical Operators
The logical operators take in two bool values and returns a bool value. These operators include the AND operator and the OR operator.
#### 5.3.4.1 The AND Operator
The AND operator is given the symbol, "and". When written in between two bool values, it returns true if both values are true and false otherwise.
#### 5.3.4.2 The OR Operator
The OR operator is given the symbol, "or". When written in between two bool values, it returns false if both values are false and true otherwise.
### 5.3.5 Variable Operators
Variable operators act on a variable and an integer. These include +=, -=, \*=, and /=.
#### 5.3.5.1 The += Operator
The += operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side is added to the variable value, which is updated as the new value for the variable.
#### 5.3.5.2 The -= Operator
The -= operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side is subtracted from the variable value, which is updated as the new value for the variable.
#### 5.3.5.3 The \*= Operator
The \*= operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side is multiplied by the variable value, which is updated as the new value for the variable.
#### 5.3.5.4 The /= Operator
The /= operator is written in between a variable on the left hand side and an integer on the right hand side. The integer value on the right hand side divides the variable value, which is updated as the new value for the variable.
#### 5.3.5.5 The = Operator
The = operator is written between a variable name on the left hand side and a value on the right hand side. The value on the right hand side is assigned as the value for the variable on the left hand side. If the variable exists already, the value of the variable is overwritten, otherwise a new variable is created.
### 5.3.6 Precedence of Operators
The precedence of operators is important for determining how to write programs in Viper. It is important to note that any expression within parentheses has the highest precedence.
#### 5.3.6.1 Precedence of Unary Operators
Unary operators receive the highest precedence, second to parentheses.
#### 5.3.6.2 Precedence of Binary Operators
The multiplicative operator, division operator, and modulus operator are left associative and have a higher precedence than the addition operator and the subtraction operator. The addition and subtraction operator are also left associative. 
#### 5.3.6.3 Precedence of Comparative Operators
The >, >=, <, <= operators are given higher precedence than the != and == operators.
#### 5.3.6.4 Precedence of Logical Operators
The and operator is given higher precedence than the or operator.
#### 5.3.6.5 Precedence of Variable Operators
Variable operators are given a lower precedence than binary operators and are right associative. 
## 5.4 Scope
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




# Standard Library
Musti

# Sample Code
Raghav
