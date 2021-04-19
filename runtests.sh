#!/bin/bash
verbose=0
type="sast"

while getopts v:t: flag
do
    case "${flag}" in
        v) verbose=${OPTARG};;
        t) type=${OPTARG};;
    esac
done

llvm_tests() {
    cd test/tests
    echo "Beginning LLVM tests"
    for i in *.vp; do
        if [ ! -e "${i}.out" ]
        then
            echo "Skipping test as no file found for: ${i}.out in ${PWD}"
            continue;
        fi
        echo "Running LLVM test on: $i"
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
}
sast_tests() {
    cd test/semantsamples
    echo "Beginning SAST tests"
    for i in *.vp; do
        echo "Running SAST test on: $i"
        if [ $verbose -eq 1 ];
        then
            ../../viper.native -a $i
        else
            ../../viper.native -a $i >/dev/null 2>&1
        fi
        if [ $? -eq 0 ]
        then
            echo "PASSED"
        else
            echo "FAILURE: $i"
            exit 1
        fi
        echo "______________________________________"
    done
}
ast_tests() {
    cd test/tests
    echo "Beginning AST tests"
    for i in *.vp; do
        echo "Running AST test on: $i"
        if [ $verbose -eq 1 ];
        then
            ../../viper.native -a $i
        else
            ../../viper.native -a $i >/dev/null 2>&1
        fi
        if [ $? -eq 0 ]
        then
            echo "PASSED"
        else
            echo "FAILURE: $i"
            exit 1
        fi
        echo "______________________________________"
    done
}

cd src
make clean
make
mv ./viper.native ../viper.native
cd ..

echo "Test type: ${type}"
echo "Verbose enabled: ${verbose}"

if [ $type == "llvm" ]
then
    llvm_tests
else
    sast_tests
fi
