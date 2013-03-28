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
	double *A_d, *b_d, x_d;
	size_t pitch, dim_d(dim);
	int lda_d;
	if(cudaMallocPitch(&A_d, &pitch, dim_d*sizeof(double), dim_d) != cudaSuccess )
	{
		cerr<<"Greska kod alokacije polja"<<endl;
		exit(-1);
	}

	cudaMemcpy2D(A_d,pitch,A,dim*sizeof(double),dim_d*sizeof(double),dim_d,cudaMemcpyDefault);
	cudaMemcpy(b_d, b, dim_d, cudaMemcpyHostToDevice);
	cudaMemcpy(x_d, x_0, dim_d, cudaMemcpyHostToDevice);
	
	if(cudaMalloc(&d_d, dim_d) != cudaSuccess || cudaMalloc(&pom, dim_d) != cudaSuccess \\
		|| cudaMalloc(&b_pom_d, dim_d) != cudaSuccess)
	{
		cerr<<"Greska kod alokacije za pomocne varijable "<<endl;
		exit(-1);
	}
	
	lda_d = pitch/sizeof(double);

	cublasDgemv(h, CUBLAS_OP_N, dim, dim, &alph, A_d, lda_d, x_d, 1, &bet, b_d, 1);

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
