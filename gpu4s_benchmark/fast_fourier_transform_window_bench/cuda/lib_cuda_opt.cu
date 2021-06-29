#include "../benchmark_library.h"

/**
 * CUDA Kernel Device code
 *
 * Computes the vector addition of A and B into C. The 3 vectors have the same
 * number of elements numElements.
 */
//#define BLOCK_SIZE 1024

__global__ void
binary_reverse_kernel(const bench_t *A, bench_t *B, const int64_t size, const int group, const int position_off)
{
    
    unsigned int id = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int position = 0;
    if (id < size)
    {   
        position = (__brev(id) >> (32 - group)) * 2;
        B[(position) + (size * 2 * position_off)] = A[(id *2) + position_off];
        B[position + 1 +  (size * 2 * position_off)] = A[(id *2 + 1) + position_off];
    }
}

__global__ void
fft_kernel( bench_t *B, const int loop,const bench_t wpr, const bench_t wpi, const unsigned int theads, const int64_t size, const int64_t position_off)
{   
    bench_t tempr, tempi;
    unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int id;
    unsigned int j;
    unsigned int inner_loop;
    unsigned  int subset;
    bench_t wr = 1.0;
    bench_t wi = 0.0;
    bench_t wtemp = 0;

    // get inner
    subset = theads / loop;
    id = i % subset;
    inner_loop = i / subset;
    //get wr and wi
    for(unsigned int z = 0; z < inner_loop ; ++z){
            wtemp=wr;
            wr += wr*wpr - wi*wpi;
            wi += wi*wpr + wtemp*wpi;
        
        }
    // get I
    i = id *(loop * 2 * 2) + 1 + (inner_loop * 2); 
    j=i+(loop * 2 );

    tempr = wr*B[j-1 + (size * 2 * position_off)] - wi*B[j+ (size * 2 * position_off)];
    tempi = wr * B[j+ (size * 2 * position_off)] + wi*B[j-1+ (size * 2 * position_off)];
    
    B[j-1+ (size * 2 * position_off)] = B[i-1+ (size * 2 * position_off)] - tempr;
    B[j+ (size * 2 * position_off)] = B[i+ (size * 2 * position_off)] - tempi;
    B[i-1+ (size * 2 * position_off)] += tempr;
    B[i+ (size * 2 * position_off)] += tempi;
    
}

void init(GraficObject *device_object, char* device_name){
    init(device_object, 0,0, device_name);
}

void init(GraficObject *device_object, int platform ,int device, char* device_name){
    cudaSetDevice(device);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, device);
    //printf("Using device: %s\n", prop.name);
    strcpy(device_name,prop.name);
    //event create 
    device_object->start = new cudaEvent_t;
    device_object->stop = new cudaEvent_t;
    device_object->start_memory_copy_device = new cudaEvent_t;
    device_object->stop_memory_copy_device = new cudaEvent_t;
    device_object->start_memory_copy_host = new cudaEvent_t;
    device_object->stop_memory_copy_host= new cudaEvent_t;
    
    cudaEventCreate(device_object->start);
    cudaEventCreate(device_object->stop);
    cudaEventCreate(device_object->start_memory_copy_device);
    cudaEventCreate(device_object->stop_memory_copy_device);
    cudaEventCreate(device_object->start_memory_copy_host);
    cudaEventCreate(device_object->stop_memory_copy_host);
}


bool device_memory_init(GraficObject *device_object,  int64_t size_a_array, int64_t size_b_array){
    cudaError_t err = cudaSuccess;
    // Allocate the device input vector A
    err = cudaMalloc((void **)&device_object->d_A, size_a_array * sizeof(bench_t));

    if (err != cudaSuccess)
    {
        return false;
    }
    // Allocate the device reverse vector B
    err = cudaMalloc((void **)&device_object->d_B, size_b_array * sizeof(bench_t));

    if (err != cudaSuccess)
    {
        return false;
    }
    return true;
}

void copy_memory_to_device(GraficObject *device_object, bench_t* h_A,int64_t size){
    cudaError_t err = cudaSuccess;
    cudaEventRecord(*device_object->start_memory_copy_device);
    err = cudaMemcpy(device_object->d_A, h_A, sizeof(bench_t) * size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy vector B from host to device (error code %s)!\n", cudaGetErrorString(err));
        return;
    }
    cudaEventRecord(*device_object->stop_memory_copy_device);
    
}

