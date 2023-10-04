//
//  JSONItemLoad.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
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
        }

        if let urlString = source.url, let link = URL(string: urlString) {
            item.link = link
        } else if let urlString = source.id, let link = URL(string: urlString) {
            item.link = link
        }

        if let author = source.author?.name {
            let formattedAuthor = author.preparingTitle()
            if formattedAuthor != "" {
                item.author = formattedAuthor
            }
        }
    }

    private func populateText() {
        if let summary = item.summary {
            item.teaser = HTMLContent(source: summary).plainText()?.truncated(limit: 1000)
        } else if let contentHtml = source.contentHtml {
            item.teaser = HTMLContent(source: contentHtml).plainText()?.truncated(limit: 1000)
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
        if let summary = source.summary {
            if let allowedImages = HTMLContent(source: summary).allowedImages(itemLink: item.link) {
                imageSelection.imagePool.append(contentsOf: allowedImages)
            }
        }
    }
}
