clean:
	rm cesar
	rm cesar.o
cesar.o:
	as -o cesar.o cesar.s
cesar: cesar.o
	ld -o cesar --no-relax cesar.o
strace: cesar
	strace -tT ./cesar
dump: cesar
	objdump -d cesar
labels: cesar
	objdump -x cesar
