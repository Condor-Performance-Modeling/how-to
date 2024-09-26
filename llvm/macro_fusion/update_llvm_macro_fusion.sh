#!/bin/bash

# Contact: Stan Iwan
#          Sofomo
#          2024.09.10

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_update_llvm_with_fusion.log"

source_dir=""
build_dir=""
fusion_definitions=""
updated_build_dirs=()
install_dirs=()
auto_yes=false  # Default to false, becomes true if -y is used

exit_with_usage() {
    echo "Usage: $0 [-s source_dir] [-b build_dir] [-f fusion_definitions] [-y]"
    exit 1
}

verify_fusion_definitions() {
    echo
    if [[ -z "$fusion_definitions" ]]; then
        fusion_definitions="$(dirname "$0")/fusion_definitions"
        if [[ "$auto_yes" = false ]]; then
            read -p "Fusion definitions not provided. Use default at $fusion_definitions? [Y/n]: " use_default
        else
            use_default="Y"
        fi
        use_default="${use_default:-Y}"
        if [[ ! "$use_default" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "No fusion definitions provided, and default declined."
            exit 1
        fi
    fi

    if [[ ! -f "$fusion_definitions" ]]; then
        echo "Fusion definitions file $fusion_definitions does not exist."
        exit_with_usage
    fi
}

verify_source_directory() {
    echo
    if [[ -z "$source_dir" ]]; then
        source_dir="$(pwd)/riscv-llvm"
        if [[ "$auto_yes" = false ]]; then
            read -p "Source directory not provided. Use default at $source_dir? [Y/n]: " use_default
        else
            use_default="Y"
        fi
        use_default="${use_default:-Y}"
        if [[ ! "$use_default" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "No source directory provided, and default declined."
            exit 1
        fi
    fi

    if [ ! -d "$source_dir" ] || 
       [ ! -f "$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.td" ] || 
       [ ! -f "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td" ]; then
        echo "Source directory $source_dir is invalid or missing required files."
        exit_with_usage
    fi
}

verify_build_directories() {
    build_dirs=()

    echo
    if [[ -z "$build_dir" ]]; then
        build_dir_baremetal="$source_dir/_build_baremetal"
        build_dir_linux="$source_dir/_build_linux"
        if [[ "$auto_yes" = false ]]; then
            read -p "Build directories not provided. Use defaults ($build_dir_baremetal and $build_dir_linux)? [Y/n]: " use_default
        else
            use_default="Y"
        fi
        use_default="${use_default:-Y}"
        if [[ ! "$use_default" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "No build directories provided, and defaults declined."
            exit 1
        fi
        build_dirs=("$build_dir_baremetal" "$build_dir_linux")
    else
        build_dirs=("$build_dir")
    fi

    for dir in "${build_dirs[@]}"; do
        if [ ! -d "$dir" ] || [ ! -f "$dir/Makefile" ]; then
            echo "Build directory $dir is invalid or missing a Makefile."
            exit_with_usage
        fi
    done
}

confirm_paths() {
    echo
    echo "The following paths have been verified:"
    echo "Fusion definitions: $fusion_definitions"
    echo "Source directory: $source_dir"
    echo "Build directories: ${build_dirs[*]}"
    if [[ "$auto_yes" = false ]]; then
        read -p "Do you want to continue with the above paths? [Y/n]: " confirm_continue
    else
        confirm_continue="Y"
    fi
    confirm_continue="${confirm_continue:-Y}"
    if [[ ! "$confirm_continue" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Execution canceled by user."
        exit 1
    fi
}

perform_build() {
    local build_dir="$1"

    echo "Cleaning RISCV target directory in $build_dir..."
    cd "$build_dir/lib/Target/RISCV" || exit
    make -j32 clean

    echo "Cleaning LLVM TargetParser directory in $build_dir..."
    cd "$build_dir/include/llvm/TargetParser" || exit
    make -j32 clean

    echo "Building and installing targets in $build_dir..."
    cd "$build_dir" || exit
    make -j32 RISCVCommonTableGen
    make -j32 RISCVTargetParserTableGen
    make -j32 install

    # Extract install directory
    install_dir=$(grep -m 1 "^CMAKE_INSTALL_PREFIX" "$build_dir/CMakeCache.txt" | cut -d '=' -f 2)
    if [ -z "$install_dir" ]; then
        install_dir=$(grep -m 1 "^prefix" "$build_dir/Makefile" | cut -d '=' -f 2)
    fi

    updated_build_dirs+=("$build_dir")
    install_dirs+=("$install_dir")
}

# Function to update the source files with fusion definitions
update_source_files() {
    local source_dir="$1"
    local fusion_definitions="$2"

    # Paths for backup files
    local macro_fusion_backup="$source_dir/llvm/lib/Target/RISCV/RISCVMacroFusion.bak"
    local processors_backup="$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.bak"

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

    # 4. Create the processor model without fusion (condor-cuzco-v1) and with fusion (condor-cuzco-v1-fusion)
    echo "" >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
    echo "//MACRO_FUSION_AUTOMATIC_UPDATE" >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"

    # Processor without fusion
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
                                            TuneLDADDFusion]>;
EOL

    # Processor with fusion
    cat <<EOL >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
def CONDOR_CUZCO_V1_FUSION : RISCVProcessorModel<"condor-cuzco-v1-fusion",
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

    # Append fusion names to the processor model without a trailing comma on the last item
    for name in $fusion_names; do
        echo "                                                 $name," >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
    done

    # Remove the last comma to correctly format the output
    sed -i '$ s/,$//' "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"

    # Close the processor model definition
    echo "]>;" >> "$source_dir/llvm/lib/Target/RISCV/RISCVProcessors.td"
}

update_llvm_with_fusion() {
    # Parse arguments
    while getopts "s:b:f:y" opt; do
        case $opt in
            s) source_dir="$OPTARG"
            ;;
            b) build_dir="$OPTARG"
            ;;
            f) fusion_definitions="$OPTARG"
            ;;
            y) auto_yes=true
            ;;
            \?) echo "Invalid option -$OPTARG" >&2
                exit_with_usage
            ;;
        esac
    done

    verify_fusion_definitions

    verify_source_directory

    verify_build_directories

    confirm_paths

    # If everything is verified, update source and perform builds
    update_source_files "$source_dir" "$fusion_definitions"
    for dir in "${build_dirs[@]}"; do
        echo "Updating LLVM with fusion groups for build directory: $dir"
        perform_build "$dir"
    done

    # Summary of the updated build directories and their install directories
    echo
    echo "Summary of updated build directories and their install paths:"
    for i in "${!updated_build_dirs[@]}"; do
        echo
        echo "Build Directory: ${updated_build_dirs[$i]}"
        echo "Install Directory: ${install_dirs[$i]}"
    done
    echo
    echo "LLVM update with macro fusion groups completed successfully."
}

update_llvm_with_fusion "$@" 2>&1 | tee -a "$LOG_FILE"
