CC = gcc
AR = ar
CFLAGS = -Wall -O2
DIST = dist
LIB = $(DIST)/libaes.a
OBJS = $(DIST)/aes.o $(DIST)/aes_asm.o
TEST = $(DIST)/aes_test

all: $(DIST) $(LIB) $(TEST)

$(DIST):
	mkdir -p $(DIST)

$(LIB): $(OBJS)
	$(AR) rcs $@ $^

$(DIST)/aes.o: aes.c aes.h | $(DIST)
	$(CC) $(CFLAGS) -c aes.c -o $@

$(DIST)/aes_asm.o: aes.s | $(DIST)
	$(CC) -c aes.s -o $@

$(TEST): main.c $(LIB)
	$(CC) $(CFLAGS) -o $@ main.c -L$(DIST) -laes

clean:
	rm -rf $(DIST)
