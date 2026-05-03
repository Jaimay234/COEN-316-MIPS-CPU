# COEN-316-MIPS-CPU

#### Disclaimer
This CPU was designed with a standard MIPS ISA in mind. The 32 bit MIPS processor was 32 bit in nature but masked down to 4 bits due to hardware constraints

## Overview
This project is a modular implementation of a mips Processor in VHDL as a part of the course COEN 316. It follows a structured data path and control architecture and supports a predefined subset of MIPS instructions.

The cpu is built from: The ALU, register file, control unit, and datapath integration

## Architecture

### Datapath Componenents
[Datapath Signals](COEN316ControlSignals.pdf)
- #### Register File
  - 32 general purpose registers
  - Dual read
  - singular write architecture
- #### ALU
  - Suports arithmetic and logical expressions
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
- Waveforms used to validate correct propogation and execution

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
 
