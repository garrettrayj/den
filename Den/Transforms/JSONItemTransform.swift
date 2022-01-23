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
    var jsonItem: JSONFeedItem

    init(workingItem: WorkingItem, jsonItem: JSONFeedItem) {
        self.jsonItem = jsonItem
        super.init(workingItem: workingItem)
    }

    override func apply() {
        populateGeneralProperties()
        populateSummary()
        findAttachedImages()
        findSummaryImages()

        chooseBestPreviewImage()
    }

    private func populateGeneralProperties() {
        if let published = jsonItem.datePublished {
            workingItem.published = published
        }

        if let title = jsonItem.title {
            workingItem.title = title
                .replacingOccurrences(of: "\u{00A0}", with: " ")
                .replacingOccurrences(of: "\u{202F}", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .htmlUnescape()
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
            workingItem.summary = WorkingItemSummary(summary).plainText()
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
                if let urlString = attachment.url, let url = URL(string: urlString) {
                    images.append(WorkingItemImage(url: url))
                }
            }
        }
    }

    private func findSummaryImages() {
        if let source = jsonItem.summary {
            if let allowedImages = WorkingItemSummary(source).allowedImages() {
                images.append(contentsOf: allowedImages)
            }
        }
    }
}
