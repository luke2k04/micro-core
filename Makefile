obj_dir ?= build
test_name ?= default

instructions_dir := tests/instructions

build-test: | scratch
	verilator -j 0 --Mdir build --binary tests/tb/core/tb.sv src/*.sv

scratch:
	mkdir -p build/scratch

clean:
	rm -rf $(obj_dir)

test: build-test
	./${obj_dir}/Vtb +memory=$(instructions_dir)/$(test_name)/memory.hex +dump=$(obj_dir)/scratch/memory_dump.hex
	@if diff -q $(instructions_dir)/$(test_name)/expected_memory.hex $(obj_dir)/scratch/memory_dump.hex; then \
		echo "PASS"; \
	else \
		echo "FAIL"; \
		diff $(instructions_dir)/$(test_name)/expected_memory.hex $(obj_dir)/scratch/memory_dump.hex; \
		exit 1; \
	fi
