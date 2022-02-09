#ifndef neighbor_utils
#define neighbor_utils

#include <vector>
#include <algorithm> // for copy() and assign()
#include <iterator> // for back_inserter

#include <nvshmem.h>
#include <nvshmemx.h>

#define WARP_SIZE 32

template <typename T>
std::vector<std::vector<T>> build_part(std::string name,
    // T* partPtr, T* part2Node,
    std::vector<T>& indptr, T num_nodes, T partSize 
); 

__device__ inline 
void atomicAdd_F(float* address, float value){
  float old = value;  
  while ((old = atomicExch(address, atomicExch(address, 0.0f)+old))!=0.0f);
}

template <typename IDType, typename dataType, typename paraType>
void SAG_host(
    dataType* output,
    const dataType* input,
    const IDType* row_pointers,
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType lowbound,
    const IDType num_nodes,
    const IDType num_parts,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
);


__global__ 
void SAG_cuda_kernel_ref(float* d_output, const float* d_input, const int* d_row_ptr, const int* d_col_ind, const int lb_src, const int pe_num_nodes, const int dim);
__global__ 
void SAG_cuda_kernel_single_ref(float* d_output, const float* d_input, const int* d_row_ptr, const int* d_col_ind, const int num_nodes, const int dim);

template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel(
    dataType* output,
    const dataType* input,
    const IDType* row_pointers, 
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType  lowbound,
    const IDType num_nodes, 
    const IDType num_parts,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker,
    const paraType warpPerBlock
);

template <typename T>
std::vector<std::vector<T>> split_CSR(std::vector<T>& origin_ptr, 
                                      std::vector<T>& origin_col_idx, 
                                      T lb, T ub);

template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_fused(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
);

template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_fused_interleaved(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock,
    const paraType interleaved_dist
);


template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_fused_interleaved_wo_shared(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock,
    const paraType interleaved_dist
);

template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_range_only(
          dataType* output,
    const dataType* input,
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType  num_parts,
    const IDType lb,          // lower bound neighbor ID.
    const IDType ub,          // upper bound neighbor ID (exclusive)
    const IDType edge_lb,     // lower bound lower ID
    const IDType num_nodes,   // number of nodes assigned to current GPU.
    // other param.
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
); 


template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_host_unified(
          dataType* output,
    const dataType* input,
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType  edge_lb,
    const IDType  num_parts,
    const IDType  num_nodes,   // number of nodes assigned to current GPU.
    // other param.
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
); 

__global__ 
void mgg_SAG_basic_cuda(
    float* output,
    const float* input,
    const int* row_pointers,
    const int* column_index,
    const int lb,
    const int ub,
    const int dim,
    const int nodePerPE
);


__global__ 
void mgg_SAG_np_cuda(
          float* output,
    const float* input,
    const int* row_pointers,
    const int* column_index,
    const int lb,
    const int ub,
    const int dim,
    const int nodePerPE,
    const int part_size,
    const int warpPerBlock
);

__global__ 
void mgg_SAG_np_div_cuda(
          float* output,
    const float* input,
    const int* row_pointers_l,
    const int* column_index_l,
    const int* row_pointers_r,
    const int* column_index_r,
    const int lb,
    const int ub,
    const int dim,
    const int nodePerPE,
    const int partSize,
    const int warpPerBlock
);

template <typename T>
std::vector<std::vector<T>> split_CSR(std::vector<T>& origin_ptr, std::vector<T>& origin_col_idx, T lb, T ub)
{
    std::vector<T> local_ptr = {0}, remote_ptr={0};
    std::vector<T> local_col_idx, remote_col_idx;
    
    // iterate through the local range of the CSR.
    // split the CSR into two different range.
    for(int i = lb; i < ub; i++){
        for (int j = origin_ptr[i]; j < origin_ptr[i+1]; j++){
            int nid = origin_col_idx[j];
            
            if (lb <= nid && nid < ub){
                local_col_idx.push_back(nid);
            }
            else{
                remote_col_idx.push_back(nid);
            }
        }
        local_ptr.push_back(local_col_idx.size());
        remote_ptr.push_back(remote_col_idx.size());
    }

    return {local_ptr, remote_ptr, local_col_idx, remote_col_idx};
}


//
// Partitioning the neighbors of input graph.
//
template <typename T>
std::vector<std::vector<T>> build_part(std::string name,
    // T* partPtr, T* part2Node,
    std::vector<T>& indptr, T num_nodes, T partSize 
  ) 
{

    T degree, thisNumParts, numParts = 0;

    std::vector<T> node2Part = {0};

    for(T i = 0; i < num_nodes; i++)
    {
        degree = indptr[i + 1] - indptr[i];
        thisNumParts = (degree + partSize - 1) / partSize;
        numParts += thisNumParts;
        node2Part.push_back(numParts);
    }
    node2Part.push_back(numParts);
    // printf("numParts: %d\n", numParts);
    // exit(0);
//   auto partPtr = torch::zeros(numParts + 1);
//   auto part2Node = torch::zeros(numParts);
    std::vector<T> partPtr(numParts + 1, 0);
    std::vector<T> part2Node(numParts, 0);

    T part_counter = 0;
    for(T i = 0; i < num_nodes; i++)
    {
        T degree = indptr[i + 1] - indptr[i];
        // if(degree % partSize == 0)
        //     thisNumParts = degree / partSize ;
        // else
        //     thisNumParts = degree / partSize + 1;
        thisNumParts = (degree + partSize - 1) / partSize;

        for (T pid = 0; pid < thisNumParts; pid++){
            T partBeg = indptr[i] + pid * partSize;
            T partEnd = partBeg + partSize < indptr[i  + 1]? partBeg + partSize: indptr[i + 1];
            partPtr[part_counter] = partBeg;
            part2Node[part_counter++] = i;

            if (i == num_nodes - 1 &&  partEnd == indptr[i + 1])
                partPtr[part_counter] = partEnd;
        }
    }
    printf("%s, num_nodes: %d, part_size, %d, num_parts, %d\n",
        name.c_str(), num_nodes, partSize, numParts);
    return {partPtr, part2Node, node2Part};
}

// support local access only.
template <typename IDType, typename dataType, typename paraType>
void SAG_host(
    dataType* output,
    const dataType* input,
    const IDType* row_pointers,
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType lowbound,
    const IDType num_nodes,
    const IDType num_parts,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
){
    // auto output = torch::zeros_like(input);
    // const int num_nodes = output.size(0);
    // const int dim = output.size(1);
    // const int num_parts = part2Node.size(0);

    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (num_parts * WARP_SIZE + block  - 1) / block; 
    int shared_memory = partSize*warpPerBlock*sizeof(int)+warpPerBlock*dim*sizeof(float);

    // printf("grid: %d, block: %d, shared_memory: %d\n", grid, block, shared_memory);
    // printf("dim: %d, num_nodes: %d, num_parts: %d\n", dim, num_nodes, num_parts);
    // printf("dimWorker: %d\n", dimWorker);

    SAG_cuda_kernel<IDType, dataType, paraType><<<grid, block, shared_memory>>>(
        output, input,
        row_pointers, column_index, 
        part_pointers, part2Node, 
        lowbound,
        num_nodes, num_parts, partSize, dim, 
        dimWorker, warpPerBlock
    );
                                 
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error at SAG_cuda_kernel: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}

