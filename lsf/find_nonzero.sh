#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <file_extension>"
    exit 1
fi

# Search for files with the given extension and size greater than 0 bytes
find $1 -type f -name "*.$2" -size +0c
