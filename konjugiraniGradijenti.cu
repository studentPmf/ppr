#include<iostream>
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


int main(int argc, char** argv)
{
	std::string datIme;
	std::cout<<"Unesite ime tekstualne datoteke u kojoj se nalazi zadani sustav: ";
	std::cin>>datIme;
	std::cout<<std::endl;
	std::cout<<"Unijeli ste ime "<<datIme;
	std::cout<<"i rezltat ce biti spremnjen u datoteku rez.txt"<<std::endl;

	fstream file(datIme.c_str());

	return 0;
}
