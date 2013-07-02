#!/bin/bash
echo kompajliranje ...
nvcc -arch=sm_20 algoritam.cu pseudo_generator/mttest.cpp pseudo_generator/mtrand/mtrand.cpp -lcurand
echo kompajliranje zavrseno
echo Pokretanje na grafovima
./a.out testni_primjeri/graf1.txt graf1.txt
./a.out testni_primjeri/graf2.txt graf2.txt
./a.out testni_primjeri/graf3.txt graf3.txt
./a.out testni_primjeri/graf4.txt graf4.txt
./a.out testni_primjeri/graf5.txt graf5.txt
./a.out testni_primjeri/graf5.txt graf6.txt
./a.out testni_primjeri/graf7.txt graf7.txt
