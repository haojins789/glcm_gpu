#include <cuda.h>

__global__ void kernel(int *image, char *mask, int *threads_glcm);

__global__ void reduce_kernel(int *threads_glcm, int *glcm);

__global__ void calculate_glcm_kernel(int *image, char *mask, int *glcm, int *dev_angles);
