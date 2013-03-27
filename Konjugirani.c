#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<mkl.h>

int konjugiraniS(double * A, double* b, double* x_0, double* x_end, int dim, int epsilon)
{
	int inc = 1;
	double alpha = 1, beta = -1;
	double tau;
	double * d = (double*)malloc(dim*sizeof(double));
	dgemv("No transpose",&dim,&dim,&alpha,A,&dim,x_0,&inc,&beta,b,&inc);
	dcopy(&dim,d,&inc,b,&inc);
	dscal(&dim,&beta,d,&inc);
	while(ddot(&dim,b,&inc,b,&inc) > epsilon )
	{
		break;
	}	
	return 1;
}

int main()
{
	return 0;
}
