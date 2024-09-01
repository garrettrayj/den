//
//  OPMLReader.swift
//  Den
//
//  Created by Garrett Johnson on 6/13/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import OSLog
import SwiftUI

import AEXML

final class OPMLReader {
    struct Folder: Hashable {
        var name: String
        var feeds: [Feed] = []
        var icon: String?
    }

    struct Feed: Hashable {
        var title: String
        var url: URL
        var previewLimit: Int?
        var previewStyle: PreviewStyle?
        var showExcerpts: Bool?
        var showBylines: Bool?
        var showImages: Bool?
        var readerMode: Bool?
        var useBlocklists: Bool?
        var allowJavaScript: Bool?
    }

    var outlineFolders: [Folder] = []

    init(xmlURL: URL) {
        guard let data = try? Data(contentsOf: xmlURL) else { return }
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            parseDocument(xmlDoc: xmlDoc)
        } catch let error as NSError {
            Logger.main.error("Error reading OPML: \(error)")
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func parseDocument(xmlDoc: AEXMLDocument) {
        let folderElements = xmlDoc.root["body"].children

        folderElements.forEach { folderElement in
            guard
                let name = folderElement.attributes["title"] ?? folderElement.attributes["text"]
            else { return }

            var folder = Folder(name: name)

            if let icon = folderElement.attributes["den:icon"] {
                folder.icon = icon
            }

            let feeds = folderElement.allDescendants { element in
                element.attributes["xmlUrl"] != nil
            }

            feeds.forEach { feedElement in
                guard
                    let title = feedElement.attributes["title"],
                    let xmlURLString = feedElement.attributes["xmlUrl"],
                    let xmlURL = URL(string: xmlURLString)
                else {
                    return
                }

                var feed = Feed(title: title, url: xmlURL)

                if let previewLimit = feedElement.attributes["den:previewLimit"] {
                    feed.previewLimit = Int(previewLimit)
                }
                if let previewStyle = feedElement.attributes["den:previewStyle"] {
                    feed.previewStyle = PreviewStyle(from: previewStyle)
                }
                if let showExcerpts = feedElement.attributes["den:showExcerpts"] {
                    feed.showExcerpts = Bool(showExcerpts)
                }
                if let showBylines = feedElement.attributes["den:showBylines"] {
                    feed.showBylines = Bool(showBylines)
                }
                if let showImages = feedElement.attributes["den:showImages"] {
                    feed.showImages = Bool(showImages)
                }
                if let readerMode = feedElement.attributes["den:useReaderAutomatically"] {
                    feed.readerMode = Bool(readerMode)
                }
                if let useBlocklists = feedElement.attributes["den:useBlocklists"] {
                    feed.useBlocklists = Bool(useBlocklists)
                }
                if let allowJavaScript = feedElement.attributes["den:allowJavaScript"] {
                    feed.allowJavaScript = Bool(allowJavaScript)
                }

                folder.feeds.append(feed)
            }

            outlineFolders.append(folder)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
