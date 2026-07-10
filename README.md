# RV32I 5-Stage Pipelined Core — RTL & Verification

A synthesizable RV32I pipelined processor with full forwarding, static branch
prediction (BTB), minimal CSR/interrupt support, precise exceptions, and an
arbitrated shared-memory interface — verified with a reference-model-driven,
coverage-closed testbench.

Status: 🚧 In development. See `docs/project_charter.md` for full scope.

## Highlights

- 5-stage in-order pipeline (IF/ID/EX/MEM/WB)
- Full data forwarding + load-use hazard stalling
- Static branch prediction with BTB, flush-and-redirect on misprediction
- Minimal privileged CSR set (mstatus, mepc, mcause, mtvec) + ECALL/EBREAK
- Precise exception model (commit at WB, in-order flush)
- Shared instruction/data memory with static-priority arbitration
- ISS-based self-checking scoreboard + functional coverage + SVA assertions
- UVM verification environment (planned, see `uvm/README.md`)

## Repository Structure

See `docs/project_charter.md` §"Project Structure" or browse:

- `rtl/` — synthesizable design, organized by function (core, hazard, branch, csr, mem, common)
- `verif/` — ISS reference model, testbench, tests, coverage, regression
- `sim/` — simulation build outputs (waveforms, logs)
- `scripts/` — lint, assembly, coverage-report helper scripts
- `docs/` — charter, microarchitecture spec, verification plan, reports
- `uvm/` — placeholder for planned Phase 2 UVM environment

## Build & Run

```bash
# Assemble a test program
./scripts/assemble.sh verif/tests/directed/test_alu_ops.s

# Run a single test in simulation
cd sim && make run TEST=test_alu_ops

# View waveform
gtkwave sim/waves/test_alu_ops.vcd

# Run full regression
./verif/regression/run_regression.sh

# Lint RTL
./scripts/run_lint.sh
```

## Toolchain

| Purpose | Tool |
|---|---|
| Simulation | Icarus Verilog |
| Waveform debug | GTKWave |
| Lint | Verilator (`--lint-only`) |
| Reference model | Python ISS |
| Assertions | SystemVerilog Assertions (SVA) |

## Documentation

- [`docs/project_charter.md`](docs/project_charter.md) — full project scope, spec, and success criteria
- [`docs/microarchitecture.md`](docs/microarchitecture.md) — datapath and stage-by-stage design
- [`docs/verification_plan.md`](docs/verification_plan.md) — verification strategy and coverage model
- [`docs/performance_report.md`](docs/performance_report.md) — CPI and benchmark results
- [`docs/bugfix_case_study.md`](docs/bugfix_case_study.md) — a real debug writeup with waveforms

## Roadmap

- [x] Project charter / specification
- [ ] Microarchitecture design
- [ ] RTL implementation (stage by stage)
- [ ] Hazard unit
- [ ] CSR / exception logic
- [ ] ISS reference model
- [ ] Self-checking testbench
- [ ] SVA assertions
- [ ] Constrained-random regression
- [ ] Coverage closure
- [ ] Performance characterization
- [ ] UVM environment (Phase 2)
