.PHONY: clean all

# Detect OS and architecture
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Set compiler
CC = gcc

# Base flags
CFLAGS = -Wall -g
LDFLAGS =
LIBS =

# OS-specific settings
ifeq ($(UNAME_S),Linux)
    CFLAGS += -D_GNU_SOURCE
    # Static linking only on Linux for better portability
    LDFLAGS += -static
    LIBS += -lcrypt
endif

ifeq ($(UNAME_S),Darwin)
    # macOS specific flags
    CFLAGS += -D_DARWIN_C_SOURCE
    # Don't use static linking on macOS
    # Check if running on Apple Silicon
    ifeq ($(UNAME_M),arm64)
        CFLAGS += -arch arm64
    else
        CFLAGS += -arch x86_64
    endif
endif

# BSD variants
ifneq (,$(filter $(UNAME_S),FreeBSD OpenBSD NetBSD))
    CFLAGS += -D_BSD_SOURCE
    LIBS += -lutil
endif

# Architecture-specific flags for 32/64 bit support
ifdef BUILD_32BIT
    CFLAGS += -m32
    LDFLAGS += -m32
else ifdef BUILD_64BIT
    CFLAGS += -m64
    LDFLAGS += -m64
endif

# Binary name
BIN = miniftpd

# Object files
OBJS = main.o sysutil.o session.o ftpproto.o privparent.o str.o \
       tunable.o parseconf.o privsock.o hash.o

# Default target
all: $(BIN)

# Link binary
$(BIN): $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)

# Compile source files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	rm -f *.o $(BIN)

# Help target
help:
	@echo "Build targets:"
	@echo "  make          - Build for current platform"
	@echo "  make BUILD_32BIT=1 - Build 32-bit binary"
	@echo "  make BUILD_64BIT=1 - Build 64-bit binary"
	@echo "  make clean    - Remove build artifacts"