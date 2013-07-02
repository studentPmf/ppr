#!/bin/bash
echo kompajliranje ...
nvcc -arch=sm_20 algoritam.cu pseudo_generator/mttest.cpp pseudo_generator/mtrand/mtrand.cpp -lcurand
echo kompajliranje zavrseno
echo Pokretanje na grafovima
./a.out graf1.txt
./a.out graf2.txt
./a.out graf3.txt
./a.out graf4.txt
./a.out graf5.txt
./a.out graf5.txt
./a.out graf7.txt
