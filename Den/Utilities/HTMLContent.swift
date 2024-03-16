//
//  HTMLContent.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI

import SwiftSoup

struct HTMLContent {
    let source: String

    let imageSourceBlocklist = ["feedburner", "npr-rss-pixel", "google-analytics"]

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

        return trimmedString == "" ? nil : trimmedString
    }

    func sanitizedHTML() -> String? {
        guard
            let doc: Document = try? SwiftSoup.parseBodyFragment(source)
        else {
            return nil
        }
        
        // Add class to small images
        if let images = try? doc.getElementsByTag("img") {
            for element in images {
                guard
                    let rawWidth: String = try? element.attr("width"),
                    let rawHeight: String = try? element.attr("height"),
                    let width = Int(rawWidth),
                    let height = Int(rawHeight)
                else {
                   continue
                }
                
                if width < 200 && height < 200 {
                    _ = try? element.addClass("den-no-border")
                }
            }
        }

        return try? doc.body()?.html()
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

    func allowedImages(itemLink: URL?) -> [PreliminaryImage]? {
        guard let elements = imageElements(), !elements.isEmpty() else {
            return nil
        }

        var images: [PreliminaryImage] = []
        for el in elements {
            // Required image atrributes
            guard
                let src = try? el.attr("src"),
                let url = URL(string: src, relativeTo: itemLink)
            else {
                continue
            }

            // Check blocklist
            if imageSourceBlocklist.contains(where: src.contains) {
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
                // Width and height must be greater than thumbnail size if specified
                // to help filter hidden images
                if CGFloat(width) >= ImageSize.smallThumbnail.width
                    && CGFloat(height) >= ImageSize.smallThumbnail.height {

                    images.append(PreliminaryImage(
                        url: url.absoluteURL,
                        width: width,
                        height: height
                    ))
                }
            } else {
                images.append(PreliminaryImage(url: url.absoluteURL))
            }
        }

        return images.isEmpty ? nil : images
    }

    func customWhitelist() throws -> Whitelist {
        let whitelist: Whitelist = try .relaxed()

        try whitelist
            .addTags("figure", "figcaption", "hr")

            // Media
            .addTags("picture")

            // Embeds
            .addTags("iframe", "object", "video", "audio")
            .addAttributes("iframe", "height", "src", "srcdoc", "width", "allow")
            .addAttributes("object", "data", "height", "name", "type", "width")
            .addAttributes("video", "controls", "src", "height", "width")
            .addAttributes("audio", "controls", "src")

            // Scripts
            .addTags("script")
            .addAttributes("script", "src", "type", "charset", "async")

            // Everything
            .addAttributes(":all", "class", "dir")

        return whitelist
    }
}
