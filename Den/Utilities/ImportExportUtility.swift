//
//  ImportExportUtility.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

struct ImportExportUtility {
    static func importOPML(url: URL, context: NSManagedObjectContext, profile: Profile) {
        let opmlFolders = OPMLReader(xmlURL: url).outlineFolders

        opmlFolders.forEach { opmlFolder in
            let page = Page.create(in: context, profile: profile)
            page.name = opmlFolder.name
            page.symbol = opmlFolder.icon

            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: context, page: page, url: opmlFeed.url)
                feed.title = opmlFeed.title

                if let itemLimit = opmlFeed.previewLimit {
                    feed.wrappedItemLimit = itemLimit
                }
                if let browserView = opmlFeed.openInBrowser {
                    feed.browserView = browserView
                }
                if let readerMode = opmlFeed.readerMode {
                    feed.readerMode = readerMode
                }
                if let previewStyle = opmlFeed.previewStyle {
                    feed.wrappedPreviewStyle = previewStyle
                }
                if let hideTeasers = opmlFeed.hideTeasers {
                    feed.hideTeasers = hideTeasers
                }
                if let hideBylines = opmlFeed.hideBylines {
                    feed.hideBylines = hideBylines
                }
                if let hideImages = opmlFeed.hideImages {
                    feed.hideImages = hideImages
                }
            }
        }

        do {
            try context.save()
        } catch let error as NSError {
            CrashUtility.handleCriticalError(error)
        }
    }

    static func exportOPML(profile: Profile) -> OPMLFile? {
        if let data = OPMLGenerator(title: profile.exportTitle, pages: profile.pagesArray).getData() {
            return OPMLFile(initialData: data)
        }
        
        return nil
    }
}
