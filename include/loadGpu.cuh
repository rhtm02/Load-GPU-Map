#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sys/shm.h>
#include <sys/ipc.h>
#include "dataType.cuh"

#define _ROAD_GPU_  0x50000001
using namespace std;


vector<float> tmp;
Node road[10000000];
__device__ Node* gpu_road;
float lan[10000000];
__device__ float* gpu_lan;
float lot[10000000];
__device__ float* gpu_lot;

cudaIpcMemHandle_t road_gpuHandle;
int gpu_roadID = 0x0fffffff;

//string -> float
void GetTmp(string str) {
    string s;

    for (int i = 0; i < str.size(); ++i) {
        if (str[i] != ',')
            s.push_back(str[i]);
        else {
            tmp.push_back(stof(s));
            s.clear();
        }
    }
    tmp.push_back(stof(s));
}
//load mapdata from csv & link node
int LoadMap(string csv)
{
    ifstream node, edge;

    string filename(csv);

    node.open(csv, ios::in);

    vector<string> s;
    if (node.is_open())
    {
        string str;
        string delim = ",";
        getline(node, str);

        int i = 0;
        while (!node.eof())
        {
            printf("%d\n", i++);
            string delim = ",";

            std::getline(node, str);
            if (str == "")
                break;
            GetTmp(str);

            lan[(int)tmp[1]] = tmp[6];
            lot[(int)tmp[1]] = tmp[7];

            if ((int)tmp[4]!= 0) {
                //road[(int)tmp[1]].node_id = (int)tmp[1];
                road[(int)tmp[1]].dest[road[(int)tmp[1]].r_len] = (int)tmp[2];
                road[(int)tmp[1]].len[road[(int)tmp[1]].r_len++] = tmp[3];
            }
            if ((int)tmp[5] != 0) {
                //road[(int)tmp[2]].node_id = (int)tmp[2];
                road[(int)tmp[2]].dest[road[(int)tmp[2]].r_len] = (int)tmp[1];
                road[(int)tmp[2]].len[road[(int)tmp[2]].r_len++] = tmp[3];
            }

            tmp.clear();
        }
        for(int idx = 0;idx < 100;idx++)
        {
            printf("%d index road len : %d dest ID : %d len : %f \n",idx,road[idx].r_len,road[idx].dest[0],road[idx].len[0]);
        }
        //for IPC
        if((gpu_roadID = shmget(_ROAD_GPU_,sizeof(cudaIpcMemHandle_t),0666 | IPC_CREAT | IPC_EXCL)) < 0)
        {
            cout << "1 \n";
            if (errno == EEXIST) {
                cout << "2 \n";
                if ((gpu_roadID = shmget(_ROAD_GPU_, 0, 0666)) < 0)
                {
                    cout << "3 \n";
                    return errno;
                }
                if (shmctl(gpu_roadID, IPC_RMID, (struct shmid_ds *)0x00) < 0)
                {
                    printf("4 \n");
                    return errno;
                }
            }
            else {
                printf("5 \n");
                return errno;
            }
            cout << "Error in ROAD GPU " << errno << '\n';
        }

        cudaMalloc(&gpu_road,10000000*sizeof(Node));
        cudaIpcGetMemHandle((cudaIpcMemHandle_t *) &road_gpuHandle, (void*)gpu_road);
        cudaMemcpy(gpu_road,road,10000000*sizeof(Node),cudaMemcpyHostToDevice);

        cudaIpcMemHandle_t* temp = (cudaIpcMemHandle_t *)shmat(gpu_roadID, 0, 0);
        if (temp == (void*)-1) {
            if (gpu_roadID != -1) shmctl(gpu_roadID, IPC_RMID, (struct shmid_ds *) 0);
        }
        memcpy(temp, &road_gpuHandle, sizeof(cudaIpcMemHandle_t));
        cout << "Load Map to GPU Success \n";
        edge.close();
    }
}
