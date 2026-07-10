#!/bin/bash
# scripts/run_lint.sh
# Lints all RTL with Verilator (--lint-only), no simulation.
set -e
verilator --lint-only -Wall $(find ../rtl -name '*.v' -o -name '*.sv')
