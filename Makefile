boot.elf: $(wildcard src/bootlib/bootlib/*.s src/*.s)
	$(CC) -g -nostdlib -m32 -Wl,-Tsrc/bootlib/bootlib/boot.ld -o $@ $^

.PHONY: test
test: boot.elf
	qemu-system-x86_64 -kernel $<

.PHONY: clean
clean:
	rm -f boot.elf

