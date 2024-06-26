#ifndef CONJUGATEGRADIENT_MULTIGPUS_CUDA_NCCL_CUH
#define CONJUGATEGRADIENT_MULTIGPUS_CUDA_NCCL_CUH

#include <memory>
#include <cstdio>
#include <cmath>
#include <iostream>
#include <mpi.h>
#include <nccl.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <omp.h>
#include <chrono>
#include <unistd.h>
#include "../../ConjugateGradient.hpp"
#define PRINT_RANK0(...) if(rank==0) printf(__VA_ARGS__)
#define PRINT_ERR_RANK0(...) if(rank==0) fprintf(stderr, __VA_ARGS__)


namespace LAM
{

    template<typename FloatingType>
    class ConjugateGradient_MultiGPUS_CUDA_NCCL:
    public ConjugateGradient<FloatingType>
    {
        public:
            using ConjugateGradient<FloatingType>::ConjugateGradient;

            bool virtual solve(int max_iters, FloatingType rel_error);
            
            bool virtual load_matrix_from_file(const char* filename);
            bool virtual load_rhs_from_file(const char* filename);
            bool virtual save_result_to_file(const char * filename) const;

            bool virtual generate_matrix(size_t num_rows, size_t num_cols);
            bool virtual generate_rhs();
            
            size_t get_num_rows() const { return _num_local_rows; }
            size_t get_num_cols() const { return _num_cols; }
            
            //destroy the streams
            ~ConjugateGradient_MultiGPUS_CUDA_NCCL()
            {   
                if(_x != nullptr)
                    cudaFreeHost(_x);
                if(_rhs != nullptr)
                    cudaFreeHost(_rhs);

                cudaStreamDestroy(stream);
                
                if(_A_dev != nullptr)
                    cudaFree(_A_dev);
            }

        private:
            FloatingType* _A_dev;
            FloatingType * _x;
            FloatingType * _rhs;

            // total number of columns of the matrix
            size_t _num_cols;
            // total number of rows of the local matrix of the rank
            size_t _num_local_rows;

            int _device_id;
            
            //cudaStream_t *streams;
            cudaStream_t stream;
            //cublasHandle_t *cublas_handler;

            // MPI communication variables
            int* _sendcounts;
            int* _displs;

            //size_t size;
            //int _numDevices;

            static MPI_Datatype get_mpi_datatype() {
                if (std::is_same<FloatingType, double>::value) {
                    return MPI_DOUBLE;
                } else {
                    return MPI_FLOAT;
                }
            }

            static constexpr ncclDataType_t nccl_datatype = std::is_same<FloatingType, double>::value ? ncclDouble : ncclFloat;

    };
    
}
#endif //CONJUGATEGRADIENT_MULTIGPUS_CUDA_NCCL_CUH