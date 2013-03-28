#include<iostream>
#include<cstdlib>
#include<string>
#include<fstream>
#include "ks.h"
#include "kp.h"
using namespace std;


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

	if(!konjugiraniS(A, b, x_0, dim, epsilon))
	{
		cout<<"Doslo je do greske kod racuna "<<endl;
		exit ( -1 );
	}

	ofstream rez("rez.txt");
	if(!file.is_open())
	{
		cerr<<"greska kod otvoranja datoteke za rezultat";
		exit(-1);
	}
	for(int i = 0; i < dim; i++)
		rez<<x_0[i]<<endl;

	return 0;
}
