#include<iostram>
#include<cuda_runtime.h>
#include<cblas.h>

__global__ 
void VecAdd(double* A, double* B, double* C, int N)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;

	if( i < N )
		C[i] = A[i] + B[i];
}


int main(int argc, char** argv)
{
	return 0;
}
