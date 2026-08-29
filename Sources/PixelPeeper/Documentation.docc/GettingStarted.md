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

## Drawing Overlays

An overlay answers "where is this, in *my* coordinates?" — the question a screenshot
cannot answer on its own. Every overlay takes `pixelsPerPoint`, the ratio between image
pixels and whatever units the caller thinks in (layout points, CSS px), and an optional
`origin`, the source coordinate of the image's top-left pixel when the image is a crop.
Labels are always printed in source units.

```swift
// A 400-point layout rendered 800 pixels wide.
let shot = try PixelImage.load(from: url)

// Rulers in a gutter, numbered 0, 100, 200, 300 — not 0, 200, 400, 600.
let gridded = try shot.withGrid(GridOptions(step: 100), pixelsPerPoint: 2)

// A box around a node's layout rect, drawn outside it so the node's own edge shows.
let boxed = try shot.withOutlines([
    Outline(rect: header.frame, label: "Header"),
], pixelsPerPoint: 2)

// A free-standing tag, for a landmark that is not a rectangle.
let marked = try shot.withLabels([
    OverlayLabel(text: "click", position: CGPoint(x: 120, y: 64)),
], pixelsPerPoint: 2)
```

Draw the grid **last**, after any resizing: the gutter is chrome, and fitting it down
with the image makes the numbers unreadable. In ``GridOptions/Mode/rulers`` the image's
own pixels come through byte for byte, so a gridded capture can still be diffed.

``PixelImage/withGridOverlay(spacing:color:)`` is a different, older thing: an unlabelled
grid measured in image pixels. Reach for ``PixelImage/withGrid(_:pixelsPerPoint:origin:)``
when you want numbers.

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

### Outlines

Box a region of an image, in the coordinates that produced it:

```bash
# A box around 10,20 100×50 in source units, on an image rendered at 2 px per unit
peep outline shot.png --rect 10,20,100,50 --scale 2 --out boxed.png

# Several boxes, named, in a colour of your choosing
peep outline shot.png \
  --rect 0,0,320,64 --label Header \
  --rect 0,64,320,400 --label Body \
  --color "#ff00aa" --scale 2 --out boxed.png
```

`--scale` is image pixels per source unit. `--raster-scale` is the separate knob for
rasterizing a PDF input.

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
