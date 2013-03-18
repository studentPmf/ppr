#include<iostream>
#include<cuda.h>

__global__ void VecAdd(double *A, double *B, double *C, int N)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;

	if( N > i )
		C[i] = A[i] + B[i];
}


int main(int argc, char *argv[])
{
	int N(100);
	size_t size = N * sizeof(double);

	double *h_A = (double*)malloc(size);
	double *h_B = (double*)malloc(size);

	for(int i(0); i < 100; i++)
		h_A[i] = h_B[i] = (double)( (i + 2)/(i + 1) );
	
	double *d_A, *d_B, *d_C;
	cudaMalloc(&amp; d_A, size);
	cudaMalloc(&amp; d_B, size);
	cudaMalloc(&amp; d_C, size);

	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
	
	 int threadsPerBlock = 256;
   int blocksPerGrid = (N + threadsPerBlock – 1) / threadsPerBlock;
   
	 VecAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, N);

	 cudaFree(d_A);
   cudaFree(d_B);
   cudaFree(d_C);

	 free(h_A);
	 free(h_B);

	return 0;
}
