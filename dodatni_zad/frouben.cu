#include<iostream>
#include<cuda_runtime.h>
#include<cmath>

using namespace std;

__device__ unsigned int *fsum;

__global__ void funkc(int *M, int dim)
{
  unsigned int rez;
  __shared__ unsigned int sum;

  sum = 0;
  __syncthreads();

  int i = blockIdx.x * blockDim.x + threadIdx.x;
  int j = blockIdx.y * blockDim.y + threadIdx.y;
  if (i < dim && j < dim)
     rez = M[dim+i+j]*M[dim*i+j];
  else
    rez = 0;

   atomicAdd((int*)&sum, rez);
   __syncthreads();
   fsum[blockIdx.x*blockDim.x + blockIdx.y] = sum;
}

__global__ void VecAdd(unsigned int *rez, int dim)
{
  int i = threadIdx.x;
  int val(0);
  __shared__ unsigned int sum;
  sum = 0;
  __syncthreads();

  if(i < dim)
     val = fsum[i];

  atomicAdd((int*)&sum, val);
  __syncthreads();
  rez[0] = sum;
}

int main(int argc, char*argv[])
{
  int N(50);

  size_t size = N*N*sizeof(int);

  int *M_h = (int*)malloc(size);

  for(int i(0); i < N*N; i++)
    M_h[i] = 1;//i%3; // elements in the matrix is less than 3

  int *M_d;
  cudaMalloc(&M_d, size);
  cudaMemcpy(M_d, M_h, size, cudaMemcpyHostToDevice);

  dim3 threadsPerBlock(32,32);
  dim3 blocksPerGrid((N/threadsPerBlock.x) + 1, (N/threadsPerBlock.y) + 1);
  cout<<blocksPerGrid.x<<","<<blocksPerGrid.y<<endl;
  int *result = (int*)malloc(sizeof(int));
  unsigned int *ptr;
  cudaMalloc(&ptr, blocksPerGrid.x*blocksPerGrid.y*sizeof(int));
  cudaMemcpyToSymbol(fsum, &ptr, sizeof(ptr));
  funkc<<<blocksPerGrid, threadsPerBlock>>>(M_d, N);
  unsigned int *rez;
  cudaMalloc(&rez,1*sizeof(int));
  VecAdd<<<1, blocksPerGrid.x*blocksPerGrid.y>>>(rez,  blocksPerGrid.x*blocksPerGrid.y);  
  cudaMemcpy(result, rez, 1*sizeof(int), cudaMemcpyDeviceToHost);

  cout<<"rezultat je:"<<result<<endl;

  free(M_h);
  cudaFree(M_d);
  cudaFree(fsum);

  return 0;
}
