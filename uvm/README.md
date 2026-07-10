# UVM Verification Environment (Planned — Phase 2)

This directory is a placeholder for the UVM-based verification
environment, planned as a Phase 2 extension after the RTL +
directed/coverage-driven verification (see docs/project_charter.md,
section 2: Scope Statement).

Planned structure (not yet implemented):
- interfaces/    — DUT interface(s)
- transactions/  — sequence item definitions
- sequences/     — stimulus sequences (directed + random)
- agents/        — driver + monitor + sequencer
- env/           — scoreboard, coverage, environment class
- tests/         — test-level classes
- reg_model/     — UVM RAL model for CSRs (mstatus, mepc, mcause, mtvec)
