verbose=0

while getopts v: flag
do
    case "${flag}" in
        v) verbose=${OPTARG};;
    esac
done

cd test/samples
for i in *.vp; do
    echo "Running test on: $i"
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
