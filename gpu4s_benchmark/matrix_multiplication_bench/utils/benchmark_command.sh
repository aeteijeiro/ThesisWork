#!/bin/bash

cd ../bin
echo "eventsfile: $3, size: $2, metric destination: $1, benchmark destination: $4"
./matrix_multiplication_cuda_int_256 $2 -s 104 $(cat ../utils/$3) 2>> $1 >> $4
cd ../utils