// support local and remote access.
template <typename IDType, typename dataType, typename paraType>
void SAG_host_fused(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    paraType warpPerBlock
){

    // const int total_parts = local_num_parts + remote_num_parts;
    const int total_parts = local_num_parts > remote_num_parts? local_num_parts: remote_num_parts;
    // const int total_parts = local_num_parts + remote_num_parts;
    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (total_parts * WARP_SIZE + block  - 1) / block; 
    int shared_memory = partSize*warpPerBlock*sizeof(int) + 2*partSize*warpPerBlock*dim*sizeof(float);    
    printf("grid: %d, block: %d, shared_memory (KB): %.3f\n", grid, block, shared_memory*1.0f/1e3);
    cudaFuncSetAttribute(SAG_cuda_kernel_fused<IDType, dataType, paraType>, cudaFuncAttributeMaxDynamicSharedMemorySize, shared_memory);
    // printf("dim: %d, num_nodes: %d, num_parts: %d\n", dim, num_nodes, num_parts);
    // printf("local_num_parts: %d, remote_num_parts: %d\n", local_num_parts, remote_num_parts);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    #define NPROF 1
    for (int i = 0; i < NPROF; i++)
    SAG_cuda_kernel_fused<IDType, dataType, paraType><<<grid, block, shared_memory>>>(
        output,
        input,
        // local access
        local_row_pointers,
        local_column_index,
        local_part_pointers,
        local_part2Node,
        local_num_parts,
        // remote access.
        remote_row_pointers,
        remote_column_index,
        remote_part_pointers,
        remote_part2Node,
        remote_num_parts,
        // other param.
        num_nodes,
        lowbound,
        partSize,
        dim,
        dimWorker, 
        warpPerBlock
    );
                               
    cudaEventRecord(stop);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    printf("kernel time (ms): %.3f\n", milliseconds/NPROF);

    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error at SAG_cuda_kernel_fused: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}

// support local and remote access.
template <typename IDType, typename dataType, typename paraType>
void SAG_host_fused_interleaved(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    paraType warpPerBlock,
    paraType interleaved_dist=1
){

    // const int total_parts = local_num_parts + remote_num_parts;
    const int total_parts = local_num_parts > remote_num_parts? local_num_parts: remote_num_parts;
    const int block = warpPerBlock * WARP_SIZE;
    const int total_warps = (total_parts + interleaved_dist - 1)/interleaved_dist;
    const int grid = (total_warps * WARP_SIZE + block  - 1) / block; 

    int shared_memory = partSize*warpPerBlock*sizeof(int) + 2*warpPerBlock*dim*sizeof(float);    
    printf("grid: %d, block: %d, shared_memory (KB): %.3f\n", grid, block, shared_memory*1.0f/1e3);
    // cudaFuncSetAttribute(SAG_cuda_kernel_fused_interleaved_wo_shared<IDType, dataType, paraType>, cudaFuncAttributeMaxDynamicSharedMemorySize, shared_memory);
    cudaFuncSetAttribute(SAG_cuda_kernel_fused_interleaved<IDType, dataType, paraType>, cudaFuncAttributeMaxDynamicSharedMemorySize, shared_memory);

    // printf("dim: %d, num_nodes: %d, num_parts: %d\n", dim, num_nodes, num_parts);
    // printf("local_num_parts: %d, remote_num_parts: %d\n", local_num_parts, remote_num_parts);

    // cudaEvent_t start, stop;
    // cudaEventCreate(&start);
    // cudaEventCreate(&stop);
    // cudaEventRecord(start);
    // #define NPROF 1
    // for (int i = 0; i < NPROF; i++)
    SAG_cuda_kernel_fused_interleaved<IDType, dataType, paraType><<<grid, block, shared_memory>>>(
    // SAG_cuda_kernel_fused_interleaved_wo_shared<IDType, dataType, paraType><<<grid, block, shared_memory>>>(
        output,
        input,
        // local access
        local_row_pointers,
        local_column_index,
        local_part_pointers,
        local_part2Node,
        local_num_parts,
        // remote access.
        remote_row_pointers,
        remote_column_index,
        remote_part_pointers,
        remote_part2Node,
        remote_num_parts,
        // other param.
        num_nodes,
        lowbound,
        partSize,
        dim,
        dimWorker, 
        warpPerBlock,
        interleaved_dist
    );
                               
    // cudaEventRecord(stop);
    // cudaEventSynchronize(stop);
    // float milliseconds = 0;
    // cudaEventElapsedTime(&milliseconds, start, stop);
    // printf("kernel time (ms): %.3f\n", milliseconds/NPROF);
    gpuErrchk(cudaDeviceSynchronize());
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error at SAG_cuda_kernel_fused_interleaved: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}



// support local and remote access.
// 1. no local and remote split.
// 2. process the nodes in [lb, ub]
// 3. row_pointers and column_index are chuncked and duplicated from original list.  
void mgg_SAG_basic(
          float* output, // NVSHMEM 
    const float* input,  // NVSHMEM
    const int* row_pointers,
    const int* column_index,
    const int lb,
    const int ub,
    const int dim,
    const int nodePerPE
){
    const int num_nodes = ub - lb;
    const int warpPerBlock = 4;
    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (num_nodes * WARP_SIZE + block  - 1) / block; 
    const int dyn_shared_mem = warpPerBlock * dim * sizeof(float); // for temporal caching the NVSHMEM result.
    printf("dyn_shared_mem: %d\n", dyn_shared_mem);

    // cudaEvent_t start, stop;
    // cudaEventCreate(&start);
    // cudaEventCreate(&stop);
    // cudaEventRecord(start);
    // #define NPROF 1
    // for (int i = 0; i < NPROF; i++)
    mgg_SAG_basic_cuda<<<grid, block, dyn_shared_mem>>>(
        output, input,
        row_pointers, column_index,
        lb, ub,
        dim,
        nodePerPE
    );
                               
    // cudaEventRecord(stop);
    // cudaEventSynchronize(stop);
    // float milliseconds = 0;
    // cudaEventElapsedTime(&milliseconds, start, stop);
    // printf("kernel time (ms): %.3f\n", milliseconds/NPROF);
    gpuErrchk(cudaDeviceSynchronize());
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error @mgg_SAG_basic_cuda: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}




// Neighbor partition version for multi-GPU SAG
// 1. no local and remote split.
// 2. process the nodes in [lb, ub].
// 3. implicitly partition the neighbors of a subgraph.
void mgg_SAG_neighbor_partition(
      float* output, // NVSHMEM 
const float* input,  // NVSHMEM
const int* row_pointers,
const int* column_index,
const int lb,
const int ub,
const int dim,
const int nodePerPE
){
    const int num_nodes = ub - lb;
    const int warpPerBlock = 4;
    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (num_nodes * WARP_SIZE + block  - 1) / block; 
    const int np_size = 4;    // for implicit neighbor partition size = 4.
    const int dyn_shared_mem = warpPerBlock * dim * sizeof(float); // for temporal  caching the NVSHMEM result.

    // cudaEvent_t start, stop;
    // cudaEventCreate(&start);
    // cudaEventCreate(&stop);
    // cudaEventRecord(start);
    // #define NPROF 1
    // for (int i = 0; i < NPROF; i++)
    mgg_SAG_np_cuda<<<grid, block, dyn_shared_mem>>>(
                                                    output, input,
                                                    row_pointers, column_index,
                                                    lb, ub,
                                                    dim,
                                                    nodePerPE,
                                                    np_size,
                                                    warpPerBlock);
                            
    // cudaEventRecord(stop);
    // cudaEventSynchronize(stop);
    // float milliseconds = 0;
    // cudaEventElapsedTime(&milliseconds, start, stop);
    // printf("kernel time (ms): %.3f\n", milliseconds/NPROF);
    gpuErrchk(cudaDeviceSynchronize());
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error @mgg_SAG_np_cuda: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}




