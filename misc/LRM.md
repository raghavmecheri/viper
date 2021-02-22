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
### 5.1.2 Iterator Statements
Iterator Statements are involved with Viper's ability to loop through statements. These statements compose for loops and while loops.
#### 5.1.2.1 For Statement
A for statement takes in an argument in the form of (assignment; condition; iterator), followed by a list of statements within its scope. The assignment creates a variable and initializes it to a given number. The condition is a boolean expression; if it returns true, the list of statements within the for statement's scope is run. The iterator changes the value of the variable in the assignment. Then the condition is checked with the new value and if it returns true, the statements are run again, otherwise the statements are not run again.

A for statement can take a second form as well. The second form of a for statement is an identifer, followed by the keyword in, followed by an object that is iterable. This statement will iterate over the values in the iterable object, using the identifier for each value, and run the statements in its scope. Once there is no elements left in the iterable object, the for statement will stop.
#### 5.1.2.2 While Statement
A while statement takes in a boolean expression. If the boolean expression returns a value of true, the statements within its scope are run. After all statements are run, the boolean expression is evaluated again; if true then statements are run again, otherwise, the while statement is done. This process repeats until the boolean expression returns a value of false.
### 5.1.3 Jump Statements
Jump statements are statements located within the scope of an iterator statement which dictates how to proceed within the iterator statement. 
#### 5.1.3.1 Continue Statement
#### 5.1.3.2 Break Statement
## 5.2 Expressions
### 5.2.1 Truth-Value Expression
### 5.2.2 Functions
#### 5.2.2.1 Arrow Functions
## 5.3 Operators
### 5.3.1 Unary Operators
#### 5.3.1.1 The NOT Operator
#### 5.3.1.2 The Increment Operator
#### 5.3.1.3 The Decrement Operator 
### 5.3.2 Binary Operators 
#### 5.3.2.1 The Addition Operator
#### 5.3.2.2 The Subtraction Operator
#### 5.3.2.3 The Multiplicative Operator
#### 5.3.2.4 The Division Operator
#### 5.3.2.5 The Modulus Operator
### 5.3.3 Compare Operators
#### 5.3.3.1 The Greater Than Operator
#### 5.3.3.2 The Greater Than Or Equal To Operator
#### 5.3.3.3 The Less Than Operator
#### 5.3.3.4 The Less Than Or Equal To Operator
#### 5.3.3.5 The Equals Operator
### 5.3.4 Logical Operators
#### 5.3.4.1 The AND Operator
#### 5.3.4.2 The OR Operator
### 5.3.5 Variable Operators
#### 5.3.5.1 The += Operator
#### 5.3.5.2 The -= Operator
#### 5.3.5.3 The \*= Operator
#### 5.3.5.4 The /= Operator
### 5.3.6 Precedence of Operators
## 5.4 Scope
### 5.4.1 Curly Braces
### 5.4.2 Indentation





# Standard Library
Musti

# Sample Code
Raghav
