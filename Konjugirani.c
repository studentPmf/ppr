#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<mkl.h>

int konjugiraniS(double * A, double* b, double* x_0, double* x_end, int dim)
{
	//double * r = (double*)malloc(dim*sizeof(double));
	dgemm('No transpose',dim,dim,1,A,dim,x_0,1,-1,b,1);	

}

int main()
{
	return 0;
}
