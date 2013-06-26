#include<iostream>
#include<cstdlib>
#include<string>
#include<cuda_runtime.h>
#include<cublas_v2.h>
#include<fstream>
#include<time.h>
#include<vector>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
using namespace std;

__global__ void postavi_tezine(double tezine)
{
  
}


int main(int argc, const char* argv[])
{
  // Provjera da li su dobri ulazni parametri
  if( argc != 2)
  {
    cerr<<"Krivi ulazni parametri"<<endl;
    return EXIT_FAILURE;
  }

  /* Citanje iz datoteke
     Sve se sprema u vektor
     Ime datoteke se cita s kom. linije
  */
  thrust::host_vector<int> indElements; // vektor veza za sve vrhove, format v1v20v1v3v40...
  ifstream myFile (argv[1]);
  
  if(myFile.is_open())
  {
    int numElements;
    myFile >> numElements;
    while(myFile.good())
    {
      int v;
      myFile >> v;
      indElements.push_back(v);
    }
  }
  else
  {
    cerr<<"Pogresno ime datoteke"<<endl;
    return EXIT_FAILURE;
  }

  //********************************************//



}
