# sim/Makefile
# Build/run targets for Icarus Verilog simulation

RTL_SRCS := $(wildcard ../rtl/**/*.v) ../rtl/riscv_pkg.sv
TB_SRCS  := ../verif/tb/tb_top.sv ../verif/tb/scoreboard.sv \
            ../verif/tb/coverage_collector.sv ../verif/tb/assertions.sv

TEST ?= test_alu_ops

.PHONY: run clean

run:
	@echo "TODO: iverilog -g2012 -o sim.vvp \$(RTL_SRCS) \$(TB_SRCS) +TEST=$(TEST)"
	@echo "TODO: vvp sim.vvp"
	@echo "Waveform will be written to waves/$(TEST).vcd"

clean:
	rm -f sim.vvp
	rm -f waves/*.vcd logs/*.log
