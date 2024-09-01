//
//  JSONItemLoader.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

import FeedKit

struct JSONItemLoader {
    static func populateItem(item: Item, itemLink: URL, jsonFeedItem: JSONFeedItem) {
        loadGeneralInfo(item: item, jsonFeedItem: jsonFeedItem)
        loadText(item: item, jsonFeedItem: jsonFeedItem)
        
        var imagePool: [PreliminaryImage] = []
        extractAttachedImages(jsonFeedItem: jsonFeedItem, itemLink: itemLink, imagePool: &imagePool)
        extractSummaryImages(jsonFeedItem: jsonFeedItem, itemLink: itemLink, imagePool: &imagePool)
        extractContentImages(jsonFeedItem: jsonFeedItem, itemLink: itemLink, imagePool: &imagePool)
        item.populateImage(imagePool: imagePool)
    }

    static private func loadGeneralInfo(
        item: Item,
        jsonFeedItem: JSONFeedItem
    ) {
        if let published = jsonFeedItem.datePublished {
            item.published = published
        }

        if let title = jsonFeedItem.title?.preparingTitle() {
            item.title = title
        }

        if let urlString = jsonFeedItem.url, let link = URL(string: urlString) {
            item.link = link
        } else if let urlString = jsonFeedItem.id, let link = URL(string: urlString) {
            item.link = link
        }

        if let author = jsonFeedItem.author?.name {
            let formattedAuthor = author.preparingTitle()
            if formattedAuthor != "" {
                item.author = formattedAuthor
            }
        }
    }

    static private func loadText(
        item: Item,
        jsonFeedItem: JSONFeedItem
    ) {
        if let summary = jsonFeedItem.summary {
            item.summary = HTMLContent(source: summary).sanitizedHTML()
        }

        if let teaser = item.summary {
            item.teaser = HTMLContent(source: teaser).plainText()?.truncated(limit: 1000)
        }

        if let contentHtml = jsonFeedItem.contentHtml {
            item.body = contentHtml
        } else if let contentText = jsonFeedItem.contentText {
            item.body = contentText
        }
    }

    static private func extractAttachedImages(
        jsonFeedItem: JSONFeedItem,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard let imageAttachments = jsonFeedItem.attachments?.filter({ attachment in
            if
                let mimeTypeString = attachment.mimeType,
                ImageMIMEType(rawValue: mimeTypeString) != nil
            {
                return true
            }
            return false
        }) else { return }
        
        for attachment in imageAttachments {
            if
                let urlString = attachment.url,
                let url = URL(string: urlString, relativeTo: itemLink)
            {
                imagePool.append(PreliminaryImage(url: url.absoluteURL))
            }
        }
    }

    static private func extractSummaryImages(
        jsonFeedItem: JSONFeedItem,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard
            let summary = jsonFeedItem.summary,
            let allowedImages = HTMLContent(source: summary).allowedImages(itemLink: itemLink)
        else { return }
        
        imagePool.append(contentsOf: allowedImages)
    }
    
    static private func extractContentImages(
        jsonFeedItem: JSONFeedItem,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard
            let html = jsonFeedItem.contentHtml,
            let allowedImages = HTMLContent(source: html).allowedImages(itemLink: itemLink)
        else { return }
        
        imagePool.append(contentsOf: allowedImages)
    }
}
