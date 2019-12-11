boot.elf: $(wildcard bootlib/bootlib/*.s *.s)
	$(CC) -g -nostdlib -m32 -Wl,-Tbootlib/bootlib/boot.ld -o $@ $^

.PHONY: test
test: boot.elf
	qemu-system-x86_64 -kernel $<

.PHONY: clean
clean:
	rm -f boot.elf