// Neighbor partition version for multi-GPU SAG
// 1. no local and remote split.
// 2. process the nodes in [lb, ub].
// 3. implicitly partition the neighbors of a subgraph.
void mgg_SAG_np_div(
    float* output, // NVSHMEM 
const float* input,  // NVSHMEM
const int* row_pointers_l,
const int* column_index_l,
const int* row_pointers_r,
const int* column_index_r,
const int lb,
const int ub,
const int dim,
const int nodePerPE
){
  const int num_nodes = ub - lb;
  
  const int warpPerBlock = 4;
  const int np_size = 4;   // for implicit neighbor partition size = 4.
  
  const int block = warpPerBlock * WARP_SIZE;
//   const int grid = (num_nodes * block + block  - 1) / block; 
  const int grid = num_nodes; // one node per block.
  const int dyn_shared_mem = 2 * warpPerBlock * dim * sizeof(float); // for temporal  caching the NVSHMEM result.

  // cudaEvent_t start, stop;
  // cudaEventCreate(&start);
  // cudaEventCreate(&stop);
  // cudaEventRecord(start);
  // #define NPROF 1
  // for (int i = 0; i < NPROF; i++)
  mgg_SAG_np_div_cuda<<<grid, block, dyn_shared_mem>>>(
                                                  output, input,
                                                  row_pointers_l, column_index_l,
                                                  row_pointers_r, column_index_r,
                                                  lb, ub,
                                                  dim,
                                                  nodePerPE,
                                                  np_size,
                                                  warpPerBlock);
                          
  // cudaEventRecord(stop);
  // cudaEventSynchronize(stop);
  // float milliseconds = 0;
  // cudaEventElapsedTime(&milliseconds, start, stop);
  // printf("kernel time (ms): %.3f\n", milliseconds/NPROF);
  gpuErrchk(cudaDeviceSynchronize());
  cudaError_t error = cudaGetLastError();
  if(error != cudaSuccess){
      printf("CUDA error @mgg_SAG_np_cuda: %s\n", cudaGetErrorString(error));
      exit(-1);
  }
}



__global__ 
void print_dev_column_index(
    const int* column_index,
    const int len)
{
    for (int i = 0; i < len; i++)
        printf("dev_column_index[%d]: %d\n", i, column_index[i]);
}


__global__ 
void mgg_SAG_basic_cuda(
          float* output,
    const float* input,
    const int* row_pointers,
    const int* column_index,
    const int lb,
    const int ub,
    const int dim,
    const int nodePerPE
)
{

    const int tid =  blockIdx.x * blockDim.x + threadIdx.x;
    const int wid = tid / 32;               // global warp-id
    const int blk_wid = threadIdx.x / 32;   // block_level warp-id.
    const int lanid = tid % 32;             // lane-id
    const int num_nodes = ub - lb;          // num of nodes per PE.
    // __shared__ float tmp[50];
    extern __shared__ float tmp[];          // for remotely fetched embeddings.

    if (wid < num_nodes){        
        const int eidx_s = row_pointers[wid] - row_pointers[0];            // Get the local edge index
        const int eidx_e = row_pointers[wid + 1] - row_pointers[0];

        for (int eidx = eidx_s; eidx < eidx_e; eidx++){
            
            int nid = column_index[eidx]; 
            // printf("eidx: %d, nid: %d, nodePerPE: %d\n", eidx, nid, nodePerPE);
            if ((lb <= nid) && (nid < ub)){
                int local_nid = nid % nodePerPE;
                for (int d = lanid; d < dim; d += WARP_SIZE){
                    output[wid * dim + d] += input[local_nid * dim + d];
                }
            }
            else{
                int r_GPUid = nid / nodePerPE; 
                int r_offset = nid % nodePerPE;
                // if (r_GPUid > 1) printf("nid: %d, nodePerPE: %d, GPU id: %d\n", nid, nodePerPE, r_GPUid);
                nvshmemx_float_get_warp((float*)&tmp[blk_wid * dim], &input[r_offset * dim], dim, r_GPUid);
                for (int d = lanid; d < dim; d += WARP_SIZE){
                    output[wid * dim + d] += tmp[blk_wid * dim + d];
                }
            }
        }
    }

}

__global__ 
void mgg_SAG_np_cuda(
          float* output,
    const float* input,
    const int* row_pointers,
    const int* column_index,
    const int lb,
    const int ub,
    const int dim,
    const int nodePerPE,
    const int partSize,
    const int warpPerBlock
){
    const int tid =  blockIdx.x * blockDim.x + threadIdx.x;
    const int wid = tid / 32;                // global warp-id
    const int blk_wid = threadIdx.x / 32;    // block-level warp-id.
    const int lanid = tid % 32;              // lane-id
    const int num_nodes = ub - lb;           // num of nodes per PE.
    // __shared__ float tmp[50];
    extern __shared__ float tmp[];

    if (wid < num_nodes){        
        // Get the neighbor range of a node.
        const int eidx_s = row_pointers[wid] - row_pointers[0];            // Get the local edge index
        const int eidx_e = row_pointers[wid + 1] - row_pointers[0];
        
        // Get the neighbor partition of a warp. (w_eidx_beg, w_eidx_beg + partSize)
        for (int w_eidx_beg = eidx_s + wid * partSize; w_eidx_beg < eidx_e; w_eidx_beg += warpPerBlock * partSize){
            
            // Iterater over the neighbor partition of a warp.
            for (int eidx = w_eidx_beg; eidx < min(w_eidx_beg + partSize, eidx_e); eidx++){

                int nid = column_index[eidx]; 
                // printf("eidx: %d, nid: %d, nodePerPE: %d\n", eidx, nid, nodePerPE);
                if ((lb <= nid) && (nid < ub)){
                    int local_nid = nid % nodePerPE;
                    for (int d = lanid; d < dim; d += WARP_SIZE){
                        output[wid * dim + d] += input[local_nid * dim + d];
                    }
                }
                else{
                    int r_GPUid = nid / nodePerPE; 
                    int r_offset = nid % nodePerPE;
                    // if (r_GPUid > 1) printf("nid: %d, nodePerPE: %d, GPU id: %d\n", nid, nodePerPE, r_GPUid);
                    nvshmemx_float_get_warp((float*)&tmp[blk_wid * dim], &input[r_offset * dim], dim, r_GPUid);
                    for (int d = lanid; d < dim; d += WARP_SIZE){
                        output[wid * dim + d] += tmp[blk_wid * dim + d];
                    }
                }
            } // end (eidx)
        } // end (w_eidex_beg)
    } // end if (wid)
}


