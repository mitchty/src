CC=cc
CFLAGS=-O4
LIBS=
SRC=$(wildcard *.c)
TARGETS:=$(patsubst %.c,%,$(SRC))
BENCHSRC=$(wildcard *sort*.c)
BENCHTARGETS:=$(patsubst %.c,%,$(BENCHSRC))
PWD=$(shell pwd)
BMCOUNT=3

.PHONY: all
.PHONY: bm

all: $(TARGETS)

clean:
	-rm $(TARGETS) > /dev/null 2>&1

cleanly: clean all

%.c:
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

bm: $(BENCHTARGETS)
	count=$(BMCOUNT); \
	index=0; \
	export PATH=$(PWD):$$PATH; \
	for foo in $(BENCHTARGETS); do \
		echo $$foo warmup; \
		/usr/bin/time ./$$foo; \
		echo $$foo x $$count; \
		while [[ $$index -le $$count ]]; do \
			(( index = $$index + 1 )); \
			/usr/bin/time ./$$foo; \
		done; \
		index=0; \
	done
