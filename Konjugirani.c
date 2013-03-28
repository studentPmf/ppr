#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<mkl.h>

int konjugiraniS(double* A, double* b, double* x_0, double* x_end, int dim, int epsilon)
{
	int inc = 1;
	double alpha = 1, beta = -1;
	double tau;
	double* d = (double*)malloc(dim*sizeof(double));
	double* pom = (double*)malloc(dim*sizeof(double));
	double* b_pom = (double*)malloc(dim*sizeof(double));
	dgemv("No transpose", &dim, &dim, &alpha, A, &dim, x_0, &inc, &beta, b, &inc);
	dcopy(&dim, b, &inc, d, &inc);
	dscal(&dim, &beta, d, &inc);

	while(ddot(&dim, b, &inc,b, &inc) > epsilon )
	{
		beta = 0;
		dgemv("No transpose", &dim, &dim, &alpha, A, &dim, d, &inc, &beta, pom, &inc )
		tau = ddot(&dim, b, &inc, b, &inc)/ddot(&dim, d, &inc, pom, &inc);
		daxpy(&dim, tau, d, &inc, x_0, &inc);
		dcopy(&dim, b, &inc, b_pom, &inc);
		dgemv("No transpose", &dim, &dim, &tau, A, &dim, d, &inc, &alpha, b, &inc);
		double beta_k = ddot(&dim, b, &inc, b, &inc)/dodt(&dim, b_pom, &inc, b_pom, &inc);
		dcopy(&dim, b, &inc, b_pom, &inc);
		beta = -1;
		dscal(&dim, &beta, b_pom, &inc);
		daxpy(&dim, beta_k, d, &inc, b_pom, &inc);
		dcopy(&dim, b_pom, &inc, d, &inc);
	}	
	return 1;
}

int main()
{
	return 0;
}
