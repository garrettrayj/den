//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import HTMLEntities
import SwiftSoup

@objc(Item)
public class Item: NSManagedObject, Identifiable {
    public var wrappedTitle: String {
        get{title ?? "Untitled"}
        set{title = newValue}
    }
    
    func markRead() {
        if read == true { return }
        read = true
        
        // Update unread count capsules
        self.feed?.page?.objectWillChange.send()
        
        if self.managedObjectContext?.hasChanges == true {
            do {
                try self.managedObjectContext?.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /**
     Creates item entity from an Atom feed entry
     */
    static func create(atomEntry: AtomFeedEntry, moc managedObjectContext: NSManagedObjectContext, feed: Feed) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feed = feed

        if let published = atomEntry.published {
            item.published = published
        } else {
            if let published = atomEntry.updated {
                item.published = published
            }
        }
        
        if let title = atomEntry.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }
        
        item.link = atomEntry.linkURL
        
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
                item.image = imageURL
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
                item.image = mediaURL
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
            item.image = thumbnailURL
        }
        
        if let summary = atomEntry.summary?.value?.htmlUnescape() {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: summary)
            item.summary = plainSummary
            if item.image == nil && image != nil {
                item.image = image
            }
        }
        
        if let body = atomEntry.content?.value?.htmlUnescape() {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: body)
            if item.summary == nil {
                item.summary = plainSummary
            }
            if item.image == nil {
                item.image = image
            }
        }
        
        return item
    }
    
    /**
     Creates item entity from a RSS feed item
     */
    static func create(rssItem: RSSFeedItem, moc managedObjectContext: NSManagedObjectContext, feed: Feed) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feed = feed
        
        // Prefer RSS pubDate element for published date
        if let published = rssItem.pubDate {
            item.published = published
        } else {
            // Fallback to Dublin Core metadata for published date (ex. http://feeds.feedburner.com/oatmealfeed does not have pubDate)
            if let published = rssItem.dublinCore?.dcDate {
                item.published = published
            }
        }
        
        if let title = rssItem.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }

        item.link = rssItem.linkURL
        
        // Look for preview image in <enclosure> and <media:content>
        if
            let enclosure = rssItem.enclosure,
            let mimeTypeString = enclosure.attributes?.type,
            let _ = MIMETypes.ImageMIMETypes(rawValue: mimeTypeString),
            let enclosureURLString = enclosure.attributes?.url,
            let enclosureURL = URL(string: enclosureURLString)
        {
            item.image = enclosureURL
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
                item.image = mediaURL
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
                item.image = mediaURL
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
            item.image = thumbnailURL
        }
        
        if let description = rssItem.description?.htmlUnescape() {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: description)
            item.summary = plainSummary
            if item.image == nil {
                item.image = image
            }
        }
        
        if let body = rssItem.content?.contentEncoded {
            let (plainSummary, image) = HTMLCleaner.extractSummaryAndImage(summaryFragment: body)
            if item.summary == nil {
                item.summary = plainSummary
            }
            if item.image == nil {
                item.image = image
            }
        }
        
        return item
    }
    
    /**
     Creates item entity from a JSON feed item
     */
    static func create(jsonItem: JSONFeedItem, moc managedObjectContext: NSManagedObjectContext, feed: Feed) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feed = feed
        
        // Prefer RSS pubDate element for published date
        if let published = jsonItem.datePublished {
            item.published = published
        }
        
        if let title = jsonItem.title {
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines).htmlUnescape()
        } else {
            item.title = "Untitled"
        }

        if let urlString = jsonItem.url, let link = URL(string: urlString) {
            item.link = link
        } else if let urlString = jsonItem.id, let link = URL(string: urlString) {
            item.link = link
        }
        
        if let imageAttachment = jsonItem.attachments?.first(where: { attachment in
            if let mimeTypeString = attachment.mimeType, let _ = MIMETypes.ImageMIMETypes(rawValue: mimeTypeString) {
                return true
            }
            return false
        }) {
            if let imageString = imageAttachment.url, let image = URL(string: imageString) {
                item.image = image
            }
        }
        
        if let summary = jsonItem.summary {
            item.summary = HTMLCleaner.stripTags(summary)?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return item
    }
}
