//
//  RSSItemLoader.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import FeedKit

struct RSSItemLoader {
    static func populateItem(item: Item, itemLink: URL, rssFeedItem: RSSFeedItem) {
        loadGeneralInfo(item: item, rssFeedItem: rssFeedItem)
        loadText(item: item, rssFeedItem: rssFeedItem)
        
        var imagePool: [PreliminaryImage] = []
        extractEnclosureImage(rssFeedItem: rssFeedItem, itemLink: itemLink, imagePool: &imagePool)
        if let media = rssFeedItem.media {
            MediaImageExtractor.extractImages(mediaNamespace: media, itemLink: itemLink, imagePool: &imagePool)
        }
        extractDescriptionImages(rssFeedItem: rssFeedItem, itemLink: itemLink, imagePool: &imagePool)
        extractContentImages(rssFeedItem: rssFeedItem, itemLink: itemLink, imagePool: &imagePool)
        item.populateImage(imagePool: imagePool)
    }
    
    private static func loadGeneralInfo(item: Item, rssFeedItem: RSSFeedItem) {
        // Prefer RSS pubDate element for published date
        if let published = rssFeedItem.pubDate {
            item.published = published
        } else if let published = rssFeedItem.dublinCore?.dcDate {
            // Fallback to Dublin Core metadata for published date
            // (ex. http://feeds.feedburner.com/oatmealfeed does not have pubDate)
            item.published = published
        }

        if let title = rssFeedItem.title?.preparingTitle() {
            item.title = title
        }

        item.link = rssFeedItem.linkURL

        if let author = rssFeedItem.author {
            let formattedAuthor = author.preparingTitle()
            if formattedAuthor != "" {
                item.author = formattedAuthor
            }
        } else if let author = rssFeedItem.dublinCore?.dcCreator {
            let formattedAuthor = author.preparingTitle()
            if formattedAuthor != "" {
                item.author = formattedAuthor
            }
        }
    }

    private static func loadText(item: Item, rssFeedItem: RSSFeedItem) {
        if let description = rssFeedItem.description?.htmlUnescape() {
            item.summary = HTMLContent(source: description).sanitizedHTML()
        } else if let contentEncoded = rssFeedItem.content?.contentEncoded {
            item.summary = HTMLContent(source: contentEncoded).sanitizedHTML()
        }

        if let teaser = item.summary {
            item.teaser = HTMLContent(source: teaser).plainText()?.truncated(limit: 1000)
        }

        if let source = rssFeedItem.content?.contentEncoded {
            item.body = HTMLContent(source: source).sanitizedHTML()
        }
    }

    private static func extractEnclosureImage(
        rssFeedItem: RSSFeedItem,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        if
            let enclosure = rssFeedItem.enclosure,
            let urlString = enclosure.attributes?.url,
            let url = URL(string: urlString, relativeTo: itemLink),
            let mimeType = enclosure.attributes?.type,
            ImageMIMEType(rawValue: mimeType) != nil
        {
            imagePool.append(PreliminaryImage(url: url.absoluteURL))
        }
    }

    private static func extractContentImages(
        rssFeedItem: RSSFeedItem,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard
            let html = rssFeedItem.content?.contentEncoded,
            let allowedImages = HTMLContent(source: html).allowedImages(itemLink: itemLink)
        else { return }
        
        imagePool.append(contentsOf: allowedImages)
    }

    private static func extractDescriptionImages(
        rssFeedItem: RSSFeedItem,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard
            let html = rssFeedItem.description?.htmlUnescape(),
            let allowedImages = HTMLContent(source: html).allowedImages(itemLink: itemLink)
        else {
            return
        }
        
        imagePool.append(contentsOf: allowedImages)
    }
}
