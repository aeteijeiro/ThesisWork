# CONFIGURATION DIRECTIVES
# Compilers 
#CC = /usr/bin/nvcc
#NVCC = /usr/bin/nvcc
CC=nvcc
NVCC=nvcc
HIP = /opt/rocm/hip/bin/hipcc
# the build target executable:
TARGET = matrix_multiplication
# FLAGS 
# CC FUNCTIONS compiler flags:
CFLAGS  = -O0
# CPU compiler flags:
CPUFLAGS  = -O0
# NVCC compiler flags
NVCCFLAGS = -arch compute_86 -code sm_86 -O0
# CUDA FLAGS
CUFLAGS = -I/usr/local/cuda/include/ -L/usr/local/cuda/lib64 -lcuda -lcudart 
# OPENCL FLAGS
OPFLAGS = -I/usr/local/cuda/include/   -L/oldroot/root/usr/lib/x86_64-linux-gnu/ -lOpenCL 
# OPENMP FLAGS
OMPFLAGS = -fopenmp -lm
# HIP FLAGS
HIPFLAGS = -I/opt/rocm/hip/include -L/opt/rocm/hip/lib
# OPENBLAS INCLUDE
OBLASFLAG = -I/opt/OpenBLAS/include/ -L/opt/OpenBLAS/lib -lopenblas
# ATLAS INCLUDE
ATLASFLAG = -I/usr/local/atlas/include -L/usr/local/atlas/lib -lcblas -latlas

# LIBRARY: ATLAS or OPENBLAS
LIBRARY=ATLAS
LIBFLAGS=$(ATLASFLAG)

# Littelendian and Bigendian flags, by default if value is not set is Littelendian if value is set to -DBIGENDIAN is Bigendian
# -DBIGENDIAN
ENDIANFLAGS = 

# Data type can be INT FLOAT HALF and DOUBLE
DATATYPE =

# By default BLOCKSIZE equals 4.
BLOCKSIZE = 4
BLOCKSIZESQUARED = $(shell echo $(BLOCKSIZE)\*$(BLOCKSIZE) | bc)

NUMEVENTS =

# FOLDERS
# CPU FUNCTIONS FOLDER
CPUFUNCTIONFOLDER = ./cpu_functions/
# CUDA FOLDER
CUFOLDER = ./cuda/
# OPENCL FOLDER
OPFOLDER = ./opencl/
# OPENMP FOLDER
OMPFOLDER = ./openmp/
# HIP FOLDER
HIPFOLDER = ./hip/
# CPU FOLDER
CPUFOLDER = ./cpu/
# OUTPUT FOLDER
OUTPUTFOLDER = ./bin/

# COMPILER MAIN
all:
	@echo "YOU NEED TO SELECT A PLATFORM -> make CPU / make CUDA / make OpenCL / make CUDA-opt / make OpenCL-opt / make CUDA-lib / make OpenCL-lib"
# End Main
# Shortcuts
.PHONY: all-cpu
all-cpu: cpu
.PHONY: all-cuda
all-cuda: cuda cuda-opt cuda-lib
.PHONY: all-opencl
all-opencl: opencl opencl-opt opencl-lib
.PHONY: all-openmp
all-openmp: openmp openmp-opt openmp-lib
.PHONY: all-hip
all-hip: hip hip-opt
.PHONY: CPU
CPU: cpu
.PHONY: CUDA
CUDA: cuda
.PHONY: OpenCL
OpenCL: opencl
.PHONY: OpenMP
OpenMP: openmp
.PHONY: Hip
Hip: hip
.PHONY: CUDA-opt
CUDA-opt: cuda-opt
.PHONY: OpenCL-opt
OpenCL-opt: opencl-opt
.PHONY: OpenMP-opt
OpenMP-opt: openmp-opt
.PHONY: Hip-opt
Hip-opt: hip-opt
.PHONY: CUDA-lib
CUDA-lib: cuda-lib
.PHONY: OpenCL-lib
OpenCL-lib: opencl-lib
.PHONY: OpenMP-lib
OpenMP-lib: openmp-lib
# End Shortcuts
# CPU FUNCTIONS part

