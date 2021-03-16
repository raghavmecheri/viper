#!/bin/sh
# Builds the MicroC Docker container, which has the dependencies needed for Viper's compiler.

echo "Entering MicroC container, run 'exit' to leave."
docker run --rm -it -v `pwd`:/home/microc -w=/home/microc columbiasedwards/plt