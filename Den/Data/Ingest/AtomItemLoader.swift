//
//  AtomItemLoader.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import FeedKit

struct AtomItemLoader {
    static func populateItem(item: Item, itemLink: URL, atomFeedEntry: AtomFeedEntry) {
        loadGeneralInfo(item: item, atomFeedEntry: atomFeedEntry)
        loadText(item: item, atomFeedEntry: atomFeedEntry)
        
        var imagePool: [PreliminaryImage] = []
        extractEnclosureImage(atomFeedEntry: atomFeedEntry, itemLink: itemLink, imagePool: &imagePool)
        if let media = atomFeedEntry.media {
            MediaImageExtractor.extractImages(mediaNamespace: media, itemLink: itemLink, imagePool: &imagePool)
        }
        extractSummaryImages(atomFeedEntry: atomFeedEntry, itemLink: itemLink, imagePool: &imagePool)
        extractContentImages(atomFeedEntry: atomFeedEntry, itemLink: itemLink, imagePool: &imagePool)
        item.populateImage(imagePool: imagePool)
    }

    static private func loadGeneralInfo(
        item: Item,
        atomFeedEntry: AtomFeedEntry
    ) {
        item.link = atomFeedEntry.linkURL

        if let published = atomFeedEntry.published {
            item.published = published
        } else if let published = atomFeedEntry.updated {
            item.published = published
        }

        if let title = atomFeedEntry.title?.preparingTitle() {
            item.title = title
        }

        if let author = atomFeedEntry.authors?.first?.name {
            let formattedAuthor = author.preparingTitle()
            if formattedAuthor != "" {
                item.author = formattedAuthor
            }
        }
    }

    static private func loadText(
        item: Item,
        atomFeedEntry: AtomFeedEntry
    ) {
        if let summary = atomFeedEntry.summary?.value?.htmlUnescape() {
            item.summary = HTMLContent(source: summary).sanitizedHTML()
        } else if let summary = atomFeedEntry.content?.value?.htmlUnescape() {
            item.summary = HTMLContent(source: summary).sanitizedHTML()
        }

        if let teaser = item.summary {
            item.teaser = HTMLContent(source: teaser).plainText()?.truncated(limit: 1000)
        }

        if let body = atomFeedEntry.content?.value {
            item.body = HTMLContent(source: body).sanitizedHTML()
        }
    }

    static private func extractEnclosureImage(
        atomFeedEntry: AtomFeedEntry,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard
            let link = atomFeedEntry.links?.first(where: { link in
                link.attributes?.rel == "enclosure"
            }),
            let urlString = link.attributes?.href,
            let url = URL(string: urlString, relativeTo: itemLink),
            let mimeType = link.attributes?.type,
            ImageMIMEType(rawValue: mimeType) != nil
        else { return }
            
        imagePool.append(PreliminaryImage(url: url.absoluteURL))
    }

    private static func extractContentImages(
        atomFeedEntry: AtomFeedEntry,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard
            let html = atomFeedEntry.content?.value?.htmlUnescape(),
            let allowedImages = HTMLContent(source: html).allowedImages(itemLink: itemLink)
        else { return }
        
        imagePool.append(contentsOf: allowedImages)
    }

    private static func extractSummaryImages(
        atomFeedEntry: AtomFeedEntry,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard
            let html = atomFeedEntry.summary?.value?.htmlUnescape(),
            let allowedImages = HTMLContent(source: html).allowedImages(itemLink: itemLink)
        else { return }
        
        imagePool.append(contentsOf: allowedImages)
    }
}
