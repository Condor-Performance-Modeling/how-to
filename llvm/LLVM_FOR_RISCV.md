# Building LLVM on Linux for RISC-V 64-bit Cross-Compilation

```text
Contact: Stan Iwan
         Sofomo
         2024.07.22
```

This document outlines the steps to build LLVM on a Linux machine for cross-compiling C/C++ code for RISC-V 64-bit.

## Before You Start

*This step is optional. All required packages should already be installed for you. If you want to verify this, follow steps below:*

Update your package manager to avoid errors during setup:

```bash
sudo apt update
```

Install the required packages:

```bash
sudo apt -y install \
  binutils build-essential libtool texinfo \
  gzip zip unzip patchutils curl git \
  make cmake ninja-build automake bison flex gperf \
  grep sed gawk python3 bc \
  zlib1g-dev libexpat1-dev libmpc-dev \
  libglib2.0-dev libfdt-dev libpixman-1-dev
```

### Exit Conda

**You must deactivate the conda environment before building LLVM.**

Deactivate once to exit the sparta environment, once again to exit the base conda
environment.

Your prompt should not show `(base)` or `(sparta)` when you have
successfully deactivated the environments.

```bash
  conda deactivate     # leave sparta
  conda deactivate     # leave base
```

### Clone the Repository

Before running the script, you need to clone the repository containing build_llvm.sh. This repository also includes additional scripts and documentation that might be useful for your development process.

Clone the repository using SSH:

```bash
git clone git@github.com:Condor-Performance-Modeling/how-to.git
```

## Use script to build LLVM

### Running the Script

To begin the setup process, navigate to the directory containing the build_llvm.sh script and execute it. This script automates the tasks of downloading, compiling, and installing the LLVM toolchain tailored for RISC-V development.

```bash
bash how-to/llvm/build_llvm.sh
```

### What `build_llvm.sh` Script Does

- *Cloning Required Repositories:* The script starts by cloning the necessary repositories, including the RISC-V GNU Toolchain and the LLVM project. These repositories provide the source code needed to compile the toolchain and LLVM specifically for the RISC-V architecture.
- *Copying/Compiling RISC-V GNU Toolchain for Baremetal:* Depending on whether a pre-built toolchain is available, the script may copy an existing toolchain or compile a new one for Baremetal development.
- *Compiling LLVM for Baremetal:* Next, the script compiles LLVM components for baremetal development. LLVM provides a collection of modular and reusable compiler and toolchain technologies.
- *Copying/Compiling RISC-V GNU Toolchain for Linux:* Depending on whether a pre-built toolchain is available, the script may copy an existing toolchain or compile a new one for Linux development.
- *Compiling LLVM for Linux:* Finally, the script compiles LLVM for Linux, enabling the development of applications for RISC-V based Linux systems.

By default, the script builds LLVM with the `-DLLVM_FORCE_ENABLE_STATS` option enabled. This feature allows LLVM to collect and print statistics related to its internal operations. These statistics can be useful for developers who want to analyze the performance and behavior of the LLVM components, such as how often certain optimizations are applied or how many times specific instructions are executed during compilation.

Once the script completes successfully, the LLVM toolchain for both baremetal and Linux RISC-V development will be installed in the specified directories.

## Compiling a Simple C/C++ Program for RISC-V 64-bit

Create a source file `hello.c`:

```c
#include <stdio.h>
int main(){
  printf("Hello RISCV!\n");
  return 0;
}
```

Compile the code:

```bash
[PATH_TO_YOUR_LLVM_INSTALL]/bin/clang -march=rv64gc -mabi=lp64d hello.c -o hello
```

## Fusion Exploration with LLVM Compiler

Macro fusion is a hardware optimization technique where certain pairs of instructions are fused together to execute more efficiently. This can lead to performance improvements without changing the existing Instruction Set Architecture (ISA). By defining preferred instruction pairs and hinting the compiler, we can increase the effectiveness of internal fusion hardware.

