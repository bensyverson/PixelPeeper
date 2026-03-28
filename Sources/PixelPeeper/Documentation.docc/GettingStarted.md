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
