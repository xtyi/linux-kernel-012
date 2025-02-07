AS := as
LD := ld

LDFLAG := -m elf_x86_64 -Ttext 0x0 -s --oformat binary

linux.img : tools/build bootsect setup
	./tools/build bootsect setup > $@

tools/build : tools/build.c
	gcc -o $@ $<

bootsect : bootsect.o
	$(LD) $(LDFLAG) -o $@ $<

bootsect.o : bootsect.S
	$(AS) -o $@ $<

# -e 指定入口地址
setup : setup.o
	$(LD) $(LDFLAG) -e _start_setup -o $@ $<

setup.o : setup.S
	$(AS) -o $@ $<

clean:
	rm -f *.o
	rm -f bootsect
	rm -f setup
	rm -f tools/build
	rm -f linux.img
