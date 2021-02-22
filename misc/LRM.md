# Overview
Tommy

# Lexical Conventions
Trey

# Data Types  
Viper supports the same primitive and higher-order data types as many modern languages. Primitive types are supported natively, while higher-order types are implemented in Viper's standard library. 

## Primitive Data Types
The five primitive types supported by Viper are ```char```, ```int```, ```float```, ```bool```, and ```nah```. The table below summarizes their properties and declarations, with more details in the following sections.  
| Primitive Type | Size | Description | Declaration/Usage |
|-----------|-----------|-----------|-----------|
| ```char``` | 2 bytes | Represents single ASCII characters | ```char a = 'a'```<br>```char c = 'b' + 1```<br>```char newline = '\n'``` |
| ```int``` | 8 bytes | Stores signed integer values | ```int pos = 12```<br>```int neg = -980```<br>```int sum = 4 + 5``` |
| ```float``` | 8 bytes | Stores signed floating-point numbers | ```float pos = 3.2```<br>```float neg = -29.7```<br>```float dec = 0.003```<br>```float whole_num = 2.0```|
| ```bool``` | 1 byte | Stores either ```true``` or ```false``` | ```bool t = true```<br>```bool f = false```<br>```bool falsy = t && f``` |
| ```nah```       | 1 byte       | Viper's ```null``` value | ```int nil = nah```<br>```char empt = nah```<br>```return nah``` |

### ```char```
```char``` is the type that represents single ASCII characters. In Viper, a ```char``` is represented as an ASCII character enclosed in single quotes. Special characters, like the newline and tab characters, are defined with an escape backslash (```'\n'``` and ```'\t'```, respectively). Each ```char``` behaves like an ```int``` in that it takes on the decimal value of its assigned ASCII character. Therefore, numerical operations that are valid for integers are also valid for ```char```s.  

### ```int```
```int```s represent signed integer values. The minimum value of an ```int``` is -2<sup>31</sup>, and the maximum value is 2<sup>31</sup> - 1. Negative integer values must be defined with a preceding minus (-) symbol, but positive integer values cannot be defined with a preceding plus (+) symbol.  

### ```float```
```float```s represent signed floating-point numbers. To define a ```float```, at least one digit must precede a decimal point (.), and at least one digit must follow. For example, ```.8``` and ```8.``` are invalid, and result in syntax errors. These values are correctly defined as ```0.8``` and ```1.0```, with padding zeroes to ensure that there is a least one digit on each side of the decimal point.  

### ```bool```
```bool```s hold one of the two Boolean values: ```true``` or ```false```. Expressions using the logical and (```&&```), logical or (```||```), and equality operators are evaluated to ```bool```s. For example, the expression ```(1 < 2) && ('c' == 'c')``` evaluates to a ```bool``` with value ```true```. Additionally, specific values of each primitive type evaluate to certain ```bool``` values. See the table below for details (note that ```nah``` always evaluates to ```false```).  
| Primitive Type | ```true``` values | ```false``` values |
|-----|------|-----|
| ```char``` | All values but ```'\0'``` | ```'\0'```
| ```int``` | [-2<sup>31</sup>, -1], [1, 2<sup>31</sup> - 1] | 0
| ```float``` | All values but 0.0 | 0.0
| ```bool``` | ```true``` | ```false```
| ```nah``` | n/a | ```nah```   

### ```nah```
```nah``` is Viper's ```null``` value. It can be used to initialize any other data type, and is a valid return value for any function, regardless of the expected return type. Functions with no return value are declared with type ```nah```.  

## Higher-Order Data Types  
Viper also supports various higher-order data types, including ```list```, ```string```, ```group```, and ```dict```.  
| Type | Description | Declaration/Usage |
|-----------|-----------|-----------|
| ```list``` | Ordered lists of any type | ```int[] list = [] /* Empty */```<br>```float[] scores = [9.7, 8.2]``` |
| ```string``` | Stores sequences of character literals | ```string pet = "bear"```<br>```string date = "2/24/21"``` |
| ```group``` | Lightweight structure to hold type-specified collections of data | ```(int, int) coord = (3, -4)```<br>```(string, int) name_id = ("Bon", 4432)``` |
| ```dict``` | Key-value pairs with random access | ```[int: int] pos = [] /* Empty */ ```<br>```[string: (string, int)] items = [```<br>                             ```"milk": ("dairy", 5),```<br>                           ```"apple": ("fruit", 3) ]```


### ```list```


### ```string```
The ```string``` type of Viper is implented as a ```list``` of ```chars```.  

### ```group```  

### ```dict```

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
