# ``PixelPeeper``

A Swift library for computing Mean Absolute Error (MAE) between two images.

## Overview

PixelPeeper loads images, extracts their pixel data into a standardized sRGB RGBA format,
and computes the Mean Absolute Error between them. It provides an overall MAE score in
8-bit channel steps (0–255, ``ImageComparisonResult/maeSteps``), and on a 0–100 scale
both overall and per channel (red, green, blue, alpha).

Supports bitmap formats (PNG, JPEG, TIFF, etc.) and PDF. PDFs are rasterized at a
configurable scale factor (default 2x).

It also draws *overlays*: labelled rulers, boxes and tags burned onto an image in the
caller's own coordinates, so an agent or a reviewer reading a screenshot can name a
position instead of estimating one.

The library is designed for use cases like visual regression testing, CI pipelines,
and image comparison tooling.

```swift
let image1 = try PixelImage.load(from: url1)
let image2 = try PixelImage.load(from: url2)
let result = try ImageComparator.compare(image1, image2)
print("MAE: \(result.maeSteps)") // "0.0 steps" = identical, "255.0 steps" = maximally different
print("MAE: \(result.mae)")      // the same on a 0–100 scale
```

## Topics

### Comparing Images

- ``ImageComparator``
- ``ImageComparisonResult``
- ``EightBitSteps``
- ``ComparisonOptions``

### Loading Images

- ``PixelImage``
- ``PixelImage/init(cgImage:)``
- ``PixelImage/init(cgImage:width:height:)``

### Overlays

- ``PixelImage/withGrid(_:pixelsPerPoint:origin:)``
- ``PixelImage/withOutlines(_:pixelsPerPoint:origin:)``
- ``PixelImage/withLabels(_:pixelsPerPoint:origin:)``
- ``GridOptions``
- ``GridLayout``
- ``Outline``
- ``OverlayLabel``

### Pixel Colors

- ``PixelColor``

### Sampling

- ``LineSample``

### Errors

- ``PixelPeeperError``

### Utilities

- ``Friendly``
