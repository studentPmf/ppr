#include<iostream>
#include<cuda_runtime.h>
#include<cmath>

using namespace std;

__global__ void funkc(int *M, int dim, unsigned int *fsum)
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
   //__syncthreads();

   fsum[blockIdx.x*blockDim.x + blockIdx.y] = sum;
   //__syncthreads();
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
  int gridDimension = blocksPerGrid.x*blocksPerGrid.y;
  cout<<blocksPerGrid.x<<","<<blocksPerGrid.y<<endl;
  int *result = (int*)malloc(gridDimension*sizeof(int));
  unsigned int *fsum;
  cudaMalloc(&fsum, gridDimension*sizeof(int));
  funkc<<<blocksPerGrid, threadsPerBlock>>>(M_d, N,fsum);
  cudaMemcpy(result, fsum, 1*sizeof(int), cudaMemcpyDeviceToHost);
  for (int s(0); s < gridDimension; s++)
    cout<<"rezultat je:"<<result[s]<<endl;

  free(M_h);
  cudaFree(M_d);
  cudaFree(fsum);

  return 0;
}
