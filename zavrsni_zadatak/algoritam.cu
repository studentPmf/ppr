#include<iostream>
#include<stdio.h>
#include<cstdlib>
#include<string>
#include<cuda_runtime.h>
#include<cuda.h>
#include<curand.h>
#include<cublas_v2.h>
#include<fstream>
#include<time.h>
#include<vector>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
using namespace std;

#define CUDA_CALL(x) do { if((x)!=cudaSuccess) { \
    printf("Error at %s:%d\n",__FILE__,__LINE__);\
    return EXIT_FAILURE;}} while(0)
#define CURAND_CALL(x) do { if((x)!=CURAND_STATUS_SUCCESS) { \
    printf("Error at %s:%d\n",__FILE__,__LINE__);\
    return EXIT_FAILURE;}} while(0)

void create_pseud_numbers(float *hostData, int numElements)
{
  size_t n = 5;//numElements;
  curandGenerator_t gen;
  float *devData;

  /* Allocate n floats on host */
  hostData = (float *)calloc(n, sizeof(float));

  /* Allocate n floats on device */
  CUDA_CALL(cudaMalloc((void **)&devData, n*sizeof(float)));

  /* Create pseudo-random number generator */
  CURAND_CALL(curandCreateGenerator(&gen, 
                CURAND_RNG_PSEUDO_DEFAULT));

  /* Set seed */
  CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, 
                1234ULL));

  /* Generate n floats on device */
  CURAND_CALL(curandGenerateUniform(gen, devData, n));

  /* Copy device memory to host */
  CUDA_CALL(cudaMemcpy(hostData, devData, n * sizeof(float),
        cudaMemcpyDeviceToHost));

  /* Cleanup */
  CURAND_CALL(curandDestroyGenerator(gen));
  CUDA_CALL(cudaFree(devData));
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
  int numElements;
  thrust::host_vector<int> indElements; // vektor veza za sve vrhove, format v1v20v1v3v40...
  thrust::host_vector<int> ptrVector;
  ifstream myFile (argv[1]);
  
  if(myFile.is_open())
  {
    int cnt = 0;
    myFile >> numElements;
    ptrVector.push_back(cnt);
    while(myFile.good())
    {
      int v;
      myFile >> v;
      if(v == 0)
        ptrVector.push_back(cnt);
      else
      {
        indElements.push_back(v);
        cnt++;
      }
    }
  }
  else
  {
    cerr<<"Pogresno ime datoteke"<<endl;
    return EXIT_FAILURE;
  }
  
  /*for(int i(0); i < indElements.size(); i++)
    cout<<indElements[i];
  cout<<endl;*/
  //********************************************//
  
  thrust::device_vector<int> DindElements = indElements; // vektor elemenata
  thrust::device_vector<int> DptrVector = ptrVector;     // vektor pointera na pocetak za svaki vrh
  
  float * hostData;
  
  //for(int j = 0; j < 5; j++)
  //{
    create_pseud_numbers(hostData, numElements);
    /* Show result */
    for( int i = 0; i < numElements; i++) {
      printf("%1.4f ", hostData[i]);
    }
    cout<<endl;
    free(hostData);
  //}

}
