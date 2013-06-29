/**
Napisati CUDA program koji trazi maksimalni nezavisni skup vrhova
u grafu korištenjem paralelnog algoritma koji koristi slučajne brojeve.
*/
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
#include <time.h>
using namespace std;

#define CUDA_CALL(x) do { if((x)!=cudaSuccess) { \
    printf("Error at %s:%d\n",__FILE__,__LINE__);\
    return EXIT_FAILURE;}} while(0)

#define CURAND_CALL(x) do { if((x)!=CURAND_STATUS_SUCCESS) { \
    printf("Error at %s:%d\n",__FILE__,__LINE__);\
    return EXIT_FAILURE;}} while(0)

/**
  * Host funkcija koja provjerava koliko je ostalo 
  * neodabranih vrhova
  */
bool findZeros(int* polje, int n)
{
  for(int i = 0; i < n; i++)
    if(polje[i] == 0)
      return true;

  return false;
}

/**
  * Umnozak pseudo i vrijeme
  */
__global__ void bestRand(float *devData, int* n)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  if(index < *n)
    devData[index] = devData[index]*((int)clock()%10);
}

/**
  * Curand host funkcija. Generira pseudo-slucajne brojeve <0,1>
  * uniformna razdioba
  */

int create_pseud_numbers(float *hostData, float *devData, int numElements)
{
  size_t n = numElements;
  curandGenerator_t gen;
  //int *nn;
  /* Create pseudo-random number generator */
  CURAND_CALL(curandCreateGenerator(&gen, 
                CURAND_RNG_PSEUDO_DEFAULT));

  /* Set seed */
  CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, 
                1234ULL));

  /* Generate n floats on device */
  CURAND_CALL(curandGenerateUniform(gen, devData, n));

  /*CUDA_CALL(cudaMalloc((void**)&nn, sizeof(int)));
  CUDA_CALL(cudaMemcpy(nn, &n, sizeof(int),
        cudaMemcpyHostToDevice));
  bestRand<<<n/128 + 1,128>>>(devData,nn);
  */
  /* Copy device memory to host */
  CUDA_CALL(cudaMemcpy(hostData, devData, n * sizeof(float),
        cudaMemcpyDeviceToHost));

  /* Cleanup */
  CURAND_CALL(curandDestroyGenerator(gen));

  return EXIT_SUCCESS;
}

/**
  * Device funkcija. Algoritam za pronalazenje maksimalnog nezavisnog skupa vrhova.
  * Ulazni parametri : polje veza, polje pokazivaca na veze za svaki vrh po jedan pointer na polje veze,
  *                    polje izbaceni, svaki thread zapise tko je izbacen sa -1 a ako je on trazeni postavi 1
  */

__global__ void algoritam(int* veze, int* ptr, int* izbaceni, float *devData, int* veze_size, int* ptr_size)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int c =(int)clock()%10;
  index = (index + c)%ptr_size;
  //izbaceni[index] = index; //provjera indekasa

  // Ako ti je index u rangu i ako nisi vec izbacen
  if(index < *ptr_size - 1 && izbaceni[index] != -1)
  {
    int provjera = 1;
    int start = ptr[index]; //pocetak u vezama
    int end = ptr[index + 1]; // kraj u vezama
    for(int i = start; i < end; i++)
    {
      // Ako je netko dobio vecu tezinu i ako taj nije izbacen kao mogucnost
      if(devData[index] >= devData[veze[i] - 1] && izbaceni[veze[i] - 1] != -1)
        provjera = 0;
    }

    // Ako je prosao provjeru
    if(provjera)
    {
       izbaceni[index] = 1; // postavi da je index dobar
       for(int i = start; i< end; i++)
         izbaceni[veze[i] - 1 ] = -1; // sve susjede izbaci kao mogucnost
    }
  }
}


