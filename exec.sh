#!/bin/bash
#./runtests.sh
./viper.native $1 > a.ll

if [ $# -eq 2 ] && [ $2 = "-v" ];
then
    cat a.ll
fi

llc -relocation-model=pic a.ll > a.s
cc -o a.exe a.s src/library.o -lm
output=$(./a.exe)
echo $output