__global__ 
void mgg_SAG_np_div_cuda(
          float* output,
    const float* input,
    const int* row_pointers_l,
    const int* column_index_l,
    const int* row_pointers_r,
    const int* column_index_r,
    const int lb,
    const int ub,
    const int dim,
    const int nodePerPE,
    const int partSize,
    const int warpPerBlock
){
    // const int tid = blockIdx.x * blockDim.x + threadIdx.x;
    const int bid = blockIdx.x;                // global warp-id
    const int blk_wid = threadIdx.x / 32;     // block-level warp-id.
    const int lanid = threadIdx.x % 32;       // lane-id
    const int num_nodes = ub - lb;           // num of nodes per PE.
    extern __shared__ float tmp[];
    float* tmp2 = (float*) &tmp[warpPerBlock * dim];

    if (bid < num_nodes){        

        for (int idx = threadIdx.x; idx < 2 * warpPerBlock * dim; idx += blockDim.x){
            tmp[idx] = 0.0f;    
        }
        __syncthreads();

        // 
        // Get the local neighbor partition.
        //
        // Get the neighbor range of a node.
        int eidx_s = row_pointers_l[bid];           
        int eidx_e = row_pointers_l[bid + 1];

        // if ((bid == 3456 || bid == 3457) && lb == 0)
        //     printf("local: %d, remote: %d\n", eidx_e - eidx_s, row_pointers_r[bid + 1] - row_pointers_r[bid]);
        
        // Get the neighbor partition of a warp. (w_eidx_beg, w_eidx_beg + partSize)
        for (int b_eidx_beg = eidx_s; b_eidx_beg < eidx_e; b_eidx_beg += warpPerBlock * partSize){
            
            int warp_eidx_beg = b_eidx_beg + blk_wid * partSize;            
            int warp_eidx_end = warp_eidx_beg + partSize;         
            // Iterater over the neighbor partition of a warp.
            for (int eidx = warp_eidx_beg; eidx < min(warp_eidx_end, eidx_e); eidx++){

                int nid = column_index_l[eidx]; 
                // printf("eidx: %d, nid: %d, nodePerPE: %d\n", eidx, nid, nodePerPE);
                int local_nid = nid % nodePerPE;
                for (int d = lanid; d < dim; d += WARP_SIZE){
                    // output[bid * dim + d] += input[local_nid * dim + d];
                    // atomicAdd_F(&output[bid * dim + d], input[local_nid * dim + d]);
                    tmp[blk_wid * dim + d] += input[local_nid * dim + d];      
                    // atomicAdd_F(&tmp[blk_wid * dim + d], input[local_nid * dim + d]);
                }
                // __syncwarp();
            } // end (eidx)
            // __syncwarp();
        } // end (w_eidex_beg)

        // __syncthreads();
        // if (blk_wid == 0)
        // for (int w_iter = 0; w_iter < warpPerBlock; w_iter++)
        // for (int d = lanid; d < dim; d += WARP_SIZE){
        //     if ((bid == 3457 || bid == 3456 ) && lb == 0) printf("bid[%d]: output: %.3f, tmp: %.3f\n", bid, output[bid * dim + d], tmp[w_iter * dim + d]);
        //     output[bid * dim + d] += tmp[w_iter * dim + d];
        // }
        // for (int idx = 0; idx < 2 * warpPerBlock * dim; idx += blockDim.x){
        //     tmp[idx] = 0;    
        // }
        // 
        // Get the remote neighbor partition.
        //
        eidx_s = row_pointers_r[bid];           
        eidx_e = row_pointers_r[bid + 1];
        // Get the neighbor partition of a warp. (w_eidx_beg, w_eidx_beg + partSize)
        for (int b_eidx_beg = eidx_s; b_eidx_beg < eidx_e; b_eidx_beg += warpPerBlock * partSize){

            int warp_eidx_beg = b_eidx_beg + blk_wid * partSize;            
            int warp_eidx_end = warp_eidx_beg + partSize;
            // Iterater over the neighbor partition of a warp.
            for (int eidx = warp_eidx_beg; eidx < min(warp_eidx_end, eidx_e); eidx++){

                int nid = column_index_r[eidx]; 
                int r_GPUid = nid / nodePerPE; 
                int r_offset = nid % nodePerPE;
                // if (r_GPUid > 1) printf("nid: %d, nodePerPE: %d, GPU id: %d\n", nid, nodePerPE, r_GPUid);

                // nvshmemx_float_get_warp((float*)&tmp[blk_wid * dim], &input[r_offset * dim], dim, r_GPUid);
                nvshmemx_float_get_warp((float*)&tmp2[blk_wid * dim], &input[r_offset * dim], dim, r_GPUid);
                for (int d = lanid; d < dim; d += WARP_SIZE){
                    // output[bid * dim + d] += tmp[blk_wid * dim + d];
                    // atomicAdd_F(&output[bid * dim + d], tmp2[blk_wid * dim + d]);
                    tmp[blk_wid * dim + d] += tmp2[blk_wid * dim + d];                    
                }
            } // end (eidx)
        } // end (w_eidex_beg)

 
        // __syncthreads();

        for (int d = lanid; d < dim; d += WARP_SIZE)
            // output[bid * dim + d] += tmp[warp_iter * dim + d];
            atomicAdd_F(&output[bid * dim + d], tmp[blk_wid * dim + d]);
    } // end if (wid)
}


// support local and remote access.
template <typename IDType, typename dataType, typename paraType>
void SAG_host_range_only(
          dataType* output,
    const dataType* input,
    // local access
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType  num_parts,
    const IDType  lb,
    const IDType  ub,
    const IDType edge_lb,     // lower bound lower ID
    const IDType  num_nodes,
    // other param.
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
)
{

    // printf("num_parts: %d \n", num_parts);
    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (num_parts * WARP_SIZE + block  - 1) / block; 
    const int shared_memory = partSize*warpPerBlock*sizeof(int) + warpPerBlock*dim*sizeof(float);    
    // printf("grid: %d, block: %d, shared_memory: %d\n", grid, block, shared_memory);
    // printf("dim: %d, num_nodes: %d, num_parts: %d\n", dim, num_nodes, num_parts);

    SAG_cuda_kernel_range_only<IDType, dataType, paraType><<<grid, block, shared_memory>>>(
        output,
        input,
        column_index,
        part_pointers,
        part2Node,
        num_parts,
        lb,
        ub,
        edge_lb,   
        num_nodes,
        // other param.
        partSize,
        dim,
        dimWorker, 
        warpPerBlock
    );


    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error at SAG_cuda_kernel_range_only: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}




// support local and remote access.
template <typename IDType, typename dataType, typename paraType>
void SAG_host_unified(
          dataType* output,
    const dataType* input,
    // local access
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType  edge_lb,
    const IDType  num_parts,
    const IDType  num_nodes,
    // other param.
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
)
{

    // printf("num_parts: %d \n", num_parts);
    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (num_parts * WARP_SIZE + block  - 1) / block; 
    const int shared_memory = partSize*warpPerBlock*sizeof(int) + warpPerBlock*dim*sizeof(float);    
    printf("grid: %d, block: %d, shared_memory (KB): %.3f\n", grid, block, 1.0f*shared_memory/1e3);
    // printf("dim: %d, num_nodes: %d, num_parts: %d\n", dim, num_nodes, num_parts);
    cudaFuncSetAttribute(SAG_cuda_kernel_host_unified<IDType, dataType, paraType>, cudaFuncAttributeMaxDynamicSharedMemorySize, shared_memory);

    SAG_cuda_kernel_host_unified<IDType, dataType, paraType><<<grid, block, shared_memory>>>(
        output,
        input,
        column_index,
        part_pointers,
        part2Node,
        edge_lb,
        num_parts,
        num_nodes,
        // other param.
        partSize,
        dim,
        dimWorker, 
        warpPerBlock
    );


    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error at SAG_cuda_kernel_host_unified: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}


