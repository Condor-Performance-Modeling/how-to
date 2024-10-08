# Macro Fusion in LLVM for RISC-V

Macro fusion is a performance optimization where specific instruction pairs are combined for more efficient execution. The LLVM compiler can be customized to support macro fusion through the modification of relevant target description files and by defining fusion rules in the `RISCVMacroFusion.td` file.

For detailed instructions on configuring and enabling macro fusion in LLVM, please refer to the `LLVM_FOR_RISCV.md` file located in the **how-to** repository.

## How Fusion Tuples Defined in `.td` Files Get Applied

Fusion tuples defined in `.td` files, like `RISCVMacroFusion.td`, are used to optimize instruction scheduling in the LLVM compilation process. These fusion groups are integrated through the auto-generated `RISCVGenMacroFusion.inc` and `RISCVGenSubtargetInfo.inc` files, which are built using the `TableGen` tool via the `RISCVCommonTableGen` target. This file contains important functionality for handling various processor-specific features, including macro fusion.

The core of the fusion application process lies in the `getMacroFusions()` function within the `RISCVGenSubtargetInfo` class, which is declared in the generated `RISCVGenSubtargetInfo.inc` file. This function collects all the macro fusion predicates that are enabled for the target processor based on its features. These predicates are added to a list of fusion tuples that will be applied during the scheduling phase. All predicates used by `getMacroFusions()` function are defined in the `RISCVGenMacroFusion.inc` file.

The `getMacroFusions()` function is called within `RISCVSubtarget.cpp` via the `getPostRAMutations()` method, which appends a fusion mutation to the instruction scheduler by calling `createMacroFusionDAGMutation()`. This setup allows LLVM to apply the appropriate fusion rules during instruction scheduling, optimizing the placement and pairing of instructions based on the target architecture's capabilities, as defined in the `.td` files and processed through `RISCVGenSubtargetInfo.inc`.

Additionally, `RISCVGenSubtargetInfo.inc` contains processor-specific definitions, which allow LLVM to handle various aspects of the scheduling process. These processor definitions include configurations for resources, buffer sizes, issue width, and scheduling models.

## Multiple Instructions Fusion

In LLVM's current implementation (`20.0.0git`), RISC-V relies on the `SimpleFusion` class defined in `TargetMacroFusion.td` to enable macro fusion for two instructions at a time. This design hinges on the concept of "fusion targets"—specifically, first and second instruction targets—evaluated through predicates defined using `FusionPredicate`. These predicates check conditions such as opcode matching, operand values, and register usage, ensuring the fusion process is both valid and beneficial.

However, LLVM currently only supports chaining two instructions together due to limitations in its `MacroFusion.cpp` implementation, where an assertion prevents more than two instructions from being fused. If more complex fusion patterns involving multiple instructions were to be implemented, significant changes to the scheduling mechanism and fusion dependency tracking would be required. The assertion in the `MacroFusion.cpp` file—"Currently we only support chaining together two instructions"—highlights this constraint. Although theoretically possible, expanding fusion to handle more than two instructions would necessitate creating artificial edges in the scheduling DAG to prevent improper instruction reordering, ensuring correct execution of chained fusion groups.

`MacroFusion.cpp` has this TODO related to multiple instructions fusion

```cpp
  // TODO - If we want to chain more than two instructions, we need to create
  // artifical edges to make dependencies from the FirstSU also dependent
  // on other chained instructions, and other chained instructions also
  // dependent on the dependencies of the SecondSU, to prevent them from being
  // scheduled into these chained instructions.
  assert(hasLessThanNumFused(FirstSU, 2) &&
         "Currently we only support chaining together two instructions");
```

## How Fusion Tuples Are Applied

In LLVM, macro fusion is applied during the instruction scheduling phase using the `fuseInstructionPair` function, which attempts to fuse two instructions into a single operation. This process is managed in the `MacroFusion.cpp` file, where the function `fuseInstructionPair` plays a central role in identifying valid instruction pairs and modifying the scheduling Directed Acyclic Graph (DAG) to reflect the fusion.

The `fuseInstructionPair` function works as follows:

1. **Validation of Fusion Conditions**: Before attempting to fuse instructions, the function checks that neither the first nor the second instruction has already been paired with another instruction through "cluster edges" (a special type of edge in the scheduling DAG). This ensures that each instruction can only be involved in one fusion.

2. **Adding a Cluster Edge**: If the fusion conditions are met, the function creates a weak cluster edge between the first and second instructions. This edge encourages the scheduling algorithm to prioritize these instructions and place them adjacently in the final instruction order.

3. **Adjusting Instruction Latencies**: The function reduces the latencies between the two instructions to zero, effectively allowing them to execute together as a single unit. This step is critical because it helps the processor treat the fused pair as a single operation, improving execution efficiency.

4. **Preventing Instruction Reordering**: Once fused, additional logic is introduced to prevent unrelated instructions from being scheduled between the fused pair. This is accomplished by modifying dependencies in the DAG. For instance, any instruction that originally depended on the first instruction is made to depend on the second instruction as well, and vice versa. This ensures that instructions do not get scheduled between the fused pair, maintaining the integrity of the fusion.

5. **Ensuring Fusion of Multiple Instructions (If Supported)**: While the current implementation only supports fusing two instructions at a time, the code leaves room for potential expansion to multiple instruction fusion. The function checks that the number of fused instructions is less than the defined limit (which is 2 by default), and it raises an assertion if more than two instructions are fused.

6. **Scheduling Priority**: Once fused, the instructions are given higher scheduling priority, ensuring that they remain adjacent in the instruction stream and that their fused execution can occur without interference from other instructions.

Through these steps, `fuseInstructionPair` ensures that the target instructions are correctly paired and fused during the scheduling process. The result is a more efficient execution pipeline, with fused instruction pairs executing as a single micro-operation. However, this is limited to two instructions at a time in the current implementation, as reflected in the assertion within the code.

## MatInt and Other Processor Features

The `MatInt` feature in RISC-V is essential for optimizing how immediate values are handled during instruction generation. Implemented in `RISCVMatInt.cpp`, it generates efficient instruction sequences based on the size and characteristics of the constant. For smaller constants (within 32 bits), combinations like `LUI` (Load Upper Immediate) and `ADDI` are used. For larger, 64-bit constants, more complex sequences with shifts and multiple additions are needed to account for sign-extension and other RISC-V nuances.

These optimizations are tied to processor-specific features and integrated with the instruction scheduler, ensuring that `MatInt` adapts to the architecture’s requirements. The scheduler keeps fused instructions together, as defined in `RISCVMacroFusion.td`, to enhance performance.

To enable these optimizations, features like `MatInt` and `MacroFusion` must be included in the processor definitions in `RISCVProcessors.td`. Without them, even basic programs may fail to compile.

## Statistics Macro in MicroFusion.cpp

The `STATISTIC` macro in `MicroFusion.cpp` is used to track how many instruction pairs are fused during instruction scheduling. This optimization is key for improving instruction throughput by ensuring that certain instructions can be executed back-to-back without delays. In `MicroFusion.cpp`, the macro `NumFused` is defined to count the number of instruction pairs fused:

```cpp
STATISTIC(NumFused, "Number of instr pairs fused");
```

This macro tracks how many times macro fusion occurs during the compilation process. The statistic provides feedback on how effectively the instruction scheduler can pair instructions, helping developers understand the performance of this optimization.

For larger projects with multiple build targets, you might neet to grep for the `NumFused`  across all .stats files generated during the build to verify if fusion optimizations were applied.
