# Overview
Tommy

# Lexical Conventions
Trey

# Data Types  
Viper supports the same primitive and higher-order data types as many modern languages. Primitive types are supported natively, while higher-order types are implemented in Viper's standard library. 

## Primitive Data Types
The five primitive types supported by Viper are ```char```, ```int```, ```float```, ```bool```, and ```nah```. The table below summarizes their important properties, with more details in the following sections.  
| Primitive Type | Size | Description | Declaration |
|-----------|-----------|-----------|-----------|
| ```char``` | 1 byte | Represents single ASCII characters | ```char a = 'a'```<br>```char null_term = '\0'```<br>```char newline = '\n'``` |
| ```int``` | 8 bytes | Stores signed integer values | ```int pos = 12```<br>```int neg = -980``` |
| ```float``` | 8 bytes | Stores signed floating-point numbers | ```float pos = 3.2```<br>```float neg = -29.7```<br>```float dec = 0.003``` |
| ```bool```          | 1 byte    | Stores either ```true``` or ```false``` | a == b<br>a != b<br>!(a == b)<br>(a && b)     |
| ```nah```       | 1 byte       | Viper's ```null``` value                                                | a == b<br>a != b<br>              |

### ```char```
```char``` is the type that represents single ASCII characters. In Viper, a ```char``` is represented as an ASCII character enclosed in single quotes. Special characters, like the newline and tab characters, are defined with an escape backslash (```'\n'``` and ```'\t'```, respectively). Each ```char``` behaves like an ```int``` in that it takes on the decimal value of its assigned ASCII character. Therefore, numerical operations that are valid for integers are also valid for ```char```s.


# Type System
Trey

# 5 Statements, Expressions and Operators
## 5.1 Statements
Viper programs are composed of a list of statements. Statements are selector statements, iterator statements and jump statements. 
### 5.1.1 Selector Statements
#### 5.1.1.1 If Statement
#### 5.1.1.2 If/Elif/Else Statement
### 5.1.2 Iterator Statements
#### 5.1.2.1 For Statement
#### 5.1.2.2 While Statement
### 5.1.3 Jump Statements
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





# Standard Library
Musti

# Sample Code
Raghav