// Reference kernel for validation across multiple GPUs
void SAG_host_ref(
          float* output,
    const float* input,
    const int* row_ptr,
    const int* column_index,
    const int lb_src,
    const int ub_src,
    const int dim
)
{
    const int warpPerBlock = 4;
    const int pe_num_nodes = ub_src - lb_src;

    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (pe_num_nodes * WARP_SIZE + block  - 1) / block; 
    printf("SAG_cuda_kernel_ref: grid: %d, block: %d\n", grid, block);

    SAG_cuda_kernel_ref<<<grid, block>>>(output, input, row_ptr, column_index, 
                                            lb_src, pe_num_nodes, dim);

    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error @ SAG_cuda_kernel_ref: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}


// A single kernel for validation
void SAG_host_single_ref(
          float* output,
    const float* input,
    const int* row_ptr,
    const int* column_index,
    const int num_nodes,
    const int dim
)
{
    const int warpPerBlock = 4;
    const int block = warpPerBlock * WARP_SIZE;
    const int grid = (num_nodes * WARP_SIZE + block  - 1) / block; 
    printf("SAG_host_single_ref: grid: %d, block: %d\n", grid, block);

    SAG_cuda_kernel_single_ref<<<grid, block>>>(output, input, row_ptr, column_index, num_nodes, dim);

    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess){
        printf("CUDA error @ SAG_cuda_kernel_single_ref: %s\n", cudaGetErrorString(error));
        exit(-1);
    }
}





template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel(
   dataType* output,
   const dataType* input,
   const IDType* row_pointers, 
   const IDType* column_index,
   const IDType* part_pointers,
   const IDType* part2Node,
   const IDType lowbound,
   const IDType num_nodes, 
   const IDType num_parts,
   const paraType partSize,
   const paraType dim,
   const paraType dimWorker,
   const paraType warpPerBlock
) {

    int tid =  blockIdx.x * blockDim.x + threadIdx.x;         // global thread-id
    int warpId = tid / WARP_SIZE;                             // global warp-id
    int block_warpId = threadIdx.x / WARP_SIZE;               // block warp-id
    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid

    extern __shared__ int part_meta[];                                      // part information.
    int *partial_ids = part_meta;                                           // caching ids
    float *partial_results = (float*)&part_meta[partSize*warpPerBlock];     // caching partial results.

    if (warpId < num_parts){

        int srcId = part2Node[warpId];              // aggregated source node
        int partBeg = part_pointers[warpId];        // partitioning pointer start
        int partEnd = part_pointers[warpId + 1];    // part pointer end

        // Cache the part neighbors.
        const int pindex_base = block_warpId * partSize;
        // #pragma unroll
        for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
            // printf("1--pindex_base: %d, laneid: %d\n", pindex_base, laneid);
            partial_ids[pindex_base + nidx - partBeg] = column_index[nidx];
            // if(partial_ids[pindex_base + laneid]  >= num_nodes || partial_ids[pindex_base + laneid]  < 0) printf("---- partial_ids: %d\n", partial_ids[pindex_base + laneid] );
        }

         __syncwarp();

        // Neighbor aggregation within each part
        const int presult_base = block_warpId * dim;
        for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
        {
            // if (laneid == 0) printf("2--pindex_base: %d, nIdx: %d\n", pindex_base, nIdx);
            int nid = partial_ids[pindex_base + nIdx] - lowbound;
            // if(nid >= num_nodes || nid < 0) printf("Error nid: %d\n", nid);

            // Initialize shared memory for partial results
            if (nIdx == 0)
                if (laneid < dimWorker)
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    partial_results[presult_base + d] = 0.0f;
                }
            
            if (laneid < dimWorker)
            #pragma unroll
            for (int d = laneid; d < dim; d += dimWorker){
                partial_results[presult_base + d] += input[nid*dim + d];
            }
        }

        // output the result to global memory from the shared memory
        if (laneid < dimWorker)
        #pragma unroll
        for (int d = laneid; d < dim; d += dimWorker){
            atomicAdd_F((float*)&output[srcId*dim + d], partial_results[presult_base + d]);
        }
    }
}

template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_fused(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
) 
{

    int tid =  blockIdx.x * blockDim.x + threadIdx.x;         // global thread-id
    int warpId = tid / WARP_SIZE;                             // global warp-id
    int block_warpId = threadIdx.x / WARP_SIZE;               // block warp-id
    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid

    extern __shared__ int part_meta[];                                      // part information.
    int *partial_ids = part_meta;                                           // caching ids
    float *partial_results = (float*)&part_meta[partSize*warpPerBlock];     // caching partial results.
    float *tmp_local = (float*)&partial_results[partSize*warpPerBlock*dim];     // caching partial results.

    // ---------------------
    // process LOCAL parts.
    // ---------------------
    if (warpId < local_num_parts){

        int srcId = local_part2Node[warpId];              // local: aggregated source node.
        int partBeg = local_part_pointers[warpId];        // local: partitioning pointer start.
        int partEnd = local_part_pointers[warpId + 1];    // local: part pointer end.

        // Cache the part neighbors.
        const int pindex_base = block_warpId * partSize;
        // #pragma unroll
        for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
            // printf("1--pindex_base: %d, laneid: %d\n", pindex_base, laneid);
            partial_ids[pindex_base + nidx - partBeg] = local_column_index[nidx];
            // if(partial_ids[pindex_base + laneid]  >= num_nodes || partial_ids[pindex_base + laneid]  < 0) printf("---- partial_ids: %d\n", partial_ids[pindex_base + laneid] );
        }

         __syncwarp();

        // Neighbor aggregation within each part
        const int presult_base = block_warpId * dim;
        for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
        {
            // if (laneid == 0) printf("2--pindex_base: %d, nIdx: %d\n", pindex_base, nIdx);
            int nid = partial_ids[pindex_base + nIdx] % num_nodes;

            // Initialize shared memory for partial results
            if (nIdx == 0)
                if (laneid < dimWorker)
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    partial_results[presult_base + d] = 0.0f;
                }
            
            if (laneid < dimWorker)
            #pragma unroll
            for (int d = laneid; d < dim; d += dimWorker){
                partial_results[presult_base + d] += input[nid*dim + d];
            }
        }

        // output the result to global memory from the shared memory
        if (laneid < dimWorker)
        #pragma unroll
        for (int d = laneid; d < dim; d += dimWorker){
            atomicAdd_F((float*)&output[(srcId % num_nodes)*dim + d], partial_results[presult_base + d]);
        }
    }

    // __syncwarp();

    #define remote
    #ifdef remote
    // ---------------------
    // process REMOTE parts.
    // ---------------------
    else{   // local_num_parts <= warpId
            // warpId < local_num_parts+remote_num_parts

        int warp_offset = warpId - local_num_parts;

        int srcId = remote_part2Node[warp_offset];              // remote: aggregated source node.
        int partBeg = remote_part_pointers[warp_offset];        // remote: partitioning pointer start.
        int partEnd = remote_part_pointers[warp_offset + 1];    // remote: part pointer end.

        // Cache the part neighbors.
        const int pindex_base = block_warpId * partSize;
        // #pragma unroll
        for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
            partial_ids[pindex_base + nidx - partBeg] = remote_column_index[nidx];
        }

         __syncwarp();

        // Neighbor aggregation within each part
        const int presult_base = block_warpId * dim;
        for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
        {
            int nid = partial_ids[pindex_base + nIdx] % num_nodes;
            int remote_pe = partial_ids[pindex_base + nIdx] / num_nodes;

            // Initialize shared memory for partial results
            if (nIdx == 0)
                // if (laneid < dimWorker)
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    partial_results[presult_base + d] = 0.0f;
                }
        
            // if (remote_pe > 1) printf("remote_pe: %d\n", remote_pe);
            nvshmemx_float_get_warp(&tmp_local[presult_base], &input[nid*dim], dim, remote_pe);
            // nvshmemx_float_get_warp(&tmp_local[0], &input[nid*dim], dim, remote_pe);

            // if (laneid < dimWorker)
            #pragma unroll
            for (int d = laneid; d < dim; d += dimWorker){
                partial_results[presult_base + d] += tmp_local[presult_base+d];
                // partial_results[presult_base + d] += tmp_local[d];
            }
        }

        // output the result to global memory from the shared memory
        // if (laneid < dimWorker)
        #pragma unroll
        for (int d = laneid; d < dim; d += dimWorker){
            atomicAdd_F((float*)&output[(srcId%num_nodes)*dim + d], partial_results[presult_base + d]);
        }
    }
    #endif
}

