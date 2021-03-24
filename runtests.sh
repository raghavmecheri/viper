#!/bin/bash
verbose=0

while getopts v: flag
do
    case "${flag}" in
        v) verbose=${OPTARG};;
    esac
done

cd test/tests
for i in *.vp; do
    echo "Running test on: $i"
    ../../viper.native $i > a.ll
    output=$(lli a.ll)
    expectedoutput=$(cat "${i}.out")
    rm a.ll
    if [ $verbose -eq 1 ];
    then
        echo "Output: ${output}"
        echo "Expected Output: ${expectedoutput}"
    fi
    if [[ "$output" == "$expectedoutput" ]]
    then
        echo "PASSED"
    else
        echo "FAILURE: $i"
        exit 1
    fi
    echo "______________________________________"
done