int main(int argc, const char* argv[])
{
  // Provjera da li su dobri ulazni parametri
  if( argc != 2)
  {
    cerr<<"Krivi ulazni parametri"<<endl;
    return EXIT_FAILURE;
  }

  int numElements; // broj vrhova
  vector<int> indElements; // vektor susjedstva ( veze )
  vector<int> ptrVector; // pointeri vrhova u vektoru susjedstva
  ifstream myFile (argv[1]);
  
  // Ako je file dobar prepisi ga u vektore
  if(myFile.is_open())
  {
    int cnt = 0;
    myFile >> numElements;
    ptrVector.push_back(cnt);
    while(myFile.good())
    {
      int v;
      myFile >> v;
      if(!myFile.good()) break;
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

  /* Provjera da li je sve procitano korektno*/
  /*cout<<numElements<<endl;
  for(int i(0); i < ptrVector.size(); i++)
    cout<<ptrVector[i]<<" ";
  cout<<endl;

  for(int i(0); i < indElements.size(); i++)
    cout<<indElements[i]<<" ";
  cout<<endl;
  */
  
  /* Priprema za device*/
  /*****************************************************************/

  int* HindElements = &indElements[0]; // iz vektora u polje
  int* HptrVector = &ptrVector[0];     // iz vektora u polje
  int Hizbaceni[numElements];
  // Inicijalno sve na 0 jer su svi vrhovi raspolozivi za koristenje
  for(int i(0); i < numElements; i++)
    Hizbaceni[i] = 0;

  float * hostData, *devData; // polja za pseudo-slucajne brojeve
  
  // alokacija za generator pseudo brojeva
  hostData = (float *)calloc(numElements, sizeof(float));
  CUDA_CALL(cudaMalloc((void **)&devData, numElements*sizeof(float)));
  
  create_pseud_numbers(hostData, devData, numElements);
  
  /* Prikaz rezultata */
  /*
  for( int i = 0; i < numElements; i++) {
    printf("%1.4f ", hostData[i]);
  }
  cout<<endl;
  */
  // Alokacija memorija za glavni program (algoritam)
  int Hveze_size = indElements.size(), Hptr_size = ptrVector.size(); // pomocne varijable  
  int *Dveze_size, *Dptr_size;
  int *DindElements, *DptrVector, *Dizbaceni;
  int izbaceni[numElements];

  CUDA_CALL(cudaMalloc((void **)&DindElements, indElements.size()*sizeof(int)));
  CUDA_CALL(cudaMalloc((void **)&DptrVector, ptrVector.size()*sizeof(int)));
  CUDA_CALL(cudaMalloc((void **)&Dizbaceni, numElements*sizeof(int)));
  CUDA_CALL(cudaMalloc((void**)&Dveze_size, sizeof(int)));
  CUDA_CALL(cudaMalloc((void**)&Dptr_size, sizeof(int)));


  CUDA_CALL(cudaMemcpy(DindElements, HindElements, indElements.size() * sizeof(int),
        cudaMemcpyHostToDevice));
  CUDA_CALL(cudaMemcpy(DptrVector, HptrVector, ptrVector.size() * sizeof(int),
        cudaMemcpyHostToDevice));
  CUDA_CALL(cudaMemcpy(Dizbaceni, &Hizbaceni, numElements * sizeof(int),
        cudaMemcpyHostToDevice));
  CUDA_CALL(cudaMemcpy(Dveze_size, &Hveze_size, sizeof(int),
        cudaMemcpyHostToDevice));
  CUDA_CALL(cudaMemcpy(Dptr_size, &Hptr_size, sizeof(int),
        cudaMemcpyHostToDevice));
 

  // CUDA grid
  //dim3 threadsPerBlock(16, 16);
  //dim3 numBlocks(numElements / threadsPerBlock.x, numElements / threadsPerBlock.y);

  // Algoritam
  do{
    
    algoritam<<<numElements/128 + 1 ,128>>>(DindElements, DptrVector, Dizbaceni, devData, Dveze_size, Dptr_size);
    CUDA_CALL(cudaMemcpy(izbaceni, Dizbaceni, numElements * sizeof(int), cudaMemcpyDeviceToHost));

  }while(findZeros(izbaceni, numElements));

  // ispisi matrice odabranih i izbacenih vrhova 1 -> odabrani, -1 -> izbaceni
  for( int k = 0; k < numElements; k++)
    cout<<k+1<<" : "<<izbaceni[k]<<endl;

  // Oslobadanje memorije na hostu i divace-u 
  free(hostData);
  CUDA_CALL(cudaFree(devData));
  CUDA_CALL(cudaFree(DindElements));
  CUDA_CALL(cudaFree(DptrVector));
  CUDA_CALL(cudaFree(Dizbaceni));
  CUDA_CALL(cudaFree(Dveze_size));
  CUDA_CALL(cudaFree(Dptr_size));

  return 0;
}