template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_fused_interleaved(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock,
    const paraType interleaved_dist
) 
{
    int tid =  blockIdx.x * blockDim.x + threadIdx.x;         // global thread-id
    int warpId = tid / WARP_SIZE;                             // global warp-id
    int block_warpId = threadIdx.x / WARP_SIZE;               // block warp-id
    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid

    extern __shared__ int part_meta[];                                      // part information.
    int *partial_ids = part_meta;                                           // caching ids
    float *partial_results = (float*)&part_meta[partSize*warpPerBlock];     // caching partial results.
    float *tmp_local = (float*)&partial_results[warpPerBlock*dim];     // caching partial results.

    int p_start, p_end;
    // ---------------------
    // process LOCAL parts.
    // ---------------------
    if (warpId*interleaved_dist < local_num_parts){
        
        p_start = warpId*interleaved_dist;
        p_end =  min(p_start + interleaved_dist, local_num_parts);

        for (int p_cursor = p_start; p_cursor < p_end; p_cursor++)
        {
            int srcId = local_part2Node[p_cursor];              // local: aggregated source node.
            int partBeg = local_part_pointers[p_cursor];        // local: partitioning pointer start.
            int partEnd = local_part_pointers[p_cursor + 1];    // local: part pointer end.

            // Cache the part neighbors.
            const int pindex_base = block_warpId * partSize;
            // #pragma unroll
            for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
                // printf("1--pindex_base: %d, laneid: %d\n", pindex_base, laneid);
                partial_ids[pindex_base + nidx - partBeg] = local_column_index[nidx];
                // if(partial_ids[pindex_base + laneid]  >= num_nodes || partial_ids[pindex_base + laneid]  < 0) printf("---- partial_ids: %d\n", partial_ids[pindex_base + laneid] );
            }

            __syncwarp();

            // Neighbor aggregation within each part
            const int presult_base = block_warpId * dim;
            for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
            {
                // if (laneid == 0) printf("2--pindex_base: %d, nIdx: %d\n", pindex_base, nIdx);
                int nid = partial_ids[pindex_base + nIdx] % num_nodes;

                // Initialize shared memory for partial results
                if (nIdx == 0)
                    if (laneid < dimWorker)
                    #pragma unroll
                    for (int d = laneid; d < dim; d += dimWorker){
                        partial_results[presult_base + d] = 0.0f;
                    }
                
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    partial_results[presult_base + d] += input[nid*dim + d];
                }
            }

            // output the result to global memory from the shared memory
            #pragma unroll
            for (int d = laneid; d < dim; d += dimWorker){
                atomicAdd_F((float*)&output[(srcId % num_nodes)*dim + d], partial_results[presult_base + d]);
            }
      }
    }

    __syncwarp();

    
    /*
    // ---------------------
    // process REMOTE parts.
    // ---------------------
    if (warpId*interleaved_dist < remote_num_parts){

        p_start = warpId*interleaved_dist;
        p_end =  min(p_start + interleaved_dist, remote_num_parts);

        for (int p_cursor = p_start; p_cursor < p_end; p_cursor++)
        {
            int srcId = remote_part2Node[p_cursor];              // remote: aggregated source node.
            int partBeg = remote_part_pointers[p_cursor];        // remote: partitioning pointer start.
            int partEnd = remote_part_pointers[p_cursor + 1];    // remote: part pointer end.

            // Cache the part neighbors.
            const int pindex_base = block_warpId * partSize;
            // #pragma unroll
            for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
                partial_ids[pindex_base + nidx - partBeg] = remote_column_index[nidx];
            }

            __syncwarp();

            // Neighbor aggregation within each part
            const int presult_base = block_warpId * dim;
            for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
            {
                int nid = partial_ids[pindex_base + nIdx] % num_nodes;
                int remote_pe = partial_ids[pindex_base + nIdx] / num_nodes;

                // Initialize shared memory for partial results
                if (nIdx == 0)
                    #pragma unroll
                    for (int d = laneid; d < dim; d += dimWorker){
                        partial_results[presult_base + d] = 0.0f;
                    }
            
                // if (remote_pe > 1) printf("remote_pe: %d\n", remote_pe);
                // nvshmemx_float_get_warp(&tmp_local[presult_base], &input[nid*dim], dim, remote_pe);
                // nvshmemx_getmem_nbi_warp(&tmp_local[presult_base], &input[nid*dim], dim*sizeof(float), remote_pe);
                nvshmemx_float_get_block(&tmp_local[presult_base], &input[nid*dim], dim, remote_pe);
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    partial_results[presult_base + d] += tmp_local[presult_base+d];
                }

                // for (int dIdx = laneid; dIdx < dim; dIdx += dimWorker){
                //     nvshmem_float_get(&tmp_local[presult_base + dIdx], &input[nid*dim + dIdx], 1, remote_pe);
                //     partial_results[presult_base + dIdx] += tmp_local[presult_base+dIdx];
                // }

                // for (int dIdx = laneid*WARP_SIZE; dIdx < min(dim, (laneid+1)*WARP_SIZE); dIdx++){
                //     nvshmem_float_get(&tmp_local[presult_base + dIdx], &input[nid*dim + dIdx], 1, remote_pe);
                //     partial_results[presult_base + dIdx] += tmp_local[presult_base+dIdx];
                // }
            }

            // output the result to global memory from the shared memory
            #pragma unroll
            for (int d = laneid; d < dim; d += dimWorker){
                atomicAdd_F((float*)&output[(srcId%num_nodes)*dim + d], partial_results[presult_base + d]);
            }
        }
    }

    */
}


