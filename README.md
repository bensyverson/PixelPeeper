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

# Box a region, in the coordinates that produced the image
swift run peep outline shot.png --rect 10,20,100,50 --scale 2 --out boxed.png

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

Overlays draw rulers, boxes and tags onto an image, numbered in **your** coordinates
rather than in pixels — `pixelsPerPoint` is the ratio between the two:

```swift
// A 400-point layout rendered 800 pixels wide: the ruler reads 0, 100, 200, 300.
let gridded = try shot.withGrid(GridOptions(step: 100), pixelsPerPoint: 2)

// A box drawn outside the rect, so it never covers the node's own edge pixels.
let boxed = try shot.withOutlines([
    Outline(rect: header.frame, label: "Header"),
], pixelsPerPoint: 2)
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

# Re-bless the overlay snapshot PNGs (look at the diff before committing it)
UPDATE_GOLDEN=1 swift test --filter OverlaySnapshotTests
```
