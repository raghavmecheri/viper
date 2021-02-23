cd test/samples
for i in *.vp; do
    echo "Running test on: $i"
    ../../viper.native -a $i
    if [ $? -eq 0 ]
    then
        echo "PASSED"
    else
        echo "FAILURE: $i"
        exit 1
    fi
    echo "______________________________________"
done
