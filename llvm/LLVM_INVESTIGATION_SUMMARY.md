# Macro Fusion in LLVM for RISC-V

Macro fusion is a performance optimization where specific instruction pairs are combined for more efficient execution, particularly useful in the RISC-V architecture. The LLVM compiler can be customized to support macro fusion through the modification of relevant target description files and by defining fusion rules in the `RISCVMacroFusion.td` file.

For detailed instructions on configuring and enabling macro fusion in LLVM, please refer to the `LLVM_FOR_RISCV.md` file located in the **how-to** repository.

## How Fusions Defined in `.td` Files Get Applied

TODO - other.td files (RISCVMacroFusion, RISCVProcessors???)

Fusions defined in `.td` files, such as `RISCVMacroFusion.td`, are integrated into the LLVM compilation process through the `RISCVGenSubtargetInfo.inc` file. This file is auto-generated as part of the build process by the `RISCVCommonTableGen` target, using the TableGen tool. The `RISCVGenSubtargetInfo.inc` file contains important functionality for handling various processor-specific features, including macro fusion.

The core of the fusion application process lies in the `getMacroFusions()` function within the `RISCVGenSubtargetInfo` class, which is declared in the generated `RISCVGenSubtargetInfo.inc` file. This function collects all the macro fusion predicates that are enabled for the target processor based on its features. These predicates are added to a list of fusions that will be applied during the scheduling phase.

The `getMacroFusions()` function is called within `RISCVSubtarget.cpp` via the `getPostRAMutations()` method, which appends a fusion mutation to the instruction scheduler by calling `createMacroFusionDAGMutation()`. This setup allows LLVM to apply the appropriate fusion rules during instruction scheduling, optimizing the placement and pairing of instructions based on the target architecture's capabilities, as defined in the `.td` files and processed through `RISCVGenSubtargetInfo.inc`.

## Multiple Instructions Fusions

In LLVM's current implementation, RISC-V relies on the `SimpleFusion` class defined in `TargetMacroFusion.td` to enable macro fusion for two instructions at a time. This design hinges on the concept of "fusion targets"—specifically, first and second instruction targets—evaluated through predicates defined using `FusionPredicate`. These predicates check conditions such as opcode matching, operand values, and register usage, ensuring the fusion process is both valid and beneficial.

However, LLVM currently only supports chaining two instructions together due to limitations in its `MacroFusion.cpp` implementation, where an assertion prevents more than two instructions from being fused. If more complex fusion patterns involving multiple instructions were to be implemented, significant changes to the scheduling mechanism and fusion dependency tracking would be required. The assertion in the `MacroFusion.cpp` file—"Currently we only support chaining together two instructions"—highlights this constraint. Although theoretically possible, expanding fusion to handle more than two instructions would necessitate creating artificial edges in the scheduling DAG to prevent improper instruction reordering, ensuring correct execution of chained fusions.

`MacroFusion.cpp` has this TODO related to multiple instructions fusions

```cpp
  // TODO - If we want to chain more than two instructions, we need to create
  // artifical edges to make dependencies from the FirstSU also dependent
  // on other chained instructions, and other chained instructions also
  // dependent on the dependencies of the SecondSU, to prevent them from being
  // scheduled into these chained instructions.
  assert(hasLessThanNumFused(FirstSU, 2) &&
         "Currently we only support chaining together two instructions");
```

## How Fusions Are Applied

In LLVM, macro fusion is applied during the instruction scheduling phase using the `fuseInstructionPair` function, which attempts to fuse two instructions into a single operation. This process is managed in the `MacroFusion.cpp` file, where the function `fuseInstructionPair` plays a central role in identifying valid instruction pairs and modifying the scheduling Directed Acyclic Graph (DAG) to reflect the fusion.

The `fuseInstructionPair` function works as follows:

1. **Validation of Fusion Conditions**: Before attempting to fuse instructions, the function checks that neither the first nor the second instruction has already been paired with another instruction through "cluster edges" (a special type of edge in the scheduling DAG). This ensures that each instruction can only be involved in one fusion.

2. **Adding a Cluster Edge**: If the fusion conditions are met, the function creates a weak cluster edge between the first and second instructions. This edge encourages the scheduling algorithm to prioritize these instructions and place them adjacently in the final instruction order.

3. **Adjusting Instruction Latencies**: The function reduces the latencies between the two instructions to zero, effectively allowing them to execute together as a single unit. This step is critical because it helps the processor treat the fused pair as a single operation, improving execution efficiency.

4. **Preventing Instruction Reordering**: Once fused, additional logic is introduced to prevent unrelated instructions from being scheduled between the fused pair. This is accomplished by modifying dependencies in the DAG. For instance, any instruction that originally depended on the first instruction is made to depend on the second instruction as well, and vice versa. This ensures that instructions do not get scheduled between the fused pair, maintaining the integrity of the fusion.

5. **Ensuring Fusion of Multiple Instructions (If Supported)**: While the current implementation only supports fusing two instructions at a time, the code leaves room for potential expansion to multiple instruction fusion. The function checks that the number of fused instructions is less than the defined limit (which is 2 by default), and it raises an assertion if more than two instructions are fused.

6. **Scheduling Priority**: Once fused, the instructions are given higher scheduling priority, ensuring that they remain adjacent in the instruction stream and that their fused execution can occur without interference from other instructions.

Through these steps, `fuseInstructionPair` ensures that the target instructions are correctly paired and fused during the scheduling process. The result is a more efficient execution pipeline, with fused instruction pairs executing as a single micro-operation. However, this is limited to two instructions at a time in the current implementation, as reflected in the assertion within the code.

This fusion mechanism is particularly beneficial in architectures like RISC-V, where certain pairs of instructions, such as load and arithmetic operations, can be fused to reduce execution time and improve overall performance.

## Default Macro Fusions in LLVM

WIP

## MatInt and Other Processor Features

WIP