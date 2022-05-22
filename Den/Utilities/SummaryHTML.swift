//
//  WorkingItemSummary.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SwiftSoup

final class SummaryHTML {
    let imageSrcBlockList = ["feedburner", "npr-rss-pixel", "google-analytics"]
    let source: String

    init(_ source: String) {
        self.source = source
    }

    func plainText() -> String? {
        guard
            let doc: Document = try? SwiftSoup.parseBodyFragment(source),
            let plainText = try? doc.text()
        else {
            return nil
        }

        let trimmedString = plainText
            .replacingOccurrences(of: "\u{00A0}", with: " ") // NO-BREAK SPACE
            .replacingOccurrences(of: "\u{202F}", with: " ") // NARROW NO-BREAK SPACE
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .truncated(limit: 2000)

        return trimmedString == "" ? nil : trimmedString
    }

    func imageElements() -> Elements? {
        guard
            let doc: Document = try? SwiftSoup.parseBodyFragment(source),
            let elements = try? doc.select("img")
        else {
            return nil
        }

        return elements
    }

    func allowedImages(itemLink: URL?) -> [RankedImage]? {
        guard let elements = imageElements(), !elements.isEmpty() else {
            return nil
        }

        var images: [RankedImage] = []
        for el in elements {
            // Requirement image atrributes
            guard
                let src = try? el.attr("src"),
                let url = URL(string: src, relativeTo: itemLink)
            else {
                continue
            }

            // Check blocklist
            if imageSrcBlockList.contains(where: src.contains) {
                continue
            }

            // Exclude based on MIME type (if attribute is available)
            if
                let mimeType = try? el.attr("type"),
                mimeType != "",
                ImageMIMEType(rawValue: mimeType) == nil
            {
                continue
            }

            if
                let width = try? Int(el.attr("width")),
                let height = try? Int(el.attr("height"))
            {
                if CGFloat(width) >= ImageSize.thumbnail.width
                    && CGFloat(height) >= ImageSize.thumbnail.height {

                    images.append(RankedImage(
                        url: url.absoluteURL,
                        rank: width * height,
                        width: width,
                        height: height
                    ))
                }
            } else {
                images.append(RankedImage(url: url.absoluteURL))
            }
        }

        return images.isEmpty ? nil : images
    }
}
