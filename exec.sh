#!/bin/bash

./viper.native $1 > a.ll
cat a.ll
llc -relocation-model=pic a.ll > a.s
cc -o a.exe a.s src/library.o -lm
output=$(./a.exe)
echo $output