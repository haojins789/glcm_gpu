#include "omp.h"
#include <stdio.h>

int calculate_glcm(int *image, char *mask, int *size, int *strides, int *angles, int Na, int *glcm, int Ng);

int calculate_glcm_parallel(int *image, char *mask, int *size, int *strides, int *angles, int Na, int *glcm, int Ng);

void load_data(int *image, char *mask, int *size);

int check_output(int *ori, int *glcm, int ng, int na);
