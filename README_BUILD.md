# Build Instructions

## Local Build

### Linux
```bash
# Default 64-bit build
make

# 32-bit build
make BUILD_32BIT=1

# Clean
make clean
```

### macOS
```bash
# Will automatically detect x64 or ARM64
make
```

### FreeBSD
```bash
# Use gmake instead of make
gmake
```

## GitHub Actions

The project includes automated builds for:
- Linux (x86, x64)
- macOS (x64, ARM64)
- FreeBSD (x64)

### Automatic Release

When you push a tag starting with 'v', GitHub Actions will:
1. Build binaries for all supported platforms
2. Create SHA256 checksums
3. Create a GitHub Release with all artifacts

Example:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Testing Builds

Every push to master/main and pull request will trigger test builds to ensure compatibility.