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
    }

    struct Feed: Hashable {
        var title: String
        var url: URL
    }

    let xmlURL: URL
    let data: Data?

    var outlineFolders: [Folder] = []

    init(xmlURL: URL) {
        self.xmlURL = xmlURL
        self.data = try? Data(contentsOf: xmlURL)

        // Populate outline with XML data
        guard let data = data else { return }
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            parseDocument(xmlDoc: xmlDoc)
        } catch let error as NSError {
            Logger.main.error("Error reading OPML: \(error)")
        }
    }

    private func parseDocument(xmlDoc: AEXMLDocument) {
        let folders = xmlDoc.root["body"].allDescendants { element in
            (element.attributes["title"] != nil || element.attributes["text"] != nil)
            && element.attributes["xmlUrl"] == nil
        }

        folders.forEach { folderElement in
            guard
                let name = folderElement.attributes["title"] ?? folderElement.attributes["text"]
            else { return }

            var opmlFolder = Folder(name: name)
            let feeds = folderElement.allDescendants { element in
                element.attributes["xmlUrl"] != nil
            }

            feeds.forEach({ feedElement in
                guard
                    let title = feedElement.attributes["title"],
                    let xmlURLString = feedElement.attributes["xmlUrl"],
                    let xmlURL = URL(string: xmlURLString)
                else {
                    return
                }

                let feed = Feed(title: title, url: xmlURL)
                opmlFolder.feeds.append(feed)
            })

            outlineFolders.append(opmlFolder)
        }
    }
}
