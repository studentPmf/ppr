#include<iostream>
#include<cstdlib>
#include<string>
#include<cuda_runtime.h>
#include<cublas_v2.h>
#include<fstream>
using namespace std;

int konjugiraniP(double* A, double* b, double* x_0, int dim, double epsilon)
{
	cublasHandle_t h;
	cublasCreate(&h);
	double alph(1), bet(-1);
	double tau, beta;
	double * d_d, *pom_d, b_pom_d;
	double *A_d, *b_d, *x_d;
	size_t pitch, dim_d(dim);
	int lda_d;
	if(cudaMallocPitch(&A_d, &pitch, dim_d*sizeof(double), dim_d) != cudaSuccess )
	{
		cerr<<"Greska kod alokacije polja"<<endl;
		exit(-1);
	}

	cudaMemcpy2D(A_d,pitch,A,dim*sizeof(double),dim_d*sizeof(double),dim_d,cudaMemcpyDefault);
	cudaMemcpy(b_d, b, dim_d*sizeof(double), cudaMemcpyHostToDevice);
	cudaMemcpy(x_d, x_0, dim_d*sizeof(double), cudaMemcpyHostToDevice);
	
	if(cudaMalloc((void**)&d_d, dim_d*sizeof(double)) != cudaSuccess || \\
		 cudaMalloc((void**)&pom_d, dim_d*sizeof(double)) != cudaSuccess || \\
		 cudaMalloc((void**)&b_pom_d, dim_d*sizeof(double)) != cudaSuccess)
	{
		cerr<<"Greska kod alokacije za pomocne varijable "<<endl;
		exit(-1);
	}
	
	lda_d = pitch/sizeof(double);

	cublasDgemv(h, CUBLAS_OP_N, dim, dim, &alph, A_d, lda_d, x_d, 1, &bet, b_d, 1);
	cublasDcopy(h, dim_d, b_d, 1, d_d, 1);
	cublasDscal(h, dim_d, &bet, d_d, 1);
	do{
		double result;
		bet = 0;
		cublasDgemv(h, CUBLAS_OP_N, dim, dim, &alph, A_d, lda_d, d_d, 1, &bet, pom_d, 1);
		double a, b;
		cublasDdot(h, dim, b_d, 1, b_d, 1, &a);
		cublasDdot(h, dim, d_d, 1, pom_d, 1, &b);
		tau = a/b;
		cublasDaxpy(h, dim, &tau, d_d, 1, x_d, 1);
		cublasDcopy(h, dim, b_d, 1, b_pom_d, 1);
		cublasDgemv(h, CUBLAS_OP_N, dim, dim, &tau, A_d, lda_d, d_d, 1, &alph, b_d, 1);
		double beta_k;
		cublasDdot(h, dim, b_d, 1, b_d, 1, &a);
		cublasDdot(h, dim, b_pom_d, 1, b_pom_d, 1, &b);
		beta_k = a/b;
		cublasDcopy(h, dim, b_d, 1, b_pom_d, 1);
		bet = -1;
		cublasDscal(h, dim, &bet, b_pom_d, 1);
		cublasDaxpy(h, dim, &beta_k, d_d, 1, b_pom_d, 1);
		cublasDcopy(h, dim, b_pom_d, 1, d_d, 1);
		cublasDdot(h, dim, b_d, 1, b_d, 1, &result); 
	}while(result > epsilon)
	
	cudaMemcpy(x_0, x_d, dim_d*sizeof(double), cudaMemcpyDeviceToHost);

	cudaFree(A_d);
	cudaFree(x_d);
	cudaFree(b_d);
	cudaFree(pom_d);
	cudaFree(d_d);
	cudaFree(b_pom_d);
	cublasDestroy(h);
	return 1;
}


void procitaj(double *data, int dim, ifstream& file)
{
	for(int i(0); i < dim; i++)
	{
		double dat;
		file>>dat;
		data[i] = dat;
	}
}


int main(int argc, char** argv)
{
	int dim;
	//double *A, *b, *x_0;
	std::string datIme;
	std::cout<<"Unesite ime tekstualne datoteke u kojoj se nalazi zadani sustav: ";
	std::cin>>datIme;
	std::cout<<std::endl;
	std::cout<<"Unijeli ste ime "<<datIme;
	std::cout<<"i rezltat ce biti spremnjen u datoteku rez.txt"<<std::endl;

	ifstream file( datIme.c_str() );
	
	if( !file.is_open() )
	{
		cerr<<"Greska kod otvaranja datoteke"<<endl;
		exit( -1 );
	}
	
	file>>dim;
	double *A = (double*)malloc(dim*dim*sizeof(double));
	double *b = (double*)malloc(dim*sizeof(double));
	double *x_0 =(double*)malloc(dim*sizeof(double));
	double *x_end = (double*)malloc(dim*sizeof(double));
	double epsilon;
	procitaj(A, dim*dim, file);
	procitaj(b, dim, file);
	procitaj(x_0, dim, file);

	cout<<"unesite zadanu tocnost za su sustav :";
	cin>>epsilon;

	if(!konjugiraniP(A, b, x_0, dim, epsilon))
	{
		cout<<"Doslo je do greske kod racuna "<<endl;
		exit ( -1 );
	}
	/*
	ofstream rez("rez.txt");
	if(!file.is_open())
	{
		cerr<<"greska kod otvoranja datoteke za rezultat";
		exit(-1);
	}
	for(int i = 0; i < dim; i++)
		rez<<x_0[i]<<endl;
	*/
	return 0;
}
