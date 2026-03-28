# PixelPeeper

A Swift library and CLI tool for computing Mean Absolute Error (MAE) between two images.

## Quick Start

### CLI

```bash
# Compare two images
swift run peep compare before.png after.png

# JSON output
swift run peep compare before.png after.png --format json

# Resize on dimension mismatch (e.g., 1x vs 2x)
swift run peep compare image-1x.png image-2x.png --resize

# CI threshold — exits non-zero if MAE > 5.0
swift run peep compare expected.png actual.png --threshold 5.0

# Sample pixel color at coordinates (0-indexed from top-left)
swift run peep sample photo.png 10 20

# Sample with different output formats
swift run peep sample photo.png 10 20 --format text
swift run peep sample photo.png 10 20 --format json
```

### Library

```swift
import PixelPeeper

let image1 = try PixelImage.load(from: url1)
let image2 = try PixelImage.load(from: url2)
let result = try ImageComparator.compare(image1, image2)

print("MAE: \(result.mae)")  // 0–100 scale
```

## Documentation

- [Getting Started](Sources/PixelPeeper/Documentation.docc/GettingStarted.md) — Installation, usage, and MAE score interpretation
- [API Reference](Sources/PixelPeeper/Documentation.docc/PixelPeeper.md) — Full API documentation

Generate DocC documentation locally:

```bash
swift package generate-documentation --target PixelPeeper
```

## Development

```bash
# Run tests
swift test

# Lint
swiftformat . --lint

# Regenerate test fixtures
swift scripts/generate-fixtures.swift
```