### Fusion Exploration Prerequisites

Steps presented below expect that you have already build the LLVM on Linux for RISC-V 64-bit Cross-Compilation using `how-to/llvm/build_llvm.sh` and want to tweak it by adding new fusion predicator. You can find instructions on how to build the LLVM [here](#building-llvm-on-linux-for-risc-v-64-bit-cross-compilation).

*Optionally, you can modify all `.td` files mentioned below in your LLVM source directory and build it by running `cmake` with desired configuration in your LLVM build directory, then `make` and `make install`.*

### Automating Fusion Integration with Script

For convenience, you can automatically update your LLVM build to include a predefined set of macro fusion predicators by running a provided script. This script is located in under `how-to/llvm/macro_fusion`.

To update LLVM with these predefined fusions, simply execute the following command:

```bash
bash how-to/llvm/macro_fusion/update_llvm_macro_fusions.sh -s [source_dir] -b [build_dir] -f [fusion_definitions]
```

- `source_dir`: Path to your LLVM source directory.
- `build_dir`: Path to your LLVM build directory.
- `fusion_definitions`: Path to the file containing predefined fusion predicates (already included in the `how-to/llvm/macro_fusion` directory).

Running this script will update the necessary LLVM source files with the predefined fusion definitions and automatically rebuild and install the updated LLVM components. After it succeeds you can run LLVM tools with `-mcpu='help'` argument to verify if new processor target with predefined fusions enabled is visible on the list.

### Add new fusion predicator to `RISCVMacroFusion.td`

Fusions are defined in the `llvm/lib/Target/RISCV/RISCVMacroFusion.td` file. Each fusion predicator is defined using the `SimpleFusion` template. The definition includes:

1. **Name and Feature Strings:**
   - A unique name for the fusion (e.g., `"lui-addi-fusion"`).
   - A feature string used in the code to check if this fusion is enabled (e.g., `"HasLUIADDIFusion"`).
   - A description string that explains what the fusion does (e.g., `"Enable LUI+ADDI macro fusion"`).

2. **CheckAll:**
   - A combination of checks that all need to pass for the fusion to be applied. This can include checks for opcodes, immediate operands, operand ranges, etc.
   - Available checks are defined in `llvm/include/llvm/Target/TargetInstrPredicate.td` file.
   - A list of `RISCV` instructions is defined in `llvm/lib/Target/RISCV/RISCVInstrInfo.td` file.
   - A list of `RISCV` registers is defined in `llvm/lib/Target/RISCV/RISCVRegisterInfo.td` file.
   - **When not using CheckAll, an Opcode check is required to match specific opcodes of the instructions to be fused (e.g., CheckOpcode<[LUI]>).**

The structure is wrapped in the SimpleFusion template with the following format:

```cpp
def Name
  : SimpleFusion<"fusion-name", "FeatureString", "Description",
                 Check<ConditionsForFirstInstruction>,
                 Check<ConditionsForSecondInstruction>>;
```

Example fusion that is defined in the LLVM source by default:

```cpp
// Fuse load with add:
//   add rd, rs1, rs2
//   ld rd, 0(rd)
def TuneLDADDFusion
  : SimpleFusion<"ld-add-fusion", "HasLDADDFusion", "Enable LD+ADD macrofusion",
                 CheckOpcode<[ADD]>,
                 CheckAll<[
                   CheckOpcode<[LD]>,
                   CheckIsImmOperand<2>,
                   CheckImmOperand<2, 0>
                 ]>>;
```

> [!IMPORTANT]
> Based on my observations I suspect that the defined fusion will not always be applied, as LLVM does not blindly follow these definitions. Instead, it evaluates whether the fusion makes sense based on the context, ensuring it does not alter the function and that it provides a benefit.

> [!IMPORTANT]
> Fusion predicates with multiple instructions seem to be possible, but I have not yet found a way to make them compile. `SimpleFusion` class is defined in`llvm/include/llvm/Target/TargetMacroFusion.td` file and seems to support only 2 opcodes by default. With better understanding of `TargetMacroFusion.td` and its syntax it could be possible to implement new fusion classes that would work for more than 2 opcodes.

### Add new fusion predicator feature to processor definition

To enable the macro fusion feature for a specific processor, you need to update the processor model in the `llvm/lib/Target/RISCV/RISCVProcessors.td` file to include the new fusion feature.

**Update the Processor Model:** Edit the processor model definition to include the new macro fusion feature.

  ```cpp
  def MY_CUSTOM_PROCESSOR : RISCVProcessorModel<"my-custom-processor",
                                                 MySchedModel,
                                                 [Feature64Bit,
                                                  FeatureStdExtI,
                                                  MyNewMacroFusionFeature]>;
  ```

Change to `RISCVProcessors.td` is reflected in `RISCVTargetParserDef.inc` and `RISCVGenSubtargetInfo.inc`.

> [!IMPORTANT]
> Ensure that you add the necessary features to your processor model, as a generic configuration may not compile even basic programs such as "Hello, World!".

### Compile, Install and Verify

You need to compile `.td` files to reflect the changes you've made, then, you need to install the updated LLVM build to apply the changes.

1. **Clean `.inc` files that you want to regenerate**:
  Old `.inc` file will exist from the initial LLVM build. They will not be regenerated unless you run `clean` target in their directory:

  ```bash
  cd [PATH_TO_YOUR_LLVM_BUILD_DIR]/lib/Target/RISCV
  make clean
  cd [PATH_TO_YOUR_LLVM_BUILD_DIR]/include/llvm/TargetParser
  make clean
  ```

2. **Install the Updated LLVM Build**:
  Make required targets, then run `make install` command to install the changes:

  ```bash
  cd [PATH_TO_YOUR_LLVM_BUILD_DIR]
  make RISCVCommonTableGen
  make RISCVTargetParserTableGen
  make install
  ```

3. **Verify the Processor Configuration**:
  To ensure that your new processor definition is recognized by the clang compiler, check the available CPUs using the `-mcpu=help` option:

  ```bash
  [PATH_TO_YOUR_LLVM_INSTALL]/bin/clang -mcpu=help
  ```

4. **Compile with the New Processor**:
  To compile code using your custom processor definition, use the `-mcpu` or `-mtune` option with LLVM tools (example):

  ```bash
  [PATH_TO_YOUR_LLVM_INSTALL]/bin/clang -mcpu=my-custom-processor -o output.o input.c
  ```

## Building LLVM compiler-rt for RISC-V

The LLVM compiler-rt library includes runtime components like compiler support libraries and sanitizers that are essential for developing and testing your RISC-V applications. Follow the steps below to build and install compiler-rt.

### LLVM compiler-rt Prerequisites

Before building compiler-rt, ensure you have completed the previous steps for setting up LLVM on your Linux machine for RISC-V cross-compilation. The LLVM toolchain should be successfully installed, and the necessary development packages should be present on your system.

**This script will install LLVM Compiler RT on top of your existing LLVM installations!**

### Running the compiler-rt Build Script

The `how-to` repository includes the `build_llvm_compiler_rt.sh` script, which simplifies the process of building and installing `compiler-rt` on top of existing LLVM installation.

```bash
bash how-to/llvm/build_llvm_compiler_rt.sh
```

### What `build_llvm_compiler_rt.sh` Script Does

- *Validation of LLVM Installation Paths:* Ensures that the LLVM installations for both baremetal and Linux contain the required binaries (clang, clang++, etc.).
- *Cloning Required Repositories:* If the LLVM source is not already present in the specified directory, the script will clone the LLVM project repository.
- *Building compiler-rt for Baremetal and Linux:* Configures and compiles compiler-rt for both baremetal and Linux targets using the previously installed LLVM toolchain.
- *Installation:* The compiled compiler-rt libraries are installed into the specified LLVM installation directories, making them available for development and compilation tasks.