TARGET := riscv64-elf
ARCH := rv32imc
ABI := ilp32

CC := $(TARGET)-gcc
AS := riscv32-elf-as
LD := riscv32-elf-ld
OBJCOPY := $(TARGET)-objcopy
LIBGCC := $(shell $(CC) -march=$(ARCH) -mabi=$(ABI) -print-libgcc-file-name)

CFLAGS := $(CFLAGS) -march=$(ARCH) -mabi=$(ABI) -ffreestanding -nostdlib -Iprefix/$(TARGET)/include
LDFLAGS := -Bstatic -Tlink.ld --strip-debug -Lprefix/$(TARGET)/lib/rv32imac/ilp32 -L$(dir $(LIBGCC))
LIBS := -lc -lgcc
Q := @

default: all

build/start.o: src/start.S build
	@echo "AS	$@"
	$(Q)$(CC) $(CFLAGS) -c -o "$@" "$<"

build/%.o: src/%.c build prefix/$(TARGET)/lib/libc.a
	@echo "CC	$@"
	$(Q)$(CC) $(CFLAGS) -c -o "$@" "$<"

build:
	mkdir build

src/secret.c: src/secret-config.h

ram.elf: build/start.o build/main.o build/bsp.o
	@echo "LINK	$@"
	$(Q)$(LD) $(LDFLAGS) -o "$@" $^ $(LIBS)

ram.bin: ram.elf
	@echo "OBJCPY	$@"
	$(Q)$(OBJCOPY) -O binary "$<" "$@"

ram.hex: ram.bin
	python3 hexify.py "$<" > "$@"

# newlib

prefix/$(TARGET)/lib/libc.a: build/newlib/Makefile
	$(MAKE) -C build/newlib
	$(MAKE) -C build/newlib install

build/newlib/Makefile: newlib/configure
	mkdir -p build/newlib
	( cd build/newlib && CC= LD= $(shell pwd)/newlib/configure --target=$(TARGET) --with-arch=$(ARCH) --with-abi=$(ABI) --prefix=$(shell pwd)/prefix )

all: ram.hex

clean:
	rm -rf build/*.o ram.elf ram.bin

.PHONY: all clean
