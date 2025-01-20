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

    private func parseDocument(xmlDoc: AEXMLDocument) {
        let rootFolderElements = xmlDoc.root["body"].children.filter {
            $0.attributes["xmlUrl"] == nil
        }

        rootFolderElements.forEach { folderElement in
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
                if let feed = createFeed(fromElement: feedElement) {
                    folder.feeds.append(feed)
                }
            }

            outlineFolders.append(folder)
        }
        
        let rootFeedElements = xmlDoc.root["body"].children.filter {
            $0.attributes["xmlUrl"] != nil
        }
        
        if !rootFeedElements.isEmpty {
            var otherFolder = Folder(name: "Other")
            
            rootFeedElements.forEach { feedElement in
                if let feed = createFeed(fromElement: feedElement) {
                    otherFolder.feeds.append(feed)
                }
            }
            
            outlineFolders.append(otherFolder)
        }
    }

    private func createFeed(fromElement element: AEXMLElement) -> Feed? {
        guard
            let title = element.attributes["title"],
            let xmlURLString = element.attributes["xmlUrl"],
            let xmlURL = URL(string: xmlURLString)
        else {
            return nil
        }

        var feed = Feed(title: title, url: xmlURL)

        if let previewLimit = element.attributes["den:previewLimit"] {
            feed.previewLimit = Int(previewLimit)
        }
        if let previewStyle = element.attributes["den:previewStyle"] {
            feed.previewStyle = PreviewStyle(from: previewStyle)
        }
        if let showExcerpts = element.attributes["den:showExcerpts"] {
            feed.showExcerpts = Bool(showExcerpts)
        }
        if let showBylines = element.attributes["den:showBylines"] {
            feed.showBylines = Bool(showBylines)
        }
        if let showImages = element.attributes["den:showImages"] {
            feed.showImages = Bool(showImages)
        }
        if let readerMode = element.attributes["den:useReaderAutomatically"] {
            feed.readerMode = Bool(readerMode)
        }
        if let useBlocklists = element.attributes["den:useBlocklists"] {
            feed.useBlocklists = Bool(useBlocklists)
        }
        if let allowJavaScript = element.attributes["den:allowJavaScript"] {
            feed.allowJavaScript = Bool(allowJavaScript)
        }
        
        return feed
    }
}
