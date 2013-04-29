#include<iostream>
#include<cuda_runtime.h>
#include<cmath>

using namespace std;

__global__ void funkc(int *M, int dim, unsigned int *fsum)
{
  unsigned int rez;
  __shared__ unsigned int sum = 0;

  int i = blockIdx.x * blockDim.x + threadIdx.x;
  int j = blockIdx.y * blockDim.y + threadIdx.y;
  if (i < dim && j < dim)
     rez = M[dim+i+j]*M[dim*i+j];

   __syncthreads();
   atomicAdd(&sum, rez);
   __syncthreads();

   fsum[0] = sum;
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
  int result;
  int *fsum;
  cudaMalloc(&fsum, 1*sizeof(int));
  funkc<<<blocksPerGrid, threadsPerBlock>>>(M_d, N,fsum);
  cudaMemcpy(&result, fsum, 1*sizeof(int), cudaMemcpyDeviceToHost);
  cout<<"rezultat je:"<<result<<endl;

  free(M_h);
  cudaFree(M_d);
  cudaFree(fsum);

  return 0;
}
