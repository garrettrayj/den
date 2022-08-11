//
//  JSONItemTransform.swift
//  Den
//
//  Created by Garrett Johnson on 1/23/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation
import FeedKit

final class JSONItemTransform: ItemTransform {
    let jsonItem: JSONFeedItem

    init(workingItem: WorkingItem, jsonItem: JSONFeedItem) {
        self.jsonItem = jsonItem
        super.init(workingItem: workingItem)
    }

    override func apply() {
        populateGeneralProperties()
        populateText()
        findAttachedImages()
        findSummaryImages()

        workingItem.selectImage()
    }

    private func populateGeneralProperties() {
        if let published = jsonItem.datePublished {
            workingItem.published = published
        }

        if let title = jsonItem.title?.preparingTitle() {
            workingItem.title = title
        } else {
            workingItem.title = "Untitled"
        }

        if let urlString = jsonItem.url, let link = URL(string: urlString) {
            workingItem.link = link
        } else if let urlString = jsonItem.id, let link = URL(string: urlString) {
            workingItem.link = link
        }
    }

    private func populateText() {
        if let summary = jsonItem.summary {
            workingItem.summary = HTMLContent(summary).sanitizedHTML()
        }

        if let teaser = workingItem.summary {
            workingItem.teaser = HTMLContent(teaser).plainText()?.truncated(limit: 1000)
        }

        if let contentHtml = jsonItem.contentHtml {
            workingItem.body = contentHtml
        } else if let contentText = jsonItem.contentText {
            workingItem.body = contentText
        }
    }

    private func findAttachedImages() {
        if
            let imageAttachments = jsonItem.attachments?.filter({ attachment in
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
                    let url = URL(string: urlString, relativeTo: workingItem.link)
                {
                    workingItem.imagePool.append(RankedImage(url: url.absoluteURL))
                }
            }
        }
    }

    private func findSummaryImages() {
        if let source = jsonItem.summary {
            if let allowedImages = HTMLContent(source).allowedImages(itemLink: workingItem.link) {
                workingItem.imagePool.append(contentsOf: allowedImages)
            }
        }
    }
}
