#!/usr/bin/env swift

// Generates small test fixture PNGs with known pixel values.
// Usage: swift scripts/generate-fixtures.swift
//
// Output directory: Tests/PixelPeeperTests/Fixtures/

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let fixturesDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Tests/PixelPeeperTests/Fixtures")

try FileManager.default.createDirectory(at: fixturesDir, withIntermediateDirectories: true)

struct FixtureSpec {
    let name: String
    let width: Int
    let height: Int
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8
}

let fixtures: [FixtureSpec] = [
    FixtureSpec(name: "red-2x2", width: 2, height: 2, red: 255, green: 0, blue: 0, alpha: 255),
    FixtureSpec(name: "blue-2x2", width: 2, height: 2, red: 0, green: 0, blue: 255, alpha: 255),
    FixtureSpec(name: "black-2x2", width: 2, height: 2, red: 0, green: 0, blue: 0, alpha: 255),
    FixtureSpec(name: "white-2x2", width: 2, height: 2, red: 255, green: 255, blue: 255, alpha: 255),
    FixtureSpec(name: "red-3x3", width: 3, height: 3, red: 255, green: 0, blue: 0, alpha: 255),
]

for spec in fixtures {
    let pixelCount = spec.width * spec.height
    var pixels = [UInt8](repeating: 0, count: pixelCount * 4)

    for i in 0 ..< pixelCount {
        pixels[i * 4 + 0] = spec.red
        pixels[i * 4 + 1] = spec.green
        pixels[i * 4 + 2] = spec.blue
        pixels[i * 4 + 3] = spec.alpha
    }

    let bpr = spec.width * 4
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        | CGBitmapInfo.byteOrder32Big.rawValue

    guard let ctx = CGContext(
        data: &pixels, width: spec.width, height: spec.height,
        bitsPerComponent: 8, bytesPerRow: bpr,
        space: colorSpace, bitmapInfo: bitmapInfo
    ) else {
        print("Failed to create context for \(spec.name)")
        continue
    }

    guard let image = ctx.makeImage() else {
        print("Failed to create image for \(spec.name)")
        continue
    }

    let url = fixturesDir.appendingPathComponent("\(spec.name).png")
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("Failed to create destination for \(spec.name)")
        continue
    }

    CGImageDestinationAddImage(dest, image, nil)

    if CGImageDestinationFinalize(dest) {
        print("Generated \(spec.name).png (\(spec.width)×\(spec.height))")
    } else {
        print("Failed to write \(spec.name).png")
    }
}
