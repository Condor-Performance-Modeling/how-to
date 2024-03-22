#!/bin/bash
#BSUB -J JOB_1
#BSUB -o %J.out
#BSUB -e %J.err
#BSUB -n 4
#BSUB -R "span[hosts=1]"
#BSUB -W 00:30
#BSUB -q normal
#BSUB -m "compute1"

# Your job commands start here
echo "Starting job at `date`"
echo "Running on host `hostname`"

# Example command: Run a parallel job
mpirun -np 32 mpi_hello_world

echo "Job finished at `date`"

