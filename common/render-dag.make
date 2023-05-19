.PHONY: all clean

all: rendered-dag.png clean

rendered-dag.png: rendered-dag.dot
	dot -Tpng $< -o $@

rendered-dag.dot: Makefile
	make -Bnd -f $< | make2graph > $@

clean:
	rm -f rendered-dag.dot

# vi: ft=make
