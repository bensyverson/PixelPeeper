# ``PixelPeeper``

A Swift library for computing Mean Absolute Error (MAE) between two images.

## Overview

PixelPeeper loads images, extracts their pixel data into a standardized sRGB RGBA format,
and computes the Mean Absolute Error between them on a 0–100 scale. It provides both an
overall MAE score and per-channel breakdowns (red, green, blue, alpha).

Supports bitmap formats (PNG, JPEG, TIFF, etc.) and PDF. PDFs are rasterized at a
configurable scale factor (default 2x).

The library is designed for use cases like visual regression testing, CI pipelines,
and image comparison tooling.

```swift
let image1 = try PixelImage.load(from: url1)
let image2 = try PixelImage.load(from: url2)
let result = try ImageComparator.compare(image1, image2)
print("MAE: \(result.mae)") // 0.0 = identical, 100.0 = maximally different
```

## Topics

### Comparing Images

- ``ImageComparator``
- ``ImageComparisonResult``
- ``ComparisonOptions``

### Loading Images

- ``PixelImage``

### Pixel Colors

- ``PixelColor``

### Errors

- ``PixelPeeperError``

### Utilities

- ``Friendly``
