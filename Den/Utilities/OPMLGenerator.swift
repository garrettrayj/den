//
//  OPMLGenerator.swift
//  Den
//
//  Created by Garrett Johnson on 6/28/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI

import AEXML

struct OPMLGenerator {
    let title: String
    let pages: [Page]

    var document: AEXMLDocument {
        let document = AEXMLDocument()
        let root = document.addChild(
            name: "opml",
            attributes: ["version": "1.0", "xmlns:den": "https://den.io/xml/opml"]
        )

        let head = root.addChild(name: "head")
        head.addChild(name: "title", value: title)

        let body = root.addChild(name: "body")
        pages.forEach { page in
            let pageOutline = body.addChild(
                name: "outline",
                attributes: [
                    "text": page.wrappedName,
                    "title": page.wrappedName,
                    "den:icon": page.wrappedSymbol
                ]
            )
            page.feedsArray.forEach { feed in
                let attributes = [
                    "text": feed.wrappedTitle,
                    "title": feed.wrappedTitle,
                    "type": feed.feedData?.format?.lowercased() ?? "rss",
                    "xmlUrl": feed.urlString,
                    "den:previewLimit": String(feed.wrappedItemLimit),
                    "den:previewStyle": feed.wrappedPreviewStyle.stringRepresentation,
                    "den:showTeasers": String(feed.showExcerpts),
                    "den:showBylines": String(feed.showBylines),
                    "den:showImages": String(feed.showImages),
                    "den:useReaderAutomatically": String(feed.readerMode),
                    "den:useBlocklists": String(feed.useBlocklists),
                    "den:allowJavaScript": String(feed.allowJavaScript)
                ]
                pageOutline.addChild(name: "outline", attributes: attributes)
            }
        }

        return document
    }

    func getData() -> Data? {
        document.xml.data(using: .utf8)
    }
}
