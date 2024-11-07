#!/bin/bash

if [[ -z "$TOP" ]]; then
    echo "The required environment variable TOP is not set."
    echo "To set the required environment variable, cd into your work area and run: source how-to/env/setuprc.sh"
    exit 1
fi

cd "$TOP" || exit

if [ ! -d "$RISCV" ]; then
    echo "The required directory $RISCV is missing. Please ensure it exists before continuing."
    exit 1
fi

if [ ! -d "$RISCV_LINUX" ]; then
    echo "The required directory $RISCV_LINUX is missing. Please ensure it exists before continuing."
    exit 1
fi

rm -f "$TOP/riscv64-unknown-elf" "$TOP/riscv64-unknown-linux-gnu"
ln -fs "$RISCV" "$TOP/riscv64-unknown-elf"
ln -fs "$RISCV_LINUX" "$TOP/riscv64-unknown-linux-gnu"

export PATH="$RV_LINUX_TOOLS/bin:$PATH"
if [ $? -ne 0 ]; then
    echo "Failed to update PATH with $RV_LINUX_TOOLS"
    exit 1
fi

export CROSS_COMPILE=riscv64-unknown-linux-gnu-

echo "Updated $TOP cross compiler links:"
echo "Linked $TOP/riscv64-unknown-elf to $RISCV"
echo "Linked $TOP/riscv64-unknown-linux-gnu to $RISCV_LINUX"

