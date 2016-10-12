.PHONY: clean deps

all: deps

deps:
	make -C external

clean:
	make -C external clean