template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_fused_interleaved_wo_shared(
    dataType* output,
    const dataType* input,
    // local access
    const IDType* local_row_pointers,
    const IDType* local_column_index,
    const IDType* local_part_pointers,
    const IDType* local_part2Node,
    const IDType  local_num_parts,
    // remote access.
    const IDType* remote_row_pointers,
    const IDType* remote_column_index,
    const IDType* remote_part_pointers,
    const IDType* remote_part2Node,
    const IDType  remote_num_parts,
    // other param.
    const IDType num_nodes,
    const IDType lowbound,
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock,
    const paraType interleaved_dist
) 
{
    int tid =  blockIdx.x * blockDim.x + threadIdx.x;         // global thread-id
    int warpId = tid / WARP_SIZE;                             // global warp-id
    int block_warpId = threadIdx.x / WARP_SIZE;               // block warp-id
    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid

    extern __shared__ int part_meta[];                                      // part information.
    int *partial_ids = part_meta;                                           // caching ids
    float *partial_results = (float*)&part_meta[partSize*warpPerBlock];     // caching partial results.
    float *tmp_local = (float*)&partial_results[warpPerBlock*dim];     // caching partial results.

    int p_start, p_end;
    // ---------------------
    // process LOCAL parts.
    // ---------------------
    if (warpId*interleaved_dist < local_num_parts){
        
        p_start = warpId*interleaved_dist;
        p_end =  min(p_start + interleaved_dist, local_num_parts);

        for (int p_cursor = p_start; p_cursor < p_end; p_cursor++)
        {
            int srcId = local_part2Node[p_cursor];              // local: aggregated source node.
            int partBeg = local_part_pointers[p_cursor];        // local: partitioning pointer start.
            int partEnd = local_part_pointers[p_cursor + 1];    // local: part pointer end.

            // Cache the part neighbors.
            const int pindex_base = block_warpId * partSize;
            // #pragma unroll
            for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
                // printf("1--pindex_base: %d, laneid: %d\n", pindex_base, laneid);
                partial_ids[pindex_base + nidx - partBeg] = local_column_index[nidx];
                // if(partial_ids[pindex_base + laneid]  >= num_nodes || partial_ids[pindex_base + laneid]  < 0) printf("---- partial_ids: %d\n", partial_ids[pindex_base + laneid] );
            }

            __syncwarp();

            // Neighbor aggregation within each part
            const int presult_base = block_warpId * dim;
            for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
            {
                // if (laneid == 0) printf("2--pindex_base: %d, nIdx: %d\n", pindex_base, nIdx);
                int nid = partial_ids[pindex_base + nIdx] % num_nodes;

                // Initialize shared memory for partial results
                if (nIdx == 0)
                    if (laneid < dimWorker)
                    #pragma unroll
                    for (int d = laneid; d < dim; d += dimWorker){
                        partial_results[presult_base + d] = 0.0f;
                    }
                
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    atomicAdd_F((float*)&output[(srcId % num_nodes)*dim + d], input[nid*dim + d]);

                }
            }
      }
    }

    __syncwarp();

    // ---------------------
    // process REMOTE parts.
    // ---------------------
    if (warpId*interleaved_dist < remote_num_parts){

        p_start = warpId*interleaved_dist;
        p_end =  min(p_start + interleaved_dist, remote_num_parts);

        for (int p_cursor = p_start; p_cursor < p_end; p_cursor++)
        {
            int srcId = remote_part2Node[p_cursor];              // remote: aggregated source node.
            int partBeg = remote_part_pointers[p_cursor];        // remote: partitioning pointer start.
            int partEnd = remote_part_pointers[p_cursor + 1];    // remote: part pointer end.

            // Cache the part neighbors.
            const int pindex_base = block_warpId * partSize;
            // #pragma unroll
            for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
                partial_ids[pindex_base + nidx - partBeg] = remote_column_index[nidx];
            }

            __syncwarp();

            // Neighbor aggregation within each part
            const int presult_base = block_warpId * dim;
            for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
            {
                int nid = partial_ids[pindex_base + nIdx] % num_nodes;
                int remote_pe = partial_ids[pindex_base + nIdx] / num_nodes;

                // Initialize shared memory for partial results
                if (nIdx == 0)
                    #pragma unroll
                    for (int d = laneid; d < dim; d += dimWorker){
                        partial_results[presult_base + d] = 0.0f;
                    }
            
                // if (remote_pe > 1) printf("remote_pe: %d\n", remote_pe);
                nvshmemx_float_get_warp(&tmp_local[presult_base], &input[nid*dim], dim, remote_pe);
                // nvshmemx_getmem_nbi_warp(&tmp_local[presult_base], &input[nid*dim], dim*sizeof(float), remote_pe);

                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    atomicAdd_F((float*)&output[(srcId%num_nodes)*dim + d], tmp_local[presult_base+d]);

                }
            }
        }
    }
}

template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_range_only(
          dataType* output,
    const dataType* input,
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType  num_parts,
    const IDType lb,          // lower bound neighbor ID.
    const IDType ub,          // upper bound neighbor ID (exclusive)
    const IDType edge_lb,     // lower bound lower ID
    const IDType num_nodes,   // number of nodes assigned to current GPU.
    // other param.
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
) 
{
    int tid =  blockIdx.x * blockDim.x + threadIdx.x;         // global thread-id
    int warpId = tid / WARP_SIZE;                             // global warp-id
    int block_warpId = threadIdx.x / WARP_SIZE;               // block warp-id
    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid

    extern __shared__ int part_meta[];                                      // part information.
    int *partial_ids = part_meta;                                           // caching ids
    float *partial_results = (float*)&part_meta[partSize*warpPerBlock];     // caching partial results.

    // ---------------------
    // Process LOCAL parts.
    // num_parts for each GPU.
    // ---------------------
    if (warpId < num_parts){

        const int part_index = warpId;                          // part index.
        const int srcId = part2Node[part_index];                // aggregated source node.
        const int partBeg = part_pointers[part_index];          // partitioning pointer start.
        const int partEnd = part_pointers[part_index + 1];      // part pointer end.

        // Cache the part neighbors.
        const int pindex_base = block_warpId * partSize;
        // #pragma unroll
        for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
            // printf("1--pindex_base: %d, laneid: %d\n", pindex_base, laneid);
            // partial_ids[pindex_base + nidx - partBeg] = column_index[nidx];
            partial_ids[pindex_base + nidx - partBeg] = column_index[nidx - edge_lb];

            // if(partial_ids[pindex_base + laneid]  >= num_nodes || partial_ids[pindex_base + laneid]  < 0) printf("---- partial_ids: %d\n", partial_ids[pindex_base + laneid] );
        }

         __syncwarp();

        // Neighbor aggregation within each part
        const int presult_base = block_warpId * dim;
        for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
        {
            // if (laneid == 0) printf("2--pindex_base: %d, nIdx: %d\n", pindex_base, nIdx);
            // int nid = partial_ids[pindex_base + nIdx] - lowbound;
            int nid = partial_ids[pindex_base + nIdx];

            if (nIdx == 0)
                // if (laneid < dimWorker)
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    partial_results[presult_base + d] = 0.0f;
                }

            // only the interested region will be aggregated.
            if (lb <= nid && nid < ub)
            {
                const int local_idx = nid - lb;
                // if(nid >= num_nodes || nid < 0) printf("Error nid: %d\n", nid);
                // Initialize shared memory for partial results
                // if (laneid < dimWorker)
                #pragma unroll
                for (int d = laneid; d < dim; d += dimWorker){
                    partial_results[presult_base + d] += input[local_idx*dim + d];
                }
            }
        }

        // output the result to global memory from the shared memory
        // if (laneid < dimWorker)
        #pragma unroll
        for (int d = laneid; d < dim; d += dimWorker){
            atomicAdd_F((float*)&output[(srcId % num_nodes)*dim + d], partial_results[presult_base + d]);
        }
    }
}



