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

final class OPMLGenerator {
    let title: String
    let pages: [Page]

    init(title: String, pages: [Page]) {
        self.title = title
        self.pages = pages
    }
    
    var document: AEXMLDocument {
        let document = AEXMLDocument()
        let root = document.addChild(name: "opml", attributes: ["version": "1.0"])

        let head = root.addChild(name: "head")
        head.addChild(name: "title", value: title)

        let body = root.addChild(name: "body")
        pages.forEach { page in
            let outline = body.addChild(
                name: "outline",
                attributes: ["text": page.name ?? "Untitled", "title": page.name ?? "Untitled"]
            )
            page.feedsArray.forEach { feed in
                let attributes = [
                    "text": feed.wrappedTitle,
                    "title": feed.wrappedTitle,
                    "type": "rss",
                    "xmlUrl": feed.urlString
                ]
                outline.addChild(name: "outline", attributes: attributes)
            }
        }
        
        return document
    }
    
    func getData() -> Data? {
        document.xml.data(using: .utf8)
    }

    func writeToFile(url: URL) {
        do {
            try document.xml.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions,
            // or more likely it can't be converted to the encoding
            Logger.main.error("""
            Failed to write OPML file – bad permissions, bad filename, missing permissions, \
            or more likely it can't be converted to the encoding.
            """)
        }
    }
}
