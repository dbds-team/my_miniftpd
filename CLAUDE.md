# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tachftp is a Linux FTP server implementation that mimics vsftpd functionality. It's written in C and supports both active and passive modes, file transfer resumption, rate limiting, and connection limits.

## Build Commands

```bash
# Build the project
make

# Clean build artifacts
make clean

# Run the server (requires sudo)
sudo ./miniftpd
```

## Testing

No test framework is included. Testing is done manually by connecting to the FTP server:
```bash
ftp 127.0.0.1 5188
```

## Architecture

The codebase follows a modular architecture with clear separation of concerns:

### Core Components

- **main.c**: Entry point, handles server initialization, signal handling, and connection limits using hash tables for IP tracking
- **session.c/h**: Manages FTP session state and coordinates between parent/child processes
- **ftpproto.c/h**: Implements the FTP protocol handlers and command processing
- **privparent.c/h**: Implements privilege separation for security (nobody process)
- **privsock.c/h**: UNIX domain socket communication between privileged parent and unprivileged child

### Supporting Modules

- **sysutil.c/h**: System utilities for socket operations, file I/O, and process management
- **str.c/h**: String manipulation utilities
- **hash.c/h**: Hash table implementation for connection tracking
- **parseconf.c/h**: Configuration file parser
- **tunable.c/h**: Configuration parameters with defaults

### Key Design Patterns

1. **Privilege Separation**: Uses fork() to create a privileged parent and unprivileged child process communicating via UNIX domain sockets
2. **Per-Connection Process**: Each client connection spawns a new process
3. **Configuration-Driven**: Behavior controlled via miniftpd.conf with sensible defaults in tunable.c

## Configuration

Edit `miniftpd.conf` to customize server behavior. Key settings:
- `listen_port`: FTP server port (default: 5188)
- `max_clients`: Maximum concurrent connections
- `max_per_ip`: Maximum connections per IP address
- `upload_max_rate`/`download_max_rate`: Transfer rate limits in bytes/sec

Default values are defined in tunable.c if not specified in config file.