void aux_execute_kernel(GraficObject *device_object, int64_t size, int64_t position){
    size = size / 2;
    dim3 dimBlock_reverse(BLOCK_SIZE);
    dim3 dimGrid_reverse(ceil(float(size)/dimBlock_reverse.x));
    dim3 dimBlock(0);
    dim3 dimGrid(0);

    bench_t wtemp, wpr, wpi, theta;

    // reorder kernel
    binary_reverse_kernel<<<dimGrid_reverse, dimBlock_reverse>>>(device_object->d_A, device_object->d_B, size, (int64_t)log2(size), position);
    // Synchronize
    cudaDeviceSynchronize();
    // kernel call
    unsigned int theads = size /2 ;
    unsigned int loop = 1;

    if (theads % BLOCK_SIZE != 0){
            // inferior part
            dimBlock.x = theads;
            dimGrid.x  = 1;
    }
    else{
            // top part
            dimBlock.x = BLOCK_SIZE;
            dimGrid.x  = (unsigned int)(theads/BLOCK_SIZE);
    }


    while(loop < size ){
        // caluclate values 
        theta = -(M_PI/loop); // check
        wtemp = sin(0.5*theta);
        wpr = -2.0*wtemp*wtemp;
        wpi = sin(theta);
        //wr = 1.0;
        //wi = 0.0;

        fft_kernel<<<dimGrid, dimBlock>>>(device_object->d_B, loop, wpr, wpi, theads, size, position);
        
        loop = loop * 2;

       
    }
   
}
void execute_kernel(GraficObject *device_object, int64_t window, int64_t size){
    cudaEventRecord(*device_object->start);
    for (unsigned int i = 0; i < (size * 2 - window + 1); i+=2){
        aux_execute_kernel(device_object, window, i);
    }
    
    cudaEventRecord(*device_object->stop);
}

void copy_memory_to_host(GraficObject *device_object, bench_t* h_B, int64_t size){
    cudaEventRecord(*device_object->start_memory_copy_host);
    cudaMemcpy(h_B, device_object->d_B, size * sizeof(bench_t), cudaMemcpyDeviceToHost);
    cudaEventRecord(*device_object->stop_memory_copy_host);
}

float get_elapsed_time(GraficObject *device_object, bool csv_format){
    cudaEventSynchronize(*device_object->stop_memory_copy_host);
    float milliseconds_h_d = 0, milliseconds = 0, milliseconds_d_h = 0;
    // memory transfer time host-device
    cudaEventElapsedTime(&milliseconds_h_d, *device_object->start_memory_copy_device, *device_object->stop_memory_copy_device);
    // kernel time
    cudaEventElapsedTime(&milliseconds, *device_object->start, *device_object->stop);
    //  memory transfer time device-host
    cudaEventElapsedTime(&milliseconds_d_h, *device_object->start_memory_copy_host, *device_object->stop_memory_copy_host);
    
    if (csv_format){
         printf("%.10f;%.10f;%.10f;\n", milliseconds_h_d,milliseconds,milliseconds_d_h);
    }else{
         printf("Elapsed time Host->Device: %.10f milliseconds\n", milliseconds_h_d);
         printf("Elapsed time kernel: %.10f milliseconds\n", milliseconds);
         printf("Elapsed time Device->Host: %.10f milliseconds\n", milliseconds_d_h);
    }
    return milliseconds;
}

void clean(GraficObject *device_object){
    cudaError_t err = cudaSuccess;

    err = cudaFree(device_object->d_A);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector B (error code %s)!\n", cudaGetErrorString(err));
        return;
    }
     err = cudaFree(device_object->d_B);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector Br (error code %s)!\n", cudaGetErrorString(err));
        return;
    }


    // delete events
    delete device_object->start;
    delete device_object->stop;
    delete device_object->start_memory_copy_device;
    delete device_object->stop_memory_copy_device;
    delete device_object->start_memory_copy_host;
    delete device_object->stop_memory_copy_host;
}
