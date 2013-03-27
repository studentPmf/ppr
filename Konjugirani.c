#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<mkl.h>

int konjugiraniS(double * A, double* b, double* x_0, double* x_end, int dim)
{
	int s = 1;
	double i = 1, j = -1;
	//double * r = (double*)malloc(dim*sizeof(double));
	dgemv("No transpose",&dim,&dim,&i,A,&dim,x_0,&s,&j,b,&s);	
	return 1;
}

int main()
{
	return 0;
}
