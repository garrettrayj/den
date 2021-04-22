//
//  WorkingFeedItem.swift
//  Den
//
//  Created by Garrett Johnson on 4/3/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import FeedKit
import OSLog

/**
 Item entity representation for working with data outside of NSManagedObjectContext (e.g. feed ingest operations)
 */
class WorkingFeedItem {
    var id: UUID?
    var image: URL?
    var imageLocal: URL?
    var ingested: Date?
    var link: URL?
    var published: Date?
    var summary: String?
    var title: String?    

    public func ingest(_ atomEntry: AtomFeedEntry) {
        if let published = atomEntry.published {
            self.published = published
        } else {
            if let published = atomEntry.updated {
                self.published = published
            }
        }
        
        if let title = atomEntry.title {
            self.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            self.title = "Untitled"
        }
        
        self.link = atomEntry.linkURL
        
        // Look for preview image in <links> and <media:content>
        if
            let imageLink = atomEntry.links?.first(where: { link in
                link.attributes?.rel == "enclosure"
            }),
            let imageURLString = imageLink.attributes?.href,
            let imageURL = URL(string: imageURLString)
        {
            if
                let linkMimeType = imageLink.attributes?.type,
                MIMETypes.ImageMIMETypes(rawValue: linkMimeType) == nil
            {
                // Incompatible MIME type
            } else {
                self.image = imageURL
            }
        } else if
            let media = atomEntry.media,
            let imageMediaContent = media.mediaContents?.first,
            let mediaURLString = imageMediaContent.attributes?.url,
            let mediaURL = URL(string: mediaURLString)
        {
            if
                let mediaMimeType = imageMediaContent.attributes?.type,
                MIMETypes.ImageMIMETypes(rawValue: mediaMimeType) == nil
            {
                // Incompatible MIME type
            } else {
                self.image = mediaURL
            }
        } else if
            let mediaThumbnails = atomEntry.media?.mediaThumbnails?.sorted(by: { a, b in
                guard
                    let aWidthString = a.attributes?.width,
                    let aWidth = Int(aWidthString),
                    let bWidthString = b.attributes?.width,
                    let bWidth = Int(bWidthString)
                else {
                    return false
                }
                
                return bWidth > aWidth
            }),
            let thumbnail = mediaThumbnails.first,
            let thumbnailURLString = thumbnail.attributes?.url,
            let thumbnailURL = URL(string: thumbnailURLString)
        {
            self.image = thumbnailURL
        }
        
        if let summary = atomEntry.summary?.value?.htmlUnescape() {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: summary)
            self.summary = plainSummary
            if self.image == nil && image != nil {
                self.image = image
            }
        }
        
        if let body = atomEntry.content?.value?.htmlUnescape() {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: body)
            if self.summary == nil {
                self.summary = plainSummary
            }
            if self.image == nil {
                self.image = image
            }
        }
        
        if self.image != nil {
            self.imageLocal = self.createLocalImagePath()
        }
    }
    
    /**
     Creates item entity from a RSS feed item
     */
    public func ingest(_ rssItem: RSSFeedItem) {
        // Prefer RSS pubDate element for published date
        if let published = rssItem.pubDate {
            self.published = published
        } else {
            // Fallback to Dublin Core metadata for published date (ex. http://feeds.feedburner.com/oatmealfeed does not have pubDate)
            if let published = rssItem.dublinCore?.dcDate {
                self.published = published
            }
        }
        
        if let title = rssItem.title {
            self.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            self.title = "Untitled"
        }

        self.link = rssItem.linkURL
        
        // Look for preview image in <enclosure> and <media:content>
        if
            let enclosure = rssItem.enclosure,
            let mimeTypeString = enclosure.attributes?.type,
            let _ = MIMETypes.ImageMIMETypes(rawValue: mimeTypeString),
            let enclosureURLString = enclosure.attributes?.url,
            let enclosureURL = URL(string: enclosureURLString)
        {
            self.image = enclosureURL
        } else if
            let media = rssItem.media,
            let imageMediaContent = media.mediaContents?.first,
            let mediaURLString = imageMediaContent.attributes?.url,
            let mediaURL = URL(string: mediaURLString)
        {
            if
                let mediaMimeType = imageMediaContent.attributes?.type,
                MIMETypes.ImageMIMETypes(rawValue: mediaMimeType) == nil
            {
                // Incompatible MIME type
            } else {
                self.image = mediaURL
            }
        } else if
            let media = rssItem.media?.mediaGroup,
            let imageMediaContent = media.mediaContents?.first,
            let mediaURLString = imageMediaContent.attributes?.url,
            let mediaURL = URL(string: mediaURLString)
        {
            if
                let mediaMimeType = imageMediaContent.attributes?.type,
                MIMETypes.ImageMIMETypes(rawValue: mediaMimeType) == nil
            {
                // Incompatible MIME type
            } else {
                self.image = mediaURL
            }
        } else if
            let mediaThumbnails = rssItem.media?.mediaThumbnails?.sorted(by: { a, b in
                guard
                    let aWidthString = a.attributes?.width,
                    let aWidth = Int(aWidthString),
                    let bWidthString = b.attributes?.width,
                    let bWidth = Int(bWidthString)
                else {
                    return false
                }
                return bWidth > aWidth
            }),
            let thumbnail = mediaThumbnails.first,
            let thumbnailURLString = thumbnail.attributes?.url,
            let thumbnailURL = URL(string: thumbnailURLString)
        {
            self.image = thumbnailURL
        }
        
        if let description = rssItem.description?.htmlUnescape() {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: description)
            self.summary = plainSummary
            if self.image == nil {
                self.image = image
            }
        }
        
        if let body = rssItem.content?.contentEncoded {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: body)
            if self.summary == nil {
                self.summary = plainSummary
            }
            if self.image == nil {
                self.image = image
            }
        }
        
        if self.image != nil {
            self.imageLocal = self.createLocalImagePath()
        }
    }
    
    /**
     Creates item entity from a JSON feed item
     */
    public func ingest(_ jsonItem: JSONFeedItem) {
        // Prefer RSS pubDate element for published date
        if let published = jsonItem.datePublished {
            self.published = published
        }
        
        if let title = jsonItem.title {
            self.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            self.title = "Untitled"
        }

        if let urlString = jsonItem.url, let link = URL(string: urlString) {
            self.link = link
        } else if let urlString = jsonItem.id, let link = URL(string: urlString) {
            self.link = link
        }
        
        if let imageAttachment = jsonItem.attachments?.first(where: { attachment in
            if let mimeTypeString = attachment.mimeType, let _ = MIMETypes.ImageMIMETypes(rawValue: mimeTypeString) {
                return true
            }
            return false
        }) {
            if let imageString = imageAttachment.url, let image = URL(string: imageString) {
                self.image = image
            }
        }
        
        if let summary = jsonItem.summary {
            self.summary = HTMLCleaner.stripTags(summary)?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if self.image != nil {
            self.imageLocal = self.createLocalImagePath()
        }
    }
    
    private func createLocalImagePath() -> URL? {
        let directoryPath = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last!
            .appendingPathExtension("Images/")
        
        if !FileManager.default.fileExists(atPath: directoryPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Logger.main.critical("Could not create Images directory \(directoryPath.absoluteString)")
            }
        }
        
        guard let filename = self.id?.uuidString.appending(".png") else { return nil }
        
        let filepath = directoryPath.appendingPathExtension(filename)
        
        return filepath
    }
}
