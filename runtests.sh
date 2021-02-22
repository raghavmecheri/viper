cd test/scripts
for i in *.vp; do
    echo "Running test on: $i"
    ../../viper.native -a $i
    echo "______________________________________"
done
