//
//  JSONItemLoad.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

import FeedKit

struct JSONItemLoad {
    let item: Item
    let source: JSONFeedItem
    
    let imageSelection = ImageSelection()

    func apply() {
        populateGeneralProperties()
        populateText()
        findAttachedImages()
        findSummaryImages()

        imageSelection.selectImage()
        item.image = imageSelection.image
        item.imageWidth = imageSelection.imageWidth ?? 0
        item.imageHeight = imageSelection.imageHeight ?? 0
    }

    private func populateGeneralProperties() {
        if let published = source.datePublished {
            item.published = published
        }

        if let title = source.title?.preparingTitle() {
            item.title = title
        } else {
            item.title = "Untitled"
        }

        if let urlString = source.url, let link = URL(string: urlString) {
            item.link = link
        } else if let urlString = source.id, let link = URL(string: urlString) {
            item.link = link
        }
    }

    private func populateText() {
        if let summary = source.summary {
            item.summary = HTMLContent(summary).sanitizedHTML()
        }

        if let teaser = item.summary {
            item.teaser = HTMLContent(teaser).plainText()?.truncated(limit: 1000)
        }

        if let contentHtml = source.contentHtml {
            item.body = contentHtml
        } else if let contentText = source.contentText {
            item.body = contentText
        }
    }

    private func findAttachedImages() {
        if
            let imageAttachments = source.attachments?.filter({ attachment in
                if
                    let mimeTypeString = attachment.mimeType,
                    ImageMIMEType(rawValue: mimeTypeString) != nil
                {
                    return true
                }
                return false
            }) {

            for attachment in imageAttachments {
                if
                    let urlString = attachment.url,
                    let url = URL(string: urlString, relativeTo: item.link)
                {
                    imageSelection.imagePool.append(RankedImage(url: url.absoluteURL))
                }
            }
        }
    }

    private func findSummaryImages() {
        if let source = source.summary {
            if let allowedImages = HTMLContent(source).allowedImages(itemLink: item.link) {
                imageSelection.imagePool.append(contentsOf: allowedImages)
            }
        }
    }
}
