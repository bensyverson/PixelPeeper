import CoreGraphics
import Foundation
import ImageIO

public extension PixelImage {
    /// Loads an image from the given file URL and extracts its pixel data.
    ///
    /// Supports bitmap formats (PNG, JPEG, TIFF, etc.) via `CGImageSource`, and PDF
    /// via `CGPDFDocument`. For PDFs, the first page is rasterized at the given scale factor.
    /// The `scale` parameter is ignored for bitmap formats.
    ///
    /// - Parameters:
    ///   - url: The file URL of the image to load.
    ///   - scale: The scale factor for rasterizing vector formats like PDF. Defaults to 2.
    ///     Ignored for bitmap formats.
    /// - Returns: A ``PixelImage`` containing the image's pixel data.
    /// - Throws: ``PixelPeeperError/fileNotFound(path:)`` if the file does not exist,
    ///   ``PixelPeeperError/imageLoadFailed(path:reason:)`` if the file cannot be decoded,
    ///   or ``PixelPeeperError/pixelExtractionFailed(path:)`` if pixel data cannot be extracted.
    static func load(from url: URL, scale: Int = 2) throws -> PixelImage {
        let path = url.path

        guard FileManager.default.fileExists(atPath: path) else {
            throw PixelPeeperError.fileNotFound(path: path)
        }

        // Try bitmap formats first (PNG, JPEG, TIFF, etc.)
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        {
            return try extractPixels(from: cgImage, sourcePath: path)
        }

        // Fall back to PDF rendering
        if let pdfImage = try loadPDF(from: url, scale: scale) {
            return pdfImage
        }

        throw PixelPeeperError.imageLoadFailed(path: path, reason: "unable to decode image data")
    }

    /// Loads the first page of a PDF and rasterizes it at the given scale.
    ///
    /// - Parameters:
    ///   - url: The file URL of the PDF.
    ///   - scale: The scale factor for rasterization (e.g., 2 for 144 DPI).
    /// - Returns: A ``PixelImage`` if the PDF can be loaded, or `nil` if it's not a valid PDF.
    /// - Throws: ``PixelPeeperError/pixelExtractionFailed(path:)`` if rendering fails.
    private static func loadPDF(from url: URL, scale: Int) throws -> PixelImage? {
        guard let document = CGPDFDocument(url as CFURL) else {
            return nil
        }

        guard let page = document.page(at: 1) else {
            throw PixelPeeperError.imageLoadFailed(
                path: url.path,
                reason: "PDF has no pages",
            )
        }

        let mediaBox = page.getBoxRect(.mediaBox)
        let width = Int(mediaBox.width) * scale
        let height = Int(mediaBox.height) * scale
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue

        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &pixels, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: bytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo,
        ) else {
            throw PixelPeeperError.pixelExtractionFailed(path: url.path)
        }

        // Fill with white background (PDFs have transparent background by default)
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Scale and draw the PDF page
        context.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
        context.drawPDFPage(page)

        return PixelImage(width: width, height: height, pixels: pixels)
    }
}
