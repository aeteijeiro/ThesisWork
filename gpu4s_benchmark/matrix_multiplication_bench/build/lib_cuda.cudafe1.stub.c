#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"
#pragma GCC diagnostic ignored "-Wcast-qual"
#define __NV_CUBIN_HANDLE_STORAGE__ static
#if !defined(__CUDA_INCLUDE_COMPILER_INTERNAL_HEADERS__)
#define __CUDA_INCLUDE_COMPILER_INTERNAL_HEADERS__
#endif
#include "crt/host_runtime.h"
#include "lib_cuda.fatbin.c"
extern void __device_stub__Z28matrix_multiplication_kernelPKiS0_Piiii(const bench_t *, const bench_t *, bench_t *, const int, const int, const int);
static void __nv_cudaEntityRegisterCallback(void **);
static void __sti____cudaRegisterAll(void) __attribute__((__constructor__));
void __device_stub__Z28matrix_multiplication_kernelPKiS0_Piiii(const bench_t *__par0, const bench_t *__par1, bench_t *__par2, const int __par3, const int __par4, const int __par5){__cudaLaunchPrologue(6);__cudaSetupArgSimple(__par0, 0UL);__cudaSetupArgSimple(__par1, 8UL);__cudaSetupArgSimple(__par2, 16UL);__cudaSetupArgSimple(__par3, 24UL);__cudaSetupArgSimple(__par4, 28UL);__cudaSetupArgSimple(__par5, 32UL);__cudaLaunch(((char *)((void ( *)(const bench_t *, const bench_t *, bench_t *, const int, const int, const int))matrix_multiplication_kernel)));}
# 12 "lib_cuda.cu"
void matrix_multiplication_kernel( const bench_t *__cuda_0,const bench_t *__cuda_1,bench_t *__cuda_2,const int __cuda_3,const int __cuda_4,const int __cuda_5)
# 13 "lib_cuda.cu"
{__device_stub__Z28matrix_multiplication_kernelPKiS0_Piiii( __cuda_0,__cuda_1,__cuda_2,__cuda_3,__cuda_4,__cuda_5);
# 24 "lib_cuda.cu"
}
# 1 "lib_cuda.cudafe1.stub.c"
static void __nv_cudaEntityRegisterCallback( void **__T7) {  __nv_dummy_param_ref(__T7); __nv_save_fatbinhandle_for_managed_rt(__T7); __cudaRegisterEntry(__T7, ((void ( *)(const bench_t *, const bench_t *, bench_t *, const int, const int, const int))matrix_multiplication_kernel), _Z28matrix_multiplication_kernelPKiS0_Piiii, (-1)); }
static void __sti____cudaRegisterAll(void) {  __cudaRegisterBinary(__nv_cudaEntityRegisterCallback);  }

#pragma GCC diagnostic pop
