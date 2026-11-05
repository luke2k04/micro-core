# micro-core

A single-cycle RISC-V processor implementing the RV32I base integer instruction set, written in SystemVerilog and simulated with Verilator.

## Features

- Single-cycle microarchitecture: every instruction completes in one clock cycle
- Separate instruction and data memories (Harvard architecture), 4 KiB each
- Byte, halfword and word loads/stores with sign and zero extension
- Self-checking test suite: each test compares the final contents of data memory against an expected result

### Supported instructions

| Group | Instructions |
|---|---|
| Arithmetic & logic (register) | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| Arithmetic & logic (immediate) | `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu` |
| Loads | `lb`, `lh`, `lw`, `lbu`, `lhu` |
| Stores | `sb`, `sh`, `sw` |
| Branches | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu` |
| Jumps | `jal`, `jalr` |
| Upper immediates | `lui`, `auipc` |
| Memory ordering | `fence` (treated as a no-op) |
| System | `ecall`, `ebreak` (halt the simulation) |

### Limitations

- No CSRs, interrupts or exceptions
- Misaligned memory accesses are not trapped
- Out-of-range addresses wrap around within the 4 KiB memories
- Instruction and data memories both start at address `0x0`

## Project structure

```
src/                     processor modules
  core.sv                top-level module connecting the datapath and control
  control_unit.sv        main decoder + ALU decoder + branch logic
  main_decoder.sv        opcode decoding into control signals
  alu_decoder.sv         selects the ALU operation
  alu.sv                 arithmetic/logic unit
  register_file.sv       32 × 32-bit registers, x0 hardwired to zero
  extend.sv              immediate generation (I/S/B/J/U formats)
  memory_read_extender.sv  byte/halfword selection and sign/zero extension for loads
  data_memory.sv         data memory with byte/halfword/word writes
  instruction_memory.sv  instruction memory
  pc_register.sv         program counter
  adder.sv               32-bit adder
tests/
  tb/core/tb.sv          testbench
  instructions/<name>/   one folder per test
utils/
  assemble.sh            assembles a test's .asm into program.hex using RARS
Makefile
```

Each test folder contains:

| File | Purpose |
|---|---|
| `<name>.asm` | test program source |
| `program.hex` | assembled program, loaded into instruction memory |
| `memory.hex` | initial contents of data memory |
| `expected_memory.hex` | expected contents of data memory after the program halts |

## Requirements

- [Verilator](https://www.veripool.org/verilator/) (tested with version 5.053)
- [RARS](https://github.com/TheThirdOne/rars) (only needed to assemble new test programs; `assemble.sh` runs it through Flatpak as `io.github.TheThirdOne.rars`)
- GNU Make

## Usage

Run a test:

```sh
make test TEST_NAME=add
```

This builds the simulator with Verilator, runs the program from `tests/instructions/add/` until it reaches `ecall`/`ebreak`, dumps the first 16 words of data memory and compares them with `expected_memory.hex`. The result is printed as `PASS` or `FAIL` (with a diff). The testbench also prints the final value of register `a0`.

Other targets:

```sh
make build-test   # only build the simulator
make clean        # remove the build directory
```

### Adding a test

1. Create a folder `tests/instructions/<name>/`.
2. Write the program in `<name>.asm` and end it with `ecall`.
3. Assemble it from inside the folder:
   ```sh
   cd tests/instructions/<name>
   ../../../utils/assemble.sh
   ```
4. Add `memory.hex` (initial data memory) and `expected_memory.hex` (expected result), one 32-bit hex word per line.
5. Run `make test TEST_NAME=<name>`.

## Acknowledgements

The microarchitecture is based on the single-cycle RISC-V processor described in *Digital Design and Computer Architecture: RISC-V Edition* by Sarah L. Harris and David Harris. All code was written independently and extends the design with additional RV32I instructions.

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
