#!/bin/bash

_NVVM_BRANCH_=nvvm
_SPACE_= 
_CUDART_=cudart
_HERE_=/usr/local/mycuda-12.2/bin
_THERE_=/usr/local/mycuda-12.2/bin
_TARGET_SIZE_=
_TARGET_DIR_=
_TARGET_DIR_=targets/x86_64-linux
TOP=/usr/local/mycuda-12.2/bin/..
NVVMIR_LIBRARY_DIR=/usr/local/mycuda-12.2/bin/../nvvm/libdevice
LD_LIBRARY_PATH=/usr/local/mycuda-12.2/bin/../lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda-12.2/targets/x86_64-linux/lib/:/usr/local/mycuda-12.2/targets/x86_64-linux/lib/:/home/antonio/Documents/PerFI_PAPI_wd/PAPI/papi/src/install/lib:/home/antonio/Documents/PerFI_PAPI_wd/PAPI/papi/src/install/lib/libpapi.so.7.0.1.0:$LD_LIBRARY_PATH
PATH=/usr/local/mycuda-12.2/bin/../nvvm/bin:/usr/local/mycuda-12.2/bin:/usr/local/mycuda-12.2/bin:/home/antonio/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/tools/Xilinx/Vivado/2022.1/bin:/opt/nvidia/nsight-compute/2023.2.2:/tools/Xilinx/Vitis_HLS/2022.1/bin:/tools/Xilinx/Vitis/2022.1/bin
INCLUDES="-I/usr/local/mycuda-12.2/bin/../targets/x86_64-linux/include"  
LIBRARIES="-L/usr/local/mycuda-12.2/bin/../targets/x86_64-linux/lib/stubs -L/usr/local/mycuda-12.2/bin/../targets/x86_64-linux/lib"
CUDAFE_FLAGS=
PTXAS_FLAGS=
gcc -D__CUDA_ARCH_LIST__=860 -E -x c++ -D__CUDACC__ -D__NVCC__  "-I/usr/local/mycuda-12.2/bin/../targets/x86_64-linux/include"    -D "INT" -D "BLOCK_SIZE=16" -D "CUDA" -D__CUDACC_VER_MAJOR__=12 -D__CUDACC_VER_MINOR__=2 -D__CUDACC_VER_BUILD__=140 -D__CUDA_API_VER_MAJOR__=12 -D__CUDA_API_VER_MINOR__=2 -D__NVCC_DIAG_PRAGMA_SUPPORT__=1 -include "cuda_runtime.h" -m64 "lib_cuda.cu" -o "lib_cuda.cpp4.ii" 
cudafe++ --c++17 --gnu_version=110400 --display_error_number --orig_src_file_name "lib_cuda.cu" --orig_src_path_name "/home/antonio/Documents/PerFI_PAPI_wd/final_runs/isolated_float_lane/GPU4S_Bench/gpu4s_benchmark/matrix_multiplication_bench/build/lib_cuda.cu" --allow_managed  --m64 --parse_templates --gen_c_file_name "lib_cuda.cudafe1.cpp" --stub_file_name "lib_cuda.cudafe1.stub.c" --gen_module_id_file --module_id_file_name "lib_cuda.module_id" "lib_cuda.cpp4.ii" 
gcc -D__CUDA_ARCH__=860 -D__CUDA_ARCH_LIST__=860 -E -x c++  -DCUDA_DOUBLE_MATH_FUNCTIONS -D__CUDACC__ -D__NVCC__  "-I/usr/local/mycuda-12.2/bin/../targets/x86_64-linux/include"    -D "INT" -D "BLOCK_SIZE=16" -D "CUDA" -D__CUDACC_VER_MAJOR__=12 -D__CUDACC_VER_MINOR__=2 -D__CUDACC_VER_BUILD__=140 -D__CUDA_API_VER_MAJOR__=12 -D__CUDA_API_VER_MINOR__=2 -D__NVCC_DIAG_PRAGMA_SUPPORT__=1 -include "cuda_runtime.h" -m64 "lib_cuda.cu" -o "lib_cuda.cpp1.ii" 
cicc --c++17 --gnu_version=110400 --display_error_number --orig_src_file_name "lib_cuda.cu" --orig_src_path_name "/home/antonio/Documents/PerFI_PAPI_wd/final_runs/isolated_float_lane/GPU4S_Bench/gpu4s_benchmark/matrix_multiplication_bench/build/lib_cuda.cu" --allow_managed   -arch compute_86 -m64 --no-version-ident -ftz=0 -prec_div=1 -prec_sqrt=1 -fmad=1 --include_file_name "lib_cuda.fatbin.c" -tused --module_id_file_name "lib_cuda.module_id" --gen_c_file_name "lib_cuda.cudafe1.c" --stub_file_name "lib_cuda.cudafe1.stub.c" --gen_device_file_name "lib_cuda.cudafe1.gpu"  "lib_cuda.cpp1.ii" -o "lib_cuda.ptx"
