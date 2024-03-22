#!/bin/bash

# Check if exactly two arguments are given (directory and file extension)
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory_path> <file_extension>"
    exit 1
fi

DIRECTORY_PATH=$1
FILE_EXTENSION=$2

# Count the number of files with the specified extension in the directory
NUM_FILES=$(find "$DIRECTORY_PATH" -type f -name "*.$FILE_EXTENSION" | wc -l)

echo "Number of files with extension .$FILE_EXTENSION in " \
       "$DIRECTORY_PATH: $NUM_FILES"

