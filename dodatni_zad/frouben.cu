#include<iostream>
#include<cuda_runtime.h>
#include<cmath>

using namespace std;

/*
  suma elemenata po blokovima koristenjem aomic funkcije
*/
__global__ void funkc(int *M, int dim, unsigned int *fsum)
{
  unsigned int rez;
  extern __shared__ int sum[];

  sum[blockIdx.x*gridDim.x + blockIdx.y] = 0;
  __syncthreads();

  int i = blockIdx.x * blockDim.x + threadIdx.x;
  int j = blockIdx.y * blockDim.y + threadIdx.y;
  if (i < dim && j < dim)
     rez = M[dim+i+j]*M[dim*i+j];
  else
    rez = 0;

   atomicAdd(&sum[blockIdx.x*gridDim.x + blockIdx.y], rez);
   //__syncthreads();

   fsum[blockIdx.x*gridDim.x + blockIdx.y] =  sum[blockIdx.x*gridDim.x + blockIdx.y] ;
   //__syncthreads();
}

/*
   suma elemenata vektora dobivenog kao suma kvadrata elemenata blokova prethodne funkcije
*/
__global__ void vecAdd(unsigned int *M, int dim, int *r)
{
  __shared__ int rez;
  rez = 0;
  __syncthreads();
  
  int i = threadIdx.x;
  int value(0);
  
  if(i < dim)
    value = M[i];
  
  atomicAdd(&rez, value);
  
  __syncthreads();
  r[0] = rez;
}



int main(int argc, char*argv[])
{
  int N(100);

  size_t size = N*N*sizeof(int);

  int *M_h = (int*)malloc(size);

  // geneiranje matrice
  for(int i(0); i < N*N; i++)
    M_h[i] = i%3; // elements in the matrix is less than 3

  int *M_d;
  cudaMalloc(&M_d, size);
  cudaMemcpy(M_d, M_h, size, cudaMemcpyHostToDevice);

  // postavljanje topologije 32x32 threada u bloku i onda blokova koliko treba
  dim3 threadsPerBlock(32,32);
  dim3 blocksPerGrid((N/threadsPerBlock.x) + 1, (N/threadsPerBlock.y) + 1);

  int gridDimension = blocksPerGrid.x*blocksPerGrid.y;

  int *result = (int*)malloc(gridDimension*sizeof(int));
  unsigned int *fsum;
  cudaMalloc(&fsum, gridDimension*sizeof(int));

  // poziv funkcije za racunanje sume kvadrata po blokovima
  funkc<<<blocksPerGrid, threadsPerBlock, gridDimension>>>(M_d, N, fsum);

  cudaMemcpy(result, fsum, gridDimension*sizeof(int), cudaMemcpyDeviceToHost);
  int *vectorSum;
  cudaMalloc(&vectorSum, sizeof(int));
  
  // poziv funkcije za racunanje zbroja dobivenih suma
  vecAdd<<<1, gridDimension>>>(fsum, gridDimension, vectorSum);
  int *sumAll = (int*)malloc(sizeof(int));
  cudaMemcpy(sumAll, vectorSum, sizeof(int), cudaMemcpyDeviceToHost);

  /*for (int s(0); s < gridDimension; s++)
  {
    cout<<"rezultat je:"<<result[s]<<endl;
  }*/

  cout<<endl<<"Konacan rezultat je : "<<sqrt(sumAll[0])<<endl;

  free(M_h);
  free(sumAll);
  cudaFree(M_d);
  cudaFree(fsum);
  cudaFree(r);

  return 0;
}
