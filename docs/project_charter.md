# Project Charter: RV32I 5-Stage Pipelined Core — RTL & Verification

## 1. Project Objective

Design, implement, and verify a synthesizable RV32I pipelined processor core
with industry-representative hazard handling, exception support, and a
verification methodology built around a reference model and coverage-driven
closure — suitable as a portfolio project demonstrating both digital design
and verification competency for VLSI internship roles.

## 2. Scope Statement

**In scope:** RTL design, directed + constrained-random verification,
coverage closure, performance characterization, documentation.

**Out of scope (future work):** UVM environment, caching, out-of-order
execution, formal verification, multi-core, full privileged spec (S-mode/U-mode).

## 3. Architecture Overview

**Core type:** In-order, single-issue, 5-stage pipeline (IF-ID-EX-MEM-WB),
Harvard-style logical split over a shared arbitrated physical memory.

**Key subsystems:**
- Datapath (5 stages + pipeline registers)
- Hazard Detection & Forwarding Unit (standalone module)
- Branch Predictor (static + BTB)
- CSR/Exception Unit
- Memory Arbiter
- Performance Counter block

## 4. Functional Specification

### 4.1 ISA Support
RV32I base integer ISA — all instruction formats (R/I/S/B/U/J) — plus ECALL,
EBREAK, and minimal CSR instructions (CSRRW/CSRRS/CSRRC).

### 4.2 Pipeline Stage Responsibilities

| Stage | Function | Key outputs to next stage |
|---|---|---|
| IF | Fetch instruction, predict next PC via BTB | Instruction, PC, PC+4, prediction info |
| ID | Decode, register read, immediate gen, hazard detect | Control signals, operands, rd |
| EX | ALU op, branch resolution, address calc | ALU result, branch outcome/target |
| MEM | Load/store via arbitrated memory | Load data or ALU passthrough |
| WB | Register writeback, exception commit | — |

### 4.3 Hazard Handling Policy
Full data forwarding (EX/MEM→EX, MEM/WB→EX); one-cycle stall for load-use
hazard; flush on branch misprediction; static-priority structural hazard
resolution (MEM stage wins memory port over IF).

### 4.4 Control Flow Prediction
Static prediction (backward-taken/forward-not-taken heuristic) backed by a
BTB for target caching. Misprediction triggers flush of IF/ID and ID/EX and
PC redirection.

### 4.5 Exception & Interrupt Model
Precise exception model — exceptions detected in early stages (illegal
opcode in ID) propagate as tagged flags and commit only at WB, in program
order, flushing all younger instructions. Supports ECALL, EBREAK, and one
external/timer interrupt source. CSR set limited to mstatus, mepc, mcause,
mtvec.

### 4.6 Memory System
Single shared memory (instruction + data), static-priority arbiter (MEM > IF).
No caching.

## 5. Verification Strategy

### 5.1 Methodology
Reference-model-driven, self-checking verification with coverage-driven test
closure — not purely directed, not full UVM (documented as Phase 2 extension).

### 5.2 Test Tiers
1. Directed tests — one per instruction, one per hazard scenario in the spec
2. Corner-case directed tests — hazard-on-hazard combinations
3. Constrained-random regression — randomized valid instruction streams
4. Interrupt injection tests — random-cycle interrupt assertion

### 5.3 Checking Mechanism
ISS executes the same instruction stream and produces expected register
file / PC / memory state; scoreboard compares against RTL state every
retiring instruction.

### 5.4 Coverage Model
Functional coverage on: instruction/opcode space, each hazard type, branch
taken/not-taken/mispredict, exception/interrupt entry, cross-coverage of
hazard × control-flow events. Code coverage as a secondary metric.

### 5.5 Assertions
SVA properties: x0 always reads zero, PC never regresses except on
control-flow/exception, single writeback per cycle, no forwarding from an
invalid/stale pipeline register.

## 6. Toolchain

| Purpose | Tool |
|---|---|
| RTL simulation | Icarus Verilog |
| Waveform debug | GTKWave |
| Lint | Verilator (`--lint-only`) |
| Reference model | Python ISS |
| Assertions | SystemVerilog Assertions (SVA) |

## 7. Development Flow (Phase Order)

```
Spec -> Microarchitecture -> RTL (stage-by-stage) -> Hazard Unit
  -> CSR/Exception Logic -> ISS Reference Model -> Self-Checking TB
  -> Assertions -> Constrained-Random Regression -> Coverage Closure
  -> Performance Characterization -> Documentation
  -> [Future: UVM environment]
```

## 8. Deliverables

1. Synthesizable, lint-clean RTL (parameterized)
2. ISS reference model source
3. Self-checking testbench + regression suite
4. Coverage database + closure report
5. SVA assertion set
6. Datapath and testbench architecture diagrams
7. CPI/performance report on a benchmark program
8. Bug-fix case study (waveform-based)
9. Top-level README / project report

## 9. Success Criteria

- All directed + random regression tests pass against the ISS
- Functional coverage >= 95% on defined coverage model (with justified waivers)
- Zero lint warnings/errors
- Documented CPI on at least one non-trivial benchmark program
- All SVA assertions hold across the full regression suite

## 10. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Exception timing bugs (imprecise exceptions) | Dedicated corner-case tests + assertion on commit order |
| Structural + control hazard interaction bugs | Explicit cross-coverage bin for "misprediction during memory stall" |
| Scope creep toward caches/OoO | Hard-scoped as future work in charter |
| ISS/RTL divergence undetected | Scoreboard compares every retiring instruction, not just final state |
