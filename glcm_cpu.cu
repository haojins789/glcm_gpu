#include "glcm_cpu.h"

int calculate_glcm(int *image, char *mask, int *size, int *strides, int *angles, int Na, int *glcm, int Ng)
{
    int glcm_idx_max = Ng * Ng * Na;
    int i = 0, j = 0;
    int iz, iy, ix;
    int a, glcm_idx;
    for (iz = 0; iz < size[0]; iz++)
    {
        for (iy = 0; iy < size[1]; iy++)
        {
            for (ix = 0; ix < size[2]; ix++)
            {
                if (mask[i])
                {
                    for (a = 0; a < Na; a++)
                    {
                        if (iz + angles[a * 3] >= 0 && iz + angles[a * 3] < size[0] &&
                            iy + angles[a * 3 + 1] >= 0 && iy + angles[a * 3 + 1] < size[1] &&
                            ix + angles[a * 3 + 2] >= 0 && ix + angles[a * 3 + 2] < size[2])
                        {
                            j = i + angles[a * 3] * strides[0] +
                                angles[a * 3 + 1] * strides[1] +
                                angles[a * 3 + 2] * strides[2];
                            if (mask[j])
                            {
                                glcm_idx = a + (image[j] - 1) * Na + (image[i] - 1) * Na * Ng;
                                if (glcm_idx >= glcm_idx_max)
                                    return 0;
                                glcm[glcm_idx]++;
                            }
                        }
                    }
                }
                i++;
            }
        }
    }
    return 1;
}

int calculate_glcm_parallel(int *image, char *mask, int *size, int *strides, int *angles, int Na, int *glcm, int Ng)
{

    int i = 0, j = 0;
    int iz, iy, ix;
    int a, glcm_idx;
    int len = size[0] * size[1] * size[2];
    omp_set_num_threads(36);
#pragma omp parallel for private(i, j, iz, iy, ix, glcm_idx, a)
    for (i = 0; i < len; i++)
    {
        if (mask[i])
        {
            iz = (i / strides[0]);
            iy = (i % strides[0]) / strides[1];
            ix = (i % strides[0]) % strides[1];
            for (a = 0; a < Na; a++)
            {
                if (iz + angles[a * 3] >= 0 && iz + angles[a * 3] < size[0] &&
                    iy + angles[a * 3 + 1] >= 0 && iy + angles[a * 3 + 1] < size[1] &&
                    ix + angles[a * 3 + 2] >= 0 && ix + angles[a * 3 + 2] < size[2])
                {
                    j = i + angles[a * 3] * strides[0] +
                        angles[a * 3 + 1] * strides[1] +
                        angles[a * 3 + 2] * strides[2];
                    if (mask[j])
                    {
                        glcm_idx = a + (image[j] - 1) * Na + (image[i] - 1) * Na * Ng;
#pragma omp atomic
                        glcm[glcm_idx]++;
                    }
                }
            }
        }
    }
    return 1;
}

void load_data(int *image, char *mask, int *size)
{
    FILE *filePtr1, *filePtr2;
    filePtr1 = fopen("/home/haoxiaoyu/gpu/gpu_pyradiomics/data/image1", "r");
    filePtr2 = fopen("/home/haoxiaoyu/gpu/gpu_pyradiomics/data/mask1", "r");

    int zz = 0;

    for (zz = 0; zz < size[0] * size[1] * size[2]; zz++)
    {

        int m;
        char n;
        fscanf(filePtr1, "%d ", &m);
        fscanf(filePtr2, "%c ", &n);

        image[zz] = m;
        mask[zz] = n;
    }
    fclose(filePtr1);
    fclose(filePtr2);
}

int check_output(int *ori, int *glcm, int ng, int na)
{
    int i = 0;
    for (i = 0; i < ng * ng * na; i++)
    {
        if (ori[i] != glcm[i])
            return 0;
    }
    return 1;
}
