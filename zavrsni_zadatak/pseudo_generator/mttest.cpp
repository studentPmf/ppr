// test program mttest.cpp, see mtreadme.txt for information
#include "mtrand/mtrand.h"
#include "myrand.h"
#include <cstdio>
using namespace std;

void generator_realnih_brojeva(float *realni, int n)
{
  unsigned long init[4] = {0x123, 0x234, 0x345, 0x456}, length = 4;
  MTRand_int32 irand(init, length); // 32-bit int generator
  MTRand drand; // double in [0, 1) generator, already init

  for (int i = 0; i < 1000; ++i) 
    realni[i] = drand();
}
void generator_cijelih_brojeva(int* cijeli, int n)
{
  unsigned long init[4] = {0x123, 0x234, 0x345, 0x456}, length = 4;
  MTRand_int32 irand(init, length); // 32-bit int generator
  MTRand drand; // double in [0, 1) generator, already init

  for (int i = 0; i < n; ++i) 
    cijeli[i] = irand();
}
