#!/bin/bash
# scripts/assemble.sh <file.s>
# Assembles a RISC-V assembly test program into a hex/mem file
# for loading into rtl/mem/shared_memory.v.
# TODO: wire up riscv32-unknown-elf-as / objcopy toolchain
set -e
echo "TODO: assemble $1 -> ${1%.s}.hex"