cpu_functions.o: $(CPUFUNCTIONFOLDER)cpu_functions.cpp
	$(CC) $(ENDIANFLAGS) -D$(DATATYPE) -c $(CPUFUNCTIONFOLDER)cpu_functions.cpp -o $(CPUFUNCTIONFOLDER)cpu_functions.o $(CFLAGS) 
# End CPU 

# CPU part
.PHONY: cpu
cpu: main_cpu
lib_cpu.o: $(CPUFOLDER)lib_cpu.cpp
	$(CC) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -c $(CPUFOLDER)lib_cpu.cpp -o $(CPUFOLDER)lib_cpu.o $(CPUFLAGS)


main_cpu: main.cpp lib_cpu.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER)
	$(CC) -D$(DATATYPE) main.cpp $(CPUFOLDER)lib_cpu.o $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_cpu_$(shell echo $(DATATYPE) | tr A-Z a-z)_$(BLOCKSIZESQUARED) $(CPUFLAGS) $(CFLAGS)

# End CPU 
# CUDA part
.PHONY: cuda
cuda: main_cuda

lib_cuda.o:
	rm $(CUFOLDER)lib_cuda.o	
	mv build/lib_cuda.o $(CUFOLDER)

pre-ptx:
	cd build;./pre_ptx.sh

pre-ptx-golden:
	cd build;./pre_ptx.sh
	cd utils; python3 inject_errors.py $(INJECTION_TARGET) $(SM_COUNT) golden; mv lib_cuda.ptx ../build/

post-ptx:
	cd build;./post_ptx.sh

inj-ptx: pre-ptx
	cd utils; python3 inject_errors.py $(INJECTION_TARGET) $(SM_COUNT) injected; mv lib_cuda.ptx ../build/

injected_errors: inj-ptx post-ptx main_cuda

