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
        populateSummary()
        populateBody()
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

    private func populateSummary() {
        if let summary = jsonItem.summary {
            workingItem.summary = HTMLContent(summary).plainText()
        }
    }

    private func populateBody() {
        if let source = jsonItem.contentHtml {
            workingItem.body = source
        } else if let source = jsonItem.contentText {
            workingItem.body = source
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
