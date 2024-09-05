#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 -s source_dir -b build_dir -f fusion_definitions"
    exit 1
fi

# Parse arguments
while getopts "s:b:f:" opt; do
  case $opt in
    s) source_dir="$OPTARG"
    ;;
    b) build_dir="$OPTARG"
    ;;
    f) fusion_definitions="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

# Check if the provided source directory exists and contains the required files
if [ ! -d "$source_dir" ] || 
   [ ! -f "$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.td" ] || 
   [ ! -f "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td" ]; then
    echo "Source directory $source_dir is invalid."
    exit 1
fi

# Check if the provided build directory exists and contains the Makefile
if [ ! -d "$build_dir" ] || 
   [ ! -f "$build_dir/Makefile" ]; then
    echo "Build directory $build_dir is invalid."
    exit 1
fi

# Check if the fusion definitions file exists
if [ ! -f "$fusion_definitions" ]; then
    echo "Fusion definitions file $fusion_definitions does not exist."
    exit 1
fi

install_dir=$(grep -m 1 "^CMAKE_INSTALL_PREFIX" "$build_dir/CMakeCache.txt" | cut -d '=' -f 2)

# If CMAKE_INSTALL_PREFIX is not available, fallback to the Makefile
if [ -z "$install_dir" ]; then
    install_dir=$(grep -m 1 "^prefix" "$build_dir/Makefile" | cut -d '=' -f 2)
fi

# Print the install directory
echo "LLVM was installed to: $install_dir"

exit 1;

# Paths for backup files
macro_fusion_backup="$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.bak"
processors_backup="$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.bak"

# 0. Check if backups exist and reset files if necessary
reset_files_if_needed() {
    local original_file="$1"
    local backup_file="$2"
    
    if [ -f "$backup_file" ] && grep -q "//MACRO_FUSION_AUTOMATIC_UPDATE" "$original_file"; then
        echo "Resetting $original_file using $backup_file"
        cp "$backup_file" "$original_file"
    fi
}

reset_files_if_needed "$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.td" "$macro_fusion_backup"
reset_files_if_needed "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td" "$processors_backup"

# 1. Create backups of the .td files if they do not already exist
create_backup_if_needed() {
    local original_file="$1"
    local backup_file="$2"
    
    if [ ! -f "$backup_file" ]; then
        echo "Creating backup of $original_file"
        cp "$original_file" "$backup_file"
    fi
}

create_backup_if_needed "$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.td" "$macro_fusion_backup"
create_backup_if_needed "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td" "$processors_backup"

# 2. Extract fusion names from the fusion definitions file
fusion_names=$(grep -oP '^def \K\w+' "$fusion_definitions")

# 3. Append fusion definitions to RISCVMacroFusion.td
echo "" >> "$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.td"
echo "//MACRO_FUSION_AUTOMATIC_UPDATE" >> "$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.td"
cat "$fusion_definitions" >> "$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.td"

# 4. Append the processor model and fusion names to RISCVProcessors.td
echo "" >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
echo "//MACRO_FUSION_AUTOMATIC_UPDATE" >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
cat <<EOL >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
def CONDOR_CUZCO_V1 : RISCVProcessorModel<"condor-cuzco-v1",
                                            NoSchedModel,
                                            [Feature64Bit,
                                             FeatureStdExtI,
                                             FeatureStdExtZifencei,
                                             FeatureStdExtZicsr,
                                             FeatureStdExtZicntr,
                                             FeatureStdExtZihpm,
                                             FeatureStdExtZihintpause,
                                             FeatureStdExtM,
                                             FeatureStdExtA,
                                             FeatureStdExtF,
                                             FeatureStdExtD,
                                             FeatureStdExtC,
                                             FeatureStdExtZba,
                                             FeatureStdExtZbb,
                                             FeatureStdExtZbc,
                                             FeatureStdExtZbs,
                                             FeatureStdExtZicbom,
                                             FeatureStdExtZicbop,
                                             FeatureStdExtZicboz],
                                             [TuneLUIADDIFusion,
                                              TuneAUIPCADDIFusion,
                                              TuneZExtHFusion,
                                              TuneZExtWFusion,
                                              TuneShiftedZExtWFusion,
                                              TuneLDADDFusion,
EOL

# Append fusion names to the processor model without trailing comma on the last item
for name in $fusion_names; do
    echo "                                              $name," >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
done

# Remove the last comma to correctly format the output
sed -i '$ s/,$//' "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"

# Close the processor model definition
echo "]>;" >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"

# 5. Perform the build steps

# Step 5.1: Clean the RISCV target directory
echo "Cleaning RISCV target directory..."
cd "$build_dir/lib/Target/RISCV" || exit
make -j32 clean

# Step 5.2: Clean the LLVM TargetParser directory
echo "Cleaning LLVM TargetParser directory..."
cd "$build_dir/include/llvm/TargetParser" || exit
make -j32 clean

# Step 5.3: Build and install the necessary targets
echo "Building and installing targets..."
cd "$build_dir" || exit
make -j32 RISCVCommonTableGen
make -j32 RISCVTargetParserTableGen
make -j32 install

echo "LLVM update with macro fusions completed successfully."

# End of the script
