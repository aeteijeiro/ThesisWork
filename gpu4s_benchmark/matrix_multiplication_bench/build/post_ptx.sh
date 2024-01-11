#!/bin/bash

ptxas -arch=sm_86 -m64  "lib_cuda.ptx"  -o "lib_cuda.cubin"
fatbinary --create="lib_cuda.fatbin" -64 --cicc-cmdline="-ftz=0 -prec_div=1 -prec_sqrt=1 -fmad=1 " "--image3=kind=elf,sm=86,file=lib_cuda.cubin" --embedded-fatbin="lib_cuda.fatbin.c"
gcc -D__CUDA_ARCH__=860 -D__CUDA_ARCH_LIST__=860 -c -x c++  -DCUDA_DOUBLE_MATH_FUNCTIONS "-I/usr/local/mycuda-12.2/bin/../targets/x86_64-linux/include"   -m64 "lib_cuda.cudafe1.cpp" -o "lib_cuda.o"
