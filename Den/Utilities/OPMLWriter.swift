//
//  OPMLWriter.swift
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

final class OPMLWriter {
    private var pages: [Page]

    init(pages: [Page]) {
        self.pages = pages
    }

    func writeToFile() -> URL {
        let opmlDocument = AEXMLDocument()
        let root = opmlDocument.addChild(name: "opml", attributes: ["version": "1.0"])

        let head = root.addChild(name: "head")
        head.addChild(name: "title", value: "Den Export")

        let body = root.addChild(name: "body")
        pages.forEach { page in
            let outline = body.addChild(
                name: "outline",
                attributes: ["text": page.wrappedName, "title": page.wrappedName]
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

        let fileDate = Date().formatted(date: .abbreviated, time: .omitted).sanitizedForFileName()
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFilename = ("Den Export " + fileDate)
        let temporaryFileUrl = temporaryDirectoryURL
            .appendingPathComponent(temporaryFilename)
            .appendingPathExtension("opml")

        do {
            try opmlDocument.xml.write(to: temporaryFileUrl, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions,
            // or more likely it can't be converted to the encoding
            Logger.main.error("""
            Failed to write OPML file – bad permissions, bad filename, missing permissions, \
            or more likely it can't be converted to the encoding.
            """)
        }

        return temporaryFileUrl
    }
}
