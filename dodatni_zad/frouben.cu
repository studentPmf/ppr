#include<iostream>
#include<cuda_runtime.h>
#include<cmath>

using namespace std;

__global__ void funkc(int *M, int dim)
{
  unsigned int rez;
  __shared__ unsigned int sum;

  int i = blockIdx.x * blockDim.x + threadIdx.x;
  int j = blockIdx.y * blockDim.y + threadIdx.y;
  if (i < dim && j < dim)
     rez = M[N+i+j]*M[N*i+j];

   __syncthreads();
   atomicAdd(&sum, rez);
   __syncthreads();
}


int main(int argc, char*argv[])
{
  int N(100);

  size_t size = N*N*sizeof(int);

  int *M_h = (int*)malloc(size);

  for(int i(0); i < N*N; i++)
    M_h[i] = i%3;

  int *M_d;
  cudaMalloc(&M_d, size);
  cudaMemcpy(M_d, M_h, size, cudaMemcpyHostToDevice);

  dim3 threadsPerBlock(16,16);
  int blocksPerGrid = ((N / threadsPerBlock.x) + 1, (N/ threadsPerBlock.y) + 1);

  funkc<<<blocksPerGrid, threadsPerBlock>>>(M_d, N);

  free(M_h);
  cudaFree(M_d);

  return 0;
}
