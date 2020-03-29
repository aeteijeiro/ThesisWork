#include "../benchmark_library.h"
#include <cstring>

void init(GraficObject *device_object, char* device_name){
	init(device_object, 0,0, device_name);
}


void init(GraficObject *device_object, int platform, int device, char* device_name)
{
	// TBD Feature: device name. -- Bulky generic platform implementation
	strcpy(device_name,"Generic device");
}


bool device_memory_init(GraficObject *device_object, unsigned int size_a_matrix, unsigned int size_b_matrix, unsigned int size_c_matrix)
{
	device_object->d_A = (bench_t*) malloc ( size_a_matrix * sizeof(bench_t*));
	device_object->d_B = (bench_t*) malloc ( size_b_matrix * sizeof(bench_t*));
	device_object->kernel = (bench_t*) malloc ( size_c_matrix * sizeof(bench_t*));
   	return true;
}


void copy_memory_to_device(GraficObject *device_object, bench_t* h_A, bench_t* kernel, unsigned int size_a, unsigned int size_b)
{
	memcpy(&device_object->d_A[0], h_A, sizeof(bench_t)*size_a);
	memcpy(&device_object->kernel[0], kernel, sizeof(bench_t)*size_b);
}


void execute_kernel(GraficObject *device_object, unsigned int n, unsigned int m,unsigned int w, unsigned int kernel_size)
{
	// Start compute timer
	const double start_wtime = omp_get_wtime();

	int kernel_rad = kernel_size / 2;

	for (int x = 0; x < n; ++x)
	{
		for (int y = 0; y < n; ++y)
		{	
			bench_t sum = 0;
			for(int i = -kernel_rad; i <= kernel_rad; ++i)
			{
				for(int j = -kernel_rad; j <= kernel_rad; ++j){
					bench_t value = 0;
					if (i + x < 0 || j + y < 0)
					{
						value = 0;
					}
					else if ( i + x > n - 1 || j + y > n - 1)
					{
						value = 0;
					}
					else
					{
						value = device_object->d_A[(x + i)*n+(y + j)];
					}
					sum += value * device_object->kernel[(i+kernel_rad)* kernel_size + (j+kernel_rad)];
				}
			}
			
			device_object->d_B[x*n+y ] = sum;
		}
	}
	// End compute timer
	device_object->elapsed_time = omp_get_wtime() - start_wtime;
}


void copy_memory_to_host(GraficObject *device_object, bench_t* h_C, int size)
{	     
	memcpy(h_C, &device_object->d_B[0], sizeof(bench_t)*size);
}


float get_elapsed_time(GraficObject *device_object, bool csv_format)
{
	if (csv_format)
	{
        printf("%.10f;%.10f;%.10f;\n", (bench_t) 0, device_object->elapsed_time * 1000.f, (bench_t) 0);
    } 
	else
	{
		printf("Elapsed time Host->Device: %.10f miliseconds\n", (bench_t) 0);
		printf("Elapsed time kernel: %.10f miliseconds\n", device_object->elapsed_time * 1000.f);
		printf("Elapsed time Device->Host: %.10f miliseconds\n", (bench_t) 0);
    }
	return device_object->elapsed_time * 1000.f;
}


void clean(GraficObject *device_object)
{
	free(device_object->d_A);
	free(device_object->d_B);
	free(device_object->kernel);
}