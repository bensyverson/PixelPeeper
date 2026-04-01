# Getting Started with PixelPeeper

Learn how to compare images using PixelPeeper.

## Overview

PixelPeeper provides two ways to compare images: the Swift library for programmatic use,
and the `peep` command-line tool for quick comparisons and CI integration.

## Using the Library

Add PixelPeeper to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/PixelPeeper", from: "1.0.0"),
]
```

Then import and use it:

```swift
import PixelPeeper

let image1 = try PixelImage.load(from: URL(fileURLWithPath: "before.png"))
let image2 = try PixelImage.load(from: URL(fileURLWithPath: "after.png"))

let result = try ImageComparator.compare(image1, image2)

print("Overall MAE: \(result.mae)")
print("Red: \(result.red), Green: \(result.green)")
print("Blue: \(result.blue), Alpha: \(result.alpha)")
```

### Handling Dimension Mismatches

By default, comparing images with different dimensions throws an error. To automatically
resize the larger image to match the smaller one:

```swift
let options = ComparisonOptions(dimensionMismatch: .resizeToSmallest)
let result = try ImageComparator.compare(image1, image2, options: options)
```

## Using the CLI

The `peep` command compares two images from the terminal:

```bash
# Basic comparison
peep before.png after.png

# JSON output for scripting
peep before.png after.png --json

# Resize on dimension mismatch
peep image-1x.png image-2x.png --resize

# CI threshold — exits non-zero if MAE exceeds 5.0
peep expected.png actual.png --threshold 5.0
```

### Cropping

Extract a region from an image:

```bash
# Crop a 100×50 region starting at (10, 20)
peep crop image.png --x 10 --y 20 --width 100 --height 50 --output cropped.png

# Apply an inset to shrink the crop region
peep crop image.png --x 10 --y 20 --width 100 --height 50 --inset 5 --output cropped.png
```

### Line Sampling

Sample pixel colors along a line between two points:

```bash
# Sample 10 points along a diagonal
peep linesample image.png --x1 0 --y1 0 --x2 100 --y2 50 --steps 10

# JSON output
peep linesample image.png --x1 0 --y1 0 --x2 100 --y2 50 --steps 10 --format json
```

### Grid Overlay

Draw a grid over an image for visual alignment:

```bash
# Red grid with 10px spacing
peep grid image.png --spacing 10 --output grid.png

# Custom color
peep grid image.png --spacing 20 --color "#00ff00" --output grid.png
```

### Visual Diff

Generate a visual diff highlighting pixel differences between two images:

```bash
# Basic diff
peep diff before.png after.png --output diff.png

# Amplify differences with intensity multiplier
peep diff before.png after.png --output diff.png --intensity 3.0

# Resize to match dimensions
peep diff image-1x.png image-2x.png --output diff.png --resize
```

## Understanding MAE Scores

MAE scores range from 0 to 100:

| Score | Meaning |
|-------|---------|
| 0 | Identical images |
| 0–1 | Near-perfect match |
| 1–5 | Excellent match with minor differences |
| 5–15 | Noticeable differences |
| 15–50 | Significant differences |
| 50–100 | Substantially or completely different |
