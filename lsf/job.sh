#!/bin/bash
#BSUB -J test_job                     # Job name
#BSUB -o logs/test_job_%J.out         # Output file, logs must exist
#BSUB -e logs/test_job_%J.err         # Error file
#BSUB -m compute1

# Your job commands go here
# For example, you could have:
echo "Starting job"
sleep 60
echo "Job completed"

