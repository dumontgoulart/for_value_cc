#!/bin/bash -l
#SBATCH -D /home/hgoulart/code
#SBATCH -o /home/hgoulart/code/job.%j.%N.out
#SBATCH -e /home/hgoulart/code/job.%j.%N.err
#SBATCH -n 96            # Total number of processors to request (32 cores per node)
#SBATCH -p high           # Queue name hi/med/lo
#SBATCH -t 150:00:00        # Run time (hh:mm:ss) - 24 hours
#SBATCH --mail-user=hdgoulart@ucdavis.edu   # address for email notification
#SBATCH --mail-type=ALL  # send email when job starts/stops

export PATH=/group/hermangrp/miniconda3/bin:$PATH
mpirun -n 96 python main-parallel.py

# programs won't automatically take advantage of multiple processors
# unless they are written to use MPI or OpenMP libraries

	