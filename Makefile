OBJDIR ?= build
TEST_NAME ?= default

INSTRUCTIONS_DIR := tests/instructions

build-test: | scratch
	verilator -j 0 --Mdir build --binary tests/tb/core/tb.sv src/*.sv

scratch:
	mkdir -p build/scratch

clean:
	rm -rf $(OBJDIR)

test: build-test
	./${OBJDIR}/Vtb +program=$(INSTRUCTIONS_DIR)/$(TEST_NAME)/program.hex +memory=$(INSTRUCTIONS_DIR)/$(TEST_NAME)/memory.hex +dump=$(OBJDIR)/scratch/memory_dump.hex
	@if diff -q $(INSTRUCTIONS_DIR)/$(TEST_NAME)/expected_memory.hex $(OBJDIR)/scratch/memory_dump.hex; then \
		echo "PASS"; \
	else \
		echo "FAIL"; \
		diff $(INSTRUCTIONS_DIR)/$(TEST_NAME)/expected_memory.hex $(OBJDIR)/scratch/memory_dump.hex; \
		exit 1; \
	fi
