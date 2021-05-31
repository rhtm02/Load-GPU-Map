#include "../include/loadGpu.cuh"
#include <unistd.h>
int main(void)
{
    string mapcsv = "../data/result_noded.csv";
    LoadMap(mapcsv);
    while (1){sleep(1000);}
    return 0;
}