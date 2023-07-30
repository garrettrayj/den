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
            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: context, page: page, url: opmlFeed.url)
                feed.title = opmlFeed.title
            }
        }

        do {
            try context.save()
        } catch let error as NSError {
            CrashUtility.handleCriticalError(error)
        }
    }

    static func exportOPML(profile: Profile) -> OPMLFile? {
        let generator = OPMLGenerator(title: profile.exportTitle, pages: profile.pagesArray)
        return OPMLFile(initialData: generator.getData() ?? Data())
    }
}
