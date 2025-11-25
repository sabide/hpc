# ping-pong
## compile and run
mkdir build 
cd build 
FC=mpiifx cmake ..
mpirun -np 2 ./ex 
