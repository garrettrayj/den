//
//  ImportExportUtility.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftData

struct ImportExportUtility {
    static func importOPML(url: URL, context: ModelContext, pageUserOrderMax: Int16) {
        let opmlFolders = OPMLReader(xmlURL: url).outlineFolders

        opmlFolders.enumerated().forEach { idx, opmlFolder in
            let page = Page.create(in: context, userOrder: pageUserOrderMax + Int16(idx))
            page.name = opmlFolder.name
            page.symbol = opmlFolder.icon

            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: context, page: page, url: opmlFeed.url)
                feed.title = opmlFeed.title

                if let itemLimit = opmlFeed.previewLimit {
                    feed.wrappedItemLimit = itemLimit
                }
                if let previewStyle = opmlFeed.previewStyle {
                    feed.wrappedPreviewStyle = previewStyle
                }
                if let showExcerpts = opmlFeed.showExcerpts {
                    feed.showExcerpts = showExcerpts
                }
                if let showBylines = opmlFeed.showBylines {
                    feed.showBylines = showBylines
                }
                if let showImages = opmlFeed.showImages {
                    feed.showImages = showImages
                }
                if let readerMode = opmlFeed.readerMode {
                    feed.readerMode = readerMode
                }
                if let useBlocklists = opmlFeed.useBlocklists {
                    feed.useBlocklists = useBlocklists
                }
                if let allowJavaScript = opmlFeed.allowJavaScript {
                    feed.allowJavaScript = allowJavaScript
                }
            }
        }

        do {
            try context.save()
        } catch let error as NSError {
            CrashUtility.handleCriticalError(error)
        }
    }

    static func exportOPML(pages: [Page]) -> OPMLFile? {
        if let data = OPMLGenerator(title: "Den Export", pages: pages).getData() {
            return OPMLFile(initialData: data)
        }

        return nil
    }
}