template <typename IDType, typename dataType, typename paraType>
__global__ 
void SAG_cuda_kernel_host_unified(
          dataType* output,
    const dataType* input,
    const IDType* column_index,
    const IDType* part_pointers,
    const IDType* part2Node,
    const IDType  edge_lb,
    const IDType  num_parts,
    const IDType  num_nodes,   // number of nodes assigned to current GPU.
    // other param.
    const paraType partSize,
    const paraType dim,
    const paraType dimWorker, 
    const paraType warpPerBlock
) 
{
    int tid =  blockIdx.x * blockDim.x + threadIdx.x;         // global thread-id
    int warpId = tid / WARP_SIZE;                             // global warp-id
    int block_warpId = threadIdx.x / WARP_SIZE;               // block warp-id
    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid

    extern __shared__ int part_meta[];                                      // part information.
    int *partial_ids = part_meta;                                           // caching ids
    float *partial_results = (float*)&part_meta[partSize*warpPerBlock];     // caching partial results.

    // ---------------------
    // Process LOCAL parts.
    // num_parts for each GPU.
    // ---------------------
    if (warpId < num_parts){

        const int part_index = warpId;                          // warp --> part index.
        const int srcId = part2Node[part_index];                // aggregated source node.
        const int partBeg = part_pointers[part_index];          // partitioning pointer start.
        const int partEnd = part_pointers[part_index + 1];      // part pointer end.

        // Cache the part neighbors.
        const int pindex_base = block_warpId * partSize;
        // #pragma unroll
        for (int nidx = partBeg + laneid; nidx < partEnd; nidx += dimWorker){
            // printf("1--pindex_base: %d, laneid: %d\n", pindex_base, laneid);
            partial_ids[pindex_base + nidx - partBeg] = column_index[nidx - edge_lb];
            // if(partial_ids[pindex_base + laneid]  >= num_nodes || partial_ids[pindex_base + laneid]  < 0) printf("---- partial_ids: %d\n", partial_ids[pindex_base + laneid] );
        }

         __syncwarp();

        // Neighbor aggregation within each part
        const int presult_base = block_warpId * dim;
        for (int nIdx = 0; nIdx < partEnd - partBeg; nIdx++)
        {
            // if (laneid == 0) printf("2--pindex_base: %d, nIdx: %d\n", pindex_base, nIdx);
            // int nid = partial_ids[pindex_base + nIdx] - lowbound;
            int nid = partial_ids[pindex_base + nIdx];

            if (nIdx == 0)
            if (laneid < dimWorker)
            #pragma unroll
            for (int d = laneid; d < dim; d += dimWorker){
                partial_results[presult_base + d] = 0.0f;
            }

            // if(nid >= num_nodes || nid < 0) printf("Error nid: %d\n", nid);
            // Initialize shared memory for partial results
            if (laneid < dimWorker)
            #pragma unroll
            for (int d = laneid; d < dim; d += dimWorker){
                partial_results[presult_base + d] += input[nid*dim + d];
            }
        }

        // output the result to global memory from the shared memory
        if (laneid < dimWorker)
        #pragma unroll
        for (int d = laneid; d < dim; d += dimWorker){
            atomicAdd_F((float*)&output[(srcId % num_nodes)*dim + d], partial_results[presult_base + d]);
        }
    }
}


__global__
void uvm_profile(float* d_output, 
                 const float* d_input, 
                 const int* d_row_ptr, 
                 const int* d_col_ind, 
                 const int e_lb,
                 const int e_ub,
                 const int ebdDim
                ){

    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid
    
    // const int lb_src = d_row_ptr[nodeOfInterest]; 
    // const int ub_src = d_row_ptr[nodeOfInterest + 1]; 

    #pragma unroll
    for (int idx = e_lb; idx < e_ub; idx++){
        int nid = d_col_ind[idx];
        for (int dIdx = laneid; dIdx < ebdDim; dIdx += WARP_SIZE){
            d_output[dIdx] +=  d_input[nid*ebdDim + dIdx];
        }
    }
}


__global__
void mgg_profile(float* d_output, 
                 const float* d_input, 
                 const int* d_row_ptr, 
                 const int* d_col_ind, 
                 const int e_lb,
                 const int e_ub,
                 const int ebdDim,
                 const int nodesPerPE
                ){
    int laneid = threadIdx.x % WARP_SIZE;                     // warp thread-id -- laneid
    
    __shared__ float local_tmp[1024];
    
    #pragma unroll
    for (int idx = e_lb; idx < e_ub; idx++){

        int nid = d_col_ind[idx];
        int peid = nid / nodesPerPE;
        int nid_loc = nid % nodesPerPE;

        if (peid != 0){
            // printf("remote-id: %d\n", peid);

            // nvshmemx_float_get_warp(local_tmp, &d_input[nid_loc*ebdDim], ebdDim, peid);
            // nvshmemx_float_get_block(local_tmp, &d_input[nid_loc*ebdDim], ebdDim, peid);
            // for (int dIdx = laneid; dIdx < ebdDim; dIdx += WARP_SIZE){
            //     d_output[dIdx] +=  local_tmp[dIdx];
            // }

            // for (int dIdx = laneid; dIdx < ebdDim; dIdx += WARP_SIZE){
            //     nvshmem_float_get(local_tmp + dIdx, &d_input[nid_loc*ebdDim] + dIdx, 1, peid);
            //     d_output[dIdx] += local_tmp[dIdx];
            // }

            for (int dIdx = laneid*WARP_SIZE; dIdx < min(ebdDim, (laneid+1)*WARP_SIZE); dIdx++){
                nvshmem_float_get(local_tmp + dIdx, &d_input[nid_loc*ebdDim] + dIdx, 1, peid);
                d_output[dIdx] +=  local_tmp[dIdx];
            }
        } 
        else{
            // printf("local-id: %d\n", peid);
            for (int dIdx = laneid; dIdx < ebdDim; dIdx += WARP_SIZE){
                d_output[dIdx] +=  d_input[nid_loc*ebdDim + dIdx];
            }
        }

    }
}



__global__ 
void SAG_cuda_kernel_ref(float* d_output, const float* d_input, const int* d_row_ptr, 
                        const int* d_col_ind, const int lb_src, const int pe_num_nodes, const int dim)
{
    const int tid =  blockIdx.x * blockDim.x + threadIdx.x;
    const int wid = tid/32;
    const int lanid = tid%32;
    
    if (wid < pe_num_nodes){
        const int src_nid = wid + lb_src;
        const int eidx_s =  d_row_ptr[src_nid];
        const int eidx_e = d_row_ptr[src_nid + 1];
        for (int eidx = eidx_s; eidx < eidx_e; eidx++){
            int nid = d_col_ind[eidx]; 
            for (int d = lanid; d < dim; d += WARP_SIZE)
                d_output[src_nid * dim + d] += d_input[nid * dim + d];
        }
    }
}


__global__ 
void SAG_cuda_kernel_single_ref(float* d_output, const float* d_input, const int* d_row_ptr, const int* d_col_ind, const int num_nodes, const int dim){
    const int tid = blockIdx.x * blockDim.x + threadIdx.x;
    const int wid = tid/32;
    const int lanid = tid%32;

    if (wid < num_nodes){
        const int src_nid = wid;
        const int eidx_s =  d_row_ptr[src_nid];
        const int eidx_e = d_row_ptr[src_nid + 1];
        for (int eidx = eidx_s; eidx < eidx_e; eidx++){
            int nid = d_col_ind[eidx]; 
            for (int d = lanid; d < dim; d += WARP_SIZE)
                d_output[src_nid * dim + d] += d_input[nid * dim + d];
        }
    }
}

#endif