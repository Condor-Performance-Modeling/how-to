#!/bin/bash

if [[ -z "$TOP" ]]; then
    echo "Error: The required environment variable TOP is not set."
    echo "To set it, cd into your work area and run: source how-to/env/setuprc.sh"
    exit 1
fi

if ! cd "$TOP"; then
    echo "Error: Unable to navigate to directory $TOP. Please check if it exists."
    exit 1
fi

if [[ -z "$RISCV" || ! -d "$RISCV" ]]; then
    echo "Error: The required directory RISCV ($RISCV) is missing. Please ensure it exists before continuing."
    exit 1
fi

if [[ -z "$RISCV_LINUX" || ! -d "$RISCV_LINUX" ]]; then
    echo "Error: The required directory RISCV_LINUX ($RISCV_LINUX) is missing. Please ensure it exists before continuing."
    exit 1
fi

rm -f "$TOP/riscv64-unknown-elf" "$TOP/riscv64-unknown-linux-gnu"
ln -fs "$RISCV" "$TOP/riscv64-unknown-elf"
ln -fs "$RISCV_LINUX" "$TOP/riscv64-unknown-linux-gnu"

echo "Updated cross-compiler links in $TOP:"
echo " - Linked $TOP/riscv64-unknown-elf to $RISCV"
echo " - Linked $TOP/riscv64-unknown-linux-gnu to $RISCV_LINUX"
