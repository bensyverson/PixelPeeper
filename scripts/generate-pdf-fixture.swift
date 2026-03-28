#!/usr/bin/env swift

// Generates a small test PDF fixture with a known solid color fill.
// Usage: swift scripts/generate-pdf-fixture.swift
//
// Output: Tests/PixelPeeperTests/Fixtures/red-100x100.pdf

import CoreGraphics
import Foundation

let fixturesDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Tests/PixelPeeperTests/Fixtures")

try FileManager.default.createDirectory(at: fixturesDir, withIntermediateDirectories: true)

let url = fixturesDir.appendingPathComponent("red-100x100.pdf")
let pageRect = CGRect(x: 0, y: 0, width: 100, height: 100)

guard let context = CGContext(url as CFURL, mediaBox: nil, nil) else {
    print("Failed to create PDF context")
    exit(1)
}

var mediaBox = pageRect
context.beginPage(mediaBox: &mediaBox)
context.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
context.fill(pageRect)
context.endPage()
context.closePDF()

print("Generated red-100x100.pdf (100×100 pt)")
