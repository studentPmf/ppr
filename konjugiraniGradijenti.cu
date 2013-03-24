#include<iostream>
#include<cstdlib>
#include<string>
#include<cuda_runtime.h>
#include<cblas.h>
#include<fstream>

using namespace std;

__global__ 
void VecAdd(double* A, double* B, double* C, int N)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;

	if( i < N )
		C[i] = A[i] + B[i];
}


void procitaj(double *data, int dim, ifstream file)
{
	for(int i(0); i < dim; i++)
	{
		if(file.eof)
		{
			cerr<<"Greska kod citanja podataka, podatci nisu potpuni"<<endl;
			exit ( -1 );
		}
		double dat;
		file>>dat;
		data[i] = data;
	}
}


int main(int argc, char** argv)
{
	int dim;
	double * A, *b, *x_0;
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
	*A = new int[dim*dim];
	*b = new int[dim];
	*x_0 = new int[dim];

	procitaj(A, dim*dim, file);
	procitaj(b, dim, file);
	procitaj(x_0, dim, file);

	return 0;
}
