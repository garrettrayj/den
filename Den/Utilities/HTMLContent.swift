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

final class HTMLContent {
    let imageSourceBlocklist = ["feedburner", "npr-rss-pixel", "google-analytics"]
    let content: String

    init(_ source: String) {
        self.content = source
    }

    func plainText() -> String? {
        guard
            let doc: Document = try? SwiftSoup.parseBodyFragment(content),
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
            let dirty: Document = try? SwiftSoup.parseBodyFragment(content),
            let doc: Document = try? Cleaner(customWhitelist()).clean(dirty)
        else {
            return nil
        }

        // Apply <iframe> scaling fix
        do {
            for element in try doc.getElementsByTag("iframe") {
                let width: String? = try? element.attr("width")
                let height: String? = try? element.attr("height")
                try element.attr("style", "aspect-ratio: \(width ?? "16") / \(height ?? "9");")
            }
        } catch {
            Logger.main.error("HTML sanitization error: \(error)")
        }

        return try? doc.body()?.html()
    }

    func imageElements() -> Elements? {
        guard
            let doc: Document = try? SwiftSoup.parseBodyFragment(content),
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
                if CGFloat(width) >= ItemThumbnailView.baseSize.width
                    && CGFloat(height) >= ItemThumbnailView.baseSize.height {

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

    func customWhitelist() throws -> Whitelist {
        let whitelist: Whitelist = try .relaxed()

        try whitelist
            .addTags("figure", "figcaption", "hr")

            // Media
            .addTags("picture", "source")
            .addAttributes("source", "srcset", "media", "src", "type")

            // Embeds
            .addTags("iframe", "object", "video", "audio")
            .addAttributes("iframe", "height", "src", "srcdoc", "width", "allow")
            .addAttributes("object", "data", "height", "name", "type", "width")
            .addAttributes("video", "controls", "src", "height", "width")
            .addAttributes("audio", "controls", "src")

            // Scripts
            .addTags("script")
            .addAttributes("script", "src", "type", "charset", "async")

            // Misc
            .addAttributes(":all", "class", "id")

        return whitelist
    }
}
