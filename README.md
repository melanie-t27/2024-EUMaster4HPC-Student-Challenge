# A Parallel Implementation of the Conjugate Gradient Solver for Dense Linear Systems on the Meluxina Supercomputer
The goal of this project is to parallelize the Conjugate Gradient method for solving dense linear systems, specifically designed to run on the Meluxina supercomputer. The Conjugate Gradient method is an iterative method for solving systems of linear equations, and it is particularly well-suited for large, sparse, symmetric, and positive-definite matrices. The method is widely used in scientific computing, and it is a key component in many scientific and engineering applications. 

The project is implemented in C++ and it leverages the **MPI** and **OMP** libraries for parallelization as well as the **CUDA** and **NCCL** libraries for GPU acceleration. The code is designed to run on both CPU and GPU nodes, and it is optimized to take advantage of the NUMA topology of the Meluxina supercomputer. The code is also designed to be extensible, allowing for easy addition of different implementations and optimizations.


## Compile the code
To compile the code on Meluxina you need to load the following modules:

```bash
module load CMake
module load CUDA NCCL
module load OpenMPI UCX
```

Then, you can compile the code using the following commands:

```bash
cd challenge/main
mkdir build
cd build
cmake ..
make
```

To compile just one of the tests, you can replace the `make` command with the name of the test you want to compile. For example, to compile the `test_CG_CPU_MPI_OMP` test, you can use the following command:

```bash
make test_CG_CPU_MPI_OMP.out
```

At the momemnt the following tests are available:
- **test_CPU_OMP.out**: This test runs the Conjugate Gradient method on a single **CPU node** using **OMP** for parallelization.
- **test_CPU_MPI_OMP.out**: This test runs the Conjugate Gradient method on multiple **CPU nodes** using **MPI** and **OMP** for parallelization.
- **test_CG_single_GPU.out**: This test runs the Conjugate Gradient method on a single **GPU node** using just one device.
- **test_CG_MultiGPUS_CUDA.out**: This test runs the Conjugate Gradient method on a single **GPU node**  using multiple devices.
- **test_CG_MultiGPUS_CUDA_MPI.out**: This test runs the Conjugate Gradient method on multiple **GPU nodes** using **MPI** for parallelization.
- **test_CG_MultiGPUS_CUDA_NCCL.out**: This test runs the Conjugate Gradient method on multiple **GPU nodes** using **NCCL** for parallelization.

## Run the code

The input to the solver can be a matrix loaded from a file or can be generated by the program. The file mode is useful for testing the solver with a specific matrix and right-hand side, and it is also useful for comparing the performance of the solver with different parallelization strategies. The generated mode is useful for testing the solver with different matrix sizes and for benchmarking the performance of the solver and it tries to simulate the behavior of the solver when solving a real problem.

The input matrix is expected to be a symmetric positive-definite matrix written in binary format as the right-hand side and the solution. The input matrix file and the rhs file should start with the rows and columns of the matrix/rhs, followed by the elements of the matrix in row-major order.

### CPU Tests

The test_CG_CPU_MPI_OMP.out and test_CG_CPU_OMP.out tests can be run in two different modes: **File mode** and **Generate mode**.

1. **File Mode**: In this mode, you need to specify the input matrix file, the input right-hand side file, the output solution file, the maximum iterations, and the relative error.

Here is an example of how to execute the program in this mode:

```bash
srun -n NUMBER_OF_MPI_PROC -c NUMBER_OF_THREADS ./test_CG_CPU_MPI_OMP_file.out -A <matrix_file> -b <rhs_file> -o <output_file> -i <max_iterations> -e <relative_error> -v
```

If any of the parameters are not provided, the program will use the following default values:
- **-A matrix_file**: The input matrix file. The default value is **"io/matrix.bin"**.
- **-b rhs_file**: The input right-hand side file. The default value is **"io/rhs.bin"**.
- **-o output_file**: The output solution file. The default value is **"io/sol.bin"**.
- **-i max_iterations**: The maximum number of iterations. The default value is **1000**.
- **-e relative_error**: The relative error. The default value is **1e-9**.
- **-v verbose mode**


2. **Generate Mode**:  In this mode, you only need to provide the size of the matrix. The program will **generate** a matrix and a right-hand side of the specified size, solve the system, and write the solution to a file.

Here is an example of how to execute the program in this mode:

```bash
srun -n NUMBER_OF_MPI_PROC -c NUMBER_OF_THREADS ./test_CG_CPU_MPI_OMP_gen.out -s <matrix_size> -o <output_file> -i <max_iterations> -e <relative_error> -v
```

### GPU Tests

The GPUs tests test_CG_MultiGPUS_CUDA_MPI.out and test_CG_MultiGPUS_CUDA_NCCL.out can be run in a similar way to the CPU tests. The only difference is that test_CG_MultiGPUS_CUDA_MPI.out associate one MPI process to each GPU and test_CG_MultiGPUS_CUDA_NCCL.out associate all the MPI processes to all the GPUs on a single node (4 on Meluxina).

For example, to run the test_CG_MultiGPUS_CUDA_MPI.out test in **File mode** you can use the following command:

```bash
srun -n NUMBER_OF_DEVICES ./test_CG_MultiGPUS_CUDA_MPI.out -A <matrix_file> -b <rhs_file> -o <output_file> -i <max_iterations> -e <relative_error> -v
```

or in **Generate mode**:

```bash
srun -n NUMBER_OF_DEVICES ./test_CG_MultiGPUS_CUDA_MPI.out -s <matrix_size> -o <output_file> -i <max_iterations> -e <relative_error> -v
```

On the other hand, the test_CG_single_GPU.out and test_CG_MultiGPUS_CUDA.out tests can be run only in **File mode**: In this mode, you need to specify the input matrix file, the input right-hand side file, the output solution file, the maximum iterations, and the relative error.


## Performance Analysis
You can use the non-verbose mode to measure the performance of the solver (not working for test_CG_single_GPU.out and test_CG_MultiGPUS_CUDA.out). The program will print:
- The size of the matrix (number of rows)
- The number of MPI processes
- The number of threads per MPI process
- The time to read the matrix from the file or to generate in seconds
- The time to initialize NCCL in seconds (only for test_CG_MultiGPUS_CUDA_NCCL.out) 
- the average time to compute the matrix-vector product in seconds
- The average time to compute one CG iteration in seconds
- The number of iterations performed
- The relative error
- The total time to solve the system in seconds

In the TESTS directory, you can find a large number of tests executed on Meluxina.
Each implementation was tested with different matrix sizes and different numbers of MPI processes and threads. The results of each test are stored under the **TESTS/results** directory, in a file with the following format : **MERGE_CPU_STRATEGY_NAME.txt** and **MERGE_GPU_STRATEGY_NAME.txt**. The **MERGE_CPU_STRATEGY_NAME.txt** file contains the results of the CPU tests, and the **MERGE_GPU_STRATEGY_NAME.txt** file contains the results of the GPU tests. 
In the **TESTS/BEST_RESULTS** file, you can find the best results for each implementation.
