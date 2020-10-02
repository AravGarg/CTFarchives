#!/bin/sh
set -e

echo "Bulding firmware..."

( cd firmware && make clean && make -j12 )

echo "Verilating RTL..."

verilator -LDFLAGS "-O3 -static -lrt -pthread -Wl,--whole-archive -lpthread -Wl,--no-whole-archive" --language 1800-2017 --cc --top-module top --exe -Wno-fatal --trace \
        rtl/top.v rtl/axi4_memory.v rtl/axi4_interconnect.v rtl/axi4_uart.v \
        rtl/axi4_lpt.v rtl/fifo.v rtl/axi4_flagdevicetm.v \
        picorv32/picorv32.v \
        main.cpp

echo "Building..."
make -C obj_dir -f Vtop.mk
cp firmware/ram.hex obj_dir/firmware.hex
