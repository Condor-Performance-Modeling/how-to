#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -q QUEUE_NAME  Specify the queue name."
    echo "  -s STATE       Specify the job state (e.g., -p for pending, -r for running)."
    echo "  -u USER        Specify the user whose jobs to target (use 'all' for every user)."
    echo "  -h             Display this help and exit."
}

# Ensure the script is run by 'lsfadmin'
if [ "$USER" != "lsfadmin" ]; then
    echo "This script must be run by 'lsfadmin'. Exiting."
    exit 1
fi

# Default values
QUEUE_NAME=""
STATE="-p" # Default to pending jobs
TARGET_USER="all"

# Parse command line options
while getopts ":q:s:u:h" opt; do
    case ${opt} in
        q )
            QUEUE_NAME=$OPTARG
            ;;
        s )
            STATE=$OPTARG
            ;;
        u )
            TARGET_USER=$OPTARG
            ;;
        h )
            show_help
            exit 0
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            show_help
            exit 1
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            show_help
            exit 1
            ;;
    esac
done

# Check if QUEUE_NAME is provided
if [ -z "$QUEUE_NAME" ]; then
    echo "Queue name (-q) is required. Use -h for help."
    show_help
    exit 1
fi

# Get job IDs
JOB_IDS=$(bjobs -q $QUEUE_NAME -u $TARGET_USER $STATE | awk 'NR > 1 {print $1}' | grep -E '^[0-9]+$')

# Count the jobs
NUM_JOBS=$(echo "$JOB_IDS" | grep -c '[^[:space:]]')

if [ "$NUM_JOBS" -eq 0 ]; then
    echo "No valid jobs found with the specified criteria. Please check the queue name, job state, and user."
    exit 0
fi

#echo "The following jobs will be affected by the operation:"
#echo "$JOB_IDS"
echo "Total number of jobs to be processed: $NUM_JOBS"

# Ask for confirmation
read -p "Do you want to proceed with killing these jobs? Y/n? " answer
case "$answer" in
    [Yy]* ) ;;
    * ) echo "Operation aborted by the user."; exit;;
esac

# Kill the jobs if confirmed
echo "$JOB_IDS" | xargs -r bkill

echo "Requested jobs in the queue $QUEUE_NAME with state $STATE for user $TARGET_USER have been processed for termination. Please verify the termination status."

