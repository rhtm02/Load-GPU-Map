//
// Created by hyungjun on 5/25/21.
//

#ifndef ASTAR_PAPER_DATATYPE_CUH
#define ASTAR_PAPER_DATATYPE_CUH

typedef struct Node {
    int node_id = 0;
    Node *prev_nod;
    int r_len = 0;
    int dest[10];
    float len[10];
    float lat;
    float lot;

    double f = 0;
    double g =0;
} Node;


#endif //ASTAR_PAPER_DATATYPE_CUH
