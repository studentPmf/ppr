#include<iostream>
#include<cstdlib>
#include<string>
#include<cuda_runtime.h>
#include<cublas_v2.h>
#include "kp.h"
using namespace std;

int konjugiraniP(double* A, double* b, double* x_0, int dim, double epsilon)
{
	cublasHandle_h h;
	cublasCreate(&h);
	cublasDestroy(h);
	return 1;
}

