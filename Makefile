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
    LIBS += -lcrypt
    # Enable static linking on Linux
    ifndef NO_STATIC
        LDFLAGS += -static
    endif
endif

ifeq ($(UNAME_S),Darwin)
    # macOS specific flags
    CFLAGS += -D_DARWIN_C_SOURCE
    # macOS doesn't support static linking well, disable by default
    # Use NO_STATIC=1 is not needed on macOS
endif

# BSD variants
ifneq (,$(filter $(UNAME_S),FreeBSD OpenBSD NetBSD))
    CFLAGS += -D_BSD_SOURCE
    LIBS += -lutil
    # Try static linking on BSD
    ifndef NO_STATIC
        LDFLAGS += -static
    endif
endif

# Architecture-specific flags for 32/64 bit support
ifdef BUILD_32BIT
    CFLAGS += -m32
    LDFLAGS += -m32
else ifdef BUILD_64BIT
    CFLAGS += -m64
    LDFLAGS += -m64
endif

# Release build flags
ifdef RELEASE
    CFLAGS += -O2 -DNDEBUG
    CFLAGS := $(filter-out -g,$(CFLAGS))
else
    CFLAGS += -g
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
	@echo "  make                    - Build for current platform (debug, static linked)"
	@echo "  make RELEASE=1          - Build release version (optimized, static linked)"
	@echo "  make NO_STATIC=1        - Build with dynamic linking"
	@echo "  make BUILD_32BIT=1      - Build 32-bit binary"
	@echo "  make BUILD_64BIT=1      - Build 64-bit binary"
	@echo "  make clean              - Remove build artifacts"
	@echo ""
	@echo "Examples:"
	@echo "  make RELEASE=1 BUILD_64BIT=1        - Release 64-bit build (static)"
	@echo "  make RELEASE=1 NO_STATIC=1          - Release build (dynamic linking)"