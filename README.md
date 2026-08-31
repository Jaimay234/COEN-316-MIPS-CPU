# MIPS-CPU

#### Disclaimer
This CPU was designed with a standard MIPS ISA in mind. The 32 bit MIPS processor was 32 bit in nature but masked down to 4 bits due to hardware constraints

## Overview
This project is a modular implementation of a mips Processor in VHDL as a part of the course COEN 316. It follows a structured data path and control architecture and supports a predefined subset of MIPS instructions. This was designed as a single cycle implementation (every single instruction performed simultaneously) rather than a traditional pipelined system. This was set up on a nexys board with a limited number of switches (12) available. This would not be enough to manually override the clock and manually trigger the desired instructions. The 32 bit functionality was sacrificed as can be seen by the top level entity specification of CPU.vhd which is the one that links directly downwards to the rest. This means that while each can be simulated independently the fully functioning CPU should use specifically that entity to integrate the other components.

The cpu is built from: The ALU, register file, control unit, and datapath integration

## Architecture

### Datapath Components
[Datapath Signals](COEN316ControlSignals.pdf)
- #### Register File
  - 32 general purpose registers
  - Dual read
  - singular write architecture
- #### ALU
  - Supports arithmetic and logical expressions
  - Controlled via signals from control unit
- #### Program Counter
  - Sequential instruction execution
  - Supports branches (conditional and unconditional)

### Control Unit
- Generates required signals based on opcode
- Separates:
  - Main logic
  - ALU control logic
- Controls
  - Register writes
  - ALU operations
  - Memory accesses (Instruction Cache and Data Cache)
  - Branch behaviour
 ### Supported Instructions

 This architecture implementation supports a subset of MIPS instructions in these formats:
 - R-type instructions (logical and arithmetic ie: and, add, sub, or)
 - I-type instructions (memory access and branch instructions, lw, sw, beq, j)
 - Immediate operations (addi)

### Theory
- Modular so each component can be individually verified
- Separation between datapath and control unit
- Easily Scalable and readable

### Tests
- Individual modules outputs independently verified
- Tested via loading instructions from Instruction cache
- Waveforms used to validate correct propagation and execution

### Outcomes
- CPU datapath design
- Control signal generation and decoding
- Hardware modularity
- Debugging using waveforms

### Improvement avenues
- Pipelining (5-stages)
- Hazard detection
- Instruction set
- More instruction types
- Removal of masking
- Optimize performance
- Stall detection
 
### How to run:
- Download .vhd files
- Create and upload them into a new modelsim project
- compile the files (Vcom in terminal)
- simulate the entity (the CPU entity is the highest level, from CPU.vhd)
- iterate through the program (It is pre-programmed with load register, load register, add + , branch to add if condition met, infinite loop) 
