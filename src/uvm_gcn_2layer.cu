
#include <iostream>
#include <stdio.h>
#include <omp.h>

#include "graph.h"
#include "utils.cuh"
#include "neighbor_utils.cuh"
#include "csr_formatter.h"


#include "cublas_utils.h"
#include "layer_new.cuh"
#include "gnn_layer.cuh"

// #define validate 1 //--> for results validation

using namespace std;
// using nidType = int;
// using nidType = long;

int main(int argc, char* argv[]){
	
    if (argc < 5){
        printf("Usage: ./main beg_file.bin csr_file.bin weight_file.bin num_GPUs partSize warpPerBlock dim\n");
        return -1;
    }

    cout << "Graph File: " << argv[1] << '\n';
    const char *beg_file = argv[1];
	const char *csr_file = argv[2];
	const char *weight_file = argv[3];
    
    int num_GPUs = atoi(argv[4]);
    int dim = atoi(argv[5]);
    int hiddenSize = atoi(argv[6]);
    int outdim = atoi(argv[7]);

    graph<long, long, nidType, nidType, nidType, nidType>* ginst = new graph<long, long, nidType, nidType, nidType, nidType>(beg_file, csr_file, weight_file);
    std::vector<nidType> global_row_ptr(ginst->beg_pos, ginst->beg_pos + ginst->vert_count + 1);
    std::vector<nidType> global_col_ind(ginst->csr, ginst->csr + ginst->edge_count);

    nidType numNodes = global_row_ptr.size() - 1;
    nidType numEdges = global_col_ind.size();    

    int nodesPerPE = (numNodes + num_GPUs - 1) / num_GPUs;
    float** h_input = new float*[num_GPUs];
    // float** d_den_out_1 = new float*[num_GPUs];
    // float** d_den_out_2 = new float*[num_GPUs];

    nidType **d_row_ptr = new nidType*[num_GPUs]; 
    nidType **d_col_ind = new nidType*[num_GPUs]; 

    float **d_input, **d_den_out_1, **d_den_out_2;
    gpuErrchk(cudaMallocManaged((void**)&d_input,       num_GPUs*sizeof(float*))); 
    gpuErrchk(cudaMallocManaged((void**)&d_den_out_1,   num_GPUs*sizeof(float*))); 
    gpuErrchk(cudaMallocManaged((void**)&d_den_out_2,   num_GPUs*sizeof(float*))); 

#ifdef validate
    float *hd_ref, *hd_input_ref;
    gpuErrchk(cudaMallocManaged((void**)&hd_ref,         nodesPerPE*dim*sizeof(float)));   // output reference
    gpuErrchk(cudaMallocManaged((void**)&hd_input_ref,   numNodes*dim*sizeof(float)));   // input reference.

    std::fill(hd_input_ref, hd_input_ref + numNodes*dim, 1.0);                           
    std::fill(hd_ref, hd_ref + nodesPerPE*dim, 0.0);                                  
#endif

#pragma omp parallel for
for (int mype_node = 0; mype_node < num_GPUs; mype_node++)
{
    cudaSetDevice(mype_node);

    h_input[mype_node] = (float*)malloc(nodesPerPE*dim*sizeof(float));
    // d_den_out_1[mype_node] = (float*)malloc(nodesPerPE*hiddenSize*sizeof(float));

    std::fill(h_input[mype_node], h_input[mype_node]+nodesPerPE*dim, 1.0);      // sets every value in the array to 1.0
    // std::fill(d_den_out_1[mype_node], d_den_out_1[mype_node]+nodesPerPE*dim, 0.0);    // sets every value in the array to 0.0

    printf("mype_node: %d, nodesPerPE: %d\n", mype_node, nodesPerPE);

    // UVM
    gpuErrchk(cudaMallocManaged((void**)&d_input[mype_node],   nodesPerPE*dim*sizeof(float))); // input: device 2D pointer
    gpuErrchk(cudaMallocManaged((void**)&d_den_out_1[mype_node], nodesPerPE*hiddenSize*sizeof(nidType)));
    gpuErrchk(cudaMallocManaged((void**)&d_den_out_2[mype_node], nodesPerPE*outdim*sizeof(nidType)));
    gpuErrchk(cudaMallocManaged((void**)&d_row_ptr[mype_node], (numNodes+1)*sizeof(nidType)));
    gpuErrchk(cudaMallocManaged((void**)&d_col_ind[mype_node], numEdges*sizeof(nidType))); 

    gpuErrchk(cudaMemcpy(d_input[mype_node],   h_input[mype_node],  nodesPerPE*dim*sizeof(float),   cudaMemcpyHostToDevice));
    gpuErrchk(cudaMemcpy(d_row_ptr[mype_node], &global_row_ptr[0],  (numNodes+1)*sizeof(nidType),   cudaMemcpyHostToDevice));
    gpuErrchk(cudaMemcpy(d_col_ind[mype_node], &global_col_ind[0],  numEdges*sizeof(nidType),       cudaMemcpyHostToDevice));
}


#ifdef validate
    cudaSetDevice(validate);
    int lb_src_val = nodesPerPE * validate;
    int ub_src_val = min_val(lb_src_val+nodesPerPE, numNodes);
    SAG_UVM_ref(hd_ref, hd_input_ref,  d_row_ptr[validate], d_col_ind[validate], ub_src_val, lb_src_val, numNodes, dim);
#endif

// One GPU per threads
#pragma omp parallel for
for (int mype_node = 0; mype_node < num_GPUs; mype_node++)
{
    cudaSetDevice(mype_node);

    float * dsp_out, *dsp_out_1;
    gpuErrchk(cudaMalloc((void**)&dsp_out,  nodesPerPE*hiddenSize*sizeof(float))); // output: device pointer
    gpuErrchk(cudaMalloc((void**)&dsp_out_1, nodesPerPE*outdim*sizeof(float))); // output: device pointer

    gpuErrchk(cudaMemset(dsp_out, 0, nodesPerPE * hiddenSize * sizeof(float)));
    gpuErrchk(cudaMemset(dsp_out_1, 0, nodesPerPE * outdim * sizeof(float)));

    dense_param_beg_uvm* dp1 = new dense_param_beg_uvm("d-1", d_input[mype_node], mype_node, d_den_out_1, nodesPerPE, dim, hiddenSize);
    dense_param_hidden_uvm* dp2 = new dense_param_hidden_uvm("d-2", dsp_out, mype_node, d_den_out_2, nodesPerPE, hiddenSize, outdim);
    softmax_param* smx2 = new softmax_param("smx-2", dsp_out_1, nodesPerPE, outdim);

    const int lb_src = nodesPerPE * mype_node;
    const int ub_src = min_val(lb_src+nodesPerPE, numNodes);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    dense_beg_forward_uvm(dp1);
    SAG_host_UVM_updated(dsp_out, d_den_out_1, 
                        d_row_ptr[mype_node], d_col_ind[mype_node], 
                        lb_src, ub_src, hiddenSize, num_GPUs, 
                        mype_node, nodesPerPE, numNodes);

    dense_hidden_forward_uvm(dp2);
    SAG_host_UVM_updated(dsp_out_1, d_den_out_2, 
                        d_row_ptr[mype_node], d_col_ind[mype_node],
                        lb_src, ub_src, outdim, num_GPUs,
                        mype_node, nodesPerPE, numNodes);
    softmax_forward(smx2);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("Time (ms): %.2f\n", milliseconds);
}

#pragma omp parallel for
for (int mype_node = 0; mype_node < num_GPUs; mype_node++)
{
    #ifdef validate
    if (mype_node == validate)
    {
        bool status = compare_array(hd_ref, d_den_out_1[mype_node], nodesPerPE*dim);
        if (status)
            printf("PE-%d: validate: True\n", mype_node);
        else
            printf("PE-%d: validate: False\n", mype_node);
    }
    #endif

    // cudaFree(hd_ref);
    cudaFree(d_den_out_1[mype_node]);
    cudaFree(d_input[mype_node]);    
    cudaFree(d_col_ind[mype_node]);
    cudaFree(d_row_ptr[mype_node]);
}
    cudaFree(d_den_out_1);
    cudaFree(d_input);
    cudaFree(d_col_ind);
    cudaFree(d_row_ptr);
    // free(h_ref);
    // free(h_input);

    return 0;
}