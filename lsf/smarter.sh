#!/bin/bash

# Number of jobs
N=10000

# LSF submission parameters
MACHINES="compute1 compute2"
QUEUE="normal"
COMMAND="sleep 30; echo done"
SUBDIR="logs"
MSTR="master"
MSTRLOG="$MSTR/jobs_N$N.log"
PREFIX="jn"

# Maximum allowed pending jobs
MAX_PENDING=95

# Interval to check pending jobs (seconds)
CHECK_INTERVAL=5

# Create directories for logs if they don't exist
mkdir -p "$SUBDIR"
mkdir -p "$MSTR"

# Clear previous logs
rm -f $SUBDIR/*
rm -f $MSTR/*

# Function to get the current number of pending jobs
get_pending_jobs() {
    bjobs -u all -q $QUEUE -p | wc -l
}

# Submit jobs
for i in $(seq 1 $N); do
    CURRENT_PENDING=$(get_pending_jobs)
    
    # Wait if pending jobs exceed MAX_PENDING
    while [ "$CURRENT_PENDING" -ge "$MAX_PENDING" ]; do
        echo "Maximum pending jobs reached ($MAX_PENDING). Waiting..."
        sleep $CHECK_INTERVAL
        CURRENT_PENDING=$(get_pending_jobs)
    done

    JOB_NAME="${PREFIX}tst$i"
    OUTPUT="$SUBDIR/${JOB_NAME}_%J.out"
    ERROR="$SUBDIR/${JOB_NAME}_%J.err"
    DONE_FILE="$SUBDIR/${JOB_NAME}.done"
    CMD="bash -c '$COMMAND > $DONE_FILE'"

    bsub -J "${JOB_NAME}" \
         -o "${OUTPUT}" \
         -e "${ERROR}" \
         -q "${QUEUE}" \
         -m "${MACHINES}" "${CMD}" \
         -W 5:0 \
         >> "${MSTRLOG}" 2>&1 &
done

