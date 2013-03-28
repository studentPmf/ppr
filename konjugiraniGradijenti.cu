#include<iostream>
#include<cstdlib>
#include<string>
//#include<cuda_runtime.h>
//#include<cblas.h>
#include<fstream>
#include<ks.h>
//using namespace std;

/*__global__ 
void VecAdd(double* A, double* B, double* C, int N)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;

	if( i < N )
		C[i] = A[i] + B[i];
}

int KonjGrad(double *A, double *b, double* x_0, double epsilon, double *x_end, int dim)
{
	double a = cblas_ddot(dim,b,1,x_0,1);
	cout<<a<<endl;
	int k = 0;
	double *r_0 = (double*)malloc(dim*sizeof(double));
	
	return 1;
}
*/


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

	if(!konjugiraniS(A, b, x_0, epsilon, x_end, dim, 0.01))
	{
		cout<<"Doslo je do greske kod racuna "<<endl;
		exit ( -1 );
	}

	return 0;
}
