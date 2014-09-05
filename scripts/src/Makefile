CC = clang
TARGET := status
SOURCES := status.c
OBJECTS := $(SOURCES:.c=.o)

#WARNINGS := -Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
           -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations \
           -Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
           -Wuninitialized -Wconversion -Wstrict-prototypes
CFLAGS := -std=c99 $(WARNINGS)
LFLAGS := -lm

DEBUG  := -ggdb
GPROF  := -pg

all: $(TARGET)

debug: CFLAGS += $(DEBUG)
debug: $(TARGET)

gprof: CFLAGS += $(GPROF)
gprof: LFLAGS += $(GPROF)
gprof: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(LFLAGS) $(OBJECTS) -o $@

%.o: %.c %.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@-rm *.o

.PHONY: all clean
