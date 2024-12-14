all: clean main run

main: main.o
	ld -s -o main main.o

main.o:
	nasm -g -f elf64 -o main.o main.s

run:
	@echo "Running main..."
	@./main && echo "Process exited normally" || echo "Process exited with error code $$?"

clean:
	rm -f main main.o