golden: pre-ptx-golden post-ptx main_cuda
dry-run:
	cp cuda/* build/
	cd build; $(NVCC) -dryrun --keep -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DCUDA -c lib_cuda.cu -o lib_cuda.o $(NVCCFLAGS)

tests:
	cd utils; echo "Makefile EVENTS_PER_FILE=$(EVENTS_PER_FILE) TOTAL_EVENTS=$(TOTAL_EVENTS)"; ./run_both_tests_shortlist.sh $(EVENTS_PER_FILE) $(TOTAL_EVENTS) $(SAMPLES_PER_EVENT) $(EVENT_TYPE) $(STARTING_POINT); python3 organize_data.py $(INJECTION_TARGET) $(EVENT_TYPE) $(SM_COUNT) $(SAMPLES_PER_EVENT); python3 analysis.py no no svm $(INJECTION_TARGET) $(EVENT_TYPE) $(SM_COUNT) $(SAMPLES_PER_EVENT) 

clean_runs:
	rm -f bin/golden_runs/profiler/* bin/injector_runs/profiler/* bin/golden_runs/benchmark/* bin/injector_runs/benchmark/* utils/final_dataset_$(INJECTION_TARGET)_$(EVENT_TYPE).parquet

main_cuda: main.cpp lib_cuda.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER)
	$(CC) -g -G -D$(DATATYPE) -DCUDA -DPAPI main.cpp $(CUFOLDER)lib_cuda.o $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_cuda_$(shell echo $(DATATYPE) | tr A-Z a-z)_$(BLOCKSIZESQUARED) $(CUFLAGS) $(CFLAGS) -lstdc++ -L/home/antonio/Documents/PerFI_PAPI_wd/PAPI/papi/src/install/lib -lpapi -L/home/antonio/Documents/PerFI_PAPI_wd/PAPI/papi/src/testlib -ltestlib 
# End CUDA

# OpenCL Part
opencl:  main_opencl

lib_opencl.o: $(OPFOLDER)lib_opencl.cpp 
	$(CC) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DOPENCL -c $(OPFOLDER)lib_opencl.cpp -o $(OPFOLDER)lib_opencl.o $(CFLAGS) $(OPFLAGS)

main_opencl: main.cpp lib_opencl.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(CC) -D$(DATATYPE) -DOPENCL main.cpp $(OPFOLDER)lib_opencl.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_opencl_$(shell echo $(DATATYPE) | tr A-Z a-z)_$(BLOCKSIZESQUARED) $(CFLAGS) $(OPFLAGS) 

# End OpenCL

# OpenMP Part
openmp:  main_openmp

lib_omp.o: $(OMPFOLDER)lib_omp.cpp 
	export OMP_NUM_THREADS=8
	$(CC) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DOPENMP -c $(OMPFOLDER)lib_omp.cpp -o $(OMPFOLDER)lib_omp.o $(CFLAGS) $(OMPFLAGS)

main_openmp: main.cpp lib_omp.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(CC) -D$(DATATYPE) -DOPENMP main.cpp $(OMPFOLDER)lib_omp.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_omp_$(shell echo $(DATATYPE) | tr A-Z a-z) $(CFLAGS) $(OMPFLAGS)

# End OpenMP

# Hip part
hip: main_hip

lib_hip.o: $(HIPFOLDER)lib_hip.cpp
	$(HIP) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DHIP -c $(HIPFOLDER)lib_hip.cpp -o $(HIPFOLDER)lib_hip.o $(CFLAGS) $(HIPFLAGS)

main_hip: main.cpp lib_hip.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(HIP) -D$(DATATYPE) -DHIP main.cpp -x none $(HIPFOLDER)lib_hip.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_hip_$(shell echo $(DATATYPE) | tr A-Z a-z)_$(BLOCKSIZESQUARED) $(CFLAGS) $(HIPFLAGS)
# End Hip 

# CUDA part optimized
.PHONY: cuda
cuda-opt: main_cuda_opt

lib_cuda_opt.o: $(CUFOLDER)lib_cuda_opt.cu
	$(NVCC) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DPAPI -DCUDA -c $(CUFOLDER)lib_cuda_opt.cu -o $(CUFOLDER)lib_cuda_opt.o $(NVCCFLAGS)


main_cuda_opt: main.cpp lib_cuda_opt.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER)
	$(CC) -D$(DATATYPE) -DCUDA main.cpp $(CUFOLDER)lib_cuda_opt.o $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_cuda_opt_$(shell echo $(DATATYPE) | tr A-Z a-z)_$(BLOCKSIZESQUARED) $(CUFLAGS) $(CFLAGS) -lstdc++

# End CUDA optimized

# OpenCL Part optimized
opencl-opt:  main_opencl_opt

lib_opencl_opt.o: $(OPFOLDER)lib_opencl_opt.cpp 
	$(CC) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DOPENCL -c $(OPFOLDER)lib_opencl_opt.cpp -o $(OPFOLDER)lib_opencl_opt.o $(CFLAGS) $(OPFLAGS)

main_opencl_opt: main.cpp lib_opencl_opt.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(CC) -D$(DATATYPE) -DOPENCL main.cpp $(OPFOLDER)lib_opencl_opt.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_opencl_opt_$(shell echo $(DATATYPE) | tr A-Z a-z)_$(BLOCKSIZESQUARED) $(CFLAGS) $(OPFLAGS) 

# End OpenCL optimized

# OpenMP Part optimized
openmp-opt:  main_openmp_opt

lib_omp_opt.o: $(OMPFOLDER)lib_omp_opt.cpp 
	export OMP_NUM_THREADS=8
	$(CC) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DOPENMP -c $(OMPFOLDER)lib_omp_opt.cpp -o $(OMPFOLDER)lib_omp_opt.o $(CFLAGS) $(OMPFLAGS)

main_openmp_opt: main.cpp lib_omp_opt.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(CC) -D$(DATATYPE) -DOPENMP main.cpp $(OMPFOLDER)lib_omp_opt.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_omp_opt_$(shell echo $(DATATYPE) | tr A-Z a-z) $(CFLAGS) $(OMPFLAGS)
# End OpenMP optimized

# Hip part
hip-opt: main_hip_opt

lib_hip_opt.o: $(HIPFOLDER)lib_hip_opt.cpp
	$(HIP) -D$(DATATYPE) -DBLOCK_SIZE=$(BLOCKSIZE) -DHIP -c $(HIPFOLDER)lib_hip_opt.cpp -o $(HIPFOLDER)lib_hip_opt.o $(CFLAGS) $(HIPFLAGS)

main_hip_opt: main.cpp lib_hip_opt.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(HIP) -D$(DATATYPE) -DHIP main.cpp -x none $(HIPFOLDER)lib_hip_opt.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_hip_opt_$(shell echo $(DATATYPE) | tr A-Z a-z)_$(BLOCKSIZESQUARED) $(CFLAGS) $(HIPFLAGS)
# End Hip 

# CUDA part library
.PHONY: cuda
cuda-lib: main_cuda_lib

lib_cuda_lib.o: $(CUFOLDER)lib_cuda_lib.cu
	$(NVCC) -D$(DATATYPE) -DCUDA -c $(CUFOLDER)lib_cuda_lib.cu -o $(CUFOLDER)lib_cuda_lib.o $(NVCCFLAGS) 


main_cuda_lib: main.cpp lib_cuda_lib.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER)
	$(CC) -D$(DATATYPE) -DCUDA main.cpp $(CUFOLDER)lib_cuda_lib.o $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_cuda_lib_$(shell echo $(DATATYPE) | tr A-Z a-z) $(CUFLAGS) $(CFLAGS) -lstdc++ -lcublas

# End CUDA library

# OpenCL Part library
opencl-lib:  main_opencl_lib

lib_opencl_lib.o: $(OPFOLDER)lib_opencl_lib.cpp 
	$(CC) -D$(DATATYPE) -DOPENCL -c $(OPFOLDER)lib_opencl_lib.cpp -o $(OPFOLDER)lib_opencl_lib.o $(CFLAGS) $(OPFLAGS) -I/home/irodrig/clBlast/include/ -L/home/irodrig/clBlast/lib/ -lclblast

main_opencl_lib: main.cpp lib_opencl_lib.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(CC) -D$(DATATYPE) -DOPENCL main.cpp $(OPFOLDER)lib_opencl_lib.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_opencl_lib_$(shell echo $(DATATYPE) | tr A-Z a-z) $(CFLAGS) $(OPFLAGS)  -I/home/irodrig/clBlast/include/ -L/home/irodrig/clBlast/lib/ -lclblast

# End OpenCL library

# OpenMP Part library
openmp-lib:  main_openmp_lib

lib_omp_lib.o: $(OMPFOLDER)lib_omp_lib.cpp 
	$(CC) -D$(DATATYPE) -D$(LIBRARY) -DBLOCK_SIZE=$(BLOCKSIZE) -DOPENMP -c $(OMPFOLDER)lib_omp_lib.cpp -o $(OMPFOLDER)lib_omp_lib.o $(CFLAGS) $(OMPFLAGS) $(LIBFLAGS)

main_openmp_lib: main.cpp lib_omp_lib.o cpu_functions.o
	mkdir -p $(OUTPUTFOLDER) 
	$(CC) -D$(DATATYPE) -D$(LIBRARY) -DOPENMP main.cpp $(OMPFOLDER)lib_omp_lib.o  $(CPUFUNCTIONFOLDER)cpu_functions.o -o $(OUTPUTFOLDER)$(TARGET)_omp_lib_$(shell echo $(DATATYPE) | tr A-Z a-z) $(CFLAGS) $(OMPFLAGS) $(LIBFLAGS)

# End OpenMP library

# Clean
.PHONY: clean
clean:
	rm -rf *.o
	rm -rf $(CPUFUNCTIONFOLDER)*.o
	rm -rf $(OPFOLDER)*.o
	rm -rf $(OMPFOLDER)*.o
	rm -rf $(HIPFOLDER)*.o
	rm -rf $(CUFOLDER)*.o
	rm -rf $(CPUFOLDER)*.o
	rm -rf $(OUTPUTFOLDER)$(TARGET)_*
